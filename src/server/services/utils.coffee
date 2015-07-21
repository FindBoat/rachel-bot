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

module.exports =
  confirm: confirm
