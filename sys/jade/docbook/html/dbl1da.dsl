<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % da.words SYSTEM "../common/dbl1da.ent">
%da.words;
<!ENTITY cmn.da SYSTEM "../common/dbl1da.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-da">
<style-specification-body>

;; $Id: dbl1da.dsl,v 1.3 1999/07/02 17:29:44 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.da;

(define (gentext-da-nav-prev prev) 
  (make sequence (literal "Forrige")))

(define (gentext-da-nav-prevsib prevsib) 
  (make sequence (literal "Hurtigt tilbage")))

(define (gentext-da-nav-nextsib nextsib)
  (make sequence (literal "Hurtigt frem")))

(define (gentext-da-nav-next next)
  (make sequence (literal "N&#230;ste")))

(define (gentext-da-nav-up up)
  (make sequence (literal "Op")))

(define (gentext-da-nav-home home)
  (make sequence (literal "Startside")))

</style-specification-body>
</style-specification>
</style-sheet>
