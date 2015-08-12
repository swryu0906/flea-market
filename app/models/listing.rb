class Listing < ActiveRecord::Base
	has_attached_file 	:image, 
						:styles => { :medium => "300x", :thumb => "100x100>" }, 
						:default_url => "no-image-available.png",
						:storage => :dropbox,
						:dropbox_credentials => Rails.root.join("config/dropbox.yml")
	validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }
end