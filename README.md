`npm install dinkum`

### version 0.0.4 (unstable)

dinkum
======

### What is this dinkum?

* A [noticeable](https://github.com/nomilous/notice/tree/master/src/tools) http(s) request client.
* With 'an attempt' at baking authentication right in.
* "authentication isn't a field i've hefted any significant accumulation efforts at."
* This modulename !withstanding.

### Why another one?

* What? 
* There are others? 
* Who requested that? ... ;)
* Seriously tho:

It's for seamless integration with [notice](https://github.com/nomilous/notice-example)

Todo
----

* fix content-length
* get stats through to the instanceroot
* include recent N request details in stats
* queueSoftLimit (exposes warnings) / hardLimit (starts rejecting)
* the example above
* documentation in general
* behaviours according to content type
* logging (perhaps unnecessary, stats over notice api will likely suffice)
* authenticator plugin api (or inline config function)
* cookie persistence
* queue persistance
