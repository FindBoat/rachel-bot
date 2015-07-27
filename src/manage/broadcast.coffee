inquirer = require 'inquirer'
mongoose = require 'mongoose'

User = require '../server/services/users'
bot = require '../server/services/bots'
config = require '../server/config/config'


db = mongoose.connect config.MONGODB_URI


broadcast = ->
  questions = [
    {
      type: 'input'
      name: 'message'
      message: 'broadcast message'
    }
  ]

  inquirer.prompt questions, (answers) ->
    User.find {}, (err, users) ->
      if err?
        console.log err
      else
        # User userId as chatId.
        for user in users
          message = answers.message.replace '#{name}', user.firstName
          bot.sendMessage
            chat_id: user.telegramUserId
            text: message

      db.disconnect()


module.exports =
  broadcast: broadcast
