// add another related-identifier section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_related_identifier', function(event) {
    event.preventDefault();

    // find the nearest parent related-identifier section and clone it
    // then clear the values in the fields in that section
    const ubiquityRelatedIdentifierClass = $(this).attr('data-addUbiquityRelatedIdentifier');
    const clonedRelatedIdentifierSection = $(this).closest(`div${ubiquityRelatedIdentifierClass}`).last().clone();
    clonedRelatedIdentifierSection.find('input').val('');
    clonedRelatedIdentifierSection.find('option').attr('selected', false);

    // add the cloned section at the end of the related-identifier list
    $(`${ubiquityRelatedIdentifierClass}`).last().after(clonedRelatedIdentifierSection);
  });
});

// remove selected related-identifier section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_related_identifier', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-related-identifier').length > 1 ) {
      const ubiquityRelatedIdentifierClass = $(this).attr('data-removeUbiquityRelatedIdentifier');
      $(this).closest(`div${ubiquityRelatedIdentifierClass}`).remove();
    }
  });
});

// if "related identifier" is filled in
// "type of related identifier" and "relationship of related identifier" are required
$(document).on('turbolinks:load', function() {
  return $('body').on('blur', '.related_identifier', function(event) {
    event.preventDefault();

    const relatedIdentifier = $.trim($(this).val());
    const relatedIdentifierType = $(this).closest('.ubiquity-meta-related-identifier').find('.related_identifier_type');
    const relatedIdentifierRelation = $(this).closest('.ubiquity-meta-related-identifier').find('.related_identifier_relation');

    if (relatedIdentifier) {
        relatedIdentifierType.attr('required', true);;
        relatedIdentifierRelation.attr('required', true);;
    } else {
        relatedIdentifierType.attr('required', false);;
        relatedIdentifierRelation.attr('required', false);;
    }
  });
});
