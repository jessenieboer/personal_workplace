#lang racket

(define (greet name)
  (string-append "hello, " name))

(define (main)
  (displayln (greet "jesse")))

(module+ main
  (main))

(module+ test
  (require rackunit)
  (check-equal? (greet "jesse") "hello, jesse")
  (check-equal? (greet "") "hello, "))
