module ApplicationHelper
    def site_name
        "Shomigo Demo"
    end

    def site_url
        if Rails.env.production?
            "https://shomigodemo.herokuapp.com"
        else 
            "http://localhost:3000/"
        end 
    end

    def meta_author
        "Audrey Li"
    end

    def meta_description
        "Beautiful simple shopping website"
    end

    def meta_keywords
        "Shopping, Arts, Design"
    end 

    #Return the full page tile on per-page basis. 
    #No need to change this. We set page_title and stie_name elsewhere
    def full_title(page_title)
        if page_title.empty?
            site_name
        else 
            "#{page_title} | #{site_name}"
        end 
        
    end

end
