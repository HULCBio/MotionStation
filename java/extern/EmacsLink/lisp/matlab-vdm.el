;;; matlab-vdm.el --- MATLAB variable display mode.
;; $Revision: 1.1.4.1 $
;; Copyright 2001-2002 The MathWorks, Inc.

;; Author: Paul Kinnucn <paulk@mathworks.com>
;; Maintainer: paulk@mathworks.com
;; Keywords: extensions
;; Created: 1995-10-06

;; $Id: matlab-vdm.el,v 1.1.4.1 2004/04/25 21:31:14 batserve Exp $

;; This file is not a part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This program was inspired by Emacs eldoc mode. Whenever you move
;; point into the name of a MATLAB variable, this mode displays 
;; the current value of the variable.

;;; Code:

(require 'timer)

(defgroup matlab-vdm nil
  "Display value of MATLAB variable in echo area."
  :group 'extensions)

;;;###autoload
(defcustom matlab-vdm-mode nil
  "*If non-nil, show the value of the MATLAB variable near point.
This variable is buffer-local."
  :type 'boolean
  :group 'matlab-vdm)
(make-variable-buffer-local 'matlab-vdm-mode)

(defcustom matlab-vdm-idle-delay 0.50
  "*Number of seconds of idle time to wait before displaying.
If user input arrives before this interval of time has elapsed after the
last input, the will not be printed.

If this variable is set to 0, no idle time is required."
  :type 'number
  :group 'matlab-vdm)

(defcustom matlab-vdm-minor-mode-string " MATLAB-Vdm"
  "*String to display in mode line when MATLAB-Vdm Mode is enabled."
  :type 'string
  :group 'matlab-vdm)

;; Put this minor mode on the global minor-mode-alist.
(or (assq 'matlab-vdm-mode (default-value 'minor-mode-alist))
    (setq-default minor-mode-alist
                  (append (default-value 'minor-mode-alist)
                          '((matlab-vdm-mode matlab-vdm-minor-mode-string)))))

;; No user options below here.

;; Commands after which it is appropriate to print in the echo area.
;; MATLAB-Vdm does not try to print function arglists, etc. after just any command,
;; because some commands print their own messages in the echo area and these
;; functions would instantly overwrite them.  But self-insert-command as well
;; as most motion commands are good candidates.
;; This variable contains an obarray of symbols; do not manipulate it
;; directly.  Instead, use `matlab-vdm-add-command' and `matlab-vdm-remove-command'.
(defvar matlab-vdm-message-commands nil)

;; This is used by matlab-vdm-add-command to initialize matlab-vdm-message-commands
;; as an obarray.
;; It should probably never be necessary to do so, but if you
;; choose to increase the number of buckets, you must do so before loading
;; this file since the obarray is initialized at load time.
;; Remember to keep it a prime number to improve hash performance.
(defvar matlab-vdm-message-commands-table-size 31)

;; Bookkeeping; elements are as follows:
;;   0 - contains the last variable read from the buffer.
;;   1 - contains the string last displayed in the echo area for that
;;       variable, so it can be printed again if necessary without reconsing.
(defvar matlab-vdm-last-data (make-vector 2 nil))
(defvar matlab-vdm-last-message nil)

;; Idle timers are supported in Emacs 19.31 and later.
(defvar matlab-vdm-use-idle-timer-p (fboundp 'run-with-idle-timer))

;; matlab-vdm's timer object, if using idle timers
(defvar matlab-vdm-timer nil)

;; idle time delay currently in use by timer.
;; This is used to determine if matlab-vdm-idle-delay is changed by the user.
(defvar matlab-vdm-current-idle-delay matlab-vdm-idle-delay)


;;;###autoload
(defun matlab-vdm-mode (&optional prefix)
  "*Enable or disable matlab-vdm mode.
See documentation for the variable of the same name for more details.

If called interactively with no prefix argument, toggle current condition
of the mode.
If called with a positive or negative prefix argument, enable or disable
the mode, respectively."
  (interactive "P")
  (setq matlab-vdm-last-message nil)
  (cond (matlab-vdm-use-idle-timer-p
         (add-hook 'post-command-hook 'matlab-vdm-schedule-timer)
         (add-hook 'pre-command-hook 'matlab-vdm-pre-command-refresh-echo-area))
        (t
         ;; Use post-command-idle-hook if defined, otherwise use
         ;; post-command-hook.  The former is only proper to use in Emacs
         ;; 19.30; that is the first version in which it appeared, but it
         ;; was obsolesced by idle timers in Emacs 19.31.
         (add-hook (if (boundp 'post-command-idle-hook)
                  'post-command-idle-hook
                'post-command-hook)
              'matlab-vdm-display-current-variable-value)
         ;; quick and dirty hack for seeing if this is XEmacs
         (and (fboundp 'display-message)
              (add-hook 'pre-command-hook
                        'matlab-vdm-pre-command-refresh-echo-area))))
  (setq matlab-vdm-mode (if prefix
                       (>= (prefix-numeric-value prefix) 0)
                     (not matlab-vdm-mode)))
  (and (interactive-p)
       (if matlab-vdm-mode
           (message "matlab-vdm-mode is enabled")
         (message "matlab-vdm-mode is disabled")))
  matlab-vdm-mode)

;;;###autoload
(defun turn-on-matlab-vdm-mode ()
  "Unequivocally turn on matlab-vdm-mode (see variable documentation)."
  (interactive)
  (matlab-vdm-mode 1))


;; Idle timers are part of Emacs 19.31 and later.
(defun matlab-vdm-schedule-timer ()
  (or (and matlab-vdm-timer
           (memq matlab-vdm-timer timer-idle-list))
      (setq matlab-vdm-timer
            (run-with-idle-timer matlab-vdm-idle-delay t
                                 'matlab-vdm-display-current-variable-value)))

  ;; If user has changed the idle delay, update the timer.
  (cond ((not (= matlab-vdm-idle-delay matlab-vdm-current-idle-delay))
         (setq matlab-vdm-current-idle-delay matlab-vdm-idle-delay)
         (timer-set-idle-time matlab-vdm-timer matlab-vdm-idle-delay t))))

(defun matlab-vdm-message (&rest args)
  (let ((omessage matlab-vdm-last-message))
    (cond 
     ((eq (car args) matlab-vdm-last-message))
     ((or (null args)
	  (null (car args)))
      (setq matlab-vdm-last-message nil))
     ;; If only one arg, no formatting to do so put it in
     ;; matlab-vdm-last-message so eq test above might succeed on
     ;; subsequent calls.
     ((null (cdr args))
      (setq matlab-vdm-last-message (car args)))
     (t
      (setq matlab-vdm-last-message (apply 'format args))))
    ;; In emacs 19.29 and later, and XEmacs 19.13 and later, all messages
    ;; are recorded in a log.  Do not put matlab-vdm messages in that log since
    ;; they are Legion.
    (cond 
     ((fboundp 'display-message)
      ;; XEmacs 19.13 way of preventing log messages.
      (cond (matlab-vdm-last-message
	     (display-message 'no-log matlab-vdm-last-message))
	    (omessage
	     (clear-message 'no-log))))
     (t
      ;; Emacs way of preventing log messages.
      (let ((message-log-max nil))
	(cond (matlab-vdm-last-message
	       (message "%s" matlab-vdm-last-message))
	      (omessage
	       (message nil)))))))
  matlab-vdm-last-message)

;; This function goes on pre-command-hook for XEmacs or when using idle
;; timers in Emacs.  Motion commands clear the echo area for some reason,
;; which make matlab-vdm messages flicker or disappear just before motion
;; begins.  This function reprints the last matlab-vdm message immediately
;; before the next command executes, which does away with the flicker.
;; This doesn't seem to be required for Emacs 19.28 and earlier.
(defun matlab-vdm-pre-command-refresh-echo-area ()
  (and matlab-vdm-last-message
       (if (matlab-vdm-display-message-no-interference-p)
           (matlab-vdm-message matlab-vdm-last-message)
         (setq matlab-vdm-last-message nil))))

;; Decide whether now is a good time to display a message.
(defun matlab-vdm-display-message-p ()
  ;; (message "No interference = %s" (if (matlab-vdm-display-message-no-interference-p) "true" "false"))
  (and (matlab-vdm-display-message-no-interference-p)
       (cond (matlab-vdm-use-idle-timer-p
              ;; If this-command is non-nil while running via an idle
              ;; timer, we're still in the middle of executing a command,
              ;; e.g. a query-replace where it would be annoying to
              ;; overwrite the echo area.
	      ;; (message "this command %s; last cmd %s" this-command last-command)
              (and (not this-command)
                   (symbolp last-command)
                   (intern-soft (symbol-name last-command)
                                matlab-vdm-message-commands)))
             (t
              ;; If we don't have idle timers, this function is
              ;; running on post-command-hook directly; that means the
              ;; user's last command is still on `this-command', and we
              ;; must wait briefly for input to see whether to do display.
              (and (symbolp this-command)
                   (intern-soft (symbol-name this-command)
                                matlab-vdm-message-commands)
                   (sit-for matlab-vdm-idle-delay))))))

(defun matlab-vdm-display-message-no-interference-p ()
  (and matlab-vdm-mode
       (not executing-kbd-macro)
       ;; Having this mode operate in an active minibuffer/echo area causes
       ;; interference with what's going on there.
       (not cursor-in-echo-area)
       (not (eq (selected-window) (minibuffer-window)))))



(defun matlab-vdm-get-value-string (variable)
  (matlab-eei-send-mcmd 
     (concat "display_variable " variable) t)    
  (if (string= (matlab-eei-wait-for-event) "variable-value")
      (matlab-vdm-format-echo-msg 
       variable
       (matlab-vdm-value-first-line matlab-eei-last-variable))))


(defun matlab-vdm-display-current-variable-value ()
  ;; (message "Display msg? %s." (if (matlab-vdm-display-message-p) "yes" "no"))
  (if (and
       (matlab-vdm-display-message-p)
       matlab-eei-matlab-in-debug-mode-p)
       (let ((current-variable (thing-at-point 'symbol))
	      value-string)
	 (message "debug: current-variable = %s" current-variable)
 	 (if current-variable
	     (setq value-string (matlab-vdm-get-value-string current-variable)))
	 (message "debug: value-string = %s" value-string)
	        (if value-string
	     (matlab-vdm-message value-string)))))


(defun matlab-vdm-last-data-store (variable value)
  (aset matlab-vdm-last-data 0 variable)
  (aset matlab-vdm-last-data 1 value))


(defun matlab-vdm-value-first-line (value)
  (if (stringp value)
      (save-match-data
	(if (string-match "\n" value)
	    (let ((first-line (substring value 0 (match-beginning 0))))
	      (if (= (length first-line) (1- (length value)))
		  first-line
		(format "%s ..." first-line)))
	  value))))

;; If the entire line cannot fit in the echo area, the symbol name may be
;; truncated or eliminated entirely from the output to make room for the
;; description.
(defun matlab-vdm-format-echo-msg (variable value)
  (save-match-data
    (let* ((msglen (+ (length variable) (length ": ") (length value)))
           ;; Subtract 1 from window width since emacs seems not to write
           ;; any chars to the last column, at least for some terminal types.
           (strip (- msglen (1- (window-width (minibuffer-window))))))
      (cond ((> strip 0)
             (let* ((len (length variable)))
               (cond ((>= strip len)
                      (format "%s" value))
                     (t
                      ;;(setq variable (substring variable 0 (- len strip)))
                      ;;
                      ;; Show the end of the partial symbol name, rather
                      ;; than the beginning, since the former is more likely
                      ;; to be unique given package namespace conventions.
                      (setq variable (substring variable strip))
                      (format "%s: %s" variable value)))))
            (t
             (format "%s: %s" variable value))))))



(defun matlab-vdm-add-command (&rest cmds)
  (or matlab-vdm-message-commands
      (setq matlab-vdm-message-commands
            (make-vector matlab-vdm-message-commands-table-size 0)))

  (let (name sym)
    (while cmds
      (setq name (car cmds))
      (setq cmds (cdr cmds))

      (cond ((symbolp name)
             (setq sym name)
             (setq name (symbol-name sym)))
            ((stringp name)
             (setq sym (intern-soft name))))

      (and (symbolp sym)
           (fboundp sym)
           (set (intern name matlab-vdm-message-commands) t)))))

(defun matlab-vdm-add-command-completions (&rest names)
  (while names
      (apply 'matlab-vdm-add-command
             (all-completions (car names) obarray 'fboundp))
      (setq names (cdr names))))

(defun matlab-vdm-remove-command (&rest cmds)
  (let (name)
    (while cmds
      (setq name (car cmds))
      (setq cmds (cdr cmds))

      (and (symbolp name)
           (setq name (symbol-name name)))

      (if (fboundp 'unintern)
          (unintern name matlab-vdm-message-commands)
        (let ((s (intern-soft name matlab-vdm-message-commands)))
          (and s
               (makunbound s)))))))

(defun matlab-vdm-remove-command-completions (&rest names)
  (while names
    (apply 'matlab-vdm-remove-command
           (all-completions (car names) matlab-vdm-message-commands))
    (setq names (cdr names))))


;; Prime the command list.
(matlab-vdm-add-command-completions
 "backward-" "beginning-of-" "delete-other-windows" "delete-window"
 "end-of-" "forward-" "indent-for-tab-command" "goto-" "mouse-set-point"
 "next-" "other-window" "previous-" "recenter" "scroll-"
 "self-insert-command" "split-window-"
 "up-list" "down-list" "mouse-track")

(provide 'matlab-vdm)

;;; matlab-vdm.el ends here
