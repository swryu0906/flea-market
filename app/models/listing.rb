class Listing < ActiveRecord::Base
	if Rails.env.development?
		has_attached_file 	:image, 
							:styles => { :medium => "300x", :thumb => "100x100>" }, 
							:default_url => "no-image-available.png"
	else
		has_attached_file 	:image, 
							:styles => { :medium => "300x", :thumb => "100x100>" }, 
							:default_url => "no-image-available.png",
							:storage => :dropbox,
							:dropbox_credentials => Rails.root.join("config/dropbox.yml"),
							:path => ":style/:id_:filename"
	end
	validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }
end