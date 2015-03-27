module OaiRecsHelper
	def render_asset(document)
		link_ident = asset_link(document)
		asset_linked = link_to(image_tag(document['thumbnail_tesim'].to_sentence, :alt => document['title_tesim'].to_sentence),link_ident, :target => "_blank", :title => "opens in a new tab") if document['thumbnail_tesim']
		return asset_linked
	end
	def asset_link(document)
		link_ident = "#"
		link_ident = document['identifier_tesim'].find { |id| id.start_with?("http") } if document['identifier_tesim']
		return link_ident
	end
end


