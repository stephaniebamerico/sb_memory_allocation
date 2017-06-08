prog: alocar.s aux.s def.s desalocar.s inicia_finaliza.s prog.s
	as alocar.s -o alocar.o
	as aux.s -o aux.o
	as def.s -o def.o
	as desalocar.s -o desalocar.o
	as inicia_finaliza.s -o inicia_finaliza.o
	as prog.s -o prog.o

	ld -I /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -s alocar.o aux.o def.o desalocar.o inicia_finaliza.o prog.o -o prog

clean:
	-rm *.o
