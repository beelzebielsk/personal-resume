#lang racket
(require pollen/core)
(require pollen/tag)
(require txexpr)
(provide (all-defined-out))

(module setup racket/base
        (provide (all-defined-out))
        (define poly-targets '(latex odt)))

; Pollen Utility Functions: {{{ --------------------------------------
(define (select-path . args)
  (let [(terms (take args (sub1 (length args))))
        (tag (last args))]
    (let [(new-terms (select* (car terms) tag))]
      (if (or (= (length terms) 1) (eq? new-terms #f))
        (if (list? new-terms)
          (car new-terms)
          new-terms)
        (apply select-path
               (append (cdr terms) (list (cons 'root new-terms))))))))
(define (select-path* . args)
  (let [(terms (take args (sub1 (length args))))
        (tag (last args))]
    (let [(new-terms (select* (car terms) tag))]
      (if (or (= (length terms) 1) (eq? new-terms #f))
        new-terms
        (apply select-path*
               (append (cdr terms) (list (cons 'root new-terms))))))))

; }}} ----------------------------------------------------------------

; Latex Functions: {{{ -----------------------------------------------
(define (latex-macro #:optional [opt-args '()] cmd-name . args)
  (let* [(macro-start (string-append "\\" cmd-name))
         (bad-args?
           (lambda (lst)
             (not (andmap string? lst))))
         (with-optional 
           (cond [(bad-args? opt-args)
                  (error "opt-args not okay.")]
                 [(null? opt-args)
                  macro-start]
                 [else 
                   (string-append macro-start 
                            (string-join opt-args ", "
                                         #:before-first "["
                                         #:after-last "]"))]))
         (bracked-args 
           (cond [(bad-args? args) 
                  (error "args not okay.")]
                 [(null? args) ""]
                 [else (string-join args
                          "}{"
                          #:before-first "{"
                          #:after-last "}")]))]
    (string-append with-optional bracked-args)))
(define (latex-env #:required [args '()] 
                   #:optional [opt-args '()] 
                   #:text-after-begin [suffix ""]
                   name contents)
  ;(displayln (list "args:" args))
  ;(displayln (list "opt-args:" opt-args))
  ;(displayln (list "suffix:" suffix))
  ;(displayln (list "name:" name))
  ;(displayln (list "contents:" contents))
  (string-append
    (apply latex-macro `("begin" ,name ,@args) #:optional opt-args)
    suffix "\n"
    contents "\n"
    (latex-macro "end" name)))
(define (latex-scope . contents)
  (apply string-append `("{" ,@contents "}")))
(define (list-item str)
  (string-append (latex-macro "item") " " str))
; }}} ----------------------------------------------------------------

; Tags: {{{ ----------------------------------------------------------

(define paragraph-break "\n\n")

; symbol? -> (procedure any/c)
; Quickly create a function to determine if a given value is a
; specific txexpr tag.
(define (is-tag? tag)
  (lambda (elem)
    (and (txexpr? elem) (eq? tag (get-tag elem)))))

(define-tag-function (skills attrs elements)
  (let* [(attrs (attrs->hash attrs))
         (type (hash-ref attrs 'type))]
    (list 'skills
    (string-append
      (list-item type) ":" "\n"
      (latex-env 
        "short"
        (string-join (map list-item (select* 'item (cons 'root elements)))
                     "\n"))))))


(define-tag-function (coursework attrs elements)
  (let* [(root (cons 'root elements))
         (courses (select* 'course root))]
    (list 'coursework)
    (latex-env
      "short"
      (string-join (map list-item courses) "\n"))))

(define-tag-function (school attrs elements)
  (let* [(root (cons 'root elements))
         (name (select 'name root))
         (date (select 'graduation-date root))
         (degree (select 'degree root))
         (course-list (select 'coursework root))]
    (list 'school
    (string-append
      (latex-env
        "newplace"
        (string-append
          (latex-macro "placerow" name date)
          (latex-macro "jobrow" degree)))
      paragraph-break
      (latex-env
        "newplace"
        (latex-macro "placerow" "Coursework"))
      paragraph-break
      course-list))))

(define-tag-function (education-information attrs elements)
  (let* [(root (cons 'root elements))
         (school (findf-txexpr root (is-tag? 'school)))]
    (list 'education-information
    (latex-env 
      "resumesection"
      #:required '("Education")
      (string-append
        paragraph-break
        school
        paragraph-break)))))

(define-tag-function (personal-information attrs elements)
  (let* [(root (cons 'root elements))
         (name (select 'name root))
         (email (select 'email root))
         (github (select 'github root))
         (phone-number (select 'phone-number root))
         (linkedin (select 'linkedin root))]
    (list 'personal-information
    (case (current-poly-target)
      [(latex)
       (latex-env 
         "center" 
         (string-append
           (latex-macro "name" name) "\n"
           (latex-scope
             (latex-macro "setlength" 
                          (latex-macro "tabcolsep") "0pt")
             (latex-env 
               "tabu"
               #:text-after-begin " to \\textwidth {XX[r]}"
               (string-append
                 email " &"
                 github " \\\\"
                 phone-number " &"
                 linkedin)))))]
      [else 'hi]))))

(define-tag-function (entry attrs elements)
  (displayln elements)
  (let* [(root (cons 'root elements))
        (name (select 'name root))
        (major-tech (select 'major-technology root))
        (place-name
          (if major-tech
            (format "~a, ~a" name major-tech)
            name))
        (date (select 'entry-date root))
        (role (select 'role root))
        (location (select 'location root))
        (placerow (latex-macro "placerow" place-name date))
        (default-value (lambda (val default) (or val default)))
        (place
          (latex-env 
            "newplace"
            (if (or role location)
              (let [(role (default-value role ""))
                    (location (default-value location ""))]
                (string-append
                  placerow "\n"
                  (latex-macro "jobrow" role location)))
              placerow)))
        (item-func (lambda (tag) 
                     (list-item (car (get-elements tag)))))
        (content-func
          (lambda (tag)
            (let [(items 
                    (map item-func (findf*-txexpr tag (is-tag? 'item))))]
              (latex-env
                "bullets"
                (string-join items "\n")))))
        (content 
          (let [(search-result (findf-txexpr root (is-tag? 'content)))]
            (if (not search-result)
              ""
              (content-func search-result))))]
    (list 'entry
    (string-append
      place "\n\n"
      content))))


(define-tag-function (projects attrs elements)
  (list 'projects
  (latex-env 
    "resumesection" 
    #:required '("Projects")
    (string-join (select* 'entry (cons 'root elements)) 
                 "\n\n"
                 #:before-first "\n"
                 #:after-last "\n"))))


(define-tag-function (experience attrs elements)
  (list 'experience
  (latex-env 
    "resumesection" 
    #:required '("Experience")
    (string-join (select* 'entry (cons 'root elements)) 
                 "\n\n"
                 #:before-first "\n"
                 #:after-last "\n"))))


(define-tag-function (phone-number attrs elements)
  (list 'phone-number
  (let* [(chars 
           (filter (lambda (char)
                     (not (member char (list #\- #\( #\)))))
                   (string->list (car elements))))
         (area-code (list->string (take chars 3)))
         (chunk1 (list->string (take (drop chars 3) 3)))
         (chunk2 (list->string (drop chars 6)))]
    (format "(~a)-~a-~a" area-code chunk1 chunk2))))

; }}} ----------------------------------------------------------------


