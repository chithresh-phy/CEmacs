;; Disabling the built-in Package.el (for elpaca)
(setq package-enable-at-startup nil)

;; UI
(tool-bar-mode -1)               ; Disable toolbar
(menu-bar-mode -1)               ; Disable menubar
(scroll-bar-mode -1)             ; Disable scrollbar
(fringe-mode 10)                 ; Add some space to the left & right border
(setq inhibit-splash-screen t)   ; Don't show startup message

;; Start emacs maximized
(push '(fullscreen . maximized) default-frame-alist)
