class FileSetIndexer < Hyrax::FileSetIndexer
  def generate_solr_document

    super.tap do |solr_doc|
      solr_doc['hasFormat_ssim'] = object.rendering_ids
      solr_doc['year_published_isi'] = object.date_published[0...4].to_i if object.date_published.present?
    end

  rescue Ldp::HttpError => exception
     puts "exception is: #{exception.inspect}"
     puts "calling to_solr on fileset failed #{object.inspect}"

     #manually call generate_solr_document on the indexing_service. It returns
     # the same values as calling to_solr on a file_set object
     get_solr_attributes = ActiveFedora::IndexingService.new(object).generate_solr_document
     puts "get_solr_attributes #{get_solr_attributes.inspect}"
     get_solr_attributes
  end

end
