;; use to get secret into emacs, assuming the envrc package has correctly loaded the devenv environment for the file being visited
(defun my-secretspec-get (name)
  "Retrieve a secret using SecretSpec CLI.
Returns the value as string or nil if not found / error."
  (let ((output (inheritenv (shell-command-to-string
			     (format "secretspec get %s"
				     (shell-quote-argument name))))))
    (if (string-empty-p (string-trim output))
        nil
      (string-trim output))))
