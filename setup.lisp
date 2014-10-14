(in-package :public)
(asdf:operate 'asdf:load-op '#:restas)
(restas:start '#:public :port 8080)

(clsql::locally-enable-sql-reader-syntax)

(dbfunc setup-db ()
  "sets up the db"
  (in-package :public)
  (mapcar
   #'(lambda (view-name)
       (let ((view (find-symbol view-name)))
	 (handler-case
	     (progn
	       (setf clsql:*default-database* current-db)
	       (if (not (clsql:table-exists-p view))
		   (clsql-sys:create-view-from-class view :database current-db)))
	   (clsql-sys::sql-database-data-error (sql-error)
	     (log:warn (clsql:sql-error-database-message sql-error))))))
   '("TASK")))

(clsql::locally-disable-sql-reader-syntax)

(setup-db)
(in-package :public)
