Template.bug.helpers

  # foo: ->
  #   return "You're in the bug view!"

Template.bug.rendered = ->
  ww = $(window).width()
  wh = $(window).height()

  @bug =
    $el: this.$(this.firstNode)
    maxSpeed: 3
    maxForce: 0.15
    location: new Victor(ww * Math.random(), wh * Math.random())
    target: new Victor(ww * Math.random(), wh * Math.random())
    velocity: new Victor(0.5, 0.5)
    acceleration: new Victor(0, 0)
    rotation: Math.random() * 360
    animationFrame: new AnimationFrame()

    applyForce: (force) =>
      @bug.acceleration = @bug.acceleration.add(force)

    seek: =>
      desired = @bug.target.subtract(@bug.location)
      # desired = desired.multiply(@bug.maxSpeed)
      # steer = desired.subtract(@bug.velocity)
      # steer = steer.limit(@bug.maxForce)
      #@bug.applyForce(steer)

    update: =>
      @bug.animationFrame.request =>
        @bug.seek()

        # Update velocity
        @bug.velocity = @bug.velocity.add(@bug.acceleration)

        # Limit Speed
        # @bug.velocity = @bug.velocity.limit(@bug.maxSpeed)

        # Update Location
        @bug.location = @bug.location.add(@bug.velocity)

        # Reset acceleration
        # @bug.acceleration = @bug.acceleration.multiply(0)

        @bug.$el[0].style.transform = "translate3d(#{@bug.location.x}px, #{@bug.location.y}px, 0) rotate(#{@bug.rotation}deg)"
        @bug.update()

  @bug.update()
  
Template.bug.events
  # 'click .foo': (evt) ->
  #    Event Callback
