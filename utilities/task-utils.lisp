(in-package :public)

(defun fill-tasks-html-from-parent-tasks (tasks &key is-child-p)
  (let ((html ""))
    (loop for task in tasks
       do
	 (setf html (format nil "~A<div class='task'><div class='task-~A'><p><b><a href='~A'>~A </a></b><span>~A</span><span class='buttons'>~A<button onclick='~A'>detete</button>~A</span></p></div>~A</div><div class='separator'></div>" html 
			    (cond 
			      ((done-p task)
			       "done")
			      ((clsql:date>= (clsql:get-date) (due-date task))
			       "delay")
			      (t
			       "pending"))
			    (format nil "/task/edit?id=~A" (id task)) (title task) 
			    (if (description task) 
				(description task) 
				"no description")
			    (date-string (due-date task)) 
			    (format nil "submitTaskEdit(\"~A\",\"~A\",\"~A\",\"~A\");return false;" (genurl 'task-post) "delete" (genurl 'tasks-get) (id task))
			    (if (not (done-p task))
				(format nil "<button onclick='submitTaskEdit(\"~A\", \"~A\", \"~A\", \"~A\"); return false;'>done</button>" 
					"/task" "complete" "/tasks" (id task))
				"")
			    (fill-tasks-html-from-parent-tasks (child-tasks task) :is-child-p t))))
    (if (and (not is-child-p) (string= "" html))
	"You currently have no tasks"
	html)))
    
