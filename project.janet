(declare-project
    :name "csv-translate"
    :description ```Translate data in CSV ```
    :version "0.0.0"
)

(declare-source :source ["src"])

(declare-executable
    :name "csv-translate"
    :lflags ["-lcurl"]
    :entry "src/init.janet"
    :dependencies [
        "https://github.com/brandonchartier/janet-uuid"
        "spork"
        "json"
        "jurl"
    ]
)
