(in-package :public)

(defun fill-template (file &optional &rest args
			      &key (package 'public) 
				&allow-other-keys)
	  "this function fills the template file using djula"
	  (let ((original-file (if (equal (char (namestring file) 0) #\/)
				   file
				   (merge-pathnames file (symbol-value (find-symbol
									(symbol-name '*template-directory*) package)))))
		(func nil))
	    (setf func (djula:compile-template* (namestring original-file)))
	    (apply #'djula:render-template* (append `(,func nil) args))))

(defun template-variable (var-name &key (format-func nil))
  "Takes a variable that was sent through fill template and resolves it to a useful lisp variable (in case the dot notation is used). Used mainly in the template between lisp code brackets"
  (let ((result nil))
    (if (or (find #\. var-name)
	    (find #\| var-name))
	(setf result (djula::resolve-variable-phrase (djula::parse-variable-phrase var-name)))
	(setf result (djula::get-variable var-name)))
    (cond
      (format-func
       (funcall format-func result))
      (t
       result))))


(defun data-param (parameter)
  "retrieves the parameter from hunchentoot request. if post parameter exists it is retrieved if not the get parameter is retrieved"
  (let ((post (hunchentoot:post-parameter parameter)))
    (if post
	post
	(hunchentoot:get-parameter parameter))))

