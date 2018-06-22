#lang racket
(require pollen/core)
(require pollen/tag)
(require txexpr)
(provide (all-defined-out))
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
(define (latex-macro cmd-name . args)
  (let* [(macro-start (string-append "\\" cmd-name))
         (bracked-args 
           (if (null? args)
             ""
             (string-join args
                          "}{"
                          #:before-first "{"
                          #:after-last "}")))]
    (string-append macro-start bracked-args)))
(define (latex-env name contents)
  (string-append
    (latex-macro "begin" name) "\n"
    contents "\n"
    (latex-macro "end" name)))
(define (latex-scope . contents)
  (apply string-append `("{" ,@contents "}")))
(define (list-item str)
  (string-append (latex-macro "item") " " str))
(define (pollen-style-test . args)
  (string-append
    (format "Number of args is ~a.\n" (length args))
    (string-join (map (lambda (arg) (string? arg)) args) "\n")))

; tags

(define-tag-function (skills attrs elements)
;(define (skills attrs elements)
  (let* [(attrs (attrs->hash attrs))
         (type (hash-ref attrs 'type))]
    (list 'skills
    (string-append
      (list-item type) ":" "\n"
      (latex-env 
        "short"
        (string-join (map list-item (select* 'item (cons 'root elements)))
                     "\n"))))))


(define-tag-function (education-information attrs elements)
;(define (education-information attrs elements)
  (let* [(root (cons 'root elements))
         (is-tag? 
           (lambda (tag)
             (lambda (elem)
               (and (txexpr? elem) (eq? tag (get-tag elem))))))

         (school (findf-txexpr root (is-tag? 'school)))
         (name (findf-txexpr root (is-tag? 'name)))
         (date (findf-txexpr root (is-tag? 'graduation-date)))
         (degree (findf-txexpr root (is-tag? 'degree)))
         (courses (findf*-txexpr root (is-tag? 'course)))]
    (displayln name)
    (displayln date)
    (list 'education-information
    (latex-env 
      "resumesection"
      (string-append
        (format "{~a}" "Education") "\n\n"
        (latex-env 
          "newplace"
          (string-append
            (latex-macro "placerow" 
                         (car (get-elements name))
                         (car (get-elements date)))
            (latex-macro "jobrow"
                         (car (get-elements degree))
                         "")))
        "\n\n"

        (latex-env 
          "newplace"
          (latex-macro "placerow" "Coursework" ""))

        "\n\n"

        (latex-env
          "short"
          (string-join (map (compose1 list-item car get-elements) courses)
                       "\n")))))))

