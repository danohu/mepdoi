# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'mechanize'
require 'csv'

#Create the folders where the data and logs will be stored
OUTPUT_SUBDIR = 'data'
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_SUBDIR)

#To complete relative paths
HOME_URL = 'http://www.europarl.europa.eu'
PREFFIX ='/meps/en/directory.html?filter=all&leg='
#Headers for the output file
HEADERS = ["legislative_term","id","name","url"]
          
#Create the log and output files
script_name = $0.gsub(/\.rb/,"")
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')
output_file = File.open("#{OUTPUT_SUBDIR}/#{script_name}.csv", 'w')
#Write the header to the output file
output_file.puts CSV::generate_line(HEADERS,:encoding => 'utf-8')

#Instantiate the mechanize object
agent = Mechanize.new

for term in 1..7 do
  url = "#{HOME_URL}#{PREFFIX}#{term}"
  #Get the page handling possible errors
  begin
    page = agent.get(url)
  rescue Mechanize::ResponseCodeError => the_error
    log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
  end
    
  #Get the nokogiri parsed document
  doc = page.parser
  #Get the rows with athletes
  links = doc.css("div.zone_info_mep li.mep_name a")
  #Check if there are any results
  if (links.length==0)
    log_file.puts("#{url}: Did not parse any data items inside.")
    next
  end
  links.each do |link|
    data = []
    name = link.text.strip
    href = link['href']
    href =~ /^\/meps\/en\/(\d+)\//
    if $1.nil?
      log_file.puts("#{href}: Did not find the MEP id.")
      next
    end
    id = $1
    data = [term,id,name,"#{HOME_URL}#{href}"]
    output_file.puts CSV::generate_line(data,:encoding => 'utf-8')
  end #links loop
  sleep(1)
end #term loop

output_file.close
log_file.close