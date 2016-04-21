;; $Id: dbl1bmno.dsl 1.11 1998/10/30 15:20:51 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://nwalsh.com/docbook/dsssl/
;;

;; ----------------------------- Localization -----------------------------

;; Norsk Bokm\U-00E5;l localization. (a-ring)
;; Translated by Stig S. Bakken, ssb@guardian.no
;; Send changes to Norman Walsh, ndw@nwalsh.com

;; The generated text for cross references to elements.  See dblink.dsl
;; for a discussion of how substitution is performed on the %x
;; keywords.
;;

(define (bmno-appendix-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Appendix; %n"
      "tillegget kalt %t"))

(define (bmno-article-xref-string gi-or-name)
  (string-append %gentext-bmno-start-quote%
		 "%t"
		 %gentext-bmno-end-quote%))

(define (bmno-bibliography-xref-string gi-or-name)
  "%t")

(define (bmno-book-xref-string gi-or-name)
  "%t")

(define (bmno-chapter-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Chapter; %n"
      "kapittelet kalt %t"))

(define (bmno-equation-xref-string gi-or-name)
  "&Equation; %n")

(define (bmno-example-xref-string gi-or-name)
  "&Example; %n")

(define (bmno-figure-xref-string gi-or-name)
  "&Figure; %n")

(define (bmno-listitem-xref-string gi-or-name)
  "%n")

(define (bmno-part-xref-string gi-or-name)
  "&Part; %n")

(define (bmno-preface-xref-string gi-or-name)
  "%t")

(define (bmno-procedure-xref-string gi-or-name)
  "&Procedure; %n, %t")

(define (bmno-section-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "seksjonen kalt %t"))

(define (bmno-sect1-xref-string gi-or-name)
  (bmno-section-xref-string gi-or-name))

(define (bmno-sect2-xref-string gi-or-name)
  (bmno-section-xref-string gi-or-name))

(define (bmno-sect3-xref-string gi-or-name)
  (bmno-section-xref-string gi-or-name))

(define (bmno-sect4-xref-string gi-or-name)
  (bmno-section-xref-string gi-or-name))

(define (bmno-sect5-xref-string gi-or-name)
  (bmno-section-xref-string gi-or-name))

(define (bmno-step-xref-string gi-or-name)
  "&Step; %n")

(define (bmno-table-xref-string gi-or-name)
  "&Table; %n")

(define (bmno-default-xref-string gi-or-name)
  (let* ((giname (if (string? gi-or-name) gi-or-name (gi gi-or-name)))
	 (msg    (string-append "[&xrefto; "
				(if giname giname "&nonexistantelement;")
				" &unsupported;]"))
	 (err    (node-list-error msg (current-node))))
    msg))

(define (gentext-bmno-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
      ((equal? name (normalize "appendix")) (bmno-appendix-xref-string gind))
      ((equal? name (normalize "article"))  (bmno-article-xref-string gind))
      ((equal? name (normalize "bibliography")) (bmno-bibliography-xref-string gind))
      ((equal? name (normalize "book"))     (bmno-book-xref-string gind))
      ((equal? name (normalize "chapter"))  (bmno-chapter-xref-string gind))
      ((equal? name (normalize "equation")) (bmno-equation-xref-string gind))
      ((equal? name (normalize "example"))  (bmno-example-xref-string gind))
      ((equal? name (normalize "figure"))   (bmno-figure-xref-string gind))
      ((equal? name (normalize "listitem")) (bmno-listitem-xref-string gind))
      ((equal? name (normalize "part"))     (bmno-part-xref-string gind))
      ((equal? name (normalize "preface"))  (bmno-preface-xref-string gind))
      ((equal? name (normalize "procedure")) (bmno-procedure-xref-string gind))
      ((equal? name (normalize "sect1"))    (bmno-sect1-xref-string gind))
      ((equal? name (normalize "sect2"))    (bmno-sect2-xref-string gind))
      ((equal? name (normalize "sect3"))    (bmno-sect3-xref-string gind))
      ((equal? name (normalize "sect4"))    (bmno-sect4-xref-string gind))
      ((equal? name (normalize "sect5"))    (bmno-sect5-xref-string gind))
      ((equal? name (normalize "step"))     (bmno-step-xref-string gind))
      ((equal? name (normalize "table"))    (bmno-table-xref-string gind))
      (else (bmno-default-xref-string gind)))))

(define (bmno-auto-xref-indirect-connector before) 
  (literal " &in; "))

;; Should the TOC come first or last?
;;
(define %generate-bmno-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;
(define bmno-abstract-name	"&Abstract;")
(define bmno-appendix-name	"&Appendix;")
(define bmno-article-name	"&Article;")
(define bmno-bibliography-name	"&Bibliography;")
(define bmno-book-name		"&Book;")
(define bmno-calloutlist-name   "")
(define bmno-caution-name	"&Caution;")
(define bmno-chapter-name	"&Chapter;")
(define bmno-copyright-name	"&Copyright;")
(define bmno-dedication-name	"&Dedication;")
(define bmno-edition-name	"&Edition;")
(define bmno-equation-name	"&Equation;")
(define bmno-example-name	"&Example;")
(define bmno-figure-name	"&Figure;")
(define bmno-glossary-name	"&Glossary;")
(define bmno-glosssee-name	"&GlossSee;")
(define bmno-glossseealso-name	"&GlossSeeAlso;")
(define bmno-important-name	"&Important;")
(define bmno-index-name		"&Index;")
(define bmno-setindex-name	"&SetIndex;")
(define bmno-isbn-name		"&ISBN;")
(define bmno-legalnotice-name	"")
(define bmno-msgaud-name	"&MsgAud;")
(define bmno-msglevel-name	"&MsgLevel;")
(define bmno-msgorig-name	"&MsgOrig;")
(define bmno-note-name		"&Note;")
(define bmno-part-name		"&Part;")
(define bmno-preface-name	"&Preface;")
(define bmno-procedure-name	"&Procedure;")
(define bmno-pubdate-name	"&Published;")
(define bmno-reference-name	"&Reference;")
(define bmno-refname-name	"&RefName;")
(define bmno-revhistory-name	"&RevHistory;")
(define bmno-revision-name	"&Revision;")
(define bmno-sect1-name		"&Section;")
(define bmno-sect2-name		"&Section;")
(define bmno-sect3-name		"&Section;")
(define bmno-sect4-name		"&Section;")
(define bmno-sect5-name		"&Section;")
(define bmno-simplesect-name	"&Section;")
(define bmno-seeie-name		"&See;")
(define bmno-seealsoie-name	"&Seealso;")
(define bmno-set-name		"&Set;")
(define bmno-sidebar-name	"&Sidebar;")
(define bmno-step-name		"&step;")
(define bmno-table-name		"&Table;")
(define bmno-tip-name		"&Tip;")
(define bmno-toc-name		"&TableofContents;")
(define bmno-warning-name	"&Warning;")

(define (gentext-bmno-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract"))	bmno-abstract-name)
     ((equal? name (normalize "appendix"))	bmno-appendix-name)
     ((equal? name (normalize "article"))	bmno-article-name)
     ((equal? name (normalize "bibliography"))	bmno-bibliography-name)
     ((equal? name (normalize "book"))		bmno-book-name)
     ((equal? name (normalize "calloutlist"))	bmno-calloutlist-name)
     ((equal? name (normalize "caution"))	bmno-caution-name)
     ((equal? name (normalize "chapter"))	bmno-chapter-name)
     ((equal? name (normalize "copyright"))	bmno-copyright-name)
     ((equal? name (normalize "dedication"))	bmno-dedication-name)
     ((equal? name (normalize "edition"))	bmno-edition-name)
     ((equal? name (normalize "equation"))	bmno-equation-name)
     ((equal? name (normalize "example"))	bmno-example-name)
     ((equal? name (normalize "figure"))	bmno-figure-name)
     ((equal? name (normalize "glossary"))	bmno-glossary-name)
     ((equal? name (normalize "glosssee"))	bmno-glosssee-name)
     ((equal? name (normalize "glossseealso"))	bmno-glossseealso-name)
     ((equal? name (normalize "important"))	bmno-important-name)
     ((equal? name (normalize "index"))		bmno-index-name)
     ((equal? name (normalize "setindex"))	bmno-setindex-name)
     ((equal? name (normalize "isbn"))		bmno-isbn-name)
     ((equal? name (normalize "legalnotice"))	bmno-legalnotice-name)
     ((equal? name (normalize "msgaud"))	bmno-msgaud-name)
     ((equal? name (normalize "msglevel"))	bmno-msglevel-name)
     ((equal? name (normalize "msgorig"))	bmno-msgorig-name)
     ((equal? name (normalize "note"))		bmno-note-name)
     ((equal? name (normalize "part"))		bmno-part-name)
     ((equal? name (normalize "preface"))	bmno-preface-name)
     ((equal? name (normalize "procedure"))	bmno-procedure-name)
     ((equal? name (normalize "pubdate"))	bmno-pubdate-name)
     ((equal? name (normalize "reference"))	bmno-reference-name)
     ((equal? name (normalize "refname"))	bmno-refname-name)
     ((equal? name (normalize "revhistory"))	bmno-revhistory-name)
     ((equal? name (normalize "revision"))	bmno-revision-name)
     ((equal? name (normalize "sect1"))		bmno-sect1-name)
     ((equal? name (normalize "sect2"))		bmno-sect2-name)
     ((equal? name (normalize "sect3"))		bmno-sect3-name)
     ((equal? name (normalize "sect4"))		bmno-sect4-name)
     ((equal? name (normalize "sect5"))		bmno-sect5-name)
     ((equal? name (normalize "simplesect"))	bmno-simplesect-name)
     ((equal? name (normalize "seeie"))		bmno-seeie-name)
     ((equal? name (normalize "seealsoie"))	bmno-seealsoie-name)
     ((equal? name (normalize "set"))		bmno-set-name)
     ((equal? name (normalize "sidebar"))	bmno-sidebar-name)
     ((equal? name (normalize "step"))		bmno-step-name)
     ((equal? name (normalize "table"))		bmno-table-name)
     ((equal? name (normalize "tip"))		bmno-tip-name)
     ((equal? name (normalize "toc"))		bmno-toc-name)
     ((equal? name (normalize "warning"))	bmno-warning-name)
     (else (let* ((msg (string-append "&unexpectedelementname;: " name))
		  (err (node-list-error msg (current-node))))
	     msg)))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-bmno-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define bmno-equation-intra-label-sep "-")
(define bmno-example-intra-label-sep "-")
(define bmno-figure-intra-label-sep "-")
(define bmno-procedure-intra-label-sep ".")
(define bmno-refentry-intra-label-sep ".")
(define bmno-reference-intra-label-sep ".")
(define bmno-refname-intra-label-sep ", ")
(define bmno-refsect1-intra-label-sep ".")
(define bmno-refsect2-intra-label-sep ".")
(define bmno-refsect3-intra-label-sep ".")
(define bmno-sect1-intra-label-sep ".")
(define bmno-sect2-intra-label-sep ".")
(define bmno-sect3-intra-label-sep ".")
(define bmno-sect4-intra-label-sep ".")
(define bmno-sect5-intra-label-sep ".")
(define bmno-step-intra-label-sep ".")
(define bmno-table-intra-label-sep "-")
(define bmno-_pagenumber-intra-label-sep "-")
(define bmno-default-intra-label-sep "")

(define (gentext-bmno-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "equation"))	bmno-equation-intra-label-sep)
     ((equal? name (normalize "example"))	bmno-example-intra-label-sep)
     ((equal? name (normalize "figure"))	bmno-figure-intra-label-sep)
     ((equal? name (normalize "procedure"))	bmno-procedure-intra-label-sep)
     ((equal? name (normalize "refentry"))	bmno-refentry-intra-label-sep)
     ((equal? name (normalize "reference"))	bmno-reference-intra-label-sep)
     ((equal? name (normalize "refname"))	bmno-refname-intra-label-sep)
     ((equal? name (normalize "refsect1"))	bmno-refsect1-intra-label-sep)
     ((equal? name (normalize "refsect2"))	bmno-refsect2-intra-label-sep)
     ((equal? name (normalize "refsect3"))	bmno-refsect3-intra-label-sep)
     ((equal? name (normalize "sect1"))		bmno-sect1-intra-label-sep)
     ((equal? name (normalize "sect2"))		bmno-sect2-intra-label-sep)
     ((equal? name (normalize "sect3"))		bmno-sect3-intra-label-sep)
     ((equal? name (normalize "sect4"))		bmno-sect4-intra-label-sep)
     ((equal? name (normalize "sect5"))		bmno-sect5-intra-label-sep)
     ((equal? name (normalize "step"))		bmno-step-intra-label-sep)
     ((equal? name (normalize "table"))		bmno-table-intra-label-sep)
     ((equal? name (normalize "_pagenumber"))	bmno-_pagenumber-intra-label-sep)
     (else bmno-default-intra-label-sep))))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define bmno-abstract-label-title-sep ": ")
(define bmno-appendix-label-title-sep ". ")
(define bmno-caution-label-title-sep "")
(define bmno-chapter-label-title-sep ". ")
(define bmno-equation-label-title-sep ". ")
(define bmno-example-label-title-sep ". ")
(define bmno-figure-label-title-sep ". ")
(define bmno-footnote-label-title-sep ". ")
(define bmno-glosssee-label-title-sep ": ")
(define bmno-glossseealso-label-title-sep ": ")
(define bmno-important-label-title-sep ": ")
(define bmno-note-label-title-sep ": ")
(define bmno-orderedlist-label-title-sep ". ")
(define bmno-part-label-title-sep ". ")
(define bmno-procedure-label-title-sep ". ")
(define bmno-prefix-label-title-sep ". ")
(define bmno-refentry-label-title-sep "")
(define bmno-reference-label-title-sep ". ")
(define bmno-refsect1-label-title-sep ". ")
(define bmno-refsect2-label-title-sep ". ")
(define bmno-refsect3-label-title-sep ". ")
(define bmno-sect1-label-title-sep ". ")
(define bmno-sect2-label-title-sep ". ")
(define bmno-sect3-label-title-sep ". ")
(define bmno-sect4-label-title-sep ". ")
(define bmno-sect5-label-title-sep ". ")
(define bmno-seeie-label-title-sep " ")
(define bmno-seealsoie-label-title-sep " ")
(define bmno-step-label-title-sep ". ")
(define bmno-table-label-title-sep ". ")
(define bmno-tip-label-title-sep ": ")
(define bmno-warning-label-title-sep "")
(define bmno-default-label-title-sep "")

(define (gentext-bmno-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract")) bmno-abstract-label-title-sep)
     ((equal? name (normalize "appendix")) bmno-appendix-label-title-sep)
     ((equal? name (normalize "caution")) bmno-caution-label-title-sep)
     ((equal? name (normalize "chapter")) bmno-chapter-label-title-sep)
     ((equal? name (normalize "equation")) bmno-equation-label-title-sep)
     ((equal? name (normalize "example")) bmno-example-label-title-sep)
     ((equal? name (normalize "figure")) bmno-figure-label-title-sep)
     ((equal? name (normalize "footnote")) bmno-footnote-label-title-sep)
     ((equal? name (normalize "glosssee")) bmno-glosssee-label-title-sep)
     ((equal? name (normalize "glossseealso")) bmno-glossseealso-label-title-sep)
     ((equal? name (normalize "important")) bmno-important-label-title-sep)
     ((equal? name (normalize "note")) bmno-note-label-title-sep)
     ((equal? name (normalize "orderedlist")) bmno-orderedlist-label-title-sep)
     ((equal? name (normalize "part")) bmno-part-label-title-sep)
     ((equal? name (normalize "procedure")) bmno-procedure-label-title-sep)
     ((equal? name (normalize "prefix")) bmno-prefix-label-title-sep)
     ((equal? name (normalize "refentry")) bmno-refentry-label-title-sep)
     ((equal? name (normalize "reference")) bmno-reference-label-title-sep)
     ((equal? name (normalize "refsect1")) bmno-refsect1-label-title-sep)
     ((equal? name (normalize "refsect2")) bmno-refsect2-label-title-sep)
     ((equal? name (normalize "refsect3")) bmno-refsect3-label-title-sep)
     ((equal? name (normalize "sect1")) bmno-sect1-label-title-sep)
     ((equal? name (normalize "sect2")) bmno-sect2-label-title-sep)
     ((equal? name (normalize "sect3")) bmno-sect3-label-title-sep)
     ((equal? name (normalize "sect4")) bmno-sect4-label-title-sep)
     ((equal? name (normalize "sect5")) bmno-sect5-label-title-sep)
     ((equal? name (normalize "seeie")) bmno-seeie-label-title-sep)
     ((equal? name (normalize "seealsoie")) bmno-seealsoie-label-title-sep)
     ((equal? name (normalize "step")) bmno-step-label-title-sep)
     ((equal? name (normalize "table")) bmno-table-label-title-sep)
     ((equal? name (normalize "tip")) bmno-tip-label-title-sep)
     ((equal? name (normalize "warning")) bmno-warning-label-title-sep)
     (else bmno-default-label-title-sep))))

(define (bmno-set-label-number-format gind) "1")
(define (bmno-book-label-number-format gind) "1")
(define (bmno-prefix-label-number-format gind) "1")
(define (bmno-part-label-number-format gind) "I")
(define (bmno-chapter-label-number-format gind) "1")
(define (bmno-appendix-label-number-format gind) "A")
(define (bmno-reference-label-number-format gind) "I")
(define (bmno-example-label-number-format gind) "1")
(define (bmno-figure-label-number-format gind) "1")
(define (bmno-table-label-number-format gind) "1")
(define (bmno-procedure-label-number-format gind) "1")
(define (bmno-step-label-number-format gind) "1")
(define (bmno-refsect1-label-number-format gind) "1")
(define (bmno-refsect2-label-number-format gind) "1")
(define (bmno-refsect3-label-number-format gind) "1")
(define (bmno-sect1-label-number-format gind) "1")
(define (bmno-sect2-label-number-format gind) "1")
(define (bmno-sect3-label-number-format gind) "1")
(define (bmno-sect4-label-number-format gind) "1")
(define (bmno-sect5-label-number-format gind) "1")
(define (bmno-default-label-number-format gind) "1")

(define (bmno-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "set")) (bmno-set-label-number-format gind))
     ((equal? name (normalize "book")) (bmno-book-label-number-format gind))
     ((equal? name (normalize "prefix")) (bmno-prefix-label-number-format gind))
     ((equal? name (normalize "part")) (bmno-part-label-number-format gind))
     ((equal? name (normalize "chapter")) (bmno-chapter-label-number-format gind))
     ((equal? name (normalize "appendix")) (bmno-appendix-label-number-format gind))
     ((equal? name (normalize "reference")) (bmno-reference-label-number-format gind))
     ((equal? name (normalize "example")) (bmno-example-label-number-format gind))
     ((equal? name (normalize "figure")) (bmno-figure-label-number-format gind))
     ((equal? name (normalize "table")) (bmno-table-label-number-format gind))
     ((equal? name (normalize "procedure")) (bmno-procedure-label-number-format gind))
     ((equal? name (normalize "step")) (bmno-step-label-number-format gind))
     ((equal? name (normalize "refsect1")) (bmno-refsect1-label-number-format gind))
     ((equal? name (normalize "refsect2")) (bmno-refsect2-label-number-format gind))
     ((equal? name (normalize "refsect3")) (bmno-refsect3-label-number-format gind))
     ((equal? name (normalize "sect1")) (bmno-sect1-label-number-format gind))
     ((equal? name (normalize "sect2")) (bmno-sect2-label-number-format gind))
     ((equal? name (normalize "sect3")) (bmno-sect3-label-number-format gind))
     ((equal? name (normalize "sect4")) (bmno-sect4-label-number-format gind))
     ((equal? name (normalize "sect5")) (bmno-sect5-label-number-format gind))
     (else (bmno-default-label-number-format gind)))))

(define ($lot-title-bmno$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond ((equal? name (normalize "table"))    "&ListofTables;")
	  ((equal? name (normalize "example"))  "&ListofExamples;")
	  ((equal? name (normalize "figure"))   "&ListofFigures;")
	  ((equal? name (normalize "equation")) "&ListofEquations;")
	  (else (let* ((msg (string-append "&ListofUnknown;: " name))
		       (err (node-list-error msg (current-node))))
		  msg)))))

(define %gentext-bmno-start-quote%  (dingbat "ldquo"))

(define %gentext-bmno-end-quote%  (dingbat "rdquo"))

(define %gentext-bmno-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-bmno-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-bmno-page% "")

(define %gentext-bmno-and% "&and;")

(define %gentext-bmno-bibl-pages% "&Pgs;")

(define %gentext-bmno-endnotes% "&Notes;")

(define %gentext-bmno-table-endnotes% "&TableNotes;:")

(define %gentext-bmno-index-see% "&See;")

(define %gentext-bmno-index-seealso% "&SeeAlso;")

