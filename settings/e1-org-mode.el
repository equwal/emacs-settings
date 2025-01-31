;;; Package --- Settings for Org Mode

;;; Commentary:

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                        Customization                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'org)
(require 'org-agenda)

;; Set the default directory for all notes.
(setq org-directory "~/notes/")

;; Default table size.
(setq org-table-default-size "2x2")

;; Show everything on startup.
(setq org-startup-folded nil)

;; Do indenting during start-up.
(setq org-startup-indented t)

;; Fontify code blocks.
(setq org-src-fontify-natively t)

;; Don't show all the leading stars.
(setq org-hide-leading-stars t)

;; Set the format of captured email link.
(setq org-email-link-description-format "Email: %s")

;; Enable bold, italic etc inside Chinese context.
(setf (nth 0 org-emphasis-regexp-components)
      "-[:space:]('\"{[:multibyte:]")
(setf (nth 1 org-emphasis-regexp-components)
      "-[:space:].,:!?;'\")}\\[[:multibyte:]")
(org-set-emph-re 'org-emphasis-regexp-components
                 org-emphasis-regexp-components)

;; Always insert a new line before new item.
(setq org-blank-before-new-entry '((heading . t)
                                   (plain-list-item . auto)))

(defun org-mode-hook-function ()
  "Setup."
  (toggle-word-wrap 1)
  (toggle-truncate-lines 0)
  
  (make-local-variable 'company-backends)
  (setq company-backends '((company-dabbrev :with company-yasnippet)))

  (make-local-variable 'company-idle-delay)
  (setq company-idle-delay 0.5)

  (setq fill-column 78))
(add-hook 'org-mode-hook 'org-mode-hook-function)
(add-hook 'org-mode-hook 'flyspell-mode)
(add-hook 'org-mode-hook 'auto-fill-mode)

;; Some hot keys.
(define-key org-mode-map (kbd "C-'") nil)
(define-key org-mode-map (kbd "M-q") 'org-fill-paragraph)
(define-key org-mode-map (kbd "C-c C-,") 'org-promote-subtree)
(define-key org-mode-map (kbd "C-c C-.") 'org-demote-subtree)
(define-key org-mode-map (kbd "C-c C-l") 'org-toggle-link-display)
(define-key org-mode-map (kbd "C-c C-i") 'org-mark-ring-goto)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                          Modules                             ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Org modules loaded with org mode itself
(setq org-modules
      '(org-notmuch org-bbdb org-habit org-bibtex org-docview org-info))

(use-package org-bullets
  :ensure
  :init
  (add-hook 'org-mode-hook 'org-bullets-mode))

(use-package org-habit
  :ensure org-plus-contrib

  :init
  ;; Habit tracking
  (require 'org-habit)
  ;; Do not spam my timeline with it.
  (setq org-habit-show-habits-only-for-today t)
  ;; Show my habits no matter whether it is scheduled today.
  (setq org-habit-show-all-today t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                       Localization                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Display org in a bigger calendar!
(use-package calfw-org
  :ensure)

;; Chinese localization
(use-package cal-china-x
  :ensure)

;; Use Chinese month name.
(setq calendar-month-name-array
      ["一月" "二月" "三月" "四月" "五月" "六月"
       "七月" "八月" "九月" "十月" "十一月" "十二月"])
;; Use Chinese weekday name.
(setq calendar-day-name-array
      ["日" "一" "二" "三" "四" "五" "六"])
;; Use Monday as the first day of week.
(setq calendar-week-start-day 0)

;; Holidays
(setq calendar-holidays
      '(;;公历节日
        (holiday-fixed 1 1 "元旦")
        (holiday-fixed 2 14 "情人节")
        (holiday-fixed 3 8 "妇女节")
        (holiday-fixed 5 1 "劳动节")
        (holiday-float 5 0 2 "母亲节")
        (holiday-fixed 6 1 "儿童节")
        (holiday-float 6 0 3 "父亲节")
        (holiday-fixed 9 10 "教师节")
        (holiday-fixed 10 1 "国庆节")
        (holiday-fixed 12 25 "圣诞节")
        ;; 农历节日
        (holiday-lunar 12 30 "年三十" 0)
        (holiday-lunar 1 1 "春节" 0)
        (holiday-lunar 1 15 "元宵节" 0)
        (holiday-solar-term "清明" "清明节")
        (holiday-lunar 5 5 "端午节" 0)
        (holiday-lunar 8 15 "中秋节" 0)))

;; Key bindings for calendar.
(define-key calendar-mode-map (kbd "M-f") 'calendar-forward-month)
(define-key calendar-mode-map (kbd "M-b") 'calendar-backward-month)
(global-set-key (kbd "C-c O") 'calendar)
(global-set-key (kbd "C-c o") 'cfw:open-org-calendar)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                            Export                            ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Get rid of the foot detail while generating HTML.
(setq org-html-postamble nil)

;; Set the extra CSS for exported HTML files.
(setq org-html-head-extra
      "
<style type=\"text/css\">
:not(pre) > code {
  background: #d4d3d3; border-radius: 2px; padding: 2px
}​
</style>
")

;; Enable Markdown export.
(require 'ox-md)

;; Read ATTR_* for images.
(setq org-image-actual-width nil)

(defun org-inline-style-file (exporter)
  "Embed CSS file indicated by INLINE_STYLE into generated HTML file.
EXPORTER is provided by Org Mode."
  (when (eq exporter 'html)
	(let ((content (buffer-string))
		  (start 0))
	  ;; match
	  (while (setq start
                   (string-match "^.+INLINE_STYLE.*:.*\.css$" content start))
		(incf start)
		(let ((filename (second (split-string (match-string 0 content)
                                              ":" t " "))))
		  (if (file-exists-p filename)
			  (setq org-html-head (concat
								   "<style type=\"text/css\">\n"
								   "<!--/*--><![CDATA[/*><!--*/\n"
								   (with-temp-buffer
									 (insert-file-contents filename)
									 (buffer-string))
								   "/*]]>*/-->\n"
								   "</style>\n"))
			(message "Style file \"%s\" does not exist" filename)))))))

(add-hook 'org-export-before-processing-hook 'org-inline-style-file)

(use-package htmlize
  :ensure
  :defer t
  :config
  (progn
    ;; It is required to disable `fci-mode' when `htmlize-buffer' is called;
    ;; otherwise the invisible fci characters show up as funky looking
    ;; visible characters in the source code blocks in the html file.
    ;; http://lists.gnu.org/archive/html/emacs-orgmode/2014-09/msg00777.html
    (with-eval-after-load 'fill-column-indicator
      (defvar modi/htmlize-initial-fci-state nil
        "Variable to store the state of `fci-mode' when `htmlize-buffer' is called.")

      (defun modi/htmlize-before-hook-fci-disable ()
        (setq modi/htmlize-initial-fci-state fci-mode)
        (when fci-mode
          (fci-mode -1)))

      (defun modi/htmlize-after-hook-fci-enable-maybe ()
        (when modi/htmlize-initial-fci-state
          (fci-mode 1)))

      (add-hook 'htmlize-before-hook #'modi/htmlize-before-hook-fci-disable)
      (add-hook 'htmlize-after-hook #'modi/htmlize-after-hook-fci-enable-maybe))

    ;; `flyspell-mode' also has to be disabled because depending on the
    ;; theme, the squiggly underlines can either show up in the html file
    ;; or cause elisp errors like:
    ;; (wrong-type-argument number-or-marker-p (nil . 100))
    (with-eval-after-load 'flyspell
      (defvar modi/htmlize-initial-flyspell-state nil
        "Variable to store the state of `flyspell-mode' when `htmlize-buffer' is called.")

      (defun modi/htmlize-before-hook-flyspell-disable ()
        (setq modi/htmlize-initial-flyspell-state flyspell-mode)
        (when flyspell-mode
          (flyspell-mode -1)))

      (defun modi/htmlize-after-hook-flyspell-enable-maybe ()
        (when modi/htmlize-initial-flyspell-state
          (flyspell-mode 1)))

      (add-hook 'htmlize-before-hook #'modi/htmlize-before-hook-flyspell-disable)
      (add-hook 'htmlize-after-hook #'modi/htmlize-after-hook-flyspell-enable-maybe))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                           Journal                            ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-journal
  :ensure
  :init
  ;; Set root directory.
  (setq org-journal-dir
        (concat org-directory "journal/"))
  ;; Set file format.
  (setq org-journal-file-format "%Y-%m-%d.org")
  ;; Set format of title in each journal file.
  (setq org-journal-date-format "%Y-%m-%d (%A)")
  ;; Use find-file in order to open new journal file in current window.
  (setq org-journal-find-file 'find-file)
  ;; Automatically adds current and future journals to agenda.
  (setq org-journal-enable-agenda-integration t)
  ;; Automatically carry over TODO items.
  (setq org-journal-carryover-items "TODO=\"TODO\"|TODO=\"HOLD\"")
  
  :bind
  ("C-c C-j" . nil)
  ("C-c j s" . org-journal-search)
  ("C-c j j" . org-journal-new-entry)
  ("C-c j k" . org-journal-new-scheduled-entry)
  ("C-c j v" . org-journal-schedule-view))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                          Workflow                            ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'org-depend)

;; Keep track of done things.
(setq org-log-done 'time)
;; Keep the task dependency.
(setq org-enforce-todo-dependencies t)
;; Archive to "archive.org" file.
(setq org-archive-location
      (format "%s/archive.org::" org-directory))
;; Record clock information of both running and history clocks.
(setq org-clock-persist t)
(org-clock-persistence-insinuate)

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c k") 'org-capture)
(global-set-key (kbd "C-c l l") 'org-store-link)
(global-set-key (kbd "C-c l i") 'org-insert-link)

(setq org-todo-keywords
      '((sequence "TODO(t)" "HOLD(h@/!)" "PROJ" "|"
                  "DONE(d@/!)" "STOP(s@/!)")))

(setq org-todo-keyword-faces
      '(("PROJ" :foreground "tomato" :weight bold)
        ("TODO" . org-todo)
        ("HOLD" :foreground "purple" :weight bold)
        ("DONE" . org-done)
        ("STOP" :foreground "DarkGreen" :weight bold)))

(setq org-tag-persistent-alist
      '((:startgroup . nil)
        ("feature" . ?f) ("bug" . ?b) ("enhancement" . ?e)
        (:endgroup . nil)
        (:startgroup . nil)
        ("@work" . ?w) ("@home" . ?h) ("@outside" . ?o)
        (:endgroup . nil)))

(setq org-refile-targets
      '((org-agenda-files :level . 1)))

;; Just let me refile!
(setq org-outline-path-complete-in-steps nil)
(setq org-refile-use-outline-path 'file)

;; Set templates:
;; (KEYS DESCRIPTION TYPE TARGET TEMPLATE PROPERTIES)
;; TYPE: entry item checkitem table-line plain
;; TARGET: file id file+headline
(setq org-capture-templates
      `(("k" "Capture" entry
         (file "capture.org") "* %?\n"
         :empty-lines 1)
        ("K" "Kill Ring" entry
         (file "capture.org") "* %c\n"
         :empty-lines 1)
        ("t" "TODO" entry
         (file "capture.org") "* TODO %?\n"
         :empty-lines 1)))

(setq org-agenda-sorting-strategy
      '((category-keep agenda habit-down time-up priority-down)
        (category-keep todo priority-down)
        (category-keep tags priority-down)
        (search category-keep)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                           Pomodoro                           ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package org-pomodoro
  :ensure

  :init
  ;; Length of pomodoro cycle.
  (setq org-pomodoro-length 25)
  ;; Length of pomodoro short break.
  (setq org-pomodoro-short-break-length 5)

  :bind
  (:map org-agenda-mode-map
        ("i" . org-pomodoro)
        ("I" . org-agenda-clock-in)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;                         Super Agenda                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Days to show in agenda view.
(setq org-agenda-span 'week)
;; Always start on today in agenda.
(setq org-agenda-start-on-weekday nil)
;; Display agenda in the other window.
(setq org-agenda-window-setup 'current-window)
;; Do not restore the window config after displaying agenda.
(setq org-agenda-restore-windows-after-quit nil)
;; Do not show scheduled and deadline of finished items.
(setq org-agenda-skip-scheduled-if-done t
      org-agenda-skip-deadline-if-done t)
;; Set it to NIL because super-agenda is used.
(setq org-agenda-todo-ignore-scheduled nil)

(use-package org-super-agenda
  :ensure
  :init
  (call-when-defined 'org-super-agenda-mode 1)

  ;; Set the separator between blocks.
  (setq org-super-agenda-header-separator "\n●")

  (setq org-agenda-custom-commands
        `(("n" "Super Agenda"
           ((agenda "" nil)
            (todo "HOLD"
                  ((org-agenda-overriding-header "On Hold")))
            (todo "PROJ"
                  ((org-agenda-overriding-header "Projects")))
            (todo ""
                  ((org-agenda-overriding-header "TASKS")
                   (org-super-agenda-groups
                    '((:discard (:scheduled t))
                      (:discard (:todo "HOLD"))
                      (:discard (:todo "PROJ"))
                      (:discard (:tag "capture"))
                      (:discard (:tag "someday"))
                      (:name "Projects"
                             :auto-parent)
                      (:name "Priority"
                             :auto-priority)))))
            (tags "capture"
                  ((org-agenda-overriding-header "INBOX")
                   (org-super-agenda-groups
                    '((:name "Capture"
                             :tag "capture")))))))

          ("u" "Scheduled Tasks"
           ((todo ""
                  ((org-super-agenda-groups
                    '((:name "Scheduled Tasks"
                             :scheduled t)
                      (:discard (:not (:scheduled t))))))))))))
  
;;; e1-org-mode.el ends here
