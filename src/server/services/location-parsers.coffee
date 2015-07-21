http = require 'http'

bot = require './bots'


parseLocation = (message, next) ->
  if message?.location?.longitude?
    location = 
      lat: message.location.latitude
      lng: message.location.longitude
    next null, location
  else if message?.text?
    address = message.text.split(' ').join '+'
    options =
      host: 'maps.googleapis.com'
      path: '/maps/api/geocode/json?sensor=false&address=' + address
    http.get options, (res) ->
      body = ''
      res.on 'data', (data) -> body += data
      res.on 'end', ->
        parsed = JSON.parse body
        if parsed.status isnt 'OK'
          next "Bad request: #{message.text}", null
        else if parsed.results? and parsed.results.length > 0
          location = 
            lat: parsed.results[0]?.geometry?.location?.lat
            lng: parsed.results[0]?.geometry?.location?.lng
          next null, location
        else
          next 'No Result', null
  else
    next 'No location and text', null

module.exports =
  parse: parseLocation
