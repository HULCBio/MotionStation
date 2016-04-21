<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % dk.words SYSTEM "../common/dbl1dk.ent">
%dk.words;
<!ENTITY cmn.dk SYSTEM "../common/dbl1dk.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-dk">
<style-specification-body>

;; $Id: dbl1dk.dsl 1.1 1998/10/30 15:27:51 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.dk;

;; THESE STILL NEED TO BE TRANSLATED!

(define (gentext-dk-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-dk-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-dk-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-dk-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-dk-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-dk-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
