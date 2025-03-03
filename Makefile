all: build

build:
	mkdir build
	nasm -f elf64 src/main.asm -o build/x86press.o
	ld build/x86press.o -o build/x86press

clean:
	rm -rf build
