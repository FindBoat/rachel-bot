mongoose = require 'mongoose'

agenda = require './services/agendas'
bot = require './services/bots'
messager = require './services/messagers'
config = require './config/config'


# Config mongo db.
mongoose.connect config.MONGODB_URI

bot.on 'message', (message) -> messager.handle message

exports.start = ->
  bot.start()
  agenda.start()

