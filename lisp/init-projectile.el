(use-package helm-projectile
	:ensure t
	:diminish
	:init
	(progn
	(projectile-mode)
	(helm-projectile-on)
	(define-key projectile-command-map (kbd "<ESC>") nil)
	(setq projectile-indexing-method 'hybrid)
	(setq projectile-globally-ignored-file-suffixes  '("png" "unity" "tga" "psd" "anim" "prefab" "mat" "meta"))
	(setq grep-find-ignored-files (append grep-find-ignored-files '("*.meta" "*.png" "*.unity" "*.tga" "*.psd" "*.anim" "*.prefab" "*.mat")))
	(define-prefix-command 'mikus-search-map)
	(general-define-key
	 :keymaps 'projectile-command-map
	 "ESC" 'keyboard-quit
	 "<tab>" 'projectile-project-buffers-other-buffer)
	(mikus-leader
		:states 'normal
		:keymaps 'override
		"s" 'mikus-search-map
		)
	(general-define-key
	 :keymaps 'projectile-command-map
	 "R" 'projectile-regenerate-tags-async)
	(general-define-key
	 :keymaps 'mikus-search-map
	 "f" 'fzf-directory
	 "g" 'helm-grep-do-git-grep
	 "a" 'projectile-ag)
		)
	(setq projectile-tags-backend '(etags-select))
	)

(use-package imenu-anywhere
	:ensure t
	:init
	(progn
	(mikus-leader
		:states 'normal
		:keymaps 'override
		"I" 'imenu-anywhere)))

;; (use-package persp-mode-projectile-bridge
;; 	:ensure t
;; 	:init
;; 	(progn
;; 		(message "best persp mode")
;; 		(persp-mode 1)
;; 		(persp-mode-projectile-bridge-mode 1)))

;;;###autoload
(defun projectile-regenerate-tags-async ()
	"Regenerate the project's [e|g]tags."
	(interactive)
	(if (and (boundp 'ggtags-mode)
					 (memq projectile-tags-backend '(auto ggtags)))
			(progn
				(let* ((ggtags-project-root (projectile-project-root))
							 (default-directory ggtags-project-root))
					(ggtags-ensure-project)
					(async-start
					 (ggtags-update-tags t)
					 (lambda (result)
						 (message "done generating gtags: %s" result)))))

		(let* ((project-root (projectile-project-root))
					 (tags-exclude (projectile-tags-exclude-patterns))
					 (default-directory project-root)
           (tags-file (expand-file-name projectile-tags-file-name))
           (command (format projectile-tags-command tags-file tags-exclude default-directory)))
			(message "regenerate tags command: %s" command)
			(async-shell-command command))))

(provide 'init-projectile)
