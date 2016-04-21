;;; mlint.el --- run mlint in a MATLAB buffer

;; Author: Eric M. Ludlam <eludlam@mathworks.com>
;; Maintainer: Eric M. Ludlam <eludlam@mathworks.com>
;; Created: June 25, 2002
;;
;; Copyright (C) 2002 Eric M. Ludlam
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

;;; Commentary:
;; 
;; Run mlint, and highlight the problems in the buffer.
;;
;; This requires Mlint written by Steve Johnson
;; This requires from matlab.el
;; This requires eieio version 0.17 or later.
;;

;;; Install
;;
;; (autoload 'mlint-minor-mode "mlint" nil t)
;; (add-hook 'matlab-mode-hook (lambda () (mlint-minor-mode 1)))

(require 'matlab)
(require 'linemark)

;;; Code:
(defvar mlint-programs '("mlint")
  "List of possible locations of the mlint program.")

(defvar mlint-program
  (let ((mlp mlint-programs)
	(ans nil))
    (while (and mlp (not ans))
      (when (file-executable-p (car mlp))
	(setq ans (car mlp)))
      (setq mlp (cdr mlp)))
    ans)
  "Program to run for MLint.")

(defvar mlint-flags '("-all" "-tmw" "-id")
  "*List of flags passed to mlint.")

(defvar mlint-output-regex
  "^L \\([0-9]+\\) (C \\([-0-9]+\\)) \\(\\w+\\):\\(\\w+\\) : \\([^\n]+\\)"
  "Regular expression for collecting mlink output.")

(defvar mlint-verbose nil
  "Non nil if `mlint-minor-mode' should display messages while running.")

(defvar mlint-warningcode-alist
  '(
    ( "CodingStyle" . minor )
    ( "MathWorksErr" . minor )
    ( "InefficientUsage" . medium )
    ( "SuspectUsage" . medium )
    ( "DeprecatedUsage" . medium )
    ( "OldUsage" . medium )
    ( "SyntaxErr" . major )
    ( "InternalErr" . major )
    )
  "Associate a warning code to a warning level.")


(defvar mlint-scan-for-fixes-flag t
  "Non-nil means that we should scan mlint output for things to fix.
Scanning using `mlint-error-fix-alist' can slow things down, and may
be cause for being turned off in a buffer.")
(make-variable-buffer-local 'mlint-scan-for-fixes-flag)

(defvar mlint-error-fix-alist
  '(
    ( "Use \\(&&\\|||\\) instead of \\(&\\||\\) as the" . mlint-lm-entry-logicals)
    ( "is an input value that is never used" . mlint-lm-entry-unused-argument )
    ( "ISSTR is deprecated" . mlint-lm-entry-isstr )
    ( "SETSTR is deprecated" . mlint-lm-entry-setstr )
    ( "Terminate line with semicolon" . mlint-lm-quiet )
    ( "Extra semicolon is unnecessary" . mlint-lm-delete-focus )
    ( "Use TRY/CATCH instead of EVAL with 2 arguments" . mlint-lm-eval->trycatch )
    ( "STR2DOUBLE is faster and often more appropriate than STR2NUM" . mlint-lm-str2num )
    )
  "List of regular expressions and auto-fix functions.
If the CAR of an association matches an error message then the linemark entry
created is of the class in CDR.")

(defun mlint-column-output (string)
  "Convert the mlint column output to a cons pair.
\(COLSTART .  COLEND).
Argument STRING is the text to interpret."
  (save-match-data
    (if (string-match "\\([0-9]+\\)-\\([0-9]+\\)" string)
	(cons (string-to-int (match-string 1 string))
	      (string-to-int (match-string 2 string)))
      (let ((i (string-to-int string)))
	(cons i i)))))

(defun mlint-run (&optional buffer)
  "Run Mlint on BUFFER and return a list of issues.
If BUFFER is nil, use the current buffer."
  (when (file-exists-p (buffer-file-name))
    (let ((fn (buffer-file-name (current-buffer)))
	  (dd default-directory)
	  (errors nil))
      (save-excursion
	(set-buffer (get-buffer-create "*Mlint*"))
	(erase-buffer)
	(when mlint-verbose (message "Running mlint..."))

	(apply 'call-process mlint-program nil (current-buffer) nil
	       (append mlint-flags (list fn)))

	(when mlint-verbose (message "Running mlint...done"))
	(goto-char (point-min))
	(while (re-search-forward mlint-output-regex nil t)
	  (setq errors (cons
			(list (string-to-int (match-string 1))
			      (mlint-column-output (match-string 2))
			      (match-string 5)
			      (match-string 3)
			      (match-string 4)
			      )
			errors))))
      errors
      )))

(defclass mlint-lm-group (linemark-group)
  ()
  "Group of linemarks for mlint.")

(defclass mlint-lm-entry (linemark-entry)
  ((column :initarg :column
	   :type integer
	   :documentation
	   "The column on which the warning occurs.")
   (column-end :initarg :column-end
	       :type integer
	       :documentation
	       "The column on which the warning ends.")
   (coverlay :type overlay
	     :documantation
	     "Overlay used for the specific part of the line at issue.")
   (warning :initarg :warning
	   :type string
	   :documentation
	   "The error message created by mlint on this line.")
   (warningcode :initarg :warningcode
		:type symbol
		:documentation
		"Mlint return code for this type of warning.")
   (warningid :initarg :warningid
		:type symbol
		:documentation
		"Mlint id for this specific warning.")
   (fixable-p :initform nil
	      :allocation :class
	      :type boolean
	      :documentation
	      "Can this class auto-fix the problem?")
   (fix-description :initform nil
		    :allocation :class
		    :type (or string null)
		    :documentation
		    "Description of how the fix will effect the buffer.")
   )
  "A linemark entry.")

(defun mlint-linemark-create-group ()
  "Create a group object for tracking linemark entries.
Do not permit multiple groups with the same name."
  (let* ((name "mlint")
	 (newgroup (mlint-lm-group name :face 'linemark-go-face))
	 (foundgroup nil)
	 (lmg linemark-groups))
    (while (and (not foundgroup) lmg)
      (if (string= name (object-name-string (car lmg)))
	  (setq foundgroup (car lmg)))
      (setq lmg (cdr lmg)))
    (if foundgroup
	(setq newgroup foundgroup)
      (setq linemark-groups (cons newgroup linemark-groups))
      newgroup)))

(defvar mlint-mark-group (mlint-linemark-create-group)
  "Group of marked lines for mlint.")

(defun mlint-warning->class (warning)
  "For a given WARNING, return a class for that warning.
Different warnings are handled by different classes."
  (if mlint-scan-for-fixes-flag
      (let ((al mlint-error-fix-alist))
	(while (and al (not (string-match (car (car al)) warning)))
	  (setq al (cdr al)))
	(or (cdr (car al)) 'mlint-lm-entry))
    'mlint-lm-entry))

(defmethod linemark-new-entry ((g mlint-lm-group) &rest args)
  "Add a `linemark-entry' to G.
It will be at location FILE and LINE, and use optional FACE.
Call the new entrie's activate method."
  (let* ((f (plist-get args :filename))
	 (l (plist-get args :line))
	 (wc (plist-get args :warningcode))
	 (c (mlint-warning->class (plist-get args :warning)))
	)
    (when (stringp f) (setq f (file-name-nondirectory f)))
    (apply c (format "%s %d" f l) args)
    ))

(defun mlint-end-of-something ()
  "Move cursor to the end of whatever the cursor is on."
  (cond ((looking-at "\\w\\|\\s(")
	 (forward-sexp 1))
	((looking-at "\\s.")
	 (skip-syntax-forward "."))
	(t (error nil))))

(defmethod linemark-display ((e mlint-lm-entry) active-p)
  "Set object E to be active."
  ;; A bug in linemark prevents individual entry colors.
  ;; Fix the color here.
  (let ((wc (oref e warningcode)))
    (oset e :face
	  (cond ((eq wc 'major) 'linemark-stop-face)
		((eq wc 'medium) 'linemark-caution-face)
		(t 'linemark-go-face))))
  ;; Call our parent method
  (call-next-method)
  ;; Add highlight area
  (if active-p
      (when (and (not (slot-boundp e 'coverlay))
		 (slot-boundp e 'overlay)
		 (oref e overlay))
	(with-slots (overlay column column-end warning) e
	  (let ((warntxt
		 (if (mlint-is-fixable e)
		     (concat warning "\nC-c , f to "
			     (oref e fix-description))
		   warning)))
	    ;; We called super first, so this should be an active overlay.
	    (linemark-overlay-put overlay 'local-map mlint-overlay-map)
	    (linemark-overlay-put overlay 'help-echo warntxt)
	    ;; Now, if we have some column data, lets put more highlighting on.
	    (save-excursion
	      (set-buffer (linemark-overlay-buffer overlay))
	      (goto-char (linemark-overlay-start overlay))
	      (forward-char (1- column))
	      ;(move-to-column (1- column))
	      (oset e coverlay (linemark-make-overlay
				(point)
				(progn
				  (beginning-of-line)
				  (forward-char column-end)
				  ;(move-to-column column-end)
				  (point))
				(current-buffer)))
	      (with-slots (coverlay) e
		(linemark-overlay-put coverlay 'face 'linemark-funny-face)
		(linemark-overlay-put coverlay 'obj e)
		(linemark-overlay-put coverlay 'tag 'mlint)
		(linemark-overlay-put coverlay 'help-echo warntxt)
		)
	      ))))
    ;; Delete our spare overlay
    (when (slot-boundp e 'coverlay)
      (with-slots (coverlay) e
	(when coverlay
	  (condition-case nil
	      (linemark-delete-overlay coverlay)
	    (error nil))
	  (slot-makeunbound e 'coverlay)))
      )))

(defmethod mlint-is-fixable ((e mlint-lm-entry))
  "Return non-nil if this entry can be automatically fixed."
  (oref-default e fixable-p))

(defmethod mlint-fix-entry :AFTER ((e mlint-lm-entry))
  "Stuff to do after a warning is considered fixed.
Subclasses fulfill the duty of actually fixing the code."
  (linemark-display e nil)
  (linemark-delete e))

(defmethod mlint-fix-entry ((e mlint-lm-entry))
  "This entry cannot fix warnings, so throw an error.
Subclasses fulfill the duty of actually fixing the code."
  (error "Don't know how to fix warning."))

;;; Specialized classes
;;

(defclass mlint-lm-delete-focus (mlint-lm-entry)
  ((fixable-p :initform t)
   (fix-description :initform "Delete the offending characters.")
   )
  "Specialized entry for deleting the higlighted entry.")

(defmethod mlint-fix-entry ((ent mlint-lm-delete-focus))
  "Add semi-colon to end of this line."
  (save-excursion
    (goto-line (oref ent line))
    (let* ((s (progn (move-to-column (1- (oref ent column))) (point)))
	   (e (progn (move-to-column (oref ent column-end)) (point)))
	   )
      (goto-char s)
      (delete-region (point) e)
      (point)
      ))
  )

(defclass mlint-lm-replace-focus (mlint-lm-delete-focus)
  ((fix-description :initform "Replace the offending symbol with ")
   (new-text :initform "" :allocation :class)
   )
  "Class which can replace the focus area."
  :abstract t)

(defmethod initialize-instance :AFTER ((this mlint-lm-replace-focus)
				       &rest fields)
  "Make sure THIS is in our master list of this class.
Optional argument FIELDS are the initialization arguments."
  ;; After basic initialization, update the fix description.
  (oset this fix-description (concat (oref mlint-lm-replace-focus fix-description)
				     (oref this new-text))))

(defmethod mlint-fix-entry ((ent mlint-lm-replace-focus))
  "Replace the focus area with :new-text"
  (let ((pos (call-next-method)))
    (save-excursion
      (goto-char (point))
      (insert (oref ent new-text)))))

(defclass mlint-lm-str2num (mlint-lm-replace-focus)
  ((new-text :initform "str2double"))
  "Replace str2num with str2double")

(defclass mlint-lm-entry-isstr (mlint-lm-replace-focus)
  ((new-text :initform "ischar"))
  "Replace isstr with ischar.")

(defclass mlint-lm-entry-setstr (mlint-lm-replace-focus)
  ((new-text :initform "char"))
  "Replace setstr with char.")

(defclass mlint-lm-entry-logicals (mlint-lm-entry)
  ((fixable-p :initform t)
   (fix-description :initform "perform a replacement.")
   )
  "Specialized logical and/or class.")

(defmethod mlint-fix-entry ((ent mlint-lm-entry-logicals))
  "Replace the single logical with double logical."
  (save-excursion
    (goto-line (oref ent line))
    (let* ((s (progn (move-to-column (1- (oref ent column))) (point)))
	   (e (progn (move-to-column (oref ent column-end)) (point)))
	   (txt (buffer-substring-no-properties s e)))
      (goto-char s)
      ;; All of these are replacing single logicals with double.
      (insert txt)))
  )

(defclass mlint-lm-entry-unused-argument (mlint-lm-entry)
  ((fixable-p :initform t)
   (fix-description :initform "remove this argument.")
   )
  "Specialized logical and/or class.")

(defmethod mlint-fix-entry ((ent mlint-lm-entry-unused-argument))
  "Remove the arguments."
  (save-excursion
    (goto-line (oref ent line))
    (let* ((s (progn (move-to-column (1- (oref ent column))) (point)))
	   (e (progn (move-to-column (oref ent column-end)) (point)))
	   )
      (goto-char s)
      (if (not (looking-at "(\\|,"))
	  (forward-char -1))
      (delete-region (point) e)
      ))
  )

(defclass mlint-lm-quiet (mlint-lm-entry)
  ((fixable-p :initform t)
   (fix-description :initform "Make sure this line prints no values.")
   )
  "Specialized logical and/or class.")


(defmethod mlint-fix-entry ((ent mlint-lm-quiet))
  "Add semi-colon to end of this line."
  (save-excursion
    (matlab-end-of-command)
    (insert ";"))
  )

(defclass mlint-lm-eval->trycatch (mlint-lm-entry)
  ((fixable-p :initform t)
   (fix-description :initform "Replace EVAL call with TRY/CATCH.")
   )
  "EVAL 2 arg form.  Transform into try/catch.")

(defun mlint-destringafy ()
  "Move forward over one string, removing string notations."
  (unless (looking-at "'")
    (error "Not looking at a string"))
  (forward-char -1)
  (let ((s (1+ (point)))
	(e (save-excursion
	     (matlab-font-lock-string-match-normal (point-at-eol))
	     (point))))
    (goto-char e)
    (delete-char -1)
    (save-excursion
      (goto-char s)
      (delete-char 1))
    (save-excursion
      (save-restriction
	(narrow-to-region s (point))
	(goto-char (point-min))
	(while (re-search-forward "''" nil t)
	  (replace-match "'"))))))

(defmethod mlint-fix-entry ((ent mlint-lm-eval->trycatch))
  "Add semi-colon to end of this line."
  (save-excursion
    (goto-line (oref ent line))
    (move-to-column (1- (oref ent column)))
    ;; (forward-word -1)
    (delete-region (point) (save-excursion (forward-word 1) (point)))
    (delete-horizontal-space)
    (delete-char 1)
    (insert "try")
    (matlab-indent-line)
    (matlab-return)
    (mlint-destringafy)
    (looking-at "\\s-*,\\s-*")
    (delete-region (match-beginning 0) (match-end 0))
    (matlab-return)
    (insert "catch")
    (matlab-return)
    (mlint-destringafy)
    (kill-line 1)
    (matlab-return)
    (insert "end ")
    (matlab-return)
    (forward-line -1)
    (end-of-line)
    (delete-horizontal-space)
    )
  )

;;; User functions
;;
(defun mlint-highlight (err)
  "Setup ERR, an mlint message to be marked."
  (linemark-add-entry mlint-mark-group
		      :line (nth 0 err)
		      :column (car (nth 1 err))
		      :column-end (cdr (nth 1 err))
		      :warning (nth 2 err)
		      :warningcode
		      (cdr (assoc (nth 3 err) mlint-warningcode-alist))
		      :warningid (intern (nth 4 err))
		      ))

(defun mlint-unhighlight-all ()
  "Unhighlight all existing mlint messages."
  (interactive)
  (mapcar (lambda (e)
	    (if (string= (oref e filename) (buffer-file-name))
		(linemark-delete e)))
	  (oref mlint-mark-group marks)))

(defun mlint-buffer ()
  "Run mlint on the current buffer, and highlight problems."
  (interactive)
  (when (buffer-file-name)
    (let ((errs (mlint-run))
	  )
      (mlint-unhighlight-all)
      (while errs
	(mlint-highlight (car errs))
	(setq errs (cdr errs))))))

(defun mlint-next-buffer ()
  "Move to the next warning in this buffer."
  (interactive)
  (let ((n (linemark-next-in-buffer mlint-mark-group 1 t)))
    (if n
	(progn (goto-line (oref n line))
	       (message (oref n warning)))
      (ding))))

(defun mlint-prev-buffer ()
  "Move to the prev warning in this buffer."
  (interactive)
  (let ((n (linemark-next-in-buffer mlint-mark-group -1 t)))
    (if n
	(progn (goto-line (oref n line))
	       (message (oref n warning)))
      (ding))))

(defun mlint-next-buffer-new ()
  "Move to the next new warning in this buffer."
  (interactive)
  (let ((p (linemark-at-point (point) mlint-mark-group))
	(n (linemark-next-in-buffer mlint-mark-group 1 t)))
    ;; Skip over messages that are the same as the one under point.
    (save-excursion
      (while (and n p (not (eq n p))
		  (string= (oref p warning) (oref n warning)))
	(goto-line (oref n line))
	(setq n (linemark-next-in-buffer mlint-mark-group 1 t))))
    (if n
	(progn (goto-line (oref n line))
	       (message (oref n warning)))
      (ding))))

(defun mlint-prev-buffer-new ()
  "Move to the prev new warning in this buffer."
  (interactive)
  (let ((p (linemark-at-point (point) mlint-mark-group))
	(n (linemark-next-in-buffer mlint-mark-group -1 t)))
    ;; Skip over messages that are the same as the one under point.
    (save-excursion
      (while (and n p (not (eq n p))
		  (string= (oref p warning) (oref n warning)))
	(goto-line (oref n line))
	(setq n (linemark-next-in-buffer mlint-mark-group -1 t))))
    (if n
	(progn (goto-line (oref n line))
	       (message (oref n warning)))
      (ding))))

(defun mlint-show-warning ()
  "Show the warning for the current mark."
  (interactive)
  (let ((n (linemark-at-point (point) mlint-mark-group)))
    (if (not n)
	(message "No warning at point.")
      (message (oref n warning)))))

(defun mlint-fix-warning ()
  "Show the warning for the current mark."
  (interactive)
  (let ((n (linemark-at-point (point) mlint-mark-group)))
    (if (not n)
	(message "No warning at point.")
      (if (not (mlint-is-fixable n))
	  (message "No method for fixing this warning.")
	(mlint-fix-entry n)))))

(defun mlint-mark-ok ()
  "Mark this line as MLint Ok."
  (interactive)
  (let ((n (linemark-at-point (point) mlint-mark-group)))
    (if (not n)
	(message "No warning at point.")
      (end-of-line)
      (insert " %#ok")))
  )


;;; Define an mlinting minor mode
;;
(defvar mlint-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "\C-c,n" 'mlint-next-buffer)
    (define-key map "\C-c,p" 'mlint-prev-buffer)
    (define-key map "\C-c,N" 'mlint-next-buffer-new)
    (define-key map "\C-c,P" 'mlint-prev-buffer-new)
    (define-key map "\C-c,g" 'mlint-buffer)
    (define-key map "\C-c,c" 'mlint-unhighlight-all)
    (define-key map "\C-c, " 'mlint-show-warning)
    (define-key map "\C-c,f" 'mlint-fix-warning)
    (define-key map "\C-c,o" 'mlint-mark-ok)
    map)
  "Minor mode keymap used when mlinting a buffer.")

(easy-menu-define
  mlint-minor-menu mlint-minor-mode-map "Mlint Minor Mode Menu"
 '("Mlint"
   ["Get MLint Warnings" mlint-buffer t]
   ["Clear MLint Warnings" mlint-unhighlight-all t]
   ["Show Warning" mlint-show-warning (linemark-at-point (point) mlint-mark-group)]
   ["Auto Fix Warning" mlint-fix-warning 
    (let ((w (linemark-at-point (point) mlint-mark-group)))
      (and mlint-scan-for-fixes-flag w (mlint-is-fixable w))) ]
   ["Enable Auto-fix scanning"
     (setq mlint-scan-for-fixes-flag (not mlint-scan-for-fixes-flag))
     :style toggle :selected mlint-scan-for-fixes-flag ]
   ["This is Ok" mlint-mark-ok
     (linemark-at-point (point) mlint-mark-group) ]
   "--"
   ["Next Warning" mlint-next-buffer t]
   ["Previous Warning" mlint-prev-buffer t]
   ["Next New Warning" mlint-next-buffer-new t]
   ["Previous New Warning" mlint-prev-buffer-new t]
   ))

(defvar mlint-overlay-map
  (let ((map (make-sparse-keymap )))
    (define-key map [down-mouse-3] 'mlint-emacs-popup-kludge)
    (define-key map [(meta n)] 'mlint-next-buffer)
    (define-key map [(meta p)] 'mlint-prev-buffer)
    (define-key map [(control meta n)] 'mlint-next-buffer-new)
    (define-key map [(control meta p)] 'mlint-prev-buffer-new)
    (set-keymap-parent map matlab-mode-map)
    map)
  "Map used in overlays marking mlint warnings.")

(defun mlint-emacs-popup-kludge (e)
  "Pop up a menu related to the clicked on item.
Must be bound to event E."
  (interactive "e")
  (let ((repos nil)
	(ipos nil)
	(startpos (point))
	)
    (save-excursion
      (mouse-set-point e)
      (setq ipos (point))
      (popup-menu mlint-minor-menu)
      (if (/= (point) ipos) (setq repos (point)))
      )
    (when repos (goto-char repos))))

(easy-mmode-define-minor-mode mlint-minor-mode
  "Toggle mlint minor mode, a mode for showing mlint errors.
With prefix ARG, turn mlint minor mode on iff ARG is positive.
\\{mlint-minor-mode-map\\}"
  nil " lint" mlint-minor-mode-map
  (if (and mlint-minor-mode (not (eq major-mode 'matlab-mode)))
      (progn
	(mlint-minor-mode -1)
	(error "Mlint minor mode is only for MATLAB Major mode.")))
  (if (not mlint-minor-mode)
      (progn
	;; We are linting, so don't verify on save.
	(make-variable-buffer-local 'matlab-verify-on-save-flag)
	(setq matlab-verify-on-save-flag nil)
	(mlint-unhighlight-all)
	(remove-hook 'after-save-hook 'mlint-buffer t)
	)
    (add-hook 'after-save-hook 'mlint-buffer nil t)
    (mlint-buffer))
  )

(defvar mlint-minor-mode-was-enabled-before nil
  "Non nil if mlint is off, and it was auto-disabled.")
(make-variable-buffer-local 'mlint-minor-mode-was-enabled-before)

(defun mlint-ediff-metabuffer-setup-hook ()
  "Hook run when EDiff is about to do stuff to a buffer.
That buffer will be current."
  (when (and (eq major-mode 'matlab-mode)
	     mlint-minor-mode)
    (setq mlint-minor-mode-was-enabled-before mlint-minor-mode)
    (mlint-minor-mode -1)
    ))

(add-hook 'ediff-prepare-buffer-hook 'mlint-ediff-metabuffer-setup-hook)

(defun mlint-ediff-cleanup-hook ()
  "Re-enable mlint for buffers being ediffed."
  (mapcar (lambda (b)
	    (when (save-excursion
		    (set-buffer b)
		    (and (eq major-mode 'matlab-mode)
			 mlint-minor-mode-was-enabled-before))
	      (save-excursion
		(set-buffer b)
		(mlint-minor-mode 1))))
	  (buffer-list)))

(add-hook 'ediff-cleanup-hook 'mlint-ediff-cleanup-hook)


(provide 'mlint)

;;; mlint.el ends 