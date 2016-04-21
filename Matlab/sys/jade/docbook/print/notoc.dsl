<!DOCTYPE style-sheet PUBLIC "-//James Clark//DTD DSSSL Style Sheet//EN" [
<!ENTITY docbook.dsl SYSTEM "docbook.dsl" CDATA DSSSL>
]>

<style-sheet>
<style-specification id="docbook-notoc" use="docbook">
<style-specification-body>

;; $Id: notoc.dsl,v 1.0 1997/12/30 17:30:52 nwalsh Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://www.berkshire.net/~norm/dsssl/
;;
;; Example of a customization layer on top of the modular docbook style
;; sheet.  Definitions inserted in this file take precedence over 
;; definitions in the 'use'd stylesheet(s).

(define %generate-toc% #f)

</style-specification-body>
</style-specification>

<external-specification id="docbook" document="docbook.dsl">

</style-sheet>
