;; TODO: enhance ibuffer-fontification-alist
;;   See http://www.reddit.com/r/emacs/comments/21fjpn/fontifying_buffer_list_for_emacs_243/


(use-package fullframe
  :ensure t)

(after-load 'ibuffer
  (fullframe ibuffer ibuffer-quit))

(use-package ibuffer-vc
  :ensure t)


(defun ibuffer-set-up-preferred-filters ()
  (ibuffer-vc-set-filter-groups-by-vc-root)
  (unless (eq ibuffer-sorting-mode 'filename/process)
    (ibuffer-do-sort-by-filename/process)))

(add-hook 'ibuffer-hook 'ibuffer-set-up-preferred-filters)

(setq-default ibuffer-show-empty-filter-groups nil)


(after-load 'ibuffer
  ;; Use human readable Size column instead of original one
  (define-ibuffer-column size-h
    (:name "Size" :inline t)
    (cond
     ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
     ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
     (t (format "%8d" (buffer-size)))))

  ;; Explicitly require ibuffer-vc to get its column definitions, which
  ;; can't be autoloaded
  ;; (after-load 'ibuffer
  ;;   (require 'ibuffer-vc))

  ;; Modify the default ibuffer-formats (toggle with `)
  (setq ibuffer-formats
	'((mark modified read-only vc-status-mini " "
		(name 18 18 :left :elide)
		" "
		(size-h 9 -1 :right)
		" "
		(mode 16 16 :left :elide)
		" "
		filename-and-process)
	  (mark modified read-only vc-status-mini " "
		(name 18 18 :left :elide)
		" "
		(size-h 9 -1 :right)
		" "
		(mode 16 16 :left :elide)
		" "
		(vc-status 16 16 :left)
		" "
		filename-and-process)))


  (setq ibuffer-filter-group-name-face 'font-lock-doc-face)
  (global-set-key (kbd "C-x C-b") 'ibuffer)

  (evil-set-initial-state 'ibuffer-mode 'normal)

  (general-define-key
   :keymaps 'ibuffer-mode-map
   :states 'normal
   "k" 'evil-next-line
   "j" 'evil-backward-char
   ";" 'evil-forward-char
   "l" 'evil-previous-line
   "gg" 'evil-goto-first-line
   )

  (general-define-key
   :keymaps 'ibuffer-mode-map
   "C-l" nil
   "C-k" nil)
  
  )



(provide 'init-ibuffer)
