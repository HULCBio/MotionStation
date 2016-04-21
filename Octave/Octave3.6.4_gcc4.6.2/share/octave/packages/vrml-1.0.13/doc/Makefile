sinclude ../../../Makeconf

TEX = vrml-mini-howto-1.tex
PDF = $(patsubst %.tex,%.pdf,$(TEX))
DVIPDF = dvipdf

all : $(PDF)

%.pdf : %.tex
	if [ `which latex` ] && [ `which $(DVIPDF)` ] ; then \
		latex -interaction=nonstopmode $< > /dev/null 2>&1 ; \
		latex -interaction=nonstopmode $< > /dev/null 2>&1 ; \
		$(DVIPDF) $(@:.pdf=.dvi) ; \
	else \
		echo "Lacking programs to build doc. Skipping" ; \
	fi 

# Note verbosity=0 as well as making latex2html quieter, has the side-effect
# of not including a url to the raw text, which it'll get wrong
html/index.html : $(TEX)
	if [ -e `which latex2html` ] ; then \
		latex2html -verbosity=0 -local_icons $< ; \
		if [ -e "html" ]; then \
		  rm -fr html; \
		fi; \
		mv -f $(patsubst %.tex,%,$<) html ; \
	fi

clean:
	rm -fr $(patsubst %.tex,%,$(TEX)) html *.log
	rm -f $(patsubst %.tex,%.aux,$(TEX))
	rm -f $(patsubst %.tex,%.out,$(TEX))
	rm -f $(patsubst %.tex,%.dvi,$(TEX))

realclean:	clean
	rm -f $(PDF) *~
