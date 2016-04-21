;; file location: matlabroot/sys/jade/docbook/contrib/header/header.dsl
;;
;; You will need to add this line to your startup.m file:
;;
;; addpath(fullfile(matlabroot,'sys','jade','docbook','contrib','header'))
;;
;; This will allow MATLAB to recognize rptstylesheets.xml
;;
;; If you are using R11, make changes to a few files:
;;
;; toolbox/rptgen/@rptparent/stylesheets.m, line 70:
;;    change 'fileref' to 'overlayfileref'
;;
;; toolbox/rptgen/@coutline/convertoutputfile.m, 
;;     drvDSSSL=[drvDSSSL,fread(dslFID)];
;;    should become:
;;    drvDSSSL=[drvDSSSL,char(fread(dslFID)')];
;;
;;  Copyright 1999-2000 The MathWorks, Inc.
;;  $Revision: 1.1 $  $Date: 2000/06/12 18:21:32 $ 
;;

(define (page-outer-header gi)
  (cond
   ((equal? (normalize gi) (normalize "dedication")) (empty-sosofo))
   ((equal? (normalize gi) (normalize "lot")) (empty-sosofo))
   ((equal? (normalize gi) (normalize "part")) (empty-sosofo))
   ((equal? (normalize gi) (normalize "toc")) (empty-sosofo))
   (else (literal "Type your custom header text here!"))))
