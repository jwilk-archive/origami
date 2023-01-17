# Copyright © 2004-2023 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

MLI_FILES = origami.mli
ML_FILES  = forlist.ml origami.ml main.ml
CMI_FILES = $(ML_FILES:ml=cmi)
CMO_FILES = $(ML_FILES:ml=cmo)
CMX_FILES = $(ML_FILES:ml=cmx)
O_FILES   = $(ML_FILES:ml=o)

ifdef NATIVE
	OCAMLC = ocamlopt.opt
	STRIP = strip -s
	OBJ_FILES = $(CMX_FILES)
else
	OCAMLC = ocamlc.opt
	STRIP = true
	OBJ_FILES = $(CMO_FILES)
endif
OCAMLDEP = ocamldep.opt

all: origami

include Makefile.dep

%.cmi: %.mli
	$(OCAMLC) ${^} -o ${@}

ifdef NATIVE
%.cmx: %.ml
	$(OCAMLC) -c ${<}
else
%.cmo: %.ml
	$(OCAMLC) -c ${<}
endif

origami: $(OBJ_FILES)
	$(OCAMLC) ${^} -o ${@}
	$(STRIP) ${@}

test: origami
	./origami < TestFile.ori

xtest: origami
	./origami < TestFile.ori > TestFile.xpm && \
	display TestFile.xpm

clean:
	rm -f origami $(CMI_FILES) $(CMO_FILES) $(CMX_FILES) $(O_FILES) TestFile.xpm
	$(OCAMLDEP) $(ML_FILES) > Makefile.dep

.PHONY: all clean test xtest

# vim:ts=4 sts=4 sw=4
