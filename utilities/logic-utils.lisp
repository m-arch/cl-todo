(in-package :public)

(defun make-uuid-string64 ()
  (uuid:print-bytes nil (uuid:make-v4-uuid)))


(defun type-to-string (type)
  (cond 
    ((string= type "pending")
     "pending ")
    ((string= type "parents-pending")
     "pending parent ")
    (t
     "")))


(defun parse-date-string (str)
  "Input string, outputs a clsql date"
  (if (or (not str) (not (stringp str)) (string= str ""))
      (clsql:get-date)
      (let ((parsed (cl-ppcre:split "-" str)))
	(handler-case 
	    (clsql:make-date :year (parse-integer (first parsed))
			     :month (parse-integer (second parsed))
			     :day (parse-integer (third parsed)))
	  (error () (clsql:get-date))))))


(defun to-bool (str)
  (if str
      (if (integerp str)
	  (if (= str 0)
	      nil
	      t)
	  (if (or (equal "true" str) (equal "TRUE" str))
	      t
	      nil))
      nil))

(defun date-string (date)
   (if (clsql-sys:date-p date)
       (multiple-value-bind (year month day)
      (clsql:date-ymd date)
	 (format nil "~A, ~A ~A" day (nth (1- month) +MONTHS+) (mod year 2000)))))


(defun date-to-yyyy-mm-dd (date)
   (if (clsql-sys:date-p date)
       (multiple-value-bind (year month day)
      (clsql:date-ymd date)
	 (format nil "~A-~2,'0d-~2,'0d" year month day))))
