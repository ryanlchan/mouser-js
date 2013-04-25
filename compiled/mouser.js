var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __slice = [].slice;

(function($, window, document) {
  "use strict";

  var Mouser, defaults;
  defaults = {
    /**
    The content to insert into the document as a Mouser object
    @property content
    @type String
    @default "<div class='mouser-container'><span class='pulsar'></span><div class='mouser-pointer'></div></div>"
    */

    content: "<div class='mouser-container'><span class='pulsar'></span><div class='mouser-pointer'></div></div>"
  };
  Mouser = (function() {
    /**
    @method constructor
    @param {Object} args the initialization arguments
    @option {String or jQuery} content the Mouser's body as either HTML or a jQuery object
    @option {String} optional id the ID to identify this Mouser
    */

    function Mouser(args) {
      this.passClick = __bind(this.passClick, this);
      args = $.extend({}, defaults, args);
      this.content = args.content;
      this.id = args.id || this.generateGUID();
      this.findOrCreateElement();
      this.setMouserId();
      this.bindClickHandlers();
    }

    /**
    Generate a GUID for this mouser if not supplied an ID
    */


    Mouser.prototype.generateGUID = function() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r, v;
        r = Math.random() * 16 | 0;
        v = (c === 'x' ? r : r & 0x3 | 0x8);
        return v.toString(16);
      });
    };

    /**
    Find or create the mouser content
    */


    Mouser.prototype.findOrCreateElement = function() {
      var $el;
      if (typeof this.content === "string") {
        $el = $('#' + this.id);
        if ($el.length > 0) {
          return this.element = $el;
        } else {
          return this.element = this.addElementToBody();
        }
      } else {
        return this.element = $(this.content);
      }
    };

    /**
    Adds Mouser content to the body
    */


    Mouser.prototype.addElementToBody = function() {
      if ($('body').length === 0) {
        return setTimeout(this.addElementToBody, 100);
      } else {
        return this.element_cache = $(this.content).appendTo('body');
      }
    };

    /**
    Sets the data-mouser-id attribute on the element
    */


    Mouser.prototype.setMouserId = function() {
      this.element.attr('data-mouser-id', this.id);
      this.element.mouser = this;
      if (this.element[0] != null) {
        return this.element[0].mouser = this;
      }
    };

    /**
    Listen for click events on the Mouser
    */


    Mouser.prototype.bindClickHandlers = function() {
      return this.element.off('click.passthrough').on('click.passthrough', this.passClick);
    };

    /**
    Pass clicks on the mousers through to what's below them
    */


    Mouser.prototype.passClick = function(evt) {
      var el;
      this.element.hide();
      el = document.elementFromPoint(evt.clientX, evt.clientY);
      $(el).click();
      return this.element.show();
    };

    /*
        Reset this Mouser:
        * Clear the queue
        * Eliminate any popovers
        * Cleanup any handlers created
        * Reset state
    */


    Mouser.prototype.reset = function() {
      this.clearQueue();
      this.element.popover('destroy');
      if (this.timeout != null) {
        clearInterval(this.timeout);
      }
      this.resume();
      $(document).off('.' + this.id);
      this.pulsate(false);
      return this;
    };

    /**
    Adjust coordinates to center Mouser over the target
    @param {Object} the coordinates object
    */


    Mouser.prototype.center = function(target) {
      var offset;
      offset = this.element.outerWidth() / 2;
      if (typeof target.left === 'number') {
        target.left -= offset;
      }
      if (typeof target.top === 'number') {
        target.top -= offset;
      }
      return target;
    };

    /**
    Check if this Mouser has queued movements
    */


    Mouser.prototype.hasQueued = function() {
      return this.element.queue().length > 0;
    };

    /**
    Clear this mouser's queue
    */


    Mouser.prototype.clearQueue = function() {
      return this.element.queue([]);
    };

    /**
    Make this Mouser visible
    @param {Boolean} jq return a jQuery object
    */


    Mouser.prototype.fadeIn = function(jq) {
      var _this = this;
      this.runner(function() {
        return _this.element.addClass('visible');
      });
      if (jq != null) {
        return this.element;
      } else {
        return this;
      }
    };

    /**
    Make this Mouser invisible
    @param {Boolean} jq return a jQuery object
    */


    Mouser.prototype.fadeOut = function(jq) {
      var _this = this;
      this.runner(function() {
        return _this.element.removeClass('visible').popover('destroy');
      });
      if (jq != null) {
        return this.element;
      } else {
        return this;
      }
    };

    /**
    Alias for fadeIn
    @param {Boolean} jq return a jQuery object
    */


    Mouser.prototype.show = function(jq) {
      return this.fadeIn();
    };

    /**
    Alias for fadeOut
    @param {Boolean} jq return a jQuery object
    */


    Mouser.prototype.hide = function(jq) {
      return this.fadeOut(jq);
    };

    /**
    Pause execution of this Mouser
    */


    Mouser.prototype.pause = function() {
      return this.element.data('paused', true);
    };

    /**
    Resume execution of this Mouser
    */


    Mouser.prototype.resume = function() {
      return this.element.data('paused', false);
    };

    /**
    Check if this Mouser is paused
    */


    Mouser.prototype.paused = function() {
      return this.element.data('paused');
    };

    /**
    Moves the mouse object to this element Accepts a jQuery selector, a
    position object with left/top defined, or a set of x, y coordinates

      mouser.move('#element_to_move_to')
      mouser.move({top: 100, left: 250})
      mouser.move('#element', offset_x, offset_y)

    By default, will move to the center of the object if specified
    @param {String, Object} target the destination to move to
    */


    Mouser.prototype.move = function(target) {
      var targ,
        _this = this;
      targ = arguments;
      return this.runner(function() {
        return _this._move(targ, {
          duration: 1000
        });
      }, 1000);
    };

    /**
    Rapid movement - no animation, just teleport into place
    # @param {String, Object} target the destination to move to
    */


    Mouser.prototype.teleport = function(target) {
      var targ,
        _this = this;
      targ = arguments;
      return this.runner(function() {
        return _this._move(targ, {
          duration: 0,
          scrollWindow: false
        });
      }, 200);
    };

    /**
    Flashes the background 30% more opaque, imitating a click
    Accepts same arguments as #move to move before clicking
    @param {String, Object} target the destination to move to
    */


    Mouser.prototype.click = function(args) {
      var _this = this;
      if (arguments.length > 0) {
        this.move.apply(this, arguments);
      }
      return this.runner(function() {
        return _this._click();
      }, 400);
    };

    /**
    Shortcut to click twice
    @param {String, Object} target the destination to move to
    */


    Mouser.prototype.doubleclick = function(target) {
      this.click(target);
      return this.click();
    };

    /**
    Imitate a click, then actually click the element
    Only accepts an element - does not accept offets!
    */


    Mouser.prototype.realClick = function(el) {
      this.click(el);
      return this.runner(function() {
        return $(el).click();
      });
    };

    /**
    Pulsate the background
    Will continue until stopped by #pulsate(false)
    @param {Boolean} start start/stop pulsating
    */


    Mouser.prototype.pulsate = function(start) {
      var _this = this;
      if (start == null) {
        start = true;
      }
      if (start) {
        this.runner(function() {
          return _this.element.find('.pulsar').addClass('pulse');
        });
      } else {
        this.runner(function() {
          return _this.element.find('.pulsar').removeClass('pulse');
        });
      }
      return this;
    };

    /**
    Move to a target then pulsate until the mouser is clicked
    @param {String, Object} target the destination to move to
    */


    Mouser.prototype.pulsateUntilClicked = function(target) {
      if (target != null) {
        this.move(target);
      }
      this.pulsate();
      this.waitForEvent('click', target);
      return this.pulsate(false);
    };

    /**
    Pause the mouser until an event is triggered on an element
    @param {String} evt the jQuery event selector
    @param {String} el the selector to bind the event listener on
    */


    Mouser.prototype.waitForEvent = function(evt, el) {
      var namespaced_evt,
        _this = this;
      if (!(el != null)) {
        el = '[data-mouser-id="' + this.id + '"]';
      }
      namespaced_evt = evt + '.' + this.id;
      return this.runner(function() {
        _this.pause();
        return $(document).on(namespaced_evt, el, function() {
          _this.resume();
          return $(document).off(namespaced_evt);
        });
      });
    };

    /**
    Delay the next action by a certain amount
    @param {Integer} the amount of time to delay, in milliseconds
    */


    Mouser.prototype.delay = function(time) {
      this.element.delay(time);
      return this;
    };

    /**
    Wrap a #queue function with a built-in next delay, if given
    @param {Function} func the function to run
    @param {Integer} the amount of time to delay before continuing, in milliseconds
    */


    Mouser.prototype.runner = function(func, delay) {
      var _this = this;
      return this.queue(function(next) {
        func();
        if (delay != null) {
          return setTimeout(next, delay);
        } else {
          return next();
        }
      });
    };

    /**
    Creates and displays the popover
    Accepts either a text string or an options object for Bootstrap's tooltip function

      mouser.annotate("This is a popover!")
      mouser.annotate('text': 'This is a popover!', 'trigger': 'manual')
    @param {Object or String} args the arguments to pass to popover
    */


    Mouser.prototype.annotate = function(args) {
      var $el, default_options, opts,
        _this = this;
      default_options = {
        trigger: 'manual'
      };
      switch (typeof args) {
        case 'string':
          args = {
            content: args
          };
          break;
        case 'boolean':
          if (args) {
            this.runner(function() {
              return _this.element.popover('show');
            });
          } else {
            this.runner(function() {
              return _this.element.popover('hide');
            });
          }
          break;
        case 'object':
          break;
        default:
          console.log('Tooltip received invalid input!');
          return false;
      }
      if (typeof args === 'object') {
        opts = $.extend(true, default_options, args);
        $el = this.element;
        return this.runner(function() {
          $el.popover('hide').addClass('has-popover');
          return setTimeout(function() {
            return $el.popover('destroy').popover(opts).popover('show');
          }, 500);
        }, 1000);
      }
    };

    /**
    Creates a popover, adding a link to the bottom which must be clicked to continue
    @param {Object or String} args the arguments to pass to popover
    @option args {Object} linkOpts attributes appended to the link itself
    @option args {String} url the url to link to
    @option args {Boolean} url the url to link to
    */


    Mouser.prototype.annotateUntilClicked = function(args) {
      var default_options,
        _this = this;
      if (typeof args === "string") {
        args = {
          content: args
        };
      }
      default_options = {
        linkOpts: "onclick='return false';",
        url: '#',
        html: true
      };
      args = $.extend({}, default_options, args);
      args.content += "<p class='mouser-next-link-container'><a href='" + args.url + "' id='" + this.id + "-next-link' class='mouser-next-link' " + args.linkOpts + ">Continue &rarr;</a></p>";
      this.annotate(args);
      this.waitForEvent('click.mouser', '#' + this.id + '-next-link');
      this.runner(function() {
        return _this.element.popover('destroy');
      });
      return this;
    };

    /**
    Use jQuery queue to enqueue a function
    Note: Function should accept a :next parameter to determine when to go to the next step
    @param {Function} func the function to enqueue
    @param {String} queue the queue name
    */


    Mouser.prototype.queue = function(func, queue) {
      var _this = this;
      if (queue == null) {
        queue = 'fx';
      }
      this.element.queue(queue, function(next) {
        return _this._wrapWithPause(func, next);
      });
      if (!this.isMoving) {
        this.dequeue;
      }
      return this;
    };

    /**
    Use jQuery queue to dequeue a function
    Accepts, optionally, a queue name
    Note: This method is only used if an action is added to a non-'fx' queue. The 'fx' queue is special in that it is auto-starting.
    @param {String} queue the queue name to dequeue from
    */


    Mouser.prototype.dequeue = function(queue) {
      if (this.hasQueued()) {
        this.isMoving = true;
      } else {
        this.isMoving = false;
      }
      if (queue != null) {
        return this.element.dequeue(queue);
      } else {
        return this.element.dequeue();
      }
    };

    /**
    Pausing decorator for the Queue method
    Before each queued method is run, wrapWithPause checks whether the mouser is Paused or not
    This allows for universal parsing through the Queue function
    @param {Function} func the function to wrap
    @param {Function} next the 'Next' argument returned by element.queue
    @private
    */


    Mouser.prototype._wrapWithPause = function(func, next) {
      var _this = this;
      if (this.paused()) {
        return this.timeout = setTimeout(function() {
          return _this._wrapWithPause(func, next);
        }, 250);
      } else {
        return func(next);
      }
    };

    /**
    Parse arguments for a move
    Accepts a selector, an object with top/left, or two coordinates
    Automatically centers the Mouser over a selector object, if given
    @param {String, Object} args the arguments to process
    @private
    */


    Mouser.prototype._parseMoveArgs = function() {
      var $target, args, target;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      switch (typeof args[0]) {
        case void 0:
        case null:
          console.log("Move requires an element to move to");
          return false;
        case 'string':
          if (args.length === 2 && typeof args[1] !== 'object') {
            target = {};
            if (args[0] !== 0) {
              target.left = args[0];
            }
            if (args[1] !== 0) {
              target.top = args[1];
            }
          } else {
            $target = $(args[0]);
            if ($target.length > 0) {
              target = $target.offset();
              target.left += $target.outerWidth() / 2;
              target.top += $target.outerHeight() / 2;
              if (args.length === 2 && typeof args[1] === 'object') {
                target.left += args[1].left;
                target.top += args[1].top;
              } else if (args.length === 3 && typeof args[1] === 'number') {
                target.left += args[1];
                target.top += args[2];
              }
            } else {
              console.log("Could not find element " + args[0] + " to move to");
              return false;
            }
          }
          break;
        case 'object':
          target = args[0];
          if (!(((target.top != null) && (target.left != null)) || ((target.x != null) && (target.y != null)))) {
            console.log("Object must have both a top and left property");
            return false;
          } else if (args.length === 2 && typeof args[1] === 'object') {
            if (typeof target.left === 'number') {
              target.left += args[1].left;
            }
            if (typeof target.top === 'number') {
              target.top += args[1].top;
            }
          }
          break;
        case 'number':
          target = {
            left: args[0],
            top: args[1]
          };
          break;
        default:
          console.log("Invalid coordinates to move to: " + args);
      }
      return target;
    };

    /**
      Raw metal functions
      You should probably be using #move and #click, but if you want
      instantaneous, low-level access...
    */


    /**
    Moves the mouser
    @param {String, Object} args the target to move to
    @param {Object} opts the options to pass to #transition
    @private
    */


    Mouser.prototype._move = function(args, opts) {
      var $window, bottomOfWindow, pos;
      pos = $.extend({
        queue: 'moveNow'
      }, this._parseMoveArgs.apply(this, args), opts);
      pos = this.center(pos);
      if (opts.scrollWindow !== false) {
        $window = $(window);
        bottomOfWindow = $window.scrollTop() + $window.innerHeight();
        if (pos.top > bottomOfWindow) {
          $('body').animate({
            scrollTop: pos.top - 200
          });
        }
      }
      this.element.transition(pos);
      this.dequeue('moveNow');
      return this;
    };

    /**
    Animates a click on the mouser
    @private
    */


    Mouser.prototype._click = function() {
      var $el;
      $el = this.element.addClass('active');
      return setTimeout(function() {
        return $el.removeClass('active');
      }, 200);
    };

    return Mouser;

  })();
  $.fn.mouser = function(settings) {
    return this.map(function() {
      var args, mouser;
      if (!(mouser = this.mouser)) {
        args = {
          content: this,
          id: this.id
        };
        return this.mouser = mouser = new Mouser(args);
      } else {
        return this.mouser;
      }
    });
  };
  return window.Mouser = Mouser;
})(jQuery, window, document);
