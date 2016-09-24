(module centaur
    (router

     respond
     respond-sxml
     respond-json

     request-body

     port
     host
     serve)

  (import chicken scheme)
  (use spiffy
       uri-common
       intarweb

       sxml-transforms
       json
       ports

       extras
       srfi-1
       srfi-13)

  (reexport spiffy)

  ;;; Helpers
  ;; Remove the prefix from a list
  (define (remove-prefix l pre
                         #!optional
                         (eq equal?))
    (if (and (pair? l)
             (pair? pre))
        (if (eq (car l)
                (car pre))
            (remove-prefix (cdr l)
                           (cdr pre)
                           eq)

            ;; pre is not a prefix of l
            #f)
        l))

  ;;; Routing
  (define ((router matchers) continue)
    ;; Get the URI and strip out unnecessary bits
    (let* ((req (current-request))
           (uri (filter-map
                 (lambda (part)
                   (and (not (or (eqv? part '/)
                                 (equal? part "")))
                        (string-downcase part)))
                 (uri-path (request-uri req))))
           (method (request-method req)))
      (call/cc
       (lambda (matched)
         ;; Loop through and run each matcher
         (for-each
          (lambda (matcher)
            (let* ((reversed-matcher (reverse matcher))
                   ;; The unprefixed URI
                   (unprefixed-uri
                    (remove-prefix uri
                                   (reverse (cdr reversed-matcher)))))
              (when unprefixed-uri
                ;; Store the return value
                (let ((rv ((car reversed-matcher)
                           (cons method unprefixed-uri))))
                  ;; If we've responded, break out of the loop
                  (when (response? rv)
                    (matched rv))))))
          matchers)

         ;; We've not exited yet, so it's not been matched
         (continue)))))

  ;;; Responding
  ;; Tiny wrapper
  (define (respond body #!optional status)
    (send-response status: status
                   body: body))

  ;; Render and respond with SXML
  (define (respond-sxml sxml)
    (respond
     (with-output-to-string
      (lambda _
        (SRV:send-reply
         (pre-post-order sxml universal-conversion-rules))))))

  ;; Generate and respond with JSON
  (define (respond-json json)
    (respond
     (with-output-to-string
      (lambda _
        (json-write json)))))

  ;;; Convenience
  ;; Getting the request body
  (define (request-body req)
    (let ((content-length (header-value 'content-length
                                        (request-headers req))))
      (cond
        ((not content-length) (error "content-length not set"))
        ((zero? content-length) "")
        (else (read-string content-length (request-port req))))))

  ;; Setting up and starting the server
  (define port server-port)
  (define host (make-parameter ".*"))

  (define (serve matchers)
    (vhost-map (list (cons (host) (router matchers))))
    (start-server)))

