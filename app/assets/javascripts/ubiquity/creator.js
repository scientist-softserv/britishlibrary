// add linked fields
$(document).on("turbolinks:load", function() {

  return $("body").on("click", ".add_creator", function(event) {
    event.preventDefault();
    var ubiquityCreatorClass = $(this).attr('data-addUbiquityCreator');
    cloneUbiDiv = $(this).parent('div' + ubiquityCreatorClass + ':last').clone();

    _this = this;
    cloneUbiDiv.find('input').val('');
    cloneUbiDiv.find('option').attr('selected', false);

    //increment hidden_field counter after cloning
    var lastInputCount = $('.ubiquity-creator-score:last').val();
    var hiddenInput = $(cloneUbiDiv).find('.ubiquity-creator-score');
    hiddenInput.val(parseInt(lastInputCount) + 1);
    $(ubiquityCreatorClass +  ':last').after(cloneUbiDiv)
    $('.ubiquity_creator_name_type:last').val('Personal').change()
  });
});

//remove linked fields
$(document).on("turbolinks:load", function() {
  return $("body").on("click", ".remove_creator", function(event) {
    event.preventDefault();
    var ubiquityCreatorClass = $(this).attr('data-removeUbiquityCreator');
    _this = this;
    removeUbiquityCreator(_this, ubiquityCreatorClass);
  });
});

function removeUbiquityCreator(self, creatorDiv) {
  if ($(".ubiquity-meta-creator").length > 1 ) {
    $(self).parent('div' + creatorDiv).remove();
  }
}

//for hiding and showing values on the edit form for creator sub fields
$(document).on("turbolinks:load", function() {
  return $("body").on("change", ".ubiquity_creator_name_type, .additional-fields", function(event) {
    if (event.target.value == 'Personal') {
      var _this = $(this);
      hideCreatorOrganization(_this);

      _this = $(this).siblings('.ubiquity_personal_fields')
      creatorUpdateRequired(_this, 'family')
      creatorUpdateRequired(_this, 'given')

    } else {
      var _this = $(this);
      hideCreatorPersonal(_this);

      _this = $(this).siblings('.ubiquity_organization_fields:last');
      creatorUpdateRequired(_this, 'organization')
    }
  });
});

$(document).on("turbolinks:load", function() {
  if($(".ubiquity_creator_name_type").is(':visible')) {
    $(".ubiquity_creator_name_type").each(function() {
      displayFields(this)
    })
  };
});

$(document).on("turbolinks:load", function() {
  $('.additional-fields').click(function(event) {
    $(".ubiquity_creator_name_type").each(function() {
        displayFields(this);
    })
  })
});

function displayFields(self) {
  var _this = $(self);

  if (self.value == 'Personal') {
    hideCreatorOrganization(_this);

    _this = $(self).siblings('.ubiquity_personal_fields:last');
    creatorUpdateRequired(_this, 'family')
    creatorUpdateRequired(_this, 'given')

    $(this).siblings('.ubiquity_personal_fields').show();

  } else if (self.value == 'Organisational') {
    hideCreatorPersonal(_this);

    var _this = $(self).siblings('.ubiquity_organization_fields:last');
    creatorUpdateRequired(_this, 'organization')

  } else {
    $('.ubiquity_creator_name_type:last').val('Personal').change()
  }
}

$(document).on("turbolinks:load", function() {
  return $("body").on("blur", ".ubiquity_creator_organization_name", function (event) {
    event.preventDefault();

    var _this = $(this).parent('.ubiquity_organization_fields:last');
    creatorUpdateRequired(_this, 'organization')
  });
});

$(document).on("turbolinks:load", function() {
  return $("body").on("blur", ".ubiquity_creator_family_name, .ubiquity_creator_given_name", function (event) {
    event.preventDefault();

    _this = $(this).parent('.ubiquity_personal_fields:last');
    creatorUpdateRequired(_this, 'family')
    creatorUpdateRequired(_this, 'given')
  });
});

function creatorUpdateRequired(self, field) {
  const givenName = self.find('.ubiquity_creator_given_name:last').val();
  const familyName = self.find('.ubiquity_creator_family_name:last').val();

  if (givenName || familyName) {
    self.find(`.ubiquity_creator_${field}_name:last`).attr('required', false);
  } else {
    self.find(`.ubiquity_creator_${field}_name:last`).attr('required', true);
  }
}

function hideCreatorOrganization(self) {
  self.siblings(".ubiquity_personal_fields").show()
  self.siblings(".ubiquity_organization_fields").find(".ubiquity_creator_organization_name:last").val('')
  self.siblings(".ubiquity_organization_fields").find(".ubiquity_creator_organization_name:last").removeAttr('required');
  self.siblings(".ubiquity_organization_fields").hide();
}

function hideCreatorPersonal(self) {
  self.siblings(".ubiquity_organization_fields").show()
  self.siblings(".ubiquity_personal_fields").find(".ubiquity_creator_family_name:last").val('').removeAttr('required');
  self.siblings(".ubiquity_personal_fields").find(".ubiquity_creator_given_name:last").val('').removeAttr('required');
  self.siblings(".ubiquity_personal_fields").find(".ubiquity_creator_orcid:last").val('');
  self.siblings(".ubiquity_personal_fields").find(".ubiquity_creator_institutional_relationship:last").val('');
  self.siblings(".ubiquity_personal_fields").hide();
}
