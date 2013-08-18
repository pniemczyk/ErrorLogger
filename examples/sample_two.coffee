refreshErrorCounter = => $('#errorCount').html(window.errorLogger.logger.errorList.length)

options =
    logger: 'debug'
    onErrorFn: refreshErrorCounter
    afterSendFn: refreshErrorCounter   
    sendOnDomReady: true
    sendDelay: 2000
    debugLoggerOptions:
      el: '#onErrors'
      displayEach: false

window.errorLogger = new $.errorLogger(options)

$('#version').html(window.errorLogger.version)

$('#throwError').click( (e)-> 
	e.preventDefault()
	$.browser.version 
	)

$('#refresh').click( (e)-> 
  e.preventDefault()
  document.location.reload(true)
  )

