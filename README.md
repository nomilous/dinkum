`npm install dinkum`

### version 0.0.4 (unstable)

dinkum
======

API Tools


HTTP(S) Client
--------------

### Example

```coffee

# todo

```

### What is this thing?

An http(s) request client.

### Why another one?

Seamless integration with [notice](git@github.com:nomilous/notice.git)

* specifically the capacity for request throttling
    * to reign the bus in
    * can lead to a lot of inprocess capsules (but thats another story)

* and the api proxy
    * properties exposed to serialization on a dinkum instatnce are queryable over the notice api 
    * eg. `hubs/:uuid:/tools/dinkumInstance/stats`
    * (later) dinkum instance configurables (eg, queueLimit, requestLimit) can be manpulated over the notice api infrastructure

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
