$(document).on 'page:change', ->
  $('.marketing-jumbotron .panel').hide()
  $('.marketing-jumbotron .panel#product-screenshot-pages-layout').show()
  $('.marketing-jumbotron-feature').removeClass('active')
  $('.marketing-jumbotron-feature[data-screenshot=product-screenshot-pages-layout]').addClass('active')

$(document).on 'click', '.marketing-jumbotron-feature', (e) ->
  $('.marketing-jumbotron .panel').hide()
  $('.marketing-jumbotron-feature').removeClass('active')
  feature = $(e.target).closest('.marketing-jumbotron-feature')
  feature.addClass('active')
  screenshotID = feature.data('screenshot')
  $(".panel##{screenshotID}").show()
