moment = require 'moment'

ChatContext = require './chat-context'
Feedback = require './feedbacks'
Reminder = require './reminders'
User = require './users'
bot = require './bots'
generalParser = require './general-parsers'
locationParser = require './location-parsers'
reminderParser = require './reminder-parsers'
tzExtractor = require './tz-extractors'
utils = require './utils'


createUserIfNotPresent = (message, next) ->
  User.findOne telegramUserId: message.from.id, (err, user) ->
    if err?
      console.log err
      return

    if user?
      console.log "User #{message.from.id} @#{message.from.username} exists in system"
      next user
      return

    # Create new user.
    console.log "Creating new user: #{message.from.id} @#{message.from.username}"
    user = new User
      firstName: message.from.first_name
      lastName: message.from.last_name
      telegramUsername: message.from.username
      telegramUserId: message.from.id
    user.save (err) ->
      if err?
        console.log err
        return
      next user

createChatContextIfNotPresent = (message, user, next) ->
  ChatContext.findOne chatId: message.chat.id, (err, chatContext) ->
    if err?
      console.log err
      return

    if chatContext?
      console.log "Chat Id #{message.chat.id} exists in system"
      next chatContext
      return

    # Create ChatContext.
    console.log "Creating new chat context: #{message.chat.id}"
    chatContext = new ChatContext
      userId: user._id
      chatId: message.chat.id
    chatContext.save (err) ->
      if err?
        console.log err
        return
      next chatContext

waitAndParseLocation = (message, user, chatContext) ->
  locationParser.parse message, (err, location) ->
    if err?
      console.log err
      bot.sendMessage
        chat_id: message.chat.id
        text: ("Sorry, I can't understand the location you sent.\n\n Can " +
            "you tap the paperclip on the bottom :point_down:, tap " +
            "Location and then tap Send My Current Location.\nOr send your " +
            "city, state and country like \"Palo Alto, CA, US\".")
      return
    console.log "Parsed location: #{JSON.stringify(location)}"

    tzExtractor.extractTimeZone location.lat, location.lng, (err, tz) ->
      if err?
        console.log err
        return

      console.log "Parsed timezone: #{JSON.stringify(tz)}"
      user.location = location
      user.timezone = tz
      user.save (err) -> if err? then console.log err
      chatContext.status = null
      chatContext.save (err) -> if err? then console.log err

      bot.sendMessage
        chat_id: message.chat.id
        text: ("Good job! Your location and timezone is set. Anything you " +
            "want me to remind you? Here are examples that might be " +
            "helpful:\n\n" +
            "\"Please remind me in 1 hour to check my email.\"\n" +
            "\"Rachel, can you remind me to check my email next week?\"\n" +
            "\"Remind me tomorrow noon to have lunch with Mark.\"\n")

askLocation = (message, user, chatContext) ->
  bot.sendMessage
    chat_id: message.chat.id
    text: ("Hi #{user.firstName}, I need to know your location to set up " +
        "the timezone for you.\n\nPlease tap the paperclip on the " +
        "bottom :point_down:, tap Location and then tap Send My " +
        "Current Location.\nOr you can just send your city, state " +
        "and country like \"Palo Alto, CA, US\".")
  chatContext.status = 'WAIT_LOCATION'
  chatContext.save (err) -> if err? then console.log err

sendGreeting = (message, user, chatContext) ->
  if user.location.lat?
    bot.sendMessage
      chat_id: message.chat.id
      text: ("Hi #{user.firstName},\n\nI'm your assistant Rachel. " +
          "I can remind you with whatever you want in anytime. Just " +
          "tell me something like \"Remind me to clear home tomorrow " +
          "at noon\" and I'll set up a reminder for you.")
  else
    bot.sendMessage
      chat_id: message.chat.id
      text: ("Hi #{user.firstName},\n\nI'm your assistant Rachel. " +
          "I can remind you with whatever you want in anytime.\n\n" +
          "Now I need to know your location to set up " +
          "the timezone for you.\n\nPlease tap the paperclip on the " +
          "bottom :point_down:, tap Location and then tap Send My " +
          "Current Location.\nOr you can just send your city, state " +
          "and country like \"Palo Alto, CA, US\".")
    chatContext.status = 'WAIT_LOCATION'
    chatContext.save (err) -> if err? then console.log err

sendHelp = (message) ->
  bot.sendMessage
    chat_id: message.chat.id
    text: ("I'm your assistant Rachel. " +
        "I can remind you with whatever you want in anytime. Just " +
        "tell me something like \"Remind me to clear home tomorrow " +
        "at noon\" and I'll set up a reminder for you.\n\n" +
        "Here are examples that I can better understand:\n" +
        "\"Please remind me in 1 hour to check my email.\"\n" +
        "\"Rachel, can you remind me to check my email next week?\"\n" +
        "\"Remind me tomorrow noon to have lunch with Mark.\"\n\n" +
        "You can also send /feedback to tell me your feedback.")

cancelReminder = (message, user) ->
  Reminder.findOne userId: user._id, null, sort: {createAt: -1}, (err, reminder) ->
    reminder.removeWithAgenda (err) -> if err? then console.log err
    bot.sendMessage
      chat_id: message.chat.id
      text: "I've canceled this reminder."

sendFeedback = (message, user, chatContext) ->
  bot.sendMessage
    chat_id: message.chat.id
    text: ("#{user.firstName}, please tell me your feedback, I really " +
        "appreciate it!\n(Reply \"cancel\" to cancel this.)")
  
  chatContext.status = 'WAIT_FEEDBACK'
  chatContext.save (err) -> if err? then console.log err

maybeSaveFeedback = (message, user, chatContext) ->
  chatContext.status = null
  chatContext.save (err) -> if err? then console.log err

  if message.text.toLowerCase() is 'cancel'
    bot.sendMessage
      chat_id: message.chat.id
      text: "Fine. So what can I do for you #{user.firstName}?"
  else
    feedback = new Feedback
      userId: user._id
      feedback: message.text
    feedback.save (err) -> if err? then console.log err
    bot.sendMessage
      chat_id: message.chat.id
      text: "Thank you so much for your feedback #{user.firstName}!"
    


handleMessage = (message, user, chatContext) ->
  # Greeting.
  if message.text is '/start'
    sendGreeting message, user, chatContext
    return
  if message.text is '/help'
    sendHelp message
    return
  if message.text is '/feedback'
    sendFeedback message, user, chatContext
    return

  # Check answer by chatContext.status.
  switch chatContext.status
    when 'WAIT_LOCATION'
      waitAndParseLocation message, user, chatContext
      return
    when 'WAIT_HRU'
      bot.sendMessage
        chat_id: message.chat.id
        text: "So what can I do for you #{user.firstName}?"
      chatContext.status = null
      chatContext.save (err) -> if err? then console.log err
      return
    when 'WAIT_CANCEL_REMINDER'
      chatContext.status = null
      chatContext.save (err) -> if err? then console.log err
      if message.text.toLowerCase() is 'cancel'
        cancelReminder message, user
        return
    when 'WAIT_FEEDBACK'
      maybeSaveFeedback message, user, chatContext
      return

  # Check location.
  if not chatContext.status? and not user.location.lat?
    askLocation message, user, chatContext
    return

  if not message?.text? then return

  # Normalize.
  normalizedText = message.text
  normalizedText = normalizedText.replace /// ^[\W_]+ ///, ''
  normalizedText = normalizedText.replace /// [\W_]+$ ///, ''
  normalizedText = normalizedText.toLowerCase().replace /// \s+ ///, ' '

  # Reminder mode.
  if normalizedText.indexOf('remind') isnt -1
    console.log 'Reminder mode'
    if user.timezone?.dstOffset?
      offset = user.timezone.dstOffset + user.timezone.rawOffset
    else
      offset = 0

    offsetDate = moment().add(offset, 'seconds').toDate()
    reminderParser.parse normalizedText, offsetDate, (err, res) ->
      if err?
        bot.sendMessage
          chat_id: message.chat.id
          text: ("#{user.firstName}, I'm not sure what you mean. " +
              "Here are examples that I can better understand:\n " +
              "\"Please remind me in 1 hour to check my email.\"\n" +
              "\"Rachel, can you remind me to check my email next week?\"\n" +
              "\"Remind me tomorrow noon to have lunch with Mark.\"\n")
        return

      displayTime = moment(res.time).format 'M/D/YYYY hh:mm:ss a'
      res.time = moment(res.time).add(-offset, 'seconds').toDate()
      console.log "ReminderParser returns: #{JSON.stringify(res)}"

      reminder = new Reminder
        userId: user._id
        message: message.text
        remindTime: res.time
        todo: res.todo
        chatId: message.chat.id
      reminder.saveWithAgenda user, (err) -> if err? then console.log err

      confirm = utils.confirm user.firstName
      bot.sendMessage
        chat_id: message.chat.id
        text: ("#{confirm} I'll remind you to #{res.todo} on #{displayTime}.\n" +
            "(Reply \"cancel\" to remove this reminder.)")

      chatContext.status = 'WAIT_CANCEL_REMINDER'
      chatContext.save (err) -> if err? then console.log err

  # General mode.
  else
    console.log 'General mode'
    generalParser.parse normalizedText, user, (err, res) ->
      if err?
        console.log err
        return
      if res?
        bot.sendMessage
          chat_id: message.chat.id
          text: res.answer
        if res.id is 'hru'
          chatContext.status = 'WAIT_HRU'
          chatContext.save (err) -> if err? then console.log err
      else
        bot.sendMessage
          chat_id: message.chat.id
          text: ("I'm sorry #{user.firstName}, I'm having some trouble " +
              "understanding what you mean. Can you explain again?\n\n" +
              "Send /help to ask for more info or /feedback to tell me " +
              "your feedback.")

  return


module.exports =
  handle: (message) ->
    createUserIfNotPresent message, (user) ->
      createChatContextIfNotPresent message, user, (chatContext) ->
        handleMessage message, user, chatContext
