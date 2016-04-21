<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % usen.words SYSTEM "../common/dbl1usen.ent">
%usen.words;
<!ENTITY cmn.usen SYSTEM "../common/dbl1usen.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-usen">
<style-specification-body>

;; $Id: dbl1usen.dsl 1.8 1998/09/18 12:51:57 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.usen;

(define (gentext-usen-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-usen-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-usen-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-usen-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-usen-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-usen-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
