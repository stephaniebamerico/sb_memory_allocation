prog: alocar.s aux.s def.s desalocar.s inicia_finaliza.s prog.s makefile mem.s lista.s
	as -g alocar.s  -o alocar.o
	as -g aux.s  -o aux.o
	as -g def.s  -o def.o
	as -g desalocar.s  -o desalocar.o
	as -g inicia_finaliza.s  -o inicia_finaliza.o
	as -g prog.s  -o prog.o
	as -g mem.s  -o mem.o
	as -g lista.s  -o lista.o

	ld -I /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc alocar.o aux.o def.o desalocar.o inicia_finaliza.o prog.o mem.o lista.o -o prog

clean:
	-rm *.o
