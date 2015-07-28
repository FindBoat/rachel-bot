# Sets application config parameters depending on `env` name
env = process.env.NODE_ENV or 'dev'
console.log "Set app environment: #{env}"

switch(env)
  when 'dev'
    exports.DEBUG_LOG = true
    exports.DEBUG_WARN = true
    exports.DEBUG_ERROR = true
    exports.DEBUG_CLIENT = true

    exports.MONGODB_URI = 'mongodb://localhost:27017/rachel'
    exports.TELEGRAM_TOKEN = '119032707:AAHbZyi4mXH6GtAP1_vpNxv_KktPEDdFEgU'

  when 'prod'
    exports.DEBUG_LOG = false
    exports.DEBUG_WARN = false
    exports.DEBUG_ERROR = true
    exports.DEBUG_CLIENT = false

    exports.MONGODB_URI = process.env.MONGOLAB_URI
    exports.TELEGRAM_TOKEN = '112582980:AAEQILFiw749CX7mg7ULhww_rvQwuax8pXI'

  else
    console.log "Environment #{env} not found"
