# OVERRIDE Hydra-access-controls 12.0.1
# Fix releasing leases on the day they are expired - this solves a 1 second bug around how
# midnights are calculated, which causes day of leases to incorrectly set the permissions to private
module Hydra
  module AccessControls
    module LeaseDecorator
      def active?
        (lease_release_date.present? && Time.zone.today.end_of_day < lease_release_date)
      end
    end
  end
end

Hydra::AccessControls::Lease.prepend(Hydra::AccessControls::LeaseDecorator)
