;; $Id: dbl1svse.dsl 1.2 1998/10/30 16:31:51 nwalsh Exp $
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

(define (svse-appendix-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Appendix; %n"
      "&Appendix; som &called; %t"))

(define (svse-article-xref-string gi-or-name)
  (string-append %gentext-svse-start-quote%
		 "%t"
		 %gentext-svse-end-quote%))

(define (svse-bibliography-xref-string gi-or-name)
  "%t")

(define (svse-book-xref-string gi-or-name)
  "%t")

(define (svse-chapter-xref-string gi-or-name)
  (if %chapter-autolabel%
      "&Chapter; %n"
      "&Chapter; som &called; %t"))

(define (svse-equation-xref-string gi-or-name)
  "&Equation; %n")

(define (svse-example-xref-string gi-or-name)
  "&Example; %n")

(define (svse-figure-xref-string gi-or-name)
  "&Figure; %n")

(define (svse-listitem-xref-string gi-or-name)
  "%n")

(define (svse-part-xref-string gi-or-name)
  "&Part; %n")

(define (svse-preface-xref-string gi-or-name)
  "%t")

(define (svse-procedure-xref-string gi-or-name)
  "&Procedure; %n, %t")

(define (svse-section-xref-string gi-or-name)
  (if %section-autolabel% 
      "&Section; %n" 
      "&Section; som &called; %t"))

(define (svse-sect1-xref-string gi-or-name)
  (svse-section-xref-string gi-or-name))

(define (svse-sect2-xref-string gi-or-name)
  (svse-section-xref-string gi-or-name))

(define (svse-sect3-xref-string gi-or-name)
  (svse-section-xref-string gi-or-name))

(define (svse-sect4-xref-string gi-or-name)
  (svse-section-xref-string gi-or-name))

(define (svse-sect5-xref-string gi-or-name)
  (svse-section-xref-string gi-or-name))

(define (svse-step-xref-string gi-or-name)
  "&step; %n")

(define (svse-table-xref-string gi-or-name)
  "&Table; %n")

(define (svse-default-xref-string gi-or-name)
  (let* ((giname (if (string? gi-or-name) gi-or-name (gi gi-or-name)))
	 (msg    (string-append "[&xrefto; "
				(if giname giname "&nonexistantelement;")
				" &unsupported;]"))
	 (err    (node-list-error msg (current-node))))
    msg))

(define (gentext-svse-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
      ((equal? name (normalize "appendix")) (svse-appendix-xref-string gind))
      ((equal? name (normalize "article"))  (svse-article-xref-string gind))
      ((equal? name (normalize "bibliography")) (svse-bibliography-xref-string gind))
      ((equal? name (normalize "book"))     (svse-book-xref-string gind))
      ((equal? name (normalize "chapter"))  (svse-chapter-xref-string gind))
      ((equal? name (normalize "equation")) (svse-equation-xref-string gind))
      ((equal? name (normalize "example"))  (svse-example-xref-string gind))
      ((equal? name (normalize "figure"))   (svse-figure-xref-string gind))
      ((equal? name (normalize "listitem")) (svse-listitem-xref-string gind))
      ((equal? name (normalize "part"))     (svse-part-xref-string gind))
      ((equal? name (normalize "preface"))  (svse-preface-xref-string gind))
      ((equal? name (normalize "procedure")) (svse-procedure-xref-string gind))
      ((equal? name (normalize "sect1"))    (svse-sect1-xref-string gind))
      ((equal? name (normalize "sect2"))    (svse-sect2-xref-string gind))
      ((equal? name (normalize "sect3"))    (svse-sect3-xref-string gind))
      ((equal? name (normalize "sect4"))    (svse-sect4-xref-string gind))
      ((equal? name (normalize "sect5"))    (svse-sect5-xref-string gind))
      ((equal? name (normalize "step"))     (svse-step-xref-string gind))
      ((equal? name (normalize "table"))    (svse-table-xref-string gind))
      (else (svse-default-xref-string gind)))))

(define (svse-auto-xref-indirect-connector before) 
  ;; In English, the (cond) is unnecessary since the word is always the
  ;; same, but in other languages, that's not the case.  I've set this
  ;; one up with the (cond) so it stands as an example.
  (cond 
   ((equal? (gi before) (normalize "book"))
    (literal " in "))
   ((equal? (gi before) (normalize "chapter"))
    (literal " in "))
   ((equal? (gi before) (normalize "sect1"))
    (literal " in "))
   (else
    (literal " in "))))

;; Should the TOC come first or last?
;;
(define %generate-svse-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;
(define svse-abstract-name	"&Abstract;")
(define svse-appendix-name	"&Appendix;")
(define svse-article-name	"&Article;")
(define svse-bibliography-name	"&Bibliography;")
(define svse-book-name		"&Book;")
(define svse-calloutlist-name	"")
(define svse-caution-name	"&Caution;")
(define svse-chapter-name	"&Chapter;")
(define svse-copyright-name	"&Copyright;")
(define svse-dedication-name	"&Dedication;")
(define svse-edition-name	"&Edition;")
(define svse-equation-name	"&Equation;")
(define svse-example-name	"&Example;")
(define svse-figure-name	"&Figure;")
(define svse-glossary-name	"&Glossary;")
(define svse-glosssee-name	"&GlossSee;")
(define svse-glossseealso-name	"&GlossSeeAlso;")
(define svse-important-name	"&Important;")
(define svse-index-name		"&Index;")
(define svse-setindex-name	"&SetIndex;")
(define svse-isbn-name		"&ISBN;")
(define svse-legalnotice-name	"&LegalNotice;")
(define svse-msgaud-name	"&MsgAud;")
(define svse-msglevel-name	"&MsgLevel;")
(define svse-msgorig-name	"&MsgOrig;")
(define svse-note-name		"&Note;")
(define svse-part-name		"&Part;")
(define svse-preface-name	"&Preface;")
(define svse-procedure-name	"&Procedure;")
(define svse-pubdate-name	"&Published;")
(define svse-reference-name	"&Reference;")
(define svse-refname-name	"&RefName;")
(define svse-revhistory-name	"&RevHistory;")
(define svse-revision-name	"&Revision;")
(define svse-sect1-name		"&Section;")
(define svse-sect2-name		"&Section;")
(define svse-sect3-name		"&Section;")
(define svse-sect4-name		"&Section;")
(define svse-sect5-name		"&Section;")
(define svse-simplesect-name	"&Section;")
(define svse-seeie-name		"&See;")
(define svse-seealsoie-name	"&Seealso;")
(define svse-set-name		"&Set;")
(define svse-sidebar-name	"&Sidebar;")
(define svse-step-name		"&step;")
(define svse-table-name		"&Table;")
(define svse-tip-name		"&Tip;")
(define svse-toc-name		"&TableofContents;")
(define svse-warning-name	"&Warning;")

(define (gentext-svse-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract"))	svse-abstract-name)
     ((equal? name (normalize "appendix"))	svse-appendix-name)
     ((equal? name (normalize "article"))	svse-article-name)
     ((equal? name (normalize "bibliography"))	svse-bibliography-name)
     ((equal? name (normalize "book"))		svse-book-name)
     ((equal? name (normalize "calloutlist"))	svse-calloutlist-name)
     ((equal? name (normalize "caution"))	svse-caution-name)
     ((equal? name (normalize "chapter"))	svse-chapter-name)
     ((equal? name (normalize "copyright"))	svse-copyright-name)
     ((equal? name (normalize "dedication"))	svse-dedication-name)
     ((equal? name (normalize "edition"))	svse-edition-name)
     ((equal? name (normalize "equation"))	svse-equation-name)
     ((equal? name (normalize "example"))	svse-example-name)
     ((equal? name (normalize "figure"))	svse-figure-name)
     ((equal? name (normalize "glossary"))	svse-glossary-name)
     ((equal? name (normalize "glosssee"))	svse-glosssee-name)
     ((equal? name (normalize "glossseealso"))	svse-glossseealso-name)
     ((equal? name (normalize "important"))	svse-important-name)
     ((equal? name (normalize "index"))		svse-index-name)
     ((equal? name (normalize "setindex"))	svse-setindex-name)
     ((equal? name (normalize "isbn"))		svse-isbn-name)
     ((equal? name (normalize "legalnotice"))	svse-legalnotice-name)
     ((equal? name (normalize "msgaud"))	svse-msgaud-name)
     ((equal? name (normalize "msglevel"))	svse-msglevel-name)
     ((equal? name (normalize "msgorig"))	svse-msgorig-name)
     ((equal? name (normalize "note"))		svse-note-name)
     ((equal? name (normalize "part"))		svse-part-name)
     ((equal? name (normalize "preface"))	svse-preface-name)
     ((equal? name (normalize "procedure"))	svse-procedure-name)
     ((equal? name (normalize "pubdate"))	svse-pubdate-name)
     ((equal? name (normalize "reference"))	svse-reference-name)
     ((equal? name (normalize "refname"))	svse-refname-name)
     ((equal? name (normalize "revhistory"))	svse-revhistory-name)
     ((equal? name (normalize "revision"))	svse-revision-name)
     ((equal? name (normalize "sect1"))		svse-sect1-name)
     ((equal? name (normalize "sect2"))		svse-sect2-name)
     ((equal? name (normalize "sect3"))		svse-sect3-name)
     ((equal? name (normalize "sect4"))		svse-sect4-name)
     ((equal? name (normalize "sect5"))		svse-sect5-name)
     ((equal? name (normalize "simplesect"))    svse-simplesect-name)
     ((equal? name (normalize "seeie"))		svse-seeie-name)
     ((equal? name (normalize "seealsoie"))	svse-seealsoie-name)
     ((equal? name (normalize "set"))		svse-set-name)
     ((equal? name (normalize "sidebar"))	svse-sidebar-name)
     ((equal? name (normalize "step"))		svse-step-name)
     ((equal? name (normalize "table"))		svse-table-name)
     ((equal? name (normalize "tip"))		svse-tip-name)
     ((equal? name (normalize "toc"))		svse-toc-name)
     ((equal? name (normalize "warning"))	svse-warning-name)
     (else (let* ((msg (string-append "&unexpectedelementname;: " name))
		  (err (node-list-error msg (current-node))))
	     msg)))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-svse-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define svse-equation-intra-label-sep "-")
(define svse-example-intra-label-sep "-")
(define svse-figure-intra-label-sep "-")
(define svse-procedure-intra-label-sep ".")
(define svse-refentry-intra-label-sep ".")
(define svse-reference-intra-label-sep ".")
(define svse-refname-intra-label-sep ", ")
(define svse-refsect1-intra-label-sep ".")
(define svse-refsect2-intra-label-sep ".")
(define svse-refsect3-intra-label-sep ".")
(define svse-sect1-intra-label-sep ".")
(define svse-sect2-intra-label-sep ".")
(define svse-sect3-intra-label-sep ".")
(define svse-sect4-intra-label-sep ".")
(define svse-sect5-intra-label-sep ".")
(define svse-step-intra-label-sep ".")
(define svse-table-intra-label-sep "-")
(define svse-_pagenumber-intra-label-sep "-")
(define svse-default-intra-label-sep "")

(define (gentext-svse-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "equation"))	svse-equation-intra-label-sep)
     ((equal? name (normalize "example"))	svse-example-intra-label-sep)
     ((equal? name (normalize "figure"))	svse-figure-intra-label-sep)
     ((equal? name (normalize "procedure"))	svse-procedure-intra-label-sep)
     ((equal? name (normalize "refentry"))	svse-refentry-intra-label-sep)
     ((equal? name (normalize "reference"))	svse-reference-intra-label-sep)
     ((equal? name (normalize "refname"))	svse-refname-intra-label-sep)
     ((equal? name (normalize "refsect1"))	svse-refsect1-intra-label-sep)
     ((equal? name (normalize "refsect2"))	svse-refsect2-intra-label-sep)
     ((equal? name (normalize "refsect3"))	svse-refsect3-intra-label-sep)
     ((equal? name (normalize "sect1"))		svse-sect1-intra-label-sep)
     ((equal? name (normalize "sect2"))		svse-sect2-intra-label-sep)
     ((equal? name (normalize "sect3"))		svse-sect3-intra-label-sep)
     ((equal? name (normalize "sect4"))		svse-sect4-intra-label-sep)
     ((equal? name (normalize "sect5"))		svse-sect5-intra-label-sep)
     ((equal? name (normalize "step"))		svse-step-intra-label-sep)
     ((equal? name (normalize "table"))		svse-table-intra-label-sep)
     ((equal? name (normalize "_pagenumber"))	svse-_pagenumber-intra-label-sep)
     (else svse-default-intra-label-sep))))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define svse-abstract-label-title-sep ": ")
(define svse-appendix-label-title-sep ". ")
(define svse-caution-label-title-sep "")
(define svse-chapter-label-title-sep ". ")
(define svse-equation-label-title-sep ". ")
(define svse-example-label-title-sep ". ")
(define svse-figure-label-title-sep ". ")
(define svse-footnote-label-title-sep ". ")
(define svse-glosssee-label-title-sep ": ")
(define svse-glossseealso-label-title-sep ": ")
(define svse-important-label-title-sep ": ")
(define svse-note-label-title-sep ": ")
(define svse-orderedlist-label-title-sep ". ")
(define svse-part-label-title-sep ". ")
(define svse-procedure-label-title-sep ". ")
(define svse-prefix-label-title-sep ". ")
(define svse-refentry-label-title-sep "")
(define svse-reference-label-title-sep ". ")
(define svse-refsect1-label-title-sep ". ")
(define svse-refsect2-label-title-sep ". ")
(define svse-refsect3-label-title-sep ". ")
(define svse-sect1-label-title-sep ". ")
(define svse-sect2-label-title-sep ". ")
(define svse-sect3-label-title-sep ". ")
(define svse-sect4-label-title-sep ". ")
(define svse-sect5-label-title-sep ". ")
(define svse-seeie-label-title-sep " ")
(define svse-seealsoie-label-title-sep " ")
(define svse-step-label-title-sep ". ")
(define svse-table-label-title-sep ". ")
(define svse-tip-label-title-sep ": ")
(define svse-warning-label-title-sep "")
(define svse-default-label-title-sep "")

(define (gentext-svse-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "abstract")) svse-abstract-label-title-sep)
     ((equal? name (normalize "appendix")) svse-appendix-label-title-sep)
     ((equal? name (normalize "caution")) svse-caution-label-title-sep)
     ((equal? name (normalize "chapter")) svse-chapter-label-title-sep)
     ((equal? name (normalize "equation")) svse-equation-label-title-sep)
     ((equal? name (normalize "example")) svse-example-label-title-sep)
     ((equal? name (normalize "figure")) svse-figure-label-title-sep)
     ((equal? name (normalize "footnote")) svse-footnote-label-title-sep)
     ((equal? name (normalize "glosssee")) svse-glosssee-label-title-sep)
     ((equal? name (normalize "glossseealso")) svse-glossseealso-label-title-sep)
     ((equal? name (normalize "important")) svse-important-label-title-sep)
     ((equal? name (normalize "note")) svse-note-label-title-sep)
     ((equal? name (normalize "orderedlist")) svse-orderedlist-label-title-sep)
     ((equal? name (normalize "part")) svse-part-label-title-sep)
     ((equal? name (normalize "procedure")) svse-procedure-label-title-sep)
     ((equal? name (normalize "prefix")) svse-prefix-label-title-sep)
     ((equal? name (normalize "refentry")) svse-refentry-label-title-sep)
     ((equal? name (normalize "reference")) svse-reference-label-title-sep)
     ((equal? name (normalize "refsect1")) svse-refsect1-label-title-sep)
     ((equal? name (normalize "refsect2")) svse-refsect2-label-title-sep)
     ((equal? name (normalize "refsect3")) svse-refsect3-label-title-sep)
     ((equal? name (normalize "sect1")) svse-sect1-label-title-sep)
     ((equal? name (normalize "sect2")) svse-sect2-label-title-sep)
     ((equal? name (normalize "sect3")) svse-sect3-label-title-sep)
     ((equal? name (normalize "sect4")) svse-sect4-label-title-sep)
     ((equal? name (normalize "sect5")) svse-sect5-label-title-sep)
     ((equal? name (normalize "seeie")) svse-seeie-label-title-sep)
     ((equal? name (normalize "seealsoie")) svse-seealsoie-label-title-sep)
     ((equal? name (normalize "step")) svse-step-label-title-sep)
     ((equal? name (normalize "table")) svse-table-label-title-sep)
     ((equal? name (normalize "tip")) svse-tip-label-title-sep)
     ((equal? name (normalize "warning")) svse-warning-label-title-sep)
     (else svse-default-label-title-sep))))

(define (svse-set-label-number-format gind) "1")
(define (svse-book-label-number-format gind) "1")
(define (svse-prefix-label-number-format gind) "1")
(define (svse-part-label-number-format gind) "I")
(define (svse-chapter-label-number-format gind) "1")
(define (svse-appendix-label-number-format gind) "A")
(define (svse-reference-label-number-format gind) "I")
(define (svse-example-label-number-format gind) "1")
(define (svse-figure-label-number-format gind) "1")
(define (svse-table-label-number-format gind) "1")
(define (svse-procedure-label-number-format gind) "1")
(define (svse-step-label-number-format gind) "1")
(define (svse-refsect1-label-number-format gind) "1")
(define (svse-refsect2-label-number-format gind) "1")
(define (svse-refsect3-label-number-format gind) "1")
(define (svse-sect1-label-number-format gind) "1")
(define (svse-sect2-label-number-format gind) "1")
(define (svse-sect3-label-number-format gind) "1")
(define (svse-sect4-label-number-format gind) "1")
(define (svse-sect5-label-number-format gind) "1")
(define (svse-default-label-number-format gind) "1")

(define (svse-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond
     ((equal? name (normalize "set")) (svse-set-label-number-format gind))
     ((equal? name (normalize "book")) (svse-book-label-number-format gind))
     ((equal? name (normalize "prefix")) (svse-prefix-label-number-format gind))
     ((equal? name (normalize "part")) (svse-part-label-number-format gind))
     ((equal? name (normalize "chapter")) (svse-chapter-label-number-format gind))
     ((equal? name (normalize "appendix")) (svse-appendix-label-number-format gind))
     ((equal? name (normalize "reference")) (svse-reference-label-number-format gind))
     ((equal? name (normalize "example")) (svse-example-label-number-format gind))
     ((equal? name (normalize "figure")) (svse-figure-label-number-format gind))
     ((equal? name (normalize "table")) (svse-table-label-number-format gind))
     ((equal? name (normalize "procedure")) (svse-procedure-label-number-format gind))
     ((equal? name (normalize "step")) (svse-step-label-number-format gind))
     ((equal? name (normalize "refsect1")) (svse-refsect1-label-number-format gind))
     ((equal? name (normalize "refsect2")) (svse-refsect2-label-number-format gind))
     ((equal? name (normalize "refsect3")) (svse-refsect3-label-number-format gind))
     ((equal? name (normalize "sect1")) (svse-sect1-label-number-format gind))
     ((equal? name (normalize "sect2")) (svse-sect2-label-number-format gind))
     ((equal? name (normalize "sect3")) (svse-sect3-label-number-format gind))
     ((equal? name (normalize "sect4")) (svse-sect4-label-number-format gind))
     ((equal? name (normalize "sect5")) (svse-sect5-label-number-format gind))
     (else (svse-default-label-number-format gind)))))

(define ($lot-title-svse$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname)))
    (cond ((equal? name (normalize "table"))    "&ListofTables;")
	  ((equal? name (normalize "example"))  "&ListofExamples;")
	  ((equal? name (normalize "figure"))   "&ListofFigures;")
	  ((equal? name (normalize "equation")) "&ListofEquations;")
	  (else (let* ((msg (string-append "&ListofUnknown;: " name))
		       (err (node-list-error msg (current-node))))
		  msg)))))

(define %gentext-svse-start-quote% (dingbat "ldquo"))

(define %gentext-svse-end-quote% (dingbat "rdquo"))

(define %gentext-svse-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-svse-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-svse-page% "")

(define %gentext-svse-and% "&and;")

(define %gentext-svse-bibl-pages% "&Pgs;")

(define %gentext-svse-endnotes% "&Notes;")

(define %gentext-svse-table-endnotes% "&TableNotes;:")

(define %gentext-svse-index-see% "&See;")

(define %gentext-svse-index-seealso% "&SeeAlso;")

