https    = require 'https'
server   = undefined

module.exports = HttpsServer =

    server: 

        #
        # access to most recent received requests
        # 

        latest: -> HttpsServer.server.requests[0]
        requests: []


    start: (opts, callback) -> 

        opts.keep ||= 10

        server = https.createServer

            #
            # to create a key
            # ---------------
            # 
            # openssl genrsa -out develop-key.pem 1024
            # cat develop-key.pem 
            #

            key:  """
            -----BEGIN RSA PRIVATE KEY-----
            MIICXQIBAAKBgQDdBg13FoLZ7LEkcyDCx8/pOrL4Wa3HZ86eX/UxS4l/OYanzXsG
            tsBVImqyVztGh88Wcfw+e1UfKd2EgPXby03X153uHn+O+wO5cYlK5nhicpfkreXW
            Gg0scMrWcStH9T0NI2p75TYk1hziJZ/8burida0k4tkovP0nWyczJqcxbwIDAQAB
            AoGAXV/cOm5pM3XaVILK2V8ex/KDf4Yrc224jZIOfRfja7s61xNpISn90TmsB9Hw
            ediQNXRMU305NeQy8HKm64dVR8xiDXLuVjVtn2f6gVwUTD8VYIkAC5rG+Py1ijIb
            wF9vv7zMr4tIQTiEH5vr1YrYP4mvcXXgPUtv+VZqrILk79kCQQD4nonQQPHY7N2Z
            okpGHshYaERTVUcu73RMTFROxtV4WspiRCcRvN/mZR1mGQ19WZQAj2ZJyM2fjuDG
            J8KZhkOzAkEA45XK1kufNzpKsy+65S6YRJx1N3hMw20N1IcsRJqWr13220HTkHMi
            Z2XPFcMvylHA8dtpK04JLZAcFTJNwwLtVQJBAMoUauYX87wjg1d+HyrxmFyrm2W0
            uiA/R+NAY4KIgTjLaxcGWE9FmyP06jlzgZBygCcYZ8bvbZsUkkTeSoFpLZsCQQCN
            Fs8B3S3eeifXQE7YR/OkDW7prY3BVblOOWKrQT8LhvBD62IyWf5JJaelMTVOczJv
            ffuMGju8YGvYhDALJqRlAkBGeOgEgcPjhjqb5oiG0DkLif4kq0xhYRUlycTNmzZ2
            TFW9SN7Px47wQ4eaQwroRSGH3YRjNUNaioSykExeigIz
            -----END RSA PRIVATE KEY-----
            """

            #
            # to create the 'self signed' key certification
            # ---------------------------------------------
            #
            # openssl req -new -key develop-key.pem -out develop-csr.pem
            # openssl x509 -req -in develop-csr.pem -signkey develop-key.pem -out develop-cert.pem
            # cat develop-cert.pem 
            # 

            cert: """
            -----BEGIN CERTIFICATE-----
            MIICATCCAWoCCQCehCafP4QyKDANBgkqhkiG9w0BAQUFADBFMQswCQYDVQQGEwJa
            QTETMBEGA1UECBMKU29tZS1TdGF0ZTEhMB8GA1UEChMYSW50ZXJuZXQgV2lkZ2l0
            cyBQdHkgTHRkMB4XDTEzMDkxNzE3NDAyMVoXDTEzMTAxNzE3NDAyMVowRTELMAkG
            A1UEBhMCWkExEzARBgNVBAgTClNvbWUtU3RhdGUxITAfBgNVBAoTGEludGVybmV0
            IFdpZGdpdHMgUHR5IEx0ZDCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEA3QYN
            dxaC2eyxJHMgwsfP6Tqy+Fmtx2fOnl/1MUuJfzmGp817BrbAVSJqslc7RofPFnH8
            PntVHyndhID128tN19ed7h5/jvsDuXGJSuZ4YnKX5K3l1hoNLHDK1nErR/U9DSNq
            e+U2JNYc4iWf/G7q4nWtJOLZKLz9J1snMyanMW8CAwEAATANBgkqhkiG9w0BAQUF
            AAOBgQBb1R4uqT9tiuj3B1kPV0RMabFoeAgtvCeQYJsoaF/dQFXO91Exzd9KiOpV
            SlPdM/umlUi4FS7ZkIcwvOTfnbPJrAj59Wv9yW9HLHYp7Kd5MYpjXuZDvT9AYG2w
            /TIitulO5s/trYfdaaYcDlX79Z59H/CEGBLNf1UxiFoNN2oWKA==
            -----END CERTIFICATE-----
            """

            (req, res) -> 

                HttpsServer.server.requests.unshift req
                while HttpsServer.server.requests.length > opts.keep
                    HttpsServer.server.requests.pop()

                res.writeHead 200, {}
                res.end ''



        server.listen opts.port, callback


    stop: (callback) -> server.close callback
