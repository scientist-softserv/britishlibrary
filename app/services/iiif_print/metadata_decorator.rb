# frozen_string_literal: true

# OVERRIDE IIIF Print v1.0 to bring the pdf name and number to the child metadata
# Added this decorator to the services folder instead of lib because of load order issues
module IiifPrint
  module MetadataDecorator
    def build_metadata
      metadata = super
      return metadata unless work['has_model_ssim'] == ['PdfPage']

      ##
      # @example
      #   "8cc760b3-cec3-4b92-88ac-d9ecb8fbeeb8 - CriticalReview-Digital-Humanities.pdf Page 1" =>
      #     [CriticalReview-Digital-Humanities.pdf, 1]
      parsed_name = work['title_tesim'].first.gsub(work['is_page_of_ssim'].first + ' - ', '').split(' Page ')
      file_name = parsed_name.first
      page_number = parsed_name.last
      metadata << { 'label' => { 'en' => ['PDF Name'] }, 'value' => { 'none' => [file_name] } }
      metadata << { 'label' => { 'en' => ['Page Number'] }, 'value' => { 'none' => [page_number] } }
    end
  end
end

IiifPrint::Metadata.prepend(IiifPrint::MetadataDecorator)
