<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % cyr1 PUBLIC "ISO 8879:1986//ENTITIES Russian Cyrillic//EN">
%cyr1;
<!ENTITY cmn.ru SYSTEM "../common/dbl1ru.dsl">
<!ENTITY % ru.words SYSTEM "../common/dbl1ru.ent">
%ru.words;
]>

<style-sheet>
<style-specification id="docbook-l10n-ru">
<style-specification-body>

;; $Id: dbl1ru.dsl,v 1.5 1998/10/30 11:37:04 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.ru;

(define (gentext-ru-nav-prev prev) 
  (make sequence (literal "&Pcy;&rcy;&iecy;&dcy;.")))

(define (gentext-ru-nav-prevsib prevsib) 
  (make sequence (literal "&Pcy;&rcy;&iecy;&dcy;. &pcy;&ocy;&dcy;&rcy;&acy;&zcy;&dcy;&iecy;&lcy;")))

(define (gentext-ru-nav-nextsib nextsib)
  (make sequence (literal "&Scy;&lcy;&iecy;&dcy;. &pcy;&ocy;&dcy;&rcy;&acy;&zcy;&dcy;&iecy;&lcy;")))

(define (gentext-ru-nav-next next)
  (make sequence (literal "&Scy;&lcy;&iecy;&dcy;.")))

(define (gentext-ru-nav-up up)
  (make sequence (literal "&Ucy;&rcy;&ocy;&vcy;&iecy;&ncy;&softcy; &vcy;&ycy;&shcy;&iecy;")))

(define (gentext-ru-nav-home home)
  (make sequence (literal "&Ncy;&acy;&chcy;&acy;&lcy;&ocy;")))

</style-specification-body>
</style-specification>
</style-sheet>
