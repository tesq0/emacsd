
;; magit package

(use-package magit
	:ensure t
	:init
	(progn

		(define-prefix-command 'mikus-magit-map)
		(define-prefix-command 'mikus-magit-blame-map)

		(defun setup-default-blame-style (type)
			(setq-local magit-blame--style (cadr magit-blame-styles))
			)
		(advice-add 'magit-blame--pre-blame-setup :before #'setup-default-blame-style)

		(general-define-key
		 :keymaps 'mikus-magit-blame-map
		 "C-S-c" 'magit-blame-copy-hash
		 "b" 'magit-blame
		 "B" 'magit-blame-popup
		 "n" 'magit-blame-next-chunk
		 "N" 'magit-blame-next-chunk-same-commit
		 "p" 'magit-blame-previous-chunk
		 "P" 'magit-blame-previous-chunk-same-commit
		 "r" 'magit-blame-removal
		 "f" 'magit-blame-reverse
		 "s" 'magit-blame-cycle-style
		 "c" 'magit-blame-show-commit
		 "q" 'magit-blame-quit
		 )
		(general-define-key
			:keymaps 'mikus-magit-map
			"g" 'magit-status
			"b" 'mikus-magit-blame-map)
		)
	:config
	(define-key magit-mode-map (kbd "<escape>") 'magit-mode-bury-buffer)
	(define-key magit-mode-map (kbd "C-g") 'magit-mode-bury-buffer)
	;; SMERGE
	(define-key smerge-mode-map (kbd "C-c m") (lookup-key smerge-mode-map (kbd "C-c ^")))
	)

(provide 'init-magit)