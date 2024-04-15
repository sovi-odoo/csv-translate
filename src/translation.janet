(import json)
(import jurl)
(import uuid)

(var- *cached-url* nil)

(defn request
    ```
    Request a translation to Yandex's servers.
    lang: Source & destination languages in the format "src-dest". Eg: "uk-en".
    text: String to translate.
    ```
    [lang text]
    
    (when (nil? *cached-url*)
        (set *cached-url* (string
            "https://translate.yandex.net/api/v1/tr.json/translate"
            "?id=" (string/replace-all "-" "" (uuid/new)) "-0-0"
            "&srv=android"
        ))
    )

    (def headers {
        "User-Agent"
        "ru.yandex.translate/21.15.4.21402814 (Xiaomi Redmi K20 Pro; Android 11)"

        "Content-Type"
        "application/x-www-form-urlencoded"
    })

    (def result (jurl/request {
        :url *cached-url*
        :headers headers
        :method "POST"
        :body {
            :text text
            :lang lang
        }
    }))

    # e.g. result-body ok:  { "code" 200 "lang" "uk-en" "text" ["Capital construction"] }
    # e.g. result-body err: { "code" 501 "message" "The specified translation direction is not supported" }
    (def result-body (json/decode (result :body)))

    (if (= (result-body "code") 200)
        (get-in result-body ["text" 0])
        (error (string
            "[yandex error code " (result-body "code") "] "
            (result-body "message")
        ))
    )
)
