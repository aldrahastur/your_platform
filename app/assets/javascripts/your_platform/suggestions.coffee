$(document).ready ->
  $('.suggestion_form.hidden').hide()

$(document).on 'click', '.show_suggestion_form', ->
  $(this).closest('.widget').find('.suggestion_form').removeClass('hidden').show()
  $(this).closest('.widget').find('.suggestion_form').find('textarea').autosize()
  false