<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % pl.words SYSTEM "../common/dbl1pl.ent">
%pl.words;
<!ENTITY cmn.pl SYSTEM "../common/dbl1pl.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-pl">
<style-specification-body>

;; $Id: dbl1pl.dsl,v 1.3 1998/10/19 12:24:32 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.pl;

(define (gentext-pl-nav-prev prev) 
  (make sequence (literal "Poprzedni")))

(define (gentext-pl-nav-prevsib prevsib) 
  (make sequence (literal "Poprzedni rozdzia&#179;")))

(define (gentext-pl-nav-nextsib nextsib)
  (make sequence (literal "Nast&#234;pny rozdzia&#179;")))

(define (gentext-pl-nav-next next)
  (make sequence (literal "Nast&#234;pny")))

(define (gentext-pl-nav-up up)
  (make sequence (literal "Pocz&#177;tek rozdzia&#179;u")))

(define (gentext-pl-nav-home home)
  (make sequence (literal "Spis tre&#182;ci")))

</style-specification-body>
</style-specification>
</style-sheet>
