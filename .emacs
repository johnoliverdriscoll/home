(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(coffee-tab-width 2)
 '(indent-tabs-mode nil)
 '(initial-scratch-message "")
 '(js-expr-indent-offset 0)
 '(js-indent-level 2)
 '(js2-auto-indent-p t)
 '(js2-basic-offset 2)
 '(js2-cleanup-whitespace t)
 '(js2-consistent-level-indent-inner-bracket-p t)
 '(js2-enter-indents-newline t)
 '(js2-indent-on-enter-key t)
 '(js2-rebind-eol-bol-keys nil)
 '(js2-use-ast-for-indentation-p t)
 '(python-indent 2)
 '(ruby-deep-indent-paren (quote (40 91 93 t)))
 '(ruby-deep-indent-paren-style nil)
 '(standard-indent 2))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(require 'cl)

;; no splash message
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; Remove the pointless menu bar
(menu-bar-mode -1)

;; backup/autosave
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq backup-directory-alist (list (cons ".*" backup-dir)))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

;; local site-lisp
(add-to-list 'load-path "~/.emacs.d/site-lisp/")
(add-to-list 'load-path "~/.emacs.d/site-lisp/malabar-1.4.0/lisp")

(setq semantic-default-submodes '(global-semantic-idle-scheduler-mode
                                  global-semanticdb-minor-mode
                                  global-semantic-idle-summary-mode
                                  global-semantic-mru-bookmark-mode))
(semantic-mode 1)
(require 'malabar-mode)
(setq malabar-groovy-lib-dir "/home/john/.emacs.d/site-lisp/malabar-1.4.0/lib")
(add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))

;; no linewrap character
(set-display-table-slot standard-display-table 'wrap ?\ )

;; indents
(setq case-fold-search t)
(defun my-indent-setup ()
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close 0))
(add-hook 'java-mode-hook 'my-indent-setup)
(add-hook 'java-mode-hook (lambda () (setq indent-tabs-mode t)))

;; custom file extensions for major mode
(require 'coffee-mode)
(add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
(add-to-list 'auto-mode-alist '("Cakefile" . coffee-mode))

(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl$" . sws-mode))
(add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))
(add-to-list 'auto-mode-alist '("\\.less$" . css-mode))

;; Tabbar
(setq mouse-wheel-mode ())
(require 'tabbar)
(tabbar-mode t)
(setq *tabbar-ignore-buffers* '("*Messages*" " *Echo Area 0*" "*Completions*"
                                " *Echo Area 1*" " *Minibuf-0*" "*scratch*"
                                " *code-conversion-work*" " *Minibuf-1*"
                                " *w3m cache*" " *Malabar Groovy eval*" 
                                " *code-converting-work*" " *srecode-map-tmp*"
                                "*Malabar Compilation*"))
(setq tabbar-buffer-list-function
      (lambda ()
        (remove-if
         (lambda (buffer)
           ;remove buffer name in this list.
	   (loop for name in *tabbar-ignore-buffers* 
		 thereis (string-equal (buffer-name buffer) name)))
         (buffer-list)
         )))
 (setq tabbar-buffer-groups-function
          (lambda ()
            (list "All")))

 (defadvice tabbar-buffer-tab-label (after fixup_tab_label_space_and_flag activate)
   (setq ad-return-value
         (if (and (buffer-modified-p (tabbar-tab-value tab))
                   (buffer-file-name (tabbar-tab-value tab)))
             (concat " + " (concat ad-return-value " "))
           (concat " " (concat ad-return-value " ")))))
 ;; called each time the modification state of the buffer changed
 (defun ztl-modification-state-change ()
   (tabbar-set-template tabbar-current-tabset nil)
   (tabbar-display-update))
 ;; first-change-hook is called BEFORE the change is made
 (defun ztl-on-buffer-modification ()
   (set-buffer-modified-p t)
   (ztl-modification-state-change))
 (add-hook 'after-save-hook 'ztl-modification-state-change)
 ;; this doesn't work for revert, I don't know
 ;;(add-hook 'after-revert-hook 'ztl-modification-state-change)
 (add-hook 'first-change-hook 'ztl-on-buffer-modification)

; Rebind buffer switching commands to not use the fucking arrow keys
(global-set-key [?\M-n] 'tabbar-forward)
(global-set-key [?\M-p] 'tabbar-backward)

; Rebind ^H to backspace
(global-set-key [?\C-h] 'delete-backward-char)

;; Smart home
(defun smart-beginning-of-line ()
  "Move point to first non-whitespace character or beginning-of-line.

Move point to the first non-whitespace character on this line.
If point was already at that position, move point to beginning of line."
  (interactive) ; Use (interactive "^") in Emacs 23 to make shift-select work
  (let ((oldpos (point)))
    (back-to-indentation)
    (and (= oldpos (point))
         (beginning-of-line))))
(global-set-key [?\C-a] 'smart-beginning-of-line)

; I did this all by myself!
(add-hook 'makefile-mode-hook 
          (lambda ()
            (local-set-key [?\M-n] 'tabbar-forward)
            (local-set-key [?\M-p] 'tabbar-backward)))