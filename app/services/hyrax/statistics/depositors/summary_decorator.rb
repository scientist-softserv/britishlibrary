# Override Hyrax 2.9.6 to stop error when trprting on deposits by since removed users
#
module Hyrax
   module Statistics
       module Depositors
         module SummaryDecorator

          def depositors
            # step through the array by twos to get each pair
            results.map do |key, deposits|
              user = ::User.find_by_user_key(key)
             # Don't freak out if user not found (they may have been removed)
             if user
               { key: key, deposits: deposits, user: user }
             else
               # Leave user undef and let the view work out what to do
               { key: key, deposits: deposits }
            end
          end
        end

      end
    end
  end
end

Hyrax::Statistics::Depositors::Summary.prepend(Hyrax::Statistics::Depositors::SummaryDecorator)
