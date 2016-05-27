require 'csv'

class CsvController < CatalogController

  configure_blacklight do |config|
    config.default_solr_params[:rows] = 1000000
  end

  def index
    (@response, @document_list) = get_search_results
    send_data render_search_results_as_csv, filename: "#{csv_file_name}.csv"

  end

  def csv_file_name
    "#{params.fetch(:q,"no-query")}#{params.fetch(:f,{}).keys.join("-")}"
  end

  def render_search_results_as_csv
    show_fields = blacklight_config.show_fields.map {|solr_name, show_field| {:solr_name => solr_name, :label => show_field.label } }

    csv_result = CSV.generate(headers: true) do |csv|
      csv << show_fields.map { |field| field[:label] }

      @document_list.each do |doc|
        csv << show_fields.map { |field| doc.fetch(field[:solr_name], nil).to_a.join(" ; ") }
      end
    end
  end
end