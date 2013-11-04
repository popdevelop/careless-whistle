class window.NoteRecorder
  _updateCallbacks = []
  _idleCallbacks  = []
  _defaultOptions =
    tolerance: 10
    minDuration: 20  # Cycles
    idleTimeout: 40 # Cycles

  constructor: (audio, opts = {}) ->
    audio.onUpdate(@analyse)
    @options = _defaultOptions
    @options[key] = val for key, val of opts
    @lastNote = 0
    @pitchDuration = 0
    @reset()

  analyse: (audio) =>
    o = @options
    note = audio.centFromFrequency(audio.stats.maxBinFreq)
    if (note >= @lastNote - o.tolerance and note <= @lastNote + o.tolerance)
      @pitchDuration++
    else
      if @pitchDuration > o.minDuration
        @sequence.push @lastNote
        @idleDuration = 0
        fn() for fn in _updateCallbacks
      else
        @idleDuration++

      @lastNote = 0
      @pitchDuration = 0

    if @idleDuration > o.idleTimeout
      fn() for fn in _idleCallbacks
      @reset()

    @lastNote = note

  onIdle: (fn) -> _idleCallbacks.push fn
  onUpdate: (fn) -> _updateCallbacks.push fn

  sequenceDeltas: ->
    (el - @sequence[0]) for el, i in @sequence

  reset: ->
    @idleDuration = 0
    @sequence = []