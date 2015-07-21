chrono = require 'chrono-node'
date = require 'date.js'
moment = require 'moment'

# Returns {'timeStr': 'in 5 mins', 'date': Date object}.
parseTime = (str, offsetDate) ->
  timeWords = ['min', 'minute', 'minutes', 'sec', 'second', 'seconds',
      'hrs', 'hour', 'hours', 'day', 'days', 'week', 'weeks', 'month',
      'months', 'year', 'years', 'now', 'mon', 'monday', 'tue', 'tuesday',
      'wed', 'wednesday', 'thu', 'thursday', 'fri', 'friday', 'sat',
      'saturday', 'sun', 'sunday', 'last', 'tomorrow', 'tmr', 'noon',
      'morning', 'night', 'afternoon', 'tonight', 'from', 'at', 'some time',
      'any time', 'in', 'this', 'next', 'last']
  words = str.split(' ').reverse()

  # Check absolute date w/ chrono.
  result = chrono.parse str, offsetDate
  if result? and result.length > 0
    absTimeStr = result[0].text.replace /// ^[\W_]+ ///, ''
    index = str.indexOf absTimeStr
    if index is -1 then return
    absTimeStr = str.substring index
    absDate = result[0].start.date()
  else
    absTimeStr = ''
    absDate = null
  console.log "Get absTimeStr: '#{absTimeStr}' and absDate: #{absDate}"

  # Check relative date w/ date.js.
  relTimeStr = ''
  backSubStr = ''
  relDate = null
  for word in words
    backSubStr = word + ' ' + backSubStr
    subDate = date backSubStr, offsetDate

    proceed = false
    if word in timeWords or not isNaN word
      proceed = true
    else if not relDate? or subDate.toString() isnt relDate.toString()
      proceed = true
    else
      break

    if proceed
      relDate = subDate
      relTimeStr = backSubStr
  relTimeStr = relTimeStr.substring 0, relTimeStr.length - 1
  console.log "Get relTimeStr: '#{relTimeStr}' and resDate: #{relDate}"

  # Merge abs & rel time.
  if absDate? and not relDate?
    timeStr = absTimeStr
    remindDate = absDate
  else if not absDate? and relDate?
    timeStr = relTimeStr
    remindDate = relDate
  else
    if absTimeStr.length > relTimeStr.length
      timeStr = absTimeStr
    else
      timeStr = relTimeStr

    remindDate = relDate
    remindDate.setFullYear absDate.getFullYear()
    remindDate.setMonth absDate.getUTCMonth()
    remindDate.setDate absDate.getUTCDate()

  # Maybe include prop.
  props = ['on', 'in', 'at', 'this']
  for prop in props
    if str.indexOf(' ' + prop + ' ' + timeStr) isnt -1
      timeStr = prop + ' ' + timeStr
      break

  console.log "Get timeStr: '#{timeStr}' and date: #{remindDate}"
  return timeStr: timeStr, date: remindDate


parseReminder = (text, offsetDate, next) ->
  # Remove leading, trailing non-alphanumerics, & consecutive spaces.
  text = text.replace /// ^[\W_]+ ///, ''
  text = text.replace /// [\W_]+$ ///, ''
  text = text.toLowerCase().replace /// \s+ ///, ' '

  # Extract "remind sentence".
  remindIndex = text.indexOf 'remind'
  if remindIndex isnt -1
    text = text.substring remindIndex

  # "remind me to <todo> <time>"
  if text.indexOf('remind me to ') is 0
    str = text.substring 13
    result = parseTime str, offsetDate
    timeIndex = str.indexOf result.timeStr

    # This should never happen.
    if timeIndex is -1 then return null
    todoStr = str.substring 0, timeIndex - 1
    res = time: result.date, todo: todoStr
    next null, res
  # "remind me <time> to <todo>."
  else if text.indexOf('remind me') is 0
    toIndex = text.indexOf ' to '
    if toIndex is -1 then return null
    timeStr = text.substring 10, toIndex
    result = parseTime timeStr, offsetDate
    todoStr = text.substring toIndex + 4
    res = time: result.date, todo: todoStr
    next null, res
  else
    next 'Fail to parse reminder', null


module.exports =
  parse: parseReminder
