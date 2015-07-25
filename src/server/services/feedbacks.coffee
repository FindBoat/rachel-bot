mongoose = require 'mongoose'

Feedback = new mongoose.Schema
  userId: mongoose.Schema.ObjectId
  feedback: type: String
  createdAt: type: Date, default: Date.now

module.exports = mongoose.model 'Feedback', Feedback
