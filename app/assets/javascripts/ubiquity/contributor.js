// add another contributor section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_contributor', function(event) {
    event.preventDefault();

    // find the nearest parent contributor section and clone it
    // then clear the values in the fields in that section
    const ubiquityContributorClass = $(this).attr('data-addUbiquityContributor');
    const clonedContributorSection = $(this).closest(`div${ubiquityContributorClass}`).last().clone();
    clonedContributorSection.find('input').val('');
    clonedContributorSection.find('option').attr('selected', false);

    // increment hidden_field counter after cloning
    const lastInputCount = $('.ubiquity-contributor-score').last().val();
    const hiddenInput = $(clonedContributorSection).find('.ubiquity-contributor-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);

    // add the cloned section at the end of the contributor list
    // and set 'Personal' as the type
    $(`${ubiquityContributorClass}`).last().after(clonedContributorSection);
    $('.ubiquity_contributor_name_type').last().val('Personal').change();
  });
});

// remove selected contributor section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_contributor', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-contributor').length > 1 ) {
      const ubiquityContributorClass = $(this).attr('data-removeUbiquityContributor');
      $(this).closest(`div${ubiquityContributorClass}`).remove();
    }
  });
});

// display a new contributor section on the new or edit form
$(document).on('turbolinks:load', function() {
  return $('body').on('change', '.ubiquity_contributor_name_type', function() {
    displayContributorFields($(this.parentElement), this.value);
  });
});

// set saved values in the contributor section(s) on the edit work form
$(document).on('turbolinks:load', function() {
  $('.ubiquity_contributor_name_type').each(function() {
    displayContributorFields($(this).parent(), this.value);
  })
});

function displayContributorFields(self, value) {
  if (value == 'Personal') {
    hideContributorOrganization(self);

  } else if (value == 'Organisational') {
    hideContributorPersonal(self);

  } else {
    $('.ubiquity_contributor_name_type').last().val('Personal').change();
  }
}

function hideContributorOrganization(self) {
  self.siblings('.ubiquity_personal_fields').show();
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_contributor_organization_name').last().val('');
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_contributor_organization_name').last().removeAttr('required');
  self.siblings('.ubiquity_organization_fields').hide();
}

function hideContributorPersonal(self) {
  self.siblings('.ubiquity_organization_fields').show();
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_contributor_family_name').last().val('').removeAttr('required');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_contributor_given_name').last().val('').removeAttr('required');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_contributor_orcid').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_contributor_institutional_relationship').last().val('');
  self.siblings('.ubiquity_personal_fields').hide();
}
