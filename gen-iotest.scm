


;;;  gen-iotest -- generate a parser test script
;;;
;;;  Copyright (C) 2010 Michael L. Gran
;;;  License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
;;;  This is free software: you are free to change and redistribute it.
;;;  There is NO WARRANTY, to the extent permitted by law.



	 
	




;;; MODULES




(require srfi/1)


;;; FUNCTIONS



(define (run-test)
  (make-chapter "Identifiers")
  (make-test (identifier))
  
  (make-chapter "Booleans")
  (make-test (boolean))
  
  (make-chapter "Base 2 Numbers")
  (make-test (inexact-num 2))
  (make-test (exact-num 2))
  
  (make-chapter "Base 8 Numbers")
  (make-test (inexact-num 8))
  (make-test (exact-num 8))
  
  (make-chapter "Base 10 Numbers")
  (make-test (inexact-num 10))
  (make-test (exact-num 10))
  
  (make-chapter "Base 16 Numbers")
  (make-test (inexact-num 16))
  (make-test (exact-num 16))
  
  (make-chapter "Characters")
  (make-test (character))

  (make-chapter "R5RS Strings")
  (make-test (t-string)))

(define *n* 1)

;; Output a list that contains the integers from START to END inclusive
(define (range start end)
  (let loop ((i start)
	     (lst '()))
    (if (<= i end)
	(loop (+ i 1) (append lst (list i)))
	lst)))


;;; The procedure takes one or more lists as parameters, and then
;;; returns a list that contains its ordered perumations.
;;;
;;; For example (list-product '(a b) '(c d e))
;;; produces '((a c) (a d) (a e) (b c) (b d) (b e))
(define list-product
  (lambda x
    (cond 
     ((= 1 (length x))
      x)
     ((= 2 (length x))
      (let* ((val1 (car x))
             (len1 (length val1))
             (val2 (cadr x))
             (len2 (length val2)))
        (map (lambda (c)
               (let ((part1 (list-ref val1 (quotient c len2)))
                     (part2 (list-ref val2 (remainder c len2))))
                 (cond
                  ((and (list? part1) (list? part2))
                   (append part1 part2))
                  ((list? part1)
                   (append part1 (list part2)))
                  ((list? part2)
                   (append (list part1) part2))
                  (else
                   (list part1 part2)))))
             (range 0 (- (* len1 len2) 1)))))
     (else
      (let ((y (apply list-product (cdr x))))
        (list-product (car x) y))))))

;; Given a list of strings, append the strings together.  If one of
;; the strings is actually the value #f, return #f instead.
(define try-string-append
  (lambda list-of-strings
    (if (every (lambda (x) x) list-of-strings)
        (apply string-append list-of-strings)
        #f)))

;; This outputs the code for each test in the TST list.  If a value in
;; the TST list is false, that test is skipped, but, the test ID is
;; still incremented
(define (make-test tst)
  (let ((tests (map (lambda (x) 
                      (if (list? x)
                          (apply try-string-append x)
                          x))
                    tst)))
    (map (lambda (t)
           (when t
                 (display "(test ")
                 (display *n*)
                 (display " ")
                 (write t)
                 (display ")")
                 (newline))
           (set! *n* (+ *n* 1)))
         tests)))

;; This outputs the code for each chapter heading
(define (make-chapter c)
  (display "(newline)")
  (newline)
  (display "(display \"Chapter: ")
  (display c)
  (display "\")")
  (newline)
  (display "(newline)")
  (newline))




(display "
(define (test n name)
  (let* ((n-string (number->string n))
         (i (open-input-string name))
         (val (with-handlers ([exn:fail:read? (lambda (exn) #f)]) 
                             (read i)))
         (d-string (open-output-string))
         (w-string (open-output-string)))
    (display val d-string)
    (write val w-string)
    (display (make-string (- 6 (string-length n-string)) #\\space))
    (display n)
    (display \": \")
    (display name)
    (display (make-string (max 1 (- 16 (string-length name))) #\\space))
    (display \" : \")
    (display (get-output-string w-string))
    (display \" : \")
    (display (get-output-string d-string))
    (newline)))
")


;;-----------------------------------------------------
;; RnRS Identifier

(define (identifier)
  (append
   (list-product '("'") (initial))
   (list-product '("'") (initial) (subsequent))
   (list-product '("'") (peculiar-identifier))
   
   (list #f)
   (list-product '(#f) (subsequent))
   
   ))

(define (initial)
  (append
   (constituent)
   (special-initial)

))

(define (constituent)
  (append
   (letter)

   '(#f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f)

))

(define (letter)
  '("a" "z" "A" "Z"))



(define (special-initial)
  '("!" "$" "%" "&" "*" "/" ":" "<" "=" ">" "?" "^" "_" "~"))

(define (subsequent)
  (append
   (initial)
   (digit 10)
   (special-subsequent)
   
   '(#f #f #f)
   
   ))

(define (digit)
  '("0" "9"))

(define (special-subsequent)
  '("+" "-" "." "@"))

(define (peculiar-identifier)
  '("+" "-" "..."))

;;-----------------------------------------------------
;; Booleans

(define (boolean)
  '("#t" "#f" "#T" "#F" "'#t" "'#f" "'#T" "'#F"))

;;-----------------------------------------------------
;; R5RS Numbers

(define (decimal)
  (append
   (list-product (uinteger 10) (suffix))
   (list-product '(".") (digit 10) '("" "#") (suffix))
   (list-product (digit 10) '(".") (digit 10) '("" "#") (suffix))
   (list-product (digit 10) '("#") '(".") '("#") (suffix))))

(define (uinteger R)
  (list-product '("0" "1") '("" "#")))

(define (suffix)
  (append
   '("")
   (list-product (exponent-marker) (sign) (digit 10))))

(define (exponent-marker)
  '("e" "s" "f" "d" "l"))

(define (sign)
  '("" "+" "-"))

(define (digit R)
  '("0" "1"))

(define (inexact-num R)
  (list-product (inexact-prefix R) (inexact-complex R)))

(define (exact-num R)
  (list-product (exact-prefix R) (exact-complex R)))

(define (inexact-prefix R)
  (append
   (list-product (radix R) (inexactness))
   (list-product (inexactness) (radix R))))

(define (exact-prefix R)
  (append
   (list-product (radix R) (exactness))
   (list-product (exactness) (radix R))))

(define (radix R)
  (cond
   ((= R 2)
    '("#b" "#B"))
   ((= R 8)
    '("#o" "#O"))
   ((= R 10)
    '("" "#d" "#D"))
   ((= R 16)
    '("#x" "#X"))))

(define (inexactness)
  '("" "#i" "#I" 
    ;;"#e" 
    ;;"#E"
    ))

(define (exactness)
  '("#e" "#E" ))

(define (inexact-complex R)
  (append
   (real R)
   (list-product (real R) '("@") (real R))
   (list-product (real R) '("+" "-") (ureal R) '("i"))
   (list-product (real R) '("+" "-") (naninf) '("i"))
   (list-product (real R) '("+" "-") '("i"))
   (list-product '("+" "-") (ureal R) '("i"))
   '("+i" "-i")))

(define (exact-complex R)
  (append
   (exact-real R)
   ;;(list-product (exact-real R) '("+" "-") (exact-ureal R) '("i"))
   ;;(list-product (exact-real R) '("+" "-") '("i"))
   ;;(list-product '("+" "-") (exact-ureal R) '("i"))
   ;;'("+i" "-i")
   ))

(define (real R)
  (append
   (list-product (sign) (ureal R))
   (list-product '("+" "-") (naninf))))

(define (exact-real R)
  (append
   (list-product (sign) (exact-ureal R))))

(define (naninf)
  '("nan.0" "inf.0"))

(define (sign)
  '("" "+" "-"))

(define (ureal R)
  (cond
   ((= R 2)
    '("0" "1" "0/10" "1/10"))
   ((= R 8)
    '("0" "7" "0/10" "7/10"))
   ((= R 10)
    (append
     '("0" "9" "0/10" "9/10" "0.0" "0.9")
     ;;(decimal)
     ))
   ((= R 16)
    '("0" "f" "F" "0/10" "f/1e" "F/1E"))))

(define (exact-ureal R)
  (cond
   ((= R 2)
    '("0" "1"))
   ((= R 8)
    '("0" "7"))
   ((= R 10)
    '("0" "9"))
   ((= R 16)
    '("0" "f" "F"))))


;;-----------------------------------------------------
;; R5RS Characters

(define (character)
  (append
   (list-product '("#\\") (any-character))
   
   (list-product '("#\\x") (hex-scalar-value))
   
   (list-product '("#\\") (r5rs-character-name))
   
   (list-product '("#\\") (r6rs-character-name))
   
   ))

(define (any-character)
  (append
   (map (lambda (n) (string (integer->char n ))) (range 1 127))
   
   '(#f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f #f)
   
   ))

(define (r5rs-character-name)
  '("space" "newline" "SPACE" "NEWLINE"))

(define (hex-scalar-value)
  (map (lambda (n) (number->string n 16)) (range 1 127)))

(define (r6rs-character-name)
  '("nul" 
    "alarm"
    "backspace" "tab" "linefeed" "newline" "vtab"
    "page" "return" "esc" "space" "delete"))


;;-----------------------------------------------------
;; R5RS String

(define (t-string)
  (append
   '("\"\"")
   (list-product '("\"") (t-string-element) '("\""))))

(define (t-string-element)
  (map (lambda (n)
         (let ((c (integer->char n)))
           (cond
            ((eq? c #\")
             (string #\\ #\"))
            ((eq? c #\\)
             (string #\\ #\\))
            (else
             (string c)))))
       (range 1 127)))

(run-test)