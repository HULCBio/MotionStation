;; $Id: dbl1dege.dsl 1.11 1998/10/30 15:20:51 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://nwalsh.com/docbook/dsssl/
;;

;; ----------------------------- Localization -----------------------------

;; If you create a new version of this file, please send it to
;; Norman Walsh, ndw@nwalsh.com

;; Thanks to Rainer Feuerstein, fire@informatik.uni-wuerzburg.de and
;; Christian Leutloff, leutloff@sundancer.oche.de for many of these
;; translations.

;; The generated text for cross references to elements.  See dblink.dsl
;; for a discussion of how substitution is performed on the %x 
;; keywords.
;;

(define (dege-appendix-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Appendix; %n"
      "&Appendix; namens %t"))

(define (dege-article-xref-string gi-or-name)
  (string-append %gentext-dege-start-quote%
		 "%t"
		 %gentext-dege-end-quote%))

(define (dege-bibliography-xref-string gi-or-name)
  "%t")

(define (dege-book-xref-string gi-or-name)
  "%t")

(define (dege-chapter-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Chapter; %n"
      "&Chapter; namens %t"))

(define (dege-equation-xref-string gi-or-name)
  "&Equation; %n")

(define (dege-example-xref-string gi-or-name)
  "&Example; %n")

(define (dege-figure-xref-string gi-or-name)
  "&Figure; %n")

(define (dege-listitem-xref-string gi-or-name)
  "%n")

(define (dege-part-xref-string gi-or-name)
  "&Part; %n")

(define (dege-preface-xref-string gi-or-name)
  "%t")

(define (dege-procedure-xref-string gi-or-name)
  "&Procedure; %n, %t")

(define (dege-section-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "&Section; namens %t"))

(define (dege-sect1-xref-string gi-or-name)
  (dege-section-xref-string gi-or-name))

(define (dege-sect2-xref-string gi-or-name)
  (dege-section-xref-string gi-or-name))

(define (dege-sect3-xref-string gi-or-name)
  (dege-section-xref-string gi-or-name))

(define (dege-sect4-xref-string gi-or-name)
  (dege-section-xref-string gi-or-name))

(define (dege-sect5-xref-string gi-or-name)
  (dege-section-xref-string gi-or-name))

(define (dege-step-xref-string gi-or-name)
  "&Step; %n")

(define (dege-table-xref-string gi-or-name)
  "&Table; %n")

(define (dege-default-xref-string gi-or-name)
  (let* ((giname (if (string? gi-or-name) gi-or-name (gi gi-or-name)))
	 (msg    (string-append "[&xrefto; "
				(if giname giname "&nonexistantelement;")
				" &unsupported;]"))
	 (err    (node-list-error msg (current-node))))
    msg))

(define (gentext-dege-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
      ((equal? name (normalize "appendix")) (dege-appendix-xref-string gind))
      ((equal? name (normalize "article"))  (dege-article-xref-string gind))
      ((equal? name (normalize "bibliography")) (dege-bibliography-xref-string gind))
      ((equal? name (normalize "book"))     (dege-book-xref-string gind))
      ((equal? name (normalize "chapter"))  (dege-chapter-xref-string gind))
      ((equal? name (normalize "equation")) (dege-equation-xref-string gind))
      ((equal? name (normalize "example"))  (dege-example-xref-string gind))
      ((equal? name (normalize "figure"))   (dege-figure-xref-string gind))
      ((equal? name (normalize "listitem")) (dege-listitem-xref-string gind))
      ((equal? name (normalize "part"))     (dege-part-xref-string gind))
      ((equal? name (normalize "preface"))  (dege-preface-xref-string gind))
      ((equal? name (normalize "procedure")) (dege-procedure-xref-string gind))
      ((equal? name (normalize "sect1"))    (dege-sect1-xref-string gind))
      ((equal? name (normalize "sect2"))    (dege-sect2-xref-string gind))
      ((equal? name (normalize "sect3"))    (dege-sect3-xref-string gind))
      ((equal? name (normalize "sect4"))    (dege-sect4-xref-string gind))
      ((equal? name (normalize "sect5"))    (dege-sect5-xref-string gind))
      ((equal? name (normalize "step"))     (dege-step-xref-string gind))
      ((equal? name (normalize "table"))    (dege-table-xref-string gind))
      (else (dege-default-xref-string gind)))))

(define (dege-auto-xref-indirect-connector before) 
  (literal " &in; "))

;; Should the TOC come first or last?
;;
(define %generate-dege-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;
(define dege-abstract-name	"&Abstract;")
(define dege-appendix-name	"&Appendix;")
(define dege-article-name	"&Article;")
(define dege-bibliography-name	"&Bibliography;")
(define dege-book-name		"&Book;")
(define dege-calloutlist-name   "")
(define dege-caution-name	"&Caution;")
(define dege-chapter-name	"&Chapter;")
(define dege-copyright-name	"&Copyright;")
(define dege-dedication-name	"&Dedication;")
(define dege-edition-name	"&Edition;")
(define dege-equation-name	"&Equation;")
(define dege-example-name	"&Example;")
(define dege-figure-name	"&Figure;")
(define dege-glossary-name	"&Glossary;")
(define dege-glosssee-name	"&GlossSee;")
(define dege-glossseealso-name	"&GlossSeeAlso;")
(define dege-important-name	"&Important;")
(define dege-index-name		"&Index;")
(define dege-setindex-name	"&SetIndex;")
(define dege-isbn-name		"&ISBN;")
(define dege-legalnotice-name	"")
(define dege-msgaud-name	"&MsgAud;")
(define dege-msglevel-name	"&MsgLevel;")
(define dege-msgorig-name	"&MsgOrig;")
(define dege-note-name		"&Note;")
(define dege-part-name		"&Part;")
(define dege-preface-name	"&Preface;")
(define dege-procedure-name	"&Procedure;")
(define dege-pubdate-name	"&Published;")
(define dege-reference-name	"&Reference;")
(define dege-refname-name	"&RefName;")
(define dege-revhistory-name	"&RevHistory;")
(define dege-revision-name	"&Revision;")
(define dege-sect1-name		"&Section;")
(define dege-sect2-name		"&Section;")
(define dege-sect3-name		"&Section;")
(define dege-sect4-name		"&Section;")
(define dege-sect5-name		"&Section;")
(define dege-simplesect-name	"&Section;")
(define dege-seeie-name		"&See;")
(define dege-seealsoie-name	"&Seealso;")
(define dege-set-name		"&Set;")
(define dege-sidebar-name	"&Sidebar;")
(define dege-step-name		"&step;")
(define dege-table-name		"&Table;")
(define dege-tip-name		"&Tip;")
(define dege-toc-name		"&TableofContents;")
(define dege-warning-name	"&Warning;")

(define (gentext-dege-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract"))	dege-abstract-name)
     ((equal? name (normalize "appendix"))	dege-appendix-name)
     ((equal? name (normalize "article"))	dege-article-name)
     ((equal? name (normalize "bibliography"))	dege-bibliography-name)
     ((equal? name (normalize "book"))		dege-book-name)
     ((equal? name (normalize "calloutlist"))	dege-calloutlist-name)
     ((equal? name (normalize "caution"))	dege-caution-name)
     ((equal? name (normalize "chapter"))	dege-chapter-name)
     ((equal? name (normalize "copyright"))	dege-copyright-name)
     ((equal? name (normalize "dedication"))	dege-dedication-name)
     ((equal? name (normalize "edition"))	dege-edition-name)
     ((equal? name (normalize "equation"))	dege-equation-name)
     ((equal? name (normalize "example"))	dege-example-name)
     ((equal? name (normalize "figure"))	dege-figure-name)
     ((equal? name (normalize "glossary"))	dege-glossary-name)
     ((equal? name (normalize "glosssee"))	dege-glosssee-name)
     ((equal? name (normalize "glossseealso"))	dege-glossseealso-name)
     ((equal? name (normalize "important"))	dege-important-name)
     ((equal? name (normalize "index"))		dege-index-name)
     ((equal? name (normalize "setindex"))	dege-setindex-name)
     ((equal? name (normalize "isbn"))		dege-isbn-name)
     ((equal? name (normalize "legalnotice"))	dege-legalnotice-name)
     ((equal? name (normalize "msgaud"))	dege-msgaud-name)
     ((equal? name (normalize "msglevel"))	dege-msglevel-name)
     ((equal? name (normalize "msgorig"))	dege-msgorig-name)
     ((equal? name (normalize "note"))		dege-note-name)
     ((equal? name (normalize "part"))		dege-part-name)
     ((equal? name (normalize "preface"))	dege-preface-name)
     ((equal? name (normalize "procedure"))	dege-procedure-name)
     ((equal? name (normalize "pubdate"))	dege-pubdate-name)
     ((equal? name (normalize "reference"))	dege-reference-name)
     ((equal? name (normalize "refname"))	dege-refname-name)
     ((equal? name (normalize "revhistory"))	dege-revhistory-name)
     ((equal? name (normalize "revision"))	dege-revision-name)
     ((equal? name (normalize "sect1"))		dege-sect1-name)
     ((equal? name (normalize "sect2"))		dege-sect2-name)
     ((equal? name (normalize "sect3"))		dege-sect3-name)
     ((equal? name (normalize "sect4"))		dege-sect4-name)
     ((equal? name (normalize "sect5"))		dege-sect5-name)
     ((equal? name (normalize "simplesect"))	dege-simplesect-name)
     ((equal? name (normalize "seeie"))		dege-seeie-name)
     ((equal? name (normalize "seealsoie"))	dege-seealsoie-name)
     ((equal? name (normalize "set"))		dege-set-name)
     ((equal? name (normalize "sidebar"))	dege-sidebar-name)
     ((equal? name (normalize "step"))		dege-step-name)
     ((equal? name (normalize "table"))		dege-table-name)
     ((equal? name (normalize "tip"))		dege-tip-name)
     ((equal? name (normalize "toc"))		dege-toc-name)
     ((equal? name (normalize "warning"))	dege-warning-name)
     (else (let* ((msg (string-append "&unexpectedelementname;: " name))
		  (err (node-list-error msg (current-node))))
	     msg)))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-dege-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define dege-equation-intra-label-sep "-")
(define dege-example-intra-label-sep "-")
(define dege-figure-intra-label-sep "-")
(define dege-procedure-intra-label-sep ".")
(define dege-refentry-intra-label-sep ".")
(define dege-reference-intra-label-sep ".")
(define dege-refname-intra-label-sep ", ")
(define dege-refsect1-intra-label-sep ".")
(define dege-refsect2-intra-label-sep ".")
(define dege-refsect3-intra-label-sep ".")
(define dege-sect1-intra-label-sep ".")
(define dege-sect2-intra-label-sep ".")
(define dege-sect3-intra-label-sep ".")
(define dege-sect4-intra-label-sep ".")
(define dege-sect5-intra-label-sep ".")
(define dege-step-intra-label-sep ".")
(define dege-table-intra-label-sep "-")
(define dege-_pagenumber-intra-label-sep "-")
(define dege-default-intra-label-sep "")

(define (gentext-dege-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "equation"))	dege-equation-intra-label-sep)
     ((equal? name (normalize "example"))	dege-example-intra-label-sep)
     ((equal? name (normalize "figure"))	dege-figure-intra-label-sep)
     ((equal? name (normalize "procedure"))	dege-procedure-intra-label-sep)
     ((equal? name (normalize "refentry"))	dege-refentry-intra-label-sep)
     ((equal? name (normalize "reference"))	dege-reference-intra-label-sep)
     ((equal? name (normalize "refname"))	dege-refname-intra-label-sep)
     ((equal? name (normalize "refsect1"))	dege-refsect1-intra-label-sep)
     ((equal? name (normalize "refsect2"))	dege-refsect2-intra-label-sep)
     ((equal? name (normalize "refsect3"))	dege-refsect3-intra-label-sep)
     ((equal? name (normalize "sect1"))		dege-sect1-intra-label-sep)
     ((equal? name (normalize "sect2"))		dege-sect2-intra-label-sep)
     ((equal? name (normalize "sect3"))		dege-sect3-intra-label-sep)
     ((equal? name (normalize "sect4"))		dege-sect4-intra-label-sep)
     ((equal? name (normalize "sect5"))		dege-sect5-intra-label-sep)
     ((equal? name (normalize "step"))		dege-step-intra-label-sep)
     ((equal? name (normalize "table"))		dege-table-intra-label-sep)
     ((equal? name (normalize "_pagenumber"))	dege-_pagenumber-intra-label-sep)
     (else dege-default-intra-label-sep))))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define dege-abstract-label-title-sep ": ")
(define dege-appendix-label-title-sep ". ")
(define dege-caution-label-title-sep "")
(define dege-chapter-label-title-sep ". ")
(define dege-equation-label-title-sep ". ")
(define dege-example-label-title-sep ". ")
(define dege-figure-label-title-sep ". ")
(define dege-footnote-label-title-sep ". ")
(define dege-glosssee-label-title-sep ": ")
(define dege-glossseealso-label-title-sep ": ")
(define dege-important-label-title-sep ": ")
(define dege-note-label-title-sep ": ")
(define dege-orderedlist-label-title-sep ". ")
(define dege-part-label-title-sep ". ")
(define dege-procedure-label-title-sep ". ")
(define dege-prefix-label-title-sep ". ")
(define dege-refentry-label-title-sep "")
(define dege-reference-label-title-sep ". ")
(define dege-refsect1-label-title-sep ". ")
(define dege-refsect2-label-title-sep ". ")
(define dege-refsect3-label-title-sep ". ")
(define dege-sect1-label-title-sep ". ")
(define dege-sect2-label-title-sep ". ")
(define dege-sect3-label-title-sep ". ")
(define dege-sect4-label-title-sep ". ")
(define dege-sect5-label-title-sep ". ")
(define dege-seeie-label-title-sep " ")
(define dege-seealsoie-label-title-sep " ")
(define dege-step-label-title-sep ". ")
(define dege-table-label-title-sep ". ")
(define dege-tip-label-title-sep ": ")
(define dege-warning-label-title-sep "")
(define dege-default-label-title-sep "")

(define (gentext-dege-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract")) dege-abstract-label-title-sep)
     ((equal? name (normalize "appendix")) dege-appendix-label-title-sep)
     ((equal? name (normalize "caution")) dege-caution-label-title-sep)
     ((equal? name (normalize "chapter")) dege-chapter-label-title-sep)
     ((equal? name (normalize "equation")) dege-equation-label-title-sep)
     ((equal? name (normalize "example")) dege-example-label-title-sep)
     ((equal? name (normalize "figure")) dege-figure-label-title-sep)
     ((equal? name (normalize "footnote")) dege-footnote-label-title-sep)
     ((equal? name (normalize "glosssee")) dege-glosssee-label-title-sep)
     ((equal? name (normalize "glossseealso")) dege-glossseealso-label-title-sep)
     ((equal? name (normalize "important")) dege-important-label-title-sep)
     ((equal? name (normalize "note")) dege-note-label-title-sep)
     ((equal? name (normalize "orderedlist")) dege-orderedlist-label-title-sep)
     ((equal? name (normalize "part")) dege-part-label-title-sep)
     ((equal? name (normalize "procedure")) dege-procedure-label-title-sep)
     ((equal? name (normalize "prefix")) dege-prefix-label-title-sep)
     ((equal? name (normalize "refentry")) dege-refentry-label-title-sep)
     ((equal? name (normalize "reference")) dege-reference-label-title-sep)
     ((equal? name (normalize "refsect1")) dege-refsect1-label-title-sep)
     ((equal? name (normalize "refsect2")) dege-refsect2-label-title-sep)
     ((equal? name (normalize "refsect3")) dege-refsect3-label-title-sep)
     ((equal? name (normalize "sect1")) dege-sect1-label-title-sep)
     ((equal? name (normalize "sect2")) dege-sect2-label-title-sep)
     ((equal? name (normalize "sect3")) dege-sect3-label-title-sep)
     ((equal? name (normalize "sect4")) dege-sect4-label-title-sep)
     ((equal? name (normalize "sect5")) dege-sect5-label-title-sep)
     ((equal? name (normalize "seeie")) dege-seeie-label-title-sep)
     ((equal? name (normalize "seealsoie")) dege-seealsoie-label-title-sep)
     ((equal? name (normalize "step")) dege-step-label-title-sep)
     ((equal? name (normalize "table")) dege-table-label-title-sep)
     ((equal? name (normalize "tip")) dege-tip-label-title-sep)
     ((equal? name (normalize "warning")) dege-warning-label-title-sep)
     (else dege-default-label-title-sep))))

(define (dege-set-label-number-format gind) "1")
(define (dege-book-label-number-format gind) "1")
(define (dege-prefix-label-number-format gind) "1")
(define (dege-part-label-number-format gind) "I")
(define (dege-chapter-label-number-format gind) "1")
(define (dege-appendix-label-number-format gind) "A")
(define (dege-reference-label-number-format gind) "I")
(define (dege-example-label-number-format gind) "1")
(define (dege-figure-label-number-format gind) "1")
(define (dege-table-label-number-format gind) "1")
(define (dege-procedure-label-number-format gind) "1")
(define (dege-step-label-number-format gind) "1")
(define (dege-refsect1-label-number-format gind) "1")
(define (dege-refsect2-label-number-format gind) "1")
(define (dege-refsect3-label-number-format gind) "1")
(define (dege-sect1-label-number-format gind) "1")
(define (dege-sect2-label-number-format gind) "1")
(define (dege-sect3-label-number-format gind) "1")
(define (dege-sect4-label-number-format gind) "1")
(define (dege-sect5-label-number-format gind) "1")
(define (dege-default-label-number-format gind) "1")

(define (dege-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "set")) (dege-set-label-number-format gind))
     ((equal? name (normalize "book")) (dege-book-label-number-format gind))
     ((equal? name (normalize "prefix")) (dege-prefix-label-number-format gind))
     ((equal? name (normalize "part")) (dege-part-label-number-format gind))
     ((equal? name (normalize "chapter")) (dege-chapter-label-number-format gind))
     ((equal? name (normalize "appendix")) (dege-appendix-label-number-format gind))
     ((equal? name (normalize "reference")) (dege-reference-label-number-format gind))
     ((equal? name (normalize "example")) (dege-example-label-number-format gind))
     ((equal? name (normalize "figure")) (dege-figure-label-number-format gind))
     ((equal? name (normalize "table")) (dege-table-label-number-format gind))
     ((equal? name (normalize "procedure")) (dege-procedure-label-number-format gind))
     ((equal? name (normalize "step")) (dege-step-label-number-format gind))
     ((equal? name (normalize "refsect1")) (dege-refsect1-label-number-format gind))
     ((equal? name (normalize "refsect2")) (dege-refsect2-label-number-format gind))
     ((equal? name (normalize "refsect3")) (dege-refsect3-label-number-format gind))
     ((equal? name (normalize "sect1")) (dege-sect1-label-number-format gind))
     ((equal? name (normalize "sect2")) (dege-sect2-label-number-format gind))
     ((equal? name (normalize "sect3")) (dege-sect3-label-number-format gind))
     ((equal? name (normalize "sect4")) (dege-sect4-label-number-format gind))
     ((equal? name (normalize "sect5")) (dege-sect5-label-number-format gind))
     (else (dege-default-label-number-format gind)))))

(define ($lot-title-dege$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond ((equal? name (normalize "table"))    "&ListofTables;")
	  ((equal? name (normalize "example"))  "&ListofExamples;")
	  ((equal? name (normalize "figure"))   "&ListofFigures;")
	  ((equal? name (normalize "equation")) "&ListofEquations;")
	  (else (let* ((msg (string-append "&ListofUnknown;: " name))
		       (err (node-list-error msg (current-node))))
		  msg)))))

(define %gentext-dege-start-quote% "\U-201E;")
(define %gentext-dege-end-quote% "\U-201C;")

(define %gentext-dege-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-dege-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-dege-page% "")

(define %gentext-dege-and% "&and;")

(define %gentext-dege-bibl-pages% "&Pgs;")

(define %gentext-dege-endnotes% "&Notes;") ;; szlig

(define %gentext-dege-table-endnotes% "&TableNotes;:")

(define %gentext-dege-index-see% "&See;")

(define %gentext-dege-index-seealso% "&SeeAlso;")
