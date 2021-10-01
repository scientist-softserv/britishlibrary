// $('a.collapse-fields').attr('id', function() {
//   return 'field_' + $(this).index();
// });

$(document).on("turbolinks:load", function() {
  $(`.collapse-fields`).click(function(event) {
    console.log({event})
    $(`#${event.target.parentElement.id} span`).toggle()
  })
});