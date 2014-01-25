# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'csv'

#Create the folders where the data and logs will be stored
INPUT_FILE = 'MEP_DIF.csv'
INPUT_SUBDIR = 'data'
OUTPUT_SUBDIR = 'data'
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_SUBDIR)
#Headers for the output file
HEADERS = ["id","first_name","surname","gender","date_birth","country","groupId","decl_date","decl_url"]

#Create the log and output files
script_name = $0.gsub(/\.rb/,"")
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')
output_file = File.open("#{OUTPUT_SUBDIR}/#{script_name}.csv", 'w')
#Write the header to the output file
output_file.puts CSV::generate_line(HEADERS,:encoding => 'utf-8')

MEPS = {}

CSV.foreach("#{INPUT_SUBDIR}/parseParltrackJSON.csv", :headers => true, :header_converters => :symbol) do |row|
  MEPS[row.fields[0]] = Hash[row.headers[1..-1].zip(row.fields[1..-1])]
end


CSV.foreach("#{INPUT_SUBDIR}/#{INPUT_FILE}") do |row|
  id,url = row
  mep = MEPS["#{id}"]
  if mep.nil?
    log_file.puts("#{id}: Did not find this MEP on the active parltrack repository")
    next
  end
  url =~ /(\d{2})-(\d{2})-(\d{4})/
  decl_date = "#{$3}-#{$2}-#{$1}" unless $1.nil?
  birth_date = mep[:date_birth][0..9] unless mep[:date_birth].nil?
  data = [id,mep[:first_name],mep[:surname],mep[:gender],birth_date,mep[:country],mep[:groupid],decl_date,url]
  output_file.puts CSV::generate_line(data,:encoding => 'utf-8')
end
output_file.close
log_file.close
