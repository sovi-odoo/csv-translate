# csv-translate

```
usage: csv-translate [option] ...

Translate each field in a CSV's column.
This tool uses Yandex for translations: DO NOT TRANSLATE SENSITIVE DATA WITH IT.

 Examples:
 csv-translate input.csv -O output.csv -i name -o name@fr -l en-fr
 csv-translate file.csv -O file.csv -i name -o name@fr -l en-fr
 cat input.csv | csv-translate -i name -o name@fr -l en-fr | tee output.csv

 Required:
 -i, --input-column VALUE                    Column to translate.
 -l, --language VALUE                        Translation language in a "src-dest" format (e.g. "uk-en").
 -o, --output-column VALUE                   Column to put the translation in (auto-created if doesn't exist).

 Optional:
 -d, --delay VALUE=2                         Delay in seconds between each request to Yandex's server.
 -h, --help                                  Show this help message.
 -O, --output VALUE=-                        Output file ('-' for stdout).
```

To avoid flooding Yandex's servers, a delay of 2 seconds per field translated has been put in place by default.
These delays can add up really quickly so make sure to go grab a cup of hot chocolate while this tool is running :)

## Install (pre-built)

If you're on a x86_64 Linux + glibc system, you can simply download the prebuilt binary
[here](https://github.com/sovi-odoo/csv-translate/releases/latest/download/csv-translate-linux-x64-glibc.xz)

Dependencies (Ubuntu):

```sh
sudo apt install libcurl4
```

## Install (from source)

Install Janet ([instructions](https://janet-lang.org/docs/index.html)) and then JPM ([instructions](https://janet-lang.org/docs/jpm.html))

Then run:

```sh
sudo apt install libcurl4-openssl-dev
git clone https://github.com/sovi-odoo/csv-translate
cd csv-translate
jpm -l deps
jpm -l build
```

The executable will be in `build/csv-translate`
