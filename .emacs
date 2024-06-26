
;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(indent-tabs-mode nil)
 '(initial-scratch-message "")
 '(js-indent-level 2)
 '(package-selected-packages
   (quote
    (rust-mode tabbar session pod-mode muttrc-mode mutt-alias markdown-mode initsplit htmlize graphviz-dot-mode folding eproject diminish csv-mode browse-kill-ring boxquote bm bar-cursor apache-mode)))
 '(python-indent 2)
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

;; indents
(setq-default c-indent-level 2)
(setq-default c-basic-offset 2)

(defun my-arg-list-indentation ()
  (c-set-offset 'arglist-intro '+)
  (c-set-offset 'arglist-close 0))
(add-hook 'c-mode-hook 'my-arg-list-indentation)
(add-hook 'c++-mode-hook 'my-arg-list-indentation)

;; no linewrap character
(set-display-table-slot standard-display-table 'wrap ?\ )

;; Tabbar
(setq mouse-wheel-mode ())
(require 'tabbar)
(tabbar-mode t)
(setq *tabbar-ignore-buffers* '("*Messages*" " *Echo Area 0*" "*Completions*"
                                " *Echo Area 1*" " *Minibuf-0*" "*scratch*"
                                " *code-conversion-work*" " *Minibuf-1*"
                                " *C parse hack 1*" " *code-converting-work*"))
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
;(global-set-key [?\M-n] 'tabbar-forward)
;(global-set-key [?\M-p] 'tabbar-backward)

(defvar my-mode-map (make-sparse-keymap) "Keymap for `my-mode'.")
(define-minor-mode my-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-mode"
    :keymap my-mode-map)
(define-globalized-minor-mode global-my-mode my-mode my-mode)
(add-to-list 'emulation-mode-map-alists `((my-mode . ,my-mode-map)))
(define-key my-mode-map [?\M-n] 'tabbar-forward)
(define-key my-mode-map [?\M-p] 'tabbar-backward)

(provide 'my-mode)


; Force C++ mode when opening header files
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

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

(put 'upcase-region 'disabled nil)
