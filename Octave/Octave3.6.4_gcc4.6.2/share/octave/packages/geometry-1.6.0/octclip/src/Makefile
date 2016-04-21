# -*- coding: utf-8 -*-
ifndef MKOCTFILE
MKOCTFILE := mkoctfile
endif

CLIPOBJECT = calctopo.o compilador.o dpeucker.o errores.o eucli.o fgeneral.o \
             geocnan.o geocomp.o greiner.o polig.o polil.o ptopol.o recpolil.o \
             segmento.o ventorno.o
FLAGS = -Wall -Wextra

%.o: %.c
	$(MKOCTFILE) $(FLAGS) -I. -c $<

%.oct: %.cc $(CLIPOBJECT)
	$(MKOCTFILE) $< $(CLIPOBJECT) $(FLAGS) -v  -I.

all: _oc_polybool.oct

clean:
	rm -rf *.o *~
