//Proyecto N°1: Simulador de Caché de Correspondencia Directa y Asociativa por Vías
//Gabriela Mora V-31.541.893
//Lucia Martinez V-31.906.577
//Maivet Pereira V-30.814.708

#include <iostream>
#include <vector>
#include <fstream>
#include <string>

using namespace std;

//constante para el tamaño del bloque en palabras
const int tamanoBloque = 4;

//estructura que representa una linea de cache
struct lineaCache
{
    int datos[tamanoBloque];  //array para almacenar un bloque completo
    int tag;
    int ultimoUso;  //contador de reloj para LRU
    bool valido;

    lineaCache(): tag(-1), ultimoUso(0), valido(false)
    {
        for(int i = 0; i < tamanoBloque; i++){
            datos[i] = 0;
        }
    }
};

//clase que simula una cache asociativa por conjuntos
class caches
{
    private:

    int numConjuntos;
    int vias;
    int reloj; //contador global para implementar LRU
    int aciertos;
    int fallos;
    int anticipo; //cantidad de direcciones a precargar (prefetch)

    vector<vector<lineaCache>> conjuntos; //matriz: conjuntos x vias

    //funcion que precarga (prefetch) direcciones futuras
    void precargar(int direccion, int cantidad)
    {
        for (int p = 1; p <= cantidad; p++)
        {
            //calcula la direccion del siguiente bloque
            int dirBloque = direccion + (p * tamanoBloque);
            int indice = (dirBloque / tamanoBloque) % numConjuntos;
            int tag = dirBloque / (tamanoBloque * numConjuntos);
            
            bool encontrado = false;

            for (int i = 0; i < vias; i++)
            {
                if (conjuntos[indice][i].valido && conjuntos[indice][i].tag == tag)
                {
                    encontrado = true;
                    //NO actualizamos ultimoUso para no distorsionar LRU
                    break;
                }
            }
            
            if (!encontrado)
            {
                for (int i = 0; i < vias; i++)
                {
                    if (!conjuntos[indice][i].valido)
                    {
                        conjuntos[indice][i].tag = tag;
                        for(int j = 0; j < tamanoBloque; j++)
                            conjuntos[indice][i].datos[j] = dirBloque + j;
                        conjuntos[indice][i].valido = true;
                        conjuntos[indice][i].ultimoUso = reloj;
                        break;
                    }
                }
            }
        }
    }

    public:

    //inicializa la cache con N conjuntos, V vias y opcionalmente prefetch
    caches(int conj, int v, int ant = 0): numConjuntos(conj), vias(v), reloj(0), 
        aciertos(0), fallos(0), anticipo(ant)
    {
        conjuntos.resize(numConjuntos, vector<lineaCache>(vias)); //redimensiona la matriz
    }

    //funcion que simula una lectura de memoria
    bool leer(int direccion, int &dato)
    {
        reloj++; //incrementa el reloj global para LRU
        
        int indice = (direccion / tamanoBloque) % numConjuntos;
        int tag = direccion / (tamanoBloque * numConjuntos);
        int offset = direccion % tamanoBloque;

        for (int i = 0; i < vias; i++)
        {
            if (conjuntos[indice][i].valido && conjuntos[indice][i].tag == tag)
            {
                dato = conjuntos[indice][i].datos[offset];
                conjuntos[indice][i].ultimoUso = reloj;
                aciertos++;
                
                if (anticipo > 0) //si hay prefetch activado
                {
                    precargar(direccion, anticipo); //precarga direcciones futuras
                }
                return (true);
            }
        }

        fallos++;

        for (int i = 0; i < vias; i++)
        {
            if (!conjuntos[indice][i].valido)
            {
                conjuntos[indice][i].tag = tag;
                for(int j = 0; j < tamanoBloque; j++)
                    conjuntos[indice][i].datos[j] = direccion - offset + j;
                conjuntos[indice][i].valido = true;
                conjuntos[indice][i].ultimoUso = reloj;
                dato = conjuntos[indice][i].datos[offset];

                if (anticipo > 0) //si hay prefetch activado
                {
                    precargar(direccion, anticipo); //precarga direcciones futuras
                }
                return (false);
            }
        }

        //si no hay lineas vacias, se aplica la politica de reemplazo LRU
        int lru = 0;

        //recorre todas las vias para encontrar la de menor ultimoUso (la mas antigua)
        for (int i = 1; i < vias; i++)
        {
            if (conjuntos[indice][i].ultimoUso < conjuntos[indice][lru].ultimoUso)
            {
                lru = i; //actualiza el indice de la linea LRU
            }
        }

        //reemplaza la linea LRU con el nuevo bloque
        conjuntos[indice][lru].tag = tag;
        for(int j = 0; j < tamanoBloque; j++)
            conjuntos[indice][lru].datos[j] = direccion - offset + j;
        conjuntos[indice][lru].valido = true;
        conjuntos[indice][lru].ultimoUso = reloj;

        dato = conjuntos[indice][lru].datos[offset];

        if (anticipo > 0) //si hay prefetch activado
        {
            precargar(direccion, anticipo); //precarga direcciones futuras
        }

        return (false); //fallo con reemplazo LRU
    }

    //muestra las estadisticas de la cache
    void estadisticas()
    {
        cout << "Aciertos: " << aciertos << endl;
        cout << "Fallos: " << fallos << endl;
        cout << "Total: " << aciertos + fallos << endl;
        cout << "Tasa: " << (float)aciertos / (aciertos + fallos) * 100 << "%" << endl;
    }

    int obtenerAciertos() const { return aciertos; }
    int obtenerFallos() const { return fallos; }
};

//funcion que compara diferentes configuraciones de cache
void comparar(vector<int>& direcciones, int viasMax, int anticipo = 0)
{
    int dato;

    cout << "Esquema        | Aciertos | Fallos | Tasa" << endl;
    cout << "---------------|----------|--------|------" << endl;

    for (int v = 1; v <= viasMax; v *= 2)
    {
        int conjuntos = 16 / v;

        caches cache(conjuntos, v, anticipo);

        for (size_t i = 0; i < direcciones.size(); i++)
        {
            cache.leer(direcciones[i], dato);
        }

        if (v == 1)
        {
            cout << "Directa        | ";
        }
        else
        {
            cout << v << " vias         | ";
        }

        cout << cache.obtenerAciertos() << "       | " << cache.obtenerFallos() << "      | ";
        cout << (float)cache.obtenerAciertos() / (cache.obtenerAciertos() + cache.obtenerFallos()) * 100 << "%" << endl;
    }
}

//funcion que lee las direcciones desde un archivo
void leerArchivo(vector<int>& direcciones)
{
    ifstream archivo("entradaCache.txt");
    int dir;
    
    direcciones.clear();
    
    if (archivo.is_open())
    {
        while (archivo >> dir)
        {
            direcciones.push_back(dir);
        }
        archivo.close();
        cout << "Direcciones cargadas desde entradaCache.txt: " << direcciones.size() << endl;
    }
    else
    {
        cout << "No se pudo abrir el archivo entradaCache.txt" << endl;
    }
}

//funcion que muestra el menu interactivo
void menu()
{
    vector<int> direcciones; //almacena las direcciones ingresadas por el usuario

    int opcion;
    int dato;

    do
    {
        cout << "\n--- MENU ---" << endl;
        cout << "1. Cargar direcciones desde archivo (entradaCache.txt)" << endl;
        cout << "2. Ver estadisticas" << endl;
        cout << "3. Comparar esquemas" << endl;
        cout << "4. Salir" << endl;
        cout << "Opcion: ";
        cin >> opcion;

        if (opcion == 1) //cargar direcciones desde archivo
        {
            leerArchivo(direcciones);
        }
        else if (opcion == 2) //ver estadisticas con cache directa por defecto
        {
            if (direcciones.empty())
            {
                cout << "Primero cargue direcciones (opcion 1)" << endl;
            }
            else
            {
                caches temp(16, 1);
                
                for (size_t i = 0; i < direcciones.size(); i++)
                {
                    temp.leer(direcciones[i], dato);
                }
                
                temp.estadisticas();
            }
        }
        else if (opcion == 3) //comparar diferentes esquemas
        {
            if (direcciones.empty())
            {
                cout << "Primero cargue direcciones (opcion 1)" << endl;
            }
            else
            {
                int viasMax;
                int anticipo;
                
                cout << "Hasta cuantas vias quiere probar? (1, 2, 4, 8, 16): ";
                cin >> viasMax;
                
                cout << "Cuantas direcciones adelante quiere anticipar? (0 = nada): ";
                cin >> anticipo;
                
                comparar(direcciones, viasMax, anticipo); //llama a la funcion de comparacion
            }
        }
        else if (opcion == 4) //salir
        {
            cout << "Saliendo..." << endl;
        }
        else
        {
            cout << "Opcion no valida" << endl;
        }
        
    } while (opcion != 4);
}

int main()
{
    menu();

    return 0;
}

//gracias:)
