root = exports ? this

# Given a count of things, determines whether to use the singular or plural
# form. Returns a string consisting of the count and the correct noun form.
#
# @example
#   pluralize(2, 'duck', 'ducks') #=> "2 ducks"
#
# @param [Integer] count The number of things.
# @param [String] singular The name of one such thing.
# @param [String] plural The name of two or more such things.
# @return [String] A string describing the thing(s) and its/their quantity.
#
root.pluralize = (count, singular, plural) ->
  if typeof count == "number"
    "#{count || 0} " + (if count == 1 then singular else plural)
  else if typeof count == "string"
    "#{count || 0} " + (if count.match(/^1(\.0+)?$/) then singular else plural)

# Converts a Date (or integer timestamp) into a rough human-readable
# approximation.  BYO "ago" or other suffix.
#
# @example
#   timeAgoInWords(1331697706) #=> "about 5 minutes"
#
# @param [Date, Integer] from_time The start of the time interval.
# @param [Boolean] include_seconds Whether to specify sub-minute intervals.
# @return [String] A description of the time interval.
# @see #distanceOfTimeInWords
#
root.timeAgoInWords = (from_time, include_seconds=false) ->
  root.distanceOfTimeInWords from_time, new Date(), include_seconds

# Converts a time interval between two Dates (or integer timestamps) into a
# rough approximation.
#
# @example
#   distanceOfTimeInWords(1331697706, 1331659274) #=> "about 1 minute"
#
# @param [Date, Integer] from_time The start of the time interval.
# @param [Date, Integer] to_time The end of the time interval.
# @param [Boolean] include_seconds Whether to specify sub-minute intervals.
# @return [String] A description of the time interval.
#
root.distanceOfTimeInWords = (from_time, to_time, include_seconds=false) ->
  from_time = new Date(from_time) if typeof from_time == 'number'
  to_time = new Date(to_time) if typeof to_time == 'number'
  distance_in_minutes = Math.round(Math.abs(to_time.getTime() - from_time.getTime()) / 60000)
  distance_in_seconds = Math.round(Math.abs(to_time.getTime() - from_time.getTime()) / 1000)

  if distance_in_minutes >= 0 && distance_in_minutes <= 1
    (return if distance_in_minutes == 0 then "less than 1 minute" else "about 1 minute") unless include_seconds
    if distance_in_seconds >= 0 && distance_in_seconds <= 4 then return "less than 5 seconds"
    else if distance_in_seconds >= 5 && distance_in_seconds <= 9 then return "less than 10 seconds"
    else if distance_in_seconds >= 10 && distance_in_seconds <= 19 then return "less than 20 seconds"
    else if distance_in_seconds >= 20 && distance_in_seconds <= 39 then return "half a minute"
    else if distance_in_seconds >= 40 && distance_in_seconds <= 59 then return "less than 1 minute"
    else "about 1 minute"
  else if distance_in_minutes >= 2 && distance_in_minutes <= 44 then return "about #{distance_in_minutes} minutes"
  else if distance_in_minutes >= 45 && distance_in_minutes <= 89 then return "about 1 hour"
  else if distance_in_minutes >= 90 && distance_in_minutes <= 1439 then return "about #{Math.round(distance_in_minutes / 60.0)} hours"
  else if distance_in_minutes >= 1440 && distance_in_minutes <= 2519 then return "about 1 day"
  else if distance_in_minutes >= 2520 && distance_in_minutes <= 43199 then return "about #{Math.round(distance_in_minutes / 1440.0)} days"
  else if distance_in_minutes >= 43200 && distance_in_minutes <= 86399 then return "about 1 month"
  else if distance_in_minutes >= 86400 && distance_in_minutes <= 525599 then return "about #{Math.round(distance_in_minutes / 43200.0)} months"
  else
    fyear = from_time.getYear()
    if from_time.getMonth() >= 3 then fyear += 1
    tyear = to_time.getYear()
    if to_time.getMonth() < 3 then tyear -= 1
    leap_years = if fyear <= tyear then 0 else (y for y in [fyear..tyear] when isLeapYear(y)).length
    minute_offset_for_leap_year = leap_years * 1440
    minutes_with_offset = distance_in_minutes - minute_offset_for_leap_year
    remainder = minutes_with_offset % 525600
    distance_in_years = Math.round(minutes_with_offset / 525600)
    if remainder < 131400
      "about #{distance_in_years} years"
    else if remainder < 394200
      "over #{distance_in_years} years"
    else
      "almost #{distance_in_years + 1} years"

# Returns whether or not the given year is a leap year.
#
# @example
#   isLeapYear(2012) #=> true
#
# @param [Integer] year The year.
# @return [true, false] Whether it was a leap year.
#
root.isLeapYear = (year) ->
  year % 4 == 0 && year % 100 != 0 || year % 400 == 0

# Sanitizes a string for use in Bourne-style shells.
#
# @param [String] str A string.
# @return [String] The sanitized and escaped string.
#
root.shellEscape = (str) ->
  if str == '' then return "''"
  str.replace(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1").replace(/\n/, "'\n'")

root.escapeCSS = (text) ->
  text.replace /[  !"#$%&'()*+,./:;<=>?@\[\\\]^`{|}~]/g, "\\$&"


# Converts an array of strings into a sentence with an Oxford comma.
#
# @param [Array] ary An array of strings.
# @return [String] The sentence form.
#
root.toSentence = (ary) ->
  if ary.length == 0
    ""
  else if ary.length == 1
    ary[0]
  else if ary.length == 2
    "#{ary[0]} and #{ary[1]}"
  else
    "#{ary[0...-1].join(', ')}, and #{ary[ary.length - 1]}"

# Converts a number like 1234 (or a string) into a string like "1,234". Works
# with decimals.
#
# @param [Integer] number A number like 1234.
# @return [String] A string like "1,234".
#
root.numberWithDelimiter = (number) ->
  parts = ("#{number}").split('.')
  parts[0] = parts[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/, "$1,")
  parts.join('.')

# Converts the names and values of a form into a JavaScript object.
#
# @example
#   $('#my-form').serializeObject() #=> { key1: 'value1', key2: 'value2', ... }

jQuery.fn.serializeObject = ->
  object = {}
  pairs = $(this[0]).serializeArray()
  for pair in pairs
    do (pair) ->
      if object[pair.name]
        if !object[pair.name].push
          object[pair.name] = [object[pair.name]]
        object[pair.name].push(pair.value || '')
      else
        object[pair.name] = (pair.value || '')
  object

jQuery.fn.extend
  # Like $.append, but safely appends text with HTML-unsafe characters.
  appendText: (text) ->
    $(this).append document.createTextNode(text)

  # Returns true if an object is scrolled into view.
  isOnScreen: ->
    win = $(window)
    viewport =
      top: win.scrollTop()
      left: win.scrollLeft()

    viewport.right = viewport.left + win.width()
    viewport.bottom = viewport.top + win.height()
    bounds = @offset()
    bounds.right = bounds.left + @outerWidth()
    bounds.bottom = bounds.top + @outerHeight()
    not (viewport.right < bounds.left or viewport.left > bounds.right or viewport.bottom < bounds.top or viewport.top > bounds.bottom)

# Simple array iterator.
Array::each = (fn) ->
  for item, index in this
    fn(item, index)
  this

# Returns true if the function evaluates to true for any value.
Array::any = (fn) ->
  for item, index in this
    return true if fn(item, index)
  return false

# Returns an array with only those items for which the function returns true.
Array::select = (fn) ->
  new_array = []
  for item, index in this
    new_array.push(item) if fn(item, index)
  return new_array

# Returns an array with only those items for which the function returns false.
Array::reject = (fn) ->
  new_array = []
  for item, index in this
    new_array.push(item) unless fn(item, index)
  return new_array

# Returns a new array with duplicates removed.
Array::uniq = ->
  'use strict'
  ret = []
  used = new Set
  i = 0
  while i < @length
    if !used.has(@[i])
      ret.push @[i]
      used.add @[i]
    i++
  ret

root.removeFromArray = (array, b) ->
  i = array.length
  while --i >= 0
    if array[i] == b
      array.splice i, 1
