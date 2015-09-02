$(window).ready ->
  $('.playlist-check').click ->
    $.ajax $(this).attr('data-url'),
      type: 'PATCH'
      success: (playlist) =>
        if playlist.listened_at?
          $(this).closest('.playlist').addClass 'listened'
          $(this).attr 'checked', 'checked'
        else
          $(this).closest('.playlist').removeClass 'listened'
          $(this).removeAttr 'checked'
