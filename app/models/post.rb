class Post 
  include Mongoid::Document
  include Mongoid::Timestamps	
	
	field :text, type: String
	field :tag,		type: String
	field :url, 	type: String

end