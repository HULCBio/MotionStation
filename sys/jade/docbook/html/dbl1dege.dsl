<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % dege.words SYSTEM "../common/dbl1dege.ent">
%dege.words;
<!ENTITY cmn.dege SYSTEM "../common/dbl1dege.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-dege">
<style-specification-body>

;; $Id: dbl1dege.dsl 1.4 1998/09/18 12:41:46 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.dege;

(define (gentext-dege-nav-prev prev) 
  (make sequence (literal "Zur\latin-small-letter-u-with-diaeresis;ck")))

(define (gentext-dege-nav-prevsib prevsib) 
  (make sequence (literal "Schnell zur\latin-small-letter-u-with-diaeresis;ck")))

(define (gentext-dege-nav-nextsib nextsib)
  (make sequence (literal "Schnell vor")))

(define (gentext-dege-nav-next next)
  (make sequence (literal "Vor")))

(define (gentext-dege-nav-up up)
  (make sequence (literal "Hoch")))

(define (gentext-dege-nav-home home)
  (make sequence (literal "Anfang")))

</style-specification-body>
</style-specification>
</style-sheet>
