# Taken from: https://github.com/zenlor/janet-csv/blob/master/csv.janet

# Copyright (c) 2022 Lorenzo Giuliani
#
# Licensed under the ISC license: https://opensource.org/licenses/ISC
# Permission is granted to use, copy, modify, and redistribute the work.
# Full license information available in the project LICENSE file.

(def csv-lang
  (peg/compile
   '{:comma ","
     :space " "
     :space? (any :space)
     :comma? (at-most 1 :comma)
     :cr "\r"
     :lf "\n"
     :nl (+ (* :cr :lf)
            :cr :lf)
     :dquote "\""
     :dquote? (? "\"")
     :d_dquote (* :dquote :dquote)
     :textdata (+ (<- (some (if-not (+ :dquote :comma :nl) 1)))
                  (* :dquote
                     (<- (any (+ (if :d_dquote 2)
                                 (if-not :dquote 1))))
                     :dquote))
     :empty_field 0
     :field (accumulate (+ (* :space? :textdata :space?)
                           :empty_field))
     :row (* :field
             (any (* :comma :field))
             (+ :nl 0))
     :main (some (group :row))}))

(defn- unescape-field [field]
  (string/replace-all "\"\"" "\"" field))

(defn- unescape-row [row]
  (map unescape-field row))

(defn- parse-and-clean [data]
  (->> data
       (peg/match csv-lang)
       (map unescape-row)))

(defn- headerize [ary]
  (let [header (map keyword (first ary))
        data   (array/slice ary 1)]
    (map (fn [row] (zipcoll header row))
         data)))

(defn parse [input &opt header]
  (let [data (parse-and-clean input)]
    (if header
      (headerize data)
      data)))

(defn- field-to-csv # edited
  [field]
  "escape strings for csv"
  (->> (string/replace-all "\"" "\"\"" field)
       (string/format "\"%s\"")))

(defn- is-list?
  [data]
  (or (array? data)
      (struct? data)))

(defn- row-to-csv
  [row]
  (let [data (if (not (is-list? row))
               (values row)
               row)]
    (map field-to-csv
         data)))

(defn- to-array-of-array
  [data]
  (let [ary @[]]
    (when (not (is-list? (first data)))
      (array/push ary (-> (first data)
                          keys)))
    (each row data
      (array/push ary (row-to-csv row)))
    ary))

(defn to-string # edited
  [data]
  (string/join (map (fn [row] (string/join row ","))
                   (to-array-of-array data))
               "\n"))
