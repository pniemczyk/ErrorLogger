lazyloader = new window.ImageLazyLoad(loadingAtTopToEnd: false)

loadedImages = 0
afterImageLoaded = ($el, src) ->
  now = new Date()
  date = "#{now.getHours()} : #{now.getMinutes()} : #{now.getSeconds()} : #{now.getMilliseconds()}"
  date = new Date().toString("D")
  loadedImages = loadedImages + 1
  $('#loaded').html(loadedImages)
  $('.log').append("<p>#{loadedImages}&nbsp|&nbsp#{src}</p>")
  $el.attr('src', src)
  $el.css("opacity", 1)

lazyload = new window.ImageLazyLoad(afterImageLoaded: afterImageLoaded)
$('#version').html(lazyload.version)
$('#refresh').click( (e) -> 
  e.preventDefault()
  document.location.reload(true)
)

$('#unbindEvents').click( (e) -> 
  e.preventDefault()
  lazyload.unbindEvents()
)

$('#bindEvents').click( (e) -> 
  e.preventDefault()
  lazyload.bindEvents()
)

$('#loadAll').click( (e) -> 
  e.preventDefault()
  lazyload.loadAll()
)
