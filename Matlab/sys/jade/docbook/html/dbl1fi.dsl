<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % fi.words SYSTEM "../common/dbl1fi.ent">
%fi.words;
<!ENTITY cmn.fi SYSTEM "../common/dbl1fi.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-fi">
<style-specification-body>

;; $Id: dbl1fi.dsl,v 1.2 1999/07/02 17:29:45 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.fi;

(define (gentext-fi-nav-prev prev) 
  (make sequence (literal "Edellinen")))

(define (gentext-fi-nav-prevsib prevsib) 
  (make sequence (literal "Nopeasti taaksep\U-00E4;in")))

(define (gentext-fi-nav-nextsib nextsib)
  (make sequence (literal "Nopeasti eteenp\U-00E4;in")))

(define (gentext-fi-nav-next next)
  (make sequence (literal "Seuraava")))

(define (gentext-fi-nav-up up)
  (make sequence (literal "Yl\U-00F6;s")))

(define (gentext-fi-nav-home home)
  (make sequence (literal "Alkuun")))

</style-specification-body>
</style-specification>
</style-sheet>
