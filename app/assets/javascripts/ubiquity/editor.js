// add another editor section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_editor', function(event) {
    event.preventDefault();

    // find the nearest parent editor section and clone it
    // then clear the values in the fields in that section
    const ubiquityEditorClass = $(this).attr('data-addUbiquityEditor');
    const clonedEditorSection = $(this).closest(`div${ubiquityEditorClass}`).last().clone();
    clonedEditorSection.find('input').val('');
    clonedEditorSection.find('option').attr('selected', false);

    // increment hidden_field counter after cloning
    const lastInputCount = $('.ubiquity-editor-score').last().val();
    const hiddenInput = $(clonedEditorSection).find('.ubiquity-editor-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);

    // add the cloned section at the end of the editor list
    // and set 'Personal' as the type
    $(`${ubiquityEditorClass}`).last().after(clonedEditorSection);
    $('.ubiquity_editor_name_type').last().val('Personal').change();
  });
});

// remove selected editor section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_editor', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-editor').length > 1 ) {
      const ubiquityEditorClass = $(this).attr('data-removeUbiquityEditor');
      $(this).closest(`div${ubiquityEditorClass}`).remove();
    }
  });
});

// display a new editor section on the new or edit form
$(document).on('turbolinks:load', function() {
  return $('body').on('change', '.ubiquity_editor_name_type', function() {
    displayEditorFields($(this), this.value, false);
  });
});

// set saved values in the editor section(s) on the edit work form
$(document).on('turbolinks:load', function() {
  $('.ubiquity_editor_name_type').each(function() {
    displayEditorFields($(this), this.value, true);
  })
});

// default the editor type to personal
// if one hasn't been selected
// init arg added
function displayEditorFields(self, value, init) {
  if (value == 'Personal') {
    hideEditorOrganization(self, init);

  } else if (value == 'Organisational') {
    hideEditorPersonal(self, init);

  } else {
    $('.ubiquity_editor_name_type').last().val('Personal').change();
  }
}

function hideEditorOrganization(self, init) {
  self.siblings('.ubiquity_personal_fields').show();
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_editor_organization_name').last().val('');
  if (init === false) {
    self.siblings('.isni_input_group').find('.ubiquity_editor_isni').last().val('');
  }
  self.siblings('.ubiquity_organization_fields').hide();
}

function hideEditorPersonal(self, init) {
  self.siblings('.ubiquity_organization_fields').show();
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_orcid').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_family_name').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_given_name').last().val('');
  if (init === false) {
    self.siblings('.isni_input_group').find('.ubiquity_editor_isni').last().val('');
  }
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_institutional_relationship').last().val('');
  self.siblings('.ubiquity_personal_fields').hide();
}
