return global['caboose-mailer'] if global['caboose-mailer']?

caboose = Caboose.exports
util = Caboose.util
logger = Caboose.logger

nodemailer = require 'nodemailer'

mailer = module.exports =
  'caboose-plugin': {
    install: (util, logger) ->
      util.mkdir(Caboose.path.app.join('mailers'))
      util.create_file(
        Caboose.path.config.join('caboose-mailer.json'),
        JSON.stringify({
          service: ''
          auth:
            user: ''
            pass: ''
        }, null, 2)
      )

    initialize: ->
      if Caboose?
        Caboose.path.mailers = Caboose.path.app.join('mailers')
        
        exports.register 'mailer', {
          get: (parsed_name) ->
            return null if parsed_name[parsed_name.length - 1] isnt 'mailer'
            name = parsed_name.join('_')
            try
              files = Caboose.path.mailers.readdir_sync()
              mailer_file = files.filter((f) -> f.basename is name)
              mailer_file = if mailer_file.length > 0 then mailer_file[0] else null
              return null unless mailer_file?
              return {file: mailer_file, object: ControllerCompiler.compile(mailer_file)} if mailer_file.extension is 'coffee'
              {file: mailer_file, object: mailer_file.require()}
            catch e
              console.error e.stack
        }
        
        if Caboose?.app?.config?['caboose-mailer']?
          mailer.configure(Caboose.app.config['caboose-mailer'])
  }
  
  configure: (opts) ->
    

module.exports = global['caboose-mailer'] = mailer
