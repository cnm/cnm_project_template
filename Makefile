LATEX = latex
BIBTEX = bibtex
L2H = latex2html
PDFLATEX = ps2pdf
DVIPS = dvips
RM = rm -f

# Rename CHANGE_THIS to the filename of your main .tex file (do not include the .tex)
# MASTER = template_project_latex

MASTER = CHANGE_THIS

# Obtain the architecture
ifndef _ARCH
	_ARCH := $(shell uname)
	export _ARCH
endif
# Location of Inkscape depends on the OS
ifeq ($(_ARCH),Linux)
	INKSCAPE = inkscape
endif
ifeq ($(_ARCH),Darwin)
	INKSCAPE = /Applications/Inkscape.app/Contents/Resources/bin/inkscape
endif


RERUN = "(There were undefined references|Rerun to get	\
	(cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

TEXFILES = $(wildcard *.tex *.cls *.sty)
FIGURES = $(wildcard figures/*.eps)
FIGURES_GEN = $(patsubst %.svg,%.eps,$(wildcard figures/*.svg))
FIGURES_GEN += $(patsubst %.dia,%.eps,$(wildcard figures/*.dia))
FIGURES += $(FIGURES_GEN)
BIBFILES = $(wildcard *.bib)

# Avoid regenerating the figures all the time
.SECONDARY : $(FIGURES_GEN)

.PHONY: clean mrproper

all:		$(MASTER).ps $(MASTER).pdf

%.dvi: 		%.tex

%.dvi:		$(FIGURES) $(TEXFILES) $(BIBFILES)
		if test -r $*.toc; then cp $*.toc $*.toc.bak; fi
		$(LATEX) $*.tex
		egrep -c $(RERUNBIB) $*.log && ($(BIBTEX) $*;$(LATEX) $*.tex) ; true
		egrep $(RERUN) $*.log && ($(LATEX) $*.tex) ; true
		egrep $(RERUN) $*.log && ($(LATEX) $*.tex) ; true
		if cmp -s $*.toc $*.toc.bak; then echo ;else $(LATEX) $* ; fi
		$(RM) $*.toc.bak
# Display relevant warnings
		egrep -i "(Reference|Citation).*undefined" $*.log ; true

%.ps:		%.dvi
		dvips -t letter -Ppdf -G0 $< -o $@

%.pdf:		%.ps
		$(PDFLATEX) -dPDFSETTINGS=/prepress		\
		-dCompatibilityLevel=1.5 -dMaxSubsetPct=100	\
		-dSubsetFonts=true -dEmbedAllFonts=true		\
		-dCompressPages=true -dUseFlateCompression=true	\
		-dASCII85EncodePages=false $<;

%.eps:		%.svg
#		inkscape --without-gui --export-text-to-path --export-eps=$@ --file=$<
		$(INKSCAPE) --without-gui --export-text-to-path --export-eps=$@ --file=$<

%.eps: 		%.dia
		dia -n -t eps-builtin -e $@ $<

clean:
		rm -f $(MASTER).aux $(MASTER).log $(MASTER).bbl		\
		$(MASTER).blg $(MASTER).brf $(MASTER).cb $(MASTER).ind	\
		$(MASTER).idx $(MASTER).ilg $(MASTER).inx $(MASTER).ps	\
		$(MASTER).dvi $(MASTER).pdf $(MASTER).toc $(MASTER).out \
		$(MASTER).fff $(MASTER).lof texput.log 
# 		\
#		$(FIGURES_GEN)

rmproper:	clean
		find . -iname "*~" | xargs rm -f

view:		${MASTER}.pdf
		evince ${MASTER}.pdf &

pdf:	all
