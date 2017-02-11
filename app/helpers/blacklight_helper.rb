module BlacklightHelper
	 include Blacklight::BlacklightHelperBehavior
	 def render_default_thumbnail_link(document, options = {})
		 track_url = "#{url_for(url_for_document(document))}/track?counter=#{options[:counter]}&search_id=#{current_search_session.try(:id)}"
		 default_thumb = document['title_tesim'].present? ? link_to(image_tag("default-thumbnail.png", :alt => document['title_tesim'].to_sentence), url_for_document(document), :'data-context-href' => track_url) : nil
		 return default_thumb
	 end
end
