# Centaur

A stupid-simple web framework for CHICKEN Scheme.

## What is Centaur?

Centaur is similar-ish to [Sinatra], a minimal web framework for Ruby.
Centaur, however, is _even more_ minimal than Sinatra, and that is
saying something. Centaur is currently just a wrapper around [spiffy],
a "small web-server written in Chicken."

Despite (and partly because of) being just a wrapper, Centaur gets out
of your way and lets you get on with what you actually want to do: build
a website.

It's best to demonstrate with some example code, so here you go:

```scheme
(use centaur matchable)

(serve
 `((/
    ,(match-lambda
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
```

Running this program will start an HTTP server on port 8080 that will
respond with an HTML page containing a heading with the words "Hello,
world!" on / and "Hello, _URL path here_" for /_whatever_.

## But isn't it better to use Ruby or Python or web development?

The only reason Ruby and Python are used for web development is because
they are interpreted languages. Interpreted languages provide benefits
during development, since compiled languages must be... well... compiled
before you can test your program.

The issue with using interpreted languages, however, is that they are
usually slower in _production_ which, let's face it, is what you're
actually developing for. For this reason, compiled languages such as Go
have been becoming popular for web development.

CHICKEN gives you the best of both worlds, as it has both an interpreter
and a compiler, allowing you to quickly test your code in the
interpreter, and then compile your code when you put it into production.


[Sinatra]: https://github.com/sinatra/sinatra
[spiffy]: http://wiki.call-cc.org/egg/spiffy
