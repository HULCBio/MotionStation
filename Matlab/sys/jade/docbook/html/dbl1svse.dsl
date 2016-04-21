<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % svse.words SYSTEM "../common/dbl1svse.ent">
%svse.words;
<!ENTITY cmn.svse SYSTEM "../common/dbl1svse.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-svse">
<style-specification-body>

;; $Id: dbl1svse.dsl 1.1 1998/10/30 15:27:47 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.svse;

;; THESE STILL NEED TO BE TRANSLATED!

(define (gentext-svse-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-svse-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-svse-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-svse-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-svse-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-svse-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
