# Introduction
A tiny emacs plugin, exporting orgmode doc to pdf using wkhtmltopdf(https://wkhtmltopdf.org).

# Installation

Add the `org-export-wkhtmltopdf/` directory to `load-path`, then call `require`:

```elisp
(add-to-list 'load-path "/path/to/org-export-wkhtmltopdf")
(require 'org-export-wkhtmltopdf)
```

# Usage

**Integration with the Org export dispatcher**: After loading the package, a `p` entry appears in the `C-c C-e` menu:

```text
C-c C-e p w    ; pdf via wkhtmltopdf
C-c C-e p o    ; pdf via wkhtmltopdf and open
```

If wkhtmltopdf location not in the path, change the value of `org-wkhtmltopdf-command` to the actual location of wkhtmltopdf.
