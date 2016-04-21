<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % ca.words SYSTEM "../common/dbl1ca.ent">
%ca.words;
<!ENTITY cmn.ca SYSTEM "../common/dbl1ca.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-ca">
<style-specification-body>

;; $Id: dbl1ca.dsl,v 1.1 1999/06/06 13:23:46 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.ca;

(define (gentext-ca-nav-prev prev) 
  (make sequence (literal "Anterior")))

(define (gentext-ca-nav-prevsib prevsib) 
  (make sequence (literal "Retrocedir")))

(define (gentext-ca-nav-nextsib nextsib)
  (make sequence (literal "Avancar")))

(define (gentext-ca-nav-next next)
  (make sequence (literal "Seguent")))

(define (gentext-ca-nav-up up)
  (make sequence (literal "Pujar")))

(define (gentext-ca-nav-home home)
  (make sequence (literal "Inici")))

</style-specification-body>
</style-specification>
</style-sheet>
