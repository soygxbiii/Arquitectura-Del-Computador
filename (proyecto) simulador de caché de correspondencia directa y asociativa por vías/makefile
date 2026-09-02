CXX = g++
CXXFLAGS = -std=c++11 -Wall -g

SRC = proyecto.cpp
OBJ = $(SRC:.cpp=.o)
TARGET = proyecto

#compila todo
all: $(TARGET)

#crea el ejecutable uniendo los archivos compilados
$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^
	
#compila cada archivo .c en un archivo .o
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $<

#ejecuta el programa
run: $(TARGET)
	./proyecto

#borra los archivos compilados y el ejecutable
clean:
	rm -f *.o proyecto

#limpia y recompila todo desde cero
rebuild: clean all
