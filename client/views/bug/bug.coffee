Template.bug.helpers

  # foo: ->
  #   return "You're in the bug view!"

Template.bug.rendered = ->
  ww = $(window).width()
  wh = $(window).height()
  bugSize = 100
  maxSpeed = new Victor(2, 2)
  maxForce = new Victor(0.15, 0.15)

  @bug =
    $el: this.$(this.firstNode)
    location: new Victor(Math.random() * ww, -bugSize)
    velocity: new Victor(0, 0)
    acceleration: new Victor(0, 0)
    wanderTheta: 0
    rotation: Math.random() * 360
    animationFrame: new AnimationFrame()

    update: =>
      @bug.animationFrame.request =>
        @bug.wander()
        @bug.avoidBorders()

        # Update Velocity
        @bug.velocity = @bug.velocity.add(@bug.acceleration)

        # Limit Speed
        @bug.velocity = maxSpeed if @bug.velocity.length() > maxSpeed.length

        # Update Location
        @bug.location = @bug.location.add(@bug.velocity)

        # Reset Acceleration
        @bug.acceleration.multiply(new Victor(0, 0))

        # Set rotation
        rotation = @bug.velocity.angleDeg() + 90

        @bug.$el[0].style.transform = "translate3d(#{@bug.location.x}px, #{@bug.location.y}px, 0) rotate(#{rotation}deg)"
        
        @bug.update()

    wander: =>
      wanderR = 25                                                  # Radius for our "wander circle"
      wanderD = 400                                                  # Distance for our "wander circle"
      change = 0.3
      @bug.wanderTheta += Math.random() * (change * 2) - change     # Randomly change wander theta

      # Now we have to calculate the new location to steer towards on the wander circle
      circleloc = @bug.velocity.clone()                                     # Start with velocity
      circleloc = circleloc.normalize()                             # Normalize to get heading
      circleloc = circleloc.multiply(Victor(wanderD, wanderD))                       # Multiply by distance
      circleloc = circleloc.add(@bug.location)                      # Make it relative to location
      
      h = @bug.velocity.direction()                                 # We need to know the heading to offset wanderTheta

      circleOffset = new Victor(wanderR * Math.cos(@bug.wanderTheta + h), wanderR * Math.sin(@bug.wanderTheta + h))
      target = circleloc.clone().add(circleOffset)

      @bug.seek(target)

    seek: (target) =>
      desired = target
      desired = desired.subtract(@bug.location)
      desired = desired.normalize()
      desired = desired.multiply(maxSpeed)
      steer = desired.clone().subtract(@bug.velocity)
      steer = maxForce if steer.length() > maxForce.length
      @bug.applyForce(steer)

    applyForce: (force) =>
      @bug.acceleration = @bug.acceleration.add(force)

    avoidBorders: =>
      @bug.location.x = ww + bugSize if (@bug.location.x < -bugSize) 
      @bug.location.y = wh + bugSize if (@bug.location.y < -bugSize) 
      @bug.location.x = -bugSize if (@bug.location.x > ww + bugSize) 
      @bug.location.y = -bugSize if (@bug.location.y > wh + bugSize) 

  @bug.update()
  
Template.bug.events
  # 'click .foo': (evt) ->
  #    Event Callback
