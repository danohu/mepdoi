# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'mechanize'
require 'csv'

#Create the folders where the data and logs will be stored
INPUT_FILE = 'MEP_DIF.csv'
INPUT_SUBDIR = 'data'
OUTPUT_SUBDIR = 'data/pdf'
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_SUBDIR)

#To complete relative paths
HOME_URL = 'http://www.europarl.europa.eu'
PREFFIX ='/meps/en/directory.html?filter=all&leg='
#Headers for the output file
          
#Create the log and output files
script_name = $0.gsub(/\.rb/,"")
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')

#Instantiate the mechanize object
agent = Mechanize.new

count = 0
CSV.foreach("#{INPUT_SUBDIR}/#{INPUT_FILE}") do |row|
  id,url = row
  
  #Skip header
  if count == 0
    count += 1
    next
  end
  puts url
  #Get the page handling possible errors
  url =~ /\/ep-dif\/(.*)$/
  filename = $1 unless url.nil?
  unless File.exists?("#{OUTPUT_SUBDIR}/#{filename}")
    begin
      agent.get(url).save!("#{OUTPUT_SUBDIR}/#{filename}")
    rescue Mechanize::ResponseCodeError => the_error
      log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
    end
    sleep(1)
  end
end #csv read loop
log_file.close
