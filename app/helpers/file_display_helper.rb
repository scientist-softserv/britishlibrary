module FileDisplayHelper
  #This method is called in app/views/shared/ubiquity/file_sets/_show_details.html.erb and /home/antonio/hyku/hyku/app/views/shared/ubiquity/works/_member.html.erb
  #to fetch create a hash of license and its terms to be loaded in the file details view and the member view
  def master_license_hash
    MASTER_LICENSE_HASH
  end
end
