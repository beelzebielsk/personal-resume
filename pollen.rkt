#lang racket
(require pollen/core)
(require txexpr)
(provide select-path)
(provide select-path*)
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
