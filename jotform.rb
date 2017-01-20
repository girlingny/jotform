#! /usr/bin/ruby

require "csv"
require "jotform-api"

API_KEY    = "d9ca424f51efe1f01ab27128cc1bd706"
CSV_FN     = ARGV[0]
FORM_TITLE = "Girling RN Confirmations"
#SUBS_TEMPL = { :title => { "PATIENT_NAME" => :patient, "VISIT_DATE" => :date }, :title => { "NURSE_NAME" => :nurse } }
SUBS_TEMPL = { "PATIENT_NAME" => :patient, "VISIT_DATE" => :date , "NURSE_NAME" => :nurse } }
FORM_KEYS = { :title => "title", :id => "id", :text = "text" }
FIELD_NAMES = { :nurse => "Name", :patient => "Patient Name", :date => "Date" }

jfapi = JotForm::JotForm.new(API_KEY)
forms = jfapi.getForms
forms.select! { |form| form[FORM_KEYS[:title]].start_with?(FORM_TITLE) }

SUB_MAPPINGS = { :title => ["NURSE_NAME"], :text => ["PATIENT_NAME", "VISIT_DATE"] }

BP_FORM = forms.find { |form| form[FORM_KEYS[:title]].end_with?("(DO NOT DELETE):") }
# FOLDER = jfapi.getFolders["subfolders"].find { |folder| folder["name"] == "Girling" }[:id]

def parse_name(text)
    split_text = text.split
    return (staff_name[1].strip + " " + staff_name[0].strip.delete(","))
end

data = CSV.read(CSV_FN, { headers: true })
visits = {}
data.each do |row|
    subs = {}
    subs[:nurse] = parse_name(row[FIELD_NAMES[:nurse]])
    form = forms.select { |form| form[FORM_KEYS[:title]].end_with?(subs[:nurse]) }
    if form.nil?
        form_title = "#{FORM_TITLE} #{subs[:nurse]}"
        properties = { FORM_KEYS[:title] => form_title }
        form = jfapi.cloneForm[BP_FORM[FORM_KEYS[:id]], properties]
    else
         jfapi.getFormQuestions(form[FORM_KEYS[:id]]).each { |question| 
                                                     jfapi.deleteFormQuestion(question[FORM_KEYS[:id]] }
    end
    questions = jfapi.getFormQuestions(BP_FORM[FORM_KEYS[:id]])
    BP_FORM.each do |property|
        properties = {}
        SUB_MAPPINGS.values.each do |field, vars|
            subst_string = BP_FORM[FORM_KEYS[field]]
            vars.each do |var|
                subst_string = substr_string.gsub("%" + var + "%", subs[SUBS_TEMPL[var]])
            end
            properties[FORM_KEYS[field]] = subst_string
        end
    end
end
