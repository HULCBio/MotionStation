<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % fr.words SYSTEM "../common/dbl1fr.ent">
%fr.words;
<!ENTITY cmn.fr SYSTEM "../common/dbl1fr.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-fr">
<style-specification-body>

;; $Id: dbl1fr.dsl,v 1.4 1999/07/02 17:29:45 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://nwalsh.com/docbook/dsssl/
;;

&cmn.fr;

(define (gentext-fr-nav-prev prev) 
  (make sequence (literal "Pr\U-00E9;c\U-00E9;dant")))

(define (gentext-fr-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-fr-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-fr-nav-next next)
  (make sequence (literal "Suivant")))

(define (gentext-fr-nav-up up)
  (make sequence (literal "Niveau sup\U-00E9;rieur")))

(define (gentext-fr-nav-home home)
  (make sequence (literal "Sommaire")))

</style-specification-body>
</style-specification>
</style-sheet>
