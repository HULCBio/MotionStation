<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % sv.words
  PUBLIC "-//Norman Walsh//ENTITIES DocBook Stylesheet Localization//SV"
         "dbl1sv.ent">
%sv.words;
]>

<style-sheet>
<style-specification id="docbook-l10n-sv">
<style-specification-body>

;; $Id: dbl1sv.dsl,v 1.8 2000/02/07 12:45:04 nwalsh Exp $
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

(define (sv-xref-strings)
  (list (list (normalize "appendix")    (if %chapter-autolabel%
					    "&Appendix; %n"
					    "&Appendix; som &called; %t"))
	(list (normalize "article")     (string-append %gentext-sv-start-quote%
						       "%t"
						       %gentext-sv-end-quote%))
	(list (normalize "bibliography") "%t")
	(list (normalize "book")        "%t")
	(list (normalize "chapter")     (if %chapter-autolabel%
					    "&Chapter; %n"
					    "&Chapter; som &called; %t"))
	(list (normalize "equation")    "&Equation; %n")
	(list (normalize "example")     "&Example; %n")
	(list (normalize "figure")      "&Figure; %n")
	(list (normalize "glossary")    "%t")
	(list (normalize "index")       "%t")
	(list (normalize "listitem")    "%n")
	(list (normalize "part")        "&Part; %n")
	(list (normalize "preface")     "%t")
	(list (normalize "procedure")   "&Procedure; %n, %t")
	(list (normalize "reference")   "&Reference; %n, %t")
	(list (normalize "section")     (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sect1")       (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sect2")       (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sect3")       (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sect4")       (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sect5")       (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "simplesect")  (if %section-autolabel%
					    "&Section; %n"
					    "&Section; som &called; %t"))
	(list (normalize "sidebar")     "&sidebar; %t")
	(list (normalize "step")        "&step; %n")
	(list (normalize "table")       "&Table; %n")))

(define (gentext-sv-xref-strings gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (xref   (assoc name (sv-xref-strings))))
    (if xref
	(car (cdr xref))
	(let* ((msg    (string-append "[&xrefto; "
				      (if giname giname "&nonexistantelement;")
				      " &unsupported;]"))
	       (err    (node-list-error msg (current-node))))
	  msg))))

(define (sv-auto-xref-indirect-connector before) 
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
(define %generate-sv-toc-in-front% #t)

;; gentext-element-name returns the generated text that should be 
;; used to make reference to the selected element.
;;

(define (sv-element-name)
  (list
   (list (normalize "abstract")		"&Abstract;")
   (list (normalize "answer")		"&Answer;")
   (list (normalize "appendix")		"&Appendix;")
   (list (normalize "article")		"&Article;")
   (list (normalize "bibliography")	"&Bibliography;")
   (list (normalize "book")		"&Book;")
   (list (normalize "calloutlist")	"")
   (list (normalize "caution")		"&Caution;")
   (list (normalize "chapter")		"&Chapter;")
   (list (normalize "copyright")	"&Copyright;")
   (list (normalize "dedication")	"&Dedication;")
   (list (normalize "edition")		"&Edition;")
   (list (normalize "equation")		"&Equation;")
   (list (normalize "example")		"&Example;")
   (list (normalize "figure")		"&Figure;")
   (list (normalize "glossary")		"&Glossary;")
   (list (normalize "glosssee")		"&GlossSee;")
   (list (normalize "glossseealso")	"&GlossSeeAlso;")
   (list (normalize "important")	"&Important;")
   (list (normalize "index")		"&Index;")
   (list (normalize "colophon")		"&Colophon;")
   (list (normalize "setindex")		"&SetIndex;")
   (list (normalize "isbn")		"&ISBN;")
   (list (normalize "legalnotice")	"&LegalNotice;")
   (list (normalize "msgaud")		"&MsgAud;")
   (list (normalize "msglevel")		"&MsgLevel;")
   (list (normalize "msgorig")		"&MsgOrig;")
   (list (normalize "note")		"&Note;")
   (list (normalize "part")		"&Part;")
   (list (normalize "preface")		"&Preface;")
   (list (normalize "procedure")	"&Procedure;")
   (list (normalize "pubdate")		"&Published;")
   (list (normalize "question")		"&Question;")
   (list (normalize "refentry")		"&RefEntry;")
   (list (normalize "reference")	"&Reference;")
   (list (normalize "refname")		"&RefName;")
   (list (normalize "revhistory")	"&RevHistory;")
   (list (normalize "refsect1")		"&RefSection;")
   (list (normalize "refsect2")		"&RefSection;")
   (list (normalize "refsect3")		"&RefSection;")
   (list (normalize "refsynopsisdiv")	"&RefSynopsisDiv;")
   (list (normalize "revision")		"&Revision;")
   (list (normalize "sect1")		"&Section;")
   (list (normalize "sect2")		"&Section;")
   (list (normalize "sect3")		"&Section;")
   (list (normalize "sect4")		"&Section;")
   (list (normalize "sect5")		"&Section;")
   (list (normalize "section")		"&Section;")
   (list (normalize "simplesect")	"&Section;")
   (list (normalize "seeie")		"&See;")
   (list (normalize "seealsoie")	"&Seealso;")
   (list (normalize "set")		"&Set;")
   (list (normalize "sidebar")		"&Sidebar;")
   (list (normalize "step")		"&step;")
   (list (normalize "table")		"&Table;")
   (list (normalize "tip")		"&Tip;")
   (list (normalize "toc")		"&TableofContents;")
   (list (normalize "warning")		"&Warning;")
   ))

(define (gentext-sv-element-name gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (pname  (assoc name (sv-element-name))))
    (if pname
	(car (cdr pname))
	(let* ((msg (string-append 
		     "gentext-sv-element-name: &unexpectedelementname;: "
		     name))
	       (err (node-list-error msg (current-node))))
	  msg))))

;; gentext-element-name-space returns gentext-element-name with a 
;; trailing space, if gentext-element-name isn't "".
;;
(define (gentext-sv-element-name-space giname)
  (string-with-space (gentext-element-name giname)))

;; gentext-intra-label-sep returns the seperator to be inserted
;; between multiple occurances of a label (or parts of a label)
;; for the specified element.  Most of these are for enumerated
;; labels like "Figure 2-4", but this function is used elsewhere
;; (e.g. REFNAME) with a little abuse.
;;

(define (sv-intra-label-sep)
  (list
   (list (normalize "equation")		"-")
   (list (normalize "informalequation")	"-")
   (list (normalize "example")		"-")
   (list (normalize "figure")		"-")
   (list (normalize "listitem")		".")
   (list (normalize "procedure")	".")
   (list (normalize "refentry")		".")
   (list (normalize "reference")	".")
   (list (normalize "refname")		", ")
   (list (normalize "refsect1")		".")
   (list (normalize "refsect2")		".")
   (list (normalize "refsect3")		".")
   (list (normalize "sect1")		".")
   (list (normalize "sect2")		".")
   (list (normalize "sect3")		".")
   (list (normalize "sect4")		".")
   (list (normalize "sect5")		".")
   (list (normalize "section")		".")
   (list (normalize "simplesect")	".")
   (list (normalize "step")		".")
   (list (normalize "table")		"-")
   (list (normalize "_pagenumber")	"-")
   ))

(define (gentext-sv-intra-label-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (sep    (assoc name (sv-intra-label-sep))))
    (if sep
	(car (cdr sep))
	"")))

;; gentext-label-title-sep returns the seperator to be inserted
;; between a label and the text following the label for the
;; specified element.  Most of these are for use between
;; enumerated labels and titles like "1. Chapter One Title", but
;; this function is used elsewhere (e.g. NOTE) with a little
;; abuse.
;;

(define (sv-label-title-sep)
  (list
   (list (normalize "abstract")		": ")
   (list (normalize "answer")		" ")
   (list (normalize "appendix")		". ")
   (list (normalize "caution")		"")
   (list (normalize "chapter")		". ")
   (list (normalize "equation")		". ")
   (list (normalize "example")		". ")
   (list (normalize "figure")		". ")
   (list (normalize "footnote")		". ")
   (list (normalize "glosssee")		": ")
   (list (normalize "glossseealso")	": ")
   (list (normalize "important")	": ")
   (list (normalize "note")		": ")
   (list (normalize "orderedlist")	". ")
   (list (normalize "part")		". ")
   (list (normalize "procedure")	". ")
   (list (normalize "prefix")		". ")
   (list (normalize "question")		" ")
   (list (normalize "refentry")		"")
   (list (normalize "reference")	". ")
   (list (normalize "refsect1")		". ")
   (list (normalize "refsect2")		". ")
   (list (normalize "refsect3")		". ")
   (list (normalize "sect1")		". ")
   (list (normalize "sect2")		". ")
   (list (normalize "sect3")		". ")
   (list (normalize "sect4")		". ")
   (list (normalize "sect5")		". ")
   (list (normalize "section")		". ")
   (list (normalize "simplesect")	". ")
   (list (normalize "seeie")		" ")
   (list (normalize "seealsoie")	" ")
   (list (normalize "step")		". ")
   (list (normalize "table")		". ")
   (list (normalize "tip")		": ")
   (list (normalize "warning")		"")
   ))

(define (gentext-sv-label-title-sep gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (sep    (assoc name (sv-label-title-sep))))
    (if sep
	(car (cdr sep))
	"")))

(define (sv-label-number-format-list)
  (list
   (list (normalize "set")		"1")
   (list (normalize "book")		"1")
   (list (normalize "prefix")		"1")
   (list (normalize "part")		"I")
   (list (normalize "chapter")		"1")
   (list (normalize "appendix")		"A")
   (list (normalize "reference")	"I")
   (list (normalize "example")		"1")
   (list (normalize "figure")		"1")
   (list (normalize "table")		"1")
   (list (normalize "procedure")	"1")
   (list (normalize "step")		"1")
   (list (normalize "refsect1")		"1")
   (list (normalize "refsect2")		"1")
   (list (normalize "refsect3")		"1")
   (list (normalize "sect1")		"1")
   (list (normalize "sect2")		"1")
   (list (normalize "sect3")		"1")
   (list (normalize "sect4")		"1")
   (list (normalize "sect5")		"1")
   (list (normalize "section")		"1")
   ))

(define (sv-label-number-format gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (format (assoc name (sv-label-number-format-list))))
    (if format
	(car (cdr format))
	"1")))

(define (sv-lot-title)
  (list
   (list (normalize "table")		"&ListofTables;")
   (list (normalize "example")		"&ListofExamples;")
   (list (normalize "figure")		"&ListofFigures;")
   (list (normalize "equation")		"&ListofEquations;")
   ))

(define ($lot-title-sv$ gind)
  (let* ((giname (if (string? gind) gind (gi gind)))
	 (name   (normalize giname))
	 (title  (assoc name (sv-lot-title))))
    (if title
	(car (cdr title))
	(let* ((msg (string-append "&ListofUnknown;: " name))
	       (err (node-list-error msg (current-node))))
	  msg))))

(define %gentext-sv-start-quote% (dingbat "ldquo"))

(define %gentext-sv-end-quote% (dingbat "rdquo"))

(define %gentext-sv-start-nested-quote% (dingbat "lsquo"))

(define %gentext-sv-end-nested-quote% (dingbat "rsquo"))

(define %gentext-sv-by% "&by;") ;; e.g. Copyright 1997 "by" A. Nonymous
                           ;; Authored "by" Jane Doe

(define %gentext-sv-edited-by% "&Editedby;")
                           ;; "Edited by" Jane Doe

(define %gentext-sv-revised-by% "&Revisedby;")
                           ;; "Revised by" Jane Doe

(define %gentext-sv-page% "")

(define %gentext-sv-and% "&and;")

(define %gentext-sv-bibl-pages% "&Pgs;")

(define %gentext-sv-endnotes% "&Notes;")

(define %gentext-sv-table-endnotes% "&TableNotes;:")

(define %gentext-sv-index-see% "&See;")

(define %gentext-sv-index-seealso% "&SeeAlso;")


(define (gentext-sv-nav-prev prev) 
  (make sequence (literal "&nav-prev;")))

(define (gentext-sv-nav-prev-sibling prevsib) 
  (make sequence (literal "&nav-prev-sibling;")))

(define (gentext-sv-nav-next-sibling nextsib)
  (make sequence (literal "&nav-next-sibling;")))

(define (gentext-sv-nav-next next)
  (make sequence (literal "&nav-next;")))

(define (gentext-sv-nav-up up)
  (make sequence (literal "&nav-up;")))

(define (gentext-sv-nav-home home)
  (make sequence (literal "&nav-home;")))



</style-specification-body>
</style-specification>
</style-sheet>
