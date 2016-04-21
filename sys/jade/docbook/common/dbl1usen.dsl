;; $Id: dbl1usen.dsl 1.20 1998/11/05 17:11:58 nwalsh Exp $
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

(define (usen-appendix-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Appendix; %n"
      "the &appendix; called %t"))

(define (usen-article-xref-string gi-or-name)
  (string-append %gentext-usen-start-quote%
		 "%t"
		 %gentext-usen-end-quote%))

(define (usen-bibliography-xref-string gi-or-name)
  "%t")

(define (usen-book-xref-string gi-or-name)
  "%t")

(define (usen-chapter-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Chapter; %n"
      "the &chapter; called %t"))

(define (usen-equation-xref-string gi-or-name)
  "&Equation; %n")

(define (usen-example-xref-string gi-or-name)
  "&Example; %n")

(define (usen-figure-xref-string gi-or-name)
  "&Figure; %n")

(define (usen-listitem-xref-string gi-or-name)
  "%n")

(define (usen-part-xref-string gi-or-name)
  "&Part; %n")

(define (usen-preface-xref-string gi-or-name)
  "%t")

(define (usen-procedure-xref-string gi-or-name)
  "&Procedure; %n, %t")

(define (usen-section-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "the &section; called %t"))

(define (usen-sect1-xref-string gi-or-name)
  (usen-section-xref-string gi-or-name))

(define (usen-sect2-xref-string gi-or-name)
  (usen-section-xref-string gi-or-name))

(define (usen-sect3-xref-string gi-or-name)
  (usen-section-xref-string gi-or-name))

(define (usen-sect4-xref-string gi-or-name)
  (usen-section-xref-string gi-or-name))

(define (usen-sect5-xref-string gi-or-name)
  (usen-section-xref-string gi-or-name))

(define (usen-sidebar-xref-string gi-or-name)
  "the &sidebar; %t")

(define (usen-step-xref-string gi-or-name)
  "&step; %n")

(define (usen-table-xref-string gi-or-name)
  "&Table; %n")

(define (usen-default-xref-string gi-or-name)
  (let* ((giname (if (string? gi-or-name) gi-or-name (gi gi-or-name)))
	 (msg    (string-append "[&xrefto; "
				(if giname giname "&nonexistantelement;")
				" &unsupported;]"))
	 (err    (node-list-error msg (current-node))))
    msg))

(define (gentext-usen-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
      ((equal? name (normalize "appendix")) (usen-appendix-xref-string gind))
      ((equal? name (normalize "article"))  (usen-article-xref-string gind))
      ((equal? name (normalize "bibliography")) (usen-bibliography-xref-string gind))
      ((equal? name (normalize "book"))     (usen-book-xref-string gind))
      ((equal? name (normalize "chapter"))  (usen-chapter-xref-string gind))
      ((equal? name (normalize "equation")) (usen-equation-xref-string gind))
      ((equal? name (normalize "example"))  (usen-example-xref-string gind))
      ((equal? name (normalize "figure"))   (usen-figure-xref-string gind))
      ((equal? name (normalize "listitem")) (usen-listitem-xref-string gind))
      ((equal? name (normalize "part"))     (usen-part-xref-string gind))
      ((equal? name (normalize "preface"))  (usen-preface-xref-string gind))
      ((equal? name (normalize "procedure")) (usen-procedure-xref-string gind))
      ((equal? name (normalize "sect1"))    (usen-sect1-xref-string gind))
      ((equal? name (normalize "sect2"))    (usen-sect2-xref-string gind))
      ((equal? name (normalize "sect3"))    (usen-sect3-xref-string gind))
      ((equal? name (normalize "sect4"))    (usen-sect4-xref-string gind))
      ((equal? name (normalize "sect5"))    (usen-sect5-xref-string gind))
      ((equal? name (normalize "sidebar"))  (usen-sidebar-xref-string gind))
      ((equal? name (normalize "step"))     (usen-step-xref-string gind))
      ((equal? name (normalize "table"))    (usen-table-xref-string gind))
      (else (usen-default-xref-string gind)))))

(define (usen-auto-xref-indirect-connector before) 
  ;; In English, the (cond) is unnecessary since the word is always the
  ;; same, but in other languages, that's not the case.  I've set this
  ;; one up with the (cond) so it stands as an example.
  (cond 
   ((equal? (gi before) (normalize "book"))
    (literal " &in; "))
   ((equal? (gi before) (normalize "chapter"))
    (literal " &in; "))
   ((equal? (gi before) (normalize "sect1"))
    (literal " &in; "))
   (else
    (literal " &in; "))))

;; Should the TOC come first or last?
;;
(define %generate-usen-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;
(define usen-abstract-name	"&Abstract;")
(define usen-appendix-name	"&Appendix;")
(define usen-article-name	"&Article;")
(define usen-bibliography-name	"&Bibliography;")
(define usen-book-name		"&Book;")
(define usen-calloutlist-name	"")
(define usen-caution-name	"&Caution;")
(define usen-chapter-name	"&Chapter;")
(define usen-copyright-name	"&Copyright;")
(define usen-dedication-name	"&Dedication;")
(define usen-edition-name	"&Edition;")
(define usen-equation-name	"&Equation;")
(define usen-example-name	"&Example;")
(define usen-figure-name	"&Figure;")
(define usen-glossary-name	"&Glossary;")
(define usen-glosssee-name	"&GlossSee;")
(define usen-glossseealso-name	"&GlossSeeAlso;")
(define usen-important-name	"&Important;")
(define usen-index-name		"&Index;")
(define usen-setindex-name	"&SetIndex;")
(define usen-isbn-name		"&ISBN;")
(define usen-legalnotice-name	"&LegalNotice;")
(define usen-msgaud-name	"&MsgAud;")
(define usen-msglevel-name	"&MsgLevel;")
(define usen-msgorig-name	"&MsgOrig;")
(define usen-note-name		"&Note;")
(define usen-part-name		"&Part;")
(define usen-preface-name	"&Preface;")
(define usen-procedure-name	"&Procedure;")
(define usen-pubdate-name	"&Published;")
(define usen-reference-name	"&Reference;")
(define usen-refname-name	"&RefName;")
(define usen-revhistory-name	"&RevHistory;")
(define usen-revision-name	"&Revision;")
(define usen-sect1-name		"&Section;")
(define usen-sect2-name		"&Section;")
(define usen-sect3-name		"&Section;")
(define usen-sect4-name		"&Section;")
(define usen-sect5-name		"&Section;")
(define usen-simplesect-name	"&Section;")
(define usen-seeie-name		"&See;")
(define usen-seealsoie-name	"&Seealso;")
(define usen-set-name		"&Set;")
(define usen-sidebar-name	"&Sidebar;")
(define usen-step-name		"&step;")
(define usen-table-name		"&Table;")
(define usen-tip-name		"&Tip;")
(define usen-toc-name		"&TableofContents;")
(define usen-warning-name	"&Warning;")

(define (gentext-usen-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract"))	usen-abstract-name)
     ((equal? name (normalize "appendix"))	usen-appendix-name)
     ((equal? name (normalize "article"))	usen-article-name)
     ((equal? name (normalize "bibliography"))	usen-bibliography-name)
     ((equal? name (normalize "book"))		usen-book-name)
     ((equal? name (normalize "calloutlist"))	usen-calloutlist-name)
     ((equal? name (normalize "caution"))	usen-caution-name)
     ((equal? name (normalize "chapter"))	usen-chapter-name)
     ((equal? name (normalize "copyright"))	usen-copyright-name)
     ((equal? name (normalize "dedication"))	usen-dedication-name)
     ((equal? name (normalize "edition"))	usen-edition-name)
     ((equal? name (normalize "equation"))	usen-equation-name)
     ((equal? name (normalize "example"))	usen-example-name)
     ((equal? name (normalize "figure"))	usen-figure-name)
     ((equal? name (normalize "glossary"))	usen-glossary-name)
     ((equal? name (normalize "glosssee"))	usen-glosssee-name)
     ((equal? name (normalize "glossseealso"))	usen-glossseealso-name)
     ((equal? name (normalize "important"))	usen-important-name)
     ((equal? name (normalize "index"))		usen-index-name)
     ((equal? name (normalize "setindex"))	usen-setindex-name)
     ((equal? name (normalize "isbn"))		usen-isbn-name)
     ((equal? name (normalize "legalnotice"))	usen-legalnotice-name)
     ((equal? name (normalize "msgaud"))	usen-msgaud-name)
     ((equal? name (normalize "msglevel"))	usen-msglevel-name)
     ((equal? name (normalize "msgorig"))	usen-msgorig-name)
     ((equal? name (normalize "note"))		usen-note-name)
     ((equal? name (normalize "part"))		usen-part-name)
     ((equal? name (normalize "preface"))	usen-preface-name)
     ((equal? name (normalize "procedure"))	usen-procedure-name)
     ((equal? name (normalize "pubdate"))	usen-pubdate-name)
     ((equal? name (normalize "reference"))	usen-reference-name)
     ((equal? name (normalize "refname"))	usen-refname-name)
     ((equal? name (normalize "revhistory"))	usen-revhistory-name)
     ((equal? name (normalize "revision"))	usen-revision-name)
     ((equal? name (normalize "sect1"))		usen-sect1-name)
     ((equal? name (normalize "sect2"))		usen-sect2-name)
     ((equal? name (normalize "sect3"))		usen-sect3-name)
     ((equal? name (normalize "sect4"))		usen-sect4-name)
     ((equal? name (normalize "sect5"))		usen-sect5-name)
     ((equal? name (normalize "simplesect"))    usen-simplesect-name)
     ((equal? name (normalize "seeie"))		usen-seeie-name)
     ((equal? name (normalize "seealsoie"))	usen-seealsoie-name)
     ((equal? name (normalize "set"))		usen-set-name)
     ((equal? name (normalize "sidebar"))	usen-sidebar-name)
     ((equal? name (normalize "step"))		usen-step-name)
     ((equal? name (normalize "table"))		usen-table-name)
     ((equal? name (normalize "tip"))		usen-tip-name)
     ((equal? name (normalize "toc"))		usen-toc-name)
     ((equal? name (normalize "warning"))	usen-warning-name)
     (else (let* ((msg (string-append "gentext-usen-element-name: &unexpectedelementname;: " name))
		  (err (node-list-error msg (current-node))))
	     msg)))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-usen-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define usen-equation-intra-label-sep "-")
(define usen-example-intra-label-sep "-")
(define usen-figure-intra-label-sep "-")
(define usen-procedure-intra-label-sep ".")
(define usen-refentry-intra-label-sep ".")
(define usen-reference-intra-label-sep ".")
(define usen-refname-intra-label-sep ", ")
(define usen-refsect1-intra-label-sep ".")
(define usen-refsect2-intra-label-sep ".")
(define usen-refsect3-intra-label-sep ".")
(define usen-sect1-intra-label-sep ".")
(define usen-sect2-intra-label-sep ".")
(define usen-sect3-intra-label-sep ".")
(define usen-sect4-intra-label-sep ".")
(define usen-sect5-intra-label-sep ".")
(define usen-step-intra-label-sep ".")
(define usen-table-intra-label-sep "-")
(define usen-_pagenumber-intra-label-sep "-")
(define usen-default-intra-label-sep "")

(define (gentext-usen-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "equation"))	usen-equation-intra-label-sep)
     ((equal? name (normalize "example"))	usen-example-intra-label-sep)
     ((equal? name (normalize "figure"))	usen-figure-intra-label-sep)
     ((equal? name (normalize "procedure"))	usen-procedure-intra-label-sep)
     ((equal? name (normalize "refentry"))	usen-refentry-intra-label-sep)
     ((equal? name (normalize "reference"))	usen-reference-intra-label-sep)
     ((equal? name (normalize "refname"))	usen-refname-intra-label-sep)
     ((equal? name (normalize "refsect1"))	usen-refsect1-intra-label-sep)
     ((equal? name (normalize "refsect2"))	usen-refsect2-intra-label-sep)
     ((equal? name (normalize "refsect3"))	usen-refsect3-intra-label-sep)
     ((equal? name (normalize "sect1"))		usen-sect1-intra-label-sep)
     ((equal? name (normalize "sect2"))		usen-sect2-intra-label-sep)
     ((equal? name (normalize "sect3"))		usen-sect3-intra-label-sep)
     ((equal? name (normalize "sect4"))		usen-sect4-intra-label-sep)
     ((equal? name (normalize "sect5"))		usen-sect5-intra-label-sep)
     ((equal? name (normalize "step"))		usen-step-intra-label-sep)
     ((equal? name (normalize "table"))		usen-table-intra-label-sep)
     ((equal? name (normalize "_pagenumber"))	usen-_pagenumber-intra-label-sep)
     (else usen-default-intra-label-sep))))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define usen-abstract-label-title-sep ": ")
(define usen-appendix-label-title-sep ". ")
(define usen-caution-label-title-sep "")
(define usen-chapter-label-title-sep ". ")
(define usen-equation-label-title-sep ". ")
(define usen-example-label-title-sep ". ")
(define usen-figure-label-title-sep ". ")
(define usen-footnote-label-title-sep ". ")
(define usen-glosssee-label-title-sep ": ")
(define usen-glossseealso-label-title-sep ": ")
(define usen-important-label-title-sep ": ")
(define usen-note-label-title-sep ": ")
(define usen-orderedlist-label-title-sep ". ")
(define usen-part-label-title-sep ". ")
(define usen-procedure-label-title-sep ". ")
(define usen-prefix-label-title-sep ". ")
(define usen-refentry-label-title-sep "")
(define usen-reference-label-title-sep ". ")
(define usen-refsect1-label-title-sep ". ")
(define usen-refsect2-label-title-sep ". ")
(define usen-refsect3-label-title-sep ". ")
(define usen-sect1-label-title-sep ". ")
(define usen-sect2-label-title-sep ". ")
(define usen-sect3-label-title-sep ". ")
(define usen-sect4-label-title-sep ". ")
(define usen-sect5-label-title-sep ". ")
(define usen-seeie-label-title-sep " ")
(define usen-seealsoie-label-title-sep " ")
(define usen-step-label-title-sep ". ")
(define usen-table-label-title-sep ". ")
(define usen-tip-label-title-sep ": ")
(define usen-warning-label-title-sep "")
(define usen-default-label-title-sep "")

(define (gentext-usen-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract")) usen-abstract-label-title-sep)
     ((equal? name (normalize "appendix")) usen-appendix-label-title-sep)
     ((equal? name (normalize "caution")) usen-caution-label-title-sep)
     ((equal? name (normalize "chapter")) usen-chapter-label-title-sep)
     ((equal? name (normalize "equation")) usen-equation-label-title-sep)
     ((equal? name (normalize "example")) usen-example-label-title-sep)
     ((equal? name (normalize "figure")) usen-figure-label-title-sep)
     ((equal? name (normalize "footnote")) usen-footnote-label-title-sep)
     ((equal? name (normalize "glosssee")) usen-glosssee-label-title-sep)
     ((equal? name (normalize "glossseealso")) usen-glossseealso-label-title-sep)
     ((equal? name (normalize "important")) usen-important-label-title-sep)
     ((equal? name (normalize "note")) usen-note-label-title-sep)
     ((equal? name (normalize "orderedlist")) usen-orderedlist-label-title-sep)
     ((equal? name (normalize "part")) usen-part-label-title-sep)
     ((equal? name (normalize "procedure")) usen-procedure-label-title-sep)
     ((equal? name (normalize "prefix")) usen-prefix-label-title-sep)
     ((equal? name (normalize "refentry")) usen-refentry-label-title-sep)
     ((equal? name (normalize "reference")) usen-reference-label-title-sep)
     ((equal? name (normalize "refsect1")) usen-refsect1-label-title-sep)
     ((equal? name (normalize "refsect2")) usen-refsect2-label-title-sep)
     ((equal? name (normalize "refsect3")) usen-refsect3-label-title-sep)
     ((equal? name (normalize "sect1")) usen-sect1-label-title-sep)
     ((equal? name (normalize "sect2")) usen-sect2-label-title-sep)
     ((equal? name (normalize "sect3")) usen-sect3-label-title-sep)
     ((equal? name (normalize "sect4")) usen-sect4-label-title-sep)
     ((equal? name (normalize "sect5")) usen-sect5-label-title-sep)
     ((equal? name (normalize "seeie")) usen-seeie-label-title-sep)
     ((equal? name (normalize "seealsoie")) usen-seealsoie-label-title-sep)
     ((equal? name (normalize "step")) usen-step-label-title-sep)
     ((equal? name (normalize "table")) usen-table-label-title-sep)
     ((equal? name (normalize "tip")) usen-tip-label-title-sep)
     ((equal? name (normalize "warning")) usen-warning-label-title-sep)
     (else usen-default-label-title-sep))))

(define (usen-set-label-number-format gind) "1")
(define (usen-book-label-number-format gind) "1")
(define (usen-prefix-label-number-format gind) "1")
(define (usen-part-label-number-format gind) "I")
(define (usen-chapter-label-number-format gind) "1")
(define (usen-appendix-label-number-format gind) "A")
(define (usen-reference-label-number-format gind) "I")
(define (usen-example-label-number-format gind) "1")
(define (usen-figure-label-number-format gind) "1")
(define (usen-table-label-number-format gind) "1")
(define (usen-procedure-label-number-format gind) "1")
(define (usen-step-label-number-format gind) "1")
(define (usen-refsect1-label-number-format gind) "1")
(define (usen-refsect2-label-number-format gind) "1")
(define (usen-refsect3-label-number-format gind) "1")
(define (usen-sect1-label-number-format gind) "1")
(define (usen-sect2-label-number-format gind) "1")
(define (usen-sect3-label-number-format gind) "1")
(define (usen-sect4-label-number-format gind) "1")
(define (usen-sect5-label-number-format gind) "1")
(define (usen-default-label-number-format gind) "1")

(define (usen-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "set")) (usen-set-label-number-format gind))
     ((equal? name (normalize "book")) (usen-book-label-number-format gind))
     ((equal? name (normalize "prefix")) (usen-prefix-label-number-format gind))
     ((equal? name (normalize "part")) (usen-part-label-number-format gind))
     ((equal? name (normalize "chapter")) (usen-chapter-label-number-format gind))
     ((equal? name (normalize "appendix")) (usen-appendix-label-number-format gind))
     ((equal? name (normalize "reference")) (usen-reference-label-number-format gind))
     ((equal? name (normalize "example")) (usen-example-label-number-format gind))
     ((equal? name (normalize "figure")) (usen-figure-label-number-format gind))
     ((equal? name (normalize "table")) (usen-table-label-number-format gind))
     ((equal? name (normalize "procedure")) (usen-procedure-label-number-format gind))
     ((equal? name (normalize "step")) (usen-step-label-number-format gind))
     ((equal? name (normalize "refsect1")) (usen-refsect1-label-number-format gind))
     ((equal? name (normalize "refsect2")) (usen-refsect2-label-number-format gind))
     ((equal? name (normalize "refsect3")) (usen-refsect3-label-number-format gind))
     ((equal? name (normalize "sect1")) (usen-sect1-label-number-format gind))
     ((equal? name (normalize "sect2")) (usen-sect2-label-number-format gind))
     ((equal? name (normalize "sect3")) (usen-sect3-label-number-format gind))
     ((equal? name (normalize "sect4")) (usen-sect4-label-number-format gind))
     ((equal? name (normalize "sect5")) (usen-sect5-label-number-format gind))
     (else (usen-default-label-number-format gind)))))

(define ($lot-title-usen$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond ((equal? name (normalize "table"))    "&ListofTables;")
	  ((equal? name (normalize "example"))  "&ListofExamples;")
	  ((equal? name (normalize "figure"))   "&ListofFigures;")
	  ((equal? name (normalize "equation")) "&ListofEquations;")
	  (else (let* ((msg (string-append "&ListofUnknown;: " name))
		       (err (node-list-error msg (current-node))))
		  msg)))))

(define %gentext-usen-start-quote% (dingbat "ldquo"))

(define %gentext-usen-end-quote% (dingbat "rdquo"))

(define %gentext-usen-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-usen-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-usen-page% "")

(define %gentext-usen-and% "&and;")

(define %gentext-usen-bibl-pages% "&Pgs;")

(define %gentext-usen-endnotes% "&Notes;")

(define %gentext-usen-table-endnotes% "&TableNotes;:")

(define %gentext-usen-index-see% "&See;")

(define %gentext-usen-index-seealso% "&SeeAlso;")

