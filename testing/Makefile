all: teken_test

teken_test: teken_test.c teken.o
	gcc -std=c99 -Wall -I.. -oteken_test \
		teken_test.c \
		teken.o

teken.o: ../third_party/libteken/teken/teken.c \
		../third_party/libteken/teken/teken.h \
		../third_party/libteken/teken/teken_state.h
	gcc -std=c99 -Wall "-D__unused=__attribute__((unused))" -c \
		../third_party/libteken/teken/teken.c
