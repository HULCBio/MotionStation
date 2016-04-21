;;; matlab-eei.el --- major mode for MATLAB dot-m files
;;; $Revision: 1.2.4.2 $
;; Author: Paul Kinnucan <paulk@mathworks.com>
;; Maintainer: Paul Kinnucan <paulk@mathworks.com>
;; Created: May 2, 2000
;; Version: 1.0
;; Keywords: MATLAB
;;
;; LCD Archive Entry:
;; matlab|Paul Kinnucan|paulk@mathworks.com|
;; Major mode for editing and debugging MATLAB dot-m files|
;; May-00|1.0|~/modes/matlab-eei.el|
;;
;; Copyright 2000-2004 The MathWorks, Inc.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;;; Commentary:
;;
;;; Finding Updates:
;;
;; The latest stable version of matlab.el can be found here:
;;
;; ftp://ftp.mathworks.com/pub/contrib/emacs_add_ons/matlab-eei.el
;;
;;; Installation:
;;


(require 'cl)
(require 'wid-edit)
(require 'matlab-vdm)

(defconst matlab-eei-xemacsp (string-match "XEmacs" (emacs-version))
  "Non-nil if we are running in the XEmacs environment.")

(defconst matlab-eei-new-m-file-name "untitled"
  "Name of a new m-file.")

(defvar matlab-eei-new-m-file-count 0
  "Number of new m-files created thus far in this session.")

(defun matlab-eei-eval-output (lisp-form)
  "Evaluates Lisp forms output by eei."
  ;; (message lisp-form)
  (condition-case error-desc
      (eval (read lisp-form))
    (error 
     (message 
      "Error: evaluating output from the MATLAB EEI caused a Lisp error.")
     (message "EEI output: %s." lisp-form)
     (message "Lisp error: %s" error-desc))))


(defun matlab-eei-extract-lisp-form (eei-output)
"Extract first complete Lisp form from eei output.
Returns (FORM . REMAINDER) where FORM is the Lisp form
or the null string and REMAINDER is the remainder of the
eei output following the Lisp form."
  (let ((lisp-form "")
	(remainder "")
	(level 0)
	in-string-p
	in-escape-p
	(curr-pos 1)
	(output-length (length eei-output))
	command-end
	lisp-form-end)
    (setq 
     lisp-form-end
     (catch 'found-lisp-form
       ;; skip over any inital white space.
       (string-match "^[\n\t ]*(" eei-output)
       (setq curr-pos (match-end 0))

       (while (< curr-pos output-length)

	 (cond 

	  ;; Current character = left slash (escape)
	  ((equal (aref eei-output curr-pos) ?\\)
	   (if in-string-p
	       (setq in-escape-p (not in-escape-p))))
	  
	  ;; Current character = quotation mark
	  ((equal (aref eei-output curr-pos) ?\")
	   (if in-string-p
	       (if in-escape-p
		   (setq in-escape-p nil)
		 (setq in-string-p nil))
	     (setq in-string-p t)))

	  ;; Current character = right paren
	  ((and
	    (not in-string-p)
	    (equal (aref eei-output curr-pos) ?\)))
	     (if (= level 0)
		 (throw 'found-lisp-form curr-pos)
	       (setq level (1- level))
	       (if (< level 0)
		   (error "Error parsing eei output."))))

	  ;; Current character = left paren
	  ((and
	    (not in-string-p)
	    (equal (aref eei-output curr-pos) ?\()
	       (setq level (1+ level))))
	  (t
	   (if in-escape-p
	       (setq in-escape-p nil))))

	 (setq curr-pos (1+ curr-pos)))

       -1))
    (if (> lisp-form-end 1)
	(progn
	  (setq lisp-form (substring eei-output 0 (1+ lisp-form-end)))
	  (when (< lisp-form-end (1- output-length))
	    (setq remainder (substring eei-output (1+ lisp-form-end) output-length))
	    (if (string-match "(" remainder)
		(setq remainder (substring remainder (string-match "(" remainder)))
	      (setq remainder ""))))
      (setq remainder eei-output))
    (cons lisp-form remainder)))

(defvar matlab-eei-standard-comint-filter nil
  "Standard process filter for comint buffers.")

(defvar matlab-eei-output nil
  "Contains output from the eei.")


(defun matlab-eei-asynch-output-listener (process output)
  "Listens at the eei socket for asynchronous eei output."
  (let* ((combined-output (concat matlab-eei-output output))
	 (parsed-output 
	  (if (string-match "^[\n\t ]*(" combined-output)
	      (matlab-eei-extract-lisp-form combined-output)))		
	 (lisp-form (car parsed-output))
	 (remainder (cdr parsed-output))
	 forms)
    
    ;; (message "asynch form: %s" lisp-form)
    ;; (message "asynch remainder: %s" remainder)

    ;; Insert output in MATLAB EEI buffer.
    (funcall matlab-eei-standard-comint-filter process output)

    ;; Extract forms from eei output.
    (while (not (string= lisp-form ""))
      ;; (message "   evaluating %s" lisp-form)
      (setq forms (append forms (list lisp-form)))
      (setq parsed-output
	    (matlab-eei-extract-lisp-form remainder))
      (setq lisp-form (car parsed-output))
      (setq remainder (cdr parsed-output)))
    (setq matlab-eei-output remainder)
    (if forms
	(mapc (lambda (form) (matlab-eei-eval-output form))
	      forms))))

(defvar matlab-eei-process nil
  "Process object for MATLAB EEI process.")

(defun matlab-eei-process-sentinel (process status)
  "Sentinel function invoked by Emacs when MATLAB exits.
This function invokes the standard Emacs exit function
`save-buffers-kill-emacs'."
  (if (string-match "exited" status)
      (save-buffers-kill-emacs)))

;;;###autoload
(defun matlab-eei-connect ()
  "Connects Emacs to MATLAB's external editor interface
on socket 5600."
  (let* ((matlab-editor-port 5600)
	 (matlab-eei-buffer-name "MATLAB EEI")
	 (matlab-eei-buffer 
	  (make-comint 
	   "MATLAB EEI" 
	   (cons (system-name) matlab-editor-port))))

    (setq matlab-eei-process (get-process matlab-eei-buffer-name))
    (process-kill-without-query matlab-eei-process)       
    (set-process-sentinel matlab-eei-process 'matlab-eei-process-sentinel)
    (setq matlab-eei-standard-comint-filter 'comint-output-filter)

    (set-process-filter matlab-eei-process
			'matlab-eei-asynch-output-listener)
    (add-hook 'matlab-mode-hook 'matlab-eei-setup-matlab-mode)
    (setq matlab-eei-new-m-file-count 0)
    (matlab-eei-send-mcmd "get_stop_conditions")
    (matlab-eei-send-mcmd "update_debug_mode_status")))

(defun matlab-eei-setup-matlab-mode ()
  "Sets up matlab-mode in a newly opened m-file."
  (matlab-eei-minor-mode)
  (make-local-hook 'after-save-hook)
  (add-hook 'after-save-hook 'matlab-eei-reset-breakpoints nil t)
  (make-local-hook 'after-revert-hook)
  (add-hook 'after-revert-hook 'matlab-eei-reset-breakpoints nil t)
  (matlab-eei-send-mcmd (format "init_breakpoints %s"
				(buffer-file-name)))
  (matlab-eei-send-mcmd "update_stack")
  (turn-on-matlab-vdm-mode))


(defun matlab-eei-send-mcmd (command &optional synch)
  "Sends an MEI M Command to the MATLAB side of the MEI interface
and waits for a response."
  ;; (message "mcmd: command = %s synch = %s" command
  ;;   (if synch "yes" "no"))
  (if (and matlab-eei-process
	   (eq (process-status matlab-eei-process) 'open))
      (progn
	(setq matlab-eei-last-event nil)
	(process-send-string matlab-eei-process (concat command "\n"))
	(if synch
	    (accept-process-output matlab-eei-process 10 0)))))

; (defun matlab-eei-eval-m-expr (expr)
;   "Send EXPR to MATLAB for evaluation. EXPR can be any valid
; MATLAB expression, including multiline expressions. This
; command prepends and appends a line containing a single quotation
; mark to EXPR to indicate its beginning and end, respectively.
; For this reason, EXPR may not contain a line containing a single
; quotation mark."
;   (if (string-match "\n\"\n" expr)
;       (error (concat "Cannot evaluate an expression containing "
; 		       "a quotation mark by itself on a line."))
;     (process-send-string matlab-eei-process 
; 		       (format "eval\n\"\n%s\n\"\n" expr))))

(defun matlab-eei-eval-m-expr (expr)
  "Send EXPR to MATLAB for evaluation. EXPR can be any valid
MATLAB expression, including multiline expressions."
  (process-send-string matlab-eei-process 
		       (format "eval %d\n%s" (length expr) expr)))
 
(defvar matlab-eei-last-event nil
"Debug event that followed the last command.")

(defun matlab-eei-wait-for-event ()
  "Waits for an event to occur. Returns the event or \"timeout\" if no
event occurred within 10 seconds."
  (if matlab-eei-last-event
      matlab-eei-last-event
    (accept-process-output matlab-eei-process 10 0)
    (or matlab-eei-last-event "timeout")))

(defun matlab-eei-mcmd-quit ()
  "Tells MATLAB to exit from eei mode."
  (matlab-eei-send-mcmd "quit"))

(defun matlab-eei-ready ()
  "E-message sent by MATLAB when it is ready to 
accept a command."
  (setq matlab-eei-last-event nil))

(defcustom matlab-eei-reuse-frame t
  "If non-nil causes Emacs to reuse the current frame to
open a new file."
  :group 'matlab
  :type 'boolean)
	 
(defun matlab-eei-find-file (filename &optional wildcards)
  "Open file FILENAME."
  (let ((file 
	 (if (string-match "\\.p$" filename)
	     (concat (file-name-sans-extension filename) ".m")
	   filename)))
    (if (file-exists-p file)
	(let ((buffer (find-file-noselect file t nil)))
	  (if (string= (buffer-name (current-buffer)) 
		       matlab-eei-stack-navigator-name)
	      (other-window 1))
	  (if (listp buffer)
	      (progn
		(setq buffer (nreverse buffer))
		(if matlab-eei-reuse-frame
		    (progn
		      (switch-to-buffer-other-frame (car buffer))
		      (setq buffer (cdr buffer))))
		(mapcar 'switch-to-buffer buffer))
	    (if matlab-eei-reuse-frame
		(switch-to-buffer buffer)
	      (switch-to-buffer-other-frame buffer))))
      (message "Error: Cannot find %s" file))))

(defun matlab-eei-new-document (content) 
  "Creates a new M-file buffer containing CONTENT.
This function implements the newDocument method of
MATLAB's ExternalEditorInterface."
  (setq matlab-eei-new-m-file-count
	(1+ matlab-eei-new-m-file-count))
  (switch-to-buffer 
   (create-file-buffer 
    (if (= matlab-eei-new-m-file-count 1)
	(concat 
	 matlab-eei-new-m-file-name
	 ".m")
      (concat
       matlab-eei-new-m-file-name
       (number-to-string matlab-eei-new-m-file-count)
       ".m")))
    nil)
   (if (not (string= content "null"))
       (insert content))
   (matlab-mode))

(defun matlab-eei-open-document (docpath)
  "Opens the document specified by DOCPATH.
This function implements the OpenDocument method
of the MATLAB ExternalEditorInterface."
  (matlab-eei-find-file docpath))

(defun matlab-eei-open-document-to-line (docpath line to-front highlight)
  "Opens the document specified by DOCPATH to the
line specified by LINE. If TO-FRONT is non-nil, this function
raises the Emacs frame to the front of the user's desktop. If 
HIGHLIGHT is non-nil, this function highlights the line specified by
LINE-NO. This function implements the openDocumentToLine method of
MATLAB's ExternalEditorInterface."
  ;; (message "open-document-to-line: doc: %s, line: %s" docpath line)
  (matlab-eei-find-file docpath)
  ;; If the user issues a step command and the current line is
  ;; the last line in a function, MATLAB issues an open-document-to-line
  ;; command with the line number equal to the negative of the last line
  ;; in the M-file and then issues a stop event with the same negative
  ;; line number. In this case, we ignore the line positioning.
  ;;
  (if (> line -1)
      (progn
	(goto-line line)
	(if matlab-eei-matlab-in-debug-mode-p
	    (matlab-eei-move-debug-cursor docpath line))
	(if to-front (raise-frame))
	;; The following never occurs for some reason.
	;; (if highlight
	;;    (matlab-eei-breakpoint-highlight-create line))
	)))


 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                               ;;
;; Set and Clear Breakpoints                                     ;;
;;                                                               ;;
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defcustom matlab-eei-breakpoint-marker-colors (cons "black" "orange red")
"*Specifies the foreground and background colors of the debugger's
breakpoint marker."
  :group 'matlab
  :type '(cons :tag "Colors"
	  (string :tag "Foreground") 
	  (string :tag "Background"))
  :set '(lambda (sym val)
	  (make-face 'matlab-eei-breakpoint-marker)
	  (set-face-foreground 'matlab-eei-breakpoint-marker (car val))
	  (set-face-background 'matlab-eei-breakpoint-marker (cdr val))
	  (set-default sym val)))

(defcustom matlab-eei-provisional-breakpoint-marker-colors (cons "red" "orange")
"*Specifies the foreground and background colors of the debugger's
provisional breakpoint marker. A provisional breakpoint is a breakpoint that MATLAB
has not yet confirmed as existing."
  :group 'matlab
  :type '(cons :tag "Colors"
	  (string :tag "Foreground") 
	  (string :tag "Background"))
  :set '(lambda (sym val)
	  (make-face 'matlab-eei-provisional-breakpoint-marker)
	  (set-face-foreground 'matlab-eei-provisional-breakpoint-marker (car val))
	  (set-face-background 'matlab-eei-provisional-breakpoint-marker (cdr val))
	  (set-default sym val)))

(defcustom matlab-eei-debug-cursor-type (list "arrow")
  "Type of cursor used to indicate the line where the debugger has
halted execution of the current M function. The arrow method displays
an arrow at the beginning of the line. In Emacs 21, the arrow appears
in the window gutter. In older versions, the arrow is a text arrow (=>)
that overlays and obscures the first two characters of the line. The
highlight method highlights the line at which execution is stopped.
Use " 
  :group 'matlab
  :type '(list
	  (radio-button-choice 
	  (const "arrow")
	  (const "highlight"))))

(defvar matlab-eei-highlight-cursor 
  (if (featurep 'xemacs)
      (make-extent 1 1)
    (make-overlay 0 0))
  "Highlight cursor.")

(defcustom matlab-eei-highlight-cursor-color (cons "black" "yellow")
"*Specifies the foreground and background colors of the debugger's
highlight-style debug cursor."
  :group 'matlab
  :type '(cons  
	  (string :tag "Foreground Color") 
	  (string :tag "Background Color"))
  :set '(lambda (sym val)
	  (make-face 'matlab-eei-highlight-cursor-face)
	  (set-face-foreground 'matlab-eei-highlight-cursor-face (car val))
	  (set-face-background 'matlab-eei-highlight-cursor-face (cdr val))
	  (if (featurep 'xemacs)
	      (progn
		(set-extent-face matlab-eei-highlight-cursor 
				 'matlab-eei-highlight-cursor-face)
		(set-extent-priority matlab-eei-highlight-cursor 98))
	    (progn
	      (overlay-put matlab-eei-highlight-cursor  
			   'face 'matlab-eei-highlight-cursor-face)
	      (overlay-put matlab-eei-highlight-cursor 'priority 99)))
	  (set-default sym val)))


(defvar matlab-eei-matlab-in-debug-mode-p nil 
  "Non-nil if MATLAB is running in debug mode.")

(defvar matlab-eei-matlab-stopped-p nil
  "Non-nil if MATLAB is stopped.")


(defun matlab-eei-debug-mode-status (status)
  "Sets debug mode status flag to STATUS."
  (message "debug mode status %s" status)
  (setq matlab-eei-matlab-in-debug-mode-p status))

;; +----------------------------------------+
;; |           Breakpoints                  |
;; +----------------------------------------+

(defvar matlab-eei-breakpoints nil
"Current breakpoints.")

(defun matlab-eei-breakpoint-set-face (marker face)
  "Apply FACE to MARKER."
  (if (featurep 'xemacs)
      (progn
	(set-extent-face marker face)
	(set-extent-priority marker 98))
    (progn
      (overlay-put marker  'face face)
      (overlay-put marker 'priority 98))))

(defun matlab-eei-is-breakpoint-marker-p (marker)
  "Return t if MARKER is a breakpoint marker (overlay or extent)."
  (let ((marker-face 
	 (if (featurep 'xemacs)
	     (extent-property marker 'face nil)
	   (overlay-get marker 'face))))
    (or
     (eq marker-face 'matlab-eei-breakpoint-marker)
     (eq marker-face 'matlab-eei-provisional-breakpoint-marker))))

(defun matlab-eei-breakpoint-marker-create (&optional file line)
  "Create a breakpoint marker at LINE in FILE."
  (save-excursion
    
    ;; Switch to buffer containing new breakpoint, if necessary.
    (if file
	(let ((buf (find-buffer-visiting file)))
	  (if (not (eq buf (current-buffer)))
	      (set-buffer buf))))	 
    (if line (goto-line line))
    (if (featurep 'xemacs)
	(make-extent
	 (line-beginning-position)
	 (line-end-position))
      (make-overlay
       (line-beginning-position)
       (line-end-position)
       (current-buffer) nil t))))

(defun matlab-eei-breakpoint-marker-remove (&optional file line)
  "Remove breakpoint marker at LINE in FILE."
  (save-excursion

    ;; Switch to buffer containing new breakpoint, if necessary.
    (if file
	(let ((buf (find-buffer-visiting file)))
	  (if (not (eq buf (current-buffer)))
	      (set-buffer buf))))

    (if line (goto-line line))

    (if (featurep 'xemacs)
	(let ((extents (extents-at (line-beginning-position))))
	  (while extents
	    (let ((extent (car extents)))
	      (if (matlab-eei-is-breakpoint-marker-p extent)
		  (delete-extent extent)))
	    (setq extents (cdr extents))))
      (let ((overlays (overlays-at (line-beginning-position))))
	(while overlays
	  (let ((overlay (car overlays)))
	    (if (matlab-eei-is-breakpoint-marker-p overlay)
		(delete-overlay overlay)))
	  (setq overlays (cdr overlays)))))))

(defvar matlab-eei-breakpoints-alist nil
"List of current breakpoints.")

(defun matlab-eei-breakpoints-add (file line &optional provisional-p)
  "Add the breakpoint at LINE in FILE to the list of current breakpoints
stored in `matlab-eei-breakpoints-alist'. PROVISIONAL-P indicates whether
the breakpoint is provisional, i.e., because FILE is dirty. EEI uses
a different face to highlight a provisional breakpoint."
  (let ((marker (matlab-eei-breakpoint-marker-create file line)))
    (matlab-eei-breakpoint-set-face 
     marker 
     (if provisional-p
	 'matlab-eei-provisional-breakpoint-marker
       'matlab-eei-breakpoint-marker))      
    (setq 
     matlab-eei-breakpoints-alist
     (append
      matlab-eei-breakpoints-alist
      (list (cons (if (eq system-type 'windows-nt) 
		      (downcase file)
		      file)
		  marker))))))

(defun matlab-eei-breakpoint-confirm-add (file line)
  "Confirm the provisional breakpoint at LINE in FILE by 
changing its face to the standard breakpoint face."
  (let ((bp (matlab-eei-breakpoint-exists-p file line)))
    (if bp
	(matlab-eei-breakpoint-set-face (cdr bp) 'matlab-eei-breakpoint-marker))))
	
(defun matlab-eei-breakpoint-set-invisible (file line)
  "Make the breakpoint at LINE in FILE invisible."
  (let ((bp (matlab-eei-breakpoint-exists-p file line)))
    (if bp
	(matlab-eei-breakpoint-set-face (cdr bp) nil))))

(defun matlab-eei-marker-line (marker)
  "Get the number of the line containing marker."
  (matlab-eei-get-line-at-point 
   (if (featurep 'xemacs)
       (extent-start-position marker)
     (overlay-start marker))))

(defun matlab-eei-breakpoints-delete (file line)
  "Delete the breakpoint at LINE in FILE."
  (setq matlab-eei-breakpoints-alist
	(remove-if
	 (lambda (xbp)
	   (let ((xfile (car xbp))
		 (xmarker (cdr xbp)))
	     (and
	      (string= file xfile)
	      (equal line (matlab-eei-marker-line xmarker)))))
	 matlab-eei-breakpoints-alist))
      (matlab-eei-breakpoint-marker-remove file line))


(defun matlab-eei-breakpoints-clear ()
  "Clear all breakpoints from all buffers."
  (mapc
   (lambda (bpspec)
     (let* ((file (car bpspec))
	    (buf (find-buffer-visiting file)))
       (if buf
	   (save-excursion
	     (set-buffer buf)
	     (let ((line (matlab-eei-marker-line (cdr bpspec))))
	       (matlab-eei-breakpoint-marker-remove file line))))))
      matlab-eei-breakpoints-alist)
  (setq matlab-eei-breakpoints-alist nil))
   

(defun matlab-eei-breakpoint-exists-p (file line)
  "Returns breakpoint if breakpoint exists at FILE and LINE."
  (find-if 
   (lambda (xbp)
       (and 
	(string= (car xbp) file)
	(equal (matlab-eei-marker-line (cdr xbp)) line)))
   matlab-eei-breakpoints-alist))


(defun matlab-eei-get-line-at-point (&optional pos)
  (let* ((point (or pos (point)))
	 (ln (if (= point 1)
		 1
	       (count-lines (point-min) point))))
    (save-excursion
      (goto-char point)
      (if (eq (char-before) ?\n)
	  (1+ ln)
	ln))))

(defun matlab-eei-request-set-breakpoint (file line)
  "If the current buffer is not modified, ask MATLAB to set
a breakpoint at the current line. Otherwise, cache the request
until the user saves the buffer."
  ;;(message "event: bp at %s %s" file line)
  (if (not (buffer-modified-p))
      (matlab-eei-send-mcmd
       (format "request_set_breakpoint %s %d" file line) t)
      (matlab-eei-breakpoints-add file line t))
  ;; (message "bp alist %s" (pp-to-string matlab-eei-breakpoints-alist))
  )

(defun matlab-eei-event-set-breakpoint (file line)
  "Handle a set breakpoint event from the MATLAB debugger."
  ;; (message "event set bp: %s %s" file line)
  (if (and
       (not matlab-eei-go-until-cursor-mode-p)
       ;; Ignore if file is currently not open.
       (find-buffer-visiting file))
      (matlab-eei-breakpoints-add file line))
  (setq matlab-eei-last-event "set-breakpoint"))


(defun matlab-eei-request-clear-breakpoint (file line)
  "Send a command to MATLAB requesting that the breakpoint
at LINE in FILE be cleared."
  (if (buffer-modified-p)
      (matlab-eei-breakpoints-delete file line)
    (matlab-eei-send-mcmd
     (format "request_clear_breakpoint %s %d" file line))))

(defun matlab-eei-event-clear-breakpoint (file line)
  "Handle a request to clear the breakpoint at LINE from
the M-file FILE."
  (matlab-eei-breakpoints-delete file line))


(defun matlab-eei-breakpoint-set-clear()
  "Request MATLAB to set a breakpoint at the current line
or clear the existing breakpoint in the current buffer."
  (interactive)
;;  (matlab-run-in-matlab-mode-only
  (if (buffer-file-name)
      (let* ((file (if (eq system-type 'windows-nt)
		       (downcase (buffer-file-name))
		     (buffer-file-name)))
	     (line (matlab-eei-get-line-at-point)))

	(if (and
	     (eq system-type 'windows-nt)
	     (featurep 'xemacs))
	    (subst-char-in-string ?\\ ?/ file t))

	(if (matlab-eei-breakpoint-exists-p file line)
	    (matlab-eei-request-clear-breakpoint file line)
	  (matlab-eei-request-set-breakpoint file line)))
    (error 
     "You must save this buffer before attempting to set a breakpoint."))
  ;; )
  )

(defun matlab-eei-clear-breakpoints ()
  "Ask MATLAB to clear all breakpoints in the current buffer."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (if matlab-eei-breakpoints-alist	
       (matlab-eei-send-mcmd
	(format "request_clear_breakpoints") t))))

(defun matlab-eei-event-clear-breakpoints ()
  "Handle a clear breakpoints event from MATLAB."
  ;; (message "event clear breakpoints")
  (matlab-eei-breakpoints-clear)
  (setq matlab-eei-last-event "clear-breakpoints"))


(defun matlab-eei-reset-breakpoints ()
  (if (eq major-mode 'matlab-mode)
      (let* ((file (if (eq system-type 'windows-nt)
		       (downcase (buffer-file-name))
		     (buffer-file-name)))
	     (breakpoints
	      (delq 
	       nil 
	       (mapcar
		(lambda (bp)
		  (let ((xfile (car bp)))
		    (if (string= xfile file) 
			(matlab-eei-marker-line (cdr bp)))))
		matlab-eei-breakpoints-alist))))
	(matlab-eei-clear-breakpoints)
	(if (and
	     breakpoints
	     (string= (matlab-eei-wait-for-event) "clear-breakpoints"))
	    (progn
	      (matlab-eei-send-mcmd (concat "reset_file " file))
	      (mapc
	       (lambda (line)
		 (matlab-eei-request-set-breakpoint file line))
	       breakpoints))))))


;; +------------------------------------+
;; | Stop-if commands                   |
;; +------------------------------------+

(defvar matlab-eei-last-stop-if-command nil
  "Last stop-if command executed.")

(defvar matlab-eei-stop-if-state '(("error" . nil) ("caught_error". nil) ("warning" . nil)
				   ("nan_inf" . nil))
  "")
(make-variable-buffer-local 'matlab-eei-stop-if-state)

;; XEmacs compatibility.
(if (not (fboundp 'assoc-ignore-representation))
    (defalias 'assoc-ignore-representation 'assoc-ignore-case))

(defun matlab-eei-get-stop-if-state (state-name)
  (cdr (assoc-ignore-representation state-name matlab-eei-stop-if-state)))

(defun matlab-eei-set-stop-if-state (state-name state)
  (setcdr (assoc-ignore-representation state-name matlab-eei-stop-if-state) state))

(defun matlab-eei-toggle-stop-if (condition)
  "Toggle stop-if state."
  (matlab-eei-send-mcmd
   (format "toggle_stop_if %s" condition))
  (setq matlab-eei-last-stop-if-command condition))


(defun matlab-eei-toggle-stop-if-error ()
  "Toggle stop-if-error state for the 
M-file in the current buffer."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (matlab-eei-toggle-stop-if "error")))

(defun matlab-eei-toggle-stop-if-caught-error ()
  "Toggle stop-if-caught-error state for the 
M-file in the current buffer."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (matlab-eei-toggle-stop-if "caught_error")))



(defun matlab-eei-toggle-stop-if-warning ()
  "Toggle stop-if-warning state for the 
M-file in the current buffer."
  (interactive)
  (matlab-eei-toggle-stop-if "warning"))


(defun matlab-eei-toggle-stop-if-nan-inf ()
  "Toggle stop-if-nan-inf state for the 
M-file in the current buffer."
  (interactive)
  (matlab-eei-toggle-stop-if "nan_inf"))

(defun matlab-eei-event-stop-if (conditions) 
  (matlab-eei-set-stop-if-state "error" (nth 0 conditions))
  (matlab-eei-set-stop-if-state "caught_error" (nth 1 conditions))
  (matlab-eei-set-stop-if-state "warning" (nth 2 conditions))
  (matlab-eei-set-stop-if-state "nan_inf" (nth 3 conditions)))
     

;; +------------------------------------+
;; | Debug Cursor                       |
;; +------------------------------------+

(if (fboundp 'move-overlay)
    (defalias 'matlab-eei-move-marker 'move-overlay)
  (defun matlab-eei-move-marker (marker beg end &optional buffer)
    "Set the endpoints of MARKER to BEG and END in BUFFER.
If MARKER is omitted, leave MARKER in the same buffer it inhabits now.
If MARKER is omitted, and MARKER is in no buffer, put it in the current
buffer."
    (if (null buffer)
	(setq buffer (extent-object marker)))
    (if (null buffer)
	(setq buffer (current-buffer)))
    (check-argument-type 'bufferp buffer)
    (and (= beg end)
	 (extent-property marker 'evaporate)
	 (delete-extent marker))
    (when (> beg end)
      (setq beg (prog1 end (setq end beg))))
    (set-extent-endpoints marker beg end buffer)
    marker))

(defun matlab-eei-set-debug-cursor-position ()
  (cond 
   ((string= (car matlab-eei-debug-cursor-type) "arrow")
    (setq overlay-arrow-string "=>")
    (or overlay-arrow-position
	(setq overlay-arrow-position (make-marker)))
    (set-marker overlay-arrow-position (point) (current-buffer)))
   (t
    (matlab-eei-move-marker
     matlab-eei-highlight-cursor 
     (line-beginning-position)
     (line-end-position) (current-buffer)))))

(defun matlab-eei-hide-debug-cursor () 
  (cond 
   ((string= (car matlab-eei-debug-cursor-type) "arrow")
    (setq overlay-arrow-position nil))
   (t
    (if (featurep 'xemacs)
	(delete-extent matlab-eei-highlight-cursor)
      (delete-overlay matlab-eei-highlight-cursor)))))



(defun matlab-eei-move-debug-cursor (file line)
  "Moves the debug cursor to LINE in FILE."
  (let* ((buffer (matlab-eei-find-file file))
	 (window 
	  (and buffer
	       (or (get-buffer-window buffer)
		   (selected-window))))
	  pos) 
    (if buffer
	(progn
	  (if (not (get-buffer-window buffer))
	      (set-window-buffer window buffer))
	  (save-excursion
	    (set-buffer buffer)
	    (save-restriction
	      (widen)
	      (goto-line line)
	      (setq pos (point))
	      (matlab-eei-set-debug-cursor-position))
	    (cond ((or (< pos (point-min)) (> pos (point-max)))
		   (widen)
		   (goto-char pos))))
	  (set-window-point window pos)))))	 

(defun matlab-eei-event-stop (file line)
  "Handles a stop event from MATLAB. This function moves the
debug cursor to LINE number in FILE. It then raises the Emacs
window to the top of the user's desktop."
  ;; (message "stop event at %d in %s" line file)
  (if (not (buffer-modified-p))
      (progn
	(raise-frame)
	(setq matlab-eei-matlab-in-debug-mode-p t)
	;;(setq matlab-eei-matlab-stopped-p t)
	(setq matlab-eei-last-event "stop")
	;; If the user issues a step command and the current line is
	;; the last line in a function, MATLAB issues an open-document-to-line
	;; command with the line number equal to the negative of the last line
	;; in the M-file and then issues a stop event with the same negative
	;; line number. In this case, we issue another step command to
	;; move back to the line that invoked the function.
	(if (< line 0)
	    (matlab-eei-step)
	  (matlab-eei-move-debug-cursor file line)))))


;; +-----------------------------------------+
;; | Step Commands                           |
;; +-----------------------------------------+

(defun matlab-eei-step () 
  "Ask MATLAB to advance to the next program line that is
not a function call. This command signals an error if
MATLAB is not stopped or the buffer
is modified."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (if matlab-eei-matlab-in-debug-mode-p
       (if (not (buffer-modified-p))
	   (progn
	     (matlab-eei-send-mcmd "step")
	     ;; (setq matlab-eei-matlab-stopped-p nil)
	     )
	 (error "Cannot step in a modified buffer."))
     (error "MATLAB is not stopped."))))
	

(defun matlab-eei-step-in ()
  "Ask MATLAB to advance to the next program line."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (if matlab-eei-matlab-in-debug-mode-p
       (if (not (buffer-modified-p))
	   (progn
	     (matlab-eei-send-mcmd "step_in")
	     ;; (setq matlab-eei-matlab-stopped-p nil)
	     )
	 (error "Cannot step in a modified buffer."))
     (error "MATLAB is not stopped."))))


(defun matlab-eei-step-out ()
  "Ask MATLAB to advance to the next program line."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (if matlab-eei-matlab-in-debug-mode-p
       (if (not (buffer-modified-p))
	   (progn
	     (matlab-eei-send-mcmd "step_out")
	     ;; (setq matlab-eei-matlab-stopped-p nil)
	     )
	 (error "Cannot step in a modified buffer."))
     (error "MATLAB is not stopped."))))


(defvar matlab-eei-go-until-cursor-mode-p nil
  "Nonnil if Emacs is in go-until-cursor-mode")

(defun matlab-eei-go-until-cursor () 
  "Ask MATLAB to advance the program to the current line in the buffer."
  (interactive)
  (if matlab-eei-matlab-in-debug-mode-p
      (matlab-run-in-matlab-mode-only
	  (if (not (buffer-modified-p))
	      (let ((file (if (eq system-type 'windows-nt) 
			      (downcase (buffer-file-name))
			    (buffer-file-name))) 
		    (line (matlab-eei-get-line-at-point)))
		(if (matlab-eei-breakpoint-exists-p file line)
		    (matlab-eei-continue)
		  (progn
		    (setq matlab-eei-go-until-cursor-mode-p t)
		    (matlab-eei-request-set-breakpoint file line)
		    (if (string= (matlab-eei-wait-for-event) "set-breakpoint")
			(progn
			  (matlab-eei-continue)
			  (matlab-eei-wait-for-event)
			  (matlab-eei-request-clear-breakpoint file line)
			  (setq matlab-eei-go-until-cursor-mode-p nil))
		      (setq matlab-eei-go-until-cursor-mode-p nil)
		      (error "Could not set temporary breakpoint.")))))
	    (error "Cannot go until cursor in a modified buffer.")))
    (error "MATLAB is not stopped.")))


(defvar matlab-eei-run-parameter-history '("()")
  "Keep track of parameters passed to MATLAB when running
M-files.")

(defun matlab-eei-run ()
  "Run the M-file in the current buffer."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (let ((fn-name (file-name-sans-extension
		   (file-name-nondirectory (buffer-file-name))))
	 (param ""))
     (if (and (buffer-modified-p)
	      (yes-or-no-p "Save changes in buffer first?"))
	 (save-buffer))
     ;; Do we need parameters?
     (if (save-excursion
	   (goto-char (point-min))
	   (end-of-line)
	   (forward-sexp -1)
	   (looking-at "([a-zA-Z ]"))
	 (setq param (read-string "Parameters: "
				  (car matlab-eei-run-parameter-history)
				  'matlab-eei-run-parameter-history)))
     (if (string= param "()")
	 (setq param ""))
     (matlab-eei-send-mcmd (format "run %s %s" fn-name param)))))	 

(defun matlab-eei-continue ()
  "Ask MATLAB to continue execution of a stopped program. This command
signals an error if MATLAB is not stopped or the buffer is modified."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (if matlab-eei-matlab-in-debug-mode-p
       (if (not (buffer-modified-p))
	   (matlab-eei-send-mcmd "continue" t)
	 (error "Cannot step in a modified buffer."))
     (error "MATLAB is not stopped."))))

(defun matlab-eei-run-continue ()
  (interactive)
  (if matlab-eei-matlab-in-debug-mode-p
      (matlab-eei-continue)
    (matlab-eei-run)))

(defun matlab-eei-event-continue () 
  "Handle a continue program execution event from MATLAB."
  (matlab-eei-hide-debug-cursor)
  ;; (setq matlab-eei-matlab-stopped-p nil)
  (setq matlab-eei-matlab-in-debug-mode-p nil))


(defun matlab-eei-exit-debug ()
  "Ask MATLAB to exit debug mode."
  (interactive)
  (when matlab-eei-matlab-in-debug-mode-p
    (matlab-eei-send-mcmd "exit_debug")))

(defun matlab-eei-event-exit-debug ()
  "Handles an exit debug event from MATLAB."
  (matlab-eei-hide-debug-cursor)
  ;; (setq matlab-eei-matlab-stopped-p nil)
  (setq matlab-eei-matlab-in-debug-mode-p nil))

(defun matlab-eei-eval-region (beg end)
  "Run region from BEG to END and display result in MATLAB command
window. "
  (interactive "r")
  (if (> beg end) (let (mid) (setq mid beg beg end end mid)))
  (let ((command 
	 (let ((str 
		(concat 
		 (buffer-substring-no-properties beg end)
		 "\n")))
	   (while (string-match "\n\\s-*\n" str)
	     (setq str (concat 
			(substring str 0 (match-beginning 0))
			"\n"
			(substring str (match-end 0)))))
	   str)))	 
    (matlab-eei-eval-m-expr command)))
 
;; +-----------------------------------------+
;; | Stack Navigation                        |
;; +-----------------------------------------+

(defvar matlab-eei-stack "<Base>"
  "List of M function names representing the current stack. The first
item in the list is the top of the stack, i.e., the function in which
MATLAB is currently stopped. The bottom of the list is MATLAB itself
represented by the notation <BASE>.")

(defvar matlab-eei-stack-pointer 0 
  "Zero-based index representing the location
of the stack pointer in `matlab-eei-stack'.
The stack pointer points to the top of the stack after
a stop event. A user can move the pointer to other
locations, using the Stack Navigator buffer.")

(defun matlab-eei-bump-stack (frame)
  "Go to FRAME on stack. FRAME is the position
of the frame relative to the top of the 
stack."
  (matlab-eei-send-mcmd 
   (format "bump_stack %d" (- frame matlab-eei-stack-pointer))))

(defconst matlab-eei-stack-navigator-name "MATLAB Stack Navigator")

(defvar matlab-eei-widgets nil
  "List of widgets in stack navigator buffer. This is
a buffer-local variable.")
(make-variable-buffer-local 'matlab-eei-widgets)

(defun matlab-eei-refresh-stack-navigator (buffer)
 (save-excursion
   (set-buffer buffer)
   (let ((inhibit-read-only t))

     ;; Clear buffer

     (loop for widget in matlab-eei-widgets do
       (widget-delete widget))

     (if (featurep 'xemacs)
	 (let ((extents (extent-list)))
	   (loop for extent in extents do
	     (delete-extent extent)))
       (let ((overlays (overlays-in (point-min) (point-max))))
	 (loop for overlay in overlays do
	   (delete-overlay overlay))))

     (setq widget-field-new nil)
     (setq widget-field-list nil)
     (erase-buffer)
 
     (setq matlab-eei-widgets nil)

     (widget-insert "MATLAB Stack\n\n")
     (let ((i 0)
	   button)
       (loop for frame in matlab-eei-stack do
	 (progn
	   (widget-insert
	    (format 
	     " %s"
	     (if (= i matlab-eei-stack-pointer) ">" " ")))
	   (setq button
		 (widget-create 
		  'push-button 
		    :notify 
		    (lambda (button &rest ignore) 
		      (matlab-eei-bump-stack
		       (widget-get button :stack-pos)))
		    frame))
	   (widget-put button :stack-pos i)
	   (widget-insert "\n")
	   (setq matlab-eei-widgets
		 (cons button matlab-eei-widgets))
	   (setq i (1+ i)))))
     (use-local-map widget-keymap)
     (widget-setup))))

(defun matlab-eei-display-stack-navigator ()
  (interactive)
  (let ((nav-buf (get-buffer matlab-eei-stack-navigator-name)))
    (if (not nav-buf)
	(progn
	  (setq nav-buf (get-buffer-create matlab-eei-stack-navigator-name))
	  (matlab-eei-refresh-stack-navigator nav-buf)))
    (pop-to-buffer nav-buf)))

(defun matlab-eei-event-stack-update (stack pointer)
  "Function invoked by MATLAB when a workspace event occurs. STACK is
a list of M function names representing the current stack.  POINTER is 
a zero-based integer index representing the stack pointer."
  (setq matlab-eei-stack stack)
  (setq matlab-eei-stack-pointer pointer)
  (let ((nav-buf (get-buffer matlab-eei-stack-navigator-name)))
    (if nav-buf
	(matlab-eei-refresh-stack-navigator nav-buf))))




;; +-----------------------------------------+
;; | Variable Display                        |
;; +-----------------------------------------+

(defvar matlab-eei-last-variable nil)

(defun matlab-eei-display-variable ()
  "Display the value of the variable at point."
  (interactive)
  (matlab-run-in-matlab-mode-only
   (let ((variable (thing-at-point 'symbol)))
     (if variable
	 (matlab-eei-send-mcmd 
	  (concat "display_variable " variable))))))

(defun matlab-eei-event-variable-value (value)
  "Handles response to a get variable value
command."
  (setq matlab-eei-last-variable value)
  (setq matlab-eei-last-event "variable-value"))


(defun matlab-eei-event-variable-value1 (value)
  "Handles response to a get variable value
command. This function displays the first line
of the value in the minibuffer. If the value
has more than one line, it appends ... to the
end of the first line to indicate that the
display is truncated."
  (let ((line1 
	 (substring 
	  value
	  0
	  (string-match "\n" value))))    
    (if (< (length line1) (1- (length value)))
	(setq line1 (concat line1 " ...")))
    (message line1)))

;; +-----------------------------------------+
;; | Close All M-File Buffers                |
;; +-----------------------------------------+

(defun matlab-eei-close-all ()
  "Close all M-file buffers."
  (interactive)
  (loop for buf in (buffer-list) do
	(save-excursion
	  (set-buffer buf)
	  (if (eq major-mode 'matlab-mode)
	      (kill-buffer buf)))))

;; +-----------------------------------------+
;; | EEI Menu                                |
;; +-----------------------------------------+

(defun matlab-eei-menu-item (item)
  "Build an XEmacs compatible menu item from vector ITEM.
That is remove the unsupported :help stuff."
  (if (featurep 'xemacs)
      (let ((n (length item))
            (i 0)
            slot l)
        (while (< i n)
          (setq slot (aref item i))
          (if (and (keywordp slot)
                   (eq slot :help))
              (setq i (1+ i))
            (setq l (cons slot l)))
          (setq i (1+ i)))
        (apply 'vector (nreverse l)))
    item))

(defvar matlab-eei-menu-spec
  (list 
   "Mdb"

   (matlab-eei-menu-item
    ["Step"                       
     matlab-eei-step 
     :active (and 
	      matlab-eei-matlab-in-debug-mode-p
	      (not (buffer-modified-p)))
     :help "Step over the next line"])

  
   (matlab-eei-menu-item
    ["Step In"                    
     matlab-eei-step-in 
     :active (and 
	      matlab-eei-matlab-in-debug-mode-p
	      (not (buffer-modified-p)))
     :help "Step into the next line."])

   (matlab-eei-menu-item
    ["Step Out"                  
     matlab-eei-step-out 
     :active (and 
	      matlab-eei-matlab-in-debug-mode-p
	      (not (buffer-modified-p)))
     :help "Step out of the current function."])

   "-"

   (matlab-eei-menu-item
    ["Run"                       
     matlab-eei-run-continue 
     :included (not matlab-eei-matlab-in-debug-mode-p)
     :active (and (not (buffer-modified-p))
		  (buffer-file-name))
     :help "Run this M-file."])
          
   (matlab-eei-menu-item
    ["Continue"                   
     matlab-eei-run-continue 
     :included (and 
		matlab-eei-matlab-in-debug-mode-p
		(not (buffer-modified-p)))
     :help "Continue from the current breakpoint."])

	
   (matlab-eei-menu-item
    ["Go Until Cursor"           
     matlab-eei-go-until-cursor
     :active (and 
	      matlab-eei-matlab-in-debug-mode-p
	      (not (buffer-modified-p)))
     :help "Continue execution to the current line."])

   (matlab-eei-menu-item
    ["Exit Debug Mode"            
     matlab-eei-exit-debug 
     :active matlab-eei-matlab-in-debug-mode-p
     :help "Exit debug mode"])

   "-"

   (matlab-eei-menu-item
    ["Set/Clear Breakpoint"      
     matlab-eei-breakpoint-set-clear 
     :active (buffer-file-name)
     :help "Set or clear breakpoint at the current line."])

   (matlab-eei-menu-item
    ["Clear All Breakpoints"      
     matlab-eei-clear-breakpoints 
     :active matlab-eei-breakpoints-alist
     :help "Clear all breakpoints."])

   "-"

   (matlab-eei-menu-item
    ["Stop If Error"              
     matlab-eei-toggle-stop-if-error 
     :active t 
     :style radio 
     :selected (matlab-eei-get-stop-if-state "error")
     :help "Stop if an uncaught error occurs."])

   (matlab-eei-menu-item
    ["Stop If Caught Error"          
     matlab-eei-toggle-stop-if-caught-error 
     :active t 
     :style radio 
     :selected (matlab-eei-get-stop-if-state "caught_error")
     :help "Stop if a caught error occurs."])

   (matlab-eei-menu-item
    ["Stop If Warning"            
     matlab-eei-toggle-stop-if-warning 
     :active t
     :style radio 
     :selected (matlab-eei-get-stop-if-state "warning")
     :help "Stop if a warning occurs."])

   
   (matlab-eei-menu-item
    ["Stop If Nan/Inf"            
     matlab-eei-toggle-stop-if-nan-inf 
     :active t
     :style radio 
     :selected (matlab-eei-get-stop-if-state "nan_inf")
     :help "Stop if an underflow or overflow occurs."])

   "-"

   (matlab-eei-menu-item
    ["Show Stack Navigator"       
     matlab-eei-display-stack-navigator 
     :active (buffer-file-name)
     :help "Display the stack navigator."])

   (matlab-eei-menu-item
    ["Evaluate Region"            
     matlab-eei-eval-region 
     :active (buffer-file-name)
     :help "Evaluate the selected lines of code"])


					; 	"-"

	  ; 	["Display Variable"           matlab-eei-display-variable
; 	                              :enable  matlab-eei-matlab-stopped-p]

   )
  "MATLAB debug menu specification.")

(defvar matlab-eei-mode-map
  (let ((km (make-sparse-keymap)))
    (easy-menu-define matlab-eei-menu km "MATLAB EEI Minor Mode Menu"
      matlab-eei-menu-spec)
    km)
  "MATLAB EEI keymap")


(defvar matlab-eei-minor-mode nil
  "If non-nil, show MATLAB EEI menu.")
(make-variable-buffer-local 'matlab-eei-minor-mode)

(defun matlab-eei-minor-mode (&optional arg)
  "Toggle MATLAB EEI minor mode.
With prefix argument ARG, turn on if positive, otherwise off..

\\{matlab-eei-mode-map}"
  (interactive
   (list (or current-prefix-arg
             (if matlab-eei-minor-mode 0 1))))

  (setq matlab-eei-minor-mode
        (if arg
            (>
             (prefix-numeric-value arg)
             0)
          (not matlab-eei-minor-mode)))

  (if matlab-eei-minor-mode
      (if (featurep 'xemacs)
            (easy-menu-add matlab-eei-menu-spec matlab-eei-mode-map))
    (if (featurep 'xemacs)
      (easy-menu-remove matlab-eei-menu-spec))))

(if (fboundp 'add-minor-mode)

    ;; Emacs 21 & XEmacs
    (defalias 'matlab-eei-add-minor-mode 'add-minor-mode)

  ;; Emacs 20
  (defun matlab-eei-add-minor-mode (toggle name &optional keymap)
    "Register a new Semantic minor mode.
TOGGLE is a symbol which is the name of a buffer-local variable that
is toggled on or off to say whether the minor mode is active or not.
It is also an interactive function to toggle the mode.

NAME specifies what will appear in the mode line when the minor mode
is active.  NAME should be either a string starting with a space, or a
symbol whose value is such a string.

Optional KEYMAP is the keymap for the minor mode that will be added
to `minor-mode-map-alist'."
  (or (assq toggle minor-mode-alist)
      (setq minor-mode-alist (cons (list toggle name)
                                   minor-mode-alist)))
    
  (or (not keymap)
      (assq toggle minor-mode-map-alist)
      (setq minor-mode-map-alist (cons (cons toggle keymap)
                                       minor-mode-map-alist))))
    
  )


(matlab-eei-add-minor-mode 'matlab-eei-minor-mode " EEI" matlab-eei-mode-map)


(defcustom matlab-eei-key-bindings
  (list (cons "[?\C-c ?\C-d ?\C-s]" 'matlab-eei-step)
	(cons "[?\C-c ?\C-d ?\C-i]" 'matlab-eei-step-in)
	(cons "[?\C-c ?\C-d ?\C-o]" 'matlab-eei-step-out)
	(cons "[?\C-c ?\C-d ?\C-r]" 'matlab-eei-run-continue)
	(cons "[?\C-c ?\C-d ?\C-b]" 'matlab-eei-breakpoint-set-clear)
	(cons "[?\C-c ?\C-d ?\C-e]" 'matlab-eei-eval-region))
  "*Specifies key bindings for MATLAB debug key bindings.
The value of this variable is an association list. The car of
each element specifies a key sequence. The cdr specifies 
an interactive command that the key sequence executes. To enter
a key with a modifier, type C-q followed by the desired modified	
keystroke. For example, to enter C-s (Control s) as the key to be
bound, type C-q C-s in the key field in the customization buffer.
You can use the notation [f1], [f2], etc., to specify function keys."
  :group 'matlab
  :type '(repeat
	  (cons :tag "Key binding"
	   (string :tag "Key")
	   (function :tag "Command")))
  :set '(lambda (sym val)
	  ;; Unmap existing key bindings
	  (if (and
	       (boundp 'matlab-eei-key-bindings)
	       matlab-eei-key-bindings)
	      (mapc 
	       (lambda (binding)
		 (let ((key (car binding))
		       (fcn (cdr binding)))
		   (if (string-match "\\[.+]"key)
		       (setq key (car (read-from-string key))))
		   (define-key matlab-eei-mode-map key nil)))
	       matlab-eei-key-bindings))
	  ;; Map new key bindings.
	  (mapc 
	   (lambda (binding)
	     (let ((key (car binding))
		   (fcn (cdr binding)))
	       (if (string-match "\\[.+]"key)
		   (setq key (car (read-from-string key))))
	       (define-key matlab-eei-mode-map key fcn)))
	   val)
	  (set-default sym val)))

(defun matlab-eei-emacs-exit-hook ()
  (matlab-eei-mcmd-quit))

(add-hook 'kill-emacs-hook 'matlab-eei-emacs-exit-hook)

(provide 'matlab-eei)

;; $Log: matlab-eei.el,v $
;; Revision 1.2.4.2  2004/04/25 21:31:13  batserve
;; 2004/04/12  1.2.4.1.2.1  gweekly
;;   Updated copyright
;; Accepted job 19572 in A
;;
;; Revision 1.2.4.1.2.1  2004/04/12 23:27:51  gweekly
;; Updated copyright
;;
;; Revision 1.2.4.1  2004/02/01 21:21:17  batserve
;; 2004/01/20  1.2.8.1  batserve
;;   2004/01/19  1.2.12.1  paulk
;;     Related Records: 184840
;;     Code Reviewer: audreyb
;;     Change menu to reflect new stop if conditions
;;   Accepted job 7613 in Ami
;; Accepted job 13335 in A
;;
;; Revision 1.2.8.1  2004/01/20 04:43:57  batserve
;; 2004/01/19  1.2.12.1  paulk
;;   Related Records: 184840
;;   Code Reviewer: audreyb
;;   Change menu to reflect new stop if conditions
;; Accepted job 7613 in Ami
;;
;; Revision 1.2.12.1  2004/01/19 20:17:57  paulk
;; Related Records: 184840
;; Code Reviewer: audreyb
;; Change menu to reflect new stop if conditions
;;
;; Revision 1.2  2002/03/30 14:51:01  batserve
;; Add a function (matlab-eei-close-all) to close all M-file documents.
;; Related Records: 124527
;; Code Reviewer: audreyb
;;
;; Revision 1.2  2002/03/20 18:35:19  paulk
;; Add a function (matlab-eei-close-all) to close all M-file documents.
;; Related Records: 124527
;; Code Reviewer: audreyb
;;
;; Revision 1.1  2002/02/06 20:43:49  paulk
;; Initial revision
;;
;; Revision 1.6  2001/10/18 17:21:27  paulk
;; Fixed a bunch of bugs related to setting and clearing breakpoints.
;; Related Records: 108087 110285 110287 110295 110685
;; Code Reviewer: audreyb
;;
;; Revision 1.5  2001/09/07 16:44:38  paulk
;; Changed "Mathworks" to "MathWorks" and "Matlab" to "MATLAB"?
;; Related Records: 107855
;;
;; Revision 1.4  2001/09/06 16:41:38  paulk
;; Move matlab-run-in-matlab-mode-only macro to matlab.el
;; Related Records: 99176
;; Code Reviewer: eludlam
;;
;; Revision 1.3  2001/09/05 16:03:21  paulk
;; Added a require statement for wid-edit.
;; Related Records: 99242
;; Code Reviewer: ktucker
;;
;; Revision 1.2  2001/08/31 20:45:52  paulk
;; Updated to support stack navigation, region evaluation, and running commands
;; with parameters
;; Related Records: 99242 107308 107338 107395
;; Code Reviewer: audreyb
;;

;; end of matlab-eei







