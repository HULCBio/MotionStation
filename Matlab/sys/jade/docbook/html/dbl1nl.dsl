<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % nl.words SYSTEM "../common/dbl1nl.ent">
%nl.words;
<!ENTITY cmn.nl SYSTEM "../common/dbl1nl.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-nl">
<style-specification-body>

;; $Id: dbl1nl.dsl,v 1.1 1998/10/19 12:24:32 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.nl;

(define (gentext-nl-nav-prev prev) 
  (make sequence (literal "Terug")))

(define (gentext-nl-nav-prevsib prevsib) 
  (make sequence (literal "Verder terug")))

(define (gentext-nl-nav-nextsib nextsib)
  (make sequence (literal "Verder vooruit")))

(define (gentext-nl-nav-next next)
  (make sequence (literal "Volgende")))

(define (gentext-nl-nav-up up)
  (make sequence (literal "Omhoog")))

(define (gentext-nl-nav-home home)
  (make sequence (literal "Begin")))

</style-specification-body>
</style-specification>
</style-sheet>
