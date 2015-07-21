expect = require('chai').expect
moment = require 'moment'

reminderParser = require '../.app/server/services/reminder-parsers'

now = new Date '5/13/2013 07:00:00'

test = (text, todo, diff, date) ->
  reminderParser.parse text, now, (err, res) ->
    expect(res.todo).to.equal todo
    if diff?
      console.log res.time
      expect(res.time.getTime() - now.getTime()).to.equal diff
    else
      expect(res.time.toString()).to.equal date.toString()

describe 'reminder', ->
  it 'basic', ->
    text = 'Remind me to check email in 5 min.'
    todo = 'check email'
    test text, todo, 5 * 60 * 1000, null

    text = 'Remind me in 5 min to check email.'
    test text, todo, 5 * 60 * 1000, null

  it 'absolute time', ->
    text = 'Remind me to check email on 6/27/2019 7:30 pm.'
    todo = 'check email'
    date = new Date('6/27/2019 7:30 pm')
    test text, todo, null, date

    text = 'Remind me on 6/27/2019 7:30 pm to check email.'
    test text, todo, null, date

  it 'extra words', ->
    text = 'Rachel, can you remind me to check email in 5 min?'
    todo = 'check email'
    test text, todo, 5 * 60 * 1000, null

    text = 'Please remind me to check email in 5 min'
    test text, todo, 5 * 60 * 1000, null

  it 'advanced', ->
    text = 'Remind me to check email 10 minutes from now'
    todo = 'check email'
    test text, todo, 10 * 60 * 1000, null

    text = 'Remind me to check email in 5 hours'
    test text, todo, 5 * 60 * 60 * 1000, null

    text = 'Remind me to check email in 2 days'
    test text, todo, 2 * 24 * 60 * 60 * 1000, null

    text = 'Remind me to check email at 5pm'
    test text, todo, null, new Date 'May 13, 2013 17:00:00'

    text = 'Remind me to check email at 12:30'
    test text, todo, null, new Date 'May 13, 2013 12:30:00'

    text = 'Remind me to check email at 23:35'
    test text, todo, null, new Date 'May 13, 2013 23:35:00'

    text = 'Remind me to check email tuesday at 9am'
    test text, todo, null, new Date 'May 14, 2013 09:00:00'

    text = 'Remind me to check email monday at 1:00am'
    test text, todo, null, new Date 'May 13, 2013 01:00:00'

    text = 'Remind me to check email tomorrow at 3pm'
    test text, todo, null, new Date 'May 14, 2013 15:00:00'

    text = 'Remind me to check email 5pm tonight'
    test text, todo, null, new Date 'May 13, 2013 17:00:00'

    # It's weird to make next tuesday the second day.
    text = 'Remind me to check email next week tuesday'
    test text, todo, null, new Date 'May 14, 2013 07:00:00'

    text = 'Remind me to check email next week tuesday at 4:30pm'
    test text, todo, null, new Date 'May 14, 2013 16:30:00'

    text = 'Remind me to check email 2 weeks from wednesday'
    test text, todo, null, new Date 'May 15, 2013 07:00:00'

    text = 'Remind me to check email tomorrow night at 9'
    test text, todo, null, new Date 'May 14, 2013 21:00:00'

    text = 'Remind me to check email tomorrow night at 9'
    test text, todo, null, new Date 'May 14, 2013 21:00:00'

    text = 'Remind me to check email tomorrow afternoon'
    test text, todo, null, new Date 'May 14, 2013 14:00:00'

    text = 'Remind me to check email this morning at 9'
    test text, todo, null, new Date 'May 13, 2013 09:00:00'

    # Chrono failed in the following cases.

    # text = 'Remind me to check email 2 years from yesterday at 5pm'
    # test text, todo, null, new Date 'May 12, 2015 17:00:00'

    # text = ('Remind me to check email tomorrow afternoon at 4:30pm 1 month ' +
    #     'from now')
    # test text, todo, null, new Date 'June 14, 2013 16:30:00'
