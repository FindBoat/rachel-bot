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



maybeAskReivew = (chatId, user) ->
  d = new Date()
  d.setDate(d.getDate() - 1)
  if user.createdAt < d and not user.hasDone.hasAskedReview
    bot.sendMessage
      chat_id: chatId
      text: ("How do you like my service so far? I'll be really appreciated " +
          "if you could write a review for me at http://storebot.me/bot/rachel_bot.")
      disable_web_page_preview: true

    user.hasDone.hasAskedReview = true
    user.save()

# Create an Agenda after save.
Reminder.methods.saveWithAgenda = (user, next) ->
  reminder = this
  reminder.save (err, reminder) ->
    if err?
      next err, null
      return
      
    agenda.define reminder.id, (job, done) ->
      message = ("Hi #{user.firstName}, " +
          "you asked me to remind you to #{reminder.todo}." )
      bot.sendMessage
        chat_id: reminder.chatId
        text: message
      reminder.reminded = true
      reminder.save()

      setTimeout ->
        maybeAskReivew reminder.chatId, user
      , 3000
      
      done()
    agenda.schedule reminder.remindTime, reminder.id
    next null, reminder

Reminder.methods.removeWithAgenda = (next) ->
  reminder = this
  reminder.remove (err) ->
    if err?
      next err
      return

    agenda.cancel name: reminder.id, (err) ->
      if err?
        next err
        return

      next null

    
module.exports = mongoose.model 'Reminder', Reminder
