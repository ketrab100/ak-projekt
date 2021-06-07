all: test

test: test.o
	ld test.o -o test

test.o: test.s
	as test.s -o test.o -g