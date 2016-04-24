class TengriParserController < ApplicationController

	require 'open-uri'
	require 'csv'
	
	URL = "https://tengrinews.kz/"

	ALPHABET = ("а".."я").to_a + ("a".."z").to_a

	def parse_site_tengri

		res = []
		ALPHABET.each do |ch|
			res << parse_with_thread_tengri(ch)
		end

		CSV.open("tmp/dataset_tengrinews.csv", "wb") do |csv|
			res.each do |tag|
				tag.each do |page|
					page.each do |post|
						csv << post
					end
				end
			end
		  
		end

		Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!       ENDED           !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		raise
	end

  def handler_tengri(source)

  	url = URL + source + "/"
    begin
      page = Nokogiri::HTML(open(url, 'User-Agent' => 'chrome'))
    rescue
      Rails.logger.info "!!!!+++++++++++++++++++++++++     Parsing failed     +++++++++++++++++++++++++++++++!!!!!"
      return [[nil, nil]]
    end


  	pagination_count =  page.css(".pager a").count
  	
  	post_list = []

  	i = 0
  	(1..pagination_count).each do |posts|
  		tmp_url = URL + source + "/?page=#{posts}"

  		Rails.logger.info "!!!!!!!!!!!!!!!!!~~~~~~~~~~    Page #{posts}      ~~~~~~~~~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			a = rand(5)
        begin
    		  posts_page = Nokogiri::HTML(open(tmp_url, 'User-Agent' => 'chrome'))
          
          posts_page.css('.search-result-name a').each do |post_link|
          a = rand(5)
          link = post_link.attr("href")
          i = i + 1
          Rails.logger.info "!!!!!!!!!!!!!!!!!! POST NUMBER ============>>>>>>>>>>>> #{i}"
          post_list << post_page(link)
          sleep(a)
        end
  		end
  			sleep(a)
  			i = 0
  	end
  	post_list

  end



  def post_page(source)
  	url = URL + source + "/"
  	url = URI.encode(url)

    begin
  	 post = Nokogiri::HTML(open(url,'User-Agent' => 'chrome')) 
    rescue 
      Rails.logger.info "!!!!+++++++++++++++++++++++++     Parsing failed     +++++++++++++++++++++++++++++++!!!!!"
      return [nil, nil]
    end

    Rails.logger.info "!!==========================================> Parsing: #{url} =======================================!!"
    content = post.css(".sharedText").text
    content = normalize_content(content)

    tags = post.css(".tag-list").text
    tags = normalize_content(tags)

    tmp = Post.where(url: url, text: content, tag: tags).first
    if tmp
    else
      Post.create(url: url, text: content, tag: tags)
    end

    [content, tags]
  end

	def parse_with_thread_tengri(ch)

		url = URL + "tags/" + ch+"/"
    posts = []

    begin
      page = Nokogiri::HTML(open(URI.encode(url), 'User-Agent' => 'chrome'))
       
      link_tags = page.css(".tags-block .tags li")
      

      links = []

      link_tags.each do |lt|
        tmp = lt.css("a").attr("href").text
        text = lt.css("a").text
        links << {
          url: URI.encode(tmp),
          text: text
        } 
      end


      links.each do |pages|
        Rails.logger.info "!!!!!!!!!!!!!!         TAG =>>>>>>> #{pages[:text]}              !!!!!!!!!!!!!!!!!!!!!!!!!!!"
        posts << handler_tengri(pages[:url])
      end
    end

    posts   
	end

	def normalize_content(text)
		text.gsub(/\r|\n|\n|\r|\\|\"/, " ").strip
	end


end