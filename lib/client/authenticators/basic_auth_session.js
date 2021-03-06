// Generated by CoffeeScript 1.6.3
module.exports = function(config, queue, cookies) {
  var basicAuth;
  return basicAuth = {
    type: 'session',
    originalRequest: void 0,
    failedAuth: function(action) {
      var error;
      error = new Error('dinkum authentication failure (session)');
      try {
        error.detail = basicAuth.originalRequest.opts;
      } catch (_error) {}
      basicAuth.originalRequest.promised.reject(error);
      basicAuth.originalRequest = void 0;
      return action.reject();
    },
    startSessionAuth: function(action, forbiddenRequest) {
      var authRequest, password, username;
      if (forbiddenRequest.authenticator != null) {
        basicAuth.failedAuth(action);
        return;
      }
      basicAuth.originalRequest = forbiddenRequest;
      authRequest = forbiddenRequest;
      authRequest.authenticator = 'basic_auth_session';
      username = config.authenticator.username;
      password = config.authenticator.password;
      authRequest.opts.auth = "" + username + ":" + password;
      return action.resolve(authRequest);
    },
    endSessionAuth: function(action, authRequest, authResponse) {
      return action.resolve();
    }
  };
};
