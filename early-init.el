;;; -*- lexical-binding: t -*-

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
;; Keep Git so package-vc (use-package :vc) can clone during init.
(setq file-name-handler-alist nil
      vc-handled-backends '(Git))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1000 1000)
                  gc-cons-percentage 0.1
                  file-name-handler-alist noorul--file-name-handler-alist
                  vc-handled-backends noorul--vc-handled-backends)))

(setq native-comp-jit-compilation-deny-list '(".*org-element.*"))
(setq native-comp-async-report-warnings-errors 'silent)
;; libgccjit needs this before the first trampoline/eln is compiled,
;; so it must be set early (libemutls_w.a lives in a per-target subdir).
(let ((dirs (append '("/opt/homebrew/lib/gcc/current")
                    (file-expand-wildcards
                     "/opt/homebrew/lib/gcc/current/gcc/*/*" t)))
      (old (getenv "LIBRARY_PATH")))
  (setenv "LIBRARY_PATH"
          (string-join (if old (append dirs (list old)) dirs) ":")))

(setq package-enable-at-startup t)
