all: teken_test_filter

teken_test_filter: teken_test_filter.c teken.o
	gcc -std=c99 -Wall -g -I.. -oteken_test_filter \
		teken_test_filter.c \
		teken.o

teken.o: ../third_party/libteken/teken/teken.c \
		../third_party/libteken/teken/teken.h \
		../third_party/libteken/teken/teken_state.h
	gcc -std=c99 -Wall -g "-D__unused=__attribute__((unused))" -c \
		../third_party/libteken/teken/teken.c
