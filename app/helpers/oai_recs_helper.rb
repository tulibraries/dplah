module OaiRecsHelper
	def render_asset(document)
		link_ident = asset_link(document)
		asset_linked = document['thumbnail_tesim'] ? link_to(image_tag(document['thumbnail_tesim'].to_sentence, :alt => document['title_tesim'].to_sentence),link_ident, :target => "_blank", :title => "opens in a new tab") : link_to(image_tag("default-thumbnail.png", :alt => "Default thumbnail - no thumbnail image available"),link_ident, :target => "_blank", :title => "opens in a new tab")
		return asset_linked
	end
	def asset_link(document)
		link_ident = "#"
		link_ident = document['identifier_tesim'] ? document['identifier_tesim'].find { |id| id.start_with?("http") } : "#"
		return link_ident
	end
end
