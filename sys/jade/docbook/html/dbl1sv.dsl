<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % sv.words SYSTEM "../common/dbl1sv.ent">
%sv.words;
<!ENTITY cmn.sv SYSTEM "../common/dbl1sv.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-sv">
<style-specification-body>

;; $Id: dbl1sv.dsl,v 1.2 1999/01/13 17:15:47 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.sv;

;; THESE STILL NEED TO BE TRANSLATED!

(define (gentext-sv-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-sv-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-sv-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-sv-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-sv-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-sv-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
