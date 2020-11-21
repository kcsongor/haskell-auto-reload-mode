;;; haskell-auto-reload-mode.el --- auto-reload haskell files -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2020 Csongor Kiss
;;
;; Author: Csongor Kiss <http://github/kcsongor>
;; Maintainer: Csongor Kiss
;; Created: March 23, 2020
;; Modified: March 23, 2020
;; Version: 0.0.1
;; Keywords:
;; Homepage: https://github.com/kcsongor/haskell-auto-reload-mode.el
;; Package-Requires: ((emacs 26.3) (cl-lib "0.5"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  description
;;
;;; Code:

(require 'haskell)

(defvar haskell-auto-reload-every-n-sec 1
  "When non-nil, automatically reloads haskell buffers after Emacs has been idle for N seconds.")

(defvar haskell-reload-timer nil
  "Variable used to store the idle timer.")

;;;###autoload
(define-minor-mode haskell-auto-reload-minor-mode
  "Minor mode for automatically reloading interactive haskell buffers."
  :lighter "HR"

  (when haskell-reload-timer (cancel-timer haskell-reload-timer))
  (if haskell-auto-reload-minor-mode
      (progn
        (add-hook 'after-save-hook 'try-reload-haskell nil t)
        (when (featurep 'evil)
         (add-hook 'evil-normal-state-entry-hook 'try-save-haskell nil t))
        (when haskell-auto-reload-every-n-sec
          (setq haskell-reload-timer
                (run-with-idle-timer
                 haskell-auto-reload-every-n-sec t
                 'try-save-haskell))))
    (progn
      (remove-hook 'after-save-hook 'try-reload-haskell t)
      (when (featurep 'evil)
           (remove-hook 'evil-normal-state-entry-hook 'try-save-haskell t)))))

(defun try-reload-haskell ()
  "Attempt to reload a Haskell buffer.
Only does so when there is an associated session."
  (when (and
         (derived-mode-p 'haskell-mode)
         (haskell-session-maybe))
    (haskell-process-reload)))

(defun try-save-haskell ()
  "Attempt to save a Haskell buffer.
Only does so when the buffer has changed, as this will trigger a reload."
  (when (and
         (when (featurep 'evil-states)
           (evil-normal-state-p))
         (buffer-modified-p)
         (derived-mode-p 'haskell-mode)
         (haskell-session-maybe))
    (save-buffer)))

(provide 'haskell-auto-reload-mode)
;;; haskell-auto-reload-mode.el ends here

