class AclassifierController < ApplicationController

	require 'ankusa'
	require 'ankusa/file_system_storage'
	require 'csv'

	def classifier
		
		path = Rails.root.join('tmp/result_ankusa')
		storage = Ankusa::FileSystemStorage.new path
		# c = Ankusa::KLDivergenceClassifier.new storage
		c = Ankusa::NaiveBayesClassifier.new storage


		strings = tags = []
		i = 0
		arr_arrs = CSV.read(Rails.root.join('tmp/dataset.csv'))
		arr_arrs.each do |row|
			tags = row[1].split(", ")
			tags.each do |st|
				c.train(st, row[0])
			end
			Rails.logger.info " !!!!!!!!!!!!!!!!!!!!!!!!!! ROW number =>>>>>>>>>>>>>>>>>>>#{i}"
			i = i + 1			
		end

		storage.save

		


		arr_arrs = CSV.read(Rails.root.join('tmp/dataset_rest.csv'))

		# [1..arr_arrs.count-1]

		# arr_arrs[0..5].each_with_index do |row, index|
		# 	raise
		# 	Rails.logger.info "!!!!!!!!!! INDEX #{index}"
		# end

		res = []
		arr_arrs.each_with_index do |row, index|
			Rails.logger.info "~!~!~!~!!!!!!!!!!!!!!!!~~~~~~~~~~~~~ STARTING TO CLASSIFY ~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!!!~!~!~!~!~!~!"
			text = row[0]
			res << c.classify(text)
			# puts c.log_likelihoods text
			Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! RES contains #{res.count} !!!!!!!!! LAST TAG #{res.last}"
		end
		# CSV.foreach(Rails.root.join('tmp/dataset_rest.csv')) do |row|
		# 	Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! RES contains #{res.count} !!!!!!!!! LAST TAG #{res.last}"
		# 	res << cls.classify(row[0][0..(row[0].length*0.8).to_i])
		# raise
		# end

		Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  CLASSIFICATION FINISHED !!!!!!!!!!!!!!!!!!!!!"

		res1 = []
		Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  ANALIZING !!!!!!!!!!!!!!!!!!!!!"

		arr_arrs.each do |row|
			tags = row[1].split(", ")
			res.each do |r|
				res1 << analyze(r.to_s, tags)
			end
		end
		Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  FINISHED !!!!!!!!!!!!!!!!!!!!!"

		percentage(res1)
		raise
	




	end

	def analyze(res, tags)
		tags.include?(res)
	end

	def percentage(arr)
		[(arr.count(true).to_f/arr.count)*100 ,(arr.count(false).to_f/arr.count)*100]
	end

	



end