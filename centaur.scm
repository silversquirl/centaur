(module centaur
    (router
     serve)

  (import chicken scheme)
  (use spiffy
       uri-common
       intarweb

       srfi-1)

  (reexport spiffy)

  (define (remove-prefix l pre
                         #!optional
                         (eq equal?))
    (if (and (pair? l)
             (pair? pre)
             (eq (car l)
                 (car pre)))
        (remove-prefix (cdr l)
                       (cdr pre)
                       eq)
        l))

  (define ((router matchers) continue)
    (let ((uri (filter
                (lambda (part)
                  (not (or (eqv? part '/)
                           (equal? part ""))))
                (uri-path (request-uri (current-request))))))
      (call/cc
       (lambda (matched)
         (for-each
          (lambda (matcher)
            (let* ((reversed-matcher (reverse matcher))
                   ;; Store the return value
                   (rv ((car reversed-matcher)
                        (remove-prefix uri (cdr reversed-matcher)))))
              (when (response? rv)
                (matched rv))))
          matchers)

         ;; We've not exited yet, so it's not been matched
         (continue)))))

  (define (serve matchers
                 #!optional
                 (port 8080)
                 (host ".*"))

    (vhost-map (list (cons host (router matchers))))
    (server-port port)
    (start-server)))
