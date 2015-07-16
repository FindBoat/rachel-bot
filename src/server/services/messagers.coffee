moment = require 'moment'

bot = require './bots'
Reminder = require './reminders'
User = require './users'


createUserIfNotPresent = (message, cb) ->
  User.findOne telegramUsername: message.chat.username, (err, user) ->
    if err?
      console.log err
      return

    if user?
      console.log "User @#{message.chat.username} exists in system"
      cb user
      return

    # Create new user.
    console.log "Creating new user: @#{message.chat.username}"
    user = new User
      firstName: message.chat.first_name
      lastName: message.chat.last_name
      telegramUsername: message.chat.username
    user.save (err) ->
      if err? then console.log err
      cb user

handleMessage = (message, user) ->
  bot.sendMessage
    chat_id: message.chat.id
    text: "Hi #{user.firstName}"

  if message.text is 'Remind me to poo in 5 seconds'
    time = moment().add 5, 'seconds'
    console.log time.toDate()
    reminder = new Reminder
      userId: user._id
      message: 'Remind me to poo in 5 seconds'
      remindTime: time.toDate()
      todo: 'poo'
      chatId: message.chat.id
    reminder.saveWithAgenda user


module.exports =
  handle: (message) ->
    createUserIfNotPresent message, (user) ->
      handleMessage message, user
