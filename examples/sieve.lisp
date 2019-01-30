(progn
  (defun range (start end)
    (if (lt start end)
      (cons start (range (plus start 1) end))
      (cons start nil)))

  (defun makelist (size val)
    (local (quote result) ())
    (for (quote x) (range 1 size)
      (quote (set (quote result) (cons val result))))
    (return result))

  (defun for (var vals body)
    (local var (car vals))
    (eval body)
    (if (not (empty (cdr vals))) (for var (cdr vals) body)))

  (defun reverse (v result)
    (if (not (empty (cdr v)))
      (reverse (cdr v) (cons (car v) result))
      (return (cons (car v) result))))

  (set (quote size) 100)
  (set (quote sieve) (makelist (plus size 1) 0))
  (setnth sieve 0 1)
  (setnth sieve 1 1)

  (for (quote d) (range 2 (div size 2))
    (quote (for (quote x) (range 2 (div size d))
      (quote (setnth sieve (times x d) 1)))))

  (set (quote result) ())
  (for (quote i) (range 0 size)
    (quote
      (progn
        (if (equal (car sieve) 0)
          (set (quote result) (cons i result)))
        (set (quote sieve) (cdr sieve)))))

  (print "Primes less than ")
  (print size)
  (print " : ")
  (println (reverse result ()))
)
