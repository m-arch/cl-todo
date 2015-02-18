(in-package :public)

(define-route home-get ("" :template-file "home.html.tmpl")
  (list
   :page-title "Welcome"
   :project-description "This is a tasks manager. It allows you to manage your task, by being able to create, edit and delete tasks. You can also create sub-tasks, by selecting a parent task."))


(define-route tasks-get ("/tasks" :template-file "tasks.html.tmpl")
;; "This route does not get the tasks to fill the template,
;; instead the template file iteslf uses lisp tags to call the function fill-tasks-html-from-parent-tasks.
;; This is done only for fun purpose and to use recursivity.
;; An iterative solution would be to get all tasks and then use hash table where a parent task points to it childs tasks and fills the template." 
    (list
     :page-title "My Tasks"))

(define-route task-get ("/task/:action" :template-file "task-edit.html.tmpl")
  (let ((task (select-task-by-id (data-param "id")))
	(parent-tasks (select-tasks-id-and-title)))
    (list
     :post-url (genurl 'task-post)
     :action action
     :page-title (if task (title task) "New Task")
     :task task
     :parent-tasks parent-tasks)))


(define-route task-post ("/task" :method :post 
				 :content-type "application/json")
  (let ((id (data-param "id"))
	(action (data-param "action"))
	(title (data-param "title"))
	(description (data-param "description"))
	(parent-id (data-param "parentId"))
	(due-date (if (string/= "" (data-param "dueDate"))(parse-date-string (data-param "dueDate")))))
    (if (string= parent-id "")
	(setf parent-id nil))
    (multiple-value-bind (success message)
	(handle-task-post action id title description parent-id due-date)
      (log:fatal success message)
      `((:success . ,success) (:message . ,message)))))


(defun handle-task-post (action id title description parent-id due-date)
  (let ((parent (select-task-by-id parent-id))
	(task (select-task-by-id id)))
    (cond
      ((and (string/= action "add") (string/= action "edit") (string/= action "delete") 
	    (string/= action "complete"))
       (values nil "Wrong action"))
      ((and (or (string= action "add") (string= action "edit")) (or (or (not title) (string= title "")) (not due-date)))
       (values nil "Required fields indicated by * are missing"))
      ((and (string= action "add") (task-title-used-p title))
       (values nil "Task title in use"))
      ((and (string= action "add") (clsql:date< due-date (clsql:get-date)))
       (values nil "Task cannot be created in the past"))
      ((and (not task) (string= action "edit") (string= action "delete") (string= action "complete"))
       (values nil "No task found"))
      ((and parent-id (not parent))
       (values nil "Parent task not found"))
      ((string= action "add")
       (insert-task title description due-date :parent-id (if parent parent-id))
       (values t "Task successfully created"))
      ((string= action "edit")
       (setf (title task) title)
       (setf (description task) description)
       (setf (due-date task) due-date)
       (setf (parent-id task) parent-id)
       (update-task task)
       (values t "Task successfully updated"))
      ((string= action "delete")
       (update-zombie-tasks-by-parent-id (id task))
       (delete-task task)
       (values t "Task successfully delete"))
      ((string= action "complete")
       (setf (done-p task) t)
       (update-task task)
       (values t "Task indiaced as completed")))))
      
