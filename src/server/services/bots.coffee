Bot = require 'node-telegram-bot'

config = require '../config/config'


bot = new Bot
  token: config.TELEGRAM_TOKEN

module.exports = bot
