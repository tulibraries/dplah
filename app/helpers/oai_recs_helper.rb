module OaiRecsHelper
	def render_asset(document)
      link_to(image_tag(document['thumbnail_tesim'].to_sentence, :alt => document['title_tesim'].to_sentence),document['identifier_tesim'].first) if document['thumbnail_tesim']
	end
end
