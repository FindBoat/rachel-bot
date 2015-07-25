mongoose = require 'mongoose'

ChatContext = new mongoose.Schema
  userId: mongoose.Schema.ObjectId

  chatId: type: String, unique: true
  # Possible values: WAIT_LOCATION, WAIT_EMAIL, WAIT_HRU, WAIT_CANCEL_REMINDER,
  # WAIT_FEEDBACK.
  status: type: String

  
module.exports = mongoose.model 'ChatContext', ChatContext
