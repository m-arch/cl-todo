(in-package :public)

(clsql-sys:def-view-class task ()
  ((id
    :type (string 64)
    :reader id
    :db-kind :key
    :initarg :id)
   (title
    :type (string 50)
    :accessor title
    :initarg :title
    :db-constraints :unique)
   (description
    :type string
    :accessor description
    :initarg :description)
   (due-date
    :type clsql:date
    :accessor due-date
    :initarg :due-date)
   (parent-id
    :type (string 64)
    :accessor parent-id
    :initarg :parent-id)
   (done-p
    :type boolean
    :accessor done-p
    :initarg :done-p)
   (child-tasks
    :db-kind :virtual
    :accessor child-tasks)
   (parent-task
    :db-kind :virtual
    :accessor parent-task))
  (:base-table tasks))

(defmethod sb-mop:slot-value-using-class :before (class (obj task) def)
  (cond
    ((equal (sb-mop:slot-definition-name def) 'parent-task)
     (setf (parent-task obj) (select-task-by-id (id obj))))
    ((equal (sb-mop:slot-definition-name def) 'child-tasks)
     (setf (child-tasks obj) (select-tasks-by-parent-id (id obj))))))

(clsql:locally-enable-sql-reader-syntax)

(dbfunc insert-task (title description due-date &key parent-id done-p)
	(let ((result (make-instance 'task :title title :description description
				     :due-date due-date :parent-id parent-id
				     :id (make-uuid-string64) :done-p done-p)))
	  (clsql-sys:update-records-from-instance result :database current-db)
	  result))

(dbfunc select-tasks-by-parent-id (parent-id)
  (clsql:select 'task :flatp t :refresh t
		:database current-db
		:where [= [parent-id] parent-id]))

(dbfunc select-task-by-id (id)
	(first (clsql:select 'task :flatp t :refresh t
			     :database current-db 
			     :where [= [id] id])))

(dbfunc select-all-tasks (&key only-parent-p only-not-expired)
	(let ((condition 
	       (cond 
		 ((and (not only-parent-p) only-not-expired)
		  [>= [due-date] (clsql:get-date)])
		 ((and only-parent-p only-not-expired)
		  [and 
		  [>= [due-date] (clsql:get-date)]
		  [is [parent-id] nil]])
		 ((and only-parent-p (not only-not-expired))
		  [is [parent-id] nil])
		 ((and (not only-parent-p) (not only-not-expired))
		  [= t t]))))
	    (clsql:select 'task :flatp t :refresh t
			  :database current-db
			  :where condition)))

(dbfunc task-title-used-p (title)
	(if (clsql:select [title] :from [tasks]
			  :database current-db
			  :flatp t :refresh t
			  :where [= [title] title]
			  :limit 1)
	    t nil))
	

(dbfunc select-tasks-id-and-title ()
	(clsql:select [id] [title] :from [tasks] :flatp t :refresh t
		      :database current-db))

(dbfunc update-task (obj)
	(clsql:update-records-from-instance obj :database current-db))

(dbfunc update-zombie-tasks-by-parent-id (parent-id)
	(clsql:update-records [tasks] :database current-db
			      :where [= [parent-id] parent-id]
			      :av-pairs `(([parent-id] nil))))

(dbfunc delete-task (obj)
	(clsql:delete-instance-records obj :database current-db))

(clsql:locally-disable-sql-reader-syntax)
