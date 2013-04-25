# Mouser v0.0.2
#
# Mouser is a class used to imitate a pointer/floating object on the user's
# screen. It aids the designer in creating an interactive tour by providing
# helpers for moving the pointer around the screen using element names, raw
# coordinates, or offset() objects
#
# Animations are done using CSS animations, preferentially, though a Modernizr
# fallback to a JS movement is planned.
#
# Dependencies:
# jQuery 1.8+ (http://jquery.com/)
# jQuery Transit v0.9.9 (http://ricostacruz.com/jquery.transit/)
# Bootstrap Tooltip and Popovers (only when using tooltips/annotations) (http://twitter.github.io/bootstrap/)
(($, window, document) ->
  "use strict"
  defaults =
    ###*
    The content to insert into the document as a Mouser object
    @property content
    @type String
    @default "<div class='mouser-container'><span class='pulsar'></span><div class='mouser-pointer'></div></div>"
    ###
    content: "<div class='mouser-container'><span class='pulsar'></span><div class='mouser-pointer'></div></div>"

  class Mouser
    ##################
    # Initialization #
    ##################
    ###*
    @method constructor
    @param {Object} args the initialization arguments
    @option {String or jQuery} content the Mouser's body as either HTML or a jQuery object
    @option {String} optional id the ID to identify this Mouser
    ###
    constructor: (args) ->
      args = $.extend {}, defaults, args
      @content = args.content
      @id = args.id || @generateGUID()

      do @findOrCreateElement
      do @setMouserId
      do @bindClickHandlers

    ###*
    Generate a GUID for this mouser if not supplied an ID
    ###
    generateGUID: ->
      'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
          r = Math.random()*16|0
          v = (if c == 'x'
            r
          else
            (r&0x3|0x8)
          )
          v.toString(16)

    ###*
    Find or create the mouser content
    ###
    findOrCreateElement: ->
      if typeof @content == "string"
        $el = $('#'+@id)
        if $el.length > 0
          @element = $el
        else
          @element = @addElementToBody()
      else
        @element = $ @content

    ###*
    Adds Mouser content to the body
    ###
    addElementToBody: ->
      if $('body').length == 0
        # If the body isn't ready yet, then set a timeout to check until it is
        setTimeout @addElementToBody, 100
      else
        @element_cache = $(@content)
                          .appendTo('body')

    ###*
    Sets the data-mouser-id attribute on the element
    ###
    setMouserId: ->
      @element
        .attr('data-mouser-id', @id)
      @element.mouser = this
      if @element[0]?
        @element[0].mouser = this


    ###*
    Listen for click events on the Mouser
    ###
    bindClickHandlers: ->
      @element
        .off('click.passthrough')
        .on 'click.passthrough', @passClick

    ###*
    Pass clicks on the mousers through to what's below them
    ###
    passClick: (evt) =>
      @element.hide()
      el = document.elementFromPoint(evt.clientX, evt.clientY)
      $(el).click()
      @element.show()

    ###########
    # Helpers #
    ###########
    ###
    Reset this Mouser:
    * Clear the queue
    * Eliminate any popovers
    * Cleanup any handlers created
    * Reset state
    ###
    reset: ->
      @clearQueue()
      @element.popover('destroy')
      if @timeout?
        clearInterval @timeout
      @resume()
      $(document).off '.'+@id
      @pulsate(false)
      return this

    ###*
    Adjust coordinates to center Mouser over the target
    @param {Object} the coordinates object
    ###
    center: (target) ->
      offset = (@element.outerWidth()/2)
      target.left -= offset if typeof target.left is 'number'
      target.top -= offset if typeof target.top is 'number'
      return target

    ###*
    Check if this Mouser has queued movements
    ###
    hasQueued: ->
      @element.queue().length > 0

    ###*
    Clear this mouser's queue
    ###
    clearQueue: ->
      @element.queue([])

    ###*
    Make this Mouser visible
    @param {Boolean} jq return a jQuery object
    ###
    fadeIn: (jq) ->
      @runner =>
        @element.addClass 'visible'
      if jq?
        return @element
      else
        return this

    ###*
    Make this Mouser invisible
    @param {Boolean} jq return a jQuery object
    ###
    fadeOut: (jq) ->
      @runner =>
        @element
          .removeClass('visible')
          .popover('destroy')
      if jq?
        return @element
      else
        return this

    ###*
    Alias for fadeIn
    @param {Boolean} jq return a jQuery object
    ###
    show: (jq) ->
      @fadeIn()

    ###*
    Alias for fadeOut
    @param {Boolean} jq return a jQuery object
    ###
    hide: (jq) ->
      @fadeOut(jq)

    ###*
    Pause execution of this Mouser
    ###
    pause: ->
      @element.data('paused', true)

    ###*
    Resume execution of this Mouser
    ###
    resume: ->
      @element.data('paused', false)

    ###*
    Check if this Mouser is paused
    ###
    paused: ->
      @element.data('paused')

    ######################
    # Instance Functions #
    ######################

    ###*
    Moves the mouse object to this element Accepts a jQuery selector, a
    position object with left/top defined, or a set of x, y coordinates

      mouser.move('#element_to_move_to')
      mouser.move({top: 100, left: 250})
      mouser.move('#element', offset_x, offset_y)

    By default, will move to the center of the object if specified
    @param {String, Object} target the destination to move to
    ###
    move: (target) ->
      targ = arguments
      @runner(
        => @_move(targ, {duration: 1000}),
        1000
      )

    ###*
    Rapid movement - no animation, just teleport into place
    # @param {String, Object} target the destination to move to
    ###
    teleport: (target) ->
      targ = arguments
      @runner =>
        @_move(targ, {duration: 0, scrollWindow: false})
      , 200

    ###*
    Flashes the background 30% more opaque, imitating a click
    Accepts same arguments as #move to move before clicking
    @param {String, Object} target the destination to move to
    ###
    click: (args) ->
      @move(arguments...) if arguments.length > 0
      @runner(
        => @_click(),
        400
      )


    ###*
    Shortcut to click twice
    @param {String, Object} target the destination to move to
    ###
    doubleclick: (target) ->
      @click(target)
      @click()

    ###*
    Imitate a click, then actually click the element
    Only accepts an element - does not accept offets!
    ###
    realClick: (el) ->
      @click(el)
      @runner ->
        $(el).click()

    ###*
    Pulsate the background
    Will continue until stopped by #pulsate(false)
    @param {Boolean} start start/stop pulsating
    ###
    pulsate: (start = true) ->
      if start
        @runner =>
          @element.find('.pulsar').addClass('pulse')
      else
        @runner =>
          @element.find('.pulsar').removeClass('pulse')
      return this

    ###*
    Move to a target then pulsate until the mouser is clicked
    @param {String, Object} target the destination to move to
    ###
    pulsateUntilClicked: (target) ->
      if target?
        @move(target)
      @pulsate()
      @waitForEvent('click', target)
      @pulsate(false)


    ###*
    Pause the mouser until an event is triggered on an element
    @param {String} evt the jQuery event selector
    @param {String} el the selector to bind the event listener on
    ###
    waitForEvent: (evt, el) ->
      el = '[data-mouser-id="'+@id+'"]' if !el?
      namespaced_evt = evt+'.'+@id
      @runner =>
        @pause()
        $(document).on namespaced_evt, el, =>
          @resume()
          $(document).off namespaced_evt

    ################
    # Misc Helpers #
    ################

    ###*
    Delay the next action by a certain amount
    @param {Integer} the amount of time to delay, in milliseconds
    ###
    delay: (time) ->
      @element.delay(time)
      return this

    ###*
    Wrap a #queue function with a built-in next delay, if given
    @param {Function} func the function to run
    @param {Integer} the amount of time to delay before continuing, in milliseconds
    ###
    runner: (func, delay) ->
      @queue (next) =>
        func()
        if delay?
          setTimeout next, delay
        else
          next()

    ###################
    # Tooltip helpers #
    ###################

    ###*
    Creates and displays the popover
    Accepts either a text string or an options object for Bootstrap's tooltip function

      mouser.annotate("This is a popover!")
      mouser.annotate('text': 'This is a popover!', 'trigger': 'manual')
    @param {Object or String} args the arguments to pass to popover
    ###
    annotate: (args) ->
      default_options = {
        # placement: 'top'
        trigger: 'manual'
      }
      switch typeof args
        when 'string'
          args = {content: args}
        when 'boolean'
          if args
            @runner =>
              @element.popover('show')
          else
            @runner =>
              @element.popover('hide')
        when 'object'
        else
          console.log 'Tooltip received invalid input!'
          return false
      if typeof args is 'object'
        opts = $.extend(true, default_options, args)
        $el = @element
        @runner( =>
          $el
            .popover('hide')
            .addClass('has-popover')
          setTimeout ->
            $el
              .popover('destroy')
              .popover(opts)
              .popover('show')
          , 500
        , 1000)

    ###*
    Creates a popover, adding a link to the bottom which must be clicked to continue
    @param {Object or String} args the arguments to pass to popover
    @option args {Object} linkOpts attributes appended to the link itself
    @option args {String} url the url to link to
    @option args {Boolean} url the url to link to
    ###
    annotateUntilClicked: (args) ->
      if typeof(args) == "string"
        args = content: args
      default_options = {
        linkOpts: "onclick='return false';"
        url: '#'
        html: true
      }
      args = $.extend {}, default_options, args
      args.content += "<p class='mouser-next-link-container'><a href='"+args.url+"' id='"+@id+"-next-link' class='mouser-next-link' "+args.linkOpts+">Continue &rarr;</a></p>"

      @annotate(args)
      @waitForEvent('click.mouser', '#'+@id+'-next-link')
      @runner =>
        @element.popover('destroy')
      return this

    #################
    # Queue methods #
    #################

    ###*
    Use jQuery queue to enqueue a function
    Note: Function should accept a :next parameter to determine when to go to the next step
    @param {Function} func the function to enqueue
    @param {String} queue the queue name
    ###
    queue: (func, queue='fx') ->
      @element.queue(
        queue,
        (next) => @_wrapWithPause(func, next)
      )

      # Queues other than FX do not automatically dequeue
      @dequeue unless @isMoving
      return this

    ###*
    Use jQuery queue to dequeue a function
    Accepts, optionally, a queue name
    Note: This method is only used if an action is added to a non-'fx' queue. The 'fx' queue is special in that it is auto-starting.
    @param {String} queue the queue name to dequeue from
    ###
    dequeue: (queue) ->
      if @hasQueued()
        @isMoving = true
      else
        @isMoving = false

      if queue?
        @element.dequeue(queue)
      else
        @element.dequeue()


    ###################
    # Private methods #
    ###################

    ###*
    Pausing decorator for the Queue method
    Before each queued method is run, wrapWithPause checks whether the mouser is Paused or not
    This allows for universal parsing through the Queue function
    @param {Function} func the function to wrap
    @param {Function} next the 'Next' argument returned by element.queue
    @private
    ###
    _wrapWithPause: (func, next) ->
      if @paused()
        @timeout = setTimeout(
          () => @_wrapWithPause(func, next),
          250)
      else
        func(next)

    ###*
    Parse arguments for a move
    Accepts a selector, an object with top/left, or two coordinates
    Automatically centers the Mouser over a selector object, if given
    @param {String, Object} args the arguments to process
    @private
    ###
    _parseMoveArgs: (args...) ->
      switch (typeof args[0])
        when undefined, null
          console.log "Move requires an element to move to"
          return false

        when 'string'
          # Check if dual-string or dual-number
          # @move '+= 1', '+=2'
          if args.length is 2 and typeof args[1] isnt 'object'
            target = {}
            target.left = args[0] if args[0] isnt 0
            target.top = args[1] if args[1] isnt 0
          else
            # Setup target with identified string
            $target = $(args[0])
            if $target.length > 0
              target = $target.offset()
              target.left += $target.outerWidth() / 2
              target.top += $target.outerHeight() / 2

              # @move 'selector', {left: offset, top: offset}
              if args.length is 2 and typeof args[1] is 'object'
                target.left += args[1].left
                target.top += args[1].top

              # @move 'selector', offset_x, offset_y
              else if args.length is 3 and typeof args[1] is 'number'
                target.left += args[1]
                target.top += args[2]
            else
              console.log "Could not find element "+args[0]+" to move to"
              return false

        when 'object'
          target = args[0]
          unless (target.top? and target.left?) or (target.x? and target.y?)
            console.log "Object must have both a top and left property"
            return false
          # @move 'selector', {left: offset, top: offset}
          else if args.length is 2 and typeof args[1] is 'object'
            target.left += args[1].left if typeof target.left is 'number'
            target.top += args[1].top if typeof target.top is 'number'
        when 'number'
          target =
            left: args[0]
            top: args[1]
        else
          console.log "Invalid coordinates to move to: "+args
      return target



    ###*
      Raw metal functions
      You should probably be using #move and #click, but if you want
      instantaneous, low-level access...
    ###

    ###*
    Moves the mouser
    @param {String, Object} args the target to move to
    @param {Object} opts the options to pass to #transition
    @private
    ###
    _move: (args, opts) ->
      pos = $.extend { queue: 'moveNow' }, @_parseMoveArgs(args...), opts
      pos = @center(pos)
      unless opts.scrollWindow == false
        $window = $ window
        bottomOfWindow = $window.scrollTop() + $window.innerHeight()
        if pos.top > bottomOfWindow
          $('body').animate({scrollTop: (pos.top - 200) })
      @element.transition(pos)
      @dequeue('moveNow')
      return this

    ###*
    Animates a click on the mouser
    @private
    ###
    _click: ->
      $el = @element.addClass('active')
      setTimeout ->
        $el.removeClass('active')
      ,200

  $.fn.mouser = (settings) ->
    @map ->
      if not mouser = @mouser
        args =
          content: this
          id: this.id
        @mouser = mouser = new Mouser args
      else
        @mouser

  window.Mouser = Mouser
)(jQuery, window, document)
