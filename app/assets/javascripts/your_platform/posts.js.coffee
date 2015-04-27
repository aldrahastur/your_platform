ready = ->
  
  refresh_number_of_recipients_display = ->
    $('span.member_count').text("…")
    valid_from = ""
    valid_from = $('input.valid_from').val() if $('input.valid_from:hidden').size() == 0 # date visible
    if (valid_from.length == 10) or (valid_from.length == 0)  # valid date or no date
      url = $('span.member_count').data('query-url')
      url += "?valid_from=" + valid_from if valid_from.length == 10
      $.ajax({
        type: 'GET',
        url: url,
        success: (r)->
          $('span.member_count').text(r.member_count)
        }
      )
  
  $('label.constrain_validity_range').click ->
    if $(this).find('input').prop('checked')
      $('ul.constrain_validity_range').removeClass('hidden').show()
    else
      $('ul.constrain_validity_range').hide()
    refresh_number_of_recipients_display()
  
  $('input#valid_from').keyup ->
    refresh_number_of_recipients_display()

  $('#test_message, #confirm_message').click (click_event)->
    btn = $(this)
    real_message = ($(this).attr('id') == 'confirm_message')
    if real_message
      $('p.buttons.right').text("Nachricht wird gesendet …")
    else
      btn.text('Test-Nachricht wurde versandt.')
      setTimeout ->
        btn.text('Erneut zum Testen an meine eigene Adresse senden.')
      , 2000
    if $('label.constrain_validity_range input').prop('checked')
      recipients_count = $('span.member_count').text()
      valid_from = $('input.valid_from').val()
    $.ajax(
      type: 'POST',
      url: $(this).attr('href'),
      data: {
        text: $('#message_text').val(),
        subject: $('input.subject').val(),
        recipients_count: recipients_count ,
        valid_from: valid_from
      },
      success: (r)->
        if real_message
          $('p.buttons.right').text("Nachricht wurde an " + r.recipients_count + " Empfänger versandt.")
    )
    click_event.preventDefault()

      
$(document).ready(ready)

