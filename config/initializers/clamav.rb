# Pre Hyrax 3.5 we will overide use of clamav gem and use clamby
# Inspired by https://github.com/UNC-Libraries/hy-c/commit/57c84bd0fdfb9ee8b00cc70194971c3fe9fea265#diff-8b7db4d5cc4b8f6dc8feb7030baa2478
Hydra::Works.default_system_virus_scanner = Hyc::VirusScanner

Clamby.configure({
                     :check => false,
                     :daemonize => true,
                     :config_file => nil,
                     :error_clamscan_missing => true,
                     :error_clamscan_client_error => false,
                     :error_file_missing => true,
                     :error_file_virus => false,
                     :fdpass => true,
                     :stream => false,
                     :output_level => 'medium', # one of 'off', 'low', 'medium', 'high'
                     :executable_path_clamscan => 'clamscan',
                     :executable_path_clamdscan => 'clamdscan',
                     :executable_path_freshclam => 'freshclam',
                 })
