<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % lat1 PUBLIC "ISO 8879:1986//ENTITIES Added Latin 1//EN">
%lat1;
<!ENTITY % no.words SYSTEM "../common/dbl1no.ent">
%no.words;
<!ENTITY cmn.no SYSTEM "../common/dbl1no.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-no">
<style-specification-body>

;; $Id: dbl1no.dsl,v 1.5 1999/01/13 17:15:47 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.no;

(define (gentext-no-nav-prev prev) 
  (make sequence (literal "Forrige")))

(define (gentext-no-nav-prevsib prevsib) 
  (make sequence (literal "Raskt Bakover")))

(define (gentext-no-nav-nextsib nextsib)
  (make sequence (literal "Raskt Fremover")))

(define (gentext-no-nav-next next)
  (make sequence (literal "Neste")))

(define (gentext-no-nav-up up)
  (make sequence (literal "Opp")))

(define (gentext-no-nav-home home)
  (make sequence (literal "Hjem")))

</style-specification-body>
</style-specification>
</style-sheet>
