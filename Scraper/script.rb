require 'nokogiri'
require 'httparty'
require 'byebug'
require 'watir'
require 'csv'

def scraper(link_arr)

  #initialize
  productArray = Array.new
  puts "Scraping of e-dostavka.by is started."
  browser = Watir::Browser.new

  #start checking link_arr
  for link in link_arr
    browser.goto link
    loop do
      puts "Scraping https:#{link}."

      #loading of dynamic page
      while browser.a(:text=>"Загружаю товары...").exists? do 
        browser.scroll.to :bottom
        browser.scroll.to :center
      end

      #scraping of dynamical page
      browser_page = browser.html
      parsed_page = Nokogiri::HTML(browser_page)
      puts parsed_page.css('div.form_wrapper').count
      
      #scraping of all products in the page
      index = 0
      loop do
        parced_price = parsed_page.css('div.price')[index].children.text.split('к')[0].delete(' ').gsub('р.', ',')
        parced_name = parsed_page.css('div.form_wrapper')[index].css('div.title').children.text
        parced_link = parsed_page.css('div.form_wrapper')[index].css('a.fancy_ajax').attribute('href').value
        parced_country = parsed_page.css('div.form_wrapper')[index].css('div.small_country').children.text.delete(" ")
        product = {
          price:   parced_price,
          name:    parced_name,
          link:    parced_link,
          country: parced_country
        }
        productArray << product

        #write in csv
        File.open("e-dostavka.csv", "a") do |csv|
          write = product[:price].to_s + ';' + product[:name] + ';' + product[:country] + ';' + product[:link]
          csv << write
          csv.puts
        end

        puts parced_name
        break if parsed_page.css('div.form_wrapper')[index] == parsed_page.css('div.form_wrapper').last
        index+=1
      end

      #check if the next page from next_page_link excists
      browser.scroll.to :center    
      break unless browser.a(:class=>"next_page_link").exists?
      browser.a(:class=>"next_page_link").click
      link = browser.url[6..browser.url.length] #get link from next_page_link

    end
  end
end

def scraper_xml

  #initialize
  puts "Getting likns from e-dostavka.by..."
  browser = Watir::Browser.new
  browser.goto 'https://e-dostavka.by/sitemap.xml'
  xml_sitemap_unparsed_page = browser.html
  xml_sitemap_parsed_page = Nokogiri::HTML(xml_sitemap_unparsed_page)
  index = 0;
  base_adress = '//e-dostavka.by/catalog/'
  link_arr = Array.new

  #getting links
  loop do
   a = xml_sitemap_parsed_page.css('loc')[index].children.text
   if a[0..23]==base_adress and a.length>base_adress.length #avoid //e-dostavka.by/catalog/
    link_arr.push(a)
   end
   break if a==xml_sitemap_parsed_page.css('loc').last.children.text
   index=index+1
  end
  browser.quit
  puts "Process is finished. Browser will be restarted."
  return link_arr

end

BEGIN{
  puts "Scraping script is started"
}

#start the program
scraper(scraper_xml) 

END{
  puts "Scraping script is over"
}
