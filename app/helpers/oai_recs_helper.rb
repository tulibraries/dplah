module OaiRecsHelper
	def render_asset(document)
          link_ident = document['identifier_tesim'].find { |id| id.start_with?("http") }
          link_to(image_tag(document['thumbnail_tesim'].to_sentence, :alt => document['title_tesim'].to_sentence),link_ident) if document['thumbnail_tesim']
	end
end

