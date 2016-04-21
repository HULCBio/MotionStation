;;
;; This file acts as a customization overlay to the DocBook Modular
;; Stylesheets.  It is for use with the Print backend.  It creates
;; a page reference whenever a link is found in the document.
;;
;;
;;  Copyright 1999-2000 The MathWorks, Inc.
;;  $Revision: 1.1 $  $Date: 2000/06/17 16:49:35 $ 
;;

(element link
  ;; No warnings about missing targets.  Jade will do that for us, and
  ;; this way we can use -wno-idref if we really don't care.
  (let* ((endterm   (attribute-string (normalize "endterm")))
	 (linkend   (attribute-string (normalize "linkend")))
	 (target    (element-with-id linkend))
	 (etarget   (if endterm 
			(element-with-id endterm)
			(empty-node-list)))
	 (link-cont (if endterm
			(if (node-list-empty? etarget)
			    (literal 
			     (string-append "LINK CONTENT ENDTERM '"
					    endterm
					    "' MISSING"))
			    (with-mode xref-endterm-mode
			      (process-node-list etarget)))
			(process-children))))
    (if (node-list-empty? target)
	link-cont
	(make link 
	  destination: (node-list-address target)
	  (make sequence 
           link-cont
           ($ss-seq$ -
           (make sequence
               (literal " [")
                (element-page-number-sosofo target)
                (literal "] "))))))))

(element anchor
  ;; This is different than (empty-sosofo) alone because the backend
  ;; will hang an anchor off the empty sequence.  This allows the link
  ;; to point to the anchor.
  (make sequence (empty-sosofo)))
