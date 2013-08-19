(($) ->
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

  errorLogger = (options) ->

    @version         = '1.0.0'
    @options         = {}

    selectLogger = =>
      if typeof @options.logger is 'string'
        switch @options.logger
          when 'debug' then return new DebugLogger(@options.debugLoggerOptions)
          when 'net' then return new NetLogger(@options.netLoggerOptions)
          else return new ConsoleLogger()
      else
        return @options.logger

    initSending = =>
      run = =>
        send() unless @options.sendOnDomReady
        setTimeout(run
                   ,@options.sendDelay)

      setTimeout(run
                 ,@options.sendDelay)
    send = =>
      if @logger.errorList.length > 0
        @options.beforeSendFn() if @options.beforeSendFn? && typeof @options.beforeSendFn is 'function'
        @logger.send()
        @logger.clear()
        @options.afterSendFn() if @options.afterSendFn? && typeof @options.afterSendFn is 'function'

    afterDomReady = =>
      send()
      @options.sendOnDomReady = false

    errorHandler = (msg, url, line) =>
      errorObj = {message:msg, url:url, line:line }
      @logger.push(errorObj)
      @options.onErrorFn(errorObj) if @options.onErrorFn? && typeof @options.onErrorFn is 'function'
      !@options.propagateErrors

    @init = (options) =>
      @options       = $.extend({}, $.errorLogger.defaultOptions, options)
      @logger        = selectLogger()
      window.onerror = errorHandler
      $(window).load(=> afterDomReady()) if @options.sendOnDomReady
      initSending() unless @options.sendOnlyOnDomReady

    @init(options)

  $.errorLogger = (options) -> new errorLogger(options)

  $.errorLogger.defaultOptions =
    logger: null
    propagateErrors: false
    onErrorFn: null
    beforeSendFn: null
    afterSendFn: null
    sendOnDomReady: true
    sendOnlyOnDomReady: false
    sendDelay: 2000
    debugLoggerOptions:
      el: '#onErrors'
      displayEach: true
    netLoggerOptions:
      method: 'POST'
      url:  '/errorlogger'
) jQuery