module BlacklightHelper
	 include Blacklight::BlacklightHelperBehavior
	 def render_default_thumbnail_link(document, options = {})
		 url = url_for_document(document)
		 track_url = "#{polymorphic_url(url_for_document(document))}/track?counter=#{options[:counter]}"
		 default_thumb = link_to(image_tag("default-thumbnail.png", :alt => document['title_tesim'].to_sentence), url_for_document(document), :'data-context-href' => track_url)
		 return default_thumb
	 end
end
