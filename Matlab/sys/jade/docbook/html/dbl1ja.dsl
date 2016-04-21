<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY % ja.words SYSTEM "../common/dbl1ja.ent">
%ja.words;
<!ENTITY cmn.ja SYSTEM "../common/dbl1ja.dsl">
]>

<style-sheet>
<style-specification id="docbook-l10n-ja">
<style-specification-body>

;; $Id: dbl1ja.dsl,v 1.2 1999/07/02 17:29:45 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;

&cmn.ja;

(define (gentext-ja-nav-prev prev) 
  (make sequence (literal "\U-524D\U-306E\U-30DA\U-30FC\U-30B8")))

(define (gentext-ja-nav-prevsib prevsib) 
  (make sequence (literal "Fast Backward")))

(define (gentext-ja-nav-nextsib nextsib)
  (make sequence (literal "Fast Forward")))

(define (gentext-ja-nav-next next)
  (make sequence (literal "\U-6B21\U-306E\U-30DA\U-30FC\U-30B8")))

(define (gentext-ja-nav-up up)
  (make sequence (literal "Up")))

(define (gentext-ja-nav-home home)
  (make sequence (literal "Home")))

</style-specification-body>
</style-specification>
</style-sheet>
