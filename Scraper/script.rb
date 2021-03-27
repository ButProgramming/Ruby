require 'nokogiri'
require 'open-uri'
require 'httparty'
require 'byebug'
require 'watir'

def scraper(link_arr)
  for link in link_arr
    browser = Watir::Browser.new
    browser.goto link
    loop do
      #sleep 3
      browser.scroll.to :bottom
      while browser.a(:text=>"Загружаю товары...").exists? do sleep 0.1 end
      browser_page = browser.html
      parsed_page = Nokogiri::HTML(browser_page)
      p = parsed_page.css('div.price')
      puts p.count
      browser.scroll.to :center    
      break unless browser.a(:class=>"next_page_link").exists?
      browser.a(:class=>"next_page_link").click
      #byebug
    end
  end
end

def scraper_xml
  browser = Watir::Browser.new
  browser.goto 'https://e-dostavka.by/sitemap.xml'
  xml_sitemap_unparsed_page = browser.html
  xml_sitemap_parsed_page = Nokogiri::HTML(xml_sitemap_unparsed_page)
  index = 0;
  base_adress = '//e-dostavka.by/catalog/'
  link_arr = Array.new
  loop do
   a = xml_sitemap_parsed_page.css('loc')[index].children.text
   if a[0..23]==base_adress and a.length>base_adress.length #avoid //e-dostavka.by/catalog/
    link_arr.push(a)
   end
   break if a==xml_sitemap_parsed_page.css('loc').last.children.text
   index=index+1
  end
  puts link_arr
  return link_arr
  #byebug
end


scraper(scraper_xml)







  
