(in-package :public)

(defmacro dbfunc (func-name arg-list &rest body)
  (let ((documentation "A database function")
	(db-name *database-name*))
    (if (stringp (first body))
	(progn
	  (setf documentation (first body))
	  (setf body (rest body))))
    `(defun ,func-name ,arg-list
       ,documentation
       (let ((temp-func-name #'(lambda ()
				 (clsql:with-database (current-db `(,*database-host* ,,db-name ,*database-user* ,*database-password*)
								  :pool t
								  :database-type ,*database-type*)
				   ,@body))))
	 (funcall temp-func-name)))))

(defmacro define-route (name 
			(url &key (method :get) template-file content-type)
			&rest body)
  "This macro will pack and provide html content. 
Variables are:
name: the name of the route
url: the url of the route.
method: a post or get method
template-file: is the file path that will fill the page
content-type: is the route content type (eg. 'application/json')"
  `(restas:define-route ,name (,url :method ,method :content-type ,content-type)
     (cond 
       ((eql ,content-type "application/json")
	(json:encode-json-to-string `,,@body))
       (t
	(apply #'fill-template 
	       (append `(,,template-file)
		       ,@body
		       (list
			:home-url (genurl 'home-get)
			:new-task-url (genurl 'task-get :action "add")
			:tasks-get-url (genurl 'tasks-get))))))))

