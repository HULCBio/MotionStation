<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % es.words SYSTEM "../common/dbl1es.ent">
%es.words;
<!ENTITY cmn.es SYSTEM "../common/dbl1es.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-es">
<style-specification-body>

;; $Id: dbl1es.dsl,v 1.1 1998/10/19 12:24:32 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.es;

(define (gentext-es-nav-prev prev) 
  (make sequence (literal "Anterior")))

(define (gentext-es-nav-prevsib prevsib) 
  (make sequence (literal "Retroceder")))

(define (gentext-es-nav-nextsib nextsib)
  (make sequence (literal "Avanzar")))

(define (gentext-es-nav-next next)
  (make sequence (literal "Siguiente")))

(define (gentext-es-nav-up up)
  (make sequence (literal "Subir")))

(define (gentext-es-nav-home home)
  (make sequence (literal "Inicio")))

</style-specification-body>
</style-specification>
</style-sheet>
