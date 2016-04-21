<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % it.words SYSTEM "../common/dbl1it.ent">
%it.words;
<!ENTITY cmn.it SYSTEM "../common/dbl1it.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-it">
<style-specification-body>

;; $Id: dbl1it.dsl,v 1.1 1998/10/19 12:24:32 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.it;

(define (gentext-it-nav-prev prev) 
  (make sequence (literal "Indietro")))

(define (gentext-it-nav-prevsib prevsib) 
  (make sequence (literal "Salta indietro")))

(define (gentext-it-nav-nextsib nextsib)
  (make sequence (literal "Salta avanti")))

(define (gentext-it-nav-next next)
  (make sequence (literal "Avanti")))

(define (gentext-it-nav-up up)
  (make sequence (literal "Risali")))

(define (gentext-it-nav-home home)
  (make sequence (literal "Partenza")))

</style-specification-body>
</style-specification>
</style-sheet>
