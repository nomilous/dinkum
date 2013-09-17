// Generated by CoffeeScript 1.6.3
var promised, transport;

promised = require('../support').promised;

transport = void 0;

exports.testable = function() {
  return transport;
};

exports.transport = function(config) {
  var api, options;
  if (config == null) {
    config = {};
  }
  config.transport || (config.transport = 'https');
  if (config.transport === 'https') {
    options = require('https').globalAgent.options;
    options.rejectUnauthorized = !config.allowUncertified;
  }
  transport = {
    request: promised(function(action, opts, result) {
      var request, requestOpts;
      if (opts == null) {
        opts = {};
      }
      requestOpts = {};
      if (config.port != null) {
        requestOpts.port = config.port;
      }
      requestOpts.hostname = config.hostname;
      requestOpts.method = opts.method;
      requestOpts.path = opts.path;
      request = require(config.transport).request(requestOpts);
      request.on('socket', function(socket) {
        if (config.connectTimeout !== 0) {
          socket.setTimeout(config.connectTimeout);
          return socket.on('timeout', function() {
            var error, msg;
            request.abort();
            msg = 'dinkum connect timeout';
            error = new Error(msg);
            error.detail = requestOpts;
            result.reject(error);
            return action.reject();
          });
        }
      });
      return request.on('error', function(error) {
        var msg;
        if (error.message === 'DEPTH_ZERO_SELF_SIGNED_CERT') {
          msg = 'dinkum encounter with uncertified server';
          msg += ' (use allowUncertified to trust it)';
          error = new Error(msg);
          error.detail = requestOpts;
          result.reject(error);
          action.reject();
        }
      });
    })
  };
  return api = {
    request: transport.request
  };
};