<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % pt.words SYSTEM "../common/dbl1pt.ent">
%pt.words;
<!ENTITY cmn.pt SYSTEM "../common/dbl1pt.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-pt">
<style-specification-body>

;; $Id: dbl1pt.dsl,v 1.1 1998/10/19 12:24:32 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.pt;

;; These need to be translated!

(define (gentext-pt-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-pt-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-pt-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-pt-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-pt-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-pt-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
