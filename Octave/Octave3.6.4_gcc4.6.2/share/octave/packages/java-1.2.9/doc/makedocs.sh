#!/bin/sh

# create all sorts of docs
makeinfo octave-java.texi --html -o octave-java.html
texi2dvi octave-java.texi -o octave-java.dvi
dvips -t a4 -Ppdf octave-java.dvi -o octave-java.ps
ps2pdf octave-java.ps -o octave-java.pdf
rm octave-java.ps
rm octave-java.dvi

makeinfo octave-java.texi -o octave-java.info
cp octave-java.info doc.info

