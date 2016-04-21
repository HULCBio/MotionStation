;; $Id: dbl1dk.dsl 1.1 1998/10/30 15:20:01 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://nwalsh.com/docbook/dsssl/
;;

;; ----------------------------- Localization -----------------------------

;; If you create a new version of this file, please send it to
;; Norman Walsh, ndw@nwalsh.com

;; The generated text for cross references to elements.  See dblink.dsl
;; for a discussion of how substitution is performed on the %x 
;; keywords.
;;

(define (dk-appendix-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Appendix; %n"
      "&appendix; med navn %t"))

(define (dk-article-xref-string gi-or-name)
  (string-append %gentext-dk-start-quote%
		 "%t"
		 %gentext-dk-end-quote%))

(define (dk-bibliography-xref-string gi-or-name)
  "%t")

(define (dk-book-xref-string gi-or-name)
  "%t")

(define (dk-chapter-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Chapter; %n"
      "kapitlet om %t"))

(define (dk-equation-xref-string gi-or-name)
  "&Equation; %n")

(define (dk-example-xref-string gi-or-name)
  "&Example; %n")

(define (dk-figure-xref-string gi-or-name)
  "&Figure; %n")

(define (dk-listitem-xref-string gi-or-name)
  "%n")

(define (dk-part-xref-string gi-or-name)
  "&Part; %n")

(define (dk-preface-xref-string gi-or-name)
  "%t")

(define (dk-procedure-xref-string gi-or-name)
  "&Procedure; %n, %t")

(define (dk-sect1-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "sektionen med navn %t"))

(define (dk-sect2-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "undersektionen med navn %t"))

(define (dk-sect3-xref-string gi-or-name)
  (dk-sect2-xref-string gi-or-name))

(define (dk-sect4-xref-string gi-or-name)
  (dk-sect2-xref-string gi-or-name))

(define (dk-sect5-xref-string gi-or-name)
  (dk-sect2-xref-string gi-or-name))

(define (dk-step-xref-string gi-or-name)
  "&step; %n")

(define (dk-table-xref-string gi-or-name)
  "&Table; %n")

(define (dk-default-xref-string gi-or-name)
  (let* ((giname (if (string? gi-or-name) gi-or-name (gi gi-or-name)))
	 (msg    (string-append "[&xrefto; "
				(if giname giname "&nonexistantelement;")
				" &unsupported;]"))
	 (err    (node-list-error msg (current-node))))
    msg))

(define (gentext-dk-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
      ((equal? name (normalize "appendix")) (dk-appendix-xref-string gind))
      ((equal? name (normalize "article"))  (dk-article-xref-string gind))
      ((equal? name (normalize "bibliography")) (dk-bibliography-xref-string gind))
      ((equal? name (normalize "book"))     (dk-book-xref-string gind))
      ((equal? name (normalize "chapter"))  (dk-chapter-xref-string gind))
      ((equal? name (normalize "equation")) (dk-equation-xref-string gind))
      ((equal? name (normalize "example"))  (dk-example-xref-string gind))
      ((equal? name (normalize "figure"))   (dk-figure-xref-string gind))
      ((equal? name (normalize "listitem")) (dk-listitem-xref-string gind))
      ((equal? name (normalize "part"))     (dk-part-xref-string gind))
      ((equal? name (normalize "preface"))  (dk-preface-xref-string gind))
      ((equal? name (normalize "procedure")) (dk-procedure-xref-string gind))
      ((equal? name (normalize "sect1"))    (dk-sect1-xref-string gind))
      ((equal? name (normalize "sect2"))    (dk-sect2-xref-string gind))
      ((equal? name (normalize "sect3"))    (dk-sect3-xref-string gind))
      ((equal? name (normalize "sect4"))    (dk-sect4-xref-string gind))
      ((equal? name (normalize "sect5"))    (dk-sect5-xref-string gind))
      ((equal? name (normalize "step"))     (dk-step-xref-string gind))
      ((equal? name (normalize "table"))    (dk-table-xref-string gind))
      (else (dk-default-xref-string gind)))))

(define (dk-auto-xref-indirect-connector before) 
  (literal " med navn "))

;; Should the TOC come first or last?
;;
(define %generate-dk-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;
(define dk-abstract-name	"&Abstract;")
(define dk-appendix-name	"&Appendix;")
(define dk-article-name	"&Article;")
(define dk-bibliography-name	"&Bibliography;")
(define dk-book-name		"&Book;")
(define dk-calloutlist-name	"")
(define dk-caution-name	"&Caution;")
(define dk-chapter-name	"&Chapter;")
(define dk-copyright-name	"&Copyright;")
(define dk-dedication-name	"&Dedication;")
(define dk-edition-name	"&Edition;")
(define dk-equation-name	"&Equation;")
(define dk-example-name	"&Example;")
(define dk-figure-name	"&Figure;")
(define dk-glossary-name	"&Glossary;")
(define dk-glosssee-name	"&GlossSee;")
(define dk-glossseealso-name	"&GlossSeeAlso;")
(define dk-important-name	"&Important;")
(define dk-index-name		"&Index;")
(define dk-setindex-name	"&SetIndex;")
(define dk-isbn-name		"&ISBN;")
(define dk-legalnotice-name	"&LegalNotice;")
(define dk-msgaud-name	"&MsgAud;")
(define dk-msglevel-name	"&MsgLevel;")
(define dk-msgorig-name	"&MsgOrig;")
(define dk-note-name		"&Note;")
(define dk-part-name		"&Part;")
(define dk-preface-name	"&Preface;")
(define dk-procedure-name	"&Procedure;")
(define dk-pubdate-name	"&Published;")
(define dk-reference-name	"&Reference;")
(define dk-refname-name	"&RefName;")
(define dk-revhistory-name	"&RevHistory;")
(define dk-revision-name	"&Revision;")
(define dk-sect1-name		"&Section;")
(define dk-sect2-name		"&Section;")
(define dk-sect3-name		"&Section;")
(define dk-sect4-name		"&Section;")
(define dk-sect5-name		"&Section;")
(define dk-simplesect-name	"&Section;")
(define dk-seeie-name		"&See;")
(define dk-seealsoie-name	"&Seealso;")
(define dk-set-name		"&Set;")
(define dk-sidebar-name	"&Sidebar;")
(define dk-step-name		"&step;")
(define dk-table-name		"&Table;")
(define dk-tip-name		"&Tip;")
(define dk-toc-name		"&TableofContents;")
(define dk-warning-name	"&Warning;")

(define (gentext-dk-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract"))	dk-abstract-name)
     ((equal? name (normalize "appendix"))	dk-appendix-name)
     ((equal? name (normalize "article"))	dk-article-name)
     ((equal? name (normalize "bibliography"))	dk-bibliography-name)
     ((equal? name (normalize "book"))		dk-book-name)
     ((equal? name (normalize "calloutlist"))	dk-calloutlist-name)
     ((equal? name (normalize "caution"))	dk-caution-name)
     ((equal? name (normalize "chapter"))	dk-chapter-name)
     ((equal? name (normalize "copyright"))	dk-copyright-name)
     ((equal? name (normalize "dedication"))	dk-dedication-name)
     ((equal? name (normalize "edition"))	dk-edition-name)
     ((equal? name (normalize "equation"))	dk-equation-name)
     ((equal? name (normalize "example"))	dk-example-name)
     ((equal? name (normalize "figure"))	dk-figure-name)
     ((equal? name (normalize "glossary"))	dk-glossary-name)
     ((equal? name (normalize "glosssee"))	dk-glosssee-name)
     ((equal? name (normalize "glossseealso"))	dk-glossseealso-name)
     ((equal? name (normalize "important"))	dk-important-name)
     ((equal? name (normalize "index"))		dk-index-name)
     ((equal? name (normalize "setindex"))	dk-setindex-name)
     ((equal? name (normalize "isbn"))		dk-isbn-name)
     ((equal? name (normalize "legalnotice"))	dk-legalnotice-name)
     ((equal? name (normalize "msgaud"))	dk-msgaud-name)
     ((equal? name (normalize "msglevel"))	dk-msglevel-name)
     ((equal? name (normalize "msgorig"))	dk-msgorig-name)
     ((equal? name (normalize "note"))		dk-note-name)
     ((equal? name (normalize "part"))		dk-part-name)
     ((equal? name (normalize "preface"))	dk-preface-name)
     ((equal? name (normalize "procedure"))	dk-procedure-name)
     ((equal? name (normalize "pubdate"))	dk-pubdate-name)
     ((equal? name (normalize "reference"))	dk-reference-name)
     ((equal? name (normalize "refname"))	dk-refname-name)
     ((equal? name (normalize "revhistory"))	dk-revhistory-name)
     ((equal? name (normalize "revision"))	dk-revision-name)
     ((equal? name (normalize "sect1"))		dk-sect1-name)
     ((equal? name (normalize "sect2"))		dk-sect2-name)
     ((equal? name (normalize "sect3"))		dk-sect3-name)
     ((equal? name (normalize "sect4"))		dk-sect4-name)
     ((equal? name (normalize "sect5"))		dk-sect5-name)
     ((equal? name (normalize "simplesect"))    dk-simplesect-name)
     ((equal? name (normalize "seeie"))		dk-seeie-name)
     ((equal? name (normalize "seealsoie"))	dk-seealsoie-name)
     ((equal? name (normalize "set"))		dk-set-name)
     ((equal? name (normalize "sidebar"))	dk-sidebar-name)
     ((equal? name (normalize "step"))		dk-step-name)
     ((equal? name (normalize "table"))		dk-table-name)
     ((equal? name (normalize "tip"))		dk-tip-name)
     ((equal? name (normalize "toc"))		dk-toc-name)
     ((equal? name (normalize "warning"))	dk-warning-name)
     (else (let* ((msg (string-append "&unexpectedelementname;: " name))
		  (err (node-list-error msg (current-node))))
	     msg)))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-dk-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define dk-equation-intra-label-sep "-")
(define dk-example-intra-label-sep "-")
(define dk-figure-intra-label-sep "-")
(define dk-procedure-intra-label-sep ".")
(define dk-refentry-intra-label-sep ".")
(define dk-reference-intra-label-sep ".")
(define dk-refname-intra-label-sep ", ")
(define dk-refsect1-intra-label-sep ".")
(define dk-refsect2-intra-label-sep ".")
(define dk-refsect3-intra-label-sep ".")
(define dk-sect1-intra-label-sep ".")
(define dk-sect2-intra-label-sep ".")
(define dk-sect3-intra-label-sep ".")
(define dk-sect4-intra-label-sep ".")
(define dk-sect5-intra-label-sep ".")
(define dk-step-intra-label-sep ".")
(define dk-table-intra-label-sep "-")
(define dk-_pagenumber-intra-label-sep "-")
(define dk-default-intra-label-sep "")

(define (gentext-dk-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "equation"))	dk-equation-intra-label-sep)
     ((equal? name (normalize "example"))	dk-example-intra-label-sep)
     ((equal? name (normalize "figure"))	dk-figure-intra-label-sep)
     ((equal? name (normalize "procedure"))	dk-procedure-intra-label-sep)
     ((equal? name (normalize "refentry"))	dk-refentry-intra-label-sep)
     ((equal? name (normalize "reference"))	dk-reference-intra-label-sep)
     ((equal? name (normalize "refname"))	dk-refname-intra-label-sep)
     ((equal? name (normalize "refsect1"))	dk-refsect1-intra-label-sep)
     ((equal? name (normalize "refsect2"))	dk-refsect2-intra-label-sep)
     ((equal? name (normalize "refsect3"))	dk-refsect3-intra-label-sep)
     ((equal? name (normalize "sect1"))		dk-sect1-intra-label-sep)
     ((equal? name (normalize "sect2"))		dk-sect2-intra-label-sep)
     ((equal? name (normalize "sect3"))		dk-sect3-intra-label-sep)
     ((equal? name (normalize "sect4"))		dk-sect4-intra-label-sep)
     ((equal? name (normalize "sect5"))		dk-sect5-intra-label-sep)
     ((equal? name (normalize "step"))		dk-step-intra-label-sep)
     ((equal? name (normalize "table"))		dk-table-intra-label-sep)
     ((equal? name (normalize "_pagenumber"))	dk-_pagenumber-intra-label-sep)
     (else dk-default-intra-label-sep))))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define dk-abstract-label-title-sep ": ")
(define dk-appendix-label-title-sep ". ")
(define dk-caution-label-title-sep "")
(define dk-chapter-label-title-sep ". ")
(define dk-equation-label-title-sep ". ")
(define dk-example-label-title-sep ". ")
(define dk-figure-label-title-sep ". ")
(define dk-footnote-label-title-sep ". ")
(define dk-glosssee-label-title-sep ": ")
(define dk-glossseealso-label-title-sep ": ")
(define dk-important-label-title-sep ": ")
(define dk-note-label-title-sep ": ")
(define dk-orderedlist-label-title-sep ". ")
(define dk-part-label-title-sep ". ")
(define dk-procedure-label-title-sep ". ")
(define dk-prefix-label-title-sep ". ")
(define dk-refentry-label-title-sep "")
(define dk-reference-label-title-sep ". ")
(define dk-refsect1-label-title-sep ". ")
(define dk-refsect2-label-title-sep ". ")
(define dk-refsect3-label-title-sep ". ")
(define dk-sect1-label-title-sep ". ")
(define dk-sect2-label-title-sep ". ")
(define dk-sect3-label-title-sep ". ")
(define dk-sect4-label-title-sep ". ")
(define dk-sect5-label-title-sep ". ")
(define dk-seeie-label-title-sep " ")
(define dk-seealsoie-label-title-sep " ")
(define dk-step-label-title-sep ". ")
(define dk-table-label-title-sep ". ")
(define dk-tip-label-title-sep ": ")
(define dk-warning-label-title-sep "")
(define dk-default-label-title-sep "")

(define (gentext-dk-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract")) dk-abstract-label-title-sep)
     ((equal? name (normalize "appendix")) dk-appendix-label-title-sep)
     ((equal? name (normalize "caution")) dk-caution-label-title-sep)
     ((equal? name (normalize "chapter")) dk-chapter-label-title-sep)
     ((equal? name (normalize "equation")) dk-equation-label-title-sep)
     ((equal? name (normalize "example")) dk-example-label-title-sep)
     ((equal? name (normalize "figure")) dk-figure-label-title-sep)
     ((equal? name (normalize "footnote")) dk-footnote-label-title-sep)
     ((equal? name (normalize "glosssee")) dk-glosssee-label-title-sep)
     ((equal? name (normalize "glossseealso")) dk-glossseealso-label-title-sep)
     ((equal? name (normalize "important")) dk-important-label-title-sep)
     ((equal? name (normalize "note")) dk-note-label-title-sep)
     ((equal? name (normalize "orderedlist")) dk-orderedlist-label-title-sep)
     ((equal? name (normalize "part")) dk-part-label-title-sep)
     ((equal? name (normalize "procedure")) dk-procedure-label-title-sep)
     ((equal? name (normalize "prefix")) dk-prefix-label-title-sep)
     ((equal? name (normalize "refentry")) dk-refentry-label-title-sep)
     ((equal? name (normalize "reference")) dk-reference-label-title-sep)
     ((equal? name (normalize "refsect1")) dk-refsect1-label-title-sep)
     ((equal? name (normalize "refsect2")) dk-refsect2-label-title-sep)
     ((equal? name (normalize "refsect3")) dk-refsect3-label-title-sep)
     ((equal? name (normalize "sect1")) dk-sect1-label-title-sep)
     ((equal? name (normalize "sect2")) dk-sect2-label-title-sep)
     ((equal? name (normalize "sect3")) dk-sect3-label-title-sep)
     ((equal? name (normalize "sect4")) dk-sect4-label-title-sep)
     ((equal? name (normalize "sect5")) dk-sect5-label-title-sep)
     ((equal? name (normalize "seeie")) dk-seeie-label-title-sep)
     ((equal? name (normalize "seealsoie")) dk-seealsoie-label-title-sep)
     ((equal? name (normalize "step")) dk-step-label-title-sep)
     ((equal? name (normalize "table")) dk-table-label-title-sep)
     ((equal? name (normalize "tip")) dk-tip-label-title-sep)
     ((equal? name (normalize "warning")) dk-warning-label-title-sep)
     (else dk-default-label-title-sep))))

(define (dk-set-label-number-format gind) "1")
(define (dk-book-label-number-format gind) "1")
(define (dk-prefix-label-number-format gind) "1")
(define (dk-part-label-number-format gind) "I")
(define (dk-chapter-label-number-format gind) "1")
(define (dk-appendix-label-number-format gind) "A")
(define (dk-reference-label-number-format gind) "I")
(define (dk-example-label-number-format gind) "1")
(define (dk-figure-label-number-format gind) "1")
(define (dk-table-label-number-format gind) "1")
(define (dk-procedure-label-number-format gind) "1")
(define (dk-step-label-number-format gind) "1")
(define (dk-refsect1-label-number-format gind) "1")
(define (dk-refsect2-label-number-format gind) "1")
(define (dk-refsect3-label-number-format gind) "1")
(define (dk-sect1-label-number-format gind) "1")
(define (dk-sect2-label-number-format gind) "1")
(define (dk-sect3-label-number-format gind) "1")
(define (dk-sect4-label-number-format gind) "1")
(define (dk-sect5-label-number-format gind) "1")
(define (dk-default-label-number-format gind) "1")

(define (dk-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "set")) (dk-set-label-number-format gind))
     ((equal? name (normalize "book")) (dk-book-label-number-format gind))
     ((equal? name (normalize "prefix")) (dk-prefix-label-number-format gind))
     ((equal? name (normalize "part")) (dk-part-label-number-format gind))
     ((equal? name (normalize "chapter")) (dk-chapter-label-number-format gind))
     ((equal? name (normalize "appendix")) (dk-appendix-label-number-format gind))
     ((equal? name (normalize "reference")) (dk-reference-label-number-format gind))
     ((equal? name (normalize "example")) (dk-example-label-number-format gind))
     ((equal? name (normalize "figure")) (dk-figure-label-number-format gind))
     ((equal? name (normalize "table")) (dk-table-label-number-format gind))
     ((equal? name (normalize "procedure")) (dk-procedure-label-number-format gind))
     ((equal? name (normalize "step")) (dk-step-label-number-format gind))
     ((equal? name (normalize "refsect1")) (dk-refsect1-label-number-format gind))
     ((equal? name (normalize "refsect2")) (dk-refsect2-label-number-format gind))
     ((equal? name (normalize "refsect3")) (dk-refsect3-label-number-format gind))
     ((equal? name (normalize "sect1")) (dk-sect1-label-number-format gind))
     ((equal? name (normalize "sect2")) (dk-sect2-label-number-format gind))
     ((equal? name (normalize "sect3")) (dk-sect3-label-number-format gind))
     ((equal? name (normalize "sect4")) (dk-sect4-label-number-format gind))
     ((equal? name (normalize "sect5")) (dk-sect5-label-number-format gind))
     (else (dk-default-label-number-format gind)))))

(define ($lot-title-dk$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond ((equal? name (normalize "table"))    "&ListofTables;")
	  ((equal? name (normalize "example"))  "&ListofExamples;")
	  ((equal? name (normalize "figure"))   "&ListofFigures;")
	  ((equal? name (normalize "equation")) "&ListofEquations;")
	  (else (let* ((msg (string-append "&ListofUnknown;: " name))
		       (err (node-list-error msg (current-node))))
		  msg)))))

(define %gentext-dk-start-quote% (dingbat "ldquo"))

(define %gentext-dk-end-quote% (dingbat "rdquo"))

(define %gentext-dk-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-dk-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-dk-page% "")

(define %gentext-dk-and% "&and;")

(define %gentext-dk-bibl-pages% "&Pgs;")

(define %gentext-dk-endnotes% "&Notes;")

(define %gentext-dk-table-endnotes% "&TableNotes;:")

(define %gentext-dk-index-see% "&See;")

(define %gentext-dk-index-seealso% "&SeeAlso;")

