;;; -*- emacs-lisp -*-
;;; Miscellaneous notes:
;;;
;;; Change font size and frame size in all frame contents:
;;;   zoom-in
;;;   zoom-out
;;;
;;; Change font size in one buffer:
;;;   C-x C-+	text-scale-increase
;;;   C-x C--	text-scale-decrease
;;;
;;; This is nice for debugging on type error:
;;;   (message (prin1-to-string (type-of (car paths)))))

(setq line-move-visual nil)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
; (fringe-mode 2)

;;; configure the load-path based on what's available
;;
(let ((paths '(
               "/usr/share/emacs/site-lisp"
	       "/usr/share/emacs/site-lisp/ruby-elisp"
	       "/usr/share/emacs/site-lisp/sml-mode"
	       "/usr/share/emacs/site-lisp/mgp"
	       "/usr/local/share/emacs/site-lisp"
               "~/site-lisp/dismal-1.4"
               "~/site-lisp/ess-5.13/lisp"
	       "~/site-lisp/ess-13.09-1/lisp"
               "~/site-lisp/bbdb/lisp"
               "~/site-lisp/gnus/lisp"
	       "~/site-lisp"
	       )))
  (mapc '(lambda (f)
	  (if f
	      (let ((dir (expand-file-name f)))
		(if (file-readable-p dir)
		    (add-to-list 'load-path dir)))))
	paths))

;;; Use extensions if they're available.
(let ((extensions
       '((ess-site "ESS")               ; For running GNU R
	 (xcscope "cscope"              ; For using cscope
		  (lambda ()
		    (setq cscope-do-not-update-database t)
		    (message "did hi mom?")))
	 (moinmoin-mode "moinmoin"      ; For editing wiki content
			(lambda ()
			  (defun moinmoin-setup-font-lock ()))))))
  (mapc (lambda (p)
	  (let ((s (car p))
		(name (car (cdr p)))
		(do-settings (car (cdr (cdr p)))))
	    (condition-case err
		(progn
		  (require s)
		  (if do-settings
		      (apply do-settings ())))
	      (error
	       (message "Cannot use %s: %s" name (cdr err))))))
	  extensions))

;;; Add some stuff to the PATH if it's there.
(let* ((home (getenv "HOME"))
       (script (concat home "/script"))
       (optbin (concat home "/opt/bin"))
       (paths (list
               script
               optbin
               "/opt/local/bin"
               "/opt/local/sbin"
               "/usr/bin"
               "/bin"
               "/usr/sbin"
               "/sbin"
               "/usr/local/bin"
               "/usr/X11/bin"))
       (extant-paths
        (delq nil
              (mapcar
               '(lambda (f)
                  (if f
                      (let ((dir (expand-file-name f)))
                        (if (file-readable-p dir)
                            dir)))) paths))))
  (setenv "PATH" (mapconcat 'identity extant-paths ":"))
  (mapc '(lambda (p)
           (if (not (member p exec-path))
               (add-to-list 'exec-path p))) paths))

((lambda ()
  (setq ruby-indent-level 8)
  (setq ruby-indent-tabs-mode t)))

((lambda ()
   (blink-cursor-mode -1)
   (set-cursor-color "plum")))

(add-hook 'java-mode-common-hook '(lambda()(require 'xcscope)))

((lambda ()                             ; Python
   (add-to-list 'auto-mode-alist (cons (purecopy "\\.pyx\\'")  'python-mode))
   (add-to-list 'auto-mode-alist (cons (purecopy "\\.pyi\\'")  'python-mode))
   (add-hook 'python-mode-hook '(lambda()
                                  (setq-default indent-tabs-mode nil)))))

(add-hook 'c-mode-common-hook
	  (lambda ()
	    (setq show-trailing-whitespace t)))
(setq-default require-final-newline t)

(defun revt ()
  "Replace the buffer text with the text of the visited file on disk.
This undoes all changes since the file was visited or saved."
  (interactive)
  (save-excursion
    (revert-buffer 'nil 't)))

(let ()
  (global-set-key "\C-x\C-b" 'electric-buffer-list)
  (global-set-key "\C-xg" 'goto-line)
  (global-set-key "\C-ci" 'ispell-region)
  )

((lambda ()
   ; (show-paren-mode -1)  ;; You have to toggle the mode to get delay change.
   (show-paren-mode 1)
   (setq show-paren-delay 0.4)))

(setq-default
 show-trailing-whitespace t
 dired-use-ls-dired nil)

(let ()
  ;; basic initialization, (require) non-ELPA packages, etc.
  (setq package-enable-at-startup nil)
  (package-initialize)
  (add-to-list 'package-archives
               '("marmalade" . "https://marmalade-repo.org/packages/"))
  (add-to-list 'package-archives
               '("melpa" . "http://melpa.milkbox.net/packages/"))
  ; (add-to-list 'package-archives '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/") t)
  (add-to-list
   'package-archives
   '("org" . "http://orgmode.org/elpa/")
   t) ; Org-mode's repository

  ;; package-install tss
  (add-to-list 'auto-mode-alist
               '("\\.ts" . typescript-mode)))

;;; Go support via go-mode from ELPA.
(if (boundp 'gofmt-before-save)
    (add-hook 'before-save-hook #'gofmt-before-save))
