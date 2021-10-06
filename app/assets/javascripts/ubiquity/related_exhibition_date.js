// add another related exhibition date section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_related_exhibition_date', function(event) {
    event.preventDefault();

    // find the nearest parent related exhibition date section and clone it
    // then clear the values in the fields in that section
    const ubiquityRelatedExhibitionDateClass = $(this).attr('data-addUbiquityRelatedExhibitionDate');
    const clonedRelatedExhibitionDateSection = $(this).closest(`div${ubiquityRelatedExhibitionDateClass}`).last().clone();
    clonedRelatedExhibitionDateSection.find('input').val('');
    clonedRelatedExhibitionDateSection.find('option').attr('selected', false);

    // add the cloned section at the end of the related exhibition date list
    $(`${ubiquityRelatedExhibitionDateClass}`).last().after(clonedRelatedExhibitionDateSection);
  });
});

// remove selected related exhibition date section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_related_exhibition_date', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-related-exhibition-date').length > 1 ) {
      const ubiquityRelatedExhibitionDateClass = $(this).attr('data-removeUbiquityRelatedExhibitionDate');
      $(this).closest(`div${ubiquityRelatedExhibitionDateClass}`).remove();
    }
  });
});
