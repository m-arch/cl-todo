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
	    (log:fatal original-file)
	    (setf func (djula:compile-template* (namestring original-file)))
	    (log:fatal func file)
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
    (log:trace post)
    (if post
	post
	(hunchentoot:get-parameter parameter))))


(defun genurl (sym  &rest args &key (relative t) &allow-other-keys)
  "allow for the generation of restas urls,
Variables:
sym, is the function symbol
relative, indicates if the returned url should be a relative url (when t) or global url (when nil)"
  (let ((url nil)
	(scheme :http))
    (log:trace args)
    (if (not restas:*MODULE*)
	(cond
	  (relative
	   (apply 'restas:genurl sym args))
	  ((not relative)
	   (setf url (restas::make-route-url sym args))
	   (setf (puri:uri-scheme url) scheme
		 (puri:uri-host url) +HOSTNAME+)
	   (puri:render-uri url nil)))
	(cond 
	  (relative
	   (setf url (restas::make-route-url (restas::route-symbol-template sym) args))	   
	   (puri:render-uri url nil))
	  ((not relative)
	   (setf url (restas::make-route-url (restas::route-symbol-template sym) args))
	   (setf (puri:uri-scheme url) scheme
		 (puri:uri-host url) +HOSTNAME+)
	   (puri:render-uri url nil))))))
