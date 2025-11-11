;;; foldvis-hideshow.el --- Display indicators for hideshow  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Shen, Jen-Chieh

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Display indicators for hideshow.
;;

;;; Code:

(require 'hideshow)

(require 'foldvis)

;;
;; (@* "Entry" )
;;

;;;###autoload
(defun foldvis-hideshow--enable ()
  "Enable the folding minor mode."
  (add-hook 'hs-show-hook #'foldvis-hideshow--refresh nil t)
  (add-hook 'hs-hide-hook #'foldvis-hideshow--refresh nil t))

;;;###autoload
(defun foldvis-hideshow--disable ()
  "Disable the folding minor mode."
  (remove-hook 'hs-show-hook #'foldvis-hideshow--refresh t)
  (remove-hook 'hs-hide-hook #'foldvis-hideshow--refresh t))

;;;###autoload
(defun foldvis-hideshow--valid ()
  "Return non-nil if the backend is valid."
  (and (featurep 'hideshow) hs-minor-mode))

;;
;; (@* "Events" )
;;

;;;###autoload
(defun foldvis-hideshow--toggle ()
  "Event to toggle folding on and off."
  (hs-toggle-hiding))

;;
;; (@* "Core" )
;;

;;;###autoload
(defun foldvis-hideshow--refresh (&rest _)
  "Refresh indicators for all folding range."
  (when hs-minor-mode
    (goto-char (point-min))
    (while (search-forward-regexp hs-block-start-regexp nil t)
      (when (if hideshowvis-ignore-same-line
                (let ((begin-line (save-excursion
                                    (goto-char (match-beginning 0))
                                    (line-number-at-pos (point)))))
                  (save-excursion
                    (goto-char (match-beginning 0))
                    (ignore-errors
                      (progn
                        (funcall hs-forward-sexp-func 1)
                        (> (line-number-at-pos (point)) begin-line)))))
              t)
        (let* ((ovl (make-overlay (match-beginning 0) (match-end 0))))
          (overlay-put ovl 'before-string
                       (propertize
                        "*hideshowvis*"
                        'display
                        (list 'left-fringe
                              'hideshowvis-hideable-marker
                              'hideshowvis-hidable-face)))
          (overlay-put ovl 'hideshowvis-hs t))))
    (run-hooks 'foldvis-refresh-hook)))

(provide 'foldvis-hideshow)
;;; foldvis-hideshow.el ends here
