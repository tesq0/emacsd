;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Change some default settings    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(setq user-full-name "Mikołaj Gałkowski")                 ; My name
;;(setq gc-cons-threshold (* 500 1024 1024))                  ; increase the threshold for garbage collection - 100 MB
;;(setq delete-old-versions -1)                     ; delete excess backup versions silently
;;(setq version-control t)                      ; use version control for backups
;;(setq backup-directory-alist `(("." . "~/.emacs.d/backups")))             ; which directory to put backups file
(setq make-backup-files nil)						;Don't write backup files
(setq inhibit-startup-screen t)                     ; inhibit useless and old-school startup screen
(setq visible-bell nil)                       ; no visible bell for errors
(setq ring-bell-function 'ignore)                   ; silent bell when you make a mistake
(setq coding-system-for-read 'utf-8)                    ; use utf-8 by default for reading
(setq coding-system-for-write 'utf-8)                   ; use utf-8 by default for writing
(setq initial-major-mode 'evil-mode)                 ; set the mode of the initial scratch buffer
(setq initial-scratch-message "")                             ; print nothing and leave screen at insert mode
(if window-system
(progn 
(menu-bar-mode -1)                        ; deactivate the menubar
(tool-bar-mode -1)                        ; deactivate the toolbar
(scroll-bar-mode -1)                        ; deactivate the scrollbar
(tooltip-mode -1)))                       ; deactivate the tooltip
(defun display-startup-echo-area-message () (message "Good morning, Logic is always number 1"))     ; change the default startup echo message
(setq-default truncate-lines t)                     ; always truncate lines ;hello
(setq large-file-warning-threshold (* 15 1024 1024))                ; increase theshold for larger files
(fset 'yes-or-no-p 'y-or-n-p)                     ; prompt for 'y' or 'n' instead of 'yes' or 'no'
;; (setq-default abbrev-mode t)                      ; turn on abbreviations by default
(setq recenter-positions '(middle top bottom))                    ; recenter from the top instead of the middle
 ;; (put 'narrow-to-region 'disabled nil)                   ; enable narrowing to region
 ;; (put 'narrow-to-defun 'disabled nil)                    ; enable narrowing to function
(when (fboundp 'winner-mode)                      ; when you can find 'winner-mode'
	(winner-mode 1))                        ; activate winner mode
;;(setq enable-recursive-minibuffers t)                   ; use the minibuffer while using the minibuffer
(setq echo-keystrokes 0.05)                     ; when to echo keystrokes
;;(setq frame-resize-pixelwise t)                     ; resize based on pixels to remove annoying gaps
(setq-default tab-width 2)                        ; default tab width
(show-paren-mode 1)                     ; hightlight pharentheses and shit
;; (setq x-super-keysym 'meta)             ;use super as meta
(setq shell-file-name "bash")           ; shell name to bash
(setq shell-command-switch "-c")        ; use my .bashrc aliases
(setq initial-buffer-choice t)					; use scratchpad as default buffer when calling emacsclient

(add-to-list 'default-frame-alist '(font . "Hack" ))

;;(setq display-buffer-alist '(("\\`\\*e?shell" display-buffer-pop-up-window)))

;; line number mode;
;;(setq display-line-numbers-current-absolute nil)
;;(set-cursor-color "#FFFFFF")
;;(blink-cursor-mode)

;; (global-display-line-numbers-mode)
;;(setq display-line-numbers-type 'relative)
;; (server-start)
;; (setq debug-on-error t)
;; (setq split-width-threshold 'nil)

;; ANSI colors in shell
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-to-list 'comint-output-filter-functions 'ansi-color-process-output)


;; scroll one line at a time (less "jumpy" than defaults)

(setq mouse-wheel-scroll-amount '(4 ((shift) . 4))) ;; one line at a time

(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling

(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(setq scroll-step 4) ;; keyboard scroll one line at a time



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Package management    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Include the module to install packages
(require 'package)

;; tells emacs not to load any packages before starting up
(setq package-enable-at-startup nil)

;; the following lines tell emacs where on the internet to look up
;; for new packages.
(setq package-archives '(("org"       . "https://orgmode.org/elpa/")
												 ("gnu"       . "https://elpa.gnu.org/packages/")
												 ("melpa"     . "https://melpa.org/packages/")))

;; initialize the packages
(setq package-check-signature nil)
(package-initialize)

;;;;;;;;;;;;;;;;;;;;;;;
;;    use-package    ;;
;;;;;;;;;;;;;;;;;;;;;;;

(unless (package-installed-p 'use-package)
	(package-refresh-contents)
	(package-install 'use-package))
(eval-when-compile
	(require 'use-package))
(require 'bind-key)

(use-package diminish
	:ensure t
	:defer t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Built-in packages    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;; pdf/image viewing
(use-package doc-view
	:hook ((doc-view-mode . doc-view-fir-page-to-window)
				 (doc-view-minor-mode . doc-view-fir-page-to-window))
	:init
	(setq doc-view-continuous t))

;; builtin version control
(use-package vc
	:init
	(setq vc-make-backup-files t
				vc-follow-symlinks t))

;; diff management
(use-package ediff
	:init
	(setq ediff-window-setup-function 'ediff-setup-windows-plain
				ediff-split-window-function 'split-window-horizontally))

;; abbrev
(use-package abbrev
	:diminish abbrev-mode
	:init
	(setq save-abbrevs 'silently)
	:config
	(if (file-exists-p abbrev-file-name)
			(quietly-read-abbrev-file)))


;; auto fill mode
(use-package simple
	:diminish auto-fill-function)

;; auto revert mode
(use-package autorevert
	:defer t
	:diminish auto-revert-mode)

;; ;; documentation helper
;; (use-package eldoc
;;   :hook (prog-mode . eldoc-mode)
;;   :diminish eldoc-mode)

;; spell check
(use-package flyspell
	:bind (:map flyspell-mode-map
							("C-;" . nil))
	:init (progn
					;; (add-hook 'prog-mode-hook #'flyspell-prog-mode)
					(dolist (mode-hook '(text-mode-hook org-mode-hook LaTeX-mode-hook))
						(add-hook mode-hook #'flyspell-mode))))

;; save history
(use-package savehist
	:defer t
	:config
	(savehist-mode 1))


(use-package fzf
	:defer t
	:config
	(progn
		(setq fzf/directory-start "/")
		)
	)

(use-package term
						 :config
						 (progn
							 (define-key term-mode-map "\C-n" 'term-next-input)
							 (define-key term-mode-map "\C-p" 'term-previous-input)
							 )
						 )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Third party packages    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; extra functions
(add-to-list 'load-path
						 (expand-file-name "defuns" user-emacs-directory))

;; other configuration
(add-to-list 'load-path
						 (expand-file-name "config" user-emacs-directory))

;; manually installed packages
(add-to-list 'load-path
						 (expand-file-name "local" user-emacs-directory))

;; themes
(add-to-list 'load-path
						 (expand-file-name "themes" user-emacs-directory))

(use-package async
	:ensure t
	:config
	(autoload 'dired-async-mode "dired-async.el" nil t)
	(dired-async-mode 1)
	)


;; hint for bindings
(use-package which-key
	:ensure t
	:demand t
	:diminish which-key-mode
	:bind* (("C-c ?" . which-key-show-top-level))
	:config
	;; workaround for emacs 26
	(if (version< emacs-version "26")
			(message "Tracking stable Emacs")
		(defalias 'display-buffer-in-major-side-window 'window--make-major-side-window))
	;; turn on which key and add some names for default/common prefixes
	(which-key-enable-god-mode-support)
	(which-key-mode))


(use-package restart-emacs
	:ensure t
	:bind* (("C-x C" . restart-emacs)))

;;configs
(require 'mikus-evil)

(require 'mikus-hydra)



;; flash current line

(require 'hl-line+)
(global-set-key (kbd "<C-return>") 'hl-line-flash)

;; web mode config - eslint, babel, react and shit


(require 'mikus-webmode)
(require 'mikus-csharp)


;;; Shell mode


;; better help

(require 'help-fns+)

;;; helm sys
(require 'helm-sys)

;; autocompletion

(use-package company
	:init (progn
					(add-hook 'prog-mode-hook 'company-mode))
	:diminish
	:config (progn
						(setq company-selection-wrap-around t)
						(define-key company-active-map [tab] 'company-complete)
						(define-key company-active-map (kbd "C-n") 'company-select-next)
						(define-key company-active-map (kbd "C-p") 'company-select-previous)
						(setq company-idle-delay 0.2)
						(setq company-tooltip-limit 10)
						(setq company-minimum-prefix-length 2)
						(setq company-tooltip-flip-when-above t)
						(add-to-list 'company-backends '( company-keywords company-capf company-files company-omnisharp))))

(use-package company-dabbrev
	:config (progn
						(setq company-dabbrev-ignore-case t)
						(setq company-dabbrev-downcase nil)))


(use-package slime-company
	:ensure t)

;; (use-package ediff
;;   :config (progn
;;             ;; window positioning & frame setup
;;             (setq ediff-window-setup-function 'ediff-setup-windows-plain
;;                   ediff-split-window-function 'split-window-horizontally)))


(use-package editorconfig
	:ensure t
	:config (editorconfig-mode 1))

(use-package elec-pair
	:ensure t
	:config (electric-pair-mode t))


(use-package company-tern
	:ensure t
	)

;; (use-package smooth-scroll
;; 	:ensure t
;; 	:config
;; 	(smooth-scroll-mode)
;; 	)

;; jump to definition

 (setq ls-lisp-use-insert-directory-program nil) 
 (require 'ls-lisp)


(use-package ag
	:ensure t )

(use-package dumb-jump
	:ensure t
	:config
	(global-set-key (kbd "M-.") 'dumb-jump-go)
	(global-set-key (kbd "M-,") 'dumb-jump-back)
	(add-hook 'dumb-jump-after-jump-hook 'hl-line-flash)
	)



(use-package rainbow-mode
	:ensure t)


(use-package org
	:ensure t)

;; defuns

(require 'reindent-buffer)
(require 'utils)



;; colortheme





(require 'dracula-theme)
;;(load-theme 'dracu

(if (daemonp)
		(add-hook 'after-make-frame-functions
							(lambda (frame)
								(with-selected-frame frame
									(load-theme 'dracula t))))
	(load-theme 'dracula t))


;; (use-package gruvbox-theme
;;   :ensure t
;;  :init
;;  (load-theme 'gruvbox-dark-hard t)
;;  )

;;   :ensure t
;;   :config
;;   (load-theme 'zerodark t)
;;   (zerodark-setup-modeline-format)
;;   )

;; (use-package zerodark-theme
;;   :ensure t
;;   :config
;;   (progn
;;     (defun set-selected-frame-dark ()
;;       (interactive)
;;       (let ((frame-name (cdr (assq 'name (frame-parameters (selected-frame))))))
;;         (call-process-shell-command
;;          (format
;;           "xprop -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT 'dark' -name '%s'"
;;           frame-name))))

;;     (when (window-system)
;;       (load-theme 'zerodark t)
;;       (zerodark-setup-modeline-format)
;;       (set-selected-frame-dark)
;;       (setq frame-title-format '(buffer-file-name "%f" ("%b"))))))

;; magit package

(use-package magit
	:ensure t
	:config
	(define-key magit-mode-map (kbd "<escape>") 'magit-mode-bury-buffer)
	(define-key magit-mode-map (kbd "C-g") 'magit-mode-bury-buffer)
	;; SMERGE
	(define-key smerge-mode-map (kbd "C-c m") (lookup-key smerge-mode-map (kbd "C-c ^")))
	)


(defun byte-compile-emacs ()
	"A function to byte compile Emacs dir."
	(interactive)
	(byte-recompile-directory (expand-file-name "~/.emacs.d") 0))

;; exex path from shell to fix stuff with bash and shit

;; (use-package exec-path-from-shell
;;   :ensure t
;;  :init
;;  (exec-path-from-shell-initialize)
;;  )

(defun sudo-edit (&optional arg)
	"Edit currently visited file as root.

With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
	(interactive "P")
	(if (or arg (not buffer-file-name))
			(find-file (concat "/sudo:root@localhost:"
												 (ido-read-file-name "Find file(as root): ")))
		(find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

;;; unset some keys
(global-set-key (kbd "<f3>") nil)
(global-unset-key (kbd "C-z"))



;; TEXT FOLDING


(use-package hideshow
	:ensure t
	:config
	(defvar hs-special-modes-alist
	(mapcar 'purecopy
	'((c-mode "{" "}" "/[*/]" nil nil)
		(c++-mode "{" "}" "/[*/]" nil nil)
		(bibtex-mode ("@\\S(*\\(\\s(\\)" 1))
		(java-mode "{" "}" "/[*/]" nil nil)
		(js-mode "{" "}" "/[*/]" nil))))

	(define-prefix-command	'fold-prefix)

	(evil-leader/set-key "/" 'toggle-hiding)
	(add-hook 'c-mode-common-hook   'hs-minor-mode)
	(add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
	(add-hook 'java-mode-hook       'hs-minor-mode)
	(add-hook 'lisp-mode-hook       'hs-minor-mode)
	(add-hook 'perl-mode-hook       'hs-minor-mode)
	(add-hook 'sh-mode-hook         'hs-minor-mode)
	(add-hook 'csharp-mode-hook      'hs-minor-mode)
	(add-hook 'web-mode-hook         'hs-minor-mode)
	(evil-leader/set-key "2" 'fold-prefix)

	(define-key fold-prefix (kbd "t") 'toggle-hiding)
	(define-key fold-prefix (kbd "s") 'hs-show-block)
	(define-key fold-prefix (kbd "h") 'hs-hide-block)
	(define-key fold-prefix (kbd "S") 'hs-show-all)
	(define-key fold-prefix (kbd "H") 'hs-hide-all)
	(define-key fold-prefix (kbd "l") 'hs-hide-level)
	(define-key fold-prefix (kbd "L") 'hs-hide-level-recursive)


	)


;; (use-package origami
;;	:ensure t
;;	:config
;;	(define-prefix-command	'origami-prefix)
;;	(define-prefix-command	'origami-prefix-all)
;;	(define-key origami-mode-map (kbd "C-o") 'origami-prefix)
;;	(define-key origami-prefix (kbd "<tab>") 'origami-recursively-toggle-node)
;;	(define-key origami-prefix (kbd "O") 'origami-show-only-node)
;;	(define-key origami-prefix (kbd "u") 'origami-undo)
;;	(define-key origami-prefix (kbd "r") 'origami-redo)
;;	(define-key origami-prefix (kbd "s") 'origami-show-node)
;;	(define-key origami-prefix (kbd "t") 'origami-toggle-node)
;;	(define-key origami-prefix (kbd "f") 'origami-forward-toggle-node)
;;	(define-key origami-prefix (kbd "o") 'origami-open-node)
;;	(define-key origami-prefix (kbd "C-o") 'origami-open-node-recursively)
;;	(define-key origami-prefix (kbd "c") 'origami-close-node)
;;	(define-key origami-prefix (kbd "C-c") 'origami-close-node-recursively)

;;	(define-key origami-prefix (kbd "n") 'origami-next-fold)
;;	(define-key origami-prefix (kbd "C-n") 'origami-forward-next-fold)
;;	(define-key origami-prefix (kbd "M-n") 'origami-forward-fold-same-level)
;;	(define-key origami-prefix (kbd "p") 'origami-previous-fold)
;;	(define-key origami-prefix (kbd "C-p") 'origami-forward-previous-fold)
;;	(define-key origami-prefix (kbd "M-p") 'origami-backward-fold-same-level)

;;	(define-key origami-prefix (kbd "R") 'origami-reset)

;;	(define-key origami-prefix (kbd "a") 'origami-prefix-all)
;;	(define-key origami-prefix-all (kbd "o") 'origami-open-all-nodes)
;;	(define-key origami-prefix-all (kbd "c") 'origami-close-all-nodes)
;;	(define-key origami-prefix/-all (kbd "t") 'origami-toggle-all-nodes)

;;	)


;; Use ranger dired extension for best file management

(use-package ranger
	:ensure t
	:commands (deer)
	:bind (("<f3>" . deer))
	:init
	(setq
	 ranger-show-hidden nil
	 ranger-override-dired-mode t
	 ranger-cleanup-on-disable t
	 ranger-cleanup-eagerly t
	 )
	(add-hook 'ranger-mode-hook
						(lambda ()
							(local-unset-key "\C-f")
							(local-unset-key "\C-b")
							(local-unset-key "\C-h")))
	:config
	(define-key ranger-mode-map "C-f" 'nil)
	(define-key ranger-mode-map "C-h" 'nil)
	(define-key ranger-mode-map "C-b" 'nil)
	(define-key ranger-normal-mode-map "k" 'ranger-next-file)
	(define-key ranger-normal-mode-map "l" 'ranger-prev-file)
	(define-key ranger-normal-mode-map "j" 'ranger-up-directory)
	(define-key ranger-mode-map ":" ranger-dired-map)
	(define-key ranger-normal-mode-map (kbd "h") 'ranger-goto-mark)
	(define-key ranger-mode-map ";" 'ranger-find-file)
	(define-key ranger-normal-mode-map ";" 'ranger-find-file)
	(define-key ranger-mode-map (kbd "C-g") 'ranger-close)
	(define-key ranger-mode-map (kbd "<escape>") 'ranger-close)
	(define-key ranger-mode-map (kbd "<f7>") 'dired-create-directory)
	(define-key ranger-mode-map (kbd "<f8>") 'dired-do-delete)
	(define-key ranger-mode-map (kbd "cw") 'dired-do-rename)
	(define-key ranger-mode-map (kbd "cm") 'dired-do-chmod)
	(define-key ranger-mode-map (kbd "cx") 'dired-do-compress)
	)

;; let's define some ghetoo keybindings

;; (define-prefix-command	'frame-map)
(defun vmake-frame ()
	"Make an Emacs horizontal frame in i3 window manager."
	(interactive)
	(shell-command "i3-msg split v")
	(make-frame))
(defun hmake-frame ()
	"Make an Emacs horizontal frame in i3 window manager."
	(interactive)
	(shell-command "i3-msg split h")
	(make-frame))

;; override this fucking shit ESC
(define-key ctl-x-map (kbd "<ESC>" ) nil)

(define-prefix-command	'toggle-map)
(global-set-key (kbd "C-c o") 'toggle-map)
(define-key toggle-map (kbd "l") 'linum-mode)
(define-prefix-command	'fast-ex-map)
(evil-leader/set-key "x" 'fast-ex-map)
(define-key fast-ex-map (kbd "e") 'shell-other-window)

(global-set-key (kbd "C-f") 'ctl-x-5-prefix)
;;(evil-leader/set-key "f" 'ctl-x-5-prefix)
(define-key ctl-x-5-map (kbd "n") 'vmake-frame)
(define-key ctl-x-5-map (kbd "N") 'hmake-frame)
(define-key ctl-x-5-map (kbd "b") 'switch-to-buffer-other-frame)
(define-key ctl-x-5-map (kbd "o") 'delete-other-frames)
(define-key ctl-x-5-map (kbd "c") 'delete-frame)
(define-key ctl-x-5-map (kbd "f") 'find-file)
(define-key ctl-x-5-map (kbd "C-i") 'other-frame)
(global-set-key (kbd "C-c C-e") 'eval-buffer)

(define-prefix-command 'mikus-search-map)
(evil-leader/set-key "s" 'mikus-search-map)
(define-key mikus-search-map (kbd "f") 'fzf-directory)
(define-key mikus-search-map (kbd "g") 'projectile-grep)
(define-key mikus-search-map (kbd "a") 'projectile-ag)


(require 'csharp-hs-forward-sexp)

;; languages config
(use-package common-lisp-snippets
	:ensure t )
(use-package slime
	:ensure t
	:config
	(setq inferior-lisp-program "/bin/sbcl"))
(use-package cl-lib
	:ensure t)
(use-package markdown-mode
	:ensure t)



;; snippets
(use-package yasnippet
	:ensure t
	:config
	(setq yas-snippet-dirs '("~/.emacs.d/snippets")))


;; (define-prefix-command 'space-map)
;; (global-set-key (kbd "SPC") 'space-map)

(define-prefix-command 'helm-utils-map)
(evil-leader/set-key "h" 'helm-utils-map)
(define-key helm-utils-map (kbd "c") 'helm-colors)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
	 (quote
		("eecacf3fb8efc90e6f7478f6143fd168342bbfa261654a754c7d47761cec07c8" default)))
 '(delete-selection-mode nil)
 '(package-selected-packages
	 (quote
		(markdown-mode omnisharp drag-stuff linum-relative move-text emmet-mode emmet origami smerge dracula-theme slime-company slime common-lisp-snippets company-slime js-comint prettier-js help-fns+ help-mode+ zerodark-theme xterm-color xref-js2 which-key web-mode use-package tide smooth-scrolling smooth-scroll rjsx-mode restart-emacs ranger rainbow-mode nav-flash json-mode js2-refactor js-doc ivy indium hydra helm-projectile helm-ag gruvbox-theme fzf exwm exec-path-from-shell evil-visualstar evil-surround evil-snipe evil-nerd-commenter evil-matchit evil-leader editorconfig dumb-jump diminish company-tern ag ace-window))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
