(require 'ox-html)

(defcustom org-wkhtmltopdf-command "wkhtmltopdf"
  "Path to wkhtmitopdf executable."
  :group 'org-export
  :type 'string)

(defcustom org-wkhtmltopdf-options
  '("--enable-local-file-access" "--encoding" "utf-8" "--outline" "--outline-depth" "7")
  "Default options passed to vkhtmitopdf."
  :group 'org-export
  :type '(repeat string))

;; inherit html，register export menu entrance.
(org-export-define-derived-backend 'wkhtmltopdf 'html
  :menu-entry
  '(?p "Custom Export" ((?w "pdf via whtmltopdf" org-wkhtmltopdf-export-to-pdf) (?o "PDF via whtmitopdf and open" org-wkhtmltopdf-export-to-pdf-and-open))))


(defun org-wkhtmltopdf-export-to-pdf (&optional async subtreep visible-only body-only ext-plist)
  "Export current 0rg buffer to PDF: first HTML, then wkhtmltopdf."
  (interactive)
  (let* ((html-file (org-export-output-file-name ".html" subtreep))
	 (pdf-file (org-export-output-file-name ".pdf" subtreep))
	 (html-abs (replace-regexp-in-string "^\\([a-zA-Z]\\):" "/\\1" (expand-file-name html-file)))
	 (pdf-abs (replace-regexp-in-string "^\\([a-zA-Z]\\):" "/\\1" (expand-file-name pdf-file)))
	 ;;awk 替换后的临时文件
	 (tmp-html (concat (file-name-sans-extension html-file) "_no_h1.html"))
	 (tmp-html-abs (replace-regexp-in-string "^\\([a-zA-Z]\\):" "/\\1" (expand-file-name tmp-html)))
	 (awk-cmd (format "awk '{gsub(/<h1 /, \"<div \"); gsub(/<\\/h1>/, \"</div>\"); print}'  \"%s\" > \"%s\""
			  html-abs tmp-html-abs))
	 (pdf-cmd (concat (mapconcat #'shell-quote-argument (append (list org-wkhtmltopdf-command)
								    org-wkhtmltopdf-options)
				       " ")
			  " \"" tmp-html-abs "\""
			  " \"" pdf-abs "\"")))
    ;; 1) 导出HTML
    (org-export-to-file 'html html-file nil subtreep visible-only body-only ext-plist)
    ;; 2) awk replace h1 with div
    (message "Replacing h1: %s" awk-cmd)
    (call-process-shell-command awk-cmd)
    ;; 3) wkhtmltopdf
    (message "Running：%s" pdf-cmd)
    (let ((code (call-process-shell-command pdf-cmd)))
      ;;4) clean temp file.
      (delete-file tmp-html)
      (if (and (numberp code) (= code 0))
	  (progn (message "PDF exported: %s" pdf-file) pdf-file)
	(error "wkhtmltopdf failed (exit code %s) " code)))))


(defun org-wkhtmltopdf-export-to-pdf-and-open (&optional async subtreep visible-only body-only ext-plist)
  "Export current 0rg buffer to PDF: first HTML, then wkhtmltopdf."
  (interactive)
  (org-wkhtmltopdf-export-to-pdf async subtreep visible-only body-only ext-plist))

;;auto open PDF after export
(defun my/org-wkhtmltopdf-open-after-export (pdf-file &rest _)
  "org-wkhtmltopdf-export-to-pdf filter-return advice. auto open PDF after export."
  (when (and pdf-file (file-exists-p pdf-file))
    (message "opening exported PDF：%s" pdf-file)
    (cond
     ((eq system-type 'darwin)
      (call-process "open" nil 0 nil pdf-file))
     ((eq system-type 'windows-nt)
      (w32-shell-execute "open" pdf-file))
     ((eq system-type 'gnu/linux)
      (call-process "xdg-open" nil 0 nil pdf-file))
     (t (message "auto opening PDF not supported system: %s" system-type))))
pdf-file) ;; return pdf-file, keep return value the same.

(advice-add 'org-wkhtmltopdf-export-to-pdf-and-open :filter-return #'my/org-wkhtmltopdf-open-after-export)

(provide 'org-export-wkhtmltopdf)
