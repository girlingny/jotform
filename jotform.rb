#! /usr/bin/ruby

require "jotform-api"

API_KEY    = "d9ca424f51efe1f01ab27128cc1bd706"
CSV_FN     = ARGV[0]
FORM_TITLE = "Girling RN Confirmations"

def parse_csv(csv)
    CUSTOMER = 4
    indexes = get_indexes(csv)
    cases = csv.map.wit_index {
        |row, i| { i => row } }.select { |row| row.dig(1,0).strip == "Assigned" }
end

def get_indexes(csv)
    # Find the rows that have personnel information, and then partition into
    # RN and PT, keeping track of index numbers as we go.
    #
    # for row in rows, row[0] is the index from the CSV, row[1] is the row from
    # the CSV (csv_row). Each csv_row has various data at csv_row[0], including
    # personnel info
    rows = csv.map!.with_index { |row, i| { i => row } }
    personnel = rows.select { |row| row.dig(1, 0).strip!.starts_with?("Personnel") }
    rn = personnel.select { |person| person.dig(1, 0).ends_with?("RN") ||
                            person.dig(1, 0).ends_with?("RN/EX") }
    rn.collect! { |person| person[0] }
    pt = personnel.select { |person| person.dig(1, 0).ends_with?("PT") ||
                            person.dig(1, 0).ends_with?("PT/EX") }
    { :rn => rn.collect { |person| person[0] }.sort,
      :pt => pt.collect { |person| person[0] }.sort }
end

jfapi = JotForm::JotForm.new(API_KEY)

forms = jfapi.getForms

forms.select! { |form| form["title"].start_with?(FORM_TITLE) }
csv = CSV.read(CSV_FN)
