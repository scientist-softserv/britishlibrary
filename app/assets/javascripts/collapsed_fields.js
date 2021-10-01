$(document).on("turbolinks:load", function() {
  $(`.collapse-fields`).click(function(event) {
    $(`#${event.target.parentElement.id} span`).toggle()
  })
});