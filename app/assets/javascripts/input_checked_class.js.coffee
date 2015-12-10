$(document).ready ->
  $('[data-input-checked-class] input[type="radio"]:checked').each (i, input) ->
    container = $(input).closest('[data-input-checked-class]')
    container.addClass(container.data('inputCheckedClass'))

$(document).on 'change', '[data-input-checked-class] input[type="radio"]', (e) ->
  $('[data-input-checked-class] input[type="radio"]').each (i, input) ->
    container = $(input).closest('[data-input-checked-class]')

    if $(input).is(':checked')
      container.addClass(container.data('inputCheckedClass'))
    else
      container.removeClass(container.data('inputCheckedClass'))
