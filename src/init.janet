(import ./translation)
(import ./csv)

(import spork/argparse)

(defn edit-csv-data
    ```
    Change the data in place.
    data: Array of arrays of strings.
    header-edit: Function to edit header array with.
    data-edit: Function to edit each data array with.
    ```
    [data header-edit data-edit] (label edit-csv-data

    (when (zero? (length data))
        (return edit-csv-data)
    )

    (header-edit (data 0))

    (for i 1 (length data)
        (data-edit (data i))
    )
))

(defn die [& message]
    (eprint (string "Error: " (apply string message)))
    (os/exit 1)
)

(defn main
    [& args]

    (def cli (argparse/argparse
        ```
        Translate each field in a CSV's column.
        This tool uses Yandex for translations: DO NOT TRANSLATE SENSITIVE DATA WITH IT.

         Examples:
         csv-translate input.csv -O output.csv -i name -o name@fr -l en-fr
         csv-translate file.csv -O file.csv -i name -o name@fr -l en-fr
         cat input.csv | csv-translate -i name -o name@fr -l en-fr | tee output.csv
        ```

        :default {
            :help "Input file ('-' for stdin)."
            :kind :option
            :default "-"
        }

        "input-column" {
            :help "Column to translate."
            :short "i"
            :kind :option
            :required true
        }

        "output-column" {
            :help "Column to put the translation in (auto-created if doesn't exist)."
            :short "o"
            :kind :option
            :required true
        }

        "output" {
            :help "Output file ('-' for stdout)."
            :short "O"
            :kind :option
            :default "-"
        }

        "language" {
            :help `Translation language in a "src-dest" format (e.g. "uk-en").`
            :short "l"
            :kind :option
            :required true
        }

        "delay" {
            :help "Delay in seconds between each request to Yandex's server."
            :short "d"
            :kind :option
            :default "2"
        }
    ))

    (when (nil? cli) (os/exit 0))

    (def input-path (cli :default))
    (def language (cli "language"))
    (def input-column (cli "input-column"))
    (def output-column (cli "output-column"))
    (def output-path (cli "output"))
    (def delay-string (cli "delay"))

    (def use-stdout? (= "-" output-path))
    (def delay-secs (scan-number delay-string))
    (when (nil? delay-secs) (die "Invalid Yandex delay"))

    (def data-string (if (= "-" input-path) (file/read stdin :all) (slurp input-path)))
    (def data (csv/parse data-string))
    (var assign-output-fn nil)
    (var get-input-fn nil)
    (edit-csv-data data
        (fn [line] # header
            (def header-to-index @{})

            (for i 0 (length line)
                (set (header-to-index (line i)) i)
            )

            (def input-index (get header-to-index input-column))
            (def output-index (get header-to-index output-column))

            (set get-input-fn (if input-index
                (fn [line] (line input-index))
                (die `Input column "` input-column `" not found.`)
            ))

            (set assign-output-fn (if output-index
                (fn [line output] (set (line output-index) output))
                (do
                    (array/push line output-column)
                    (fn [line output] (array/push line output))
                )
            ))

            (when use-stdout?
                (print (csv/to-string [line])) (flush)
            )
        )
        (fn [line] # data
            (def text (get-input-fn line))
            (def { :text translated :delay-secs delay-secs }
                (if (empty? text)
                    { :text "" :delay-secs nil }
                    { :text (translation/request language text) :delay-secs delay-secs }
                )
            )
            
            (assign-output-fn line translated)

            (when use-stdout?
                (print (csv/to-string [line])) (flush)
            )
                    
            (when delay-secs (os/sleep delay-secs))
        )
    )

    (when (not use-stdout?)
        (with [f (file/open output-path :w)]
            (file/write f (csv/to-string data))
            (file/write f "\n")
        )
    )
)
