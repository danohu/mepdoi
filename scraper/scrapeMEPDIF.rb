# encoding: utf-8
#Libraries needed for the program
require 'fileutils'
require 'mechanize'
require 'csv'

#Create the folders where the data and logs will be stored
INPUT_FILE = 'scrapeMEPList.csv'
INPUT_SUBDIR = 'data'
OUTPUT_SUBDIR = 'data'
LOG_SUBDIR = 'logs'
FileUtils.makedirs(LOG_SUBDIR)
FileUtils.makedirs(OUTPUT_SUBDIR)

#To complete relative paths
HOME_URL = 'http://www.europarl.europa.eu'
#Headers for the output file
HEADERS = ["id","url"]
          
#Create the log and output files
script_name = $0.gsub(/\.rb/,"")
log_file = File.open("#{LOG_SUBDIR}/#{script_name}.log", 'w')
output_file = File.open("#{OUTPUT_SUBDIR}/#{script_name}.csv", 'w')
#Write the header to the output file
output_file.puts CSV::generate_line(HEADERS,:encoding => 'utf-8')

#Instantiate the mechanize object
agent = Mechanize.new

count = 0
CSV.foreach("#{INPUT_SUBDIR}/#{INPUT_FILE}") do |row|
  term,id,name,url = row
  
  #Skip header
  if count == 0 || term != 7
    count += 1
    next
  end
  puts url
  #Get the page handling possible errors
  begin
    page = agent.get(url)
  rescue Mechanize::ResponseCodeError => the_error
    log_file.puts("#{url}: Got a bad status code #{the_error.response_code}")
    return
  end
    
  #Get the nokogiri parsed document
  doc = page.parser
  
  #Get the rows with athletes
  pdfs = doc.css("a.link_pdf")
  #Check if there are any results
  if (pdfs.length==0)
    log_file.puts("#{url}: Did not find any DIF for this MEP.")
    next
  end
  pdfs.each do |pdf|
    data = []
    href = pdf["href"]
    if href =~ /\/ep-dif\//
      puts "href: #{href}"
      data = [id,href]
      output_file.puts CSV::generate_line(data,:encoding => 'utf-8')
    end
  end #more loop
  sleep(1)
end #term loop

output_file.close
log_file.close
