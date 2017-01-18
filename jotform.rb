#! /usr/bin/ruby

require "csv"
require "jotform-api"

module JotForm 
    class JotForm
        def _executePutRequest(endpoint, payload)
            return _excuteHTTPRequest(endpoint, payload, "PUT")
        end
        def createForm(content)
        end
    end
end

API_KEY    = "d9ca424f51efe1f01ab27128cc1bd706"
CSV_FN     = ARGV[0]
FORM_TITLE = "Girling RN Confirmations"

data = CSV.read(CSV_FN, { headers: true })
visits = { }
data.each do |row|
    staff_name = row["Name"].split
    staff_name = staff_name[1].strip + " " + staff_name[0].strip.delete(",")
    if visits[staff_name].nil? then visits[staff_name] = [ ] end
    visits[staff_name].push({ :patient => row["Patient Name"], :date => row["Date"] })
end

jfapi = JotForm::JotForm.new(API_KEY)
forms = jfapi.getForms
forms.select! { |form| form["title"].start_with?(FORM_TITLE) }
BP_FORM = forms.find { |form| form["title"].end_with?("(DO NOT DELETE):") }["id"]
FOLDER = jfapi.getFolders["subfolders"].find { |folder| folder["name"] == "Girling" }["id"]

visits.each do |visit|
    form = forms.find { |f| f["title"].end_with?visit[0] }
    if form.nil?
        properties = { "title" => FORM_TITLE + " " + visit[0] }
        new_form = jfapi.cloneForm(BP_FORM, properties)
    end
end
