$(document).ready(function(){
  leader = new Mouser();
  leader
    .teleport('#mouser-box')
    .show()
    .pulsateUntilClicked()
    .annotateUntilClicked("Couldn't resist?")
    .annotateUntilClicked("Neither can your users.")
    .move('#demo h1', 100, 0);

  mover = new Mouser();
  mover
    .teleport('#from-place')
    .show()
    .pulsateUntilClicked();

  mover.place = '#from-place';
  mover.element.on('click', function() {
    mover.place = mover.place === '#to-place' ? '#from-place': '#to-place';
    mover
      .move(mover.place)
      .pulsateUntilClicked();
  });

  pulsater = new Mouser();
  pulsater
    .teleport('#pulsate-place')
    .show()
    .pulsateUntilClicked()
    .hide();

  $('#pulsate-place')
    .on('click.demo', function() {
      $(this)
        .addClass('active')
        .text('Clicked!');});

  annotater = new Mouser();
  annotater
    .teleport('#annotate-place-1')
    .show()
    .pulsateUntilClicked()
    .annotate('Hello there!');

  annotater2 = new Mouser();
  annotater2
    .teleport('#annotate-place-2')
    .show()
    .pulsateUntilClicked()
    .annotate({title: "Fancy Annotation", content: 'This is a fancy annotation', placement: "top"});

  decorator = new Mouser({content: "<div class='mouser-container' id='styled-mouser'><span class='pulsar'></span><div class='mouser-pointer'></div></div>"});
  decorator
    .teleport('#style-place')
    .show();

  simult = new Mouser();
  simult
    .teleport('#simult-place')
    .show()
    .pulsateUntilClicked()
    .runner(function (){
      decorator.move('#simult-place', 100, 0);
    }, 1000)
    .runner(function (){
      decorator.move("-=100", 0);
    })
    .move("+=100", 0)
    .runner(function (){
      decorator.move("+=100", 0);
    })
    .move("-=100", 0)
    .annotate('Cool.');

  $('.tooltipped').tooltip({placement: "bottom"});
});

