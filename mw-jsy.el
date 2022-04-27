;;; John Yates's mathworks.el
;; init.el -*- lexical-binding: t; outshine-mode: 1; fill-column: 119 -*-

(defun my/workspace-shell (WORKSPACE)
  "Create or switch to a running shell process in WORKSPACE."
  (interactive "BWorkspace: ")
  (let ((default-directory (concat "/ws/" WORKSPACE "/")))
    (shell WORKSPACE)))

(defun mathworks-sbroot-for-directory (dir)
  "Get the sandbox root for DIR."
  (locate-dominating-file dir ".sbtools"))

(when (file-exists-p "/mathworks/hub/share/sbtools/emacs_setup.el")
  (add-to-list 'load-path "/mathworks/hub/share/sbtools/apps/emacs-add-ons/src/sb-tools/" t)
  (add-to-list 'load-path "/mathworks/hub/share/sbtools/apps/emacs-add-ons/src/general-libs/" t)
  (add-to-list 'load-path "/mathworks/hub/share/sbtools/apps/emacs-add-ons/src/matlab-emacs/matlab-emacs/" t)

  ;; Kill SBTools' heavy-handed attempt to manage my windows
  (defun w100 (&rest args) "" (interactive) nil)
  (defun W100 (&rest args) "" (interactive) nil)
  (defun w200 (&rest args) "" (interactive) nil)
  (defun W200 (&rest args) "" (interactive) nil)
  (defun w300 (&rest args) "" (interactive) nil)
  (defun W300 (&rest args) "" (interactive) nil)

  (provide 'matlab)
  (provide 'matlab-cgen)
  (provide 'matlab-compat)
  (provide 'matlab-complete)
  (provide 'matlab-load)
  (provide 'matlab-maint)
  (provide 'matlab-netshell)
  (provide 'matlab-publish)
  (provide 'matlab-scan)
  (provide 'matlab-shell)
  (provide 'matlab-shell-gud)
  (provide 'matlab-syntax)
  (provide 'matlab-topic)
  (provide 'sb-frame-config)

; (require 'sb-clipboard)
  (require 'sb-tools-root)
  (require 'sb-prompt)
  (require 'sb)

  ;; (defvar sb-prefix-map nil
  ;;   "Special keymap for Matlab & BaT functions.")
  ;; (setq sb-prefix-map (make-sparse-keymap))
  ;; (global-set-key "\C-cm" sb-prefix-map)

  (require 'sb-maps)

  (setq p4-global-key-prefix "\C-cP") ; custom

  (add-to-list 'load-path "/mathworks/hub/share/sbtools/apps/emacs-add-ons/src/p4" t)
  (require 'p4)

  (defun my/clean-up-gud-buffers (orig-fun &rest args)
    (dolist (buf (buffer-list))
      (let ((name (buffer-name buf)))
        (when (>= (length name) 5)
          (let ((prefix (substring name 0 5)))
            (if (or (string= prefix "*gud*")
                    (string= prefix "*gud-"))
                (kill-buffer buf))))))
    ;(select-frame (display-buffer (current-buffer) display-buffer--other-frame-action t))
    (apply orig-fun args))

  (defun sb-debug-ut-gdb ()
    "'sb -debug-ut' in selected directory via GDB/MI (2 windows)"
    (interactive)
    (sb-debug "gdb" t))

  (defun sb-debug-ut-gdb-many-windows ()
    "'sb -debug-ut' in selected directory via GDB/MI (many windows)"
    (interactive)
    (sb-debug "gdb-many-windows" t))

  (advice-add 'sb-debug                     :around #'my/clean-up-gud-buffers)
  (advice-add 'sb-debug-gdb                 :around #'my/clean-up-gud-buffers)
  (advice-add 'sb-debug-gdb-many-windows    :around #'my/clean-up-gud-buffers)
  (advice-add 'sb-debug-ut                  :around #'my/clean-up-gud-buffers)
  (advice-add 'sb-debug-ut-gdb              :around #'my/clean-up-gud-buffers)
  (advice-add 'sb-debug-ut-gdb-many-windows :around #'my/clean-up-gud-buffers)

  (setq locate-dominating-stop-dir-regexp
        (concat
         "\\`" ;; start of string
         "\\(?:" "[\\/][\\/][^\\/]+[\\/]"
         "\\|"   "/\\(?:net\\|afs\\|\\.\\.\\.\\)/"
         ;; Anything under /mathworks /mathworks/SITE needs to be skipped
         "\\|"   "/mathworks/"
         "\\|"   "/mathworks/[A-Z]+/"
         ;; /mathworks/home, /mathworks/hub, /mathworks/public, etc.
         ;; /mathworks/SITE/home/ ...
         "\\|"   "/mathworks/[^/]+/"
         "\\|"   "/mathworks/[A-Z]+/[^/]+/"
         ;; /mathworks/devel/blah, /mathworks/SITE/devel/blah
         "\\|"   "/mathworks/devel/[^/]+/"
         "\\|"   "/mathworks/[A-Z]+/devel/[^/]+/"
         ;; /mathworks/devel/bat/Aslrtw, etc.
         "\\|"   "/mathworks/devel/bat/[^/]+/"
         "\\|"   "/mathworks/[A-Z]+/devel/bat/[^/]+/"
         ;; /mathworks/AH/devel/jobarchive, etc.
         "\\|"   "/mathworks/devel/jobarchive/"
         "\\|"   "/mathworks/[A-Z]+/devel/jobarchive/"
         ;; /mathworks/hub/{blah}
         "\\|"   "/mathworks/hub/[^/]+/"
         "\\|"   "/mathworks/[A-Z]+/hub/[^/]+/"
         ;; /mathworks/hub/scratch
         "\\|"   "/mathworks/hub/scratch/"
         "\\|"   "/mathworks/[A-Z]+/hub/scratch/"
         ;; /mathworks/AH/hub/site-local, etc.
         "\\|"   "/mathworks/hub/site-local/"
         "\\|"   "/mathworks/[A-Z]+/hub/site-local/"
         ;; symlinks
         "\\|"   "/mathworks/sandbox/"
         "\\|"   "/mathworks/home/"
         "\\|"   "/mathworks/hub/"
         "\\|"   "/mathworks/public/"
         "\\)"
         "\\'"  ;; end of string
         ))

  (defvar skip-sbtools-matlab-mode-setup t)
  (when (or (not (boundp 'skip-sbtools-matlab-mode-setup))
            (not skip-sbtools-matlab-mode-setup))

    ;; (add-to-list 'el-get-sources
    ;;              '(:name matlab
    ;;                   :description "Mathworks in-house version of matlab-mode"
    ;;                      :type        http
    ;;                      :url         "file://localhost/hub/share/sbtools/apps/emacs-add-ons/src/matlab-emacs/matlab-emacs/matlab.el"
    ;;                   :features    (matlab)))
    ;; (my/el-get-install "matlab")

    (autoload #'matlab-mode "matlab" "MATLAB Editing Mode" t)
    (autoload #'matlab-shell "matlab" "Interactive MATLAB mode." t)

    (add-to-list 'auto-mode-alist '("\\.m\\'" . matlab-mode)) ;; \' is end of string
    (add-to-list 'auto-mode-alist '("\\.m_[^/]+\\'" . matlab-mode))

    (defun my/matlab-mode-hook ()
      (setq fill-column 80              ; where auto-fill should wrap
            )
      (imenu-add-to-menubar "Find") ; xxx what is this for?
      )
    (add-hook 'matlab-mode-hook 'my/matlab-mode-hook)

    (defun my/matlab-shell-mode-hook ()
      '())
    (add-hook 'matlab-shell-mode-hook 'my/matlab-shell-mode-hook)

    ;; To disable, specify
    ;;  (setq skip-sbtools-mlint-setup t)
    ;; prior to loading emacs_setup.el
    ;;
    ;; See the /matlab/java/extern/EmacsLink/lisp load path addition above
    ;; for mlint lisp code.
    (with-no-warnings
      (if (or (not (boundp 'skip-sbtools-mlint-setup))
              (not skip-sbtools-mlint-setup))
          (progn
            (message "Configuring auto-mlint")
            (autoload #'mlint-minor-mode "mlint" nil t)
            (add-hook 'matlab-mode-hook
                      (lambda ()
                        ;; Following are off by default to help customers
                        ;; which have installed mlint, but didn't install
                        ;; linemark.el, etc. object libraries.
                        (setq matlab-show-mlint-warnings t
                              highlight-cross-function-variables t
                              mlint-flags '("-all" "-id"))
                        (mlint-minor-mode 1)))
            ) ;; progn
        )
      )

    ;;
    ;; Delete file.p if it exists when file.m is saved
    ;;
    (defun matlab-deletep-after-save-hook ()
      "Delete file.p if it exists when file.m is saved"
      (let* ((fname (buffer-file-name (current-buffer)))
             (pfile (concat (file-name-sans-extension fname) ".p"))
             )
        (when (and (file-exists-p pfile)
                   (or noninteractive  ;; sbindent
                       (y-or-n-p (format "Delete %s too? " pfile))))
          (delete-file pfile)
          (message "Deleted %s. Remember to run sbgentbxcache!"
                   (file-name-nondirectory pfile))
          )))

    (add-hook 'matlab-mode-hook (lambda ()
                                  (add-hook 'after-save-hook
                                            'matlab-deletep-after-save-hook
                                            t t))) ;; Local hook in matlab-mode
    )

  (with-no-warnings
    (setq matlab-shell-command "sb"
          matlab-auto-fill nil
          matlab-fill-code nil
          matlab-indent-function-body 'MathWorks-Standard
          matlab-functions-have-end t
          ))


;; Debugging via 'sb -Dgdb' or 'sb -Ddbx', etc.:
;; (defun MY/mathworks-sb-debug (&optional many-windows debug-ut)
;;   "Run 'sb -debug' in specified directory, optionally with many-windows in
;; emacs23 and later. The many-windows mode is known to be slow/buggy when
;; used on MATLAB. Specify sb-default-args use different default arguments
;; to sb"
;;   (interactive)
;;   (let ((run-with-many-windows
;;          (and many-windows
;;               (not (member (framep (selected-frame)) '(nil t pc))))
;;          )
;;         )
;;     (if (equal (get-buffer "*gud*") nil)
;;         ;; Launch gdb
;;      (let* ((start-dir (mathworks-get-sb-dir
;;                            (if debug-ut
;;                                (concat "Unit test directory to debug: " )
;;                              "Run sb -debug in dir: ")))
;;                (default-args (if debug-ut
;;                                  (concat "-debug-ut " start-dir)
;;                                "-debug"))
;;                (sb-args (read-string "Run sb with args: "
;;                                      default-args nil default-args))
;;                (sb-cmd (concat (mathworks-path-to-sbtool-program "sb ")
;;                                " -gdb-switches -i=mi -debug-exe /home/jyates/bin/gdb-strip-fullname " sb-args))
;;                )

;;           ;; Ask for directory to run in.
;;        (switch-to-buffer "*gud*")
;;        (cd start-dir)
;;           (setq gud-chdir-before-run nil) ;; use current directory, start-dir

;;           (if run-with-many-windows  ;; many-windows has a 'studio' interface
;;               (progn
;;                 (require 'gdb-mi)
;;                 ;; (w160)
;;                 (gdb-many-windows 1)
;;                 (gdb sb-cmd)
;;                 )
;;             ;; else run in classic mode
;;             (gud-gdb sb-cmd)
;;             )
;;           )
;;       (progn
;;         (switch-to-buffer "*gud*")
;;         (message "*gud* buffer already exists"))
;;       )
;;     )
;;   )

  ;; Mathworks added undesired lambdas as hook functions.
  ;; HACK: assume that there were no pre-existing hook functions.
  (setq gud-gdb-mode-hook nil)
  (setq gdb-mode-hook nil)

  )  ; (when (file-exists-p "/mathworks/hub/share/sbtools/emacs_setup.el") ...

;; (if (file-exists-p "/mathworks/hub/share/sbtools/emacs_setup.el")
;;     (let (save-version emacs-major-version)
;;       (setq emacs-major-version 24)
;;       (load-file "/mathworks/hub/share/sbtools/emacs_setup.el")
;;       (setq emacs-major-version save-version)))

(provide 'mw-jsy)
