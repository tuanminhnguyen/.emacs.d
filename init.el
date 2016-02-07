1;; no startup messages
(setq inhibit-startup-message t)

;; Move to the next 'last character' of a word
1(defun last-in-word ()
  "Move to the next 'last character' of a word."
  (interactive)
  (forward-char)
  (re-search-forward "\\w\\b" nil t)
  (goto-char (match-beginning 0))) 
(global-set-key "\M-n" 'last-in-word)

;; Include MELPA
(require 'package)

;; package-initialize is required to load auto-complete correctly
(package-initialize)

(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'custom-theme-load-path "~/.emacs.d/atom-one-dark-theme/")

;; Load text color theme
(load-theme 'atom-one-dark t)

;; Set line spacing
(setq-default line-spacing 5)

;; Support for multiple major modes
(add-to-list 'load-path "~/.emacs.d/ess-15.09-2/lisp/")
(load "ess-site")
(setq load-path
      (append '("~/.emacs.d/polymode" "~/.emacs.d/polymode/modes")
	      load-path))

;; Enable copy/paste between emacs and other applications
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-selection-value); OUTDATED:: 'x-cut-buffer-or-selection-value)

;; Enable showing matching parentheses
(show-paren-mode 1)

;; Show matching paren when it is offscreen
(defadvice show-paren-function
    (after show-matching-paren-offscreen activate)
  "If the matching paren is offscreen, show the matching line in the echo
area. Has no effect if the character before point is not of the syntax class ')'."
  (interactive)
  (let* ((cb (char-before (point)))
	 (matching-text (and cb
			     (char-equal (char-syntax cb) ?\) )
			     (blink-matching-open))))
    (when matching-text (message matching-text))))

;; Enable ido mode
;; to configure: M-x customize-group RET ido RET
(add-to-list 'load-path "~/.emacs.d/ido.el")
(require 'ido)
(ido-mode t)

;; Enable auto complete mode
(setq line-number-mode t)
(setq column-number-mode t)

;; Enable global auto completion
;(load-file "~/.emacs.d/elpa/auto-complete-1.5.0/auto-complete.elc")
(require 'auto-complete)
(global-auto-complete-mode t)

;; delete selection with a keypress
(delete-selection-mode t)

;; smart tab behavior - indent or complete
(setq tab-always-indent 'complete)

;; highlight the current line-spacing
(global-hl-line-mode +1)

;; from Emacs Redux
(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (indent-buffer)
        (message "Indented buffer.")))))

;; keybinding
(global-set-key (kbd "C-M-\\") 'indent-region-or-buffer)

(setq visual-fill-column-mode 1)

;; Enable yasnippet for template expansion
(require 'yasnippet)
(yas-global-mode 1)

(require 'dash)
(require 's)
(require 'f)
;; Enable live py mode
;; See details at https://github.com/donkirkby/live-py-plugin
(require 'live-py-mode)

;; Python IDE setup
(elpy-enable)

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

(add-to-list 'load-path "~/.emacs.d/elpa/")
(require 'ob-ipython)

;; enable emacs server in anaconda Ipython notebook
(defvar server-buffer-clients)
(when (and (fboundp 'server-start) (string-equal (getenv "TERM") 'xterm))
  (server-start)
  (defun fp-kill-server-with-buffer-routine ()
    (and server-buffer-clients (server-done)))
  (add-hook 'kill-buffer-hook 'fp-kill-server-with-buffer-routine))

;; Enable transient mark mode

;; org-mode configuration
(require 'org)
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))

;; Activate Babel support for the following languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (python . t)))
;;   (cpp . t)
;;   (shell . t)	     
;;   (mathematica . t)
;;   (matlab . t)     	    
;;   (latex . t)	     
;;   (emacslisp . t)  
;;   ))		     

(setq org-confirm-babel-evaluate nil)				       	      
(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append) 

(defun backward-kill-line (arg)
  "Kill ARG lines backward."
  (interactive "p")
  (kill-line (- 1 arg)))

(global-set-key "\C-cu" 'backward-kill-line) ;;'C-c u'

					; Fix iedit bug in Mac
(define-key global-map (kbd "C-c ;") 'iedit-mode)

(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; Auto-indent yanked (pasted) code
(dolist (command '(yank yank-pop))
   (eval `(defadvice ,command (after indent-region activate)
            (and (not current-prefix-arg)
                 (member major-mode '(emacs-lisp-mode lisp-mode
                                                      clojure-mode    scheme-mode
                                                      haskell-mode    ruby-mode
                                                      rspec-mode      python-mode
                                                      c-mode          c++-mode
                                                      objc-mode       latex-mode
                                                      plain-tex-mode))
                 (let ((mark-even-if-inactive transient-mark-mode))
                   (indent-region (region-beginning) (region-end) nil))))))
