all: prog
	ld -I /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -s *.o -o prog

clean:
	-rm *.o

purge: clean
	-rm prog

#---------

prog: alocar.o debug.o def.o inicia_finaliza.o libera.o
	as prog.s -o prog.o
alocar: def.o
	as alocar.s -o alocar.o
debug: def.o
	as debug.s -o debug.o
def:
	as def.s -o def.o
inicia_finaliza:
	as inicia_finaliza.s -o inicia_finaliza.o
libera: def.o
	as libera.s -o libera.o
