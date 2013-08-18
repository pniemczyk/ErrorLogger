class ErrorLoggerController
    config: 
        logger: null
        propagateErrors: false
        onErrorFn: null
        sendOnDomReady: true
        sendDelay: 2000
    setConfig: (config) ->
        return unless config?
        @config[prop] = config[prop] for prop of config when config.hasOwnProperty(prop)
    constructor: (config) -> 
        @setConfig(config)
        @init() if @config.logger?
                    
    init: -> 
        window.onerror = @errorHandler
        $(window).load(@afterDomReady) if @config.sendOnDomReady
        @initSending()
    initSending: =>
        run = ()=> 
            @send() unless @config.sendOnDomReady
            setTimeout(run
                       ,@config.sendDelay)
        
        setTimeout(run
                   ,@config.sendDelay)        
    send: ->
        if @config.logger.errorList.length > 0
            @config.logger.send()
            @config.logger.clear()
    afterDomReady: =>
        @send()
        @config.sendOnDomReady = false
    errorHandler: (msg, url, line) =>
        errorObj = {message:msg, url:url, line:line }
        @config.onError(errorObj) if @config.onError? && typeof @config.onError is 'function'
        @config.logger.push(errorObj)
        !@config.propagateErrors
        
class Logger
  errorList: []
  lastError: -> @errorList[@errorList.length - 1]
  browser: window.navigator.userAgent
  push: (errorObj) -> 
      @errorList.push errorObj
      @added()
  added: -> null
  clear: -> @errorList = []
  
class ConsoleLogger extends Logger
  added: -> console.log @lastError
      
class DebugLogger extends Logger
  constructor: (options={el:'', displayEach:false})->
    @el = options.el
    @displayEach = options.displayEach
  added: -> @display(@lastError()) if @displayEach
  send: -> (@display error for error in @errorList) unless @displayEach
  display: (error) ->
      $(@el).append("<p>message: #{error.message} <br />url: #{error.url}, lineNumber: #{error.line}<br /> browser: #{@browser}")

class NetLogger extends Logger
  constructor: (options={url:null, method:'POST'}) ->
    @url = options.url
    @method = options.method
  jsonToSend: ->
      objToSend =
          browser: @browser
          errors: @errorList
      JSON.stringify(objToSend)
  send: ->
      if (window.XMLHttpRequest)
          xhr = new XMLHttpRequest()
          xhr.open(@method, @url, true)
          xhr.setRequestHeader("Content-Type", "text/plain;charset=UTF-8")
          xhr.send(@jsonToSend())
       