VERSION = 0.4
DIST_FILES = Makefile Makefile.dep $(ML_FILES) $(MLI_FILES)

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
	./origami

xtest: origami
	./origami > test.xpm
	display test.xpm
            
clean:
	rm -f origami $(CMI_FILES) $(CMO_FILES) $(CMX_FILES) $(O_FILES) test.xpm
	$(OCAMLDEP) $(ML_FILES) > Makefile.dep

distclean:
	rm -f origami-$(VERSION).tar.*

dist: distclean
	fakeroot tar cf origami-$(VERSION).tar $(DIST_FILES)
	bzip2 -9 origami-$(VERSION).tar

.PHONY: all clean distclean dist test xtest

# vim:ts=4 sw=4

