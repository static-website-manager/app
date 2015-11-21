$(document).on 'submit', 'form#credit_card', (e) ->
  e.preventDefault()
  form = $(e.target)

  form.find('button').
    removeClass('btn-success').
    addClass('btn-default disabled').
    text('Subscribing...').
    prepend('<i class="fa fa-spinner fa-spin m-r-sm">')

  enableFormButton = ->
    form.find('button').
      removeClass('btn-default disabled').
      addClass('btn-success').
      text('Subscribe').
      find('i').
      remove()

  stripeResponseHandler = (status, response) ->
    if response.error
      $('#credit_card-errors').css('display', 'block').find('li').text(response.error.message)
      $('html, body').animate({ scrollTop: 0 }, 'slow')
      enableFormButton()
    else
      $('#subscription_payment_information').val(response.id)
      form.get(0).submit()

  Stripe.card.createToken({
    number: $('#card_number').val(),
    cvc: $('#card_cvc').val(),
    exp_month: $('#exp_month').val(),
    exp_year: $('#exp_year').val()
  }, stripeResponseHandler)
