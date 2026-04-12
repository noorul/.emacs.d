(setq frame-inhibit-implied-resize 'force)
(setq frame-resize-pixelwise t)
(push '(fullscreen . fullboth) default-frame-alist)
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)

(defvar noorul--file-name-handler-alist file-name-handler-alist)
(defvar noorul--vc-handled-backends vc-handled-backends)
(setq file-name-handler-alist nil
      vc-handled-backends nil)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1000 1000)
                  gc-cons-percentage 0.1
                  file-name-handler-alist noorul--file-name-handler-alist
                  vc-handled-backends noorul--vc-handled-backends)))

(setq native-comp-jit-compilation-deny-list '(".*org-element.*"))
(setq native-comp-async-report-warnings-errors 'silent)

(setq package-enable-at-startup t)
