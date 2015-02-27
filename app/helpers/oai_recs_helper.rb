module OaiRecsHelper
	def render_asset(document)
      image_tag(document['thumbnail_tesim'].to_sentence, :alt => document['title_tesim'].to_sentence) if document['thumbnail_tesim']
	end
end
