class mk.m11s.tech.Clone

  constructor : (@parts, @numDelay) ->
    @view = new paper.Group()
    @view.transformContent = false

    @white = new paper.Color('white')
    @initColor = new paper.Color() #'#151515'
    @initColor.brightness = 0.1

    @view.visible = false

    @views = []
    # @views.push [] for i in [0...@numDelay]

    @offset = 0
    @strombo = false

    @colors = []
    for c in ['skin','cream','beige','red','lightRed']
      color = mk.Scene::settings.getPaperColor c
      @colors.push color

    @currColor = @colors.random()
    @colorInterval()

  setVisible : (@visible) ->
    @view.visible = false
    @view.removeChildren()
    @views = []

  update : ->
    parts = []
    for p in @parts
      p.setColor @currColor, false
      s = p.view.clone()
      if !@strombo
        p.setColor @initColor, false
      s.position.x += @offset
      s.remove()
      parts.push s

    @views.push parts

    @view.visible = true

    # console.log @numDelay
    if @views.length > @numDelay
      view = @views.shift()
    else
      return
      # id = Math.floor @views.length*0.5
      # view = @views[id]

    @view.removeChildren()
    for p in view
      @view.addChild p

    if @strombo
      for p in view
        for c in p.children
          c.fillColor = @white
    return

  colorInterval : =>
    @currColor = @colors.random()
    delayed rng('ctvl')*600+300, @colorInterval



class mk.m11s.tech.Clones

  constructor : (@parts) ->
    @view = new paper.Group()
    @view.transformContent = false
    @view.z = 0

    @visible = @view.visible = false

    @white = new paper.Color 'white'
    @initColor = @white.clone()
    @initColor.brightness = 0.5

    @clones = []
    numDelay = 10
    for i in [0...2]
      cl = new mk.m11s.tech.Clone @parts, numDelay
      cl.view.scale 0.8
      @view.addChild cl.view
      @clones.push cl
      numDelay += 20

    @strombo = false

  toggleStrombo : ->
    @strombo = !@strombo
    c.strombo = @strombo for c in @clones
    for p in @parts
      if @strombo
        p.setColor @white, false
      else p.setColor @initColor, false

  setVisible : (@visible) ->
    c.setVisible @visible for c in @clones
    @view.visible = @visible

  update : (dt) ->
    if !@visible then return
    @clones[0].offset = -200
    @clones[1].offset = 200
    c.update() for c in @clones