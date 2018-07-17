
(use-package ivy
	:ensure t
	:bind
	(("C-c C-r" . ivy-resume)
	 ("C-x b" . ivy-switch-buffer)
	 ("C-r" . 'counsel-expression-history)
	 ("C-c q" . 'counsel-browse-kill-ring)
	 :map ivy-minibuffer-map
	 ("<escape>" . 'minibuffer-keyboard-quit))
	:config
	(ivy-mode)
	;; better performance on everything (especially windows), ivy-0.10.0 required
	;; @see https://github.com/abo-abo/swiper/issues/1218
	(setq ivy-dynamic-exhibit-delay-ms 200)

	;; Press C-p and Enter to select current input as candidate
	;; https://oremacs.com/2017/11/30/ivy-0.10.0/
	(setq ivy-use-selectable-prompt t)


	
	;; work around ivy issue.
	;; @see https://github.com/abo-abo/swiper/issues/828
	(setq ivy-display-style 'fancy)
	)




(use-package counsel
	:ensure t
	:bind
	(
	 ("C-h f" . 'counsel-describe-function)
	 ("C-h v" . 'counsel-describe-variable)
	 ("C-s" . 'swiper)
	 ("C-x C-f" . 'counsel-find-file)
	 :map read-expression-map
	 ("C-r" . 'counsel-expression-history))
	:init
	(progn
		(evil-leader/set-key
			"i" 'counsel-imenu)
		)
	:config

	;; {{ @see http://oremacs.com/2015/04/19/git-grep-ivy/
	(defun counsel-read-keyword (hint &optional default-when-no-active-region)
		(let (keyword)
			(cond
			 ((region-active-p)
				(setq keyword (counsel-unquote-regex-parens (my-selected-str)))
				;; de-select region
				(set-mark-command nil))
			 (t
				(setq keyword (if default-when-no-active-region
													default-when-no-active-region
												(read-string hint)))))
			keyword))

	(defun my-counsel-recentf (&optional n)
		"Find a file on `recentf-list'.
If N is not nil, only list files in current project."
		(interactive "P")
		(require 'recentf)
		(recentf-mode)
		(let* ((files (mapcar #'substring-no-properties recentf-list))
					 (root-dir (if (ffip-project-root) (file-truename (ffip-project-root)))))
			(when (and n root-dir)
				(setq files (delq nil (mapcar (lambda (f) (path-in-directory-p f root-dir)) files))))
			(ivy-read "Recentf: "
								files
								:initial-input (if (region-active-p) (my-selected-str))
								:action (lambda (f)
													(with-ivy-window
														(find-file f)))
								:caller 'counsel-recentf)))

	(defmacro counsel-git-grep-or-find-api (fn git-cmd hint no-keyword)
		"Apply FN on the output lines of GIT-CMD.  HINT is hint when user input.
Yank the file name at the same time.  FILTER is function to filter the collection"
		`(let* ((str (if (buffer-file-name) (file-name-base (buffer-file-name)) ""))
						(default-directory (locate-dominating-file
																default-directory ".git"))
						collection)

			 (unless ,no-keyword
				 ;; selected region contains no regular expression
				 (setq keyword (counsel-read-keyword (concat "Enter " ,hint " pattern:" ))))

			 (setq collection
						 (split-string (shell-command-to-string (if ,no-keyword ,git-cmd
																											(format ,git-cmd keyword)))
													 "\n"
													 t))
			 (cond
				((and collection (= (length collection) 1))
				 (funcall ,fn (car collection)))
				(t
				 (ivy-read (if ,no-keyword ,hint (format "matching \"%s\":" keyword))
									 collection
									 :action ,fn)))))

	(defun counsel--open-file (val)
		(let* ((lst (split-string val ":"))
					 (linenum (string-to-number (cadr lst))))
			;; open file
			(find-file (car lst))
			;; goto line if line number exists
			(when (and linenum (> linenum 0))
				(goto-char (point-min))
				(forward-line (1- linenum)))))

	;; grep by author is bad idea because it's too slow

	(defun counsel-git-show-file ()
		"Find file in HEAD commit or whose commit hash is selected region."
		(interactive)
		(counsel-git-grep-or-find-api 'find-file
																	(format "git --no-pager diff-tree --no-commit-id --name-only -r %s"
																					(counsel-read-keyword nil "HEAD"))
																	"files from `git-show' "
																	t))

	(defun counsel-git-diff-file ()
		"Find file in `git diff'."
		(interactive)
		(counsel-git-grep-or-find-api 'find-file
																	"git --no-pager diff --name-only"
																	"files from `git-diff' "
																	t))

	(defun counsel-insert-grepped-line (val)
		(let ((lst (split-string val ":")) text-line)
			;; the actual text line could contain ":"
			(setq text-line (replace-regexp-in-string (format "^%s:%s:" (car lst) (nth 1 lst)) "" val))
			;; trim the text line
			(setq text-line (replace-regexp-in-string (rx (* (any " \t\n")) eos) "" text-line))
			(kill-new text-line)
			(if insert-line (insert text-line))
			(message "line from %s:%s => kill-ring" (car lst) (nth 1 lst))))

	(defun counsel--replace-current-line (leading-spaces content)
		(beginning-of-line)
		(kill-line)
		(insert (concat leading-spaces content))
		(end-of-line))

	(defvar counsel-complete-line-use-git t)

	(defun counsel-has-quick-grep ()
		(executable-find "rg"))

	(defun counsel-find-quick-grep (&optional for-swiper)
		;; ripgrep says that "-n" is enabled actually not,
		;; so we manually add it
		(concat (executable-find "rg")
						" -n -M 128 --no-heading --color never "
						(if for-swiper "-i '%s' %s" "-s")))

	(if (counsel-has-quick-grep)
			(setq counsel-grep-base-command (counsel-find-quick-grep t)))

	(defvar counsel-my-name-regex ""
		"My name used by `counsel-git-find-my-file', support regex like '[Tt]om [Cc]hen'.")

	(defun counsel-git-find-my-file (&optional num)
		"Find my files in the current git repository.
If NUM is not nil, find files since NUM weeks ago.
Or else, find files since 24 weeks (6 months) ago."
		(interactive"P")
		(unless (and num (> num 0))
			(setq num 24))
		(let* ((cmd (concat "git log --pretty=format: --name-only --since=\""
												(number-to-string num)
												" weeks ago\" --author=\""
												counsel-my-name-regex
												"\" | grep \"%s\" | sort | uniq")))
			;; (message "cmd=%s" cmd)
			(counsel-git-grep-or-find-api 'find-file cmd "file" nil)))
	;; }}

	(defun counsel--build-bookmark-candidate (bookmark)
		(let (key)
			;; build key which will be displayed
			(cond
			 ((and (assoc 'filename bookmark) (cdr (assoc 'filename bookmark)))
				(setq key (format "%s (%s)" (car bookmark) (cdr (assoc 'filename bookmark)))))
			 ((and (assoc 'location bookmark) (cdr (assoc 'location bookmark)))
				;; bmkp-jump-w3m is from bookmark+
				(setq key (format "%s (%s)" (car bookmark) (cdr (assoc 'location bookmark)))))
			 (t
				(setq key (car bookmark))))
			;; re-shape the data so full bookmark be passed to ivy-read:action
			(cons key bookmark)))

	(defun counsel-bookmark-goto ()
		"Open ANY bookmark.  Requires bookmark+"
		(interactive)

		(unless (featurep 'bookmark)
			(require 'bookmark))
		(bookmark-maybe-load-default-file)

		(let* ((bookmarks (and (boundp 'bookmark-alist) bookmark-alist))
					 (collection (delq nil (mapcar #'counsel--build-bookmark-candidate
																				 bookmarks))))
			;; do the real thing
			(ivy-read "bookmarks:"
								collection
								:action (lambda (bookmark)
													(unless (featurep 'bookmark+)
														(require 'bookmark+))
													(bookmark-jump bookmark)))))

	(defun counsel-yank-bash-history ()
		"Yank the bash history."
		(interactive)
		(shell-command "history -r") ; reload history
		(let* ((collection
						(Nreverse
						 (split-string (with-temp-buffer
														 (insert-file-contents (file-truename "~/.bash_history"))
														 (buffer-string))
													 "\n"
													 t))))
      (ivy-read (format "Bash history:") collection
                :action (lambda (val)
                          (kill-new val)
                          (message "%s => kill-ring" val)))))

	(defun counsel-recent-directory (&optional n)
		"Goto recent directories.
If N is not nil, only list directories in current project."
		(interactive "P")
		(unless recentf-mode (recentf-mode 1))
		(let* ((cands (delete-dups
                   (append my-dired-directory-history
                           (mapcar 'file-name-directory recentf-list)
                           ;; fasd history
                           (if (executable-find "fasd")
                               (nonempty-lines (shell-command-to-string "fasd -ld"))))))
					 (root-dir (if (ffip-project-root) (file-truename (ffip-project-root)))))
			(when (and n root-dir)
				(setq cands (delq nil (mapcar (lambda (f) (path-in-directory-p f root-dir)) cands))))
			(ivy-read "directories:" cands :action 'dired)))

	(defun ivy-occur-grep-mode-hook-setup ()
		;; no syntax highlight, I only care performance when searching/replacing
		(font-lock-mode -1)
		;; @see https://emacs.stackexchange.com/questions/598/how-do-i-prevent-extremely-long-lines-making-emacs-slow
		(column-number-mode -1)
		;; turn on wgrep right now
		;; (ivy-wgrep-change-to-wgrep-mode) ; doesn't work, don't know why
		(local-set-key (kbd "RET") #'ivy-occur-press-and-switch)
		)
	(add-hook 'ivy-occur-grep-mode-hook 'ivy-occur-grep-mode-hook-setup)

	(defun counsel-git-grep-by-selected ()
		(interactive)
		(cond
		 ((region-active-p)
			(counsel-git-grep counsel-git-grep-cmd-default (my-selected-str)))
		 (t
			(counsel-git-grep))))

	(defun counsel-browse-kill-ring (&optional n)
		"Use `browse-kill-ring' if it exists and N is 1.
If N > 1, assume just yank the Nth item in `kill-ring'.
If N is nil, use `ivy-mode' to browse the `kill-ring'."
		(interactive "P")
		(my-select-from-kill-ring my-insert-str n))


	;; {{ swiper&ivy-mode
	(defun swiper-the-thing ()
		(interactive)
		;; better performance on large files than swiper
		(counsel-grep-or-swiper (my-use-selected-string-or-ask "")))


	;; @see https://oremacs.com/2015/07/23/ivy-multiaction/
	;; press "M-o" to choose ivy action

	(ivy-set-actions
	 'counsel-find-file
	 '(("j" find-file-other-frame "other frame")
		 ("b" counsel-find-file-cd-bookmark-action "cd bookmark")
		 ("x" counsel-find-file-extern "open externally")
		 ("d" delete-file "delete")
		 ("r" counsel-find-file-as-root "open as root")))


	)





(provide 'init-ivy)
