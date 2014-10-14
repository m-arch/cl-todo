(in-package :public)

(defparameter *database-host* "localhost")
(defparameter *database-name* "marcdb")
(defparameter *database-user* "root")
(defparameter *database-password* "")
(defparameter *database-type* :mysql)
(defparameter +HOSTNAME+ "localhost:8080")
(defparameter *template-directory*
  (merge-pathnames #p"templates/" instance:*base-directory*))
(defparameter *js-directory*
  (merge-pathnames #p"javascript/" instance:*base-directory*))


(defparameter +MONTHS+ '("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))
