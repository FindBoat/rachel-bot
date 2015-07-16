Agenda = require 'agenda'

config = require '../config/config'


agenda = new Agenda
  db:
    address: config.MONGODB_URI

module.exports = agenda
