emoji = require('node-emoji').emoji


confirm = (name) ->
  res = [
    "No problem #{name}!"
    "Sure thing!"
    "I'd love to #{name}!"
    "Roger that."
    "Ok!"
    "Sure!"
  ]
  r = Math.floor (Math.random() * res.length)
  return res[r]

random = (name) ->
  res = [
    ("I am currently out at a job interview and will reply to you " +
     "if I fail to get the position.")
    ("#{name}, I have a cell phone, but I will not be giving the number " +
     "out. If you can guess the number, however, I will take your call.")
    ("#{name}, I’m thinking about what you’ve just sent me. Please wait " +
     "for an hour for my response. LOL")
    "#{name}, I'm so tired and probably out-of-my-mind drunk."
    "I'm having a shower now, will reply you later."
  ]
  r = Math.floor (Math.random() * res.length)
  return res[r]

module.exports =
  confirm: confirm
  random: random
