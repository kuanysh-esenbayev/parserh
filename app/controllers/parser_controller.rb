class ParserController < ApplicationController

	# Nokogiri::HTML(open("https://habrahabr.ru/post/280486/",'User-Agent' => 'chrome'))
	require 'open-uri'
	require 'csv'
	
	URL = "https://habrahabr.ru/"


	def parse_site
		
		res =  parse_with_thread


		CSV.open("tmp/dataset.csv", "wb") do |csv|
			res.each do |pag|
				pag.each do |site|
					csv << site
				end
			end
		  
		end

		Rails.logger.info " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!       ENDED           !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		raise
	end

  def handler(source)

    page = Nokogiri::HTML(open(source.to_s, 'User-Agent' => 'chrome'))

    container = page.css('.post.shortcuts_item')

    Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!===================> OPEN => #{source}"
 		
    sources = []
    statuses = []

    (0..container.count-1).each do |i|
    	tmp = container[i].css('h1.title a')
    	if tmp.count > 0
      	sources << tmp.attr("href").text
      	statuses << false
    	end
    end

    res = []
    
    (0..sources.count-1).each do |i| 
    	res <<  pages(sources[i])
    	a = rand(7)
    	sleep(a)
    	statuses[i] = true
   	end
   	
	   while !statuses.all?
      puts "........"
      sleep(3)
    end

   	res
  end

  def pages(source)
    page = Nokogiri::HTML(open(source.to_s,'User-Agent' => 'chrome'))

    Rails.logger.info "!!==========================================> Parsing: #{source} =======================================!!"

    title = page.css('.post_title').text
    content = page.css('.content.html_format').text
    content = normalize_content(content)
    tags = page.css('.tags.icon_tag li').text

    res = [content, tags, title]

  end

	def parse_with_thread
    page = Nokogiri::HTML(open(URL, 'User-Agent' => 'chrome'))
    
    a = page.css('#nav-pages li a')
    pagination = a.last.attr('href')[/\d+/]


    sources = []
    statuses = []
    (1..pagination.to_i).each do |i| 
      sources << "#{URL}page#{i}/"
      statuses << false
    end

    res = []

    sources.each_with_index do |link, index|
      # Thread.new(link, index, statuses) do |link, index, statuses|
        a = rand(7)
        res << handler(link)
        sleep(a)
        statuses[index] = true
      # end
    end

    while !statuses.all?
      puts "........"
      sleep(3)
    end

    puts 'ended'
    res
	end

	def normalize_content(text)
		text.gsub(/\r|\n|\n|\r/, " ").strip
	end

end