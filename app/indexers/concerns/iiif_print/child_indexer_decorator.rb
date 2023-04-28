IiifPrint::ChildIndexer.module_eval do
  def self.decorate_work_types!
    Hyrax.config.curation_concerns.each do |work_type|
      work_type.send(:include, IiifPrint::SetChildFlag) unless work_type.included_modules.include?(IiifPrint::SetChildFlag)
      indexer = work_type.indexer
      unless indexer.respond_to?(:iiif_print_lineage_service)
        indexer.prepend(self)
        indexer.class_attribute(:iiif_print_lineage_service, default: IiifPrint::LineageService)
      end
      if work_type.const_defined?(:GeneratedResourceSchema)
        work_type::GeneratedResourceSchema.send(:include, IiifPrint::SetChildFlag)
      end
    end
  end
end