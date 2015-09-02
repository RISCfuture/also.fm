root = exports ? this

root.removeFromArray = (array, b) ->
  i = array.length
  while --i >= 0
    if array[i] == b
      array.splice i, 1
