(defpackage #:instance
  (:export *base-directory*))

(defvar instance:*base-directory* 
  (make-pathname :name nil :type nil :defaults *load-truename*))

(asdf:defsystem #:cl-todo
  :serial t
  :description "Welcome to marc's todo list"
  :author "Marc Mouallem"
  :depends-on (:restas :cl-json :hunchentoot :html-template :djula :log4cl :clsql :clsql-mysql :uuid)
  :components ((:file "modules") (:file "constants") (:file "macros")   
	       (:module 
		"db" :pathname "db-models" 
		:components ((:file "task")))
	       (:module 
		"utilities" :pathname "utilities"
		:components ((:file "template-utils") (:file "logic-utils") (:file "task-utils")))
	       (:module
		"logic" :pathname "logic"
		:components ((:file "task")))
	       (:file "setup")))
