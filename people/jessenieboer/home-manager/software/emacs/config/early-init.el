(setq user-emacs-directory
      (expand-file-name "emacs/" (or (getenv "XDG_CONFIG_HOME") "~/.config")))
(make-directory user-emacs-directory t)

(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "emacs/auto-save/" 
                                 (or (getenv "XDG_CACHE_HOME") "~/.cache")) t)))
(make-directory (expand-file-name "emacs/auto-save/" 
                                  (or (getenv "XDG_CACHE_HOME") "~/.cache")) t)

;; Auto-save files (temporary, can be cleaned more aggressively)
(setq auto-save-list-file-prefix
      (expand-file-name "emacs/auto-save/.saves-" 
                        (or (getenv "XDG_STATE_HOME") "~/.local/state")))

;; Backups (infrequent, should survive cache clear)
(setq backup-directory-alist
      `(("." . ,(expand-file-name "emacs/backups/" 
                                  (or (getenv "XDG_STATE_HOME") "~/.local/state")))))
(make-directory (expand-file-name "emacs/backups/" 
                                  (or (getenv "XDG_STATE_HOME") "~/.local/state")) t)

(setq savehist-file
      (expand-file-name "emacs/savehist"
                        (or (getenv "XDG_STATE_HOME") "~/.local/state")))

(setq transient-history-file
      (expand-file-name "emacs/transient/history.el"
                        (or (getenv "XDG_STATE_HOME") "~/.local/state")))

(setq package-enable-at-startup nil)  ; Nix handles everything

(setq inhibit-startup-screen t)

;; Performance
(setq gc-cons-percentage 0.6
      gc-cons-threshold most-positive-fixnum)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-percentage 0.1
              	  gc-cons-threshold (* 16 1024 1024))))

;; UI cleanup
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
