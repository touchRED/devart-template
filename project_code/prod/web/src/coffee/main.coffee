view     = null
scene    = null
skeleton = null
sync     = null
light    = null
playback = null
record   = null

accumulator = 0
currMetamorphoseId = 0
currentTime = 0
timestamp = 0
frameNum = 0


setupPlayback = (filename) ->
  setupApp()
  playback = new mk.playback.Playback skeleton, onPlaybackComplete
  playback.load filename, (seed, m11) ->
    setSeed new Date().getTime() #seed
    setMetamorphose 'birds'

setupLive = (m11) ->
  setupApp()
  sync = new mk.skeleton.SkeletonSync skeleton, 7000
  sync.connect true
  seed = new Date().getTime()
  setSeed seed
  setMetamorphose m11
  record = new mk.playback.Record()


# Setup 

setupApp = ->
  setupPaper()

  window.addEventListener 'resize', windowResized
  window.addEventListener 'focus', windowFocus
  window.addEventListener 'blur', windowLostFocus
  window.addEventListener 'keydown', onKeyDown
  window.addEventListener 'mousemove', onMouseMove

  setupSkeleton()

  # dmxLightAnimation()

setupPaper = ->
  canvas = window.canvas = document.getElementById 'paperjs-canvas'
  canvas.setAttribute 'data-paper-hidpi', ''
  canvas.setAttribute 'data-paper-resize', ''
  document.body.appendChild canvas

  paper.setup canvas

  view = new paper.Layer()
  view.pivot = new paper.Point 0,0
  view.transformContent = false
  
setupSkeleton = ->
  skeleton = new mk.skeleton.Skeleton window.debug
  skeleton.setDataRatio 640 / 480
  view.addChild(skeleton.view)

  windowResized()


# Global Setters

setNextMetamorphose = ->
  if(++currMetamorphoseId >= metamorphoses.length)
    currMetamorphoseId = 0
  m = metamorphoses[currMetamorphoseId]
  setMetamorphose m

setMetamorphose = (m) ->
  window.metamorphose = m
  if scene
    scene.setMetamorphose m
  else
    scene = new mk.Scene onSceneReady
    @setMetamorphose m

toggleDebug = () ->
  window.debug = !window.debug
  skeleton.setDebug window.debug
  skeleton.view.bringToFront()
  scene.setDebug window.debug

onSceneReady = () ->
  console.log 'onSceneReady'
  view.addChild scene.perso.view
  
  if window.debug
    scene.setDebug true

  if record
    record.begin 
      timestamp : window.seed
      m11  : window.metamorphose

  start()
  if playback
    goto 2900, false

start = () ->
  if !paper.view.onFrame
    paper.view.onFrame = onFrame
  scene.start()
  console.log '> started'

stop = () ->
  paper.view.onFrame = undefined  
  scene.stop()
  console.log '> stopped'

goto = (frame, bStop = false, dt = 1/50) ->
  if frame < frameNum
    console.log "Can't go backward yet.."
    return
  scene.music.stop()
  update dt for i in [frameNum...frame]
  scene.music.play()
  if bStop
    stop()

onPlaybackComplete = () ->
  # ...

# System Events

windowResized = (ev) ->
  v =
    width : window.innerWidth
    height : window.innerHeight
  view.scaling = v.height / viewport.height#* 0.85

  view.position.x = v.width * 0.5
  view.position.y = v.height * 0.5

windowFocus = (ev) ->
  start()

windowLostFocus = (ev) ->
  stop()

onKeyDown = (ev) ->
  switch ev.keyCode
    when 83 # 's'
      toggleDebug()
      # if record
      #   record.end()
    when 32 # spacebar
      setNextMetamorphose()

onMouseMove = (ev) ->
  window.mouse.x = ev.clientX
  window.mouse.y = ev.clientY

onFrame = (ev) ->
  if ev.delta < 0.5
    window.dt = ev.delta
  update window.dt

update = (deltaTime) ->

  deltaTime *= 1000

  if record
    record.update deltaTime
    if sync.hasNewData
      skeleton.setData sync.data
      record.addFrame sync.data
      sync.hasNewData = false

  dt = 1000 / 50
  accumulator += deltaTime
  while accumulator >= dt

    if playback
      playback.update dt
    
    currentTime += dt
    frameNum++
    # if frameNum is 500
    #   stop()
    window.currentTime = currentTime

    TWEEN.update currentTime
    skeleton.update dt*0.007
    scene.setPersoPose skeleton
    scene.update dt, currentTime
    accumulator -= dt

# MISCELLANEOUS

dmxLightAnimation = ->
  light = new ArtNetClient '192.168.0.2', 6454, ->
    i = 0
    speed = 0.05
    setInterval ->
      i += Math.PI / 2 * speed
      val = Math.floor( (1 + Math.sin(i)) * 127 )
      light.send([val])
    ,1000/30

setupPlayback '1401061237730_018304_birds'
# setupLive 'birds'
     