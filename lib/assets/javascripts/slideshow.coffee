# Slideshow.
#
# The slideshow html and css SHOULD be as this (n: slides amount; slider_heigt: altezza dello slider):
#
#   <style>
#   .slideshow {
#     overflow: hidden;
#   }
#   .slideshow .slides {
#     position: relative;
#     width: calc(100% * #{n});
#   }
#   .slideshow .slides .slide {
#      float: left;
#      width: calc(100% / #{n});
#   }
#   .slideshow .slider {
#     position: absolute;
#     z-index: 1;
#     top: calc(50% - #{slider_height / 2});
#   }
#   /* optional: on-click sliders */
#   .slideshow .slider.left {
#     left: 0;
#   }
#   .slideshow .slider.right {
#     right: 0;
#   }
#   </style>
#   <div class=".slideshow">
#     <!-- optional; on-click sliders -->
#     <a href="javascript:;" class="slider left"></a>
#     <a href="javascript:;" class="slider right"></a>
#     <div class=".slides">
#       <div class=".slide">
#         Slide 1 content
#       </div>
#       <div class=".slide">
#         Slide 2 content
#       </div>
#       [...]
#     </div>
#   </div>
#
#  The slideshow MUST be initialized in this way:
#
#    new Slideshow( $('.slideshow') )
#
#  It will declare two methods, slideLeft and slideRight, to be used in order to slide respectively to the left or to the right.
#  They cn be used in this way:
#
#    var slideshow = new Slideshow( $('.slideshow') )
#    slideshow.slideLeft()
#    slideshow.slideRight()
#
#  If in the slideshow element are present .slider.left and .slider.right elements, slideshow.slideLeft() and slideshow.slideRight() will be automatically binded to their clicks.
class Slideshow
  slide = (modifier) ->
    @$slides.animate
      left: "#{modifier}=#{@slideshow_width()}"
    ,
      start: => @start_callback()
      done:  => @done_callback()

  constructor: (@$slideshow) ->
    @slideshow_width = -> @$slideshow.width()
    @$slides         = @$slideshow.find '.slides'
    @slides_length   = @$slides.find('.slide').length

    @sliding_key     = 'sliding'

    @start_callback  = -> @$slideshow.data @sliding_key, true
    @done_callback   = -> @$slideshow.data @sliding_key, false

    @$slideshow.find( '.slider.left'  ).on 'click', @slideLeft
    @$slideshow.find( '.slider.right' ).on 'click', @slideRight

  slideLeft: =>
    return false if @$slideshow.data @sliding_key

    left = @$slides.position().left

    return false if left >= 0

    slide.call @, '+'

  slideRight: =>
    return false if @$slideshow.data @sliding_key

    left      = @$slides.position().left
    last_left = -( (@slides_length - 1) * @slideshow_width() )

    return false if left <= last_left

    slide.call @, '-'

window.Slideshow = Slideshow