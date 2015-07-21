https = require 'https'


extractTimeZone = (lat, lng, next) ->
  timestamp = Math.round(new Date().getTime() / 1000)
  options =
    host: 'maps.googleapis.com'
    path: ("/maps/api/timezone/json?location=#{lat},#{lng}" +
        "&timestamp=#{timestamp}")

  https.get options, (res) ->
    body = ''
    res.on 'data', (data) -> body += data
    res.on 'end', ->
      parsed = JSON.parse body
      if parsed.status is 'OK'
        tz = rawOffset: parsed.rawOffset, dstOffset: parsed.dstOffset
        next null, tz
      else
        next "Request failed: #{parsed.status}", null
  

module.exports =
  extractTimeZone: extractTimeZone
