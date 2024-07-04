;;;; Starting up
;; The default is 800 kilobytes.  Measured in bytes.
(setq save-abbrevs 'silently)
(setq gc-cons-threshold (* 100 1000 1000))
(setq native-comp-async-report-warnings-errors 'silent)
; Profile emacs startup
;; (add-hook 'emacs-startup-hook
;;           (lambda ()
;;             (message "*** Emacs loaded in %s with %d garbage collections."
;;                      (format "%.2f seconds"
;;                              (float-time
;;                               (time-subtract after-init-time before-init-time)))
;;                      gcs-done)))
(package-initialize)
(setq use-package-always-ensure t)
(add-to-list 'load-path "~/git.sv.gnu.org/org-mode/lisp")
(add-to-list 'load-path "~/git.sr.ht/bzg/org-contrib/lisp")
(setq custom-file "~/.config/emacs/custom-settings.el")
(load custom-file t)

(setq read-process-output-max (* 1024 1024))

(unless (assoc-default "melpa" package-archives)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t))
(unless (assoc-default "melpa-stable" package-archives)
  (add-to-list 'package-archives
               '("melpa-stable" . "https://stable.melpa.org/packages/") t))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(setq use-package-verbose t)
(setq use-package-always-ensure t)
(require 'use-package)
(use-package auto-compile
  :config (auto-compile-on-load-mode))
(setq load-prefer-newer t)

(defun my/macbookpro ()
  (interactive)
  (string-equal system-type "darwin"))
(global-auto-revert-mode)  ; simplifies syncing

(defun noorul/run-xmodmap ()
  (interactive)
  (start-process-shell-command "xmodmap" nil "xmodmap ~/.xmodmap"))

(setq noorul/exwm-enabled (and (eq window-system 'x)
                               (seq-contains command-line-args "--use-exwm")))

(when noorul/exwm-enabled
  (require 'exwm)
  (require 'exwm-config)
  (exwm-enable)
  (noorul/run-xmodmap))

(setq user-full-name "Noorul Islam K M"
      user-mail-address "noorul@noorul.com")

;; Syntax highlighting is must
(setq global-font-lock-mode t)

(use-package emacs
  :custom (pixel-scroll-precision-mode t))

(when (window-system)
  (defvar ha/fixed-font-family
    (cond
     ((x-list-fonts "Iosevka SS05")    "Iosevka SS05")
     ((x-list-fonts "Iosevka SS14")    "Iosevka SS14")
     ((x-list-fonts "Jetbrains Mono")  "Jetbrains Mono")
     ((x-list-fonts "Iosevka SS04")    "Iosevka SS04")
     ((x-list-fonts "Iosevka Fixed")   "Iosevka Fixed")
     ((x-list-fonts "Menlo")           "Menlo")
     ((x-list-fonts "SauceCodePro Nerd Font Mono") "SauceCodePro Nerd Font Mono")
     ((x-list-fonts "IBM Plex Mono")   "IBM Plex Mono")
     ((x-list-fonts "Fira Code")       "Fira Code")
     ((x-list-fonts "Roboto Mono")     "Roboto Mono")
     ((x-list-fonts "Hack")            "Hack")
     ((x-list-fonts "Source Code Pro") "Source Code Pro")
     ((x-list-fonts "Anonymous Pro")   "Anonymous Pro")
     ((x-list-fonts "Hasklig")         "Hasklig")
     ((x-list-fonts "M+ 1mn")          "M+ 1mn"))
    "My fixed width font based on what is installed, `nil' if not defined.")

  (defvar ha/variable-font-family
    (cond
     ((x-list-fonts "Iosevka Etoile") "Iosevka Etoile")
     ((x-list-fonts "Source Sans Pro") "Source Sans Pro")
     ((x-list-fonts "ETBembo") "ETBembo")
     ((x-list-fonts "SF Pro") "SF Pro")
     ((x-list-fonts "FiraGO") "FiraGO")
     ((x-list-fonts "Lucida Grande")   "Lucida Grande")
     ((x-list-fonts "Verdana")         "Verdana")
     ((x-family-fonts "Sans Serif")    "Sans Serif")
     (nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro.")))
    "My variable width font available to org-mode files and whatnot.")

  (defconst ha/fixed-font-family-height
    (if (my/macbookpro)
        160
      135))
  (when ha/fixed-font-family
    (set-frame-font ha/fixed-font-family)
    (set-face-attribute 'default nil :font ha/fixed-font-family :height ha/fixed-font-family-height :weight 'normal)
    (set-face-attribute 'fixed-pitch nil :font ha/fixed-font-family :height ha/fixed-font-family-height :weight 'normal)
    (set-face-font 'default ha/fixed-font-family))

  (when ha/variable-font-family
    (set-face-attribute 'variable-pitch nil :font ha/variable-font-family :height 1.0 :weight 'extralight)))

(use-package modus-themes
  :pin melpa
  :init
  (setq modus-themes-slanted-constructs t
        modus-themes-mixed-fonts t
        modus-themes-bold-constructs nil
        modus-themes-region '(bg-only no-extend)
        modus-themes-org-agenda
        '((header-block . (variable-pitch scale-title))
          (header-date . (grayscale workaholic bold-today))
          (scheduled . uniform)
          (habit . traffic-light-deuteranopia))
        )
  ;; Load the theme files before enabling a theme (else you get an error).
  :config
  (load-theme 'modus-vivendi-tritanopia :no-confim))

(use-package ef-themes
  :init (setq ef-themes-mixed-fonts t)
  )

(defun my/reload-emacs-configuration ()
  (interactive)
  (load-file "~/.config/emacs/init.el"))

(setenv "LC_TYPE" "en_US.UTF-8")
(setenv "LC_ALL" "en_US.UTF-8")
(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

(add-hook 'compilation-filter-hook (lambda () (ansi-color-apply-on-region (point-min) (point-max))))

(require 'cl)
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config
  (setq exec-path-from-shell-variables
        (list "PATH" "MANPATH" "PYTHONPATH" "JFROG_USERNAME"
              "JFROG_PASSWORD" "GVT_WORKSPACE" "BITBUCKET_TOKEN"
              "JIRA_TOKEN" "KUBECONFIG" "GVT_COMPOSE_FILE" "AWS_DEFAULT_REGION"
              "AWS_ACCOUNT_ID" "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY"
              "COMPOSE_FILE" "DEVENV_DIR" "LOCAL_GITHUB_ACCESS_TOKEN" "SSH_AUTH_SOCK_PATH"
              "DOCKER_AUTH_SOCK_PATH" "PUSHBULLET_TOKEN"))
  (exec-path-from-shell-initialize)
  (if (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
      (progn
        (message "Native comp is available")
        ;; Using Emacs.app/Contents/MacOS/bin since it was compiled with
        ;; ./configure --prefix="$PWD/nextstep/Emacs.app/Contents/MacOS"
        (add-to-list 'exec-path (concat invocation-directory "bin") t)
        (setenv "LIBRARY_PATH" (concat (getenv "LIBRARY_PATH")
                                       (when (getenv "LIBRARY_PATH")
                                         ":")
                                       ;; This is where Homebrew puts gcc libraries.
                                       (car (file-expand-wildcards
                                             (expand-file-name "/opt/gcc/lib/gcc/*")))))
        ;; Only set after LIBRARY_PATH can find gcc libraries.
        (setq comp-deferred-compilation t))
    (message "Native comp is *not* available")))

(if (my/macbookpro)
    (progn
      (setq ns-command-modifier 'meta)
      (setq mac-option-modifier 'super)
      (setq insert-directory-program (executable-find "gls"))
      ;; Upgraded to El Capitan. Facing problem described here
      ;; http://stuff-things.net/2015/10/05/emacs-visible-bell-work-around-on-os-x-el-capitan/
      (setq visible-bell nil) ;; The default
      (setq ring-bell-function 'ignore)))

(defconst user-data-directory
  (expand-file-name "data/" user-emacs-directory))

(use-package dash)
(use-package diminish)

(setq backup-directory-alist '(("." . "~/.config/emacs/backups")))

(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.config/emacs/auto-save-list/" t)))

(tool-bar-mode -1)

(display-time-mode 1)

(setq column-number-mode t)

(use-package winner
  :defer t)

(setq sentence-end-double-space nil)

;; I hate typing full 'yes', just 'y' is enough.
(defalias 'yes-or-no-p 'y-or-n-p)

;; I don't need tool bar, scroll bar and menu bar
;; I get lots of real estate without them.
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; I don't need splash screen everytime
(setq inhibit-splash-screen t)

;; Don't show the startup screen
(setq inhibit-startup-message t)

(setq-default indent-tabs-mode nil)

(use-package vertico
  :init
  (vertico-mode)

  ;; Different scroll margin
  ;; (setq vertico-scroll-margin 0)

  ;; Show more candidates
  ;; (setq vertico-count 20)

  ;; Grow and shrink the Vertico minibuffer
  ;; (setq vertico-resize t)

  ;; Optionally enable cycling for `vertico-next' and `vertico-previous'.
  ;; (setq vertico-cycle t)
  )

(use-package marginalia
  :init
  (marginalia-mode)
  :config
  (add-to-list 'marginalia-prompt-categories '("Find file: " . file))
  (add-to-list 'marginalia-command-categories '(counsel-projectile-find-file . file))
  (add-to-list 'marginalia-command-categories '(projectile-find-file-dwim . file))
  (add-to-list 'marginalia-command-categories '(projectile-find-file-other-window . file))
  (add-to-list 'marginalia-command-categories '(projectile-find-file-other-frame . file))
  (add-to-list 'marginalia-command-categories '(projectile-find-file . file))
  (add-to-list 'marginalia-command-categories '(projectile-find-file-in-directory . file))
  (add-to-list 'marginalia-command-categories '(projectile-switch-project . projectile-project))
  (add-to-list 'marginalia-command-categories '(projectile-find-file-in-known-projects . file)))

(use-package embark
  :after vertico
  :bind
  (("M-o" . embark-act)
   ("C-h b" . embark-bindings))
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq
   prefix-help-command #'embark-prefix-help-command
;;   embark-prompter 'embark-completing-read-prompter
   )
  :config
  (setq embark-cycle-key "<space>")
  (setq embark-quit-after-action t)
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))
(use-package
  embark-consult
  :after (embark consult)
  :demand t                ; only necessary if you have the hook below
  ;; if you want to have consult previews as you move around an
  ;; auto-updating embark collect buffer
  :hook (embark-collect-mode . consult-preview-at-point-mode)
  :config

  (defun noorul/my-projectile-vc (&optional project)
    (interactive "s")
    (projectile-vc project))

(defun my/embark-projectile-switch-project-action-vc (project)
  "Switch PROJECT's magit buffer."
  (interactive "s")
  (let ((projectile-switch-project-action 'projectile-vc))
    (my/embark-projectile-switch-project-by-name project)))

(defun my/embark-projectile-switch-project-action-run-vterm (project)
  "Invoke `vterm' from PROJECT's root."
  (let ((projectile-switch-project-action
         (lambda ()
           (projectile-run-vterm))))
    (my/embark-projectile-switch-project-by-name project)))


(defun my/embark-projectile-switch-project-action-rg (project)
  "Search PROJECT with rg."
  (let ((projectile-switch-project-action
         (lambda ()
           (consult-ripgrep))))
    (my/embark-projectile-switch-project-by-name project)))

(defvar-keymap my/embark-projectile-extended-map
  :doc "Keymap for extended projectile actions."
  "v" #'my/embark-projectile-switch-project-action-run-vterm)

(fset 'my/embark-projectile-extended-map my/embark-projectile-extended-map)

(defun my/embark-projectile-switch-project-by-name (project)
  "Switch to PROJECT.
Invokes the command referenced by
`projectile-switch-project-action' on switch.
This is a replacement for `projectile-switch-project-by-name'
with a different switching mechanism: the switch-project action
is called from a dedicated buffer rather than the initial buffer.
Also, PROJECT's dir-local variables are loaded before calling the
action."
  (run-hooks 'projectile-before-switch-project-hook)
  ;; Kill and recreate the switch buffer to get rid of any local
  ;; variable
  (ignore-errors (kill-buffer " *embark-projectile*"))
  (set-buffer (get-buffer-create " *embark-projectile*"))
  (setq default-directory project)
  ;; Load the project dir-local variables into the switch buffer, so
  ;; the action can make use of them
  (hack-dir-local-variables-non-file-buffer)
  (funcall projectile-switch-project-action)
  ;; If the action relies on `ivy-read' then, after one of its
  ;; `ivy-read' actions is executed, the current buffer will be set
  ;; back to the initial buffer. Hence we make sure tu evaluate
  ;; `projectile-after-switch-project-hook' from the switch buffer.
  (with-current-buffer " *embark-projectile*"
    (run-hooks 'projectile-after-switch-project-hook)))

  (defvar-keymap projectile-map
    :doc "Commands to act on current file or buffer."
    :parent embark-general-map
    "v" #'my/embark-projectile-switch-project-action-vc
    "s" #'my/embark-projectile-switch-project-action-rg
    "x" #'my/embark-projectile-extended-map)

  (add-to-list 'embark-keymap-alist '(projectile-project . (projectile-map embark-file-map))))

(use-package consult
  :after projectile
  :bind (("C-x r x" . consult-register)
         ("C-x r b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complet-command
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("M-y" . consult-yank-pop)
         ("C-M-#" . consult-register)
         ("M-g o" . consult-outline)
         ("M-g h" . consult-org-heading)
         ("M-g a" . consult-org-agenda)
         ("M-g m" . consult-mark)
         ("C-x b" . consult-buffer)
         ("<help> a" . consult-apropos)            ;; orig. apropos-command
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-project-imenu)
         ("M-g e" . consult-error)
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s L" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch)
         ("M-g l" . consult-line)
         ("M-s m" . consult-multi-occur)
         ("C-x c o" . consult-multi-occur)
         ("C-x c SPC" . consult-mark)
         :map isearch-mode-map
         ("M-e" . consult-isearch)                 ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch)               ;; orig. isearch-edit-string
         ("M-s l" . consult-line))
  :init
  (setq register-preview-delay 0
        register-preview-function #'consult-register-format)
  :config
  (setq consult-project-function (lambda (_) (projectile-project-root)))
  (setq consult-narrow-key "<"))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode)
  (setq undo-tree-auto-save-history nil
        undo-tree-visualizer-timestamps t
        undo-tree-visualizer-diff t
        undo-tree-history-directory-alist '(("." . "~/.config/emacs/backups/undo-tree"))))

(use-package persistent-scratch
  :defer t
  :init
  (progn
    (setq persistent-scratch-save-file (expand-file-name ".persistent-scratch" user-data-directory))
    (persistent-scratch-setup-default)))

(server-start)

(setenv "EDITOR" "emacsclient")

(use-package edit-server
  :if (window-system)
  :defer 5
  :config
  (setq edit-server-new-frame nil
        edit-server-port 10202)
  (edit-server-start))

(setq epa-file-encrypt-to '("noorul@noorul.com"))
(setq epa-pinentry-mode 'loopback)
(setq epg-pinentry-mode 'loopback)

;; Add the following to ~/.gnupg/gpg-agent.conf
;; and restart gpg-agent
;;;; allow-emacs-pinentry
;;;; allow-loopback-pinentry
;;;; pinentry-program /usr/local/bin/pinentry
(setq epa-file-cache-passphrase-for-symmetric-encryption t)
(use-package pinentry
  :hook
  (after-init . pinentry-start)
  :config
  (setq epa-pinentry-mode 'loopback))

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

(defun noorul/store-current-location ()
  (interactive)
  (point-to-register ?1))

(defun noorul/jump-to-saved-location ()
  (interactive)
  (jump-to-register ?1))

(bind-key "C-M-;" 'noorul/store-current-location)
(bind-key "C-M-'" 'noorul/jump-to-saved-location)

(use-package whole-line-or-region
  :diminish whole-line-or-region-local-mode
  :init (whole-line-or-region-global-mode))

(show-paren-mode 1)

(bind-key "C-x p" 'pop-to-mark-command)
(setq set-mark-command-repeat-pop t)

(use-package smartscan
  :defer 5
  :hook (prog-mode . smartscan-mode-turn-on))

(use-package avy
  :bind
  (("C-:" . avy-goto-char-timer)
   ("M-g g" . avy-goto-line)
   ("M-g e" . avy-goto-word-0)
   ("M-g w" . avy-goto-word-1)))

(setq bookmark-default-file (concat user-data-directory "bookmarks"))

(use-package ace-window
  :bind (("C-x o" . ace-window))
  :config (setq aw-background nil))

(use-package recentf
  :defer 10
  :commands (recentf-mode
             Recentf-add-file
             recentf-apply-filename-handlers)
  :preface
  (defun recentf-add-dired-directory ()
    (if (and dired-directory
             (file-directory-p dired-directory)
             (not (string= "/" dired-directory)))
        (let ((last-idx (1- (length dired-directory))))
          (recentf-add-file
           (if (= ?/ (aref dired-directory last-idx))
               (substring dired-directory 0 last-idx)
             dired-directory)))))
  :hook (dired-mode . recentf-add-dired-directory)
  :config
  (setq recentf-exclude '("~$" "/tmp/" "/ssh:" "/sudo:" "/kubernetes:"))
  (recentf-mode 1))

(defun prelude-copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(use-package wgrep
  :defer 5)

;; (use-package counsel
;;   :after ivy
;;   :demand t
;;   :diminish
;;   :bind (("M-i" . counsel-imenu)
;;          ("C-h v". counsel-describe-variable)
;;          ("C-c O" . counsel-git-grep)))

;; (use-package swiper
;;   :diminish ivy-mode
;;   :config
;;   (ivy-mode 1)
;;   (setq ivy-use-virtual-buffers t)
;;   :bind (("C-s" . swiper)
;;          ("C-c C-r" . ivy-resume)
;;          ("M-x" . counsel-M-x)
;;          ("C-x C-f" . counsel-find-file)
;;          ("C-x C-b" . ivy-switch-buffer)
;;          ("C-x b" . ivy-switch-buffer)))

;; (use-package ivy-rich
;;   :after swiper
;;   :config
;;   (setq ivy-virtual-abbreviate 'full
;;         ivy-rich-switch-buffer-align-virtual-buffer t
;;         ivy-rich-abbreviate-paths t)
;;   (ivy-rich-mode))
  ;; (ivy-set-display-transformer 'ivy-switch-buffer 'ivy-rich-switch-buffer-transformer))

;; (use-package ivy-hydra
;;   :after swiper)

(use-package ace-link)

(use-package consult
  :after projectile
  :defines consult-buffer-sources
  :config
  (projectile-load-known-projects)
  (setq my-consult-source-projectile-projects
        `(:name "Projectile projects"
                :narrow   ?P
                :category project
                :action   ,#'projectile-switch-project-by-name
                :items    ,projectile-known-projects))
  (add-to-list 'consult-buffer-sources my-consult-source-projectile-projects 'append))

(setq dired-listing-switches "-alt")

(setq dired-dwim-target t)

(require 'dired-x)

(use-package multiple-cursors
  :bind
   (("C->" . mc/mark-next-like-this)
    ("C-<" . mc/mark-previous-like-this)
    ("C-|" . mc/skip-to-next-like-this)
    ("C-*" . mc/mark-all-like-this))
   :config
   (setq mc/list-file (expand-file-name "mc-lists.el" user-data-directory)))

;;;
;;; Org Mode
;;;
(use-package org
  :diminish "org-mode"
  :hook (org-mode . variable-pitch-mode)
  )

;; Only .org and .org_archive files carry this mode
(add-to-list 'auto-mode-alist '("\\.\\(org\\|org_archive\\)$" . org-mode))
;;
;; Standard key bindings
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(use-package org-bullets
  :disabled
  :init (add-hook 'org-mode-hook 'org-bullets-mode))

;; Load org modules
(setq org-modules (quote (ol-bbdb
                          ol-bibtex
                          org-crypt
                          org-id
                          ol-info
                          ;; org-jsinfo
                          org-habit
                          org-inlinetask
                          ol-irc
                          ol-mew
                          ol-mhe
                          org-protocol
                          ol-rmail
                          ol-vm
                          ol-wl
                          ol-w3m)))
(use-package ob-http)

(org-reload)

;; Every .org file under ~/github.com/noorul/notebook/notebook should be part of agenda.
(setq org-agenda-files (quote ("~/github.com/noorul/notebook/notebook")))

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "PHONE" "MEETING"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("MEETING" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

(setq org-use-fast-todo-selection t)
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

(setq org-todo-state-tags-triggers
      (quote (("CANCELLED" ("CANCELLED" . t))
              ("WAITING" ("WAITING" . t))
              ("HOLD" ("WAITING") ("HOLD" . t))
              (done ("WAITING") ("HOLD"))
              ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
              ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
              ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

(setq org-directory "~/github.com/noorul/notebook/notebook")
(setq org-default-notes-file "~/github.com/noorul/notebook/notebook/organizer.org")

;; I use C-c r to start capture mode
(global-set-key (kbd "C-c r") 'org-capture)

(setq noorul/refile-target "~/github.com/noorul/notebook/notebook/organizer.org")

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file+headline noorul/refile-target "Tasks")
               "* TODO %?\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("r" "respond" entry (file+headline noorul/refile-target "Tasks")
               "* TODO Respond to %:from on %:subject\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
              ("n" "Notes" entry (file+datetree noorul/refile-target)
               "* %? :NOTE:\n%U\n%a\n  %i" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree noorul/refile-target)
               "* %?\n%U\n  %i" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file noorul/refile-target)
               "* TODO Review %c\n%U\n  %i" :immediate-finish t)
              ("m" "Meeting" entry (file noorul/refile-target)
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
              ("a" "Aruba Meeting" entry (file+olp "~/github.com/noorul/notebook/notebook/aruba.org" "Meetings")
               "* %?\n%U\n  %i" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file+datetree noorul/refile-target)
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("c" "Contacts" entry (file "~/github.com/noorul/notebook/notebook/contacts.org")
               "* %(org-contacts-template-name)
:PROPERTIES:
:EMAIL: %(org-contacts-template-email)
:END:")
              ("h" "Habit" entry (file "~/github.com/noorul/notebook/notebook/routines.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %t .+1d/3d\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

;; Remove empty LOGBOOK drawers on clock out
(defun bh/remove-empty-drawer-on-clock-out ()
  (interactive)
  (save-excursion
    (beginning-of-line 0)
    (org-remove-empty-drawer-at (point))))

(add-hook 'org-clock-out-hook 'bh/remove-empty-drawer-on-clock-out 'append)

; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)

; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

; Use IDO for both buffer and file completion and ido-everywhere to t
;; (setq org-completion-use-ido t)
;; (setq ido-everywhere t)
;; (setq ido-max-directory-size 100000)
;; (ido-mode (quote both))

;;;; Refile settings
; Exclude DONE state tasks from refile targets
(defun bh/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))

(setq org-refile-target-verify-function 'bh/verify-refile-target)

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks t)

;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("w" "Work" tags "work")
              ("c" "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               nil))))

(defun bh/org-auto-exclude-function (tag)
  "Automatic task exclusion in the agenda with / RET"
  (and (cond
        ((string= tag "hold")
         t)
        ((string= tag "farm")
         t))
       (concat "-" tag)))

(setq org-agenda-auto-exclude-function 'bh/org-auto-exclude-function)

;;
;; Resume clocking task when emacs is restarted
(org-clock-persistence-insinuate)
;;
;; Show lot of clocking history so it's easy to pick items off the C-F11 list
(setq org-clock-history-length 23)
;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)
;; Change tasks to NEXT when clocking in
(setq org-clock-in-switch-to-state 'bh/clock-in-to-next)
;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))
;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Sometimes I change tasks I'm clocking quickly - this removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)
;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)
;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)
;; Do not prompt to resume an active clock
(setq org-clock-persist-query-resume nil)
;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolution (quote when-no-clock-is-running))
;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)

(setq bh/keep-clock-running nil)

(defun bh/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (bh/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (bh/is-project-p))
      "TODO"))))

(defun bh/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task (save-excursion (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun bh/punch-in (arg)
  "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
  (interactive "p")
  (setq bh/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;;
      ;; We're in the agenda
      ;;
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (bh/clock-in-organization-task-as-default)))
    ;;
    ;; We are not in the agenda
    ;;
    (save-restriction
      (widen)
      ; Find the tags on the current task
      (if (and (equal major-mode 'org-mode) (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (bh/clock-in-organization-task-as-default)))))

(defun bh/punch-out ()
  (interactive)
  (setq bh/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-remove-restriction-lock))

(defun bh/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun bh/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when bh/keep-clock-running
            (bh/clock-in-default-task)))))))

(defvar bh/organization-task-id "eb155a82-92b2-4f25-a3c6-0304591af2f9")

(defun bh/clock-in-organization-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find bh/organization-task-id 'marker)
    (org-clock-in '(16))))

(defun bh/clock-out-maybe ()
  (when (and bh/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (bh/clock-in-parent-task)))

(add-hook 'org-clock-out-hook 'bh/clock-out-maybe 'append)

(require 'org-id)
(defun bh/clock-in-task-by-id (id)
  "Clock in a task by id"
  (org-with-point-at (org-id-find id 'marker)
    (org-clock-in nil)))

(defun bh/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
Skip the default task and get the next one.
A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history)) (cadr org-clock-history))
          (t (car org-clock-history)))))
    (widen)
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(setq org-time-stamp-rounding-minutes (quote (1 1)))


(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
                            :min-duration 0
                            :max-gap 0
                            :gap-ok-around ("4:00"))))

(setq org-clock-out-remove-zero-time-clocks t)

;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))

; Set default column view headings: Task Effort Clock_Summary
(setq org-columns-default-format "%80ITEM(Task) %10Effort(Effort){:} %10CLOCKSUM")

; global Effort estimate values
; global STYLE property values for completion
(setq org-global-properties (quote (("Effort_ALL" . "0:15 0:30 0:45 1:00 2:00 3:00 4:00 5:00 6:00 0:00")
                                    ("STYLE_ALL" . "habit"))))

;; Agenda log mode items to display (closed and state changes by default)
(setq org-agenda-log-mode-items (quote (state)))

; Tags with fast selection keys
(setq org-tag-alist '(("@work" . ?o)
                      ("@home" . ?h)
                      ("@writing" . ?w)
                      ("@errands" . ?e)
                      ("@drawing" . ?d)
                      ("@coding" . ?c)
                      ("@phone" . ?p)
                      ("@reading" . ?r)
                      ("@computer" . ?l)
                      ("quantified" . ?q)))

; Allow setting single tags without the menu
(setq org-fast-tag-selection-single-key (quote expert))

; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)

(setq org-agenda-span 'day)

(setq org-stuck-projects (quote ("" nil nil "")))

(defun bh/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

(defun bh/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (bh/find-project-task)
      (if (equal (point) task)
          nil
        t))))

(defun bh/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

(defun bh/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components)) org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components)) org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))

(defun bh/list-sublevels-for-projects-indented ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels 'indented)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defun bh/list-sublevels-for-projects ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels t)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defvar bh/hide-scheduled-and-waiting-next-tasks t)

(defun bh/toggle-next-task-display ()
  (interactive)
  (setq bh/hide-scheduled-and-waiting-next-tasks (not bh/hide-scheduled-and-waiting-next-tasks))
  (when  (equal major-mode 'org-agenda-mode)
    (org-agenda-redo))
  (message "%s WAITING and SCHEDULED NEXT Tasks" (if bh/hide-scheduled-and-waiting-next-tasks "Hide" "Show")))

(defun bh/skip-stuck-projects ()
  "Skip trees that are not stuck projects"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                nil
              next-headline)) ; a stuck project, has subtasks but no next task
        nil))))

(defun bh/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (if (bh/is-project-p)
          (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next) (< (point) subtree-end) (re-search-forward "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              nil)) ; a stuck project, has subtasks but no next task
        next-headline))))

(defun bh/skip-non-projects ()
  "Skip trees that are not projects"
  ;; (bh/list-sublevels-for-projects-indented)
  (if (save-excursion (bh/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (cond
           ((bh/is-project-p)
            nil)
           ((and (bh/is-project-subtree-p) (not (bh/is-task-p)))
            nil)
           (t
            subtree-end))))
    (save-excursion (org-end-of-subtree t))))

(defun bh/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((and bh/hide-scheduled-and-waiting-next-tasks
             (member "WAITING" (org-get-tags-at)))
        next-headline)
       ((bh/is-project-p)
        next-headline)
       ((and (bh/is-task-p) (not (bh/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))

(defun bh/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks, habits, NEXT tasks, and loose tasks.
When not restricted, skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max))))
           (limit-to-project (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (bh/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-project-tasks ()
  "Show non-project tasks.
Skip project and sub-project tasks, habits, and project related tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       ((bh/is-project-subtree-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-project-tasks ()
  "Show project tasks.
Skip project and sub-project tasks, habits, and loose non-project tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
           (next-headline (save-excursion (or (outline-next-heading) (point-max)))))
      (cond
       ((bh/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (bh/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       ((not (bh/is-project-subtree-p))
        subtree-end)
       (t
        nil)))))

(defun bh/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((bh/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun bh/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (bh/is-subproject-p)
        nil
      next-headline)))

(setq org-archive-mark-done nil)
(setq org-archive-location "%s_archive::* Archived Tasks")

(defun bh/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (let ((next-headline (save-excursion (or (outline-next-heading) (point-max)))))
    ;; Consider only tasks with done todo headings as archivable candidates
    (if (member (org-get-todo-state) org-done-keywords)
        (let* ((subtree-end (save-excursion (org-end-of-subtree t)))
               (daynr (string-to-number (format-time-string "%d" (current-time))))
               (an-year-ago (* 26 60 60 24 (+ daynr 1)))
               (time-difference (time-subtract
                                 (current-time)
                                 (seconds-to-time an-year-ago)))
               (last-year (- (string-to-number
                              (format-time-string "%Y"
                                                  (current-time))) 1))

               (last-month (string-to-number
                            (format-time-string "%m" (current-time))))
               (my-pair)
               (dates-string
                (do
                    ((count 0 (+ 1 count))
                     (ret-string ""))
                    ((> count 12) ret-string)
                  (setq my-pair (calendar-increment-month-cons count last-month
                                                               last-year))
                  (if (> 10 (car my-pair))
                      (setq ret-string (concat ret-string
                                               (format "%d-0%d-"
                                                       (cdr
                                                        my-pair)
                                                       (car my-pair))))
                    (setq ret-string (concat ret-string
                                             (format "%d-%d-"
                                                     (cdr
                                                      my-pair)
                                                     (car my-pair)))))
                  (if (<= count 11)
                      (setq ret-string (concat ret-string "\\|")))))
               (subtree-is-current (save-excursion
                                     (forward-line 1)
                                     (and (< (point) subtree-end)
                                          (re-search-forward dates-string
                                                             subtree-end
                                                             t)))))
          (if subtree-is-current
              next-headline ; Has a date in this month or last month, skip it
            nil))  ; available to archive
      (or next-headline (point-max)))))

(use-package es-mode
  :mode "\\.es$")

(org-babel-do-load-languages
  (quote org-babel-load-languages)
  (quote ((emacs-lisp . t)
          (dot . t)
          (sql . t)
          (calc . t)
          (ditaa . t)
          (R . t)
          (python . t)
          (ruby . t)
          (gnuplot . t)
          (clojure . t)
          (shell . t)
;;          (ledger . t)
          (org . t)
          (plantuml . t)
          (latex . t)
;;          (elasticsearch . t)
          (java . t)
          (groovy . t)
          (js . t)
          (jq . t)
          )))

 (setq org-babel-default-header-args:java
       '((:dir . "~/bitbucket.org/noorul/sandbox/java")
         (:results . "output")))

 (setq org-babel-python-command "python3")

 ;; Do not prompt to confirm evaluation
 ;; This may be dangerous - make sure you understand the consequences
 ;; of setting this -- see the docstring for details
 ;; (setq org-confirm-babel-evaluate nil)

 ;; Use fundamental mode when editing plantuml blocks with C-c '
 (add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental)))

 ;; Don't enable this because it breaks access to emacs from my Android phone
 (setq org-startup-with-inline-images nil)

; Erase all reminders and rebuilt reminders for today from the agenda
(defun bh/org-agenda-to-appt ()
  (interactive)
  (setq appt-time-msg-list nil)
  (org-agenda-to-appt))

; Rebuild the reminders everytime the agenda is displayed
(add-hook 'org-finalize-agenda-hook 'bh/org-agenda-to-appt 'append)

; This is at the end of my .emacs - so appointments are set up when Emacs starts
(bh/org-agenda-to-appt)

; Activate appointments so we get notifications
(appt-activate t)

; If we leave Emacs running overnight - reset the appointments one minute after midnight
(run-at-time "24:01" nil 'bh/org-agenda-to-appt)

;; Skeletons
;;
;; sblk - Generic block #+begin_FOO .. #+end_FOO
(define-skeleton skel-org-block
  "Insert an org block, querying for type."
  "Type: "
  "#+begin_" str "\n"
  _ - \n
  "#+end_" str "\n")

(define-abbrev org-mode-abbrev-table "sblk" "" 'skel-org-block)


;; selisp - Emacs Lisp source block
(define-skeleton skel-org-block-elisp
  "Insert a org emacs-lisp block"
  ""
  "#+begin_src emacs-lisp\n"
  _ - \n
  "#+end_src\n")

(define-abbrev org-mode-abbrev-table "selisp" "" 'skel-org-block-elisp)

(global-set-key (kbd "<f5>") 'bh/org-todo)

(defun bh/org-todo (arg)
  (interactive "p")
  (if (equal arg 4)
      (save-restriction
        (bh/narrow-to-org-subtree)
        (org-show-todo-tree nil))
    (bh/narrow-to-org-subtree)
    (org-show-todo-tree nil)))

(global-set-key (kbd "<S-f5>") 'bh/widen)

(defun bh/widen ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-agenda-remove-restriction-lock)
        (when org-agenda-sticky
          (org-agenda-redo)))
    (widen)))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "W" (lambda () (interactive) (setq bh/hide-scheduled-and-waiting-next-tasks t) (bh/widen))))
          'append)

(defun bh/restrict-to-file-or-follow (arg)
  "Set agenda restriction to 'file or with argument invoke follow mode.
I don't use follow mode very often but I restrict to file all the time
so change the default 'F' binding in the agenda to allow both"
  (interactive "p")
  (if (equal arg 4)
      (org-agenda-follow-mode)
    (widen)
    (bh/set-agenda-restriction-lock 4)
    (org-agenda-redo)
    (beginning-of-buffer)))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "F" 'bh/restrict-to-file-or-follow))
          'append)

(defun bh/narrow-to-org-subtree ()
  (widen)
  (org-narrow-to-subtree)
  (save-restriction
    (org-agenda-set-restriction-lock)))

(defun bh/narrow-to-subtree ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (org-get-at-bol 'org-hd-marker)
          (bh/narrow-to-org-subtree))
        (when org-agenda-sticky
          (org-agenda-redo)))
    (bh/narrow-to-org-subtree)))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "N" 'bh/narrow-to-subtree))
          'append)

(defun bh/narrow-up-one-org-level ()
  (widen)
  (save-excursion
    (outline-up-heading 1 'invisible-ok)
    (bh/narrow-to-org-subtree)))

(defun bh/get-pom-from-agenda-restriction-or-point ()
  (or (and (marker-position org-agenda-restrict-begin) org-agenda-restrict-begin)
      (org-get-at-bol 'org-hd-marker)
      (and (equal major-mode 'org-mode) (point))
      org-clock-marker))

(defun bh/narrow-up-one-level ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (bh/get-pom-from-agenda-restriction-or-point)
          (bh/narrow-up-one-org-level))
        (org-agenda-redo))
    (bh/narrow-up-one-org-level)))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "U" 'bh/narrow-up-one-level))
          'append)

(defun bh/narrow-to-org-project ()
  (widen)
  (save-excursion
    (bh/find-project-task)
    (bh/narrow-to-org-subtree)))

(defun bh/narrow-to-project ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (progn
        (org-with-point-at (bh/get-pom-from-agenda-restriction-or-point)
          (bh/narrow-to-org-project)
          (save-excursion
            (bh/find-project-task)
            (org-agenda-set-restriction-lock)))
        (org-agenda-redo)
        (beginning-of-buffer))
    (bh/narrow-to-org-project)
    (save-restriction
      (org-agenda-set-restriction-lock))))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "P" 'bh/narrow-to-project))
          'append)

(defvar bh/project-list nil)

(defun bh/view-next-project ()
  (interactive)
  (let (num-project-left current-project)
    (unless (marker-position org-agenda-restrict-begin)
      (goto-char (point-min))
      ; Clear all of the existing markers on the list
      (while bh/project-list
        (set-marker (pop bh/project-list) nil))
      (re-search-forward "Tasks to Refile")
      (forward-visible-line 1))

    ; Build a new project marker list
    (unless bh/project-list
      (while (< (point) (point-max))
        (while (and (< (point) (point-max))
                    (or (not (org-get-at-bol 'org-hd-marker))
                        (org-with-point-at (org-get-at-bol 'org-hd-marker)
                          (or (not (bh/is-project-p))
                              (bh/is-project-subtree-p)))))
          (forward-visible-line 1))
        (when (< (point) (point-max))
          (add-to-list 'bh/project-list (copy-marker (org-get-at-bol 'org-hd-marker)) 'append))
        (forward-visible-line 1)))

    ; Pop off the first marker on the list and display
    (setq current-project (pop bh/project-list))
    (when current-project
      (org-with-point-at current-project
        (setq bh/hide-scheduled-and-waiting-next-tasks nil)
        (bh/narrow-to-project))
      ; Remove the marker
      (setq current-project nil)
      (org-agenda-redo)
      (beginning-of-buffer)
      (setq num-projects-left (length bh/project-list))
      (if (> num-projects-left 0)
          (message "%s projects left to view" num-projects-left)
        (beginning-of-buffer)
        (setq bh/hide-scheduled-and-waiting-next-tasks t)
        (error "All projects viewed.")))))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "V" 'bh/view-next-project))
          'append)

(setq org-show-entry-below (quote ((default))))

(add-hook 'org-agenda-mode-hook
          '(lambda () (org-defkey org-agenda-mode-map "\C-c\C-x<" 'bh/set-agenda-restriction-lock))
          'append)

(defun bh/set-agenda-restriction-lock (arg)
  "Set restriction lock to current task subtree or file if prefix is specified"
  (interactive "p")
  (let* ((pom (bh/get-pom-from-agenda-restriction-or-point))
         (tags (org-with-point-at pom (org-get-tags-at))))
    (let ((restriction-type (if (equal arg 4) 'file 'subtree)))
      (save-restriction
        (cond
         ((and (equal major-mode 'org-agenda-mode) pom)
          (org-with-point-at pom
            (org-agenda-set-restriction-lock restriction-type))
          (org-agenda-redo))
         ((and (equal major-mode 'org-mode) (org-before-first-heading-p))
          (org-agenda-set-restriction-lock 'file))
         (pom
          (org-with-point-at pom
            (org-agenda-set-restriction-lock restriction-type))))))))

;; Limit restriction lock highlighting to the headline only
(setq org-agenda-restriction-lock-highlight-subtree nil)

;; Use sticky agenda's so they persist
(setq org-agenda-sticky t)

;; Always hilight the current agenda line
(add-hook 'org-agenda-mode-hook
          '(lambda () (hl-line-mode 1))
          'append)

;; The following custom-set-faces create the highlights
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(org-mode-line-clock ((t (:foreground "red" :box (:line-width -1 :style released-button)))) t))

;; Keep tasks with dates on the global todo lists
(setq org-agenda-todo-ignore-with-date nil)

;; Keep tasks with deadlines on the global todo lists
(setq org-agenda-todo-ignore-deadlines nil)

;; Keep tasks with scheduled dates on the global todo lists
(setq org-agenda-todo-ignore-scheduled nil)

;; Keep tasks with timestamps on the global todo lists
(setq org-agenda-todo-ignore-timestamp nil)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

(setq org-agenda-include-diary nil)
(setq org-agenda-diary-file "~/github.com/noorul/notebook/notebook/organizer.org")
(setq org-agenda-insert-diary-extract-time t)

;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))

;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)

;; Show all agenda dates - even if they are empty
(setq org-agenda-show-all-dates t)

;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote ((agenda habit-down time-up user-defined-up effort-up category-keep)
              (todo category-up effort-up)
              (tags category-up effort-up)
              (search category-up))))

;; Start the weekly agenda on Monday
(setq org-agenda-start-on-weekday 1)

;; Enable display of the time grid so we can see the marker for the current time
(setq org-agenda-time-grid (quote ((daily today remove-match)
                                   (0900 1100 1300 1500 1700)
                                   "......"
                                   #("----------------" 0 16 (org-heading t))
                                   )))

;; Display tags farther right
(setq org-agenda-tags-column -102)

;;
;; Agenda sorting functions
;;
(setq org-agenda-cmp-user-defined 'bh/agenda-sort)

(defun bh/agenda-sort (a b)
  "Sorting strategy for agenda items.
Late deadlines first, then scheduled, then non-late deadlines"
  (let (result num-a num-b)
    (cond
     ; time specific items are already sorted first by org-agenda-sorting-strategy

     ; non-deadline and non-scheduled items next
     ((bh/agenda-sort-test 'bh/is-not-scheduled-or-deadline a b))

     ; deadlines for today next
     ((bh/agenda-sort-test 'bh/is-due-deadline a b))

     ; late deadlines next
     ((bh/agenda-sort-test-num 'bh/is-late-deadline '> a b))

     ; scheduled items for today next
     ((bh/agenda-sort-test 'bh/is-scheduled-today a b))

     ; late scheduled items next
     ((bh/agenda-sort-test-num 'bh/is-scheduled-late '> a b))

     ; pending deadlines last
     ((bh/agenda-sort-test-num 'bh/is-pending-deadline '< a b))

     ; finally default to unsorted
     (t (setq result nil)))
    result))

(defmacro bh/agenda-sort-test (fn a b)
  "Test for agenda sort"
  `(cond
    ; if both match leave them unsorted
    ((and (apply ,fn (list ,a))
          (apply ,fn (list ,b)))
     (setq result nil))
    ; if a matches put a first
    ((apply ,fn (list ,a))
     (setq result -1))
    ; otherwise if b matches put b first
    ((apply ,fn (list ,b))
     (setq result 1))
    ; if none match leave them unsorted
    (t nil)))

(defmacro bh/agenda-sort-test-num (fn compfn a b)
  `(cond
    ((apply ,fn (list ,a))
     (setq num-a (string-to-number (match-string 1 ,a)))
     (if (apply ,fn (list ,b))
         (progn
           (setq num-b (string-to-number (match-string 1 ,b)))
           (setq result (if (apply ,compfn (list num-a num-b))
                            -1
                          1)))
       (setq result -1)))
    ((apply ,fn (list ,b))
     (setq result 1))
    (t nil)))

(defun bh/is-not-scheduled-or-deadline (date-str)
  (and (not (bh/is-deadline date-str))
       (not (bh/is-scheduled date-str))))

(defun bh/is-due-deadline (date-str)
  (string-match "Deadline:" date-str))

(defun bh/is-late-deadline (date-str)
  (string-match "\\([0-9]*\\) d\. ago:" date-str))

(defun bh/is-pending-deadline (date-str)
  (string-match "In \\([^-]*\\)d\.:" date-str))

(defun bh/is-deadline (date-str)
  (or (bh/is-due-deadline date-str)
      (bh/is-late-deadline date-str)
      (bh/is-pending-deadline date-str)))

(defun bh/is-scheduled (date-str)
  (or (bh/is-scheduled-today date-str)
      (bh/is-scheduled-late date-str)))

(defun bh/is-scheduled-today (date-str)
  (string-match "Scheduled:" date-str))

(defun bh/is-scheduled-late (date-str)
  (string-match "Sched\.\\(.*\\)x:" date-str))

;; Use sticky agenda's so they persist
(setq org-agenda-sticky t)

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (define-key org-agenda-mode-map "q" 'bury-buffer))
          'append)

(setq org-enforce-todo-dependencies t)

(setq org-hide-leading-stars nil)

(setq org-startup-indented t)

(setq org-cycle-separator-lines 0)
(setq org-blank-before-new-entry (quote ((heading)
                                         (plain-list-item . auto))))

(setq org-insert-heading-respect-content nil)

(setq org-reverse-note-order nil)

(setq org-show-following-heading t)
(setq org-show-hierarchy-above t)
(setq org-show-siblings (quote ((default))))

(setq org-special-ctrl-a/e 'reversed)
(setq org-special-ctrl-k t)
(setq org-yank-adjusted-subtrees t)

(setq org-id-method (quote uuidgen))

(setq org-deadline-warning-days 30)

(setq org-table-export-default-format "orgtbl-to-csv")

(setq org-link-frame-setup (quote ((vm . vm-visit-folder)
                                   (gnus . org-gnus-no-new-news)
                                   (file . find-file))))

; Use the current window for C-c ' source editing
(setq org-src-window-setup 'current-window)

(setq org-log-done (quote time))
(setq org-log-into-drawer t)
(setq org-log-state-notes-insert-after-drawers nil)

(setq org-clock-sound nil)

; position the habit graph on the agenda to the right of the default
(setq org-habit-graph-column 50)

(run-at-time "06:00" 86400 '(lambda () (setq org-habit-show-habits t)))

(setq global-auto-revert-mode t)
(add-hook 'dired-mode-hook 'auto-revert-mode)

(setq org-use-speed-commands t)
(setq org-speed-commands-user
      (quote (("0" . ignore)
              ("1" . ignore)
              ("2" . ignore)
              ("3" . ignore)
              ("4" . ignore)
              ("5" . ignore)
              ("6" . ignore)
              ("7" . ignore)
              ("8" . ignore)
              ("9" . ignore)

              ("a" . ignore)
              ("d" . ignore)
              ("h" . bh/hide-other)
              ("i" progn
               (forward-char 1)
               (call-interactively 'org-insert-heading-respect-content))
              ("k" . org-kill-note-or-show-branches)
              ("l" . ignore)
              ("m" . ignore)
              ("q" . bh/show-org-agenda)
              ("r" . ignore)
              ("s" . org-save-all-org-buffers)
              ("w" . org-refile)
              ("x" . ignore)
              ("y" . ignore)
              ("z" . org-add-note)

              ("A" . ignore)
              ("B" . ignore)
              ("E" . ignore)
              ("F" . bh/restrict-to-file-or-follow)
              ("G" . ignore)
              ("H" . ignore)
              ("J" . org-clock-goto)
              ("K" . ignore)
              ("L" . ignore)
              ("M" . ignore)
              ("N" . bh/narrow-to-subtree)
              ("P" . bh/narrow-to-project)
              ("Q" . ignore)
              ("R" . ignore)
              ("S" . ignore)
              ("T" . bh/org-todo)
              ("U" . bh/narrow-up-one-level)
              ("V" . ignore)
              ("W" . bh/widen)
              ("X" . ignore)
              ("Y" . ignore)
              ("Z" . ignore))))

(defun bh/show-org-agenda ()
  (interactive)
  (if org-agenda-sticky
      (switch-to-buffer "*Org Agenda( )*")
    (switch-to-buffer "*Org Agenda*"))
  (delete-other-windows))

(defvar bh/insert-inactive-timestamp t)

(defun bh/toggle-insert-inactive-timestamp ()
  (interactive)
  (setq bh/insert-inactive-timestamp (not bh/insert-inactive-timestamp))
  (message "Heading timestamps are %s" (if bh/insert-inactive-timestamp "ON" "OFF")))

(defun bh/insert-inactive-timestamp ()
  (interactive)
  (org-insert-time-stamp nil t t nil nil nil))

(defun bh/insert-heading-inactive-timestamp ()
  (save-excursion
    (when bh/insert-inactive-timestamp
      (org-return)
      (org-cycle)
      (bh/insert-inactive-timestamp))))

(add-hook 'org-insert-heading-hook 'bh/insert-heading-inactive-timestamp
          'append)

(setq org-return-follows-link t)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(org-mode-line-clock ((t (:foreground "red" :box (:line-width -1 :style released-button)))) t))

(defun bh/prepare-meeting-notes ()
  "Prepare meeting notes for email
   Take selected region and convert tabs to spaces, mark TODOs with leading >>>, and copy to kill ring for pasting"
  (interactive)
  (let (prefix)
    (save-excursion
      (save-restriction
        (narrow-to-region (region-beginning) (region-end))
        (untabify (point-min) (point-max))
        (goto-char (point-min))
        (while (re-search-forward "^\\( *-\\\) \\(TODO\\|DONE\\): " (point-max) t)
          (replace-match (concat (make-string (length (match-string 1)) ?>) " " (match-string 2) ": ")))
        (goto-char (point-min))
        (kill-ring-save (point-min) (point-max))))))

(setq org-remove-highlights-with-change nil)

(add-to-list 'Info-default-directory-list "~/.config/emacs/site-lisp/org-mode/doc")

(setq org-read-date-prefer-future 'time)

(setq org-list-demote-modify-bullet
      (quote (("+" . "-")
              ("*" . "-")
              ("1." . "-")
              ("1)" . "-")
              ("A)" . "-")
              ("B)" . "-")
              ("a)" . "-")
              ("b)" . "-")
              ("A." . "-")
              ("B." . "-")
              ("a." . "-")
              ("b." . "-"))))

(setq org-tags-match-list-sublevels t)

(setq org-agenda-persistent-filter t)

(setq org-link-mailto-program (quote (compose-mail "%a" "%s")))

(use-package org-mime
  :commands (org-mime-htmlize
             org-mime-org-buffer-htmlize
             org-mime-org-subtree-htmlize))
(use-package htmlize
  :commands (htmlize-buffer
             htmlize-region
             htmlize-file))

(setq org-agenda-skip-additional-timestamps-same-entry t)

(setq org-table-use-standard-references (quote from))

(setq org-file-apps (quote ((auto-mode . emacs)
                            ("\\.mm\\'" . system)
                            ("\\.x?html?\\'" . system)
                            ("\\.pdf\\'" . system))))

; Overwrite the current window with the agenda
(setq org-agenda-window-setup 'current-window)

(setq org-clone-delete-id t)

(setq org-cycle-include-plain-lists t)

(setq org-src-fontify-natively t)

(defun bh/mark-next-parent-tasks-todo ()
  "Visit each parent task and change NEXT states to TODO"
  (let ((mystate (or (and (fboundp 'org-state)
                          state)
                     (nth 2 (org-heading-components)))))
    (when mystate
      (save-excursion
        (while (org-up-heading-safe)
          (when (member (nth 2 (org-heading-components)) (list "NEXT"))
            (org-todo "TODO")))))))

(defun noorul/store-org-clocked-tags ()
  (setq noorul/org-clocked-tags (nth 5 (org-heading-components))))


(add-hook 'org-after-todo-state-change-hook 'bh/mark-next-parent-tasks-todo 'append)
(add-hook 'org-clock-in-hook 'bh/mark-next-parent-tasks-todo 'append)
(add-hook 'org-clock-in-hook 'noorul/store-org-clocked-tags 'append)

(setq org-startup-folded t)

(setq org-alphabetical-lists t)

;; flyspell mode for spell checking everywhere
(add-hook 'org-mode-hook 'turn-on-flyspell 'append)

;; Disable keys in org-mode
;;    C-c [
;;    C-c ]
;;    C-c ;
;;    C-c C-x C-q  cancelling the clock (we never want this)
(add-hook 'org-mode-hook
          '(lambda ()
             ;; Undefine C-c [ and C-c ] since this breaks my
             ;; org-agenda files when directories are include It
             ;; expands the files in the directories individually
             (org-defkey org-mode-map "\C-c[" 'undefined)
             (org-defkey org-mode-map "\C-c]" 'undefined)
             (org-defkey org-mode-map "\C-c;" 'undefined)
             (org-defkey org-mode-map "\C-c\C-x\C-q" 'undefined))
          'append)

(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c M-o") 'bh/mail-subtree))
          'append)

(defun bh/mail-subtree ()
  (interactive)
  (org-mark-subtree)
  (org-mime-subtree))

(setq org-enable-priority-commands nil)

(setq org-src-preserve-indentation nil)
(setq org-edit-src-content-indentation 0)

(setq org-catch-invisible-edits 'error)

(setq org-time-clocksum-format
      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))

(use-package org-contacts
  :commands org-contacts
  :load-path "~/git.sr.ht/bzg/org-contrib/lisp"
  :custom
  (org-contacts-files (quote ("~/github.com/noorul/notebook/notebook/contacts.org")))
  (calendar-mark-holidays-flag t))

(run-at-time "00:59" 3600 'org-save-all-org-buffers)

(defun my/helm-multi-swoop-all-headings ()
  "Search only for headings across all files"
  (interactive)
  (helm-multi-swoop-all "\\* ")
  )

;; ——— WORF Utilities ———————————————————————————————————————————————————————————————
;; https://github.com/abo-abo/worf/blob/master/worf.el
(defun worf--pretty-heading (str lvl)
  "Prettify heading STR or level LVL."
  (setq str (or str ""))
  (setq str (propertize str 'face (nth (1- lvl) org-level-faces)))
  (let (desc)
    (while (and (string-match org-bracket-link-regexp str)
                (stringp (setq desc (match-string 3 str))))
      (setq str (replace-match
                 (propertize desc 'face 'org-link)
                 nil nil str)))
    str))

(defun worf--pattern-transformer (x)
  "Transform X to make 1-9 select the heading level in `worf-goto'."
  (if (string-match "^[1-9]" x)
      (setq x (format "^%s" x))
    x))

(defun worf-goto ()
  "Jump to a heading with `helm'."
  (interactive)
  (require 'helm-match-plugin)
  (let ((candidates
         (org-map-entries
          (lambda ()
            (let ((comp (org-heading-components))
                  (h (org-get-heading)))
              (cons (format "%d%s%s" (car comp)
                            (make-string (1+ (* 2 (1- (car comp)))) ?\ )
                            (if (get-text-property 0 'fontified h)
                                h
                              (worf--pretty-heading (nth 4 comp) (car comp))))
                    (point))))))
        helm-update-blacklist-regexps
        helm-candidate-number-limit)
    (helm :sources
          `((name . "Headings")
            (candidates . ,candidates)
            (action . (lambda (x) (goto-char x)
                         (call-interactively 'show-branches)
                         (worf-more)))
            (pattern-transformer . worf--pattern-transformer)))))

(defun bh/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading 'invisible-ok)
    (hide-other)
    (org-cycle)
    (org-cycle)
    (org-cycle)))

(defun bh/set-truncate-lines ()
  "Toggle value of truncate-lines and refresh window display."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  ;; now refresh window display (an idiom from simple.el):
  (save-excursion
    (set-window-start (selected-window)
                      (window-start (selected-window)))))

(defun bh/make-org-scratch ()
  (interactive)
  (find-file "/tmp/publish/scratch.org")
  (gnus-make-directory "/tmp/publish"))

(defun bh/switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(setq org-alphabetical-lists t)
(require 'ox-html)
(require 'ox-latex)
(require 'ox-ascii)
(require 'ox-md)
(setq org-publish-project-alist
      '(
        ("noorul-blog"
         ;; Path to your org files.
         :base-directory "~/git/noorul.github.com/_org/"
         :base-extension "org"

         ;; Path to your Jekyll project.
         :publishing-directory "~/git/noorul.github.com/"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-extension "html"
         :body-only t ;; Only export section between <body> </body>
         )
        ("pubtest"
         ;; Path to your org files.
         :base-directory "~/partition"
         :base-extension "org"

         ;; Path to your Jekyll project.
         :publishing-directory "/tmp/pubtest"
         :recursive t
         :publishing-function org-html-publish-to-html
         :headline-levels 4
         :html-extension "html"
         :body-only t ;; Only export section between <body> </body>
         )
        ))

(use-package ox-reveal
  :config
  (setq org-reveal-root "https://cdn.jsdelivr.net/npm/reveal.js"))

;;;_, org-mode bindings.
(global-set-key (kbd "<f9> g") 'noorul/switch-to-gnus)
(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key (kbd "<f5>") 'bh/org-todo)
(global-set-key (kbd "<S-f5>") 'bh/widen)
;; (global-set-key (kbd "<f7>") 'bh/set-truncate-lines)
(global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
(global-set-key (kbd "<f9> <f9>") 'bh/show-org-agenda)
(global-set-key (kbd "<f9> b") 'bbdb)
(global-set-key (kbd "<f9> c") 'calendar)
(global-set-key (kbd "<f9> f") 'boxquote-insert-file)
(global-set-key (kbd "<f9> h") 'bh/hide-other)
(global-set-key (kbd "<f9> n") 'org-narrow-to-subtree)
(global-set-key (kbd "<f9> w") 'widen)

(global-set-key (kbd "<f9> I") 'bh/punch-in)
(global-set-key (kbd "<f9> O") 'bh/punch-out)

(global-set-key (kbd "<f9> o") 'bh/make-org-scratch)

(global-set-key (kbd "<f9> r") 'boxquote-region)
(global-set-key (kbd "<f9> s") 'bh/switch-to-scratch)

(global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
(global-set-key (kbd "<f9> T") 'tabify)
(global-set-key (kbd "<f9> U") 'untabify)

(global-set-key (kbd "<f9> v") 'visible-mode)
(global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
(global-set-key (kbd "C-<f9>") 'previous-buffer)
(global-set-key (kbd "M-<f9>") 'org-toggle-inline-images)
(global-set-key (kbd "C-x n r") 'narrow-to-region)
(global-set-key (kbd "C-<f10>") 'next-buffer)
(global-set-key (kbd "<f11>") 'org-clock-goto)
(global-set-key (kbd "C-<f11>") 'org-clock-in)
(global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)
(global-set-key (kbd "C-M-r") 'org-capture)
(global-set-key (kbd "C-c r") 'org-capture)

(defun noorul/gen_weekly_report (startPos endPos)
  "Generate weekly report using external python script"
  (interactive "r")
  (let (scriptName)
    (setq scriptName "~/git/sandbox/python/gen_weekly_report.py")
    (shell-command-on-region startPos endPos scriptName "*Weekly Report*"
                             nil nil t)))

(setq org-id-locations-file (convert-standard-filename
                                  (concat user-data-directory ".org-id-locations")))

(use-package org-ql
  :after org
  :commands org-ql-search
  :bind
  ("M-g q" . org-ql-find)
  :config
  (add-to-list 'vertico-multiform-commands
               '(org-ql-find)))

(add-hook 'before-save-hook #'delete-trailing-whitespace nil nil)

(use-package column-enforce-mode
  :config
  (setq column-enforce-column 110)
  :hook (progmode-hook . column-enforce-mode))

(use-package rainbow-delimiters
  :commands rainbow-delimiters-mode
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package flycheck
  :diminish
  :commands (flycheck-mode
             flycheck-next-error
             flycheck-previous-error)
  :init (global-flycheck-mode))

(use-package company
  :after lsp-mode
  :hook ((lsp-mode emacs-lisp-mode) . company-mode)
  :bind (:map company-active-map
	      ("<tab>" . company-complete-selection))
  :config
  (setq company-backends '(company-capf
			   company-yasnippet))
  (global-company-mode))

(use-package scala-mode
  :mode "\\.s\\(cala\\|bt\\)$")

;; Enable sbt mode for executing sbt commands
(use-package sbt-mode
  :commands sbt-start sbt-command
  :config
  ;; WORKAROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
  ;; allows using SPACE when in the minibuffer
  (substitute-key-definition
   'minibuffer-complete-word
   'self-insert-command
   minibuffer-local-completion-map)
   ;; sbt-supershell kills sbt-mode:  https://github.com/hvesalai/emacs-sbt-mode/issues/152
   (setq sbt:program-options '("-Dsbt.supershell=false"))
)

(use-package lsp-mode
  ;; Optional - enable lsp-mode automatically in scala files
  :commands lsp
  :hook  (scala-mode . lsp)
         (lsp-mode . lsp-lens-mode)
  :config (setq lsp-prefer-flymake nil))

;; Add metals backend for lsp-mode
;; (use-package lsp-metals
;;   :after lsp-mode
;;   )

;; Enable nice rendering of documentation on hover
(use-package lsp-ui
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions]
    #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references]
    #'lsp-ui-peek-find-references)
  (setq lsp-ui-doc-enable nil))

;; lsp-mode supports snippets, but in order for them to work you need to use yasnippet
;; If you don't want to use snippets set lsp-enable-snippet to nil in your lsp-mode settings
;;   to avoid odd behavior with snippets and indentation

(use-package yasnippet
  :demand t
  :diminish yas-minor-mode
  :bind (("C-c y d" . yas-load-directory)
         ("C-c y i" . yas-insert-snippet)
         ("C-c y f" . yas-visit-snippet-file)
         ("C-c y n" . yas-new-snippet)
         ("C-c y t" . yas-tryout-snippet)
         ("C-c y l" . yas-describe-tables)
         ("C-c y g" . yas/global-mode)
         ("C-c y m" . yas/minor-mode)
         ("C-c y r" . yas-reload-all)
         ("C-c y x" . yas-expand))
  :bind (:map yas-keymap
              ("C-i" . yas-next-field-or-maybe-expand))
  :mode ("/\\.emacs\\.d/snippets/" . snippet-mode)

  :config
  (yas-load-directory (concat user-emacs-directory "/" "snippets"))
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;; Use the Debug Adapter Protocol for running tests and debugging
(use-package posframe
  :disabled
  ;; Posframe is a pop-up tool that must be manually installed for dap-mode
  )
(use-package dap-mode
  :after lsp-mode
  :hook
  (lsp-mode . dap-mode)
  (lsp-mode . dap-ui-mode)
  )

;; Use the Tree View Protocol for viewing the project structure and triggering compilation
(use-package lsp-treemacs
  :after lsp-mode
  :config
  (setq lsp-metals-treeview-show-when-views-received t
        treemacs-no-delete-other-windows nil)
  )

(defun noorul/ensime-sbt-do-assembly ()
  (interactive)
  (sbt-command "assembly"))

;; (define-key scala-mode-map (kbd "C-c C-b a") 'noorul/ensime-sbt-do-assembly)
;; (define-key scala-mode-map (kbd "C-c C-b h") 'sbt-hydra)

(use-package groovy-mode
  :mode ("Jenkinsfile" . groovy-mode)
  :interpreter ("groovy" . groovy-mode)
  :config
  (setq
   groovy-indent-offset 4))

(use-package lsp-java
  :after lsp-mode
  :init
  (add-hook 'java-mode-hook (lambda ()
                              (flycheck-mode +1)
                              (lsp)))
  :config

  ;; Do not organize imports on file save
  (setq lsp-java-save-action-organize-imports nil)
  (setq lsp-java-vmargs
        (list
         "-noverify"
         "-Xmx1G"
         "-XX:+UseG1GC"
         "-XX:+UseStringDeduplication"
         "-javaagent:/Users/noorul/.m2/repository/org/projectlombok/lombok/1.18.30/lombok-1.18.30.jar")))

(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(use-package go-mode
  :defer t
  :mode ("\\.go\\'" . go-mode)
  :init
  (add-hook 'go-mode-hook #'lsp-go-install-save-hooks)
  (add-hook 'go-mode-hook #'lsp)
)

(use-package rust-mode
  :defer t
  :mode ("\\.rs\\'" . rust-mode)
  :config
  (setq rust-format-on-save t)
  :init
  (add-hook 'rust-mode-hook
          (lambda () (setq indent-tabs-mode nil)))
  (add-hook 'rust-mode-hook #'lsp))

(use-package expand-region
  :defer t
  :bind ("C-=" . er/expand-region))

(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x G" . magit-status-with-prefix))
  :commands magit-auto-revert-mode
  :custom
  (magit-auto-revert-mode nil)
  (magit-log-margin '(t "%Y-%m-%d %H:%M " magit-log-margin-width t 18))
  :pin melpa
  :init
  (defun magit-status-with-prefix ()
    (interactive)
    (let ((current-prefix-arg '(4)))
      (call-interactively 'magit-status))))

(add-hook
 'magit-mode-hook
 (lambda ()
   ;; Hide "Recent Commits"
   ;; https://github.com/magit/magit/issues/3230
   (magit-add-section-hook 'magit-status-sections-hook
                           'magit-insert-unpushed-to-upstream
                           'magit-insert-unpushed-to-upstream-or-recent
                           'replace)))

(use-package git-timemachine
    :commands git-timemachine)

(use-package projectile
  :diminish
  :defer 5
  :bind-keymap ("C-c p" . projectile-command-map)
  :init
  (setq projectile-cache-file "~/.config/emacs/data/projectile.cache")
  (setq projectile-known-projects-file "~/.config/emacs/data/projectile-bookmarks.eld")
  :config
  (setq projectile-enable-caching t)
  (setq projectile-globally-ignored-files (quote ("TAGS" "GPATH" "GRTAGS" "GTAGS" "ID")))
  (setq projectile-use-git-grep t)
  ;; (setq projectile-completion-system 'ivy)
  (projectile-global-mode))

(use-package helm-projectile
  :disabled t
  :config
  (setq projectile-completion-system 'helm)
  (setq projectile-switch-project-action (quote helm-projectile))
  (helm-projectile-on))

(use-package helm-ag
  :disabled t)

;; (use-package counsel-projectile
;;   :after (counsel projectile)
;;   :config
;;   (counsel-projectile-mode 1))

(use-package git-messenger
  :defer t
  :bind (("C-x v m" . git-messenger:popup-message))
  :init (setq git-messenger:show-detail t))

(setenv "PYTHONPATH"
        (concat
         (if (getenv "PYTHONPATH") path-separator "")
         (getenv "PYTHONPATH")))
(use-package lsp-mode
  :commands lsp
  :config
  (setq lsp-idle-delay 0.5
        lsp-enable-symbol-highlighting t
        lsp-enable-snippet nil  ;; Not supported by company capf, which is the recommended company backend
        lsp-pylsp-configuration-sources "flake8"
        lsp-pylsp-plugins-flake8-enabled t
        lsp-pylsp-plugins-pycodestyle-enabled nil
        lsp-pylsp-plugins-mccabe-enabled nil)
  (lsp-register-custom-settings
   '(
     ;; Disable these as they're duplicated by flake8
     ("pylsp.plugins.pycodestyle.enabled" nil t)
     ("pylsp.plugins.mccabe.enabled" nil t)
     ("pylsp.plugins.pyflakes.enabled" nil t)))
  (define-key lsp-mode-map (kbd "C-c s") lsp-command-map)
  (require 'dap-python)
  (defun dap-python--pyenv-executable-find (command)
    (executable-find "python"))

  :hook
  ((python-mode . lsp)
   (lsp-mode . lsp-enable-which-key-integration)))

(use-package pyvenv
  :commands pyvenv-activate
  :config
  (setq pyvenv-mode-line-indicator
        '(pyvenv-virtual-env-name ("[venv:" pyvenv-virtual-env-name "] ")))
  (pyvenv-mode +1))


(defun flymake-get-file-name-mode-and-masks (file-name)
  "Return the corresponding entry from `flymake-allowed-file-name-masks'."
  (unless (stringp file-name)
    (error "Invalid file-name"))
  (let ((fnm flymake-allowed-file-name-masks)
        (mode-and-masks nil)
        (matcher nil))
    (while (and (not mode-and-masks) fnm)
      (setq matcher (car (car fnm)))
      (if (or (and (stringp matcher) (string-match matcher file-name))
              (and (symbolp matcher) (equal matcher major-mode)))
          (setq mode-and-masks (cdr (car fnm))))
      (setq fnm (cdr fnm)))
    (flymake-log 3 "file %s, init=%s" file-name (car mode-and-masks))
    mode-and-masks))

;;(add-to-list 'flymake-allowed-file-name-masks '(python-mode elpy-flymake-python-init))
(setq python-check-command "pycheckers")
;;(add-hook 'python-mode-hook 'auto-complete-mode)

(use-package python-pytest
  :after projectile
  :bind ("C-c s t" . python-pytest-popup)
  :custom
  (python-pytest-executable "pytest.sh"))

(use-package ruby-mode
  :ensure nil
  :after lsp-mode
  :hook ((ruby-mode . lsp-deferred)))

(use-package inf-ruby)

(use-package ruby-test-mode
  :after ruby-mode
  :diminish ruby-test-mode
  :config
  (defun amk-ruby-test-pretty-error-diffs (old-func &rest args)
    "Make error diffs prettier."
    (let ((exit-status (cadr args)))
      (apply old-func args)
      (when (> exit-status 0)
        (diff-mode)
        ;; Remove self
        (advice-remove #'compilation-handle-exit #'amk-ruby-test-pretty-error-diffs))))

  (defun amk-ruby-test-pretty-error-diffs-setup (old-func &rest args)
    "Set up advice to enable pretty diffs when tests fail."
    (advice-add #'compilation-handle-exit :around #'amk-ruby-test-pretty-error-diffs)
    (apply old-func args))

  (advice-add #'ruby-test-run-command :around #'amk-ruby-test-pretty-error-diffs-setup))

(setq vc-follow-symlinks t)

(use-package ediff
  :init
  (defvar ctl-period-equals-map)
  (define-prefix-command 'ctl-period-equals-map)
  (bind-key "C-. =" #'ctl-period-equals-map)
  (setq ediff-combination-pattern
        (quote
         ("<<<<<<< A: HEAD" A "||||||| Ancestor" Ancestor "=======" B ">>>>>>> B: Incoming")))
  (setq ediff-diff-options "-w")
  (setq ediff-highlight-all-diffs nil)
  (setq ediff-show-clashes-only t)
  (setq ediff-window-setup-function (quote ediff-setup-windows-plain))

  :bind (("C-. = b" . ediff-buffers)
         ("C-. = B" . ediff-buffers3)
         ("C-. = c" . compare-windows)
         ("C-. = =" . ediff-files)
         ("C-. = f" . ediff-files)
         ("C-. = F" . ediff-files3)
         ("C-. = r" . ediff-revision)
         ("C-. = p" . ediff-patch-file)
         ("C-. = P" . ediff-patch-buffer)
         ("C-. = l" . ediff-regions-linewise)
         ("C-. = w" . ediff-regions-wordwise))

  :config
  (use-package ediff-keep
    :load-path "~/github.com/jwiegley/dot-emacs/lisp"))

(use-package yaml-mode
    :mode "\\.ya?ml\\'")

(use-package dockerfile-mode
  :mode ("\\`Dockerfile" . dockerfile-mode))

(use-package docker-tramp
  :if (version< emacs-version "29.0")
  :after docker)

(use-package docker
  :bind ("C-c d" . docker)
  :init
  (setq docker-show-status nil
        docker-run-async-with-buffer-function 'docker-run-async-with-buffer-shell))

(defun my-elisp-indent-or-complete (&optional arg)
        (interactive "p")
        (call-interactively 'lisp-indent-line)
        (unless (or (looking-back "^\\s-*")
                    (bolp)
                    (not (looking-back "[-A-Za-z0-9_*+/=<>!?]+")))
          (call-interactively 'completion-at-point)))

(bind-key "<tab>" #'my-elisp-indent-or-complete emacs-lisp-mode-map)

(use-package macrostep
  :bind ("C-c e m" . macrostep-expand))

(use-package magit-popup
  :pin melpa
  :after (magit kubernetes))

(use-package kubernetes
  :load-path "~/github.com/noorul/kubernetes-el"
  :commands (kubernetes-overview
             kubernetes-display-pods
             kubernetes-display-configmaps
             kubernetes-display-secrets)
  :bind (("C-c K" . kubernetes-overview))
  :config
  (setq kubernetes-poll-frequency 3600
        kubernetes-redraw-frequency 3600))

(use-package color-identifiers-mode
  :disabled t
  :diminish color-identifiers-mode
  :init (add-hook 'after-init-hook 'global-color-identifiers-mode))

(use-package protobuf-mode
  :mode "\\.proto\\'")

(use-package js2-mode
  :mode "\\.js\\'"
  :bind (("C-c s j" . nl/counsel-ag-js))
  :preface
  (defun js-filename-p (filename)
    (string-match "\.js$" filename))

  (defun nl/counsel-ag-js ()
    "Perform counsel-ag on the project's JavaScript files."
    (interactive)
    (counsel-ag "" (projectile-project-root) "--js"))

  (defun nl/counsel-ag-js-spec ()
    "Perform counsel-ag on the project's JavaScript files."
    (interactive)
    (counsel-ag "" (projectile-project-root) "-G Spec.js$"))

  (defun nl/webpack-find-file ()
    "From a webpack failure backtrace, opens the file under the cursor at the line specified."
    (interactive)
    (let (p1 p2 err-line filename file-with-proj-path)
      (save-some-buffers t)
      (setq p1 (line-beginning-position) )
      (setq p2 (line-end-position) )
      (setq err-line (buffer-substring-no-properties p1 p2))
      (save-match-data ; is usually a good idea
        (and (string-match "^\\(ERROR\\|WARNING\\) in \\.\\/\\([^$]+\\)" err-line)
             (setq filename (match-string 2 err-line))))
      (message "filename: %s" (expand-file-name filename (projectile-project-root)))
      (ace-select-window)
      (find-file (expand-file-name filename (projectile-project-root)))
      (goto-char (point-min))))

  (defun nl/webpack-find-next-error ()
    "searches for the next line starting with ERROR and then calls nl/webpack-find-file."
    (interactive)
    (next-line)
    (while (re-search-forward "^ERROR" nil t)
      (goto-char (match-beginning 0))
      (recenter 0)
      (nl/webpack-find-file)))

  :init
  (setq js2-global-externs '("define"
                             "jasmine"
                             "describe"
                             "fdescribe"
                             "fail"
                             "beforeEach"
                             "afterEach"
                             "inject"
                             "expect"
                             "spyOn"
                             "it"
                             "fit"
                             "xdescribe"
                             "xit"))
  :config
  (setq javascript-common-imenu-regex-list
        '(("Controller" "[. \t]controller([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Controller" "[. \t]controllerAs:[ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Filter" "[. \t]filter([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("State" "[. \t]state[(:][ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Factory" "[. \t]factory([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Service" "[. \t]service([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Module" "[. \t]module( *['\"]\\([a-zA-Z0-9_.]+\\)['\"], *\\[" 1)
          ("ngRoute" "[. \t]when(\\(['\"][a-zA-Z0-9_\/]+['\"]\\)" 1)
          ("Directive" "[. \t]directive([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Event" "[. \t]\$on([ \t]*['\"]\\([^'\"]+\\)" 1)
          ("Config" "[. \t]config([ \t]*function *( *\\([^\)]+\\)" 1)
          ("Config" "[. \t]config([ \t]*\\[ *['\"]\\([^'\"]+\\)" 1)
          ("OnChange" "[ \t]*\$(['\"]\\([^'\"]*\\)['\"]).*\.change *( *function" 1)
          ("OnClick" "[ \t]*\$([ \t]*['\"]\\([^'\"]*\\)['\"]).*\.click *( *function" 1)
          ("Watch" "[. \t]\$watch( *['\"]\\([^'\"]+\\)" 1)
          ("Function" "function[ \t]+\\([a-zA-Z0-9_$.]+\\)[ \t]*(" 1)
          ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*function[ \t]*(" 1)
          ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)([^)'\"]*)[ \t]*{[ \t]*$" 1)
          ("Task" "[. \t]task([ \t]*['\"]\\([^'\"]+\\)" 1)
          ;;("Testcase" "^[ \t]*it(['\"][^']*['\"][ \t]*,[ \t]*function([^)'\"]*)[ \t]*{$" 1)
          ))

  ;; js-mode imenu enhancement
  ;; @see http://stackoverflow.com/questions/20863386/idomenu-not-working-in-javascript-mode
  (defun nl-js-imenu-make-index ()
    (save-excursion
      (imenu--generic-function javascript-common-imenu-regex-list)))

  (defun nl/common-prog-mode-settings ())
  (defun nl/javascript-mode-hook ()
    (nl/setup-indent 2) ; indent 2 spaces width
    (setq comment-multi-line t
          mode-name "JS2")
    (define-key js-mode-map [remap indent-new-comment-line]
      'c-indent-new-comment-line)
    (setq indent-tabs-mode nil)
    (setq imenu-create-index-function 'nl-js-imenu-make-index)
    (prettier-js-mode)
    (flycheck-mode t))

  ;;(eval-after-load 'js2-mode
  ;;  '(define-key js2-mode-map (kbd "RET") 'js2-line-break))

  ;;(setq ac-js2-evaluate-calls t)

  (setq-default js2-mode-show-parse-errors t)
  (setq-default js2-strict-missing-semi-warning t)
  (setq-default js2-strict-trailing-comma-warning t)


  :custom
  (js2-basic-offset 2)
  (js2-bounce-indent-p nil)
  (js2-highlight-level 3)
  :hook ((js2-mode . fic-mode)
         ;;(js2-mode-hook  . ac-js2-mode)
         (js2-mode . nl/javascript-mode-hook)
         (js2-mode . nl/common-prog-mode-settings)))

(use-package js2-refactor
  :after js2-mode
  :diminish js2-refactor-mode
  :hook (js-mode . js2-refactor-mode)
  :config
  (js2r-add-keybindings-with-prefix "C-c C-m"))

(use-package prettier-js
  :after (typescript-mode web-mode js-mode)
  :hook ((typescript-mode . prettier-js-mode)))

(use-package tern
  :commands tern-mode
  :diminish tern-mode
  :hook (js2-mode . tern-mode))

(use-package jq-mode)

(use-package typescript-mode
  :hook
  (typescript-mode . column-enforce-mode)
  (typescript-mode . rainbow-delimiters-mode)
  (typescript-mode . nl/typescript-mode)
  :preface
  (defun nl/typescript-mode ()
    (flycheck-mode +1)
    (eldoc-mode +1)
    (company-mode +1)
    (prettier-js-mode)
    (nl/common-prog-mode-settings)

    ;; need to override the value set in typescript-mode.el
    (push '(typescript-tsc-pretty
            "^\\(?:\\(Error\\|Warning\\)\\):[[:blank:]]\\([^:]+\\):\\([[:digit:]]+\\):\\([[:digit:]]+\\)"
            2 3 4 1)
          compilation-error-regexp-alist-alist)

    (setq prettify-symbols-alist nl-typescript-prettify-symbols)
    (prettify-symbols-mode))
  :config
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . typescript-mode))
  (setq prettify-symbols-unprettify-at-point 'right-edge
        company-tooltip-align-annotations t ;; aligns annotation to the right hand side
        flycheck-check-syntax-automatically '(save mode-enabled))
  (setq-default typescript-indent-level 2)

  (defconst nl-typescript-prettify-symbols
    '(("=>" . ?⇒)
      ("<=" . ?≤)
      (">=" . ?≥)
      ("===" . ?≡)
      ("!" . ?¬)
      ("!=" . ?≠)
      ("!==" . ?≢)
      ("&&" . ?∧)
      ("||" . ?∨))))

(use-package tide
  :after (typescript-mode company flycheck)
  :bind (:map tide-mode-map
              ("C-c C-t f" . tide-fix)
              ("C-c C-t n" . tide-nav)
              ("C-c C-t o" . tide-organize-imports)
              ("C-c C-t r" . tide-rename-symbol)
              ("C-c C-t x" . tide-references))
  :init
  (use-package typescript-mode)

  :config
  (setq tide-sync-request-timeout 5
        tide-server-max-response-length 204800)

  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)

  (defun nl-tide-mode-hook ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    (company-mode +1)
    (prettier-js-mode)
    (nl/common-prog-mode-settings)
    (setq prettify-symbols-alist nl-typescript-prettify-symbols-alist
          prettify-symbols-unprettify-at-point 'right-edge
          company-tooltip-align-annotations t) ;; aligns annotation to the right hand side
    (setq-default typescript-indent-level 2))

  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (typescript-mode . nl-tide-mode-hook)
         (typescript-mode . column-enforce-mode)
         (typescript-mode . rainbow-delimiters-mode)))

(use-package web-mode
  :mode (("\\.html?\\'" . web-mode)
         ("\\.json\\'" . web-mode))
  :bind ("C-c s h" . nl/counsel-ag-html)
  :hook (web-mode  . nl/web-mode-hook)
  :preface
  (defun html-filename-p (filename)
    (string-match "\.html$" filename))

  (defun nl/counsel-ag-html ()
    "Perform counsel-ag on the project's HTML files."
    (interactive)
    (counsel-ag "" (projectile-project-root) "--html"))

  (defun nl/web-mode-hook ()
    "Hooks for Web mode."
    (setq web-mode-markup-indent-offset 2)
    (prettier-js-mode)
    (yas-minor-mode))

  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2
        web-mode-enable-auto-closing t
        web-mode-enable-auto-quoting t
        web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev))))

  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'typescript-tslint 'web-mode))

(use-package csv-mode
  :mode "\\.csv$")

(setq nxml-child-indent 4
      nxml-attribute-indent 4)

(use-package keytar
  :after lsp-grammarly)

(use-package lsp-grammarly
  :commands lsp)

(use-package pdf-tools
  :defer t
  :mode "\\.pdf$"
  :config
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations t)
  :init
  (pdf-tools-install :no-query))

(use-package async :defer t)

;; which email addresses to detect for special highlighting
(defvar noorul/mail-addresses "")

(defun noorul/switch-to-gnus ()
  (interactive)
  (if (get-buffer "*Group*")
      (progn (switch-to-buffer "*Group*"))
    (gnus)))

(use-package gnus
  :commands gnus

  :bind (:map gnus-summary-mode-map
              ("\C-c\C-g" . noorul/move-to-gmail-trash)
              ("\C-c\C-o" . noorul/archive-office-inbox)
              ("\C-c\C-g" . noorul/move-to-gmail-trash))
;;  :bind (:map gnus-group-mode-map
;;              ("j" noorul/gnus-jump-to-group))
;;
  :config
  (gnus-delay-initialize)
  (add-to-list 'org-modules 'ol-gnus)
  (org-load-modules-maybe t)
  (setq gnus-check-new-newsgroups nil  ;; Save some startup time
        ;; I do not want gnus to use full window
        gnus-use-full-window nil

        ;; To save some time on exit. I don't use any other news reader.
        gnus-save-newsrc-file nil

        gnus-group-line-format "%M%S%p%P%(%-60,60g%)%-5uy %ud\n"
        gnus-sum-thread-tree-single-indent "* "
        gnus-sum-thread-tree-single-leaf "+-> ")


  (defun gnus-user-format-function-j (headers)
    ;; prefix each post depending on whether to, cc or Bcc to
    (let ((to (gnus-extra-header 'To headers)))
      (if (string-match noorul/mail-addresses to)
          (if (string-match "," to) "~" "»")
        (if (or (string-match noorul/mail-addresses
                              (gnus-extra-header 'Cc headers))
                (string-match noorul/mail-addresses
                              (gnus-extra-header 'BCc headers)))
            "~"
          " "))))
  (defun gnus-user-format-function-y (headers)
    (if (string-match "^nnfolder" gnus-tmp-group)
        ""
      (concat "(" gnus-tmp-number-of-unread ")")
      )
    )

  (defun gnus-user-format-function-d (headers)
    (let ((time (gnus-group-timestamp gnus-tmp-group)))
      (if time
          (format-time-string "%b %d  %H:%M" time)
        ""
        )
      )
    )

  (setq gnus-summary-line-format "%U%R%z%-2,2uj|%-12,12&user-date; |%-15,15f |%-12,12B %s\n"
        gnus-sum-thread-tree-false-root "  "
        gnus-sum-thread-tree-indent " "
        gnus-sum-thread-tree-root "☢"
        gnus-sum-thread-tree-leaf-with-other "├► "
        gnus-sum-thread-tree-single-leaf "╰► "
        gnus-sum-thread-tree-vertical "│")
  (setq gnus-extra-headers '(To X-NextAction X-Waiting)
        nnmail-extra-headers gnus-extra-headers
        nntp-nov-is-evil t
        gnus-thread-sort-functions 'gnus-thread-sort-by-most-recent-date
        gnus-summary-check-current t
        gnus-auto-center-summary nil
        gnus-thread-indent-level 1)

  (add-hook 'gnus-summary-mode-hook 'turn-on-gnus-mailing-list-mode)

  ;; Fetch only part of the article if we can.  I saw this in someone
  ;; else's .gnus
  (setq gnus-read-active-file 'some)

  ;; Tree view for groups.  I like the organisational feel this has.
  (add-hook 'gnus-group-mode-hook 'gnus-topic-mode)

  ;; Threads!  I hate reading un-threaded email -- especially mailing
  ;; lists.  This helps a ton!
  (setq gnus-summary-thread-gathering-function
        'gnus-gather-threads-by-subject)

  ;; Also, I prefer to see only the top level message.  If a message has
  ;; several replies or is part of a thread, only show the first
  ;; message.  'gnus-thread-ignore-subject' will ignore the subject and
  ;; look at 'In-Reply-To:' and 'References:' headers.
  ;;(setq gnus-thread-hide-subtree t)
  (setq gnus-thread-ignore-subject t)

  ;; 20030627: Changed kill mark to just -1
  ;; I find adaptive scoring very useful for keeping killed (boring)
  ;; threads out of sight. I do have some keyword scoring rules that
  ;; can bring some threads back up, though.

  (setq gnus-use-adaptive-scoring t)
  (setq gnus-default-adaptive-score-alist
        '((gnus-unread-mark)
          (gnus-ticked-mark (subject 5))
          (gnus-dormant-mark (subject 5))
          (gnus-del-mark (subject -1))
          (gnus-killed-mark (subject -1))
          (gnus-catchup-mark (subject -1))))
  (setq gnus-gcc-mark-as-read t)

  ;; Inline images?
  (setq mm-attachment-override-types '("image/.*"))

  ;; don't like html or richtext
  (when (boundp 'mm-automatic-display)
    (setq mm-discouraged-alternatives '("text/html" "text/richtext")
          mm-automatic-display (remove "text/html" mm-automatic-display)))

  (defun my-async-short-unread-p (data)
    "Return non-nil for short, unread articles."
    (and (gnus-data-unread-p data)
         (< (mail-header-lines (gnus-data-header data))
            100)))
  (setq gnus-visible-headers "^From:\\|^To:\\|^Subject:\\|^Date:")

  (setq gnus-summary-exit-hook 'gnus-summary-bubble-group)

  ;(setq nnmail-treat-duplicates 'delete)
  (setq nnmail-treat-duplicates nil)
  (setq gnus-save-duplicate-list t)

  ;; Lots of things I can twiddle depending on how much I feel
  ;; like pretending other people observe netiquette. =)
  (setq gnus-treat-fill-article nil)
  (setq gnus-treat-fill-long-lines nil)
  (setq gnus-treat-capitalize-sentences nil)
  (setq gnus-treat-date-local 'head)
  (setq gnus-treat-hide-headers 'head)
  (setq gnus-treat-hide-boring-headers 'head)
  (setq gnus-treat-date-english t)

  (setq gnus-boring-article-headers '(empty followup-to reply-to to-address date long-to many-to))

  ;; I browse by thread, so I tend to remember thread context; if I need
  ;; more info, I can just unhide cited text.
  (setq gnus-treat-hide-citation t)

  (add-hook 'nnmail-prepare-incoming-header-hook
            'nnmail-remove-list-identifiers)
  (setq nnmail-list-identifiers '("[.*] "))
  (setq gnus-list-identifiers '("\\[.*\\] "))

  (setq nnslashdot-threshold 4)
  (setq nnslashdot-threaded nil)

  (setq gnus-always-read-dribble-file t)
  (setq gnus-asynchronous t)
  (setq  gnus-search-use-parsed-queries t)

  (setq gnus-activate-foreign-newsgroups nil)
  (setq gnus-summary-display-while-building 10)
  (setq gnus-gcc-mark-as-read t)

  ;;;_+ GTD action hack - Stolen from Sacha Chua

  (defun sacha/gnus-next-action (header)
    "Given a Gnus message header, returns priority mark.
  If I am the only recipient, return \"!\".
  If I am one of a few recipients, but I'm listed in To:, return \"*\".
  If I am one of a few recipients, return \"/\".
  If I am one of many recipients, return \".\".
  Else, return \" \"."
    (let ((my-action (cdr (assoc 'X-NextAction (mail-header-extra header))))
          (waiting (cdr (assoc 'X-Waiting (mail-header-extra header)))))
      (cond
       (my-action "<")
       (waiting ">")
       (t " "))))

  (defalias 'gnus-user-format-function-A 'sacha/gnus-next-action)

  (add-to-list 'nnmail-extra-headers 'To)
  (add-to-list 'nnmail-extra-headers 'Cc)

  (defun sacha/gnus-count-recipients (header)
    "Given a Gnus message header, returns priority mark.
  If I am the only recipient, return \"!\".
  If I am one of a few recipients, but I'm listed in To:, return \"*\".
  If I am one of a few recipients, return \"/\".
  If I am one of many recipients, return \".\".
  Else, return \" \"."
    (let* ((to (or (cdr (assoc 'To (mail-header-extra header))) ""))
           (cc (or (cdr (assoc 'Cc (mail-header-extra header))) ""))
           (threshold 5))
      (cond
       ((string-match gnus-ignored-from-addresses to)
        (let ((len (length (bbdb-split to ","))))
          (cond
           ((= len 1) "!")
           ((< len threshold) "*")
           (t "/"))))
       ((string-match gnus-ignored-from-addresses
                      (concat to ", " cc))
        (if (< (length (bbdb-split (concat to ", " cc) ","))
               threshold)
            "-"
          "."))
       (t " "))))

  ;(defalias 'gnus-user-format-function-s 'sacha/gnus-count-recipients)

  (setq gnus-invalid-group-regexp "[:`'\"]\\|^$")
  (setq gnus-ignored-newsgroups "")

  (setq gnus-select-method '(nnnil))

  (setq gnus-secondary-select-methods
        '((nnimap "work"
                  (nnimap-address "work")
                  (nnimap-server-port 143)
                  (nnimap-stream network)
                  (nnimap-authinfo-file "~/.authinfo"))
          (nnimap "noorul"
                  (nnimap-address "personal")
                  (nnimap-server-port 143)
                  (nnimap-stream network)
                  (nnimap-authinfo-file "~/.authinfo"))))

  ;; gnus-posting-styles are present in work.org and personal.org
  ;; because they contain sensitive information like e-mail address

  ;; Available SMTP accounts.
  (defun noorul/get-smtp-accounts ()
    (let ((result))
      (with-temp-buffer
        (insert-file-contents "~/.smtp-accounts")
        (goto-char (point-min))
        (while (not (eobp))
          (push (split-string (thing-at-point 'line)) result)
          (forward-line 1))
        result)))

  (setq smtp-accounts (funcall 'noorul/get-smtp-accounts))

  (setq send-mail-function 'smtpmail-send-it
        message-send-mail-function 'smtpmail-send-it
        smtpmail-local-domain      nil
        smtpmail-debug-info t
        smtpmail-debug-verb t)

  (defun set-smtp-plain (server port user password)
    "Set related SMTP variables for supplied parameters."
    (message "Setting SMTP server to `%s:%s' for user `%s'."
             server port user)
    (setq smtpmail-smtp-server server
          smtpmail-smtp-service port
          smtpmail-auth-credentials (list (list server port user password))
          smtpmail-starttls-credentials nil)
    (message "Setting SMTP server to `%s:%s' for user `%s'."
             server port user))

  (defun set-smtp-ssl (server port user password key cert)
    "Set related SMTP and SSL variables for supplied parameters."
    (message "`%s:%s:%s:%s:%s:%s'" server port user password key cert)
    (setq starttls-use-gnutls t
          starttls-gnutls-program "gnutls-cli"
          starttls-extra-arguments nil
          smtpmail-smtp-server server
          smtpmail-smtp-user user
          smtpmail-smtp-service port
          smtpmail-auth-credentials (list (list server port user password))
          smtpmail-starttls-credentials (list (list server port key cert)))
    (message
     "Setting SMTP server to `%s:%s' for user `%s'. (SSL enabled.)"
     server port user))

  (defun change-smtp ()
    "Change the SMTP server according to the current from line."
    (save-excursion
      (loop with from = (save-restriction
                          (message-narrow-to-headers)
                          (message-fetch-field "from"))
            for (acc-type address . auth-spec) in smtp-accounts
            when (string-match address from)
            do (cond
                ((string= acc-type "plain")
                 (return (apply 'set-smtp-plain auth-spec)))
                ((string= acc-type "ssl")
                 (return (apply 'set-smtp-ssl auth-spec)))
                (t (error "Unrecognized SMTP account type: `%s'." acc-type)))
            finally (error "Cannot interfere SMTP information."))))

  (add-hook 'message-send-hook 'change-smtp)

  (setq gnus-large-newsgroup nil)

  (setq gnus-message-archive-group nil)

  (defun noorul/move-to-gmail-trash ()
    (interactive)
    (let ((prefix (funcall gnus-move-group-prefix-function
                           gnus-newsgroup-name)))
      (let ((trash (concat prefix "Trash")))
        (gnus-summary-move-article nil trash))))


  (defun noorul/gnus-goto-personal-inbox ()
    (interactive)
    (gnus-group-read-group t t "nnimap+noorul:GmailInbox"))

  (defun noorul/gnus-goto-gmail-inbox ()
    (interactive)
    (gnus-group-read-group t t "nnimap+gmail:INBOX"))

  (defun noorul/compose-personal-mail ()
    (interactive)
    (gnus-group-mail 1))

  (setq gnus-list-identifiers nil)

  (defun noorul/gnus-jump-to-group ()
    (interactive)
    (let
        ((collection gnus-active-hashtb)
      choices group)
      (if (listp collection)
          (dolist (symbol collection)
            (setq group (symbol-name symbol))
            (push (if (string-match "[^\000-\177]" group)
                      (gnus-group-decoded-name group)
                    group)
                  choices))
        (mapatoms (lambda (symbol)
                    (setq group (symbol-name symbol))
                    (push (if (string-match "[^\000-\177]" group)
                              (gnus-group-decoded-name group)
                            group)
                          choices))
                  collection))
        (gnus-group-jump-to-group
         (ido-completing-read
          "Group: " choices nil t)))))

(use-package offlineimap
  :commands offlineimap
  :config (setq offlineimap-command "/usr/local/bin/offlineimap -u machineui"))

(use-package org-msg
  :disabled

  :init (setq org-msg-options "html-postamble:nil H:5 num:nil ^:{} toc:nil"
              org-msg-startup "hidestars indent inlineimages"
              org-msg-greeting-fmt "\nHi *%s*,\n\n"
              org-msg-greeting-name-limit 3)
  (when (and org-contacts-enable-completion
             (boundp 'completion-at-point-functions))
    (add-hook 'org-msg-edit-mode-hook 'org-contacts-setup-completion-at-point))

  :config
  (org-msg-mode))

(use-package esh-toggle
  :load-path "~/github.com/jwiegley/dot-emacs/lisp"
  :bind ("C-x C-z" . eshell-toggle))

(use-package eshell-git-prompt
  :disabled
  :config
  (eshell-git-prompt-use-theme 'robbyrussell))

(use-package eshell
  :commands (eshell eshell-command)
  :init (setq eshell-hist-ignoredups t
              eshell-history-size 50000)
  :config
  (add-hook 'eshell-mode-hook
            '(lambda () (define-key eshell-mode-map (kbd "M-r") 'counsel-esh-history))))

(use-package which-key
  :defer 5
  :diminish
  :commands which-key-mode
  :config
  (which-key-mode))

(bind-key "C-c ;" 'comment-or-uncomment-region)

(defun duplicate-line ()
  "Duplicate the line containing point."
  (interactive)
  (save-excursion
    (let (line-text)
      (goto-char (line-beginning-position))
      (let ((beg (point)))
        (goto-char (line-end-position))
        (setq line-text (buffer-substring beg (point))))
      (if (eobp)
          (insert ?\n)
        (forward-line))
      (open-line 1)
      (insert line-text))))

(bind-key "C-x C-d" 'duplicate-line)

;;;_ , ledger

(use-package "ledger-mode"
  :commands ledger-mode
  :mode ("/finance/accounts\\.dat" . ledger-mode)
  :config
  (progn
    (ledger-reports-add "monthly budget" "ledger -y '%a %e %b %Y' --budget -M -p \"this month\" register Expenses Assets:LivretA")
    (ledger-reports-add "monthly unbudgeted" "ledger -y '%a %e %b %Y'  --unbudgeted -M -p \"this month\"  register Expenses Income")
    (ledger-reports-add "by Payee" "ledger -y '%a %e %b %Y' register -P")
    (ledger-reports-add "uncleared" "ledger -y '%a %e %b %Y' register -U")
    (ledger-reports-add "bal" "ledger -y '%a %e %b %Y' cleared")
    (ledger-reports-add "monthly expenses" "ledger -y '%b %Y' -M -n reg Expenses")
    (ledger-reports-add "monthly expenses weekly" "ledger -y '%a %e %b %Y' -W -n reg Expenses -p \"this month\"")
    (ledger-reports-add "monthly expenses daily" "ledger -y '%a %e %b %Y' -D -n reg Expenses -p \"this month\"")
    (ledger-reports-add "net worth" "ledger -X INR balance ^Assets ^Liabilities")
    (ledger-reports-add "wallet" "ledger balance ^Assets:Wallet ^Assets:Sajida:Wallet")
    (ledger-reports-add "sajida" "ledger reg -p 'this month' Assets:Sajida:Wallet")
    (ledger-reports-add "current month expenses" "ledger --aux-date -p 'this month' -S -a reg Expenses")
    (ledger-reports-add "current month food expenses" "ledger --aux-date -p 'this month' -S -a -s reg Expenses:Food")
    (ledger-reports-add "monthly food expenses" "ledger -y '%b %Y' -M -n reg Expenses:Food"))
  :init
  (progn
    (setq ledger-file "~/github.com/noorul/notebook/finance/accounts.dat")
    (setq ledger-post-use-ido t)

    (add-hook 'ledger-mode-hook
          (lambda ()
            (setq-local tab-always-indent 'complete)
            (setq-local completion-cycle-threshold t)
            (setq-local ledger-complete-in-steps t)))

    (defun my-ledger-open (&optional arg)
      (interactive "p")
      (find-file-other-window ledger-file)
      (goto-char (point-max)))

    (bind-key "C-c L" 'my-ledger-open)))

;;;_ , erc

(use-package erc
  :disabled
  :config
  (progn
    (setq erc-log-channels t)
    (setq erc-log-channels-directory "~/erclog")
    (setq erc-save-buffer-on-part t)
    (setq erc-autojoin-channels-alist
          '((".freenode.net$" . ("#zuul")))))
  :init
  (progn
    (erc-spelling-mode 1)
    (add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)

    (load "~/.erc-auth")

    (defun noorul/xml-escape (s)
      (setq s (replace-regexp-in-string "'" "&apos;"
      (replace-regexp-in-string "\"" "&quot;"
      (replace-regexp-in-string "&" "&amp;"
      (replace-regexp-in-string "<" "&lt"
      (replace-regexp-in-string ">" "&gt" s)))))))

    (defun noorul/erc-notify ()
      (let ((output) (emacs-icon) (notify-command))
           (setq output (buffer-substring (point-min) (point-max)))
           (setq emacs-icon
                 "/usr/local/share/icons/hicolor/32x32/apps/emacs.png")
           (setq notify-command "/usr/local/bin/e-notify-send")
           (if (> (length output) 250)
               (setq output (substring output 0 249)))
           (save-window-excursion
             (cond ((and
                     (file-exists-p notify-command)
                     (not (string-match "changed mode" output))
                     (not (string-match "has joined" output))
                     (not (string-match "now known as" output))
                     (not (string-match "has quit" output)))
                    (shell-command (format
                                    "%s -i %s 'ERC' '%s'"
                                    notify-command
                                    emacs-icon
                                    (noorul/xml-escape output)
                                    ) "*erc-notify-output*"))))))

    ;; (if (or (eq window-system 'X) (eq window-system 'x))
    ;;     (add-hook 'erc-insert-post-hook 'noorul/erc-notify))

    (add-hook 'erc-insert-post-hook 'noorul/erc-notify)

    (add-hook 'erc-mode-hook
              '(lambda ()
                 (define-key erc-mode-map "<tab>" 'erc-complete-word)))))

(use-package eww
  :commands eww
  :config
  (setq eww-search-prefix "https://google.com/search?q="))

(use-package google-this
  :diminish
  :config (google-this-mode 1))

(use-package tls
  :disabled
  :config
  (setq tls-program
        '("openssl s_client -connect %h:%p -no_ssl2 -ign_eof"
          "gnutls-cli --x509cafile %t -p %p %h"
          "gnutls-cli --x509cafile %t -p %p %h --protocols ssl3")))

(use-package restclient
  :mode ("\\.rest\\'" . restclient-mode))

(use-package ob-restclient
  :config
  (org-babel-do-load-languages
   (quote org-babel-load-languages)
   (quote ((restclient . t)))))

(use-package vterm
;;  :load-path "/Users/noorul/github.com/akermu/emacs-libvterm"
  :commands (vterm)
;;             counsel-projectile-switch-project-action-run-vterm)
  :config
  (setq vterm-shell "/bin/zsh"
        vterm-timer-delay 0.01)
  (defun vterm-send-escape ()
    (vterm-send-key "<escape>")))

(let ((work-config-file "~/github.com/noorul/work-emacs-config/work.el"))
 (if (file-exists-p work-config-file)
     (load-file work-config-file)))

(let ((personal-config-file "~/github.com/noorul/work-emacs-config/personal.el"))
 (if (file-exists-p personal-config-file)
     (load-file personal-config-file)))

(defalias 'noorul/record-exercise
   (kmacro "C-SPC <down> <down> M-w C-p C-e <return> C-a C-y C-k C-p M-f M-f M-f M-f C-f S-<down> M-f M-f M-f M-f M-f M-f C-f S-<down> C-p M-f M-f M-f C-f S-<down> C-n C-a C-p"))

(org-agenda "" "c")
(toggle-frame-fullscreen)
(toggle-frame-fullscreen)
