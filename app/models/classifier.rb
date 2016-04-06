class Classifier < StuffClassifier::Bayes 

	require 'csv'

	attr_accessor :cls

	def initialize(name, opt={})
		super(name, opt)
	end	

	def train_data
		strings = tags = []
		i = 0
		# tmp = []

		# CSV.foreach(Rails.root.join('tmp/dataset.csv')) do |row|
		# 	tmp << { 
		# 		row[1].split(", ") => row[0][0..(row[0].length*0.8).to_i]
		# 	}
		# 	Rails.logger.info " !!!!!!!!!!!!!!!!!!!!!!!!!! ROW number =>>>>>>>>>>>>>>>>>>>#{i}"
		# 	i = i + 1
		# end

		# tmp[0..500].each do |row|

		# end


		# raise
		arr_arrs = CSV.read(Rails.root.join('tmp/dataset.csv'))


		arr_arrs.each do |row|
			tags = row[1].split(", ")
			tags.each do |st|
				train(st, row[0][0..(row[0].length*0.8).to_i])
			end
			Rails.logger.info " !!!!!!!!!!!!!!!!!!!!!!!!!! ROW number =>>>>>>>>>>>>>>>>>>>#{i}"
			i = i + 1			
		end

		save_state
		# raise
	end

end