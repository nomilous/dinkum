// Generated by CoffeeScript 1.6.3
var https, server;

https = require('https');

server = void 0;

module.exports = {
  start: function(port, callback) {
    server = https.createServer({
      key: "-----BEGIN RSA PRIVATE KEY-----\nMIICXQIBAAKBgQDdBg13FoLZ7LEkcyDCx8/pOrL4Wa3HZ86eX/UxS4l/OYanzXsG\ntsBVImqyVztGh88Wcfw+e1UfKd2EgPXby03X153uHn+O+wO5cYlK5nhicpfkreXW\nGg0scMrWcStH9T0NI2p75TYk1hziJZ/8burida0k4tkovP0nWyczJqcxbwIDAQAB\nAoGAXV/cOm5pM3XaVILK2V8ex/KDf4Yrc224jZIOfRfja7s61xNpISn90TmsB9Hw\nediQNXRMU305NeQy8HKm64dVR8xiDXLuVjVtn2f6gVwUTD8VYIkAC5rG+Py1ijIb\nwF9vv7zMr4tIQTiEH5vr1YrYP4mvcXXgPUtv+VZqrILk79kCQQD4nonQQPHY7N2Z\nokpGHshYaERTVUcu73RMTFROxtV4WspiRCcRvN/mZR1mGQ19WZQAj2ZJyM2fjuDG\nJ8KZhkOzAkEA45XK1kufNzpKsy+65S6YRJx1N3hMw20N1IcsRJqWr13220HTkHMi\nZ2XPFcMvylHA8dtpK04JLZAcFTJNwwLtVQJBAMoUauYX87wjg1d+HyrxmFyrm2W0\nuiA/R+NAY4KIgTjLaxcGWE9FmyP06jlzgZBygCcYZ8bvbZsUkkTeSoFpLZsCQQCN\nFs8B3S3eeifXQE7YR/OkDW7prY3BVblOOWKrQT8LhvBD62IyWf5JJaelMTVOczJv\nffuMGju8YGvYhDALJqRlAkBGeOgEgcPjhjqb5oiG0DkLif4kq0xhYRUlycTNmzZ2\nTFW9SN7Px47wQ4eaQwroRSGH3YRjNUNaioSykExeigIz\n-----END RSA PRIVATE KEY-----",
      cert: "-----BEGIN CERTIFICATE-----\nMIICATCCAWoCCQCehCafP4QyKDANBgkqhkiG9w0BAQUFADBFMQswCQYDVQQGEwJa\nQTETMBEGA1UECBMKU29tZS1TdGF0ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0\ncyBQdHkgTHRkMB4XDTEzMDkxNzE3NDAyMVoXDTEzMTAxNzE3NDAyMVowRTELMAkG\nA1UEBhMCWkExEzARBgNVBAgTClNvbWUtU3RhdGUxITAfBgNVBAoTGEludGVybmV0\nIFdpZGdpdHMgUHR5IEx0ZDCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA3QYN\ndxaC2eyxJHMgwsfP6Tqy+Fmtx2fOnl/1MUuJfzmGp817BrbAVSJqslc7RofPFnH8\nPntVHyndhID128tN19ed7h5/jvsDuXGJSuZ4YnKX5K3l1hoNLHDK1nErR/U9DSNq\ne+U2JNYc4iWf/G7q4nWtJOLZKLz9J1snMyanMW8CAwEAATANBgkqhkiG9w0BAQUF\nAAOBgQBb1R4uqT9tiuj3B1kPV0RMabFoeAgtvCeQYJsoaF/dQFXO91Exzd9KiOpV\nSlPdM/umlUi4FS7ZkIcwvOTfnbPJrAj59Wv9yW9HLHYp7Kd5MYpjXuZDvT9AYG2w\n/TIitulO5s/trYfdaaYcDlX79Z59H/CEGBLNf1UxiFoNN2oWKA==\n-----END CERTIFICATE-----"
    }, function(req, res) {
      console.log('\nrequest:');
      console.log({
        headers: req.headers
      });
      console.log({
        method: req.method
      });
      console.log({
        url: req.url
      });
      res.writeHead(200, {});
      return res.end('');
    });
    return server.listen(port, callback);
  },
  stop: function(callback) {
    return server.close(callback);
  }
};