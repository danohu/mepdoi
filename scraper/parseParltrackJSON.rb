# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'json'
require 'csv'

#Create the folders where the data and logs will be stored
INPUT_FILE = 'ep_meps_current.json'
INPUT_SUBDIR = 'tmp'
OUTPUT_SUBDIR = 'data'
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_SUBDIR)

#Headers for the output file
HEADERS = ["id","first_name","surname","gender","date_birth","country","groupId"]

#Create the log and output files
script_name = $0.gsub(/\.rb/,"")
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')
output_file = File.open("#{OUTPUT_SUBDIR}/#{script_name}.csv", 'w')

#Write the header to the output file
output_file.puts CSV::generate_line(HEADERS,:encoding => 'utf-8')

# Read JSON from a file, iterate over objects
file = open("#{INPUT_SUBDIR}/#{INPUT_FILE}")
json = file.read()
parsed = JSON.parse(json)
parsed.each_with_index do |mep, i|
  if !mep["active"]
    next
  end
  id = mep["UserID"]
  begin
    firstName = mep["Name"]["sur"]
    surname = mep["Name"]["family"]
    gender = mep["Gender"]
    date_birth = mep["Birth"]["date"] if mep.has_key?("Birth") 
    # Assuming that the first constituency is the most recent one
    country = mep["Constituencies"][0]["country"]
    groupId = mep["Groups"][0]["groupid"]
    data = [id,firstName,surname,gender,date_birth,country,groupId]
    output_file.puts CSV::generate_line(data,:encoding => 'utf-8')
  rescue NoMethodError
    log_file.puts("#{id}: Did not have an attibute")
  end
end
output_file.close
log_file.close
