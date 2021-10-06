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
    // ---------------- and set 'Personal' as the type
    $(`${ubiquityEditorClass}`).last().after(clonedEditorSection);
    // $('.ubiquity_editor_name_type').last().val('Personal').change();
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
    displayFields($(this.parentElement), this.value);
  });
});

function displayFields(self, value) {
  if (value == 'Personal') {
    // const lastPersonalSibling = self.siblings('.ubiquity_personal_fields').last();

    hideEditorOrganization(self);

  } else if (value == 'Organisational') {
    // const lastOrgSibling = self.siblings('.ubiquity_organization_fields').last();

    hideEditorPersonal(self);

  } else {
    $('.ubiquity_editor_name_type').last().val('Personal').change();
  }
}

// // update the org name
// $(document).on('turbolinks:load', function() {
//   return $('body').on('blur', '.ubiquity_creator_organization_name', function (event) {
//     event.preventDefault();

//     const _this = $(this).closet('.ubiquity_organization_fields').last();
//   });
// });

// update the family or given name
// $(document).on('turbolinks:load', function() {
//   return $('body').on('blur', '.ubiquity_creator_family_name, .ubiquity_creator_given_name', function (event) {
//     event.preventDefault();

//     const _this = $(this).closest('.ubiquity_personal_fields').last()
//   });
// });

function hideEditorOrganization(self) {
  self.siblings('.ubiquity_personal_fields').show();
  self.siblings('.ubiquity_organization_fields').find('.ubiquity_editor_organization_name').last().val('');
  self.siblings('.ubiquity_organization_fields').hide();
}

function hideEditorPersonal(self) {
  self.siblings('.ubiquity_organization_fields').show();
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_orcid').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_family_name').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_given_name').last().val('');
  self.siblings('.ubiquity_personal_fields').find('.ubiquity_editor_institutional_relationship').last().val('');
  self.siblings('.ubiquity_personal_fields').hide();
}
