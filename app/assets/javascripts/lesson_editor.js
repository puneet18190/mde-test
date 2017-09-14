/**
The Lesson Editor is used to add and edit slides to a private lesson.
<br/><br/>
When opening the Editor on a lesson, all its slides are appended to a queue, of which it's visible only the portion that surrounds the <b>current slide</b> (the width of such a portion depends on the screen resolution, see {{#crossLink "LessonEditorSlidesNavigation/initLessonEditorPositions:method"}}{{/crossLink}} and {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyResize:method"}}{{/crossLink}}). The current slide is illuminated and editable, whereas the adhiacent slides are covered by a layer with opacity that prevents the user from editing them: if the user clicks on this layer, the application takes the slide below it as new current slide and moves it to the center of the screen (see {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlidesNavigator:method"}}{{/crossLink}} and the methods in {{#crossLink "LessonEditorSlidesNavigation"}}{{/crossLink}}): only after this operation, the user can edit that particular slide. To avoid overloading when there are many slides containing media, the slides are instanced all together but their content is loaded only when the user moves to them (see the methods in {{#crossLink "LessonEditorSlideLoading"}}{{/crossLink}}).
<br/><br/>
On the right side of each slide the user finds a list of <b>buttons</b> (initialized in {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlideButtons:method"}}{{/crossLink}}): each button corresponds either to an action that can be performed on the slide, either to an action that can be performed to the whole lesson (for instance, save and exit, or edit title description and tags).
<br/><br/>
The <b>tool to navigate the slides</b> is located on the top of the editor: each small square represents a slide (with its position), and passing with the mouse over it the Editor shows a miniature of the corresponding slide (these functionalities are initialized in {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlidesNavigator:method"}}{{/crossLink}}). Clicking on a slide miniature, the application moves to that slide using the function {{#crossLink "LessonEditorSlidesNavigation/slideTo:method"}}{{/crossLink}}. The slides can be sorted dragging with the mouse (using the JQueryUi plugin, initialized in {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyJqueryAnimations:method"}}{{/crossLink}} and {{#crossLink "LessonEditorJqueryAnimations/initializeSortableNavs:method"}}{{/crossLink}}).
<br/><br/>
Inside the Editor, there are two operations that require hiding and replacement of the queue of slides: <b>adding a media element to a slide</b> and <b>choosing a new slide</b>. In both these operations, an HTML div is extracted from the main template (where it was hidden), and put in the place of the current slide, hiding the rest of the slides queue, buttons, and slides navigation (operations performed by {{#crossLink "LessonEditorCurrentSlide/hideEverythingOutCurrentSlide:method"}}{{/crossLink}}). For the galleries, the extracted div must be filled by an action called via Ajax (see the module {{#crossLinkModule "galleries"}}{{/crossLinkModule}}), whereas the div with the list of available slides is already loaded with the Editor (see {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyNewSlideChoice:method"}}{{/crossLink}}).
<br/><br/>
To add a media element to a slide, the user picks it from its specific gallery: when he clicks on the button 'plus', the system calls the corresponding subfunction in {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyAddMediaElement:method"}}{{/crossLink}}. To avoid troubles due to the replacement of JQuery plugins, video and audio tags, etc, this method always replaces the sources of <b>audio</b> and <b>video</b> tags and calls <i>load()</i>.
<br/><br/>
If the element added is of type <b>image</b>, the user may drag it inside the slide, using {{#crossLink "LessonEditorJqueryAnimations/makeDraggable:method"}}{{/crossLink}}. A set of methods (in the class {{#crossLink "LessonEditorImageResizing"}}{{/crossLink}}) is available to resize the image and the alignment chosen by the user; more specificly, the method {{#crossLink "LessonEditorImageResizing/isHorizontalMask:method"}}{{/crossLink}} is used to understand, depending on the type of slide and on the proportions of the image, if the image is <b>vertical</b> (and then the user can drag it vertically) or <b>horizontal</b> (the user can drag it horizontally).
<br/><br/>
Each slide contains a form linked to the action that updates it, there is no global saving for the whole lesson. The slide is automaticly saved (using the method {{#crossLink "LessonEditorForms/saveCurrentSlide:method"}}{{/crossLink}}) <i>before moving to another slide</i>, <i>before showing the options to add a new slide</i>, and <i>before changing position of a slide</i>. The same function is called by the user when he clicks on the button 'save' on the right of each slide; the buttons <b>save and exit</b> and <b>edit general info</b> are also linked to slide saving, but in this case it's performed with a callback (see again the buttons initialization in {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlideButtons:method"}}{{/crossLink}}).
<br/><br/>
The text slides are provided of <b>TinyMCE</b> text editor, initialized in the methods of {{#crossLink "LessonEditorTinyMCE"}}{{/crossLink}}.
@module lesson-editor
**/





/**
Hides buttons, adhiacent slides and slide navigation (used before {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyNewSlideChoice:method"}}{{/crossLink}} and {{#crossLink "LessonEditorGalleries/showGalleryInLessonEditor:method"}}{{/crossLink}}).
@method hideEverythingOutCurrentSlide
@for LessonEditorCurrentSlide
**/
function hideEverythingOutCurrentSlide() {
  var current_slide = $('li._lesson_editor_current_slide');
  $('#heading').children().hide();
  $('._add_new_slide_options_in_last_position').hide();
  $('._not_current_slide').removeClass('_not_current_slide').addClass('_not_current_slide_disabled');
  current_slide.find('.buttons a:not(._hide_add_slide)').css('visibility', 'hidden');
}

/**
Hides the template for selection of new slides.
@method hideNewSlideChoice
@for LessonEditorCurrentSlide
**/
function hideNewSlideChoice() {
  var current_slide = $('li._lesson_editor_current_slide');
  current_slide.find('div.slide-content').addClass(current_slide.data('kind'));
  current_slide.find('.box.new_slide').remove();
  if(!current_slide.find('.slide-content').hasClass('cover')) {
    current_slide.find('.slide-content').css('padding', '20px');
  }
  current_slide.find('._hide_add_new_slide_options').removeAttr('class').addClass('addButtonOrange _add_new_slide_options');
  var new_title = current_slide.find('._add_new_slide_options').data('title');
  current_slide.find('._add_new_slide_options').removeAttr('title').attr('title', new_title);
  showEverythingOutCurrentSlide();
}

/**
Opposite of {{#crossLink "LessonEditorCurrentSlide/hideEverythingOutCurrentSlide:method"}}{{/crossLink}}.
@method showEverythingOutCurrentSlide
@for LessonEditorCurrentSlide
**/
function showEverythingOutCurrentSlide() {
  var current_slide = $('li._lesson_editor_current_slide');
  $('#heading').children().show();
  $('._add_new_slide_options_in_last_position').show();
  $('._not_current_slide_disabled').addClass('_not_current_slide').removeClass('_not_current_slide_disabled');
  current_slide.find('.buttons a').css('visibility', 'visible');
}

/**
Shows the template for selection of new slides.
@method showNewSlideOptions
@for LessonEditorCurrentSlide
**/
function showNewSlideOptions() {
  stopMediaInCurrentSlide();
  var current_slide_content = $('li._lesson_editor_current_slide .slide-content');
  if(!current_slide_content.hasClass('cover')) {
    current_slide_content.css('padding', '0');
  }
  var html_to_be_replaced = $('#new_slide_option_list').html();
  current_slide_content.prepend(html_to_be_replaced);
  current_slide_content.siblings('.buttons').find('._add_new_slide_options').removeAttr('class').addClass('minusButtonOrange _hide_add_slide _hide_add_new_slide_options');
  var new_title = current_slide_content.siblings('.buttons').find('._hide_add_new_slide_options').data('other-title');
  current_slide_content.siblings('.buttons').find('._hide_add_new_slide_options').removeAttr('title').attr('title', new_title);
  hideEverythingOutCurrentSlide();
}

/**
Stop video and audio playing into the current slide (used before changing slide with {{#crossLink "LessonEditorSlidesNavigation/slideTo:method"}}{{/crossLink}}).
@method stopMediaInCurrentSlide
@for LessonEditorCurrentSlide
**/
function stopMediaInCurrentSlide() {
  var current_slide_id = $('li._lesson_editor_current_slide').attr('id');
  stopMedia('#' + current_slide_id + ' audio');
  stopMedia('#' + current_slide_id + ' video');
}

/**
Switches the titles of disabled and enabled buttons when the user reaches the maximum number of allowed slides.
@method switchDisabledMaximumSlideNumberLessonEditor
@for LessonEditorCurrentSlide
**/
function switchDisabledMaximumSlideNumberLessonEditor() {
  var title_disabled = $('._add_new_slide_options').attr('title');
  var title_disabled_last_position = $('._add_new_slide_options_in_last_position').attr('title');
  $('._add_new_slide_options').attr('title', $('._add_new_slide_options').data('disabled-title'));
  $('._add_new_slide_options_in_last_position').attr('title', $('._add_new_slide_options_in_last_position').data('disabled-title'));
  $('._add_new_slide_options').data('disabled-title', title_disabled);
  $('._add_new_slide_options_in_last_position').data('disabled-title', title_disabled_last_position);
}





/**
General initialization of Lesson Editor.
@method lessonEditorDocumentReady
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReady() {
  lessonEditorDocumentReadyJqueryAnimations();
  lessonEditorDocumentReadyResize();
  lessonEditorDocumentReadySlidesNavigator();
  lessonEditorDocumentReadySlideButtons();
  lessonEditorDocumentReadyNewSlideChoice();
  lessonEditorDocumentReadyGalleries();
  lessonEditorDocumentReadyAddMediaElement();
  lessonEditorDocumentReadyReplaceMediaElement();
  lessonEditorDocumentReadyTextFields();
  lessonEditorDocumentReadyInitializeImageInscription();
  lessonEditorDocumentReadyUploaderInGallery();
}

/**
Initializer of the three functionalities to add an element (image, audio, video).
@method lessonEditorDocumentReadyAddMediaElement
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyAddMediaElement() {
  $body.on('click', '._add_image_to_slide', function(e) {
    e.preventDefault();
    var current_slide = $('li._lesson_editor_current_slide');
    var image_id = $(this).data('image-id');
    var image_url = $(this).data('url');
    var image_width = $(this).data('width');
    var image_height = $(this).data('height');
    var current_kind = current_slide.data('kind')
    closePopUp('dialog-image-gallery-' + image_id);
    removeGalleryInLessonEditor('image');
    var position = $('#info_container').data('current-media-element-position');
    var place_id = 'media_element_' + position + '_in_slide_' + current_slide.data('slide-id');
    $('#' + place_id + ' .image-id').val(image_id);
    $('#' + place_id + ' .inscribed').val('false');
    var inscribe_toggle_icon = $('#' + place_id + ' .deinscribe, #' + place_id + ' .inscribe');
    var new_title = inscribe_toggle_icon.data('inscribe-title');
    inscribe_toggle_icon.attr('title', new_title).removeClass('deinscribe').addClass('inscribe');
    $('#' + place_id).data('width', image_width).data('height', image_height);
    var full_place = $('#' + place_id + ' .mask');
    if(!full_place.is(':visible')) {
      full_place.show();
      $('#' + place_id + ' .empty-mask').hide();
    }
    var old_mask = 'horizontal';
    var new_mask = 'vertical';
    var old_orientation = 'width';
    var orientation = 'height';
    var orientation_val = resizeHeight(image_width, image_height, current_kind);
    var align_val = (getVerticalStandardSizeOfSlideImage(current_kind) - orientation_val) / 2;
    var this_align_side = 'top';
    var other_align_side = 'left';
    if(isHorizontalMask(image_width, image_height, current_kind)) {
      old_mask = 'vertical';
      new_mask = 'horizontal';
      old_orientation = 'height';
      orientation = 'width';
      orientation_val = resizeWidth(image_width, image_height, current_kind);
      align_val = (getHorizontalStandardSizeOfSlideImage(current_kind) - orientation_val) / 2;
      this_align_side = 'left';
      other_align_side = 'top';
    }
    $('#' + place_id + ' .align').val(align_val);
    full_place.addClass(new_mask).removeClass(old_mask);
    var img_tag = $('#' + place_id + ' .mask img');
    img_tag.attr('src', image_url);
    img_tag.parent().css(this_align_side, align_val);
    img_tag.parent().css(other_align_side, 0);
    img_tag.removeAttr(old_orientation);
    img_tag.attr(orientation, orientation_val);
    makeDraggable(place_id);
  });
  $body.on('click', '._add_video_to_slide', function(e) {
    e.preventDefault();
    var video_id = $(this).data('video-id');
    closePopUp('dialog-video-gallery-' + video_id);
    removeGalleryInLessonEditor('video');
    var current_slide = $('li._lesson_editor_current_slide');
    var position = $('#info_container').data('current-media-element-position');
    var place_id = 'media_element_' + position + '_in_slide_' + current_slide.data('slide-id');
    $('#' + place_id + ' .video-id').val(video_id);
    $('#' + place_id + ' .mask .add').hide();
    var video_mp4 = $(this).data('mp4');
    var video_webm = $(this).data('webm');
    var duration = $(this).data('duration');
    var full_place = $('#' + place_id + ' .mask');
    if(!full_place.is(':visible')) {
      full_place.show();
      $('#' + place_id + ' .empty-mask').hide();
    }
    $('#' + place_id + ' .mask source[type="video/mp4"]').attr('src', video_mp4);
    $('#' + place_id + ' .mask source[type="video/webm"]').attr('src', video_webm);
    $('#' + place_id + ' video').load();
    $('#' + place_id + ' ._media_player_total_time').html(secondsToDateString(duration));
    var video_player = $('#' + place_id + ' ._empty_video_player, #' + place_id + ' ._instance_of_player');
    if(video_player.data('initialized')) {
      video_player.data('duration', duration);
      $('#' + video_player.attr('id') + ' ._media_player_slider').slider('option', 'max', duration);
    } else {
      video_player.removeClass('_empty_video_player').addClass('_instance_of_player');
      video_player.data('duration', duration);
      initializeMedia(video_player.attr('id'), 'video');
    }
  });
  $body.on('click', '._add_audio_to_slide', function(e) {
    e.preventDefault();
    var audio_id = $(this).data('audio-id');
    var new_audio_title = $('#gallery_audio_' + audio_id+' .titleTrack').text();
    $('#gallery_audio_' + audio_id).removeClass('_audio_expanded_in_gallery');
    stopMedia('#gallery_audio_' + audio_id + ' audio');
    $('#gallery_audio_' + audio_id + ' ._expanded').hide();
    removeGalleryInLessonEditor('audio');
    var current_slide = $('li._lesson_editor_current_slide');
    var position = $('#info_container').data('current-media-element-position');
    var place_id = 'media_element_' + position + '_in_slide_' + current_slide.data('slide-id');
    $('#' + place_id + ' .audio-id').val(audio_id);
    var audio_m4a = $(this).data('m4a');
    var audio_ogg = $(this).data('ogg');
    var duration = $(this).data('duration');
    var full_place = $('#' + place_id + ' .mask');
    if(!full_place.is(':visible')) {
      full_place.show();
      $('#' + place_id + ' .empty-mask').hide();
    }
    $('#' + place_id + ' .mask source[type="audio/mp4"]').attr('src', audio_m4a);
    $('#' + place_id + ' .mask source[type="audio/ogg"]').attr('src', audio_ogg);
    $('#' + place_id + ' audio').load();
    $('#' + place_id + ' ._media_player_total_time').html(secondsToDateString(duration));
    $('#' + place_id + ' .mask .title').text(new_audio_title);
    var audio_player = $('#' + place_id + ' ._empty_audio_player, #' + place_id + ' ._instance_of_player');
    if(audio_player.data('initialized')) {
      audio_player.data('duration', duration);
      $('#' + audio_player.attr('id') + ' ._media_player_slider').slider('option', 'max', duration);
    } else {
      audio_player.removeClass('_empty_audio_player').addClass('_instance_of_player');
      audio_player.data('duration', duration);
      initializeMedia(audio_player.attr('id'), 'audio');
    }
  });
}

/**
Initializer for galleries.
@method lessonEditorDocumentReadyGalleries
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyGalleries() {
  $body.on('click', '.slide-content .image.editable .add', function() {
    if(!$(this).parents('.slide-content').hasClass('small-size')) {
      showGalleryInLessonEditor(this, 'image');
    }
  });
  $body.on('click', '.slide-content .audio.editable .add', function() {
    if(!$(this).parents('.slide-content').hasClass('small-size')) {
      stopMediaInCurrentSlide();
      showGalleryInLessonEditor(this, 'audio');
    }
  });
  $body.on('click', '.slide-content .video.editable .add', function() {
    if(!$(this).parents('.slide-content').hasClass('small-size')) {
      stopMediaInCurrentSlide();
      showGalleryInLessonEditor(this, 'video');
    }
  });
  $body.on('click', '._close_image_gallery_in_lesson_editor', function(e) {
    e.preventDefault();
    removeGalleryInLessonEditor('image');
  });
  $body.on('click', '._close_video_gallery_in_lesson_editor', function(e) {
    e.preventDefault();
    removeGalleryInLessonEditor('video');
  });
  $body.on('click', '._close_audio_gallery_in_lesson_editor', function(e) {
    e.preventDefault();
    var current_playing_audio = $('._audio_expanded_in_gallery');
    if(current_playing_audio.length != 0) {
      current_playing_audio.removeClass('_audio_expanded_in_gallery');
      stopMedia('#' + current_playing_audio.attr('id') + ' audio');
      $('#' + current_playing_audio.attr('id') + ' ._expanded').hide();
    }
    removeGalleryInLessonEditor('audio');
  });
  $body.on('click', '#lesson_editor_document_gallery_container #document_gallery .footerButtons .cancel', function() {
    removeGalleryInLessonEditor('document');
    loadDocumentGalleryForSlideInLessonEditor($('#lesson_editor_document_gallery_container').data('slide-id'));
  });
  $body.on('click', '#lesson_editor_document_gallery_container #document_gallery .footerButtons .attach', function() {
    removeGalleryInLessonEditor('document');
    unLoadDocumentGalleryContent($('#lesson_editor_document_gallery_container').data('slide-id'));
    var num_docs = $('.document_attached .documentInGallery').length;
    if(num_docs == 0) {
      $('li._lesson_editor_current_slide .attached_document_internal').hide();
    } else {
      var my_title = $('#lesson_editor_document_gallery_container').data('title-' + num_docs + '-doc');
      $('li._lesson_editor_current_slide .attached_document_internal').attr('title', my_title).show();
    }
    saveCurrentSlide('', false);
  });
  $body.on('click', '#lesson_editor_document_gallery_container .documentInGalleryExternal .documentInGallery:not(".disabled") .add_remove', function() {
    var document_id = $(this).data('document-id');
    var target = $('.attachedExternal .document_attached.not_full').first();
    var new_content = $('<div>' + $('#gallery_document_' + document_id).html() + '</div>');
    new_content.find('.to_be_removed').each(function() {
      $(this).replaceWith($(this).find('u').html());
    });
    target.html(new_content.html());
    target.removeClass('not_full');
    $('#inputs_for_documents').append('<input type="text" name="' + target.attr('id').replace('_attached', '') + '" value="' + document_id + '" />');
    updateEffectsInsideDocumentGallery();
  });
  $body.on('click', '#lesson_editor_document_gallery_container .document_attached .documentInGallery .add_remove', function() {
    var target = $(this).parents('.document_attached');
    target.html($('#' + target.attr('id') + '_empty').html());
    target.addClass('not_full');
    $('#inputs_for_documents input[name="' + target.attr('id').replace('_attached', '') + '"]').remove();
    updateEffectsInsideDocumentGallery();
  });
  $body.on('keydown', '#lesson_editor_document_gallery_container #document_gallery_filter', function(e) {
    if(e.which == 13) {
      e.preventDefault();
    } else if(e.which != 39 && e.which != 37) {
      var loader = $('#lesson_editor_document_gallery_container .documentsFooter ._loader');
      var letters = $(this).data('letters');
      letters += 1;
      $(this).data('letters', letters);
      loader.show();
      setTimeout(function() {
        var input = $('#lesson_editor_document_gallery_container #document_gallery_filter');
        if(input.data('letters') == letters) {
          loader.hide();
          $.get('/lessons/galleries/document/filter?word=' + input.val());
        }
      }, 1500);
    }
  });
  $body.on('mouseover', '.barzeretti', function() {
    var father = $(this).parent();
    if(!father.find('.documentInGallery').hasClass('disabled')) {
      father.find('.documentInGallery').data('rollovered', true);
      setTimeout(function() {
        if(father.find('.documentInGallery').data('rollovered')) {
          showPopuppina(father.attr('id'));
        }
      }, 500);
    }
  });
  $body.on('mouseout', '.barzeretti', function() {
    var father = $(this).parent();
    father.find('.documentInGallery').data('rollovered', false);
    hidePopuppina(father.attr('id'));
  });
}

/**
Initializer for dynamics of inscriptions and deinscriptions of images (it uses {{#crossLink "LessonEditorJqueryAnimations/lessonEditorInscribeImage:method"}}{{/crossLink}} and {{#crossLink "LessonEditorJqueryAnimations/lessonEditorDeinscribeImage:method"}}{{/crossLink}}).
@method lessonEditorDocumentReadyInitializeImageInscription
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyInitializeImageInscription() {
  $body.on('click', '.slide-content .image.editable .inscribe', function() {
    lessonEditorInscribeImage($(this).parents('.image.editable').attr('id'));
  });
  $body.on('click', '.slide-content .image.editable .deinscribe', function() {
    lessonEditorDeinscribeImage($(this).parents('.image.editable').attr('id'));
  });
}

/**
Initializer for JQueryUi animations defined in the class {{#crossLink "LessonEditorJqueryAnimations"}}{{/crossLink}}.
@method lessonEditorDocumentReadyJqueryAnimations
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyJqueryAnimations() {
  $('.slide-content .image.editable').each(function() {
    makeDraggable($(this).attr('id'));
  });
  initializeSortableNavs();
  $('#nav_list_menu').jScrollPane({
    autoReinitialise: false
  });
  $('#lesson_subject').selectbox();
  initLessonEditorPositions();
}

/**
Initializer for the template that contains the list of possible slides to be added.
@method lessonEditorDocumentReadyNewSlideChoice
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyNewSlideChoice() {
  $body.on('click', '._add_new_slide', function() {
    hideNewSlideChoice();
    var slide = $('li._lesson_editor_current_slide');
    slide.prepend('<layer class="_not_current_slide_disabled"></layer>');
    var kind = $(this).data('kind');
    var lesson_id = $('#info_container').data('lesson-id');
    var slide_id = slide.data('slide-id');
    $.ajax({
      type: 'post',
      url: '/lessons/' + lesson_id + '/slides/' + slide_id + '/kind/' + kind + '/create/'
    });
  });
}

/**
Initializer for the mouseover and mouseout to replace a media element already added.
@method lessonEditorDocumentReadyReplaceMediaElement
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyReplaceMediaElement() {
  $body.on('mouseover', '.slide-content .image.editable .mask', function() {
    if($(this).find('.alignable').data('rolloverable')) {
      $(this).find('.add').show();
      $(this).find('.inscribe, .deinscribe').show();
    }
  });
  $body.on('mouseout', '.slide-content .image.editable .mask', function() {
    if($(this).find('.alignable').data('rolloverable')) {
      $(this).find('.add').hide();
      $(this).find('.inscribe, .deinscribe').hide();
    }
  });
  $body.on('mouseover', '.slide-content .video.editable .mask video', function(e) {
    var position = $(this).offset();
    var top = position.top + 59;
    var right = position.left + 291;
    var bottom = position.top + 222;
    var left = position.left + 129;
    if($(this).width() > 420) {
      top = position.top + 179;
      right = position.left + 526;
      bottom = position.top + 371;
      left = position.left + 334;
    }
    if(left <= e.clientX && e.clientX <= right && top <= e.clientY && e.clientY <= bottom) {
      return;
    }
    var granpa = $(this).parents('.mask');
    if(granpa.find('.alignable').data('rolloverable')) {
      granpa.find('.add').show();
    }
  });
  $body.on('mouseout', '.slide-content .video.editable .mask video', function(e) {
    var position = $(this).offset();
    var top = position.top + 59;
    var right = position.left + 291;
    var bottom = position.top + 222;
    var left = position.left + 129;
    if($(this).width() > 420) {
      top = position.top + 179;
      right = position.left + 526;
      bottom = position.top + 371;
      left = position.left + 334;
    }
    if(left <= e.clientX && e.clientX <= right && top <= e.clientY && e.clientY <= bottom) {
      return;
    }
    var granpa = $(this).parents('.mask');
    if(granpa.find('.alignable').data('rolloverable')) {
      granpa.find('.add').hide();
    }
  });
}

/**
Initializer for window resize.
@method lessonEditorDocumentReadyResize
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyResize() {
  $('.lesson-editor-layout ul#slides').css('margin-top', ((($window.height() - 590) / 2) - 40) + 'px');
  $('.lesson-editor-layout ul#slides.new').css('margin-top', ((($window.height() - 590) / 2)) + 'px');
  $window.resize(function() {
    $('.lesson-editor-layout ul#slides').css('margin-top', ((($window.height() - 590) / 2) - 40) + 'px');
    $('.lesson-editor-layout ul#slides.new').css('margin-top', ((($window.height() - 590) / 2)) + 'px');
    if(parseInt($window.outerWidth()) > 1000) {
      $('ul#slides li:first').css('margin-left', (($window.width() - 900) / 2) + 'px');
      $('ul#slides.new li:first').css('margin-left', (($window.width() - 900) / 2) + 'px');
    }
    $('#footer').css('top', ($window.height() - 44) + 'px').css('width', $window.width() + 'px');
    var open_gallery = $('.lesson_editor_gallery_container:visible');
    if(open_gallery.length > 0) {
      centerThis(open_gallery);
    }
  });
}

/**
Initializer for the buttons on the right side of each slide.
@method lessonEditorDocumentReadySlideButtons
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadySlideButtons() {
  $body.on('click', '._hide_add_new_slide_options', function() {
    hideNewSlideChoice();
  });
  $body.on('click', '._save_slide', function(e) {
    saveCurrentSlide('', false);
  });
  $body.on('click', '._save_slide_and_exit', function() {
    saveCurrentSlide('_and_exit', true);
  });
  $body.on('click', '._save_slide_and_edit', function() {
    saveCurrentSlide('_and_edit', true);
  });
  $body.on('click', '._add_new_slide_options', function() {
    if(!$(this).hasClass('disabled')) {
      saveCurrentSlide('', false);
      showNewSlideOptions();
    }
  });
  $body.on('click', '._delete_slide', function() {
    var title = $captions.data('confirm-delete-slide-title');
    var confirm = $captions.data('confirm-delete-slide-confirm');
    var yes = $captions.data('confirm-delete-slide-yes');
    var no = $captions.data('confirm-delete-slide-no');
    showConfirmPopUp(title, confirm, yes, no, function() {
      closePopUp('dialog-confirm');
      stopMediaInCurrentSlide();
      var slide = $('li._lesson_editor_current_slide');
      slide.prepend('<layer class="_not_current_slide_disabled"></layer>');
      $.ajax({
        type: 'post',
        url: '/lessons/' + $('#info_container').data('lesson-id') + '/slides/' + slide.data('slide-id') + '/delete'
      });
    }, function() {
      closePopUp('dialog-confirm');
    });
  });
  $body.on('click', '._attach_document, li._lesson_editor_current_slide .attached_document_internal', function() {
    stopMediaInCurrentSlide();
    showDocumentGalleryInLessonEditor();
  });
}

/**
Initializer for the scroll and all the actions of the slide navigator (see the class {{#crossLink "LessonEditorSlidesNavigation"}}{{/crossLink}}).
@method lessonEditorDocumentReadySlidesNavigator
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadySlidesNavigator() {
  $body.on('mouseover', '#slide-numbers li.navNumbers:not(._add_new_slide_options_in_last_position)', function(e) {
    var tip = $(this);
    var this_tooltip = tip.children('.slide-tooltip');
    if(e.pageX < ($window.width() / 2)) {
      this_tooltip.show();
    } else {
      this_tooltip.addClass('slide-tooltip-to-left');
      tip.children('.slide-tooltip-to-left').show();
    }
  });
  $body.on('mouseout', '#slide-numbers li.navNumbers:not(._add_new_slide_options_in_last_position)', function(e) {
    var this_tooltip = $(this).children('.slide-tooltip');
    this_tooltip.removeClass('slide-tooltip-to-left');
    this_tooltip.hide();
  });
  $body.on('click', '._slide_nav:not(._lesson_editor_current_slide_nav)', function(e) {
    e.preventDefault();
    stopMediaInCurrentSlide();
    saveCurrentSlide('', false);
    slideTo($(this).data('slide-id'));
  });
  $body.on('click', '._not_current_slide', function(e) {
    e.preventDefault();
    saveCurrentSlide('', false);
    stopMediaInCurrentSlide();
    slideTo($(this).parent().data('slide-id'));
    scrollPaneUpdate(this);
  });
  $body.on('click', '._add_new_slide_options_in_last_position', function() {
    if(!$(this).hasClass('disabled')) {
      saveCurrentSlide('', false);
      var last_slide_id = $("#slide-numbers li.navNumbers:last").find('a').data('slide-id');
      $('#nav_list_menu').data('jsp').scrollToPercentX(100, true);
      if($('#slide_in_lesson_editor_' + last_slide_id).hasClass('_lesson_editor_current_slide')) {
        showNewSlideOptions();
      } else {
        slideTo('' + last_slide_id, showNewSlideOptions);
      }
    }
  });
}

/**
Initializer for the placeholders of text inputs throughout the Lesson Editor.
@method lessonEditorDocumentReadyTextFields
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyTextFields() {
  $body.on('focus', '._lesson_editor_placeholder', function() {
    if($(this).data('placeholder')) {
      $(this).val('');
      $(this).data('placeholder', false);
    }
  });
  $body.on('focus', '.lessonForm .part2 .title', function() {
    var container = $(this).parents('.lessonForm');
    var placeholder = container.find('.title_placeholder');
    if(placeholder.val() == '') {
      $(this).val('');
      placeholder.val('0');
    }
  });
  $body.on('focus', '.lessonForm .part2 .description', function() {
    var container = $(this).parents('.lessonForm');
    var placeholder = container.find('.description_placeholder');
    if(placeholder.val() == '') {
      $(this).val('');
      placeholder.val('0');
    }
  });
  $body.on('keydown', '.lessonForm .part2 .title, .lessonForm .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('keydown', '.lessonForm .part2 ._tags_container .tags', function() {
    $(this).parents('._tags_container').removeClass('form_error');
  });
  $body.on('click', '.lessonForm .part3 .submit', function() {
    var container = $(this).parents('.lessonForm');
    container.find('form').submit();
  });
  $body.on('click', '.lessonForm .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.lessonForm');
    myself.hide();
    container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
  });
  $body.on('change', '.lessonForm .part2 #lesson_subject', function() {
    var myself = $(this);
    if(myself.val() != '') {
      myself.find('.delete_me').remove();
      myself.selectbox('detach');
      myself.selectbox();
    }
  });
}

/**
Initializer for specific media elements or documents uploader inside the Lesson Editor.
@method lessonEditorDocumentReadyUploaderInGallery
@for LessonEditorDocumentReady
**/
function lessonEditorDocumentReadyUploaderInGallery() {
  $body.on('change', '.loadInGallery .part1 .attachment input.file', function() {
    var container = $(this).parents('.loadInGallery');
    var file_name = $(this).val().replace("C:\\fakepath\\", '');
    if(file_name.replace(/^[\s\t]+/, '') != '') {
      if(file_name.length > 20) {
        file_name = file_name.substring(0, 20) + '...';
      }
      container.find('.part1 .attachment .media').val(file_name).removeClass('form_error');
    } else {
      container.find('.part1 .attachment .media').val(container.data('placeholder-media')).removeClass('form_error');
    }
  });
  $body.on('click', '.gallery_upload_container a', function() {
    var myself = $(this);
    var my_father = myself.parent();
    var popup = my_father.prev();
    myself.hide();
    my_father.next().hide();
    popup.find('.part2 .title_and_description .title').val(popup.data('placeholder-title'));
    popup.find('.part2 .title_and_description .description').val(popup.data('placeholder-description'));
    popup.find('.part2 .title_and_description .title_placeholder').val('');
    popup.find('.part2 .title_and_description .description_placeholder').val('');
    popup.find('.part2 .tags_loader .tags_value').val('');
    popup.find('.part2 .tags_loader ._tags_container span').remove();
    popup.find('.part2 .tags_loader ._tags_container ._placeholder').show();
    popup.find('._tags_container .tags').show();
    popup.find('.part1 .attachment .media').val(popup.data('placeholder-media'));
    popup.find('.part1 .attachment label input').val('');
    popup.find('.form_error').removeClass('form_error');
    popup.find('.errors_layer').hide();
    popup.find('.full_folder').hide();
    popup.show();
  });
  $body.on('click', 'a.document_quick_upload_hint', function() {
    var my_father = $('#document_gallery');
    var popup = my_father.prev();
    my_father.hide();
    popup.find('.part2 .title_and_description .title').val(popup.data('placeholder-title'));
    popup.find('.part2 .title_and_description .description').val(popup.data('placeholder-description'));
    popup.find('.part2 .title_and_description .title_placeholder').val('');
    popup.find('.part2 .title_and_description .description_placeholder').val('');
    popup.find('.part1 .attachment .media').val(popup.data('placeholder-media'));
    popup.find('.part1 .attachment label input').val('');
    popup.find('.form_error').removeClass('form_error');
    popup.find('.errors_layer').hide();
    popup.find('.full_folder').hide();
    popup.show();
  });
  $body.on('click', '.loadInGallery.stegosauro .part3 .close', function() {
    if(!$(this).hasClass('disabled')) {
      var father = $(this).parents('.loadInGallery');
      father.hide();
      father.next().find('a').show();
      father.next().next().show();
    }
  });
  $body.on('click', '.loadInGallery.document .part3 .close', function() {
    if(!$(this).hasClass('disabled')) {
      var father = $(this).parents('.loadInGallery');
      father.hide();
      father.next().show();
    }
  });
  $body.on('focus', '.loadInGallery .part2 .title_and_description .description', function() {
    var placeholder = $(this).parent().find('.description_placeholder');
    if(placeholder.val() == '') {
      $(this).val('');
      placeholder.val('0');
    }
  });
  $body.on('focus', '.loadInGallery .part2 .title_and_description .title', function() {
    var placeholder = $(this).parent().find('.title_placeholder');
    if(placeholder.val() == '') {
      $(this).val('');
      placeholder.val('0');
    }
  });
  $body.on('click', '.loadInGallery .part3 .submit', function(e) {
    if(!$(this).hasClass('disabled')) {
      var container = $(this).parents('.loadInGallery');
      if(container.attr('id') == 'load-gallery-document') {
        disableUploadForm(container, $captions.data('dont-leave-page-upload-document'));
      } else {
        disableUploadForm(container, $captions.data('dont-leave-page-upload-media-element'));
      }
      recursionUploadingBar(container, 0);
      setTimeout(function() {
        container.find('form').submit();
      }, 1500);
    } else {
      e.preventDefault();
    }
  });
  $body.on('submit', '.loadInGallery form', function() {
    var container = $(this).parents('.loadInGallery');
    document.getElementById($(this).attr('id')).target = 'upload_target';
    document.getElementById('upload_target').onload = function() {
      uploadFileTooLarge(container);
    }
  });
  $body.on('keydown', '.loadInGallery .part2 .title, .loadInGallery .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('keydown', '.loadInGallery .part2 .tags', function() {
    $(this).parent().removeClass('form_error');
  });
  $body.on('click', '.loadInGallery .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.loadInGallery');
    if(!myself.hasClass('media')) {
      myself.hide();
      container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
    }
  });
  $body.on('click', '.loadInGallery .part1 .attachment label', function() {
    $('.loadInGallery .errors_layer.media').hide();
  });
  $body.on('click', '.loadInGallery .full_folder .back_to_gallery', function() {
    var father = $(this).parents('.loadInGallery');
    father.find('.part3 .close').click();
    father.find('form').show();
    father.find('·full_folder').hide();
  });
}





/**
Save current slide. It sends tinyMCE editor content to form data to be serialized, it handles form placeholders.
@method saveCurrentSlide
@for LessonEditorForms
@param action_suffix {String} action suffix to be appended after 'save' (it can be 'save_and_edit' or 'save_and_exit', or just 'save', see also {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlideButtons:merthod"}}{{/crossLink}})
@param with_loader {Boolean} if true shows the loader while calling ajax
**/
function saveCurrentSlide(action_suffix, with_loader) {
  tinyMCE.triggerSave();
  var temporary = [];
  var temp_counter = 0;
  var current_slide = $('._lesson_editor_current_slide');
  var current_slide_form = current_slide.find('form');
  var math_inputs_class = '_math_image';
  var editor = tinyMCE.get( 'ta-' + current_slide.data('slideId') );
  if (editor) {
    current_slide_form.find('.' + math_inputs_class).remove();
    $(editor.getBody()).find('img.Wirisformula').each(function(i, el) {
      var formula = UrlParser.parse( $(el).attr('src') ).searchObj.formula;
      var input = $( '<input type="hidden" name="math_images[]" />', { 'class': math_inputs_class } ).val( formula );
      current_slide_form.append(input);
    });
  }
  current_slide.find('._lesson_editor_placeholder').each(function() {
    if($(this).data('placeholder')) {
      temporary[temp_counter] = $(this).val();
      temp_counter++;
      $(this).val('');
    }
  });
  if(with_loader) {
    $.ajax({
       type: 'post',
      url: current_slide_form.attr('action') + action_suffix,
       timeout: 5000,
      data: current_slide_form.serialize()
     });
  } else {
    unbindLoader();
    $.ajax({
      type: 'post',
      url: current_slide_form.attr('action') + action_suffix,
      timeout: 5000,
      data: current_slide_form.serialize()
    }).always(bindLoader);
  }
  temp_counter = 0;
  current_slide.find('._lesson_editor_placeholder').each(function() {
    if($(this).data('placeholder')) {
      $(this).val(temporary[temp_counter]);
      temp_counter++;
    }
  });
}





/**
Hides the small popup containing the description of a document inside the document gallery.
@method hidePopuppina
@for LessonEditorGalleries
@param id {String} HTML id of the document
**/
function hidePopuppina(id) {
  $('#' + id + ' .popuppina, #' + id + ' .popuppina-tri').hide();
}

/**
Loads the documents from the slide to the gallery.
@method loadDocumentGalleryContent
@for LessonEditorGalleries
@param slide_id {Number} the id of the slide
**/
function loadDocumentGalleryContent(slide_id) {
  $('#inputs_for_documents').html($('#slide_in_lesson_editor_' + slide_id + ' .inputs_for_documents').html());
  for(var i = 1; i < 4; i++) {
    var doc = $('#document_' + i + '_attached_in_slide_' + slide_id);
    if(doc.length > 0) {
      $('#document_' + i + '_attached').html(doc.html()).removeClass('not_full');
    } else {
      $('#document_' + i + '_attached').html($('#document_' + i + '_attached_empty').html()).addClass('not_full');
    }
  }
}

/**
Loads the specific gallery for documents relative to a slide. The gallery is supposed to have already been loaded previously, by {{#crossLink "LessonEditorGalleries/showDocumentGalleryInLessonEditor:method"}}{{/crossLink}}
@method loadDocumentGalleryForSlideInLessonEditor
@for LessonEditorGalleries
@param slide_id {Number} the id of the slide
**/
function loadDocumentGalleryForSlideInLessonEditor(slide_id) {
  loadDocumentGalleryContent(slide_id);
  updateEffectsInsideDocumentGallery();
  $('#lesson_editor_document_gallery_container').data('slide-id', slide_id);
}

/**
Handles correct uploading process in the Lesson Editor (correct in the sense that the file is not too large and could correctly be received by the web server).
@method reloadGalleryInLessonEditor
@for LessonEditorGalleries
@param selector {String} HTML selector for the specific uploader (audio, video, image or document)
@param type {String} 'image', 'audio', 'video', or 'document'
@param gallery {String} the HTML content to be replaced into the gallery, if the uploading was successful
@param pages {Number} number of pages of the newly loaded gallery
@param count {Number} number of elements inside the gallery
@param item_id {Number} id of the newly loaded item (used only for documents)
**/
function reloadGalleryInLessonEditor(selector, type, gallery, pages, count, item_id) {
  var container = $(selector);
  if(type != 'audio' && type != 'document') {
    var dialogs_selector = (type == 'image') ? '.imageInGalleryPopUp' : '.videoInGalleryPopUp'
    $(dialogs_selector).each(function() {
      if($(this).hasClass('ui-dialog-content')) {
        $(this).dialog('destroy');
      }
    });
  }
  var gallery_scrollable = (type == 'document') ? $('.for-scroll-pain') : $('#' + type + '_gallery_content > div');
  if(gallery_scrollable.data('jsp') != undefined) {
    gallery_scrollable.data('jsp').destroy();
  }
  var container = $('#lesson_editor_' + type + '_gallery_container');
  container.data('page', 1);
  container.data('tot-pages', pages);
  if(type == 'document') {
    container.find('#document_gallery .documentsExternal').replaceWith(gallery);
    $('#document_gallery_filter').val('');
    if(count > 6) {
      initializeDocumentGalleryInLessonEditor();
    }
    container.find('#document_gallery').data('empty', false)
    $('#gallery_document_' + item_id + ' .add_remove').click();
  } else {
    container.find('#' + type + '_gallery').replaceWith(gallery);
    $('._close_' + type + '_gallery').addClass('_close_' + type + '_gallery_in_lesson_editor');
    $('._select_' + type + '_from_gallery').addClass('_add_' + type + '_to_slide');
    if(type == 'audio') {
      if(count > 6) {
        initializeAudioGalleryInLessonEditor();
      } else {
        $('.audio_gallery .scroll-pane').css('overflow', 'hidden');
      }
    }
    if(type == 'image') {
      if(count > 21) {
        initializeImageGalleryInLessonEditor();
      } else {
        $('.image_gallery .scroll-pane').css('overflow', 'hidden');
      }
    }
    if(type == 'video') {
      if(count > 6) {
        initializeVideoGalleryInLessonEditor();
      } else {
        $('.video_gallery .scroll-pane').css('overflow', 'hidden');
      }
    }
  }
  container.find('.part3 .close').click();
  container.find('.loading-square').hide();
}

/**
Hides media gallery for selected type.
@method removeGalleryInLessonEditor
@for LessonEditorGalleries
@param sti_type {String} gallery type
**/
function removeGalleryInLessonEditor(sti_type) {
  $('#lesson_editor_' + sti_type + '_gallery_container').hide();
  $('li._lesson_editor_current_slide .slide-content').children().show();
  showEverythingOutCurrentSlide();
}

/**
Resets the filter of documents in the gallery.
@method resetDocumentGalleryFilter
@for LessonEditorGalleries
@param callback {Function} to be called after ajax
@param otherwise {Function} to be called if there is no filter to reset
**/
function resetDocumentGalleryFilter(callback, otherwise) {
  var input = $('#lesson_editor_document_gallery_container #document_gallery_filter');
  if(input.val() != '') {
    input.val('');
    input.data('letters', 0);
    $.ajax({
      type: 'get',
      url: '/lessons/galleries/document/filter?word=',
      complete: function() {
        if(callback != undefined) {
          callback();
        }
      }
    });
  } else {
    if(callback != undefined) {
      callback();
    }
    if(otherwise != undefined) {
      otherwise();
    }
  }
}

/**
Shows document gallery.
@method showDocumentGalleryInLessonEditor
@for LessonEditorGalleries
**/
function showDocumentGalleryInLessonEditor() {
  var current_slide = $('li._lesson_editor_current_slide');
  current_slide.prepend('<layer class="_not_current_slide_disabled"></layer>');
  hideEverythingOutCurrentSlide();
  var gallery_container = $('#lesson_editor_document_gallery_container');
  if(gallery_container.data('loaded')) {
    if(gallery_container.data('slide-id') != current_slide.data('slide-id')) {
      var slide_id = current_slide.data('slide-id');
      loadDocumentGalleryContent(slide_id);
      $('#lesson_editor_document_gallery_container').data('slide-id', slide_id);
      resetDocumentGalleryFilter(function() {
        gallery_container.show();
        centerThis(gallery_container);
        $('li._lesson_editor_current_slide .slide-content').children().hide();
        current_slide.find('layer').remove();
      }, updateEffectsInsideDocumentGallery);
    } else {
      resetDocumentGalleryFilter(function() {
        gallery_container.show();
        centerThis(gallery_container);
        $('li._lesson_editor_current_slide .slide-content').children().hide();
        current_slide.find('layer').remove();
      });
    }
  } else {
    $.ajax({
      type: 'get',
      url: '/lessons/galleries/document'
    });
  }
}

/**
Shows media gallery for selected type.
@method showGalleryInLessonEditor
@for LessonEditorGalleries
@param obj {String} HTML selector for the button that opens the gallery (used to extract the position of the current slide)
@param sty_type {String} gallery type
**/
function showGalleryInLessonEditor(obj, sti_type) {
  $('#info_container').data('current-media-element-position', $(obj).data('position'));
  var current_slide = $('li._lesson_editor_current_slide');
  current_slide.prepend('<layer class="_not_current_slide_disabled"></layer>');
  hideEverythingOutCurrentSlide();
  var gallery_container = $('#lesson_editor_' + sti_type + '_gallery_container');
  if(gallery_container.data('loaded')) {
    gallery_container.show();
    centerThis(gallery_container);
    $('li._lesson_editor_current_slide .slide-content').children().hide();
    current_slide.find('layer').remove();
  } else {
    $.ajax({
      type: 'get',
      url: '/lessons/galleries/' + sti_type
    });
  }
}

/**
Shows the small popup containing the description of a document inside the document gallery.
@method showPopuppina
@for LessonEditorGalleries
@param id {String} HTML id of the document
**/
function showPopuppina(id) {
  var container = $('#lesson_editor_document_gallery_container');
  var parent = $('#' + id);
  var offset = parent.position();
  var document = parent.find('.documentInGallery');
  var popuppina = document.find('.popuppina');
  var triangolo = document.find('.popuppina-tri');
  if(parent.hasClass('document_attached')) {
    popuppina.css('top', ((offset.top + 44) + 'px')).show('fade', {}, 300);
    triangolo.css('-webkit-transform', ('rotate(180deg)'));
    triangolo.css('-moz-transform', ('rotate(180deg)'));
    triangolo.css('-o-transform', ('rotate(180deg)'));
    triangolo.css('-ms-transform', ('rotate(180deg)'));
    triangolo.css('top', ((offset.top + 34) + 'px')).css('left', ((offset.left + 24) + 'px')).show('fade', {}, 300);
  } else {
    var top_distance = offset.top;
    if(container.find('.for-scroll-pain').hasClass('jspScrollable')) {
      top_distance -= container.find('.for-scroll-pain').data('jsp').getContentPositionY();
    } else {
      top_distance -= 205.75;
    }
    if(top_distance < (popuppina.height() + 5)) {
      var to_top = 5;
      if(parent.prev().length == 0) {
        to_top = 0;
      }
      popuppina.css('top', ((offset.top + 44 + to_top) + 'px')).show('fade', {}, 300);
      triangolo.css('-webkit-transform', ('rotate(180deg)'));
      triangolo.css('-moz-transform', ('rotate(180deg)'));
      triangolo.css('-o-transform', ('rotate(180deg)'));
      triangolo.css('-ms-transform', ('rotate(180deg)'));
      triangolo.css('top', ((offset.top + 34 + to_top) + 'px')).css('left', ((offset.left + 24) + 'px')).show('fade', {}, 300);
    } else {
      popuppina.css('top', ((offset.top - popuppina.height() - 5) + 'px')).show('fade', {}, 300);
      triangolo.css('-webkit-transform', ('rotate(0deg)'));
      triangolo.css('-moz-transform', ('rotate(0deg)'));
      triangolo.css('-o-transform', ('rotate(0deg)'));
      triangolo.css('-ms-transform', ('rotate(0deg)'));
      triangolo.css('top', ((offset.top + 5) + 'px')).css('left', ((offset.left + 24) + 'px')).show('fade', {}, 300);
    }
  }
}

/**
Unloads the documents to the slide.
@method unLoadDocumentGalleryContent
@for LessonEditorGalleries
@param slide_id {Number} the id of the slide
**/
function unLoadDocumentGalleryContent(slide_id) {
  $('#slide_in_lesson_editor_' + slide_id + ' .inputs_for_documents').html($('#inputs_for_documents').html());
  $('#document_1_attached_in_slide_' + slide_id + ', #document_2_attached_in_slide_' + slide_id + ', #document_3_attached_in_slide_' + slide_id).remove();
  for(var i = 1; i < 4; i++) {
    var doc = $('#document_' + i + '_attached');
    if(!doc.hasClass('not_full')) {
      var new_content = '<div id="document_' + i + '_attached_in_slide_' + slide_id + '">' + doc.html() + '</div>';
      $('#slide_in_lesson_editor_' + slide_id + ' .hidden_html_for_documents').append(new_content)
    }
  }
}

/**
Updates the faded documents and the gallery is locked if three documents are loaded.
@method updateEffectsInsideDocumentGallery
@for LessonEditorGalleries
**/
function updateEffectsInsideDocumentGallery() {
  var inputs = $('#inputs_for_documents input');
  var ids = new Array();
  inputs.each(function() {
    ids.push($(this).val());
  });
  $('.documentsExternal .documentInGallery.disabled').removeClass('disabled');
  for(var i = 0; i < ids.length; i++) {
    $('#gallery_document_' + ids[i] + ' .documentInGallery').addClass('disabled');
  }
  if(!$('#lesson_editor_document_gallery_container #document_gallery').data('empty')) {
    if(inputs.length == 3) {
      $('.documentsExternal .for-scroll-pain').hide();
      $('.documentsExternal #empty_document_gallery').show();
      $('.documentsFooter .triangolo, .documentsFooter .footerLeft').hide();
    } else {
      $('.documentsExternal .for-scroll-pain').show();
      $('.documentsExternal #empty_document_gallery').hide();
      $('.documentsFooter .triangolo, .documentsFooter .footerLeft').show();
    }
  }
  var container = $('#lesson_editor_document_gallery_container');
  $('.document_attached .documentInGallery .add_remove').attr('title', container.data('title-remove'));
  $('.documentInGalleryExternal .documentInGallery:not(.disabled) .add_remove').attr('title', container.data('title-add'));
  $('.documentInGalleryExternal .documentInGallery.disabled .add_remove').attr('title', '');
}





/**
Returns the width of the image space for the kind of slide.
@method getHorizontalStandardSizeOfSlideImage
@for LessonEditorImageResizing
@param kind {String} type image into slide, accepts values: cover, image1, image2, image3, image4
@return {Number} width of the image space for this kind of slide
**/
function getHorizontalStandardSizeOfSlideImage(kind) {
  switch(kind) {
    case 'cover': slideWidth = 900;
    break;
    case 'image1': slideWidth = 420;
    break;
    case 'image2': slideWidth = 420;
    break;
    case 'image3': slideWidth = 860;
    break;
    case 'image4': slideWidth = 420;
    break;
    default: slideWidth = 900;
  }
  return slideWidth;
}

/**
Returns the height of the image space for the kind of slide.
@method getVerticalStandardSizeOfSlideImage
@for LessonEditorImageResizing
@param kind {String} type image into slide, accepts values: cover, image1, image2, image3, image4
@return {Number} height of the image space for this kind of slide
**/
function getVerticalStandardSizeOfSlideImage(kind) {
  switch(kind) {
    case 'cover': slideHeight = 560;
    break;
    case 'image1': slideHeight = 420;
    break;
    case 'image2': slideHeight = 550;
    break;
    case 'image3': slideHeight = 550;
    break;
    case 'image4': slideHeight = 265;
    break;
    default: slideHeight = 590;
  }
  return slideHeight;
}

/**
Check if image ratio is bigger then kind ratio.
@method isHorizontalMask
@for LessonEditorImageResizing
@param width {Number} width of the image
@param height {Number} height of the image
@param kind {String} type image into slide, accepts values: cover, image1, image2, image3, image4
@return {Boolean} true if the image is horizontal, false if vertical
**/
function isHorizontalMask(width, height, kind) {
  var ratio = width / height;
  var slideRatio = 0;
  switch(kind) {
    case 'cover': slideRatio = 1.6;
    break;
    case 'image1': slideRatio = 1;
    break;
    case 'image2': slideRatio = 0.75;
    break;
    case 'image3': slideRatio = 1.55;
    break;
    case 'image4': slideRatio = 1.55;
    break;
    default: slideRatio = 1.5;
  }
  return (ratio >= slideRatio);
}

/**
Gets scaled height to slide images.
@method resizeHeight
@for LessonEditorImageResizing
@param image_width {Number} width of the image
@param image_height {Number} height of the image
@param kind {String} type image into slide, accepts values: cover, image1, image2, image3, image4
@return {Number} scaled height
**/
function resizeHeight(width, height, kind) {
  return parseInt((height * getHorizontalStandardSizeOfSlideImage(kind)) / width) + 1;
}

/**
Gets scaled width to slide images.
@method resizeWidth
@for LessonEditorImageResizing
@param width {Number} width of the image
@param height {Number} height of the image
@param kind {String} type image into slide, accepts values: cover, image1, image2, image3, image4
@return {Number} scaled width
**/
function resizeWidth(width, height, kind) {
  return parseInt((width * getVerticalStandardSizeOfSlideImage(kind)) / height) + 1;
}





/**
Inizializes jQueryUI <b>sortable</b> function on top navigation numbers, so that they can be sorted (see also {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadySlidesNavigator:method"}}{{/crossLink}} and {{#crossLink "LessonEditorSlidesNavigation"}}{{/crossLink}}).
@method initializeSortableNavs
@for LessonEditorJqueryAnimations
**/
function initializeSortableNavs() {
  $('#heading, #heading .scroll-pane').css('width', (parseInt($window.outerWidth()) - 50) + 'px');
  var slides_numbers = $('#slide-numbers');
  var slides_amount = slides_numbers.find('li.navNumbers').length;
  slides_numbers.css('width', '' + ((parseInt(slides_amount + 1) * 32) - 28) + 'px');
  var add_last_button = $('._add_new_slide_options_in_last_position');
  if(parseInt(slides_numbers.css('width')) < (parseInt($window.outerWidth()) - 100)) {
    add_last_button.css('left', '' + (slides_numbers.find('li.navNumbers').last().position().left + 40) + 'px');
  }
  slides_numbers.sortable({
    items: '._slide_nav_sortable',
    axis: 'x',
    stop: function(event, ui) {
      var previous = ui.item.prev();
      var new_position = 0;
      var old_position = parseInt(ui.item.find('a._slide_nav').html());
      if(parseInt(previous.find('a._slide_nav').html()) == 1) {
        new_position = 2;
      } else {
        var previous_item_position = parseInt(previous.find('a._slide_nav').html());
        if(old_position > previous_item_position) {
          new_position = previous_item_position + 1;
        } else {
          new_position = previous_item_position;
        }
      }
      saveCurrentSlide('', false);
      if(old_position != new_position) {
        stopMediaInCurrentSlide();
        $.ajax({
          type: 'post',
          url: '/lessons/' + $('#info_container').data('lesson-id') + '/slides/' + ui.item.find('a._slide_nav').data('slide-id') + '/move/' + new_position
        });
      } else {
        slideTo(ui.item.find('a._slide_nav').data('slide-id'));
      }
    }
  });
}

/**
Method that deinscribes the image.
@method lessonEditorDeinscribeImage
@for LessonEditorJqueryAnimations
@param place_id {String} HTML id for the container to make draggable
**/
function lessonEditorDeinscribeImage(place_id) {
  var place = $('#' + place_id);
  var full_place = place.find('.mask');
  var alignable = full_place.find('.alignable');
  var image = alignable.find('img');
  var kind = $('li._lesson_editor_current_slide').data('kind');
  if(!full_place.is(':visible') || kind == 'cover') {
    return;
  }
  $('#' + place_id + ' .inscribed').val('false');
  var new_title = $('#' + place_id + ' .deinscribe').data('inscribe-title');
  $('#' + place_id + ' .deinscribe').attr('title', new_title).removeClass('deinscribe').addClass('inscribe');
  var align_val;
  var this_align_side;
  var other_align_side;
  var orientation_val;
  if(full_place.hasClass('vertical')) {
    orientation_val = resizeHeight(place.data('width'), place.data('height'), kind);
    align_val = (getVerticalStandardSizeOfSlideImage(kind) - orientation_val) / 2;
    this_align_side = 'top';
    other_align_side = 'left';
    image.removeAttr('width').attr('height', orientation_val);
  } else {
    orientation_val = resizeWidth(place.data('width'), place.data('height'), kind);
    align_val = (getHorizontalStandardSizeOfSlideImage(kind) - orientation_val) / 2;
    this_align_side = 'left';
    other_align_side = 'top';
    image.removeAttr('height').attr('width', orientation_val);
  }
  alignable.css(this_align_side, align_val).css(other_align_side, 0);
  $('#' + place_id + ' .align').val(align_val);
  alignable.draggable('destroy');
  makeDraggable(place_id);
}

/**
Method that inscribes the image.
@method lessonEditorInscribeImage
@for LessonEditorJqueryAnimations
@param place_id {String} HTML id for the container to make draggable
**/
function lessonEditorInscribeImage(place_id) {
  var place = $('#' + place_id);
  var full_place = place.find('.mask');
  var alignable = full_place.find('.alignable');
  var image = alignable.find('img');
  var kind = $('li._lesson_editor_current_slide').data('kind');
  if(!full_place.is(':visible') || kind == 'cover') {
    return;
  }
  $('#' + place_id + ' .inscribed').val('true');
  var new_title = $('#' + place_id + ' .inscribe').data('deinscribe-title');
  $('#' + place_id + ' .inscribe').attr('title', new_title).removeClass('inscribe').addClass('deinscribe');
  var align_val;
  var this_align_side;
  var other_align_side;
  var orientation_val;
  if(full_place.hasClass('vertical')) {
    orientation_val = resizeWidth(place.data('width'), place.data('height'), kind);
    align_val = (getHorizontalStandardSizeOfSlideImage(kind) - orientation_val) / 2;
    this_align_side = 'left';
    other_align_side = 'top';
    image.removeAttr('height').attr('width', orientation_val);
  } else {
    orientation_val = resizeHeight(place.data('width'), place.data('height'), kind);
    align_val = (getVerticalStandardSizeOfSlideImage(kind) - orientation_val) / 2;
    this_align_side = 'top';
    other_align_side = 'left';
    image.removeAttr('width').attr('height', orientation_val);
  }
  alignable.css(this_align_side, align_val).css(other_align_side, 0);
  $('#' + place_id + ' .align').val(align_val);
  alignable.draggable('destroy');
  makeDraggable(place_id);
}

/**
Inizializes jQueryUI <b>draggable</b> function on slide image containers.
@method makeDraggable
@for LessonEditorJqueryAnimations
@param place_id {String} HTML id for the container to make draggable
**/
function makeDraggable(place_id) {
  var full_place = $('#' + place_id + ' .mask');
  if(!full_place.is(':visible')) {
    return;
  }
  var image = $('#' + place_id + ' .mask img');
  var inscribed = (full_place.find('.deinscribe').length > 0);
  var side;
  var limit_max;
  var limit_min;
  if(full_place.hasClass('vertical')) {
    if(inscribed) {
      side = 'left';
      limit_min = 0;
      limit_max = full_place.width() - image.width();
    } else {
      side = 'top';
      limit_min = full_place.height() - image.height();
      limit_max = 0;
    }
  } else {
    if(inscribed) {
      side = 'top';
      limit_min = 0;
      limit_max = full_place.height() - image.height();
    } else {
      side = 'left';
      limit_min = full_place.width() - image.width();
      limit_max = 0;
    }
  }
  $('#' + place_id + ' .mask .alignable').draggable({
    axis: ((side == 'top') ? 'y' : 'x'),
    cursor: 'move',
    start: function() {
      $('#' + place_id + ' .mask img').css('cursor', 'move');
      $('#' + place_id + ' .alignable').data('rolloverable', false);
      $('#' + place_id + ' span').hide();
    },
    stop: function() {
      $('#' + place_id + ' .mask img').css('cursor', 'url(https://mail.google.com/mail/images/2/openhand.cur), move');
      $('#' + place_id + ' .alignable').data('rolloverable', true);
      $('#' + place_id + ' span').show();
      var myself = $(this);
      var offset;
      if(side == 'top') {
        offset = myself.position().top;
        if(offset < limit_min) {
          offset = limit_min;
          myself.animate({
            top: limit_min
          }, 100);
        }
        if(offset > limit_max) {
          offset = limit_max;
          myself.animate({
            top: limit_max
          }, 100);
        }
      } else {
        offset = myself.position().left;
        if(offset < limit_min) {
          offset = limit_min;
          myself.animate({
            left: limit_min
          }, 100);
        }
        if(offset > limit_max) {
          offset = limit_max;
          myself.animate({
            left: limit_max
          }, 100);
        }
      }
      $('#' + place_id + ' .align').val(offset);
    }
  });
}





/**
Asynchronously loads current slide, previous and following.
@method loadSlideAndAdhiacentInLessonEditor
@for LessonEditorSlideLoading
@param slide_id {Number} id in the database of the current slide, used to extract the HTML id
**/
function loadSlideAndAdhiacentInLessonEditor(slide_id) {
  var slide = $('#slide_in_lesson_editor_' + slide_id);
  loadSlideInLessonEditor(slide);
  loadSlideInLessonEditor(slide.prev());
  loadSlideInLessonEditor(slide.next());
}

/**
Asynchronous slide loading. It checks if the slide has been loaded or not.
@method loadSlideInLessonEditor
@for LessonEditorSlideLoading
@param slide {Object} slide to be loaded
**/
function loadSlideInLessonEditor(slide) {
  if(slide.length > 0 && !slide.data('loaded')) {
    $.ajax({
      type: 'get',
      url: '/lessons/' + $('#info_container').data('lesson-id') + '/slides/' + slide.data('slide-id') + '/load'
    });
  }
}





/**
Initialize slides position to center.
@method initLessonEditorPositions
@for LessonEditorSlidesNavigation
**/
function initLessonEditorPositions() {
  var outer_width = parseInt($window.outerWidth());
  var outer_height = parseInt($window.outerHeight());
  $('#main').css('width', outer_width);
  $('ul#slides').css('width', (($('ul#slides li').length + 2) * 1000));
  $('ul#slides').css('top', ((outer_height / 2) - 295) + 'px');
  $('ul#slides.new').css('top', ((outer_height / 2) - 335) + 'px');
  $('#footer').css('top', (outer_height - 44) + 'px').css('width', outer_width + 'px');
  if(outer_width > 1000) {
    $('ul#slides li:first').css('margin-left', ((outer_width - 900) / 2) + 'px');
    $('ul#slides.new li:first').css('margin-left', ((outer_width - 900) / 2) + 'px');
  }
}

/**
Re-initialize slides position to center after ajax events.
@method reInitializeSlidePositionsInLessonEditor
@for LessonEditorSlidesNavigation
**/
function reInitializeSlidePositionsInLessonEditor() {
  $('ul#slides').css('width', (($('ul#slides li').length + 2) * 1000));
  $('ul#slides li').each(function(index){
    $(this).data('position', (index + 1));
  });
}

/**
Scrolls navigation scrollPane ({{#crossLink "LessonEditorSlidesNavigation"}}{{/crossLink}}) when moving to another slide.
@method scrollPaneUpdate
@for LessonEditorSlidesNavigation
@param trigger_element {String} HTML selector for the element which triggers the scroll
@return {Boolean} false, probably to stop further actions
**/
function scrollPaneUpdate(trigger_element) {
  var not_current = $(trigger_element);
  if($('.slides.active').data('position') < not_current.parent('li').data('position')) {
    $('#nav_list_menu').data('jsp').scrollByX(30);
  } else {
    $('#nav_list_menu').data('jsp').scrollByX(-30);
  }
  return false;
}

/**
Moves to a slide, update current slide in top navigation.
@method slideTo
@for LessonEditorSlidesNavigation
@param slide_id {Number} id in the database of the slide, used to extract the HTML id
@param callback {Object} callback function, to be executed after the slide (for instance, this function is used to call {{#crossLink "LessonEditorCurrentSlide/showNewSlideOptions:method"}}{{/crossLink}})
**/
function slideTo(slide_id, callback) {
  var tiny_tool = $('#ta-' + $('li._lesson_editor_current_slide').data('slide-id') + '_external');
  if(tiny_tool.length > 0) {
    tiny_tool.hide();
  }
  loadSlideAndAdhiacentInLessonEditor(slide_id);
  var slide = $('#slide_in_lesson_editor_' + slide_id);
  var position = slide.data('position');
  if (position == 1) {
    marginReset = 0;
  } else {
    marginReset = (-((position - 1) * 1010)) + 'px';
  }
  $('ul#slides').animate({
    marginLeft: marginReset
  }, 1500, function() {
    if(typeof(callback) != 'undefined') {
      callback();
    }
  });
  $('ul#slides li').animate({
    opacity: 0.4,
  }, 150, function() {
    $(this).find('.buttons').fadeOut();
    if($(this).find('layer').length == 0) {
      $(this).prepend('<layer class="_not_current_slide"></layer>');
    } else {
      if($(this).find('layer._not_current_slide_disabled').length > 0) {
        $(this).find('layer._not_current_slide_disabled').removeClass('_not_current_slide_disabled').addClass('_not_current_slide');
      }
    }
    $('a._lesson_editor_current_slide_nav').removeClass('_lesson_editor_current_slide_nav active');
    $('#slide_in_nav_lesson_editor_' + slide_id).addClass('_lesson_editor_current_slide_nav active');
  });
  $('ul#slides li:eq(' + (position - 1) + ')').animate({
    opacity: 1,
  }, 500, function() {
    $(this).find('.buttons').fadeIn();
    $(this).find('layer').remove();
    $('li._lesson_editor_current_slide').removeClass('_lesson_editor_current_slide active');
    $('#slide_in_lesson_editor_' + slide_id).addClass('_lesson_editor_current_slide active');
  });
}





/**
TinyMCE callback to clean spans containing classes for font size: these classes are attached to the first ol, ul, p
@method cleanTinyMCESpanTagsFontSize
@for LessonEditorTinyMCE
@param editor {Object} tinyMCE instance
**/
function cleanTinyMCESpanTagsFontSize(editor) {
  var spans = $(editor.getBody()).find('span.size1, span.size2, span.size3, span.size4, span.size5, span.size6');
  var sizes = ['size1', 'size2', 'size3', 'size4', 'size5', 'size6'];
  var sizes_class = sizes.join(' ');
  if(spans.length > 0) {
    spans.each(function() {
      var my_sizes = $(this).attr('class').split(' ').filter(function(i) {
        return sizes.indexOf(i) > -1;
      }).join(' ');
      $(this).removeClass(my_sizes);
      $(this).parents('.mceContentBody ul, .mceContentBody ol, .mceContentBody p').removeClass(sizes_class).addClass(my_sizes);
    });
  }
}

/**
Initialize tinyMCE editor for a single textarea.
@method initTinymce
@for LessonEditorTinyMCE
@param tiny_id {String} HTML id of the tinyMCE textarea
**/
function initTinymce(tiny_id) {
  var plugins = 'pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,';
  plugins += 'insertdatetime,preview,media,searchreplace,print,paste,directionality,fullscreen,';
  plugins += 'noneditable,visualchars,nonbreaking,xhtmlxtras,template,tiny_mce_wiris';
  var buttons = 'fontsizeselect,forecolor,justifyleft,justifycenter,justifyright,justifyfull,';
  buttons += 'bold,italic,underline,numlist,bullist,link,unlink,charmap,tiny_mce_wiris_formulaEditor';
  tinyMCE.init({
    mode: 'exact',
    elements: tiny_id,
    element_format: 'xhtml',
    theme: 'advanced',
    editor_selector: 'tinymce',
    skin: 'desy',
    plugins: plugins,
    custom_shortcuts: false,
    paste_preprocess: function(pl, o) {
      o.content = stripTagsForCutAndPaste(o.content, '');
    },
    theme_advanced_buttons1: buttons,
    theme_advanced_toolbar_location: 'external',
    theme_advanced_toolbar_align: 'left',
    theme_advanced_statusbar_location: false,
    theme_advanced_resizing: true,
    theme_advanced_font_sizes: '13px=.size1,17px=.size2,21px=.size3,25px=.size4,29px=.size5,35px=.size6',
    setup: function(ed) {
      ed.onInit.add(function(ed, e) {
        $('#' + tiny_id + '_ifr').attr('scrolling', 'no');
      });
      ed.onNodeChange.add(function(ed, cm, e) {
        cleanTinyMCESpanTagsFontSize(ed);
        $(ed.getBody()).find('a').addClass('target_blank_mce');
      });
      ed.onKeyUp.add(function(ed, e) {
        handleTinyMCEOveflow(ed, tiny_id);
      });
      ed.onClick.add(function(ed, e) {
        var textarea = $('#' + tiny_id);
        if(textarea.data('placeholder')) {
          ed.setContent('');
          textarea.data('placeholder', false);
        }
      });
    }
  });
}

/**
TinyMCE callback to show warning when texearea content exceeds the available space. Adds a red border to the textarea.This function is used in tinyMCE setup ({{#crossLink "LessonEditorTinyMCE/initTinymce:method"}}{{/crossLink}}).
@method handleTinyMCEOveflow
@for LessonEditorTinyMCE
@param inst {Object} tinyMCE instance
@param tiny_id {Number} HTML id of the tinyMCE textarea
**/
function handleTinyMCEOveflow(inst, tiny_id) {
  var maxH = 420;
  if($('textarea#' + tiny_id).parents('.slide-content.audio').length > 0) {
    maxH = 329;
  }
  if(inst.getBody().scrollHeight > maxH) {
    $('#' + tiny_id + '_tbl').css('border-left', '1px solid red').css('border-right', '1px solid red');
    $('#' + tiny_id + '_tbl tr.mceFirst td').css('border-top', '1px solid red');
    $('#' + tiny_id + '_tbl tr.mceLast td').css('border-bottom', '1px solid red');
  } else {
    $('#' + tiny_id + '_tbl').css('border-left', '1px solid #EFEFEF').css('border-right', '1px solid #EFEFEF');
    $('#' + tiny_id + '_tbl tr.mceFirst td').css('border-top', '1px solid #EFEFEF');
    $('#' + tiny_id + '_tbl tr.mceLast td').css('border-bottom', '1px solid #EFEFEF');
  }
}

/**
Function to strip tags in a text pasted inside TinyMCE.
@method stripTagsForCutAndPaste
@for LessonEditorTinyMCE
@param str {String} string to be stripped
@param allowed_tags {Array} allowed HTML tags
**/
function stripTagsForCutAndPaste(str, allowed_tags) {
  var key = '', allowed = false;
  var matches = [];
  var allowed_array = [];
  var allowed_tag = '';
  var i = 0;
  var k = '';
  var html = '';
  var replacer = function (search, replace, str) {
    return str.split(search).join(replace);
  };
  if (allowed_tags) {
    allowed_array = allowed_tags.match(/([a-zA-Z0-9]+)/gi);
  }
  str += '';
  matches = str.match(/(<\/?[\S][^>]*>)/gi);
  for(key in matches) {
    if(isNaN(key)) {
      continue;
    }
    html = matches[key].toString();
    allowed = false;
    for(k in allowed_array) {
      allowed_tag = allowed_array[k];
      i = -1;
      if(i != 0) {
        i = html.toLowerCase().indexOf('<' + allowed_tag + '>');
      }
      if(i != 0) {
        i = html.toLowerCase().indexOf('<' + allowed_tag + ' ');
      }
      if(i != 0) {
        i = html.toLowerCase().indexOf('</' + allowed_tag);
      }
      if(i == 0) {
        allowed = true;
        break;
      }
    }
    if(!allowed) {
      str = replacer(html, '', str);
    }
  }
  return str;
}
