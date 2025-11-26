(setq inhibit-startup-message t  ; Don't show the splash screen
      use-short-answers t        ; Use y or n instead of yes or no
      visible-bell t)            ; Flash Screen instead of Audible Bell

(menu-bar-mode -1)               ; Hide Menu Bar
(tool-bar-mode -1)               ; Hide Tool Bar
(scroll-bar-mode -1)             ; Hide Scroll Bar
(fringe-mode 10)                 ; Add some Space to the Left & Right Border

(global-display-line-numbers-mode 1)      ; Enable Line Numbers
(setq display-line-numbers-type 'visual)  ; Relative Line Numbers
(setq column-number-mode t)               ; Set Column Numbers

(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

;; Install all Packages instead of :ensure t for Every Package
;; Specifiy :ensure nil for Packages which should not be Installed Automatically
(setq use-package-always-ensure t)

(setq modus-themes-mode-line '(accented borderless)
      modus-themes-bold-constructs t
      modus-themes-italic-constructs t
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold intense)
      modus-themes-prompts '(bold intense)
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings t
      modus-themes-region '(bg-only))

;; Load the light theme by default
(load-theme 'modus-operandi-tinted t)

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-undo-system 'undo-redo)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-setup-minibuffer t) ; Enable Evil Mode in MiniBuffer
  :config
  (evil-collection-init))

(use-package engrave-faces)

(use-package mode-line-bell
  :custom
  (mode-line-bell-mode t))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((python . t)))

(setq org-latex-src-block-backend 'engraved)     ; Set src block formatting backend to Engraved
(setq org-latex-engraved-theme 'doom-one-light)  ; Set doom-one-light theme for Latex Code Block Export

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)  ; ESC quits Prompts (Partially Works)
