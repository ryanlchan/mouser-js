# Mouser.js
#### Easy, smooth, and cross-platform pointer-based tutorials

Mouser is a Coffeescript library for making virtual pointer-based tutorials for your website.


Installation
------------
Just require the script and css after loading the dependencies.

``` html
<html>
<head>
  ...
  <link href="mouser.css" type="text/css">
</head>
<body>
  ...
  <script src='jquery.js'></script>
  <script src='jquery.transit.js'></script>
  <!-- Only required if using annotations -->
  <script src='bootstrap.tooltip.js'></script>
  <script src='bootstrap.popover.js'></script>
  <script src='mouser.js'></script>
</body>

````

Mouser depends on jQuery, jQuery Transit for transitions, and Bootstrap Popovers for annotations.

Usage
-----
Mouser.js uses instances of the Mouser class to represent each pointer.

**Initialize**
``` javascript
mouser = new Mouser();   // Initializes a new pointer
                         // The new mouser is appended to <body> on initialize
existing = $('.mousers').mouser() // Use existing or custom mousers
```

**Moving the pointer**
The `Mouser.move()` function will move the pointer to a new location, with easing.
It accepts a jQuery selector, a position object with left/top defined, or a
set of x, y coordinates.

By default, will move to the center of the object.

``` javascript
mouser.move('#element_to_move_to')              // Move to center of #element_to_move_to
mouser.move({top: 100, left: 250})              // Move to coordinates 250, 100
mouser.move('#element', offset_x, offset_y)     // Move to #element, but offset by offset_x, offset_y
```

If you need to quickly reposition the mouser, `Mouser.teleport()` will allow you
to instantly change positions.
``` javascript
mouser.teleport('#element_to_move_to')          // Instantly reposition to #element_to_move_to
```

**Clicking**

Hint that a Mouser is clickable by using the `Mouser.pulsate()` command.

``` javascript
mouser.pulsate()      // Start pulsating
mouser.pulsate(false) // Stop pulsating
````

Mouser can imitate clicks, highlighting the background of the pointer.
`Mouser.click()` accepts the same arguments as `Mouser.move()`

``` javascript
mouser.click('#element_to_click')               // Flash pointer on the center of #element_to_click
mouser.doubleClick('#element_to_click')         // Flash pointer twice
```

There is also the option to perform an actual click on an element.

``` javascript
mouser.realClick('#element_to_click')           // Imitate click, then trigger click event on element
```

**Showing and hiding**

Mousers can be shown and hidden, allowing multiple mousers to participate in one tour.

``` javascript
mouser.hide()                                   // Fade opacity to 0
mouser.show()                                   // Fade opacity to 1
```

**Annotation**

Mousers can have speech-bubble style annotations through Bootstrap's Popover
plugin by using `Mouser.annotate()`, which takes either a text string or a
configuration object for Bootstrap Popover.

``` javascript
mouser.annotate('Hello, world!')
mouser.annotate({title: "This is a title",
                content: "And here is some content!"})
mouser.annotate(false) // Close the popover
```

**Queues**

By default, Mouser uses the standard *fx* queue jQuery uses. This allows you
to queue up multiple movements, clicks, and annotations at one time without
having them overlap.

``` javascript
mouser
  .move('#element_to_move_to')              // Each action executes independently
  .click()
  .annotate("Let's go!")
```

**Storybodaring**

Mousers have two main commands which help storyboarding: `pulsateUntilClicked()` or `annotateUntilClicked()`

`pulsateUntilClicked()` will pause execution of the Mouser's queue until the mouse is clicked.

`annotateUntilClicked()` will pause execution of the MOuser's queue until a link appended to the annotation is clicked.

For more advanced control over storyboarding, you can use the low-level function `waitForEvent()`.

``` javascript
mouser.waitForEvent('click', '#mouser-id') // Accepts event and target selectors, like .on()
mouser.waitForEvent('scroll', 'body')
```


Customization
-------------
Mouser objects are just HTML classes absolutely positioned on your website.
Styling can be accomplished through plain old CSS.

``` css
.mouser-container { background-color: red }
.mouser-pointer { background: url('link/to/another/pointer.png') }
```

For additional flexibility, use the `=mouser` mixin included in the SASS stylesheet.
``` sass
#special-mouser-container
  +mouser(100px, 0.5, red)    // Accepts mouser diameter, pointer-to-container scale, and background color
```

Alternatives
------------
**[Kera.io][]**
  * Excellent SAAS solution which supports pausing, audio, highlighting, and all sorts of additional functionality
  * Price: $50-350/mo

**[Taurus.io][]**
  * Dialog box based tours with a WYSWYG editor; perfect for non-technical folks
  * Price: $9+/mo

**[Joyride][]**
  * Open Source, dialog box based tours you code
  * Price: Free!

**[Bootstrap Tour][bootstraptour]**
  * Open Source, Bootstrap-popover box based tours you code
  * Price: Free!

Acknowledgements
----------------
Released under the [MIT License](http://www.opensource.org/licenses/mit-license.php).

Mouser was hacked together and dubiously maintained by [Ryan Chan][rlc] as an introduction tool for [Musubi][].

* [My website](rlc)
* [Twitter](http://twitter.com/ryanlchan) (@ryanlchan)
* [Github](http://github.com/ryanlchan)

[Kera.io]: http://kera.io
[Taurus.io]: http://taurus.io
[Joyride]: http://www.zurb.com/playground/jquery-joyride-feature-tour-plugin
[bootstraptour]: http://bootstraptour.com/
[rlc]: http://ryanlchan.com
[Musubi]: http://www.musubimail.com
