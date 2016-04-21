<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % de.words SYSTEM "../common/dbl1de.ent">
%de.words;
<!ENTITY cmn.de SYSTEM "../common/dbl1de.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-de">
<style-specification-body>

;; $Id: dbl1de.dsl,v 1.5 1999/01/13 17:15:47 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://nwalsh.com/docbook/dsssl/
;;

&cmn.de;

(define (gentext-de-nav-prev prev) 
  (make sequence (literal "Zur\latin-small-letter-u-with-diaeresis;ck")))

(define (gentext-de-nav-prevsib prevsib) 
  (make sequence (literal "Schnell zur\latin-small-letter-u-with-diaeresis;ck")))

(define (gentext-de-nav-nextsib nextsib)
  (make sequence (literal "Schnell vor")))

(define (gentext-de-nav-next next)
  (make sequence (literal "Vor")))

(define (gentext-de-nav-up up)
  (make sequence (literal "Hoch")))

(define (gentext-de-nav-home home)
  (make sequence (literal "Anfang")))

</style-specification-body>
</style-specification>
</style-sheet>


