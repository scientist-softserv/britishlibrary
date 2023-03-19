Hydra::Works::MimeTypes.module_eval do
  def mesh?
    self.class.mesh_mime_types.include? mime_type
  end

  module ClassMethods
    def mesh_mime_types
      # British Library only would use `.glb` files which would be `model/gltf-binary`
      # other common mime types include:
      # ['model/gltf+json', 'model/obj', 'model/vnd.collada+xml', 'model/stl']
      ['model/gltf-binary']
    end
  end
end
