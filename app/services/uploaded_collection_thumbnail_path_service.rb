class UploadedCollectionThumbnailPathService < Hyrax::ThumbnailPathService
  class << self
    # @param [Collection] object to get the thumbnail path for an uploaded image
    def call(object)
      "/uploaded_collection_thumbnails/#{object.id}/#{object.id}_card.jpg"
    end

    # rubocop:disable Rails/FilePath, Lint/StringConversionInInterpolation
    def uploaded_thumbnail?(collection)
      File.exist?("#{Rails.root.to_s}/public/uploads/uploaded_collection_thumbnails/#{collection.id}/#{collection.id}_card.jpg")
    end

    def upload_dir(collection)
      "#{Rails.root.to_s}/public/uploads/uploaded_collection_thumbnails/#{collection.id}"
    end
    # rubocop:enable Rails/FilePath, Lint/StringConversionInInterpolation
  end
end
