#lang racket
(require pollen/setup)
(require pollen/core)
(require pollen/tag)
(require txexpr)
(provide (all-defined-out))

(module setup racket/base
        (provide (all-defined-out))
        (define poly-targets '(tex odt java)))

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

; tex Functions: {{{ -----------------------------------------------
(define (tex-macro #:optional [opt-args '()] cmd-name . args)
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
(define (tex-env #:required [args '()] 
                   #:optional [opt-args '()] 
                   #:text-after-begin [suffix ""]
                   name contents)
  ;(displayln (list "args:" args))
  ;(displayln (list "opt-args:" opt-args))
  ;(displayln (list "suffix:" suffix))
  ;(displayln (list "name:" name))
  ;(displayln (list "contents:" contents))
  (string-append
    (apply tex-macro `("begin" ,name ,@args) #:optional opt-args)
    suffix "\n"
    contents "\n"
    (tex-macro "end" name)))
(define (tex-scope . contents)
  (apply string-append `("{" ,@contents "}")))
(define empty-tex-arg "")
(define (list-item str)
  (string-append (tex-macro "item") " " str))

; }}} ----------------------------------------------------------------

; Java Functions: {{{ ------------------------------------------------
(define (write-java-call func . args)
  (string-append 
    func
    (string-join args ", "
                 #:before-first "("
                 #:after-last ");")))
(define (java-string str)
  (format "\"~a\"" str))
(define (java-array type lst)
  (string-join lst ", "
               #:before-first (format "new ~a[] {" type)
               #:after-last "}"))
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
         (type (hash-ref attrs 'type))
         (items (select* 'item (cons 'root elements)))
         ]
    (list 'skills
    (case (current-poly-target)
      [(tex)
       (string-append
         (list-item type) ":" "\n"
         (tex-env 
           "short"
           (string-join (map list-item items) "\n")))]
      [(java)
       (java-string "1")
       (write-java-call "creator.addSkills" 
                        (java-string type) 
                        (java-string (string-join items ", ")))]
      [else 'file-type-error]))))


(define-tag-function (coursework attrs elements)
  (let* [(root (cons 'root elements))
         (courses (select* 'course root))]
    (list 'coursework
    (case (current-poly-target)
      [(tex)
       (tex-env
         "short"
         (string-join (map list-item courses) "\n"))]
      [(java)
       (string-join courses ", ")]
      [else 'file-type-error]))))

(define-tag-function (school attrs elements)
  (let* [(root (cons 'root elements))
         (name (select 'name root))
         (date (select 'graduation-date root))
         (degree (select 'degree root))
         (course-list (select 'coursework root))
         (empty-tex-arg "")]
    (list 'school
    (case (current-poly-target)
      [(tex)
       (string-append
         (tex-env
           "newplace"
           (string-append
             (tex-macro "placerow" name date)
             (tex-macro "jobrow" degree empty-tex-arg)))
         paragraph-break
         (tex-env
           "newplace"
           (tex-macro "placerow" "Coursework" empty-tex-arg))
         paragraph-break
         course-list)]
      [(java) 
       (let* [(arg-list 
                (map java-string 
                     (list name date degree course-list)))]
         (apply write-java-call (list* "creator.addSchool" arg-list)))]
      [else 'file-type-error]))))

(define (resume-section section-name attrs elements)
  (list section-name
  (case (current-poly-target)
    [(tex)
     (let [(section-name-string (string-titlecase (symbol->string section-name)))]
       (tex-env 
         "resumesection" 
         #:required (list section-name-string)
         (string-join (select* 'entry (cons 'root elements)) 
                      "\n\n"
                      #:before-first "\n"
                      #:after-last "\n")))]
    [(java)
     (let [(section-name-string (string-titlecase (symbol->string section-name)))]
       (string-append
         (write-java-call 
           "creator.addSection" 
           (java-string section-name-string))
         ";\n"
         (let [(entries (select* 'entry (cons 'root elements)))]
           (if entries
             (string-join entries "\n")
             ""))))]
    [else 'type-error])))

(define-tag-function (education-information attrs elements)
  (let* [(root (cons 'root elements))
         (school (findf-txexpr root (is-tag? 'school)))]
    (list 'education-information
    (case (current-poly-target)
      [(tex)
    (tex-env 
      "resumesection"
      #:required '("Education")
      (string-append
        paragraph-break
        (first (get-elements school))
        paragraph-break))]
      [(java) 
       (let* [(section-start 
                (first (get-elements (resume-section 'education attrs elements))))]
         (string-append section-start
                        "\n"
                        (first (get-elements school))))]
      [else 'file-type-error]))))

(define-tag-function (personal-information attrs elements)
  (let* [(root (cons 'root elements))
         (name (select 'name root))
         (email (select 'email root))
         (github (select 'github root))
         (phone-number (select 'phone-number root))
         (linkedin (select 'linkedin root))]
    (list 'personal-information
    (case (current-poly-target)
      [(tex)
       (tex-env 
         "center" 
         (string-append
           (tex-macro "name" name) "\n"
           (tex-scope
             (tex-macro "setlength" 
                          (tex-macro "tabcolsep") "0pt")
             (tex-env 
               "tabu"
               #:text-after-begin " to \\textwidth {XX[r]}"
               (string-append
                 email " &"
                 github " \\\\"
                 phone-number " &"
                 linkedin)))))]
      [(java)
       (apply write-java-call 
              (cons "creator.addPersonalInfo"
                    (map java-string (list email github phone-number linkedin))))]
      [else 'hi]))))

(define-tag-function (entry attrs elements)
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
         (not-whitespace?
           (lambda (str)
             (case str
               [("\n" "\r" "\t" " ") #f]
               [else #t])))
         (normalize-item 
           (lambda (item-elem)
             (let* [(strings (filter string? (get-elements item-elem)))
                    (normalized (filter not-whitespace? strings))
                    (content (string-join normalized " "))
                    (trimmed (string-trim content #px"\\s*\\.*"))]
               trimmed)))]
    (case (current-poly-target)
      [(tex)
       (let* [(placerow (tex-macro "placerow" place-name date))
              (default-value (lambda (val default) (or val default)))
              (place
                (tex-env 
                  "newplace"
                  (if (or role location)
                    (let [(role (default-value role ""))
                          (location (default-value location ""))]
                      (string-append
                        placerow "\n"
                        (tex-macro "jobrow" role location)))
                    placerow)))
              (item-func 
                (lambda (tag) 
                  (list-item (normalize-item tag))))
              (content-func
                (lambda (tag)
                  (let [(items 
                          (map item-func (findf*-txexpr tag (is-tag? 'item))))]
                    (tex-env
                      "bullets"
                      (string-join items "\n")))))
              (content 
                (let [(search-result (findf-txexpr root (is-tag? 'content)))]
                  (if (not search-result)
                    ""
                    (content-func search-result))))]
         (list 'entry
               (string-append
                 place paragraph-break
                 content)))]
    [(java)
     (let* [(default-value (lambda (default val) (or val default)))
            (item-func 
              (lambda (tag) 
                (java-string (normalize-item tag))))
            (entry-args
              (map java-string 
                   (if (or role location)
                     (map (curry default-value "") 
                          (list place-name date role location))
                     (list place-name date))))
            (content-func
              (lambda (tag)
                (let [(items 
                        (map item-func (findf*-txexpr tag (is-tag? 'item))))]
                  (java-array "String" items))))
            (content 
              (let [(search-result (findf-txexpr root (is-tag? 'content)))]
                (if (not search-result)
                  (java-array "String")
                  (content-func search-result))))]
       (list 'entry
             (apply write-java-call 
                    (append (list "creator.addEntry")
                            entry-args 
                            (list content)) 
                    )))]
    [else 'type-error])))



(define-tag-function (projects attrs elements)
  (resume-section 'projects attrs elements))


(define-tag-function (experience attrs elements)
  (resume-section 'experience attrs elements))

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
