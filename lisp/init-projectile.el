(use-package counsel-projectile
	:ensure t
	:init
	(progn
		(counsel-projectile-mode)
		(setq projectile-indexing-method 'alien)
		(define-prefix-command 'mikus-search-map)
		(mikus-leader
		 :states 'normal
		 :keymaps 'override
		 "s" 'mikus-search-map
		 )
		(general-define-key
		 :keymaps 'mikus-search-map
		 "f" 'fzf-directory
		 "g" 'projectile-grep
		 "a" 'projectile-ag)
		)
	)

(provide 'init-projectile)