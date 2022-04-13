CC = gcc -no-pie -m64
CFLAGS = -Wall
ALLEGROFLAGS = $$(pkg-config --libs allegro-5)
LDFLAGS = -L/usr/lib -lallegro
INCLUDE = -I/usr/include/allegro5

all: main.o julia.o
	$(CC) $(CFLAGS) -o julia main.o julia.o  $(INCLUDE) $(LDFLAGS)

julia.o: julia.asm
	nasm -f elf64 -o julia.o julia.asm

main.o: main.c
	$(CC) $(CFLAGS) -c main.c -o main.o $$(pkg-config --libs allegro-5)

clean:
	rm -f *.o