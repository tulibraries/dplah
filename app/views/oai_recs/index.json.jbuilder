json.array!(@oai_recs) do |oai_rec|
  json.extract! oai_rec, :id, :title, :creator, :subject, :description, :publisher, :contributor, :date, :type, :format, :identifier, :source, :language, :relation, :coverage, :rights
  json.url oai_rec_url(oai_rec, format: :json)
end
