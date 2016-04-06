class ClassifierController < ApplicationController


	require 'csv'

	def classifier
		store = StuffClassifier::FileStorage.new(Rails.root.join('tmp/result2'))
		cls = Classifier.new("Post classification 2", language: "ru", :storage => store)
		# cls = StuffClassifier::Bayes.new("Post classification", language: "ru")
		# cls = train(cls)
		# raise
		# cls.train_data
		# Rails.logger.info "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TRAIN FINISHED !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		test(cls)
	end

	def test(cls)
		
		string, tag = ""
		res = []
		arr_arrs = CSV.read(Rails.root.join('tmp/dataset_rest.csv'))

		# [1..arr_arrs.count-1]

		# arr_arrs[0..5].each_with_index do |row, index|
		# 	raise
		# 	Rails.logger.info "!!!!!!!!!! INDEX #{index}"
		# end

		arr_arrs.each_with_index do |row, index|
			Rails.logger.info "~!~!~!~!!!!!!!!!!!!!!!!~~~~~~~~~~~~~ STARTING TO CLASSIFY ~~~~~~~~~~~~~~~~~~!!!!!!!!!!!!!!!!~!~!~!~!~!~!"
			text = row[0][0..500] + ". " + row[0][row[0].length-500..row[0].length]
			res << cls.classify(text)
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
				res1 << analyze(r, tags)
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

	def train(cls)
		# string, tag = ""
		# CSV.foreach(Rails.root.join('tmp/dataset.csv')) do |row|
		# 	tags = row[1].split(", ")
		# 	tags.each do |st|
		# 		cls.train(st, row[0][0..(row[0].length*0.8).to_i])
		# 	end
		# end
	end
	

end