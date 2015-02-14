root = exports ? this

class root.BugCanvas

  constructor: (@options) ->
    # options:
    # $target:          The jQuery Element that the canvas will be applied to
    #                   (required)
    @options = $.extend @options,
      imageAssets: [
        '/images/bug-body.png'
      ]

    # The array of all bugs
    @bugs = []

    # Other common variables
    @bugSize = 200
    @maxSpeed = new Victor(2, 2)
    @maxForce = new Victor(0.15, 0.15)

    # Wait for canvas library to load (if not yet loaded)
    if PIXI?
      @_init()
    else
      $.getScript '/scripts/pixi.js', @_init

  _init: =>
    # Load image assets
    @_loadAssets()
    @_addEventListeners()

  _loadAssets: =>

    loader = new PIXI.AssetLoader(@options.imageAssets)
    loader.onComplete = @_createScene
    loader.load()

  _addEventListeners: =>
    # Watch for window size to change
    $(window).on('resize', @_resize)
    window.onorientationchange = @_resize

    # Watch for mouse to move
    $(window).on('mousemove', @_updateMouseCoords)

  _createScene: =>
    @renderer = new PIXI.CanvasRenderer(null, null, { transparent: true })
    @options.$target.append(@renderer.view)
    @stage = new PIXI.Stage(@options.stageBgColor)
    @_resize()

    # Start animation cycle
    @animating = true
    @animationFrame = requestAnimationFrame(@_animate)


  _updateMouseCoords: (evt) =>
    @mouseX = evt.pageX
    @mouseY = evt.pageY

  _animate: =>
    if @animating
      @_updateItems()
      @renderer.render(@stage)
      requestAnimationFrame(@_animate)

  _updateItems: =>
    for bug in @bugs
      @_wander(bug)
      @_avoidBorders(bug)

      # Update Velocity
      bug.velocity = bug.velocity.add(bug.acceleration)

      # Limit Speed
      bug.velocity = @maxSpeed if bug.velocity.length() > @maxSpeed.length

      # Update Location
      bug.location = bug.location.add(bug.velocity)

      # Reset Acceleration
      bug.acceleration.multiply(new Victor(0, 0))

      # Update Position and Rotation
      bug.position.x = bug.location.x
      bug.position.y = bug.location.y
      bug.rotation = bug.velocity.angle()

  _wander: (bug) =>
    wanderR = 15                                                # Radius for our "wander circle"
    wanderD = 400                                               # Distance for our "wander circle"
    change = 0.3
    bug.wanderTheta += Math.random() * (change * 2) - change    # Randomly change wander theta

    # Now we have to calculate the new location to steer towards on the wander circle
    circleloc = bug.velocity.clone()                            # Start with velocity
    circleloc = circleloc.normalize()                           # Normalize to get heading
    circleloc = circleloc.multiply(Victor(wanderD, wanderD))    # Multiply by distance
    circleloc = circleloc.add(bug.location)                     # Make it relative to location
    
    h = bug.velocity.direction()                                # We need to know the heading to offset wanderTheta

    circleOffset = new Victor(wanderR * Math.cos(bug.wanderTheta + h), wanderR * Math.sin(bug.wanderTheta + h))
    target = circleloc.clone().add(circleOffset)

    @_seek(bug, target)

  _seek: (bug, target) =>
    desired = target
    desired = desired.subtract(bug.location)
    desired = desired.normalize()
    desired = desired.multiply(@maxSpeed)
    steer = desired.clone().subtract(bug.velocity)
    steer = @maxForce if steer.length() > @maxForce.length
    @_applyForce(bug, steer)

  _applyForce: (bug, force) =>
    bug.acceleration = bug.acceleration.add(force)

  _avoidBorders: (bug) =>
    bug.location.x = @renderer.width + @bugSize if (bug.location.x < -@bugSize) 
    bug.location.y = @renderer.height + @bugSize if (bug.location.y < -@bugSize) 
    bug.location.x = -@bugSize if (bug.location.x > @renderer.width + @bugSize) 
    bug.location.y = -@bugSize if (bug.location.y > @renderer.height + @bugSize) 

  _resize: =>
    @width = $(window).width()
    @height = $(window).height()
    @renderer.resize(@width, @height)

  destroy: =>
    # Halt animation frame cycle
    @animating = false

  addBug: (_id) =>
    bugTexture = PIXI.Texture.fromImage(@options.imageAssets[0])

    bugSprite = new PIXI.Sprite(bugTexture)

    bugSprite._id = _id

    bugSprite.anchor.x = 0.5
    bugSprite.anchor.y = 0.5

    bugSprite.scale.x = bugSprite.scale.y = 0.5

    bugSprite.blendMode = 2 # Multiply

    bugSprite.location = new Victor(Math.random() * @renderer.height, -@bugSize)
    bugSprite.velocity = new Victor(0, 0)
    bugSprite.acceleration = new Victor(0, 0)
    bugSprite.wanderTheta = 0
    bugSprite.rotation = Math.random() * 6

    # make the button interactive..    
    bugSprite.interactive = true
    
    # set the mouseover callback..
    bugSprite.mouseover = (data) =>
      bugSprite.alpha = 0.5
      Session.set('selected_bug', _id)
    
    # set the mouseout callback..
    bugSprite.mouseout = (data) =>
      bugSprite.alpha = 1
    
    bugSprite.click = bugSprite.tap = (data) =>
      Session.set('selected_bug', _id)

    @bugs.push(bugSprite)
    @stage.addChild(bugSprite)