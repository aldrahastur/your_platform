$(document).ready ->
  
  # Submit the form when the image is uploaded.
  #
  $(document).on 'upload:complete', 'form.edit_user', ->
    $(this).submit()
    
  # Show notice when upload begins.
  $(document).on 'upload:start', 'form.edit_user', ->
    $('form.edit_user').hide()
    $('.uploading_avatar').removeClass('hidden').show()

  # When the user clicks on the image, switch to edit_mode
  # such that the user can see the upload button.
  #
  $(document).on 'click', '.avatar.thumbnail.pull-left', ->
    if $(this).closest('.box').find('.show_only_in_edit_mode').count() > 0
      $(this).closest('.box').trigger('edit')
    
  # Open upload mechanism automatically when the trigger is
  # pressed. This is done by the "change avatar" button in the
  # logged-in-bar sessions menu.
  #
  if $('input#user_avatar.auto_trigger').count() > 0
    setTimeout ->
      $('.box.first').trigger('edit')
    , 200
    setTimeout ->
      $('input#user_avatar.auto_trigger')
        .effect('highlight', 'slow', 200)
        .effect('highlight', 'slow', 200)
        .effect('highlight', 'slow', 200)
    , 800
