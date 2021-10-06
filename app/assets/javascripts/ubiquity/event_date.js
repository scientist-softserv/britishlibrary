// add another event date section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.add_event_date', function(event) {
    event.preventDefault();

    // find the nearest parent event date section and clone it
    // then clear the values in the fields in that section
    const ubiquityEventDateClass = $(this).attr('data-addUbiquityEventDate');
    const clonedEventDateSection = $(this).closest(`div${ubiquityEventDateClass}`).last().clone();
    clonedEventDateSection.find('input').val('');
    clonedEventDateSection.find('option').attr('selected', false);

    // add the cloned section at the end of the event-date list
    $(`${ubiquityEventDateClass}`).last().after(clonedEventDateSection);
  });
});

// remove selected event date section
$(document).on('turbolinks:load', function() {
  return $('body').on('click', '.remove_event_date', function(event) {
    event.preventDefault();

    if ($('.ubiquity-meta-event-date').length > 1 ) {
      const ubiquityEventDateClass = $(this).attr('data-removeUbiquityEventDate');
      $(this).closest(`div${ubiquityEventDateClass}`).remove();
    }
  });
});
