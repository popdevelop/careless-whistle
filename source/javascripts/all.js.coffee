#= require jquery/jquery
#= require flot/jquery.flot
#= require fft
#= require audio
#= require noterecorder
# require pitch


alert('Sorry, this login method only works in Chrome') unless window.chrome?

$(Audio.startRecording);

window.Users = [
  {
    name: 'Sebastian Wallin'
    image: 'https://secure.gravatar.com/avatar/46ab5c60ced85b09c35fd31a510206ef?s=192'
    sequence: [0, -40, -26, -85]
  }
  {
    name: 'Johan Brissmyr'
    image: 'http://www.gravatar.com/avatar/6b7b3a9f9d1c63a344cfc1d8ebb02981?s=192'
    sequence: [0, 20, 40]
  }
]

arrayEquals = (arr, arr2, tolerance = 15) ->
  return false if arr.length isnt arr2.length
  for el, i in arr2
    if el < (arr[i] - tolerance) or
    el > (arr[i] + tolerance)
      return false
  return true

outClass = 'pt-page-rotateBottomSideFirst'
inClass = 'pt-page-moveFromBottom pt-page-delay200 pt-page-ontop'
currentClass = 'pt-page-current'

LOGGED_IN = false
setLoginState = (user) ->
  return if LOGGED_IN is !!user
  LOGGED_IN = !!user
  $el = $('#pt-main')
  cls = if !user then '.login' else '.logout'
  currPage = $el.find('.' + currentClass).addClass(outClass)
  nextPage = $el.find(cls).addClass(inClass).addClass(currentClass)

  setTimeout ->
    currPage.removeClass(currentClass).removeClass(outClass)
    nextPage.removeClass(inClass)
  , 800
  $el.find('#name').text(user?.name)
  $el.find('#avatar').attr('src', user?.image or '')
  return

setPasswordField = (sequence) ->
  html = ("<li>&#9679;</li>" for s in sequence).join('')
  $('#password').html(html)


currentSequence = []
window.Authentication =
  setPassword: (sequence) ->
    currentSequence = sequence
    setPasswordField(sequence)
  login: (sequence) ->
    Authentication.setPassword(sequence) if sequence
    for user in Users
      setLoginState(user) if arrayEquals(currentSequence, user.sequence)
    return
  logout: ->
    setLoginState(null)
    return

# Setup canvas
canvas = document.getElementById('fft');
ctx = canvas.getContext('2d');
ctx.fillStyle = "rgba(0, 0, 0, 0.2)";
cHeight = canvas.height
cWidth = canvas.width


# Setup behaviour
Audio.onStart ->
  $('.trigger-pulse').addClass('pulsate')

Audio.onError -> alert("There was a problem accessing the audio.\nPlease check permissions.")

Audio.onUpdate ->
  spacing = cWidth / Audio.options.spectrumRange
  ctx.clearRect(0, 0, cWidth, cHeight);
  for val, i in Audio.spectrum
    ctx.fillRect(i * spacing, cHeight, spacing / 1.5, -val*200)

nr = new NoteRecorder(Audio)

nr.onUpdate ->
  Authentication.setPassword(nr.sequenceDeltas(nr.sequence))

nr.onIdle ->
  Authentication.login()
  Authentication.setPassword([])
