class Listing < ActiveRecord::Base
	has_attached_file :image, :styles => { :medium => "300x", :thumb => "100x100>" }, :default_url => "no-image-available.png"
	validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }
end