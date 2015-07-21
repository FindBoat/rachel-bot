mongoose = require 'mongoose'

User = new mongoose.Schema
  firstName: type: String
  lastName: type: String
  telegramUsername: type: String
  email: type: String, lowercase: true
  createdAt: type: Date, default: Date.now
  location:
    lat: type: Number
    lng: type: Number
  timezone:
    dstOffset: type: Number
    rawOffset: type: Number


module.exports = mongoose.model 'User', User  
