json.array!(@providers) do |provider|
  json.extract! provider, :id, :name, :description, :endpoint_url, :metadata_prefix, :set
  json.url provider_url(provider, format: :json)
end
