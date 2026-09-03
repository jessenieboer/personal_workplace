(require 'info) ;; need this early to avoid envrc errors
(defalias 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-processes nil
      debug-on-error t
      lexical-binding t
      package-archives nil)

(require 'buffer-focus-hook)
(require 'major-mode-hydra)
;; (use-package major-mode-hydra
;;   :config
;;   (setq hydra-is-helpful nil))

(global-set-key (kbd "<f1>") #'major-mode-hydra)
(global-set-key (kbd "<f2>") nil) ;; for voice toggle
(global-set-key (kbd "<f11>") (setq hydra-is-helpful t))
(global-set-key (kbd "<f5>") (setq hydra-is-helpful nil))
(global-set-key (kbd "<f12> <f1>") #'describe-key)

;; make it cleaner to define hydras by being able to separate the list of modes from the definition of the keys rather than having them all in the same call
(defmacro my-make-hydra (modes keys)
  `(major-mode-hydra-define ,(eval modes) (:color amaranth :quit-key ("<f7>") :title "Controls") ,keys))

(defmacro my-add-to-hydra (modes keys)
  `(major-mode-hydra-define+ ,(eval modes) (:color amaranth :quit-key ("<f7>") :title "Controls") ,keys))


(defun my-show-major-mode ()
  "Displays the name of the major mode at the bottom of the screen. Makes it easier to see what modes I need to add to various hydras."
  (interactive)
  (message "major-mode: %s" major-mode))

(setq my-recorded-major-mode nil)

(defun my-record-major-mode ()
  (setq my-recorded-major-mode major-mode))

(defun my-autohydra ()
  "Switches to the appropriate hydra for the buffer when focus changes"
  (if (not (or (eq major-mode 'minibuffer-mode)
	       (eq major-mode 'minibuffer-inactive-mode)
	       (eq major-mode 'fundamental-mode) ;; for org capture templates
	       (eq my-recorded-major-mode 'fundamental-mode) ;; for org capture templates
	       (eq my-recorded-major-mode 'minibuffer-mode)
	       (eq my-recorded-major-mode 'minibuffer-inactive-mode)))
      (setq unread-command-events '(f7 f1))))

(add-hook 'buffer-focus-hook--out 'my-record-major-mode)
(add-hook 'buffer-focus-hook--in 'my-autohydra)

(setq all-modes '(backtrace-mode
		  calendar-mode
		  comint-mode
		  compilation-mode
		  conf-toml-mode
		  conf-unix-mode
		  css-mode
  		  debugger-mode
  		  dired-mode
  		  dirvish-directory-view-mode
  		  dirvish-special-preview-mode
		  eat-mode
		  eca-chat-mode
		  eca-settings-mode
                  ediff-mode
  		  emacs-lisp-mode
                  feature-mode
		  gptel-context-buffer-mode
  		  fundamental-mode
  		  help-mode
                  html-mode
		  inferior-python-mode
  		  Info-mode
		  js-json-mode
  		  lisp-data-mode
  		  lisp-interaction-mode
		  magit-diff-mode
  		  magit-log-mode
  		  magit-status-mode
  		  messages-buffer-mode
                  mhtml-mode
  		  minibuffer-inactive-mode
  		  minibuffer-mode
  		  nix-mode
  		  org-agenda-mode
  		  org-mode
		  python-mode
  		  sh-mode
  		  shell-mode
		  special-mode
  		  text-mode))

;; modes that show up "on top" of a buffer
;; (setq layered-modes '())

;; the minibuffer
(setq minibuffer-modes '(minibuffer-inactive-mode
    			 minibuffer-mode))

;; modes that show up on the sides of the screen
;;(setq side-modes '(dired-mode))

;; modes that don't navigate text in the usual way
(setq alt-nav-modes  '(calendar-mode
		       dired-mode
  		       dirvish-directory-view-mode
		       eat-mode
                       ediff-mode
		       gptel-context-buffer-mode
		       magit-diff-mode
  		       magit-log-mode
  		       magit-status-mode
		       org-agenda-mode))

;; generally modes that display text content and want to navigate it in the usual way
(setq main-modes (seq-remove (lambda (m) (or (member m alt-nav-modes)
					     (member m minibuffer-modes))) all-modes))

;; modes where you don't edit the text it displays
(setq main-non-edit-modes '(backtrace-mode
			    compilation-mode
  			    debugger-mode
  			    dirvish-special-preview-mode
  			    help-mode
  			    Info-mode
  			    messages-buffer-mode
			    special-mode))

(setq main-edit-modes (seq-remove (lambda (m) (member m main-non-edit-modes)) main-modes))

(global-set-key (kbd "<f12> v") #'my-show-major-mode)

(my-make-hydra all-modes
  	       ("Connection"
    		(("<f11>" (setq hydra-is-helpful t) "show controls")
    		 ("<f5>" (setq hydra-is-helpful nil) "hide controls")
		 ("<f12> v" my-show-major-mode "show mm")
		 ("<f12> <f1>" describe-key "desc key" :exit t))))

(my-add-to-hydra (append main-modes alt-nav-modes)
    		 ("Connection"
    		  (("h:" save-buffers-kill-emacs "close emacs")
  		   ("<f12> t" describe-variable "desc var")
    		   ("<f12> a" describe-function "desc fun"))
    		  "General"
    		  (("ha" execute-extended-command "command" :exit t)
    		   ("h=" eval-expression "eval exp" :exit )
  		   ("h\\" restart-emacs "restart emacs"))))

(my-add-to-hydra minibuffer-modes
    		 ("Connection"
    		  (("f" abort-recursive-edit "quit"))))

(require 'marginalia)
(require 'orderless)
(require 'vertico)
(require 'vertico-sort)

(setq completion-category-overrides '((file (styles basic partial-completion)))
      completion-ignore-case t
      completion-styles '(orderless basic)
      orderless-matching-styles '(orderless-prefixes orderless-literal)
      vertico-sort-function 'vertico-sort-history-alpha)

(marginalia-mode)
(savehist-mode 1)
(vertico-mode)

(my-add-to-hydra minibuffer-modes
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  (("SPC" vertico-previous "prev line")
  		   ("e" vertico-next "next line")
  		   ("(" vertico-previous-group "prev group")
  		   (")" vertico-next-group "next group"))
  		  "Completion"
  		  (("RET" (vertico-exit nil) "select")
  		   ("*" vertico-exit-input "force select")
		   ("<tab> RET" vertico-insert "insert"))))

(require 'consult)
(global-visual-line-mode t)

(my-add-to-hydra main-modes
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  (("SPC" previous-line "prev line")
  		   ("e" next-line "next line")
  		   ("t" backward-char "prev char")
  		   ("s" forward-char  "next char")
  		   ("a" backward-word "prev word")
  		   ("n" forward-word "next word")
  		   ("w" backward-sexp "prev exp")
  		   ("b" forward-sexp "next exp")
  		   ("l" move-beginning-of-line "line first")
  		   ("c" move-end-of-line "line last")		     
  		   ("/" beginning-of-buffer "buff first")
  		   ("," end-of-buffer "buff last")
		   ("r" consult-line "search" :exit t)
  		   ("{" consult-line-multi "search buffers" :exit t))
  		  "Text"
  		  (("o" set-mark-command "mark")
  		   ("-" exchange-point-and-mark "mark switch")
  		   ("i SPC" kill-ring-save "copy"))))

(my-add-to-hydra minibuffer-modes
  		 ("Connection"
  		  (("f" abort-recursive-edit "quit"))
  		  "Display"
  		  ()
  		  "Navigation"
  		  (("t" backward-char "prev char")
  		   ("s" forward-char  "next char")
  		   ("a" backward-word "prev word")
  		   ("n" forward-word "next word"))
  		  "Text"
  		  (("o" set-mark-command "mark")
  		   ("-" exchange-point-and-mark "mark switch")
		   ("i SPC" vertico-save "copy" :exit t))))

;; (my-add-to-hydra side-modes
;;   		 ("Connection"
;;   		  ()
;;   		  "Display"
;;   		  ()
;;   		  "Navigation"
;;   		  (("SPC" previous-line "prev line")
;;   		   ("e" next-line "next line")
;;   		   ("/" beginning-of-buffer "buff first")
;;   		   ("," end-of-buffer "buff last")
;; 		   ("r" consult-line "search" :exit t))
;;   		  "Text"
;;   		  (("o" set-mark-command "mark"))))

(require 'undo-fu)

(setq undo-fu-session-directory
      (expand-file-name "emacs/undo/" 
                        (or (getenv "XDG_STATE_HOME") "~/.local/state")))

(setq-default indent-tabs-mode nil)  ; insert spaces, not tab characters
;; (setq-default tab-width 8)           ; how wide a tab *displays*

(my-add-to-hydra main-edit-modes
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  ()
  		  "Text"
  		  (("RET" newline "newline")
  		   ("*" split-line "split line")
		   ("il" join-line "join prev line")
  		   ("ic" (join-line t) "join next line")
		   ("DEL" delete-backward-char "del back")
		   ("<deletechar>" delete-forward-char "del fwd")
  		   ("i DEL" kill-whole-line "kill line")
  		   ("i <deletechar>" kill-line "kill to end")
  		   ("it" kill-region "cut")
  		   ("ia" yank "paste")
  		   ("ir" yank-from-kill-ring "paste from ring")
  		   ("<tab> m" indent-relative "indent")
		   ("im" indent-region "indent")
		   ("ip" comment-dwim "comment")
  		   ("ig" undo-fu-only-undo "undo")
  		   ("iw" undo-fu-only-redo "redo")
  		   ("id" with-editor-finish "editor finish"))))

(my-add-to-hydra minibuffer-modes
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  ()
  		  "Text"
  		  (("DEL" delete-backward-char "del back")
		   ("<deletechar>" delete-forward-char "del fwd")
  		   ("i DEL" delete-minibuffer-contents "del all")
		   ("ia" yank "paste")
		   ("<tab> RET" vertico-insert "insert"))))

(require 'easysession)
(require 'easysession-magit)

(setq auto-revert-interval 2
      auto-revert-verbose nil
      clean-buffer-list-delay-general 1
      clean-buffer-list-delay-special 0.04
      clean-buffer-list-kill-buffer-names '("*Apropos*" "*Backtrace*" "*Buffer List*" "*Compile-Log*" "*diff*"
    					    "*envrc*" "*Help*" "*info*" "*lsp-log*" "*nixfmt*" "*Warnings*" "*vc*"
          				    "*vc-diff*")
      clean-buffer-list-kill-regexps '("^\\*Async.*" "^\\*Ilist\\*" "^\\*Help\\*")
      consult-line-start-from-top t
      consult-preview-key nil ;; if this is set to 'any, it screws up autohydra
      easysession-directory (expand-file-name "emacs/easysession/"
    					      (or (getenv "XDG_STATE_HOME") "~/.local/state"))
      easysession-switch-to-save-session nil
      global-auto-revert-mode t
      my-center-buffer-patterns nil
      my-hidden-buffer-patterns nil
      my-left-buffer-patterns nil
      my-right-buffer-patterns nil
      revert-without-query '("/home/jessenieboer/Dropbox/"))

(easysession-magit-mode 1)
(easysession-save-mode -1) ; save manually
(make-directory easysession-directory t)

(defun my-center-buffer-p (buffer-or-name &rest ARGS)
  "Test whether buffer should be displayed in my center frame."
  (let ((buffer (get-buffer buffer-or-name)))
    (when (and buffer (buffer-live-p buffer))
      (my-string-matches-any-regex-p (buffer-name buffer) my-center-buffer-patterns))))

(defun my-left-buffer-p (buffer-or-name &rest ARGS)
  "Test whether buffer should be displayed in my left frame."
  (let ((buffer (get-buffer buffer-or-name)))
    (when (and buffer (buffer-live-p buffer))
      (my-string-matches-any-regex-p (buffer-name buffer) my-left-buffer-patterns))))

(defun my-right-buffer-p (buffer-or-name &rest ARGS)
  "Test whether buffer should be displayed in my right frame."
  (let ((buffer (get-buffer buffer-or-name)))
    (when (and buffer (buffer-live-p buffer))
      (my-string-matches-any-regex-p (buffer-name buffer) my-right-buffer-patterns))))

(defun my-add-center-buffer-patterns (regex-list)
  "Add patterns to my list of buffers that display in my center frame."
  (setq my-center-buffer-patterns (append my-center-buffer-patterns regex-list)))

(defun my-add-left-buffer-patterns (regex-list)
  "Add patterns to my list of buffers that display in my left frame."
  (setq my-left-buffer-patterns (append my-left-buffer-patterns regex-list)))

(defun my-add-right-buffer-patterns (regex-list)
  "Add patterns to my list of buffers that display in my right frame."
  (setq my-right-buffer-patterns (append my-right-buffer-patterns regex-list)))

(my-add-left-buffer-patterns '(".*shell\\*" "^\\*Info\\*$" "^\\*Metahelp\\*$" "^\\*Process List\\*$" "^\\*Shell Command Output\\*$""^\\*Warnings\\*$"))
(my-add-right-buffer-patterns '("^\\*Async-.*" "^\\*Backtrace\\*$" "\\*envrc\\*" "^\\*Help\\*$" "^\\*Messages\\*$"))

(my-add-to-hydra main-modes
  		 ("Connection"
  		  (("h\"" consult-buffer "switch buff" :exit t)
		   ("hf" (kill-buffer nil) "kill buffer")
		   ("h$" kill-buffer "kill any buffer")
  		   ("hm" clone-indirect-buffer-other-window "clone buffer")
  		   ("u RET" tab-new "make tab-bar")
  		   ("uf" tab-close "close tab-bar"))
  		  "Display"
  		  (("!" tab-line-move-tab-backward "tab-line left")
  		   ("?" tab-line-move-tab-forward "tab-line right")
  		   ("f`" tab-bar-mode "tab-bar toggle")
		   ("f~" tab-line-mode "tab-line toggle")
  		   ("`" (tab-move -1) "tab-bar left")
  		   ("~" tab-move "tab-bar right")
		   ("ub" tab-rename "rename tab-bar"))
  		  "Navigation"
  		  (("v" tab-line-switch-to-prev-tab  "prev tab-line")
  		   ("x" tab-line-switch-to-next-tab "next tab-line")
		   ("q" tab-previous "prev tab-bar")
  		   ("z" tab-next "next tab-bar")
		   ("u SPC" tab-switch "switch tab-bar"))
  		  "General"
  		  (("hd" save-buffer "write buffer")
  		   ("h<" (save-some-buffers t nil) "write all buffers")
  		   ("hw" revert-buffer "revert buffer")
		   ("ud" (easysession-save "desktop") "save desktop")
		   ("u<" (easysession-switch-to "desktop") "load desktop"))))

(my-add-to-hydra alt-nav-modes
  		 ("Connection"
  		  (("h\"" consult-buffer "switch buff" :exit t)
		   ("hf" (kill-buffer nil) "kill buffer")
		   ("h$" kill-buffer "kill any buffer")
		   ("u RET" tab-new "make tab-bar")
		   ("uf" tab-close "close tab-bar"))
		  "Display"
  		  (("f`" tab-bar-mode "tab-bar toggle")
  		   ("`" (tab-move -1) "tab-bar left")
  		   ("~" tab-move "tab-bar right")
		   ("ub" tab-rename "rename tab-bar"))
		  "Navigation"
		  (("v" tab-line-switch-to-prev-tab  "prev tab-line")
		   ("x" tab-line-switch-to-next-tab "next tab-line")
		   ("q" tab-previous "prev tab-bar")
		   ("z" tab-next "next tab-bar")
		   ("u SPC" tab-switch "switch tab-bar"))
		  "General"
  		  (("h<" (save-some-buffers t nil) "write all buffers")
  		   ("hw" revert-buffer "revert buffer")
		   ("ud" (easysession-save "desktop") "save desktop")
		   ("u<" (easysession-switch-to "desktop") "load desktop"))))

(require 'golden-ratio)
(require 'popper)
(require 'windswap)

(setq ;;desktop-restore-frames nil ;; messes with my 3-frame setup
 ignore-window-parameters t
 my-center-frame-name "jn_center"
 my-left-frame-name "jn_left"
 my-right-frame-name "jn_right"
 popper-reference-buffers '("^CAPTURE-.*$"  ;; org captures
      			    ;;"^COMMIT_EDITMSG$"
      			    ;;"^.*\.org\:\:.*$" ;; agenda indirect follow mode buffers; does not give any benefit compared to default behavior
      			    ;;".*\\*shell\\*"
      			    ;;shell-mode
      			    ;;"^\\*Help\\*$"   help-mode
      			    ;;"^\\*Messages\\*$"  messages-buffer-mode
      			    )
 popper-window-height 20
 split-height-threshold nil)

;; Force commit buffer to open in current frame
;; (add-to-list 'display-buffer-alist
;;              '("\\*magit-edit:\\|COMMIT_EDITMSG\\*"
;;                (display-buffer-same-window)
;;                (inhibit-same-window . nil)))

(defun my-ensure-frame (name)
  "Ensure a frame with NAME exists, creating it if necessary."
  (unless (seq-find (lambda (frame) (equal (frame-parameter frame 'name) name))
              	    (frame-list))
    (let ((frame (make-frame `((name . ,name)
                               (fullscreen . maximized)))))))) ; fullboth is annoying on wayland
    					;(set-frame-parameter frame 'undecorated t)

(defun my-create-frames ()
  (interactive)
  (let ((center-frame (my-ensure-frame my-center-frame-name))
  	(left-frame (my-ensure-frame my-left-frame-name))
  	(right-frame (my-ensure-frame my-right-frame-name))
  	(scratch-frame (seq-find (lambda (frame) (equal (frame-parameter frame 'name) "*scratch*")) (frame-list))))
    (if center-frame
	(select-frame center-frame))
    (if scratch-frame
	(delete-frame scratch-frame))))


;;tie all reference/results buffers to the reference/results frame
(add-to-list 'display-buffer-alist
  	     '(my-center-buffer-p
  	       (display-buffer-reuse-window
  		display-buffer-use-some-frame)
  	       (reusable-frames . t)
  	       (frame-predicate . (lambda (frame) (equal (frame-parameter frame 'name) my-center-frame-name)))
  	       (inhibit-switch-frame . t)))

(add-to-list 'display-buffer-alist
  	     '(my-left-buffer-p
  	       (display-buffer-reuse-window
  		display-buffer-use-some-frame)
  	       (reusable-frames . t)
  	       (frame-predicate . (lambda (frame) (equal (frame-parameter frame 'name) my-left-frame-name)))
  	       (inhibit-switch-frame . t)))

(add-to-list 'display-buffer-alist
  	     '(my-right-buffer-p
  	       (display-buffer-reuse-window
  		display-buffer-use-some-frame)
  	       (reusable-frames . t)
  	       (frame-predicate . (lambda (frame) (equal (frame-parameter frame 'name) my-right-frame-name)))
  	       (inhibit-switch-frame . t)))

  					;(winner-mode)

(my-add-to-hydra all-modes
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  (("m" (other-window -1) "prev win")
  		   ("y" other-window "next win")
  		   ("&" (other-frame -1) "prev frame")
  		   ("|" (other-frame 1) "next frame"))))

(my-add-to-hydra main-modes
  		 ("Connection"
  		  (("fl" popper-kill-latest-popup "close popup"))
  		  "Display"
  		  (("fn" split-window-right "split right")
  		   ("fh" split-window-below "split down")
  		   ("ff" delete-window "del win")
  		   ("fd" delete-other-windows "del other wins")
  		   ("f <tab>" minimize-window "min win")
  		   ("fb" maximize-window "max win")
		   ;; ("f+" toggle-frame-fullscreen "fullscreen") ;;annoying on wayland
		   ("f+" toggle-frame-maximized "max frame") 
  		   ("fp" fit-window-to-buffer "fit win")
  		   ("f]" balance-windows "bal win")
		   ("f <f7>" golden-ratio "gold")
  		   ("fe" (recenter nil) "recenter")
  		   ("fi" (recenter 0) "recenter top")
  		   ("fo" (recenter -1) "recenter bot")
		   ("<home>" shrink-window-horizontally "shrink horz")
  		   ("<end>" enlarge-window-horizontally "grow horz")
  		   ("<prior>" shrink-window "shrink vert")
  		   ("<next>" enlarge-window "grow vert")
		   ("C-<left>" windswap-left "left win swap")
		   ("C-<right>" windswap-right "right win swap")
		   ("C-<up>" windswap-up "up win swap")
		   ("C-<down>" windswap-down "down win swap"))))

(my-add-to-hydra alt-nav-modes
  		 ("Connection"
  		  (("fl" popper-kill-latest-popup "close popup"))
  		  "Display"
  		  (("fn" split-window-right "split right")
		   ("fh" split-window-below "split down")
		   ("ff" delete-window "del win")
		   ("f <tab>" minimize-window "min win")
  		   ("fb" maximize-window "max win")
  		   ("fp" fit-window-to-buffer "fit win")
  		   ("f]" balance-windows "bal win")
		   ("f <f7>" golden-ratio "gold")
  		   ("fe" (recenter nil) "recenter")
  		   ("fi" (recenter 0) "recenter top")
  		   ("fo" (recenter -1) "recenter bot")
		   ("<home>" shrink-window-horizontally "shrink horz")
  		   ("<end>" enlarge-window-horizontally "grow horz")
  		   ("<prior>" shrink-window "shrink vert")
  		   ("<next>" enlarge-window "grow vert")
		   ("C-<left>" windswap-left "left win swap")
		   ("C-<right>" windswap-right "right win swap")
		   ("C-<up>" windswap-up "up win swap")
		   ("C-<down>" windswap-down "down win swap"))))

(require 'dirvish)
(require 'dirvish-side)
(require 'dirvish-subtree)
(require 'envrc)

(add-hook 'dirvish-mode-hook #'auto-revert-mode)
(dirvish-override-dired-mode)
(setq dired-copy-preserve-time t
      dired-dwim-target t
      dired-kill-when-opening-new-dired-buffer t
      dired-recursive-deletes 'top
      dirvish-cache-dir
      (expand-file-name "emacs/dirvish/"
                        (or (getenv "XDG_CACHE_HOME") "~/.cache"))
      recentf-max-saved-items 200)
(recentf-mode 1)

(defun my-get-dir-at-point ()
  "Return the project root directory at point, or nil if none found."
  (interactive)
  (let* ((file (dired-get-file-for-visit))
	 (dir (if (file-directory-p file)
                  file
		(file-name-directory file))))
    (when dir
      (message "Found dir: %s" dir)
      dir)))

(defun my-dirvish-side-project ()
  (interactive)
  (dirvish-side (project-root (project-current))))

;;(my-add-hidden-buffer-patterns '("^\\*envrc\\*$")) ;; for some reason this causes errors

;; todo: dirvish close if open, open in ace window, open on either side?

(my-add-to-hydra main-modes
  		 ("Connection"
  		  (("ht" consult-project-buffer "switch proj buff" :exit t)
		   ("h SPC" my-dirvish-side-project  "dir side")
		   ("h(" dirvish "dir")
		   ("h*" find-file "find any file"))))

(my-add-to-hydra 'dired-mode
  		 ("Connection"
  		  (("ho" my-open-new-org-agenda-at-point "agenda")
		   ("RET" dired-find-file "select")
  		   ("d" dired-find-file-other-window "select other")
		   ("h SPC" my-dirvish-side-project "dir side"))
  		  "Navigation"
  		  (("SPC" dired-previous-line "prev line")
  		   ("e" dired-next-line "next line")
  		   ("(" dired-previous-dirline "prev dir")
  		   (")" dired-next-dirline "next dir")
  		   ("w" dired-up-directory "up dir")
		   ("r" dired-goto-file "goto file"))
  		  "Display"
  		  (("t" dirvish-subtree-remove "hide sub")
  		   ("s" dirvish-subtree-toggle "show sub")
		   ("n" dired-hide-details-mode "details")
		   (";" dired-sort-or-toggle-edit "sort"))
  		  "Filesystem"
  		  (("o" dired-mark "mark")
		   ("-" dired-toggle-marks "invert marks")
  		   ("<f9>" dired-unmark "unmark")
		   ("<f10>" dired-unmark-all-marks "unmark all")
		   ("DEL" dired-flag-file-deletion "flag")
		   ("'" dired-do-flagged-delete "delete flagged")
		   ("it" dired-do-rename "rename")
  		   ("i SPC" dired-do-copy "copy")
		   ("i (" (dired-copy-filename-as-kill 0))
  		   ("i DEL" dired-do-flagged-delete "delete flagged")
		   ("i'" dired-do-delete "delete")
		   ("ia" dired-create-empty-file "make file")
  		   ("i RET" make-directory "make dir")
  		   ("ig" dired-undo "undo"))))

(require 'project)
(setq my-project-management-directory (file-name-as-directory "~/Dropbox/_project_management")
      my-projects-directory (file-name-as-directory "~/kingdoms")
      project-mode-line nil ;; causes some slowdown if not nil
      project-switch-commands 'project-find-file
      project-vc-extra-root-markers '(".project" "devenv.nix" "flake.nix")
      project-vc-ignores '(".devenv/")
      project-vc-use-cache t
      tab-bar-tab-name-function (lambda () (let ((proj (project-current)))
					     (if proj
						 (project-name proj)
					       "No project"))))

(defun my-reset-projects ()
  (interactive)
  (project-forget-zombie-projects)
  (project-forget-projects-under my-project-management-directory t)
  (project-forget-projects-under my-projects-directory t)
  (project-remember-projects-under my-project-management-directory t)
  (project-remember-projects-under my-projects-directory t)
  (dolist (proj project--list)
    (let* ((root (car proj))
	   (envrc (when root (expand-file-name ".envrc" root))))
      (add-to-list 'safe-local-variable-directories root)
      (when (and envrc (file-exists-p envrc))
	(let ((default-directory root))
	  (envrc-allow))))))


(defun my-get-project-root-at-point ()
  "Return the project root directory at point, or nil if none found."
  (interactive)
  (let* ((dir (my-get-dir-at-point))
	 (project (project-current nil dir)))
    (if project
	(let ((root (project-root project)))
          (message "Project root: %s" root)
	  root)
      (message "No project root found at point")
      nil)))

(my-add-to-hydra (append main-modes alt-nav-modes)
  		 ("Connection"
  		  (("ht" consult-project-buffer "switch proj buff" :exit t)
  		   ("h DEL" project-switch-project "switch proj" :exit t)
  		   ("h RET" project-find-file "find proj file" :exit t))))

(require 'cl-lib)

(setq tab-line-close-button-show nil
      tab-line-new-button-show nil
      tab-line-tab-name-function 'tab-line-tab-name-truncated-buffer
      tab-line-tabs-buffer-group-function 'my-tab-line-tabs-buffer-group-function ;'tab-line-tabs-buffer-group-by-project
      tab-line-tabs-function 'tab-line-tabs-buffer-groups)

(global-tab-line-mode 1)
(tab-bar-mode 1)

(defun my-add-hidden-buffer-patterns (regex-list)
  "Add patterns to my list of buffers that won't show up on the tab line."
  (setq my-hidden-buffer-patterns (append my-hidden-buffer-patterns regex-list)))

(defun my-cache-for-tab-display (buffer)
  "Cache given buffer according to visibility."
  (let ((bname (buffer-name buffer)))
    (if (my-string-matches-any-regex-p bname my-hidden-buffer-patterns)
        (puthash bname "Hidden" my-tab-display-cache)
      (puthash bname (my-get-project-name-for-buffer buffer) my-tab-display-cache))))

(defvar my-project-name-cache (make-hash-table :test 'eq :weakness 'key)
  "Buffer -> project name cache.")

(defun my-get-project-name-for-buffer (buffer)
  "Return the project name for BUFFER, or nil if none."
  (let ((buf (get-buffer buffer)))
    (when buf
      (with-current-buffer buf
	(or (gethash buf my-project-name-cache)
	    (when-let* ((proj (project-current nil (buffer-file-name buf)))
			(proj-name (project-name proj)))
	      (puthash buf (or proj-name "no_project") my-project-name-cache)
	      proj-name))))))

(defun my-string-matches-any-regex-p (str regex-list)
  "Return t if STR matches any regex in REGEX-LIST."
  (cl-loop for regex in regex-list
  	   thereis (string-match-p regex str)))

(defvar my-tab-display-cache (make-hash-table :test 'equal :weakness 'key)
  "Cache for hidden buffer checks.")

(defun my-tab-line-tabs-buffer-group-function (buffer)
  (gethash (buffer-name buffer) my-tab-display-cache "No tab group"))

(defun my-update-tab-display-cache ()
  (clrhash my-tab-display-cache)
  (mapc 'my-cache-for-tab-display (buffer-list)))

(add-hook 'buffer-list-update-hook #'my-update-tab-display-cache)

(my-add-hidden-buffer-patterns '("^\\*Async-.*" "^\\*Backtrace\\*$" "\\*envrc\\*" "^\\*Help\\*$" "^\\*Ilist\\*$"
              			 "^\\*Info\\*$" "^\\*Metahelp\\*$" "^\\*Messages\\*$" ".*Old buffer.*"
              			 "^\\*Process List\\*$" "^\\*Shell Command Output\\*$" "^\\*Warnings\\*$"))

(my-add-to-hydra main-modes
  		 ("Connection"
  		  (("h\"" consult-buffer "switch buff" :exit t)
		   ("hf" (kill-buffer nil) "kill buffer")
		   ("h$" kill-buffer "kill any buffer")
  		   ("hm" clone-indirect-buffer-other-window "clone buffer")
  		   ("u RET" tab-new "make tab-bar")
  		   ("uf" tab-close "close tab-bar"))
  		  "Display"
  		  (("!" tab-line-move-tab-backward "tab-line left")
  		   ("?" tab-line-move-tab-forward "tab-line right")
  		   ("f`" tab-bar-mode "tab-bar toggle")
		   ("f~" tab-line-mode "tab-line toggle")
  		   ("`" (tab-move -1) "tab-bar left")
  		   ("~" tab-move "tab-bar right")
		   ("ub" tab-rename "rename tab-bar"))
  		  "Navigation"
  		  (("v" tab-line-switch-to-prev-tab  "prev tab-line")
  		   ("x" tab-line-switch-to-next-tab "next tab-line")
		   ("q" tab-previous "prev tab-bar")
  		   ("z" tab-next "next tab-bar")
		   ("u SPC" tab-switch "switch tab-bar"))
  		  "General"
  		  (("hd" save-buffer "write buffer")
  		   ("h<" (save-some-buffers t nil) "write all buffers")
  		   ("hw" revert-buffer "revert buffer")
		   ("ud" (easysession-save "desktop") "save desktop")
		   ("u<" (easysession-switch-to "desktop") "load desktop"))))

(my-add-to-hydra alt-nav-modes
  		 ("Connection"
  		  (("h\"" consult-buffer "switch buff" :exit t)
		   ("hf" (kill-buffer nil) "kill buffer")
		   ("h$" kill-buffer "kill any buffer")
		   ("u RET" tab-new "make tab-bar")
		   ("uf" tab-close "close tab-bar"))
		  "Display"
  		  (("f`" tab-bar-mode "tab-bar toggle")
  		   ("`" (tab-move -1) "tab-bar left")
  		   ("~" tab-move "tab-bar right")
		   ("ub" tab-rename "rename tab-bar"))
		  "Navigation"
		  (("v" tab-line-switch-to-prev-tab  "prev tab-line")
		   ("x" tab-line-switch-to-next-tab "next tab-line")
		   ("q" tab-previous "prev tab-bar")
		   ("z" tab-next "next tab-bar")
		   ("u SPC" tab-switch "switch tab-bar"))
		  "General"
  		  (("h<" (save-some-buffers t nil) "write all buffers")
  		   ("hw" revert-buffer "revert buffer")
		   ("ud" desktop-save "save desktop")
		   ("u<" (easysession-switch-to "desktop") "load desktop"))))

(require 'default-text-scale)
(require 'solarized)

;; apparently this is a good way to load themes
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (with-selected-frame frame
                (load-theme 'solarized-dark t)))))

(add-to-list 'default-frame-alist '(font . "Source Code Pro"))

(when (display-graphic-p)
(set-fontset-font t 'unicode
                  (font-spec :family "Hack Nerd Font Mono")
                  nil 'prepend)
;; optional: also cover the specific symbol ranges more aggressively
(set-fontset-font t '(#xe000 . #xf8ff)
                  (font-spec :family "Hack Nerd Font Mono")
                  nil 'prepend))

(setq custom-safe-themes t
      mode-line-right-align-edge 'right-margin
      solarized-high-contrast-mode-line t
      solarized-scale-org-headlines t
      solarized-use-variable-pitch nil)

(setq-default mode-line-format '("%e" mode-line-modified " " mode-line-buffer-identification
				 " %l:%c %P " mode-line-format-right-align (:eval mode-name) " "
				 (vc-mode vc-mode) " " (project-mode-line project-mode-line-format)))

(toggle-frame-fullscreen)

(my-add-to-hydra (append main-modes alt-nav-modes)
  		 ("Connection"
  		  ()
  		  "Display"
  		  (("f r" (default-text-scale-reset) "zoom reset")
  		   ("f SPC" (default-text-scale-decrease) "zoom out")
  		   ("f (" text-scale-decrease "buffer zoom out")
  		   ("f RET" (default-text-scale-increase) "zoom in")
  		   ("f *" text-scale-increase "buffer zoom in"))))

(defun my-secretspec-get (name)
  "Retrieve a secret using SecretSpec CLI, given there is a ~/.config/secretspec/secretspec.toml.
Returns the value as string or nil if not found / error."
  (let ((output (shell-command-to-string
			     (format "secretspec get -f ~/.config/secretspec/secretspec.toml %s"
				     (shell-quote-argument name)))))
    (if (string-empty-p (string-trim output))
        nil
      (string-trim output))))

(require 'eca)
(require 'gptel)
(require 'gptel-agent)
(require 'gptel-context)
(require 'gptel-integrations)
(require 'gptel-openai-extras)
(require 'gptel-transient)
(require 'mcp)
(require 'mcp-hub)

(defun my-gptel-add-project-context ()
  (interactive)
  (gptel-context--add-directory (expand-file-name (project-root (project-current))) 'add))

(setq gptel-default-mode 'org-mode
      gptel-include-reasoning nil
      ;; key is set in when hotkey is called because it needs to be pulled out of secretspec
      jn-grok-backend (gptel-make-xai "jn_grok"
			:key (my-secretspec-get "XAI_API_KEY")
   			:models '(grok-4.6)
  			:request-params nil
  			:stream nil)
      my-default-ai-chat-name "*ai chat*")

(setq gptel-backend jn-grok-backend
      gptel-model 'grok-4.6)

(defun my/run-project-toolbox-setups ()
"Load every *_toolbox_setup file under .toolboxes/ in the current project."
(when-let* ((root (and (project-current)
                       (project-root (project-current))))
            (toolboxes-dir (expand-file-name ".toolboxes" root)))
  (when (file-directory-p toolboxes-dir)
    (dolist (file (directory-files-recursively
                   toolboxes-dir
                   "_toolbox_setup\\'"))
      (when (file-regular-p file)
        (message "Loading toolbox setup: %s" file)
        (load file t t t))))))

(add-hook 'envrc-mode-hook #'my/run-project-toolbox-setups)

(my-add-left-buffer-patterns '("^\\*gptel-agent.*" ".*eca-chat.*"))
(my-add-right-buffer-patterns '("^\\*ai chat\\*" ".*eca-workspaces.*" "^\\*gptel-context\\*" "^\\*Mcp-Hub\\*"))
(my-add-hidden-buffer-patterns '("^\\*Mcp-Hub\\*"))

;; (my-add-to-hydra main-edit-modes
;;   		 ("Connection"
;; 		  (("dix" (gptel-agent (project-root (project-current)) 'ai_vizier) "open ai agent") 
;; 		   ("di <f7>" (gptel my-default-ai-chat-name) "open ai chat")
;; 		   ;; ("diw" gptel-mode "ai mode")
;; 		   ;; ("di\\" (my-xAI-login) "ai login" :exit t)
;; 		   ;; ("di\\" gptel-menu "ai login" :exit t)
;; 		   ("dih" (gptel-context--buffer-setup nil nil gptel-context) "show ai context"))
;; 		  "Navigation"
;; 		  ()
;; 		  "Display"
;; 		  ()
;; 		  "AI"
;; 		  (("di?" (gptel-agent-update) "agent update")
;; 		   ("i RET" gptel-send "ai send")
;; 		   ;; ("i*" (gptel--accept-tool-calls) "accept tool calls")
;; 		   ;; ("i$" (gptel--reject-tool-calls) "reject tool calls")
;; 		   ("dio" gptel-add "add ai context")
;; 		   ("di-" my-gptel-add-project-context "add project context")
;; 		   ("di DEL" gptel-context-remove-all "remove ai context"))))

(my-add-to-hydra main-edit-modes
                 ("Connection"
		  (("dix" eca "open agentic ai"))
		  "Navigation"
		  ()
		  "Display"
		  ()
		  "AI"
		  ()))

(my-add-to-hydra alt-nav-modes
                 ("Connection"
		  (("ix" eca "open agentic ai"))
		  "Navigation"
		  ()
		  "Display"
		  ()
		  "AI"
		  ()))

(my-add-to-hydra 'eca-chat-mode
                 ("Connection"
		  ()
		  "Navigation"
		  ()
		  "Display"
		  ()
		  "AI"
		  (("ix" eca-chat-select-agent "ai choose agent")
                   ("i?" eca-chat-select-model "ai choose model")
                   ("i RET" eca-chat--key-pressed-return "ai send")
                   ("in" eca-chat-tool-call-accept-next "ai tool accept")
                   ("i;" eca-chat-tool-call-reject-next "ai tool reject")
                   ("ic" eca-chat-tool-call-accept-all "ai tool accept all")
                   ("i," eca-chat-tool-call-accept-all-and-remember "ai tool accept all remember")
                   ("if" eca-chat-stop-prompt)
                   ("i$" eca-stop))))

;; eca chat tool call accept, accept and remember, reject, view diff

(my-add-to-hydra 'dired-mode
		 ("Connection"
		  (("ix" eca "open agentic ai")
		   ("i <f7>" (gptel my-default-ai-chat-name) "open ai chat")
		   ;; ("diw" gptel-mode "ai mode")
		   ;; ("di\\" (my-xAI-login) "ai login" :exit t)
		   ;; ("di\\" gptel-menu "ai login" :exit t)
		   ("ih" (gptel-context--buffer-setup nil nil gptel-context) "show ai context"))
		  "Navigation"
		  ()
		  "Display"
		  ()
		  "AI"
		  (("i?" (gptel-agent-update) "agent update")
		   ("io" gptel-add "add ai context")
		   ("i-" my-gptel-add-project-context "add project context")
		   ("i DEL" gptel-context-remove-all "remove ai context"))))



(my-add-to-hydra 'gptel-context-buffer-mode
		 ("Connection"
		  ()
		  "Navigation"
		  (("SPC" previous-line "prev line")
		   ("e" next-line "nex line")
		   ("a" gptel-context-previous "prev context")
		   ("n" gptel-context-next "next context"))
		  "Display"
		  ()
		  "AI"
		  (("d" gptel-context-visit "visit")
		   ("o" gptel-context-flag-deletion "flag deletion")
		   ("DEL" gptel-context-confim "confirm delete" :exit t)
		   ("f" gptel-context-quit "quit"))))

(require 'flycheck)
  (set-face-attribute 'flycheck-error nil :underline '(:color "red" :style wave))
  (set-face-attribute 'flycheck-warning nil :underline '(:color "orange" :style wave))
  (set-face-attribute 'flycheck-info nil :underline '(:color "blue" :style wave))
  (setq flycheck-display-errors-delay 0.5)

  (require 'flycheck-posframe)
  (setq flycheck-posframe-border-width 3 
        flycheck-posframe-position 'frame-bottom-left-corner)
  (add-hook 'flycheck-mode-hook #'flycheck-posframe-mode)
  (my-add-hidden-buffer-patterns '("^\\*flycheck-.*"))

  (require 'lsp-mode)
  (require 'lsp-headerline)
  (require 'lsp-modeline)
  (setq lsp-auto-guess-root t
   lsp-completion-provider :none
        lsp-diagnostics-provider :flycheck
        lsp-eldoc-enable-hover nil
	lsp-enable-file-watchers t
        lsp-enable-snippet nil
        lsp-file-watch-ignored-directories (append lsp-file-watch-ignored-directories '("/nix/store" "[/\\\\]\\.devenv\\'"))
        lsp-idle-delay 0.5
	lsp-lens-enable nil
        lsp-log-io nil
        lsp-restart 'interactive)
  ;;:custom	  lsp-use-plists nil ;; t is causing errors at the moment)

  (require 'lsp-ui)
  (setq lsp-ui-doc-alignment 'frame ;; only relevant if lsp-ui-doc-position is not 'at-point
        lsp-ui-doc-delay 0.5
        lsp-ui-doc-enable t
        lsp-ui-doc-header nil
        lsp-ui-doc-include-signature nil
        lsp-ui-doc-max-height 80
        lsp-ui-doc-position 'bottom
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-show-with-mouse nil
        lsp-ui-doc-use-childframe t
        lsp-ui-imenu-mode-map (make-sparse-keymap)
        lsp-ui-imenu-auto-refresh t
        lsp-ui-imenu-buffer-position 'left
        lsp-ui-peek-always-show t
        lsp-ui-peek-enable t
        lsp-ui-sideline-enable -1)


(add-hook 'prog-mode-hook (lambda () (eldoc-mode -1)
	        	    (flymake-mode -1)))
  ;; (add-hook 'prog-mode-hook #'lsp-deferred)
  (add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
  (add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))

(with-eval-after-load 'lsp-ui    
  ;;Custom keybindings for lsp-ui-peek
  ;; Connection
  (define-key lsp-ui-peek-mode-map (kbd "RET") 'lsp-ui-peek--goto-xref)
  (define-key lsp-ui-peek-mode-map (kbd "d") 'lsp-ui-peek--goto-xref-other-window)
  (define-key lsp-ui-peek-mode-map (kbd "f") 'lsp-ui-peek--abort) 

  ;; Navigation
  (define-key lsp-ui-peek-mode-map (kbd "SPC") 'lsp-ui-peek--select-prev)
  (define-key lsp-ui-peek-mode-map (kbd "e") 'lsp-ui-peek--select-next)
  (define-key lsp-ui-peek-mode-map (kbd "v") 'lsp-ui-peek--select-prev-file)
  (define-key lsp-ui-peek-mode-map (kbd "x") 'lsp-ui-peek--select-next-file))

  (my-add-to-hydra main-edit-modes
  		 ("Connection"
  		  (("d\\" lsp-restart-workspace "debug quit"))
  		  "Navigation"
  		  (("g" (lsp-ui-find-prev-reference nil) "prev ref")
  		   ("p" (lsp-ui-find-next-reference nil) "next ref")
  		   ;; ("[" flycheck-previous-error "prev err")
  		   ;; ("]" flycheck-next-error "next err")
  		   ;; ("iy" lsp-ui-doc-focus-frame "focus doc")
  		   ;;("i|" lsp-ui-doc-unfocus-frame "unfocus doc")
  		   )
  		  "Display"
  		  (("dy" lsp-ui-peek-find-definitions "peek def" :exit t)
  		   ("dk" (lsp-ui-peek-find-references nil) "peek ref" :exit t)
  		   ("hg" lsp-ui-imenu "lsp nav"))
  		  "Code"
  		  (("ip" comment-dwim "comment") 
  		   ("im" lsp-format-buffer "format buffer")
  		   ("ib" lsp-rename "rename")
  		   ;; ("TAB C-d" org-edit-src-exit "org src exit")
  		   ;; ("TAB C-f" org-edit-src-abort "org src abort")
             )
  		  "Completion"
  		  ()))

(require 'eat)
(setq eat-enable-auto-line-mode t
      eat-line-input-history-isearch t)

;;(eat-eshell-mode 1)
					;(add-hook 'eat-mode-hook #'eat-line-mode)
(add-hook 'eat-mode-hook #'eat-line-mode)

;; (defun my-eat-direnv-hook ()
;;   "Reload direnv environment when entering eat buffer."
;;   (when (and (fboundp 'direnv-update-environment)
;;              (buffer-file-name))
;;     (direnv-update-environment (file-name-directory (buffer-file-name)))))

(my-add-left-buffer-patterns '(".*eat\\*"))

					;(add-hook 'eat-mode-hook #'my-eat-direnv-hook)

(my-add-to-hydra (append main-modes alt-nav-modes)
		 ("Connection"
		  (("hn" eat-project  "project terminal")
		   ("h;" eat  "terminal"))))

(my-add-to-hydra 'eat-mode
  		 ("Connection"
  		  (("h SPC" my-dirvish-side-project "dir side"))
  		  "Navigation"
  		  (
		   ;;("SPC" previous-line "prev line")
		   ;;("e" next-line "next line")
		   ("t" backward-char  "next char")
  		   ("s" forward-char  "next char")
  		   ("a" backward-word "prev word")
  		   ("n" forward-word "next word")
  		   ("w" backward-sexp "prev exp")
  		   ("b" forward-sexp "next exp")
  		   ("l" move-beginning-of-line "line first")
  		   ("c" move-end-of-line "line last")
		   ("r" consult-line "search" :exit t)
		   ;;("/" beginning-of-buffer "buff first")
  		   ;;("," end-of-buffer "buff last")
  		   ;; 
		   )
  		  "Terminal"
  		  (("in" eat-line-mode "eat line mode")
		   ("(" eat-previous-shell-prompt "prev prompt")
		   (")" eat-next-shell-prompt "next prompt")
		   ("o" set-mark-command "mark")
		   ("-" exchange-point-and-mark "mark switch")
		   ("DEL" delete-backward-char "pre del")
		   ;; ("i DEL" kill-whole-line "kill whole line")
		   ;; ("<deletechar>" delete-forward-char "nex del")
		   ;; ("i <deletechar>" kill-line "kill to end") 
		   ("it" kill-region "snip")
		   ("i SPC" kill-ring-save "copy")
		   ("ia" eat-yank "paste")
		   ("ir" eat-line-history-isearch-backward "history search" :exit t)
		   ("w" eat-line-previous-input "prev input")
		   ("b" eat-line-next-input "next input")
		   ;; ("ir" yank-from-kill-ring "paste from ring")
		   ;; ("ig" undo "undo")
  		   ("RET" eat-line-send "send input")
  		   ;; ("if" comint-quit-subjob "quit")
  		   ("i$" eat-kill-process "kill"))))

(setq ediff-window-setup-function 'ediff-setup-windows-plain
          ediff-split-window-function #'split-window-horizontally)
    (my-add-hidden-buffer-patterns '(".*Ediff.*"))

;; https://oremacs.com/2017/03/18/dired-ediff/
  (defun ora-ediff-files ()
  (interactive)
  (let ((files (dired-get-marked-files))
        (wnd (current-window-configuration)))
    (if (<= (length files) 2)
        (let ((file1 (car files))
              (file2 (if (cdr files)
                         (cadr files)
                       (read-file-name
                        "file: "
                        (dired-dwim-target-directory)))))
          (if (file-newer-than-file-p file1 file2)
              (ediff-files file2 file1)
            (ediff-files file1 file2))
          (add-hook 'ediff-after-quit-hook-internal
                    (lambda ()
                      (setq ediff-after-quit-hook-internal nil)
                      (set-window-configuration wnd))))
      (error "no more than 2 files should be marked"))))

(my-add-to-hydra main-modes
		 ("Connection"
		  (("hq" ediff-buffers "ediff buffers" :exit t)
                   ("h`" ediff-files "ediff files" :exit t))))

(my-add-to-hydra 'dired-mode
                 ("Connection"
		  (("q" ora-ediff-files "ediff files" :exit t))))


(my-add-to-hydra 'ediff-mode
  		 ("Connection"
  		  ()
  		  "Display"
  		  (("SPC" (ediff-scroll-vertically -1) "scroll up")
                   ("e" (ediff-scroll-vertically 1) "scroll down")
                   ("t" (ediff-scroll-horizontally -1) "scroll left")
                   ("s" (ediff-scroll-horizontally 1) "scroll right"))
  		  "Navigation"
                  (("a" ediff-previous-difference "prev diff")
                   ("n" ediff-next-difference "next diff"))
  		  "Ediff"
  		  (("i SPC o h" ediff-copy-A-to-B  "A->B")
                   ("i SPC o u" ediff-copy-A-to-C  "A->C")
                   ("i SPC h o" ediff-copy-B-to-A  "B->A")
                   ("i SPC h u" ediff-copy-B-to-C  "B->C")
                   ("i SPC u o" ediff-copy-C-to-A  "C->A")
                   ("i SPC u h" ediff-copy-C-to-B  "C->B")
                   ("id" ediff-save-buffer  "save")
                   ("igo" (ediff-restore-diff :key ?A)  "restore A")
                   ("igh" (ediff-restore-diff :key ?B)  "restore B")
                   ("igu" (ediff-restore-diff :key ?C)  "restore C")
                   ("if" ediff-quit "quit"))))

(my-add-to-hydra '(emacs-lisp-mode
  		   lisp-data-mode
  		   lisp-interaction-mode
  		   lisp-mode
  		   org-mode)
  		 ("Code"
  		  (("do" eval-last-sexp "eval last")
  		   ("d-" eval-region "eval region")
  		   ("dh" eval-buffer "eval all"))))

(require 'feature-mode)

(require 'apheleia)
(require 'impatient-mode)
(require 'simple-httpd)

(setq lsp-enable-suggest-server-download nil)

(add-to-list 'auto-mode-alist '("\\.html?\\'" . mhtml-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))

(defun my-web-lsp ()
  "Start HTML/CSS LSP only once the toolbox PATH is visible."
  (setq-local lsp-enabled-clients '(html-ls css-ls))
  (cond
   ((executable-find "vscode-html-language-server")
    (lsp-deferred)
    (apheleia-mode 1))
   ((bound-and-true-p envrc-mode)
    (message "html-ls binary not on devenv PATH"))
   (t
    (add-hook 'envrc-mode-hook #'my-web-lsp nil t))))

(add-hook 'mhtml-mode-hook #'my-web-lsp)
(add-hook 'html-mode-hook #'my-web-lsp)
(add-hook 'css-mode-hook #'my-web-lsp)

(defun my-impatient-preview ()
  "Serve this buffer and open the live preview in Firefox Developer Edition."
  (interactive)
  (unless (process-status "httpd")
    (httpd-start))
  (impatient-mode 1)
  (let ((url (format "http://127.0.0.1:%s/imp/live/%s/"
                     httpd-port
                     (url-hexify-string (buffer-name)))))
    (start-process "impatient-preview" nil
                   "firefox-devedition"
                   "-P" "dev-edition-default"
                   "--new-window"
                   url)))

(my-add-to-hydra '(css-mode html-mode mhtml-mode)
                 ("HTML"
                  (("dn" my-impatient-preview "live preview")
                   ("df" httpd-stop "stop preview")
                   ("im" apheleia-format-buffer "format buffer"))))



(require 'magit)
(setq ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function #'split-window-horizontally
      magit-clone-set-remote.pushDefault t
      magit-diff-refine-hunk 'all
      magit-process-verbose t)
(my-add-hidden-buffer-patterns '(".*magit.*"))
;; (my-add-right-buffer-patterns '(".*magit.*"))

(my-add-to-hydra (append '(dired-mode) main-modes)
  		 ("Connection"
  		  (("hh" magit "magit" :exit t)
  		   ("h>" magit-clone "magit clone" :exit t))))

(my-add-to-hydra '(magit-diff-mode magit-status-mode)
  		 ("Connection"
  		  (("ht" consult-project-buffer "switch proj buff" :exit t)
		   ("h SPC" my-dirvish-side-project "dir side")
		   ("h(" dirvish "dir")
		   ("h*" find-file "find any file"))
		  "Navigation"
  		  (("SPC" magit-previous-line "pree line")
  		   ("e" magit-next-line "nex line"))
		  "Display"
  		  (("t" magit-section-hide "hide sect")
  		   ("s" magit-section-show "show sect"))
		  "Magit"
		  (
		   ;; setting up for work
  		   ("w" magit-fetch "git fetch" :exit t)
  		   ("\\" magit-remote "git remote" :exit t)
  		   ("g" magit-checkout "git checkout")
  		   ("[" magit-branch "git branch" :exit t)

  		   ;; preserving work
  		   ("RET" magit-stage "git stage")
  		   ("DEL" magit-unstage "git unstage")
  		   ("'" magit-reset "git reset" :exit t)
  		   ("d" magit-stash "git stash" :exit t)
  		   ("<tab>" magit-commit "git commit" :exit t)
  		   ("b" magit-push "git push" :exit t)

  		   ;; integrating work
  		   ("p" magit-merge "git merge" :exit t)
  		   ("]" magit-rebase "git rebase" :exit t)
  		   ("ie" magit-discard "choose side to keep")
                 ("q" magit-ediff-show-working-tree "head v changes" :exit t)

		   ;; other
		   ("iq" magit-log "git log" :exit t)
		   ("iw" magit-refresh "git refresh")
  		   ("o" set-mark-command "mark")
  		   ("-" exchange-point-and-mark "mark switch"))))

(require 'markdown-mode)

;; (my-add-to-hydra main-modes
;;   		 ("Connection"
;;   		  ()
;;   		  "Display"
;;   		  ()
;;   		  "Navigation"
;;   		  ()
;;   		  "Interaction"
;;   		  ()))

(require 'nix-mode)

(my-add-to-hydra 'nix-mode
  		 ("Code"
  		  (("im" nix-mode-format "format buffer"))))

(require 'htmlize)
(require 'org)
(require 'org-agenda)
(require 'org-clock nil t) ;; avoid clock kill errors on save and exit?
(require 'org-tidy)
    					;(require 'origami) ;; for some reason this screws with emacs client frame stuff

(add-hook 'org-mode-hook 'org-tidy-mode)

;; ;; fix a warning
;; (add-hook 'org-mode-hook
;;         (lambda () (setq-local tab-width 8))
;;         90)

(defun my-capture-in-project-at-point ()
  "Load project dir-locals and capture to project at point."
  (interactive)
  (let ((project-root (my-get-project-root-at-point)))
    (if (not project-root)
      	(message "No project found at point")
      (let ((default-directory project-root))
        (hack-dir-local-variables-non-file-buffer))
      (org-capture))))

(defun my-open-new-org-agenda ()
  "Force org-agenda to use ONLY the current project's agenda files from .dir-locals."
  (interactive)
  (mapc #'kill-buffer
    	(seq-filter (lambda (b)
                      (string-prefix-p "*Org Agenda" (buffer-name b)))
                    (buffer-list)))
  (setq org-agenda-files nil)
  (hack-dir-local-variables-non-file-buffer)
  (org-agenda))

(defun my-open-new-org-agenda-at-point ()
  "Load project dir-locals and org-agenda for project at point."
  (interactive)
  (let ((project-root (my-get-project-root-at-point)))
    (if (not project-root)
      	(message "No project found at point")
      (let ((default-directory project-root))
        (my-open-new-org-agenda)))))

(defun my-org-agenda-cycle-span (direction)
  "Cycle agenda time span forward or backward.
    DIRECTION: +1 for forward (day → week → month → year), -1 for backward.
    Stops at ends, no wraparound."
  (interactive "p")
  (unless (derived-mode-p 'org-agenda-mode)
    (user-error "Not in an org-agenda buffer"))
  (let* ((current org-agenda-current-span)
         (spans '(day week month year))
         (pos (cl-position current spans))
         (new-pos (max 0 (min (+ pos direction) (1- (length spans)))))
         (new-span (nth new-pos spans)))
    (if (= pos new-pos)
        (message "Already at %s span: %s" (if (> direction 0) "maximum" "minimum") current)
      (org-agenda-change-time-span new-span)
      (message "Span: %s → %s" current new-span))))

;; (defun my-org-agenda-show-headline-in-echo-area ()
;;   (when (eq major-mode 'org-agenda-mode)
;;     (let* ((marker (org-get-at-bol 'org-hd-marker))
;;            (headline (and marker
;;                           (with-current-buffer (marker-buffer marker)
;;                             (save-excursion
;;                               (goto-char (marker-position marker))
;;                               (org-get-heading t t t t))))))  ; t = no TODO, no tags, etc. Adjust as needed
;;       (when (and headline (or (not (current-message)) (string-empty-p (current-message))))
;; 	(message "%s" headline)))))


(defun my-org-agenda-show-headline-in-echo-area ()
  (when (eq major-mode 'org-agenda-mode)
    (let* ((marker (org-get-at-bol 'org-hd-marker))
           (headline (and marker
                          (with-current-buffer (marker-buffer marker)
                            (save-excursion
                              (goto-char (marker-position marker))
                              (org-get-heading t t t t))))))  ; t = no TODO, no tags, etc. Adjust as needed
      (when headline
    	(message "%s" headline)))))

(defun my-select-schedule-from-calendar ()
  (interactive)
  (if (eq major-mode 'calendar-mode)
      (progn
    	(org-calendar-select)
    	(calendar-exit t)
    	(org-agenda-schedule nil (org-read-date nil nil org-ans1))
    	(org-agenda-redo))))

(defun my-select-deadline-from-calendar ()
  (interactive)
  (if (eq major-mode 'calendar-mode)
      (progn
    	(org-calendar-select)
    	(calendar-exit t)
    	(org-agenda-deadline nil (org-read-date nil nil org-ans1))
    	(org-agenda-redo))))

(defun my-org-timestamp-headline ()
"Append an inactive timestamp to the current headline."
(interactive)
(save-excursion
  (org-back-to-heading)
  (end-of-line)
  (insert " ")
  (org-timestamp nil)))

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (add-hook 'post-command-hook
                      #'my-org-agenda-show-headline-in-echo-area
                      nil t)))

(add-hook 'calendar-today-visible-hook 'calendar-mark-today)

(setq calendar-date-style 'iso
      calendar-holidays (append holiday-general-holidays
    				holiday-local-holidays
    				holiday-other-holidays)
      calendar-mark-holidays-flag t
      org-agenda-confirm-kill t
      org-agenda-follow-indirect t
      org-agenda-menu-show-matcher nil
      ;; org-agenda-prefix-format '((agenda . "%?-t ")
      ;; 				 (search . " ")
      ;; 				 (tags . " ")
      ;; 				 (todo . " "))
      org-agenda-show-inherited-tags nil
    					;org-agenda-skip-deadline-prewarning-if-scheduled t
    					;org-agenda-skip-scheduled-if-deadline-is-shown t
      org-agenda-start-with-follow-mode nil
      org-agenda-use-tag-inheritance nil
      org-agenda-window-setup 'current-window
      org-blank-before-new-entry '((heading . nil) (plain-list-item . nil))
      org-id-link-to-org-use-id 'create-if-interactive
      org-refile-use-cache t
      org-refile-use-outline-path t
      org-startup-folded 'nofold
      org-tidy-general-drawer-flag t 
      org-tidy-properties-backspace-map nil
      org-tidy-properties-delete-map nil
      org-tidy-properties-style 'fringe
      org-tidy-top-property-style 'fringe)

(my-add-left-buffer-patterns '("\\*Agenda Commands\\*" "\\*Org Agenda\\*"))
;; (my-add-center-buffer-patterns '(".*\.org$"))


;; custom project stuff

(add-hook 'org-agenda-mode-hook 'hack-dir-local-variables-non-file-buffer)
(defun pmt-get-org-entry-property (pom property-name)
  (car (cdr (flatten-list (org-entry-properties pom property-name)))))

(defun pmt-get-agenda-entry-property (entry property-name)
  (let* ((em (or (get-text-property 1 'org-marker entry)
      		 (get-text-property 1 'org-hd-marker entry)))
      	 (eb (marker-buffer em)))
    (with-current-buffer eb (pmt-get-org-entry-property em property-name))))

(defun pmt-org-cmp-relative-value (a b property)
  "Compare agenda entries by less/average/more. 
      Returns +1 if A > B, -1 if A < B, nil if equal or missing."
  (if (and a b)
      (let* ((ea (pmt-get-agenda-entry-property a property))
             (eb (pmt-get-agenda-entry-property b property))
             (sea (or ea "less"))
             (seb (or eb "less"))
             (order '("less" "average" "more"))
             (ia (cl-position sea order :test #'string=))
             (ib (cl-position seb order :test #'string=)))
        (cond ((= ia ib) nil)
      	      ((< ia ib) -1)
      	      ((> ia ib) +1)))
    nil))

(defun pmt-org-cmp-strategic-value (a b)
  (pmt-org-cmp-relative-value a b "STRATEGIC_VALUE"))

(defun pmt-org-cmp-tactical-value (a b)
  (pmt-org-cmp-relative-value a b "TACTICAL_VALUE"))

(defun pmt-org-cmp-estimated-effort (a b)
  (pmt-org-cmp-relative-value a b "ESTIMATED_EFFORT"))

(defun pmt-skip-top-level-headlines ()
  (if (= (org-outline-level) 1) 1 nil))

(defun pmt-skip-non-tasks ()
  (or (pmt-skip-top-level-headlines)
      (if (member (car (org-get-outline-path)) '("Ideas"
        					 "Occurrences"
        					 "References")) 1 nil)))
(defun pmt-skip-non-occurrences ()
  (or (pmt-skip-top-level-headlines)
      (if (member (car (org-get-outline-path)) '("Ideas"
    						 "Tasks"
        					 "References"
        					 "User stories")) 1 nil)))
(defun pmt-skip-references ()
  (or (pmt-skip-top-level-headlines)
      (if (member (car (org-get-outline-path)) '("References")) 1 nil)))

(defun pmt-skip-hard-dependent-tasks ()
  (or (pmt-skip-non-tasks)
      (cond ((string= (org-entry-get nil "HARD_INTERNAL_DEPENDENCY") "yes") 1)
            ((string= (org-entry-get nil "HARD_EXTERNAL_DEPENDENCY") "yes") 1))))

(defun pmt-skip-all-dependent-tasks ()
  (or (pmt-skip-hard-dependent-tasks)
      (cond ((string= (org-entry-get nil "SOFT_INTERNAL_DEPENDENCY") "yes") 1)
            ((string= (org-entry-get nil "SOFT_EXTERNAL_DEPENDENCY") "yes") 1))))

(setq org-agenda-skip-function-global '(org-agenda-skip-entry-if 'todo 'done)
      org-id-link-to-org-use-id t
      org-todo-keywords '((sequence "future" "next" "now" "|" "past"))
      org-todo-keyword-faces '(("future" . (:foreground "blue" :weight bold))
        		       ("next" . (:foreground "deep sky blue" :weight bold))
        		       ("now" . (:foreground "lawn green" :weight bold))
        		       ("past" . (:foreground "dark olive green" :weight bold))))

(my-add-to-hydra main-modes
  		 ("Connection"
  		  (("ho" my-open-new-org-agenda "agenda"))
  		  "Display"
  		  ()
  		  "Navigation"
  		  ()
  		  "General"
  		  (("j" (progn (org-capture) (org-tidy-buffer)) "org capture" :exit t))))

(my-add-to-hydra 'dired-mode
  		 ("Connection"
  		  ()
  		  "Display"
  		  ()
  		  "Navigation"
  		  ()
  		  "General"
  		  (("j" (progn (my-capture-in-project-at-point) (org-tidy-buffer)) "org capture" :exit t))))

(my-add-to-hydra 'org-mode
  		 ("Connection"
  		  ()
  		  "Display"
  		  (("C-s" (org-fold-show-entry nil) "show entry")
    		   ("C-n" org-fold-show-children "show child")
    		   ("C-c" org-fold-show-branches "show branch")
    		   ("C-u" org-fold-show-all "show subtree")
		   ("C-h" org-cycle "cycle")
		   ("C-g" org-fold-hide-drawer-toggle "toggle drawer")
		   ("C-w" org-tidy-mode "toggle tidy")
		   ("C-a" org-fold-hide-sublevels "hide @lvl")
    		   ("C-t" org-fold-hide-subtree "or hide sub"))
  		  "Navigation"
  		  (("C-SPC" previous-line "or pree line")
    		   ("C-e" next-line "or nex line")
		   ("C-<f1>" org-previous-visible-heading "prev head")
    		   ("C-<f7>" org-next-visible-heading "next head")
		   ("C-v" org-babel-previous-src-block "prev block")
  		   ("C-x" org-babel-next-src-block "next block"))
		  "Text"
		  (("ip" org-comment-dwim "comment"))
  		  "Org"
  		  (("C-<backspace>" org-move-subtree-up "sub up")
    		   ("C-<tab>" org-move-subtree-down "sub down")
    		   ("C-q" org-promote-subtree "promote sub")
    		   ("C-z" org-demote-subtree "demote sub")
		   ("TAB C-t" org-insert-heading "insert head here")
    		   ("TAB C-<f1>" org-insert-subheading "insert sub here")
    		   ("TAB C-SPC" org-insert-heading-respect-content "insert head")
    		   ("TAB C-<return>" my-insert-subheading-respect-content "insert sub")
		   ("TAB TAB" org-todo "cycle todo")
    		   ("TAB C-<tab>" org-priority-down "priority down")
    		   ("TAB C-p" org-priority-up "priority up")
    		   ("TAB C-w" org-property-previous-allowed-value "prev prop val")
    		   ("TAB C-b" org-property-next-allowed-value "next prop val")
		   ("TAB C-s" org-timestamp-down "timestamp down")
		   ("TAB C-e" org-timestamp "timestamp")
		   ("TAB C-n" org-timestamp-up "timestamp up")
		   ("TAB C-<f7>" org-schedule "schedule")
		   ("TAB C-o" my-org-timestamp-headline "timestamp headline")
		   ("TAB C-h" org-deadline "deadline")
    		     ("TAB C-s" org-set-tags-command "set tags")
		   ("d <f12>" org-gfm-export-to-markdown "tangle to md")
		   ("C-d C-b" org-org-export-to-org "export to org")
		   ("db" org-babel-tangle "tangle all")
    		   ("d+" (org-babel-tangle '(4)) "tangle block")
		   ("di RET" org-ctrl-c-ctrl-c "confirm"))
		 ;; "Table"
		 ;; (
		   ;;("M-r" org-table-toggle-column-width "or col width")
  		  ;;  ("M-j" org-table-shrink "or shrink")
  		  ;;  ("M-k" org-table-expand "or expand")
  		  ;;  ("M-q" org-table-move-row-up "or row up")
  		  ;;  ("M-z" org-table-move-row-down "or row down")
  		  ;;  ("M-f" org-table-move-column-left "or col left")
  		  ;;  ("M-u" org-table-move-column-right "or col right")
  		  ;;  ("M-i M-m" org-table-align "or align") ;; alt tab
  		  ;;  ("M-<return>" org-table-edit-field "or edit field")
  		  ;;  ("M-i M-d" (org-table-finish-edit-field) "or confirm edit")
  		  ;;  ("M-i M-d" (org-table-finish-edit-field) "or confirm edit")
  		  ;;  ("M-i M-l" org-table-create "or make table")
  		  ;;  ("M-i M-SPC" (org-table-insert-row '(4)) "or in row")
  		  ;;  ("M-i M-a" org-table-insert-hline "or in line")
  		  ;;  ("M-i M-t" org-table-insert-column "or in col")
  		  ;;  ;; ("M-i M-DEL" org-table-kill-row "or delete row")
  		  ;;  ;; ("M-i M-q" org-table-delete-column "or delete col")
  		  ;;  ;; ("M-i M-r" org-table-sort-lines "or sort")
  		  ;;  ;; ("M-i M-p" org-table-follow-field-mode "or follow mode")
  		  ;;  ;; ("M-i M-n" org-table-header-line-mode "or head mode")
  		  ;;  ("M-t" org-table-previous-field "or pree field")
  		  ;;  ("M-s" org-table-next-field "or nex field")   
  		  ;;  ("M-SPC" previous-line "pree line")
  		  ;;  ("M-e" org-table-next-row "next row")
  		  ;;  ("M-a" org-table-beginning-of-field "or field first")
  		  ;;  ("M-n" org-table-end-of-field "or field last")
  		  ;;  ("M-l" move-beginning-of-line "line first")
  		  ;;  ("M-c" move-end-of-line "line last"))
		  ))

(my-add-to-hydra minibuffer-modes
		 ("Navigation"
  		  (("C-SPC" org-calendar-backward-week "prev day week")
  		   ("C-e" org-calendar-forward-week "next week")
  		   ("C-t" org-calendar-backward-day "prev day")
  		   ("C-s" org-calendar-forward-day  "next day")
  		   ("C-a" org-calendar-backward-month "prev month")	
  		   ("C-n" org-calendar-forward-month "next month")
  		   ("C-l" calendar-backward-year "prev year")	
  		   ("C-c" calendar-forward-year "next year"))))

(my-add-to-hydra 'org-agenda-mode
  		 ("Connection"
  		  (("ho" org-agenda "agenda")
		   ("RET" (org-agenda-goto t) "goto")
  		   ("hf" org-agenda-exit "close agenda")
		   ("h SPC" my-dirvish-side-project "dir side")
		   ("ir" org-goto-calendar "goto calendar"))
  		  "Navigation"
  		  (("SPC" org-agenda-previous-line "pree line")
  		   ("e" org-agenda-next-line "next line")
  		   ("t" backward-char "prev column")
  		   ("s" forward-char "next column")
  		   ("r" consult-line "search" :exit t))
  		  "Display"
  		  (("fd" delete-other-windows "del other wins")
		   ("d" (org-agenda-show-1 4) "show")
  		   ("l" org-agenda-earlier "earlier")
  		   ("c" org-agenda-later "later")
		   ("/" (my-org-agenda-cycle-span -1) "decrease time spac")
  		   ("," (my-org-agenda-cycle-span 1) "increase time span")
  		   ;; ("/" org-agenda-day-view "day view")
  		   ;; ("," org-agenda-week-view "week view")
  		   ;; ("\\" org-agenda-month-view "month view")
  		   ;; ("+" org-agenda-year-view "year view")
  		   ;; ("i TAB" org-agenda-follow-mode "follow mode")
  		   ;; ("iz" (my-agenda-indirect-switch) "follow indirect")
  		   ("ip" org-agenda-filter-by-category "show single cat")
  		   ("i]" (org-agenda-filter-by-category t) "remove cat")
  		   ;;("ib" (org-agenda-filter-remove-all) "remove all filters")
  		   ;; ("ie" (org-agenda-filter-by-tag nil ?\t nil) "show single tag")
  		   ;; ("ic" (org-agenda-filter-by-tag '(64) ?\t nil) "show tag no subs")
  		   ;; ("in" (org-agenda-filter-by-tag '(16) ?\t nil)  "add tag")
  		   ;; ("i;" (org-agenda-filter-by-tag '(4) ?\t nil) "remove tag")
  		   ;; ("i)" (org-agenda-remove-filter 'tag) "remove tag filter")
  		   ;;("io" org-agenda-columns "columns view")
  		   ;;("ih" org-columns "default view")
  		   ;;("is" org-agenda-show-tags "show tags")
  		   ;; ("iy" org-agenda-entry-text-show "show entry text")
  		   ;; ("i|" (org-agenda-entry-text-hide) "hide entry text")
  		   ("iu" org-agenda-toggle-time-grid "togg time grid")
  		   ;;("C-t" origami-close-node "fold")
  		   ;;("C-s" origami-open-node "unfold")
  		   ("hw" org-agenda-redo-all "refresh")
  		   ("iw" org-agenda-redo-all "refresh"))
  		  "Agenda"
  		  (
  		   ("a" org-columns-previous-allowed-value "prev val")
  		   ("n" org-columns-next-allowed-value "next val")  		   
  		   ("<backspace>" org-agenda-date-earlier "date earlier")
  		   ("<tab>" org-agenda-date-later "date later")
  		   ("ii" org-agenda-todo "cycle todo")
  		   ;; ("it" org-agenda-set-tags "set tag" :exit t)
  		   ;;("ir" (progn (org-agenda-todo nil) (org-agenda-redo-all)) "cycle todo")
  		   ;;("ir" org-goto-calendar "goto calendar")
		 ("io" (progn (org-agenda-schedule nil) (org-agenda-redo-all)) "set scheduled" :exit t)
  		   ("i-" (progn (org-agenda-schedule '(4)) (org-agenda-redo-all)) "remove scheduled" :exit t)
  		   ("ih" (progn (org-agenda-deadline nil) (org-agenda-redo-all)) "set deadline" :exit t)
  		   ("i>" (progn (org-agenda-deadline '(4)) (org-agenda-redo-all)) "remove deadline" :exit t)
					;("w" (progn (org-agenda-priority-up) (org-agenda-redo-all)) "priority up")
					;("b" (progn (org-agenda-priority-down) (org-agenda-redo-all)) "priority down")
  		   ("o" org-agenda-bulk-mark "mark")
  		   ("-" org-agenda-bulk-mark-all "mark all")
		   ("<f9>" org-agenda-bulk-unmark "unmark")
  		   ("<f10>" org-agenda-bulk-unmark-all "unmark all")
  		   ("hd" (org-save-all-org-buffers) "save and refresh")
  		   ("i DEL" org-agenda-archive "archive node")
  		   ("i '" org-agenda-kill :exit t "delete node")
  		   ("ig" org-agenda-undo "undo"))))

(my-add-to-hydra 'calendar-mode
  		 ("Connection"
  		  (("hf" calendar-exit "exit"))
  		  "Navigation"
  		  (("SPC" calendar-backward-week "prev day week")
  		   ("e" calendar-forward-week "next week")
  		   ("t" calendar-backward-day "prev day")
  		   ("s" calendar-forward-day  "next day")
  		   ("a" calendar-backward-month "prev month")	
  		   ("n" calendar-forward-month "next month")
  		   ("l" calendar-backward-year "prev year")	
  		   ("c" calendar-forward-year "next year"))
  		  "Display"
  		  ()
  		  "Calendar"
  		  (("RET" my-select-deadline-from-calendar "select deadline")
		   ("d" my-select-schedule-from-calendar "select scheduled"))))

(setq python-indent-offset 4)

(require 'lsp-pyright)
    (add-to-list 'lsp-disabled-clients
      	     '(python-mode . (pyls pylsp ruff-lsp semgrep-ls ty)))

    (add-hook 'python-mode-hook 
    	  (lambda ()
    	    (setq-local lsp-enabled-clients '(pyright)
    			lsp-pyright-diagnostic-mode "openFilesOnly")
    	    (lsp-deferred)))

    (require 'python-pytest)
    (my-add-left-buffer-patterns '("^\\*Python.*"))
    (my-add-hidden-buffer-patterns '("^\\*pyright.*" "^\\*pytest.*" "^\\*ruff.*"))
    (my-add-right-buffer-patterns '("^\\*pytest.*"))

(my-add-to-hydra 'python-mode
  		 ("Connection"
  		  (("in" run-python "python repl"))
  		  "Navigation"
  		  ()
  		  "Display"
  		  ()
  		  "Python"
  		  (("de" python-shell-send-statement "run last")
  		   ("d)" python-shell-send-statement "run region")
  		   ("dn" python-shell-send-buffer "run buffer")
                 ("do" python-pytest-last-failed "test last failed")
                 ("dh" python-pytest-file "test file")
                 ("du" python-pytest "test project")
  		   ("d:" (python-pytest '("--tb=short")) "test project verbose"))))





;; (my-add-to-hydra main-modes
;;   		 ("Connection"
;;   		  ()
;;   		  "Display"
;;   		  ()
;;   		  "Navigation"
;;   		  ()
;;   		  "Interaction"
;;   		  ()))

(defun my-startup ()
  (popper-mode)
  (my-create-frames)
  (envrc-global-mode 1)
  (my-reset-projects))
(add-hook 'server-after-make-frame-hook #'my-startup)
