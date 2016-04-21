<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % en.words SYSTEM "../common/dbl1en.ent">
%en.words;
<!ENTITY cmn.en SYSTEM "../common/dbl1en.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-en">
<style-specification-body>

;; $Id: dbl1en.dsl,v 1.9 1999/01/13 17:15:47 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.en;

(define (gentext-en-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-en-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-en-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-en-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-en-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-en-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
