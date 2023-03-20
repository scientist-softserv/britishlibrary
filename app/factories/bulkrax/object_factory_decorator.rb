# frozen_string_literal: true

module Bulkrax
  module ObjectFactoryDecorator
    def handle_remote_file(remote_file:, actor:, update: false)
      # points to BL's specific drive that is large enough to store huge temp file
      tmp_dir = './tmp/shared'
      actor.file_set.label = remote_file['file_name']
      actor.file_set.import_url = remote_file['url']

      url = remote_file['url']
      FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
      tmp_file = Tempfile.new(remote_file['file_name'].split('.').first, tmp_dir)
      tmp_file.binmode

      URI.open(url) do |url_file|
        tmp_file.write(url_file.read)
      end

      tmp_file.rewind
      update == true ? actor.update_content(tmp_file) : actor.create_content(tmp_file, from_url: true)
      tmp_file.close
    end
  end
end

Bulkrax::ObjectFactory.prepend(Bulkrax::ObjectFactoryDecorator)
