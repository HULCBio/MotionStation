;; $Id: dbprocdr.dsl,v 1.3 1998/07/31 13:25:25 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

;; ============================= PROCEDURES =============================

(define (PROCSTEP ilvl)
  (if (> ilvl 1) 2.0em 1.8em))

(element procedure 
  (let ((titles (select-elements (children (current-node)) (normalize "title")))
	(preamble (node-list-filter-by-not-gi (children (current-node))
					      (list (normalize "step"))))
	(steps (node-list-filter-by-gi (children (current-node))
				       (list (normalize "step")))))
    (make element gi: "DIV"
	  attributes: (list
		       (list "CLASS" (gi)))
	  (if (not (node-list-empty? titles))
	      (make element gi: "P"
		    (make element gi: "B"
			  (with-mode title-mode
			    (process-node-list titles))))
	      (empty-sosofo))
	  (process-node-list preamble)
	  (make element gi: "OL"
		attributes: (list
			     (list "TYPE" ($proc-hierarch-number-format$ 1)))
		(process-node-list steps)))))

(element (procedure title) (empty-sosofo))

(element substeps
  (make element gi: "OL"
	attributes: (list
		     (list "CLASS" "SUBSTEPS")
		     (list "TYPE" ($proc-hierarch-number-format$
				   (+ ($proc-step-depth$ (current-node)) 1))))
	(process-children)))

(element step
  (let ((id (attribute-string (normalize "id"))))
    (make sequence
      (make element gi: "LI"
	    (if id
		(make element gi: "A"
		      attributes: (list
				   (list "NAME" id))
		      (empty-sosofo))
		(empty-sosofo))
	    (process-children)))))


