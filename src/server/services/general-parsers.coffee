mappings = (name) ->
  [
    {
      id: 'hi'
      regex: /// (^hi$)|(^hi\s\S+) ///
      answers: ["Hi #{name}, what can I do for you?"]
    }
    {
      id: 'hru'
      regex: /// (how\sare\syou)|(how's\sit\sgoin)|(what's\sup) ///
      answers: [
        "I am better than heaven today!, thank you #{name}. How about you?"
        "Cool as a cucumber! How about you #{name}?"
        "I'd be better if I won the lottery. And you?"
        "I can't complain... I've tried, but no one listens."
        "Blood pressure 120/80, respiration 16, CBC and Chem Panels normal."
        "I am feeling happier than ever!! And you?"
      ]
    }
    {
      id: 'thank'
      regex: /// (\bthank)|(\bthx\b) ///
      answers: [
        "You're very welcome #{name}!"
        "No problem #{name}!"
        "You're welcome #{name}!"
      ]
    }
    {
      id: 'sorry'
      regex: /// \bsorry\b ///
      answers: [
        "Please, no apology needed. I only exist to serve you #{name}."
      ]
    }
    {
      id: 'wru'
      regex: /// who\sare\syou ///
      answers: [
        "How could you forget about me. I'm your assistant Rachel."
      ]
    }
    {
      id: 'iloveyou'
      regex: /// i\slove\syou ///
      answers: [
        "Rachel also loves you!"
      ]
    }
    
  ]


parse = (text, user, next) ->
  for rule in mappings user.firstName
    if rule.regex.test text
      r = Math.floor (Math.random() * rule.answers.length)
      next null, {id: rule.id, answer: rule.answers[r]}
      return

  next null, null


module.exports =
  parse: parse
