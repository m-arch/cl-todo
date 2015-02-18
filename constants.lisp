(in-package :public)

(defvar *database-host* "localhost")
(defvar *database-name* "marcdb")
(defvar *database-user* "root")
(defvar *database-password* "")
(defvar *database-type* :mysql)
(defvar *template-directory*
  (merge-pathnames #p"templates/" instance:*base-directory*))
(defvar *js-directory*
  (merge-pathnames #p"javascript/" instance:*base-directory*))

(defvar +HOSTNAME+ "localhost:8080")
(defvar +MONTHS+ '("Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"))


