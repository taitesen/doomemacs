
;;; setting theme-----------------------------------------------------------------------------------------
(setq doom-theme 'black)
;;;----------------------------------------------------------------------------------------- setting theme

;; relative line number ----------------------------------------------------------------------------------
(setq display-line-numbers-type 'relative)
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))
;; ---------------------------------------------------------------------------------- relative line number

;; font --------------------------------------------------------------------------------------------------
(setq doom-font (font-spec :family "RobotoMono Nerd Font" :size 24 :weight 'light)
      doom-variable-pitch-font (font-spec :family "Visomatic_Electrite") ; inherits `doom-font''s :size
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono" :size 24)
      doom-big-font (font-spec :family "Open Sans" :size 30))

;;--------------------------------------------------------------------------------------------------- font

;; transparency ------------------------------------------------------------------------------------------
(unless (string= "" (shell-command-to-string "pgrep dwm"))
  (set-frame-parameter (selected-frame) 'alpha-background 90)
  (add-to-list 'default-frame-alist '(alpha-background . 90)))
;; ------------------------------------------------------------------------------------------ transparency

;;; clangd config ----------------------------------------------------------------------------------------
(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("-j=3"
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 2))

;;;------------------------------------------------------------------------------------------ clangd config



;;; eglog config ------------------------------------------------------------------------------------------

(after! cc-mode
  (set-eglot-client! 'cc-mode '("clangd" "-j=3" "--clang-tidy")))

;;;------------------------------------------------------------------------------------------- eglog config



;;; marginalia --------------------------------------------------------------------------------------------
(after! marginalia
  (setq marginalia-censor-variables nil)

  (defadvice! +marginalia--anotate-local-file-colorful (cand)
    "Just a more colourful version of `marginalia--anotate-local-file'."
    :override #'marginalia--annotate-local-file
    (when-let (attrs (file-attributes (substitute-in-file-name
                                       (marginalia--full-candidate cand))
                                      'integer))
      (marginalia--fields
       ((marginalia--file-owner attrs)
        :width 12 :face 'marginalia-file-owner)
       ((marginalia--file-modes attrs))
       ((+marginalia-file-size-colorful (file-attribute-size attrs))
        :width 7)
       ((+marginalia--time-colorful (file-attribute-modification-time attrs))
        :width 12))))

  (defun +marginalia--time-colorful (time)
    (let* ((seconds (float-time (time-subtract (current-time) time)))
           (color (doom-blend
                   (face-attribute 'marginalia-date :foreground nil t)
                   (face-attribute 'marginalia-documentation :foreground nil t)
                   (/ 1.0 (log (+ 3 (/ (+ 1 seconds) 345600.0)))))))
      ;; 1 - log(3 + 1/(days + 1)) % grey
      (propertize (marginalia--time time) 'face (list :foreground color))))

  (defun +marginalia-file-size-colorful (size)
    (let* ((size-index (/ (log (+ 1 size)) 7.0))
           (color (if (< size-index 10000000) ; 10m
                      (doom-blend 'orange 'green size-index)
                    (doom-blend 'red 'orange (- size-index 1)))))
      (propertize (file-size-human-readable size) 'face (list :foreground color)))))
;;; -------------------------------------------------------------------------------------------- marginalia

;;; dashboard ---------------------------------------------------------------------------------------------
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-footer)
(setq +doom-dashboard-banner-file (expand-file-name "images/doom.png" doom-user-dir))
;;; --------------------------------------------------------------------------------------------- dashboard

;;; modeline ----------------------------------------------------------------------------------------------
(after! doom-modeline
  (setq auto-revert-check-vc-info t
        doom-modeline-major-mode-icon t
        doom-modeline-buffer-file-name-style 'relative-to-project
        doom-modeline-github nil
        doom-modeline-height 50
        doom-modeline-bar-width 4
        doom-modeline-window-width-limit 80
        doom-modeline-vcs-max-length 60)
  (remove-hook 'doom-modeline-mode-hook #'size-indication-mode)
  (doom-modeline-def-modeline 'main
    '(matches bar modals workspace-name window-number persp-name selection-info buffer-info remote-host debug vcs matches)
    '(github mu4e grip gnus check misc-info repl lsp " ")))
;;; ---------------------------------------------------------------------------------------------------------------modeline

;;; org mode --------------------------------------------------------------------------------------------------------------

;; Set org directory and agenda files
(setq org-directory "~/org/"
      org-agenda-files '("~/org/Home.org" "~/org/Work.org" "~/org/Notes.org"))

;; Configure org-mode
(after! org
  (setq org-todo-keywords
        '((sequence "TODO(t)" "INPROG(i)" "PROJ(p)" "STORY(s)" "WAIT(w@/!)" "|" "DONE(d@/!)" "KILL(k@/!)")
          (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))

  (setq org-todo-state-tags-triggers
        '(("KILL" ("killed" . t))
          ("HOLD" ("hold" . t))
          ("WAIT" ("waiting" . t))
          (done ("waiting") ("hold"))
          ("TODO" ("waiting") ("cancelled") ("hold"))
          ("NEXT" ("waiting") ("cancelled") ("hold"))
          ("DONE" ("waiting") ("cancelled") ("hold"))))

  ;; Additional org settings
  (setq org-ellipsis " ▾"
        org-use-property-inheritance t
        org-agenda-start-with-log-mode t
        org-log-done 'time
        org-log-into-drawer t
        org-cycle-emulate-tab nil
        org-startup-folded 'content
        org-startup-with-inline-images t
        org-image-actual-width 600))

;; Configure org-appear
(use-package! org-appear
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autolinks t
        org-appear-autosubmarkers t))

;; Configure org-superstar
(use-package! org-superstar
  :hook (org-mode . org-superstar-mode)
  :config
  (setq org-superstar-headline-bullets-list '(("◉" "○" "●" "○" "●" "○" "●"))
        org-superstar-item-bullet-alist '((?* . ?⋆)
                                          (?+ . ?‣)
                                          (?- . ?•))))

;; Configure toc-org
(use-package! toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

;; Configure mixed-pitch-mode
(setq +zen-mixed-pitch-modes '(org-mode LaTeX-mode markdown-mode gfm-mode Info-mode rst-mode adoc-mode))
(dolist (mode +zen-mixed-pitch-modes)
  (add-hook (intern (concat (symbol-name mode) "-hook")) #'mixed-pitch-mode))

;; Configure prettify-symbols for org-mode
(add-hook 'org-mode-hook
          (lambda ()
            (setq prettify-symbols-alist
                  '(("#+end_quote" . "‟")
                    ("#+END_QUOTE" . "‟")
                    ("#+begin_quote" . "„")
                    ("#+BEGIN_QUOTE" . "„")
                    ("#+end_src" . "»")
                    ("#+END_SRC" . "»")
                    ("#+begin_src" . "«")
                    ("#+BEGIN_SRC" . "«")
                    ("#+name:" . "☙")
                    ("#+NAME:" . "☙")))
            (prettify-symbols-mode)))

;;; ---------------------------------------------------------------------------------------------------------------org mode

;; something like zen mode in org mode ------------------------------------------------------------------------------------
(use-package! visual-fill-column
  :custom
  (visual-fill-column-width 100)
  (visual-fill-column-center-text t)
  :hook (org-mode . visual-fill-column-mode))
;; ------------------------------------------------------------------------------------ something like zen mode in org mode


;; font setup for org mode ------------------------------------------------------------------------------------------------
(defun taitesen/org-font-setup ()
  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.5)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Inconsolata Nerd Font Propo" :weight 'regular :height (cdr face) :slant 'unspecified))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-tag nil :foreground nil :inherit '(shadow fixed-pitch) :weight 'bold)
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))
;; ------------------------------------------------------------------------------------------------ font setup for org mode


;; Mode to enable org mode ------------------------------------------------------------------------------------------------
(defun taitesen/org-setup-hook ()
  "Modes to enable on org-mode start"
  (org-indent-mode)
  (visual-line-mode 1)
  (+org-pretty-mode)
  (taitesen/org-font-setup))

(add-hook! org-mode #'taitesen/org-setup-hook)

;; ------------------------------------------------------------------------------------------------ Mode to enable org mode

;; vertico ----------------------------------------------------------------------------------------------------------------
(after! vertico
  (setq vertico-count 5))
;; ---------------------------------------------------------------------------------------------------------------- vertico

;; Padding ----------------------------------------------------------------------------------------------------------------
(use-package spacious-padding
  :ensure t
  :if (display-graphic-p)
  :hook (after-init . spacious-padding-mode)
  :bind ("<f8>" . spacious-padding-mode)
  :init
  ;; These are the defaults, but I keep it here for visiibility.
  (setq spacious-padding-widths
        '( :internal-border-width 30
           :header-line-width 4
           :mode-line-width 6
           :tab-width 4
           :right-divider-width 30
           :scroll-bar-width 8
           :left-fringe-width 20
           :right-fringe-width 20))

  ;; (setq spacious-padding-subtle-mode-line
  ;;       `( :mode-line-active ,(if (or (eq prot-emacs-load-theme-family 'modus)
  ;;                                     (eq prot-emacs-load-theme-family 'standard))
  ;;                                 'default
  ;;                               'help-key-binding)
  ;;          :mode-line-inactive window-divider))

  ;; Read the doc string of `spacious-padding-subtle-mode-line' as
  ;; it is very flexible.
  (setq spacious-padding-subtle-mode-line nil))
;; ------------------------------------------------------------------------------------------------------------- padding

;; custom theme --------------------------------------------------------------------------------------------------------
(add-to-list 'custom-theme-load-path "~/Vaults/git/doom/theme/")
;; -------------------------------------------------------------------------------------------------------- custom theme
