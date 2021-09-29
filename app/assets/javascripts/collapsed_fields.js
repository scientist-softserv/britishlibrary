$(document).on("turbolinks:load", function() {
  $('.collapse-fields').click(function(event) {
    $('.collapse-fields span').toggle()
  })
});