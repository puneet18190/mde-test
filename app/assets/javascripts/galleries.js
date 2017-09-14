/**
The galleries are containers of media elements, used at any time the user needs to pick an element of a specific type.
<br/><br/>
There are three kinds of gallery, each of them has specific features depending on where it's used. Each instance of a gallery is provided of its specific url route, that performs the speficic javascript actions it requires. For instance, in the image gallery contained inside the {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}, to each image popup (see also {{#crossLink "DialogsGalleries/showImageInGalleryPopUp:method"}}{{/crossLink}}) is attached additional HTML code that contains the input for inserting the duration of the image component. Each gallery is also provided of infinite scroll pagination, which is initialized in the methods of {{#crossLink "GalleriesInitializers"}}{{/crossLink}}. The complete list of galleries is:
<br/>
<ul>
  <li>
    <b>audio gallery</b>, whose occurrences are
    <ul>
      <li>in Audio Editor, initialized by {{#crossLink "GalleriesInitializers/initializeAudioGalleryInAudioEditor:method"}}{{/crossLink}}</li>
      <li>in Lesson Editor, initialized by {{#crossLink "GalleriesInitializers/initializeAudioGalleryInLessonEditor:method"}}{{/crossLink}}</li>
      <li>in Video Editor, initialized by {{#crossLink "GalleriesInitializers/initializeAudioGalleryInVideoEditor:method"}}{{/crossLink}}</li>
    </ul>
  </li>
  <li>
    <b>image gallery</b>, whose occurrences are
    <ul>
      <li>in Image Editor, initialized by {{#crossLink "GalleriesInitializers/initializeImageGalleryInImageEditor:method"}}{{/crossLink}}</li>
      <li>in Lesson Editor, initialized by {{#crossLink "GalleriesInitializers/initializeImageGalleryInLessonEditor:method"}}{{/crossLink}}</li>
      <li>in the mixed gallery of Video Editor, initialized by {{#crossLink "GalleriesInitializers/initializeMixedGalleryInVideoEditor:method"}}{{/crossLink}}</li>
    </ul>
  </li>
  <li>
    <b>video gallery</b>, whose occurrences are
    <ul>
      <li>in Lesson Editor, initialized by {{#crossLink "GalleriesInitializers/initializeVideoGalleryInLessonEditor:method"}}{{/crossLink}}</li>
      <li>in the mixed gallery of Video Editor, initialized by {{#crossLink "GalleriesInitializers/initializeMixedGalleryInVideoEditor:method"}}{{/crossLink}}.</li>
    </ul>
  </li>
</ul>
@module galleries
**/





/**
Scale image size form image gallery popup.
@method resizedWidthForImageGallery
@for GalleriesAccessories
@param width {Number} image original width
@param height {Number} image original height
**/
function resizedWidthForImageGallery(width, height) {
  if(height > width) {
    return (420 * width / height) + 20;
  } else {
    return 440;
  }
}





/**
Initializer for effects of opening a gallery and opening the individual dialog of an element in a gallery: this method calls methods belonging to the class {{#crossLink "DialogsGalleries"}}{{/crossLink}}.
@method galleriesDocumentReady
@for GalleriesDocumentReady
**/
function galleriesDocumentReady() {
  $body.on('click','._image_gallery_thumb', function(e) {
    e.preventDefault();
    showImageInGalleryPopUp($(this).data('image-id'));
  });
  $body.on('click','._video_gallery_thumb', function(e) {
    e.preventDefault();
    if(!$(this).hasClass('_disabled')) {
      showVideoInGalleryPopUp($(this).data('video-id'));
    }
  });
  $body.on('click', '._audio_gallery_thumb._enabled ._compact', function(e) {
    if(!$(e.target).hasClass('_select_audio_from_gallery')) {
      var parent_id = $(this).parent().attr('id');
      var was_open = false;
      var obj = $('#' + parent_id + ' ._expanded');
      if(obj.is(':visible')) {
        $('#' + parent_id).removeClass('_audio_expanded_in_gallery');
        stopMedia('#' + parent_id + ' audio');
        if($('._audio_gallery_thumb').length == 6) {
          obj.hide('blind', {}, 500, function() {
            $('.audio_gallery .scroll-pane').css('height', 304);
          });
        } else {
          obj.hide('blind', {}, 500);
        }
      } else {
        var currently_open = $('._audio_expanded_in_gallery');
        if(currently_open.length != 0) {
          was_open = true;
          currently_open.removeClass('_audio_expanded_in_gallery');
          stopMedia('#' + currently_open.attr('id') + ' audio');
          $('#' + currently_open.attr('id') + ' ._expanded').hide('blind', {}, 500);
        }
        $('#' + parent_id).addClass('_audio_expanded_in_gallery');
        var instance_id = $('#' + parent_id + ' ._empty_audio_player, #' + parent_id + ' ._instance_of_player').attr('id');
        if(!$('#' + instance_id).data('initialized')) {
          var button = $(this).find('._select_audio_from_gallery');
          var duration = button.data('duration');
          $('#' + instance_id + ' source[type="audio/mp4"]').attr('src', button.data('m4a'));
          $('#' + instance_id + ' source[type="audio/ogg"]').attr('src', button.data('ogg'));
          $('#' + instance_id + ' audio').load();
          $('#' + instance_id + ' ._media_player_total_time').html(secondsToDateString(duration));
          $('#' + instance_id).data('duration', duration);
          $('#' + instance_id).removeClass('_empty_audio_player').addClass('_instance_of_player');
          initializeMedia(instance_id, 'audio');
        }
        var jsp_handler = $('#audio_gallery_content > div').data('jsp');
        if(jsp_handler == undefined) {
          if($('._audio_gallery_thumb').length == 6 && !was_open) {
            // the calculation was 304 + 52
            $('.audio_gallery .scroll-pane').css('height', 356);
          }
          obj.show('blind', {}, 500);
        } else {
          obj.show('blind', {}, 500, function() {
            setTimeout(function() {
              var hidden_pixels = jsp_handler.getContentPositionY();
              var elements_before = 0;
              var looking = true
              $('._audio_gallery_thumb').each(function() {
                if(looking) {
                  if($(this).attr('id') == parent_id) {
                    looking = false;
                  } else {
                    elements_before += 1;
                  }
                }
              });
              // This is the result of the calculation 52X + 44 + 52 - 304
              var scroll_destination = elements_before * 52 - 208;
              if(hidden_pixels < scroll_destination) {
                // This excludes automatically the case in which scroll_destination < 0
                jsp_handler.scrollToY(scroll_destination, true);
              }
            }, 300);
          });
        }
      }
    }
  });
}





/**
Initialize audio gallery in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}.
@method initializeAudioGalleryInAudioEditor
@for GalleriesInitializers
**/
function initializeAudioGalleryInAudioEditor() {
  $('#audio_editor_gallery_container #audio_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#audio_editor_gallery_container .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#audio_editor_gallery_container').data('page');
    var tot_pages = $('#audio_editor_gallery_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/audios/galleries/audio/new_block?page=' + (page + 1));
    }
  });
}

/**
Initialize audio gallery in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}}.
@method initializeAudioGalleryInLessonEditor
@for GalleriesInitializers
**/
function initializeAudioGalleryInLessonEditor() {
  $('#lesson_editor_audio_gallery_container #audio_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#lesson_editor_audio_gallery_container .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#lesson_editor_audio_gallery_container').data('page');
    var tot_pages = $('#lesson_editor_audio_gallery_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/lessons/galleries/audio/new_block?page=' + (page + 1));
    }
  });
}

/**
Initialize audio gallery in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}.
@method initializeAudioGalleryInVideoEditor
@for GalleriesInitializers
**/
function initializeAudioGalleryInVideoEditor() {
  $('#video_editor_audio_gallery_container #audio_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#video_editor_audio_gallery_container .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#video_editor_audio_gallery_container').data('page');
    var tot_pages = $('#video_editor_audio_gallery_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/videos/galleries/audio/new_block?page=' + (page + 1));
    }
  });
}

/**
Initialize audio gallery in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}}.
@method initializeDocumentGalleryInLessonEditor
@for GalleriesInitializers
**/
function initializeDocumentGalleryInLessonEditor() {
  $('#lesson_editor_document_gallery_container .for-scroll-pain').jScrollPane({
    autoReinitialise: true
  });
  $('#lesson_editor_document_gallery_container .for-scroll-pain').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var gallery_container = $('#lesson_editor_document_gallery_container');
    var input = gallery_container.find('#document_gallery_filter');
    var page = gallery_container.data('page');
    var tot_pages = gallery_container.data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/lessons/galleries/document/new_block?page=' + (page + 1) + '&word=' + input.val());
    }
  });
}

/**
Initialize image gallery in {{#crossLinkModule "image-editor"}}{{/crossLinkModule}}.
@method initializeImageGalleryInImageEditor
@for GalleriesInitializers
**/
function initializeImageGalleryInImageEditor() {
  $('#image_gallery_for_image_editor #image_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#image_gallery_for_image_editor .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#image_gallery_for_image_editor').data('page');
    var tot_pages = $('#image_gallery_for_image_editor').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/images/galleries/image/new_block?page=' + (page + 1));
    }
  });
}

/**
Initialize image gallery in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}}.
@method initializeImageGalleryInLessonEditor
@for GalleriesInitializers
**/
function initializeImageGalleryInLessonEditor() {
  $('#lesson_editor_image_gallery_container #image_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#lesson_editor_image_gallery_container .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#lesson_editor_image_gallery_container').data('page');
    var tot_pages = $('#lesson_editor_image_gallery_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/lessons/galleries/image/new_block?page=' + (page + 1));
    }
  });
}

/**
Initialize mixed gallery in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}.
@method initializeMixedGalleryInVideoEditor
@for GalleriesInitializers
**/
function initializeMixedGalleryInVideoEditor() {
  if(!$('#info_container').hasClass('_dont_initialize_video_gallery')) {
    $('#video_editor_mixed_gallery_container #video_gallery_content > div').jScrollPane({
      autoReinitialise: true
    });
    $('#video_editor_mixed_gallery_container #video_gallery_content .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
      var page = $('#video_editor_mixed_gallery_container').data('video-page');
      var tot_pages = $('#video_editor_mixed_gallery_container').data('video-tot-pages');
      if(isAtBottom && (page < tot_pages)) {
        $.get('/videos/galleries/video/new_block?page=' + (page + 1));
      }
    });
  } else {
    $('.video_gallery .scroll-pane').css('overflow', 'hidden');
  }
  if(!$('#info_container').hasClass('_dont_initialize_image_gallery')) {
    $('#video_editor_mixed_gallery_container #image_gallery_content > div').jScrollPane({
      autoReinitialise: true
    });
    $('#video_editor_mixed_gallery_container #image_gallery_content .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
      var page = $('#video_editor_mixed_gallery_container').data('image-page');
      var tot_pages = $('#video_editor_mixed_gallery_container').data('image-tot-pages');
      if(isAtBottom && (page < tot_pages)) {
        $.get('/videos/galleries/image/new_block?page=' + (page + 1));
      }
    });
  } else {
    $('.image_gallery .scroll-pane').css('overflow', 'hidden');
  }
}

/**
Initialize video gallery in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}}.
@method initializeVideoGalleryInLessonEditor
@for GalleriesInitializers
**/
function initializeVideoGalleryInLessonEditor() {
  $('#lesson_editor_video_gallery_container #video_gallery_content > div').jScrollPane({
    autoReinitialise: true
  });
  $('#lesson_editor_video_gallery_container .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#lesson_editor_video_gallery_container').data('page');
    var tot_pages = $('#lesson_editor_video_gallery_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/lessons/galleries/video/new_block?page=' + (page + 1));
    }
  });
}
