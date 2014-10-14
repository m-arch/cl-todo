(in-package #:clsql-sys)


(defmethod update-view-from-class ((class standard-db-class)
                                   &key (database *default-database*) (transactions t)
                                   (drop-extra-columns t)
                                   (if-does-not-exist :create))
  "Update the table correspoding to the clas CLASS.

DATABASE and TRANSACTIONS have the same semantisc as with
CREATE-VIEW-FROM-CLASS. DROP-EXTRA-COLUMNS specifies what to do
with columns which appear in the table but not in the class. When
T we drop these 'extra' columns, when NIL we just leave them.

IF-DOES-NOT-EXIST specifies what to do when the table doesn't
exist:

  :CREATE - Create the table using CREATE-VIEW-FROM-CLASS.
  :ERROR  - Signal an error.
  NIL     - Do nothing."
  (if (table-exists-p (view-table class))
      (update-existing-table class
                             :drop-extra-columns drop-extra-columns
                             :database database)
      (ecase if-does-not-exist
        (:create (create-view-from-class (class-name class)
                                         :database database
                                         :transactions transactions))
        (:error (error "No existing table to update. Class: ~S; base-table: ~S"
                       class (view-table class)))
        (nil ()))))
