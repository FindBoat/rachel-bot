mongoose = require 'mongoose'

agenda = require './agendas'
bot = require './bots'

Reminder = new mongoose.Schema
  userId: mongoose.Schema.ObjectId

  message: String
  createAt: type: Date, default: Date.now
  remindTime: type: Date
  todo: String
  reminded: type: Boolean, default: false
  chatId: String

# Create an Agenda after save.
Reminder.methods.saveWithAgenda = (user) ->
  reminder = this
  reminder.save (err, reminder) ->
    if err?
      console.log err
      return
      
    agenda.define reminder.id, (job, done) ->
      message = ("Hi #{user.firstName}, " +
          "you asked me to remind you to #{reminder.todo}." )
      bot.sendMessage
        chat_id: reminder.chatId
        text: message
      reminder.reminded = true
      reminder.save()
      done()
    agenda.schedule reminder.remindTime, reminder.id

    
Reminder.post 'save', (next) ->
  reminder = this
  

module.exports = mongoose.model 'Reminder', Reminder
