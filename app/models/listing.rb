class Listing < ActiveRecord::Base
    has_attached_file :image, styles: { medium: "200x>", thumb: "100x100>" }, default_url: "/images/:style/missing.png", 
        :storage => :dropbox,
        :dropbox_credentials => Rails.root.join("config/dropbox.yml")
        
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/


end