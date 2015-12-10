$(document).ready ->
  checkSetup = ->
    $.get $('#website_setup_check').data('url'), (data) ->
      if data.length
        clearPolling()
        Turbolinks.visit(data)

  clearPolling = ->
    if setupCheckInterval
      clearInterval(setupCheckInterval)
      $(document).off('page:change', clearPolling)

  if $('#website_setup_check').length
    setupCheckInterval = setInterval(checkSetup, 5000)
    $(document).on('page:change', clearPolling)
