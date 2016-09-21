(use centaur matchable)

(print "Starting...")
(serve
 `((,(match-lambda
       (()
        (send-response status: 'ok
                       body: "<h1>Hello, world!</h1>"))

       ((name)
        (send-response status: 'ok
                       body: (string-append
                              "<h1>Hello, "
                              name
                              "!</h1>")))
       (else #f)))))

