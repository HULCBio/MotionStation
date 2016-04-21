<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % lat1 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 1//EN">
%lat1;
<!ENTITY % lat2 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 2//EN">
%lat2;
<!ENTITY % ro.words SYSTEM "../common/dbl1ro.ent">
%ro.words;
<!ENTITY cmn.ro SYSTEM "../common/dbl1ro.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-ro">
<style-specification-body>

;; $Id: dbl1ro.dsl,v 1.1 1999/02/22 22:29:49 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.ro;

(define (gentext-ro-nav-prev prev) 
  (make sequence (literal "Prev")))

(define (gentext-ro-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-ro-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-ro-nav-next next)
  (make sequence (literal "Next")))

(define (gentext-ro-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-ro-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
