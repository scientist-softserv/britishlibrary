# TODO ~alignment: Bring over related JS file app/assets/javascripts/ubiquity/preselect_institution_by_tenant.js

# Modify this method to changes the preselection for the Institute field
module Ubiquity
  module PreselectInstitutionHelper
    def fetch_institution_by_tenant
      tenant_name = ubiquity_url_parser request.original_url
      institution_hash = {
                            'British Library' => ['sandbox', 'sandbox2', 'bl', 'bl-demo'],
                            'British Museum' => ['britishmuseum', 'britishmuseum-demo'],
                            'Historic Royal Palaces' => ['hrp', 'hrp-demo'],
                            'MOLA' => ['sandbox2', 'mola', 'mola-demo'],
                            'National Library of Scotland' => ['nls', 'nls-demo'],
                            'National Museums Scotland' => ['nms', 'nms-demo'],
                            'National Trust' => ['nt', 'nt-demo'],
                            'Royal Botanic Gardens, Kew' => ['kew', 'kew-demo'],
                            'Science Museum Group' => ['sciencemuseumgroup', 'sciencemuseumgroup-demo'],
                            'Tate' => ['tate', 'tate-demo'],
                            'The Alan Turing Institute' => ['ati', 'ati-demo'],
                            '' => ['nhs', 'nhs-demo']
                          }
      institution_hash.select { |_key, values| values.include?(tenant_name) }.keys.first
    end
  end
end
