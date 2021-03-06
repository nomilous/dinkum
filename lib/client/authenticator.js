// Generated by CoffeeScript 1.6.3
var HttpRequest, deferred, testable;

deferred = require('also').deferred;

HttpRequest = require('./http_request');

testable = void 0;

exports._authenticator = function() {
  return testable;
};

exports.Authenticator = function(config, queue, cookies) {
  var api, authenticator;
  config || (config = {});
  authenticator = {
    queue: queue,
    cookies: cookies,
    authenticating: 0,
    scheme: void 0,
    type: void 0,
    assign: function() {
      var modulePath;
      if (config.authenticator.module == null) {
        return false;
      }
      if (authenticator.scheme != null) {
        return true;
      }
      try {
        modulePath = "./authenticators/" + config.authenticator.module;
        authenticator.scheme = require(modulePath)(config, queue, cookies);
      } catch (_error) {}
      try {
        authenticator.type = authenticator.scheme.type;
      } catch (_error) {}
      return authenticator.scheme != null;
    },
    configured: function() {
      return (config.authenticator != null) && authenticator.assign();
    },
    requestAuth: function(httpRequest) {
      var error;
      try {
        authenticator.scheme.requestAuth(httpRequest);
        return true;
      } catch (_error) {
        error = _error;
        try {
          error.detail = {
            request: httpRequest.opts
          };
        } catch (_error) {}
        httpRequest.promised.reject(error);
        return false;
      }
    },
    startSessionAuth: deferred(function(action, httpRequest) {
      var error, notify, reject, resolve;
      resolve = action.resolve, reject = action.reject, notify = action.notify;
      if (!authenticator.configured()) {
        error = new Error('dinkum absence of authenticator scheme');
        error.detail = {
          request: httpRequest.opts
        };
        httpRequest.promised.reject(error);
        action.reject();
        return;
      }
      if (authenticator.authenticating === 0) {
        queue.suspend = true;
        authenticator.authenticating = httpRequest.sequence;
        return authenticator.scheme.startSessionAuth(action, httpRequest);
      } else {
        if (httpRequest.authenticator != null) {
          authenticator.authenticating = 0;
          authenticator.scheme.startSessionAuth(action, httpRequest);
          return;
        }
        return queue.requeue(httpRequest).then(resolve, reject, notify);
      }
    }),
    endSessionAuth: deferred(function(action, httpRequest, httpResponse) {
      try {
        return authenticator.scheme.endSessionAuth(action, httpRequest, httpResponse);
      } catch (_error) {}
    })
  };
  if (config.authenticator != null) {
    authenticator.assign();
  }
  testable = authenticator;
  return api = {
    startSessionAuth: authenticator.startSessionAuth,
    endSessionAuth: authenticator.endSessionAuth,
    requestAuth: authenticator.requestAuth,
    type: authenticator.type
  };
};
