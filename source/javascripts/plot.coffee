window.totalPoints = 300
window.Data = new Array(totalPoints)
window.idx = 0


window.addToPlotData = (point) ->
  d = window.Data
  d[window.idx++] = [window.idx, point]
  window.idx = 0 if window.idx >= totalPoints

$ ->

  return
  data = []

  # We use an inline data source in the example, usually data would
  # be fetched from a server
  getRandomData = ->
    data = data.slice(1)  if data.length > 0

    # Do a random walk
    while data.length < totalPoints
      prev = (if data.length > 0 then data[data.length - 1] else 50)
      y = prev + Math.random() * 10 - 5
      if y < 0
        y = 0
      else y = 100  if y > 100
      data.push y

    # Zip the generated y values with the x values
    res = []
    i = 0

    while i < data.length
      res.push [i, data[i]]
      ++i
    res

  # Set up the control widget
  # Drawing is faster without shadows
  update = ->
    plot.setData [window.Data]

    # Since the axes don't change, we don't need to call plot.setupGrid()
    plot.draw()
    setTimeout update, updateInterval
  data = []
  totalPoints = 300
  updateInterval = 30
  $("#updateInterval").val(updateInterval).change ->
    v = $(this).val()
    if v and not isNaN(+v)
      updateInterval = +v
      if updateInterval < 1
        updateInterval = 1
      else updateInterval = 2000  if updateInterval > 2000
      $(this).val "" + updateInterval

  plot = $.plot("#placeholder", [getRandomData()],
    series:
      shadowSize: 0

    yaxis:
      min: 600
      max: 880
      logarithmicScale: no

    xaxis:
      show: false
  )
  update()