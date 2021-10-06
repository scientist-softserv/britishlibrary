// add another alternate identifier section
$(document).on('turbolinks:load', function() {
    return $('body').on('click', '.add_alternate_identifier', function(event) {
      event.preventDefault();

      // find the nearest parent alternate identifier section and clone it
      // then clear the values in the fields in that section
      const ubiquityAlternateIdentifierClass = $(this).attr('data-addUbiquityAlternateIdentifier');
      const clonedAlternateIdentifierSection = $(this).closest(`div${ubiquityAlternateIdentifierClass}`).last().clone();
      clonedAlternateIdentifierSection.find('input').val('');
      clonedAlternateIdentifierSection.find('option').attr('selected', false);

      // add the cloned section at the end of the alternate identifier list
      $(`${ubiquityAlternateIdentifierClass}`).last().after(clonedAlternateIdentifierSection);
    });
  });

  // remove selected alternate identifier section
  $(document).on('turbolinks:load', function() {
    return $('body').on('click', '.remove_alternate_identifier', function(event) {
      event.preventDefault();

      if ($('.ubiquity-meta-alternate-identifier').length > 1 ) {
        const ubiquityAlternateIdentifierClass = $(this).attr('data-removeUbiquityAlternateIdentifier');
        $(this).closest(`div${ubiquityAlternateIdentifierClass}`).remove();
      }
    });
  });

  // if "alternate identifier" is filled in, "type of alternate identifier" is required
  $(document).on('turbolinks:load', function() {
    return $('body').on('blur', '.alternate_identifier', function(event) {
      event.preventDefault();

      const alternateIdentifier = $.trim($(this).val());
      const alternateIdentifierType = $(this).closest('.ubiquity-meta-alternate-identifier').find('.alternate_identifier_type');

      if (alternateIdentifier) {
          alternateIdentifierType.attr('required', true);;
      } else {
          alternateIdentifierType.attr('required', false);;
      }
    });
  });
