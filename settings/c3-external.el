;;; Package --- Functions with external programs

;;; Commentary:

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                             emms                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package emms
  :ensure
  :init
  (require 'emms-setup)

  ;; Set players.
  (emms-all)
  (emms-default-players)

  ;; Show info at mode-line.
  (require 'emms-mode-line)
  (emms-mode-line 1)

  ;; Show time of music.
  (require 'emms-playing-time)
  (emms-playing-time 1)

  ;; Auto identify encode.
  (require 'emms-i18n)

  ;; Do NOT save and import playlist automatically.
  ;; WARNING! It will make Emacs slow.
  ;; (require 'emms-history)
  ;; (emms-history-load)

  ;; Don't repeat playlist.
  (setq emms-repeat-playlist nil)
  ;; Set default music directory.
  (setq emms-source-file-default-directory "~/music")

  :bind
  ("C-c e g" . emms-play-directory)
  ("C-c e e" . emms-play-file)

  ("C-c e d" . emms-play-dired)
  ("C-c e f" . emms-shuffle)
  ("C-c e l" . emms-playlist-mode-go)
  ("C-c e x" . emms-start)
  ("C-c e SPC" . emms-pause)
  ("C-c e s" . emms-stop)
  ("C-c e n" . emms-next)
  ("C-c e p" . emms-previous))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                         Dictionary                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(cond
 ((executable-find "sdcv")
  (use-package sdcv
	:bind ("C-c d" . sdcv-search-input)))
 ((executable-find "ydcv")
  (use-package youdao-dictionary
	:bind
    ("C-c d" . youdao-dictionary-search-from-input))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                          Image+                              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Image processing
(when (executable-find "convert")
  :ensure
  (use-package image+
	:init
	(add-hook 'after-init-hook 'imagex-global-sticky-mode)
    ;; Stop showing annoying warnings.
    (setq imagex-quiet-error t)
    ;; Use feh to view image externally.
    (setq image-dired-external-viewer "feh")

	(defun image-rotate-original (degree)
	  "Rotate original image file with given DEGREE."
	  (interactive)
	  (let ((file (buffer-file-name)))
		(shell-command
		 (format "convert -rotate %d \"%s\" \"%s\"" degree file file)))
	  (revert-buffer nil t)
	  (message "Image rotated."))

	(defun image-rotate-original-left ()
	  (interactive)
	  (image-rotate-original 270))

	(defun image-rotate-original-right ()
	  (interactive)
	  (image-rotate-original 90))

	(defun image-delete-original-file ()
	  "Delete original file from disk."
	  (interactive)
	  (if (yes-or-no-p "File will be deleted forever. Continue? ")
		  (let ((file-to-delete (buffer-file-name)))
			(image-next-file)
			(delete-file file-to-delete)
			(message "File deleted."))
		(message "Aborted.")))

	:bind
    (:map image-mode-map
          ("=" . imagex-sticky-zoom-in)
          ("-" . imagex-sticky-zoom-out)
          ("o" . imagex-sticky-restore-original)
          ("m" . imagex-sticky-maximize)
          ("D" . image-delete-original-file)
          ("r" . imagex-sticky-rotate-right)
          ("R" . image-rotate-original-right)
          ("l" . imagex-sticky-rotate-left)
          ("L" . image-rotate-original-left)
          ("S" . imagex-sticky-save-image))
	
	:config
	(add-hook 'imagex-sticky-mode-hook 'imagex-auto-adjust-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                         Silver Brain                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(add-to-list 'load-path "~/.silver-brain/emacs/")
(use-package silver-brain
  :init
  (setq silver-brain-server-port 5000)

  :bind
  ("C-c b" . silver-brain))

;;; c3-external.el ends here
