module Hyrax
  module CreateDerivativesJobDecorator
    def perform(file_set, file_id, filepath = nil)
      return if file_set.video? && !Hyrax.config.enable_ffmpeg
      filename = Hyrax::WorkingDirectory.find_or_retrieve(file_id, file_set.id, filepath)

      if file_set.mesh?
        apply_mesh_derivative(file_set, filename)
      else
        file_set.create_derivatives(filename)
      end

      # Reload from Fedora and reindex for thumbnail and extracted text
      file_set.reload
      file_set.update_index
      file_set.parent.update_index if parent_needs_reindex?(file_set)
    end

    # skips the normal derivative service for .glb files and instead
    # copies the file directly into where it needs to be
    def apply_mesh_derivative(file_set, uploaded_filename)
      extension = 'glb'
      derivative_path = Hyrax::DerivativePath.derivative_path_for_reference(file_set, extension)
      output_file_dir = File.dirname(derivative_path)
      FileUtils.mkdir_p(output_file_dir) unless File.directory?(output_file_dir)
      FileUtils.cp(uploaded_filename, derivative_path)
    end
  end
end

Hyrax::CreateDerivativesJob.prepend(Hyrax::CreateDerivativesJobDecorator)
