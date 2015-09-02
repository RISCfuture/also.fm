class Multibutton
  constructor: (@input) ->
    @input.wrap $('<ul/>').addClass('multibutton')
    @wrapper = @input.parent()
    for o in @input[0].options
      do (o) =>
        li = $('<li/>').html(o.innerHTML).attr('data-value', $(o).attr('value')).appendTo @wrapper
        li.addClass('active') if @input.val() == $(o).attr('value')
        li.click =>
          @wrapper.find('li').removeClass 'active'
          li.addClass 'active'
          @input.val $(o).attr('value')

$(window).ready ->
  $('[data-multibutton]').each ->
    new Multibutton($(this))
