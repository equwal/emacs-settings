;;; Package --- Common settings for development environments

;;; Commentary:

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                          Company                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package company
  :ensure

  :preface
  (defun complete-or-indent ()
	"Complete using company-mode or indent current line by checking "
	(interactive)
	(cond
	 ;; When in region, indent the region.
	 ((use-region-p)
	  (indent-region (region-beginning) (region-end)))
	 ;; When yasnippet is active, move to next field.
	 ((yas-active-snippets)
	  (yas-next-field))
	 ;; When it is possible to complete, do it.
	 ((and (string-match-p company-begin-regex (char-to-string (char-before)))
           (call-when-defined 'company-manual-begin))
	  (call-when-defined 'company-complete-common))
	 (t (indent-for-tab-command))))

  :init
  ;; Make company mode complete immediately.
  (setq company-idle-delay 0)
  ;; Make it possible to select item before first or after last wraps around.
  (setq company-selection-wrap-around t)

  ;; Regex to match whether to complete.
  (defcustom company-begin-regex "[0-9a-zA-Z_.>:-]"
	"Used by function `complete-or-indent' to decide whether or not to start
completion."
	:type 'string
	:group 'none
	:safe t)  
    
  :bind (:map company-active-map
			  ("C-n" . company-select-next)
			  ("C-p" . company-select-previous))

  :bind (:map company-mode-map
  			  ("<tab>" . complete-or-indent))

  :config
  ;; Remove unused backends.
  (dolist (target-backend '(company-semantic company-clang))
	(dolist (backend company-backends)
	  (let ((main-backend (if (listp backend)
							  (car backend)
							backend)))
		(when (equal main-backend target-backend)
		  (delete backend company-backends)))))

  ;; Combine capf and dabbrev-code backends.
  (delete 'company-capf company-backends)
  (dolist (backend company-backends)
	(when (and (listp backend)
			   (eql 'company-dabbrev-code (car backend)))
	  (let ((original-backends (cl-copy-list backend)))
		(setcar backend 'company-capf)
		(setcdr backend original-backends))))

  ;; Setup yasnippet backend for company mode.
  (defun company-mode-setup-yasnippet-backend ()
	"Setup yasnippet source for company-mode backends."
	(setq company-backends
		  (mapcar (lambda (backend)
					(if (and (listp backend)
							 (member 'company-yasnippet backend))
						backend
					  (append (if (consp backend) backend (list backend))
							  '(:with company-yasnippet))))
				  company-backends)))

  (company-mode-setup-yasnippet-backend)

  :hook
  ;; Enable company-mode for all programming languages.
  (prog-mode . company-mode))

(use-package company-quickhelp
  :ensure
  :init
  (setq company-quickhelp-delay 0)

  :config
  (call-when-defined 'company-quickhelp-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                         projectile                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package projectile
  :ensure
  :init
  ;; Offline SVN.
  (setq projectile-svn-command "find . -type f -not -iwholename '*.svn/*' -print0")

  :config
  (call-when-defined 'projectile-mode 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                          Yasnippet                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package yasnippet
  :ensure
  :init
  (setq yas-snippet-dirs (list (concat *data-path* "yasnippets")))

  :bind
  (:map yas-keymap
        ("<tab>" . nil))

  :config
  (call-when-defined 'yas-global-mode 1))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                        Syntax Checking                       ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flycheck
  :ensure
  :config
  (call-when-defined 'global-flycheck-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                        Spell Checking                        ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package flyspell
  :ensure
  :config
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                           ggtags                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package ggtags
  :ensure
  :init
  (add-hook 'prog-mode-hook 'ggtags-mode)

  :bind
  ;; Stop messing up my key bindings!
  (:map ggtags-navigation-map
		("M-o" . nil)
		("M->" . nil)
		("M-<" . nil)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                        Indentation                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package highlight-indent-guides
  :ensure
  :config
  (setq highlight-indent-guides-method 'character)
  ;; Set how obvious the indicator character is. Higher, more obvious.
  (setq highlight-indent-guides-auto-character-face-perc 10)

  :hook
  (prog-mode . highlight-indent-guides-mode))

(use-package fill-column-indicator
  :ensure
  :after company

  :preface
  (defvar-local company-fci-mode-on-p nil
    "Used by hack between company-mode and fci-mode inside dev-common.el")

  (defun company-turn-off-fci (&rest ignore)
    (when (boundp 'fci-mode)
      (setq company-fci-mode-on-p fci-mode)
      (when fci-mode (call-when-defined 'fci-mode -1))))

  (defun company-maybe-turn-on-fci (&rest ignore)
    (when company-fci-mode-on-p (call-when-defined 'fci-mode 1)))

  :init
  (setq-default fill-column 79)
  ;; Do not truncate long lines.
  (setq fci-handle-truncate-lines nil)

  :hook
  (company-completion-started . company-turn-off-fci)
  (company-completion-finished . company-maybe-turn-on-fci)
  (company-completion-cancelled . company-maybe-turn-on-fci))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                         HS Mode                              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'hideshow)
(use-package hideshow
  :ensure
  
  :hook
  (prog-mode . hs-minor-mode)
  
  :bind
  (:map hs-minor-mode-map
        ("C-c i s" . hs-show-all)
        ("C-c i h" . hs-hide-all)
        ("C-c i i" . hs-toggle-hiding)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                            Misc                              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package prog-mode
  :bind
  (:map prog-mode-map
        ("<return>" . newline-smart-comment)))


;;; d1-dev-common.el ends here
