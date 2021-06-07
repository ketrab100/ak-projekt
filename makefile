all: test

test: test.o
	ld test.o -m elf_i386 -o test

test.o: test.s
	as test.s --32 -o test.o -g