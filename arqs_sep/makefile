AS_FLAGS=--gstabs+

all: prog.o
	ld -I /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -s *.o -o prog

clean:
	-rm *.o

purge: clean
	-rm prog

#---------

prog.o: alocar.o debug.o def.o imprimeMapa.o inicia_finaliza.o libera.o
	as $(AS_FLAGS) prog.s -o prog.o
alocar.o: def.o
	as $(AS_FLAGS) alocar.s -o alocar.o
debug.o: def.o
	as $(AS_FLAGS) debug.s -o debug.o
def.o:
	as $(AS_FLAGS) def.s -o def.o
imprimeMapa.o: def.o
	as $(AS_FLAGS) imprimeMapa.s -o imprimeMapa.o
inicia_finaliza.o:
	as $(AS_FLAGS) inicia_finaliza.s -o inicia_finaliza.o
libera.o: def.o
	as $(AS_FLAGS) libera.s -o libera.o
