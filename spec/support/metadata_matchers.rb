module MetadataMatchers
  RSpec::Matchers.define :have_datastream_of_type do |name, datastreamClass|
    match do |target|
      target.datastreams.has_key?(name) &&
        target.datastreams[name].class == datastreamClass 
    end
  end

  RSpec::Matchers.define :have_metadata_stream_of_type do |metadataStreamClass|
    match do |target|
      not target.metadata_streams.select { |m| m.class == metadataStreamClass }.empty?
    end
  end
end
