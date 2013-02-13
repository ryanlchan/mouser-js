# Mouser v0.0.1
#
# Mouser is a class used to imitate a pointer/floating object on the user's
# screen. It aids the designer in creating an interactive tour by providing
# helpers for moving the pointer around the screen using element names, raw
# coordinates, or offset() objects
#
# Animations are done using CSS animations, preferentially, though a Modernizr
# fallback to a JS movement is planned.
#
# Mouser dependencies:
#   * jQuery (tested on 1.9.1)
#   * Bootstrap 2 (For annotations)
#   * jQuery Transit (http://ricostacruz.com/jquery.transit/)
class Mouser
  ##################
  # Initialization #
  ##################
  constructor: (@id = 'mouser', @content) ->
    @content = "<div class='mouser-container'><div class='mouser-pointer'></div></div>" unless @content?
    @id = @id.replace '#', ''
    @moveQueue = []

    $el = $('#'+@id)
    if $el.length > 0
      @element_cache = $el
    else
      $('body')
        .append(@content)
        .children()
        .last()
        .attr('id', @id)

  ###########
  # Helpers #
  ###########
  element: ->
    if @element_cache?
      @element_cache
    else
      @element_cache = $('#'+@id)

  center: (target) ->
    target.left -= (@element().outerWidth()/2 - 5) if typeof target.left is 'number'
    target.top -= 5 if typeof target.top is 'number'
    return target

  hasQueued: ->
    @element().queue().length > 0

  clearQueue: ->
    @element().queue([])

  # jQuery helpers
  fadeIn: (jq) ->
    @element().transition
      opacity: 1
    if jq?
      return @element()
    else
      return this

  fadeOut: (jq) ->
    @element().transition
      opacity: 0
    if jq?
      return @element()
    else
      return this

  hide: (jq) ->
    @element().css
      opacity: 0
    if jq?
      return @element()
    else
      return this

  show: (jq) ->
    @element().css
      opacity: 1
    if jq?
      return @element()
    else
      return this

  ######################
  # Instance Functions #
  ######################

  # Moves the mouse object to this element Accepts a jQuery selector, a
  # position object with left/top defined, or a set of x, y coordinates
  #
  #   mouser.move('#element_to_move_to')
  #   mouser.move({top: 100, left: 250})
  #   mouser.move('#element', offset_x, offset_y)
  #
  # By default, will move to the center of the object if specified
  move: (target) =>
    targ = arguments
    @queue (next) =>
      @_move(targ, {duration: 1000})
      setTimeout next, 1000


  # Rapid movement - no animation, just teleport into place
  teleport: (target) =>
    targ = arguments
    @queue (next) =>
      @_move(targ, {duration: 0})
      next()

  # Click helpers
  # Flashes the background 30% more opaque, imitating a click
  # Accepts same arguments as #move to move before clicking
  click: (args) ->
    @move(arguments...) if arguments.length > 0
    @queue (next) =>
      @_click()
      setTimeout next, 400

  # Shortcut to execute a click action twice
  doubleclick: ->
    @click()
    @click()

  # Imitate a click, then actually click the element
  # Only accepts an element - does not accept offets!
  realClick: (el) ->
    @click(el)
    @queue (next) ->
      $(el).click()
      next()

  # Misc Helpers
  # Delay the next action by a certain amount
  delay: (time) ->
    @queue (next) ->
      setTimeout next, time

  # Triggers the given function once it comes up in the queue
  runner: (func, delay) ->
    @queue (next) =>
      func()
      if delay?
        setTimeout next, delay
      else
        next()

  # Tooltip helpers
  # Creates and displays the popover
  # Accepts either a text string or an options object for Bootstrap's tooltip function
  #
  #   mouser.annotate("This is a popover!")
  #   mouser.annotate('text': 'This is a popover!', 'trigger': 'manual')
  #
  annotate: (args) ->
    default_options = {
      # placement: 'top'
      trigger: 'manual'
    }
    switch typeof args
      when 'string'
        args = {content: args}
      when 'object'
        # do nothing
      else
        console.log 'Tooltip received invalid input!'
        return false
    if typeof args is 'object'
      opts = $.extend(true, default_options, args)
      $el = @element()
      @queue (next) =>
        $el
          .popover('hide')
          .addClass('has-popover')
        setTimeout ->
          $el
            .popover('destroy')
            .popover(opts)
            .popover('show')
          setTimeout(next, 500)
        , 500

  #################
  # Queue methods #
  #################

  # Use jQuery queue to enqueue a function
  # Accepts the function and, optionally, a queue name
  queue: (func, queue) ->
    if queue?
      @element().queue(queue, func)
    else
      @element().queue(func)

    @dequeue unless @isMoving
    return this

  # Use jQuery queue to dequeue a function
  # Accepts, optionally, a queue name
  # Note: This method is only used if an action is added to a non-'fx' queue. The 'fx' queue is special in that it is auto-starting.
  dequeue: (queue) ->
    if @hasQueued()
      @isMoving = true
    else
      @isMoving = false

    if queue?
      @element().dequeue(queue)
    else
      @element().dequeue()

  ###################
  # Private methods #
  ###################
  # Parse arguments for a move. Accepts a selector, an object with top/left, or two coordinates
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
            console.log "Could not find element to move to"
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



  ############
  # Base API #
  ############
  # These methods are used to abstract the actual move code out of the mouser functions.

  # Instantaneous methods #
  # Provides the instantaneous action

  # Moves the pointer in current moment
  _move: (args, opts) ->
    pos = $.extend @_parseMoveArgs(args...), opts, { queue: 'moveNow' }
    pos = @center(pos)
    console.log 'Moved #'+@id+' to '+pos.left+','+pos.top
    @element().transition(pos)
    @dequeue('moveNow')
    return this

  # Animates a click on the mouser
  _click: ->
    $el = @element().addClass('rapid').addClass('active')
    setTimeout ->
      $el.removeClass('active')
      setTimeout ->
        $el.removeClass('rapid')
      ,100
    ,200

window.Mouser = Mouser
