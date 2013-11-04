class _Audio
  _audioContext = window.AudioContext or window.webkitAudioContext
  _startCallbacks = []
  _updateCallbacks = []
  _errorCallbacks = []
  _defaultOptions =
    alpha: 0.5
    sampleSize: 2048
    spectrumStart: 18
    spectrumRange: 38

  constructor: (opts = {})->
    @context = new _audioContext()
    @options = _defaultOptions
    @options[key] = val for key, val of opts

    @buffer = new Uint8Array( @options.sampleSize / 2 );
    @fft = new FFT(@options.sampleSize / 2, @context.sampleRate)
    @spectrum = (0 for i in [0..@options.spectrumRange])
    @stats = {}

  analyse: =>
    window.requestAnimationFrame(@analyse)
    @analyser.getByteTimeDomainData( @buffer )
    @fft.forward(@buffer)

    s = @stats
    s.maxBinFreq = 0
    s.maxBinVal = 0
    s.totalVal = 0
    opts = @options
    # Create filtered spectrum in range
    for i in [0..opts.spectrumRange]
      mag = @fft.spectrum[i + opts.spectrumStart]
      newBinVal = (1.0 - opts.alpha)* + mag*opts.alpha
      if newBinVal > s.maxBinVal
        s.maxBinFreq = @frequencyFromBin(i + opts.spectrumStart)
        s.maxBinVal = newBinVal
      s.totalVal += newBinVal
      @spectrum[i] = newBinVal

    fn(@) for fn in _updateCallbacks


  setupStream: (stream) =>
    @stream = @context.createMediaStreamSource(stream)
    @analyser = @context.createAnalyser();
    @analyser.fftSize = 2048;
    @stream.connect(@analyser);
    fn() for fn in _startCallbacks
    @analyse()

  onError: (fn) -> _errorCallbacks.push fn
  onStart: (fn) -> _startCallbacks.push fn
  onUpdate: (fn) -> _updateCallbacks.push fn

  startRecording: =>
    @getUserMedia({audio: true}, @setupStream)

  getUserMedia:(dictionary, callback) ->
    try
      navigator.getUserMedia =
        navigator.getUserMedia ||
        navigator.webkitGetUserMedia ||
        navigator.mozGetUserMedia
      navigator.getUserMedia(dictionary, callback, ->
        fn() for fn in _errorCallbacks
      )
    catch e
      @onError?('getUserMedia threw exception :' + e)

  centFromFrequency: (f = 0) ->
    return 0 if f is 0
    noteNum = 12 * (Math.log( f / 440 )/Math.log(2) );
    Math.round(noteNum*10) + 690;

  frequencyFromBin: (b) ->
    b * @context.sampleRate / @options.sampleSize


window.Audio = new _Audio