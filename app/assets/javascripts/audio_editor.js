/**
This module contains javascript functions used to animate the Audio Editor. The editing of an audio consists in cutting and connecting together different elements of type audio (referred to as <b>audio components</b>): each component has a unique <b>identifier</b>, to be distinguished by the ID in the database of the corresponding audio.
<br/><br/>
Each audio component contains a <b>cutter</b> (used to select a portion of the original audio), the standard player controls, and a <b>sorting handle</b>. To use the controls of a component, first it must be <b>selected</b> (using the function {{#crossLink "AudioEditorComponents/selectAudioEditorComponent:method"}}{{/crossLink}}): if a component is not selected, it's shown with opacity and without the player controls. The functionality of sorting components is handled in {{#crossLink "AudioEditorDocumentReady/audioEditorDocumentReadyGeneral:method"}}{{/crossLink}}; the functionalities of player commands, together with the most important functionalities of the cutter, are located in the module {{#crossLinkModule "players"}}{{/crossLinkModule}} (class {{#crossLink "PlayersAudioEditor"}}{{/crossLink}}); the only functionalities of the cutter located in this module are found in the class {{#crossLink "AudioEditorCutters"}}{{/crossLink}} and in the method {{#crossLink "AudioEditorDocumentReady/audioEditorDocumentReadyCutters:method"}}{{/crossLink}} (functionality of precision arrows).
<br/><br/>
On the top of the right column are positioned the time durations (updated with {{#crossLink "AudioEditorComponents/changeDurationAudioEditorComponent:method"}}{{/crossLink}}), ad the button 'plus' used to open the audio gallery (see the class {{#crossLink "AudioEditorGalleries"}}{{/crossLink}} and the method {{#crossLink "AudioEditorDocumentReady/audioEditorDocumentReadyGeneral:method"}}{{/crossLink}}).
<br/><br/>
On the bottom of the right column are positioned the controls for the <b>global preview</b> (which plays all the components globally). Similarly to the module {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}, before playing the global preview the system must enter in <b>preview mode</b>: the difference is that in the Audio Editor this mode is switched automatically by the system, whereas in the Video Editor it's the user who decides to enter and leave the preview mode. To enter in preview mode we use the method {{#crossLink "AudioEditorPreview/enterAudioEditorPreviewMode:method"}}{{/crossLink}}, which calls {{#crossLink "AudioEditorPreview/switchAudioComponentsToPreviewMode:method"}}{{/crossLink}} or each component. A component in preview mode can be <b>selected</b> (using a differente method respect to the normal component selection: see {{#crossLink "AudioEditorPreview/selectAudioEditorComponentInPreviewMode:method"}}{{/crossLink}}). Each component in the global preview is played using the method {{#crossLink "AudioEditorPreview/startAudioEditorPreview:method"}}{{/crossLink}} (to which we pass the component to start with); the main part of the functionality of passing from a component to the next one during the global preview is handled in the module {{#crossLinkModule "players"}}{{/crossLinkModule}} (more specificly, in the method {{#crossLink "PlayersAudioEditor/initializeActionOfMediaTimeUpdaterInAudioEditor:method"}}{{/crossLink}}.
<br/><br/>
As for the other Element Editors ({{#crossLinkModule "image-editor"}}{{/crossLinkModule}}, {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}) the core of the process of committing changes is handled in the module {{#crossLinkModule "media-element-editor"}}{{/crossLinkModule}} (more specificly in the class {{#crossLink "MediaElementEditorForms"}}{{/crossLink}}); the part of this functionality specific for the Audio Editor is handled in {{#crossLink "MediaElementEditorDocumentReady/mediaElementEditorDocumentReady:method"}}{{/crossLink}}.
@module audio-editor
**/





/**
This function adds a new audio component to the timeline: it extracts the empty audio component hidden in the template, replaces in it the values of the new audio component, and appends it right after the selected component. If there are no selected components, the new one is appended at the end of the timeline.
@method addComponentInAudioEditor
@for AudioEditorComponents
@param audio_id {Number} the ID of the audio in the database
@param ogg {String} the path of the attached audio in format ogg
@param m4a {String} the path of the attached audio in format mp4
@param duration {Number} the integer duration of the audio
@param title {String} the title of the audio extracted from the database
**/
function addComponentInAudioEditor(audio_id, ogg, m4a, duration, title) {
  var next_position = $('#info_container').data('last-component-id') + 1;
  var selected_component = $('._audio_editor_component._selected');
  $('#info_container').data('last-component-id', next_position);
  var empty_component = $($('#empty_component_for_audio_editor').html());
  empty_component.attr('id', ('audio_component_' + next_position));
  empty_component.find('source[type="audio/ogg"]').attr('src', ogg);
  empty_component.find('source[type="audio/mp4"]').attr('src', m4a);
  empty_component.data('duration', 0);
  empty_component.data('from', 0);
  empty_component.data('to', duration);
  empty_component.data('max-to', duration);
  empty_component.find('._title').html(title);
  empty_component.removeClass('_audio_editor_empty_component').addClass('_audio_editor_component');
  empty_component.find('._current_time').html(secondsToDateString(0));
  empty_component.find('._total_length').html(secondsToDateString(duration));
  empty_component.find('._cutter_from').html(secondsToDateString(0));
  empty_component.find('._cutter_to').html(secondsToDateString(duration));
  var to_be_appended = fillAudioEditorSingleParameter('audio_id', next_position, audio_id);
  to_be_appended += fillAudioEditorSingleParameter('from', next_position, 0);
  to_be_appended += fillAudioEditorSingleParameter('to', next_position, duration);
  to_be_appended += fillAudioEditorSingleParameter('position', next_position, next_position);
  if(selected_component.length == 0) {
    $('#audio_editor_timeline .jspPane').append(empty_component);
  } else {
    selected_component.after(empty_component);
  }
  empty_component.append(to_be_appended);
  empty_component.find('audio').load();
  initializeAudioEditorCutter(next_position);
  reloadAudioEditorComponentPositions(empty_component);
  changeDurationAudioEditorComponent(empty_component, duration);
  if(selected_component.length == 0) {
    resizeLastComponentInAudioEditor();
  }
  if($('._audio_editor_component').length == 1) {
    enableCommitAndPreviewInAudioEditor();
  }
  setTimeout(function() {
    scrollToFirstSelectedAudioEditorComponent();
    selectAudioEditorComponent(empty_component);
    empty_component.find('._title').effect('highlight', {color: '#41A62A'}, 1000);
  }, 500);
}

/**
This function changes the duration of a component, and updates the global durations.
@method changeDurationAudioEditorComponent
@for AudioEditorComponents
@param component {Object} the component
@param new_duration {Number} the new duration
**/
function changeDurationAudioEditorComponent(component, new_duration) {
  var old_duration = component.data('duration');
  var total_length = $('#info_container').data('total-length');
  total_length -= old_duration;
  total_length += new_duration;
  component.data('duration', new_duration);
  $('#info_container').data('total-length', total_length);
  $('#visual_audio_editor_total_length').html(secondsToDateString(total_length));
}

/**
Function that deselects all the audio components.
@method deselectAllAudioEditorComponents
@for AudioEditorComponents
**/
function deselectAllAudioEditorComponents() {
  var selected_component = $('._audio_editor_component._selected');
  if(selected_component.length > 0) {
    var pause = selected_component.find('._media_player_pause_in_audio_editor_preview');
    if(pause.is(':visible')) {
      pause.click();
    }
    deselectAllAudioEditorCursors(getAudioComponentIdentifier(selected_component));
  }
  $('._audio_editor_component._selected ._content').removeClass('current');
  $('._audio_editor_component._selected ._box_ghost').show();
  $('._audio_editor_component._selected ._sort_handle').removeClass('current');
  $('._audio_editor_component._selected ._player_content').css('opacity', 0.2);
  $('.msie ._audio_editor_component._selected ._double_slider .ui-slider-range').css('opacity', 0.4);
  $('._audio_editor_component._selected ._controls').css('visibility', 'hidden');
  $('._audio_editor_component._selected').removeClass('_selected');
}

/**
Function that creates a single input field to be inserted in the empty audio component during the process of construction of a new one (similar to {{#crossLink "VideoEditorComponents/fillVideoEditorSingleParameter:method"}}{{/crossLink}}; used in {{#crossLink "AudioEditorComponents/addComponentInAudioEditor:method"}}{{/crossLink}}).
@method fillAudioEditorSingleParameter
@for AudioEditorComponents
@param input {String} the specific input to be filled (for example, <i>audio_id</i>, <i>from</i>, or <i>to</i>)
@param identifier {Number} the identifier of the component
@param value {String} the HTML value to be assigned to the input
@return {String} the resulting input written in HTML
**/
function fillAudioEditorSingleParameter(input, identifier, value) {
  return '<input id="' + input + '_' + identifier + '" class="_audio_component_input_' + input + '" type="hidden" value="' + value + '" name="' + input + '_' + identifier + '"/>';
}

/**
An HTML5 audio is loaded only when necessary: this function extracts from the data the sources of the audio, and loads it (unless the component had already been loaded previously)
@method loadAudioComponentIfNotLoadedYet
@for AudioEditorComponents
@param component {Object} the component to load
**/
function loadAudioComponentIfNotLoadedYet(component) {
  if(!component.data('loaded')) {
    var m4a = component.data('m4a');
    var ogg = component.data('ogg');
    component.find('source[type="audio/mp4"]').attr('src', m4a);
    component.find('source[type="audio/ogg"]').attr('src', ogg);
    component.find('audio').load();
    component.data('loaded', true);
  }
}

/**
Reloads the correct positions of the components after sorting them.
@method reloadAudioEditorComponentPositions
@for AudioEditorComponents
**/
function reloadAudioEditorComponentPositions() {
  var components = $('._audio_editor_component');
  components.each(function(index) {
    $(this).data('position', (index + 1));
    $(this).find('._audio_component_input_position').val(index + 1);
    $(this).find('._audio_component_icon').html(index + 1);
  });
}

/**
Removes a component from the timeline.
@method removeAudioEditorComponent
@for AudioEditorComponents
@param component {Object} the component to be removed
**/
function removeAudioEditorComponent(component) {
  if(component.hasClass('_selected')) {
    component.find('._media_player_pause_in_audio_editor_preview').click();
  }
  component.hide('fade', {}, 500, function() {
    changeDurationAudioEditorComponent(component, 0);
    $(this).remove();
    reloadAudioEditorComponentPositions();
    if($('._audio_editor_component').length == 0) {
      disableCommitAndPreviewInAudioEditor();
    }
    resizeLastComponentInAudioEditor();
  });
}

/**
This function removes the margin bottom from the last component in the timeline: this is necessary to handle with precision the JScrollPain (see {{#crossLink "AudioEditorScrollpain"}}{{/crossLink}}).
@method resizeLastComponentInAudioEditor
@for AudioEditorComponents
**/
function resizeLastComponentInAudioEditor() {
  $('._audio_editor_component._last').last().removeClass('_last')
  $('._audio_editor_component').last().addClass('_last');
}

/**
Function that selects an audio component.
@method selectAudioEditorComponent
@for AudioEditorComponents
@param component {Object} the component to be selected
**/
function selectAudioEditorComponent(component) {
  loadAudioComponentIfNotLoadedYet(component);
  deselectAllAudioEditorComponents();
  component.addClass('_selected');
  component.find('._content').addClass('current');
  component.find('._box_ghost').hide();
  component.find('._sort_handle').addClass('current');
  component.find('._player_content').css('opacity', 1);
  if( $html.hasClass('msie') ) {
    component.find('._double_slider .ui-slider-range').css('opacity', 1);
  }
  component.find('._controls').css('visibility', 'visible');
  selectAudioEditorCursor(getAudioComponentIdentifier(component));
}





/**
Changes the value of the left margin of an audio component, and updates its duration using {{#crossLink "AudioEditorComponents/changeDurationAudioEditorComponent:method"}}{{/crossLink}}.
@method cutAudioComponentLeftSide
@for AudioEditorCutters
@param identifier {Number} the unique identifier of the component
@param pos {Number} the new position of the left margin of the component (input <i>from</i>)
**/
function cutAudioComponentLeftSide(identifier, pos) {
  var component = $('#audio_component_' + identifier);
  var new_duration = component.data('to') - pos;
  component.data('from', pos);
  component.find('._cutter_from').html(secondsToDateString(pos));
  component.find('._audio_component_input_from').val(pos);
  changeDurationAudioEditorComponent(component, new_duration);
}

/**
Changes the value of the right margin of an audio component, and updates its duration using {{#crossLink "AudioEditorComponents/changeDurationAudioEditorComponent:method"}}{{/crossLink}}.
@method cutAudioComponentRightSide
@for AudioEditorCutters
@param identifier {Number} the unique identifier of the component
@param pos {Number} the new position of the right margin of the component (input <i>to</i>)
**/
function cutAudioComponentRightSide(identifier, pos) {
  var component = $('#audio_component_' + identifier);
  var new_duration = pos - component.data('from');
  component.data('to', pos);
  component.find('._cutter_to').html(secondsToDateString(pos));
  component.find('._audio_component_input_to').val(pos);
  changeDurationAudioEditorComponent(component, new_duration);
}

/**
Deselects all the cursors in a component.
@method deselectAllAudioEditorCursors
@for AudioEditorCutters
@param id {Number} the unique identifier of the component
**/
function deselectAllAudioEditorCursors(id) {
  $('#audio_component_' + id + ' .ui-slider-handle').removeClass('selected');
  $('#audio_component_' + id + ' ._cutter_from, #audio_component_' + id + ' ._cutter_to, #audio_component_' + id + ' ._current_time').removeClass('selected');
}

/**
Selects the central cursor of an audio component.
@method selectAudioEditorCursor
@for AudioEditorCutters
@param id {Number} the unique identifier of the component
**/
function selectAudioEditorCursor(id) {
  deselectAllAudioEditorCursors(id);
  $('#audio_component_' + id + ' ._media_player_slider .ui-slider-handle').addClass('selected');
  $('#audio_component_' + id + ' ._current_time').addClass('selected');
}

/**
Selects the left handle of an audio component.
@method selectAudioEditorLeftHandle
@for AudioEditorCutters
@param id {Number} the unique identifier of the component
**/
function selectAudioEditorLeftHandle(id) {
  deselectAllAudioEditorCursors(id);
  $('#audio_component_' + id + ' ._double_slider .ui-slider-handle').first().addClass('selected');
  $('#audio_component_' + id + ' ._cutter_from').addClass('selected');
}

/**
Selects the right handle of an audio component.
@method selectAudioEditorRightHandle
@for AudioEditorCutters
@param id {Number} the unique identifier of the component
**/
function selectAudioEditorRightHandle(id) {
  deselectAllAudioEditorCursors(id);
  $($('#audio_component_' + id + ' ._double_slider .ui-slider-handle')[1]).addClass('selected');
  $('#audio_component_' + id + ' ._cutter_to').addClass('selected');
}





/**
Initializes the whole Audio Editor, calling all the subinitializers
@method audioEditorDocumentReady
@for AudioEditorDocumentReady
**/
function audioEditorDocumentReady() {
  audioEditorDocumentReadyPreview();
  audioEditorDocumentReadyCutters();
  audioEditorDocumentReadyGeneral();
}

/**
Initializer for the precision arrows in the cutters. For the other functionalities related to cutters, see {{#crossLink "PlayersAudioEditor"}}{{/crossLink}}.
@method audioEditorDocumentReadyCutters
@for AudioEditorDocumentReady
**/
function audioEditorDocumentReadyCutters() {
  $body.on('click', '._audio_editor_component ._precision_arrow_left', function() {
    var component = $(this).parents('._audio_editor_component');
    var identifier = getAudioComponentIdentifier(component);
    var single_slider = component.find('._media_player_slider');
    var double_slider = component.find('._double_slider');
    if(single_slider.find('.ui-slider-handle').hasClass('selected')) {
      var resp = single_slider.slider('value');
      if(resp > 0 && resp > double_slider.slider('values', 0)) {
        selectAudioComponentCutterHandle(component, resp - 1);
      }
    } else if(double_slider.find('.ui-slider-handle').first().hasClass('selected')) {
      var resp = double_slider.slider('values', 0);
      if(resp > 0) {
        double_slider.slider('values', 0, resp - 1);
        cutAudioComponentLeftSide(identifier, resp - 1);
      }
    } else {
      var resp = double_slider.slider('values', 1);
      if(resp > double_slider.slider('values', 0) + 1) {
        if(single_slider.slider('value') == resp) {
          selectAudioComponentCutterHandle(component, resp - 1);
        }
        double_slider.slider('values', 1, resp - 1);
        cutAudioComponentRightSide(identifier, resp - 1);
      }
    }
  });
  $body.on('click', '._audio_editor_component ._precision_arrow_right', function() {
    var component = $(this).parents('._audio_editor_component');
    var identifier = getAudioComponentIdentifier(component);
    var duration = component.data('max-to');
    var single_slider = component.find('._media_player_slider');
    var double_slider = component.find('._double_slider');
    if(single_slider.find('.ui-slider-handle').hasClass('selected')) {
      var resp = single_slider.slider('value');
      if(resp < duration && resp < double_slider.slider('values', 1)) {
        selectAudioComponentCutterHandle(component, resp + 1);
      }
    } else if(double_slider.find('.ui-slider-handle').first().hasClass('selected')) {
      var resp = double_slider.slider('values', 0);
      if(resp < double_slider.slider('values', 1) - 1) {
        if(single_slider.slider('value') == resp) {
          selectAudioComponentCutterHandle(component, resp + 1);
        }
        double_slider.slider('values', 0, resp + 1);
        cutAudioComponentLeftSide(identifier, resp + 1);
      }
    } else {
      var resp = double_slider.slider('values', 1);
      if(resp < duration) {
        double_slider.slider('values', 1, resp + 1);
        cutAudioComponentRightSide(identifier, resp + 1);
      }
    }
  });
}

/**
Initializes the JQueryUi animations (sorting components), and all the effects of selection of components (see {{#crossLink "AudioEditorComponents/selectAudioEditorComponent:method"}}{{/crossLink}} and similar methods).
@method audioEditorDocumentReadyGeneral
@for AudioEditorDocumentReady
**/
function audioEditorDocumentReadyGeneral() {
  if($.browser === 'msie') {
    $('._audio_editor_component ._double_slider .ui-slider-range').css('opacity', 0.4);
  }
  $body.on('click', '._close_audio_gallery_in_audio_editor', function() {
    closeGalleryInAudioEditor();
    var expanded_audio = $('._audio_expanded_in_gallery');
    if(expanded_audio.length > 0) {
      expanded_audio.removeClass('_audio_expanded_in_gallery');
      var audio_id = expanded_audio.attr('id');
      stopMedia('#' + audio_id + ' audio');
      $('#' + audio_id + ' ._expanded').hide();
    }
  });
  $body.on('mouseover', '._audio_editor_component ._box_ghost', function() {
    $(this).parent().find('._sort_handle').addClass('current');
  });
  $body.on('mouseout', '._audio_editor_component ._box_ghost', function(e) {
    if($(this).is(':visible') && !$(e.relatedTarget).hasClass('_remove')) {
      $(this).parent().find('._sort_handle').removeClass('current');
    }
  });
  $body.on('click', '._audio_editor_component ._sort_handle', function() {
    selectAudioEditorComponent($(this).parent().parent());
  });
  $body.on('click', '._audio_editor_component ._box_ghost', function() {
    selectAudioEditorComponent($(this).parent());
  });
  $body.on('click', '._audio_editor_component ._remove', function() {
    removeAudioEditorComponent($(this).parent());
  });
  $body.on('click', '#add_new_audio_component_in_audio_editor', function() {
    if(!$('#add_new_audio_component_in_audio_editor').hasClass('disabled')) {
      var selected_component = $('._audio_editor_component._selected');
      if(selected_component.length > 0) {
        selected_component.find('._media_player_pause_in_audio_editor_preview').click();
      }
      if($('#audio_editor_gallery_container').data('loaded')) {
        showGalleryInAudioEditor();
      } else {
        $.ajax({
          type: 'get',
          url: '/audios/galleries/audio'
        });
      }
    }
  });
  $body.on('click', '._add_audio_component_to_audio_editor', function() {
    stopMedia('._audio_expanded_in_gallery audio');
    $('._audio_expanded_in_gallery ._expanded').hide();
    $('._audio_expanded_in_gallery').removeClass('_audio_expanded_in_gallery');
    var audio_id = $(this).data('audio-id');
    closeGalleryInAudioEditor();
    stopMedia('#gallery_audio_' + audio_id + ' audio');
    $('#gallery_audio_' + audio_id + ' ._expanded').hide();
    addComponentInAudioEditor(audio_id, $(this).data('ogg'), $(this).data('m4a'), $(this).data('duration'), $(this).data('title'));
  });
  resizeLastComponentInAudioEditor();
  $('#audio_editor_timeline').jScrollPane({
    autoReinitialise: true
  });
  $('#audio_editor_timeline .jspPane').sortable({
    scroll: true,
    handle: '._sort_handle',
    axis: 'y',
    cursor: 'move',
    start: function(event, ui) {
      selectAudioEditorComponent($(ui.item));
    },
    stop: function(event, ui) {
      var my_item = $(ui.item);
      resizeLastComponentInAudioEditor();
      var boolean1 = (my_item.next().length == 0);
      var boolean2 = (my_item.data('position') != $('._audio_editor_component').length);
      var boolean3 = (my_item.next().data('position') != (my_item.data('position') + 1));
      if(boolean1 && boolean2 || !boolean1 && boolean3) {
        reloadAudioEditorComponentPositions();
        $('._audio_editor_component ._title').effect('highlight', {color: '#41A62A'}, 1000);
      }
    }
  });
  if( $html.hasClass('msie') ) {
    $('._audio_editor_component ._double_slider .ui-slider-range').css('opacity', 0.4);
  }
}

/**
Initializes the functionalities of the preview (see also {{#crossLink "AudioEditorPreview"}}{{/crossLink}}).
@method audioEditorDocumentReadyPreview
@for AudioEditorDocumentReady
**/
function audioEditorDocumentReadyPreview() {
  $body.on('click', '#start_audio_editor_preview', function() {
    if(!$(this).hasClass('disabled')) {
      enterAudioEditorPreviewMode();
    }
  });
  $body.on('click', '#rewind_audio_editor_preview', function() {
    if(!$(this).hasClass('disabled')) {
      var selected_component = $('._audio_editor_component').first();
      selectAudioEditorComponent(selected_component);
      disableCommitAndPreviewInAudioEditor();
      scrollToFirstSelectedAudioEditorComponent(function() {
        enableCommitAndPreviewInAudioEditor();
        var from = selected_component.data('from');
        selected_component.find('._media_player_slider').slider('value', from);
        selected_component.find('._current_time').html(secondsToDateString(from));
        setCurrentTimeToMedia(selected_component.find('audio'), selected_component.find('._media_player_slider').slider('value'));
      });
    }
  });
  $body.on('click', '#stop_audio_editor_preview', function() {
    leaveAudioEditorPreviewMode();
  });
}





/**
Sets the correct position of the gallery: used while showing and closing the audio gallery (see respectively {{#crossLink "AudioEditorGalleries/showGalleryInAudioEditor:method"}}{{/crossLink}} and {{#crossLink "AudioEditorGalleries/closeGalleryInAudioEditor:method"}}{{/crossLink}}.
@method calculateNewPositionGalleriesInAudioEditor
@for AudioEditorGalleries
**/
function calculateNewPositionGalleriesInAudioEditor() {
  $('#audio_editor_gallery_container').css('left', (($window.width() - 940) / 2) + 'px');
}

/**
Closes the gallery.
@method closeGalleryInAudioEditor
@for AudioEditorGalleries
**/
function closeGalleryInAudioEditor() {
  $('._audio_editor_bottom_bar').show();
  $('#audio_editor_gallery_container').hide('fade', {}, 250, function() {
    setBackAllZIndexesInAudioEditor();
  });
}

/**
Shows the gallery.
@method showGalleryInAudioEditor
@for AudioEditorGalleries
**/
function showGalleryInAudioEditor() {
  $('._audio_editor_bottom_bar').hide();
  $('#audio_editor_gallery_container').show();
  setToZeroAllZIndexesInAudioEditor();
  calculateNewPositionGalleriesInAudioEditor();
}





/**
Extracts the unique identifier of a component using its HTML id.
@method getAudioComponentIdentifier
@for AudioEditorGeneral
@param component {Object} the component from which we want to extract the identifier
@return {Number} the identifier
**/
function getAudioComponentIdentifier(component) {
  var id = component.attr('id').split('_');
  return id[id.length - 1];
}





/**
Disables the buttons <i>commit</i> and <i>prewiev</i>.
@method disableCommitAndPreviewInAudioEditor
@for AudioEditorGraphics
**/
function disableCommitAndPreviewInAudioEditor() {
  $('#empty_audio_editor').show();
  $('._commit_media_element_editor').hide();
  $('#start_audio_editor_preview').addClass('disabled');
  $('#rewind_audio_editor_preview').addClass('disabled');
}

/**
Enables the buttons <i>commit</i> and <i>preview</i>.
@method enableCommitAndPreviewInAudioEditor
@for AudioEditorGraphics
**/
function enableCommitAndPreviewInAudioEditor() {
  $('#empty_audio_editor').hide();
  $('._commit_media_element_editor').show();
  $('#start_audio_editor_preview').removeClass('disabled');
  $('#rewind_audio_editor_preview').removeClass('disabled');
}

/**
Function that sets the correct value to all the z-indexes: there are in total three hidden layers for each component, one global, plus two sliders in each cutter, and each of them needs its specific z-index. Used at any time the components are hidden and need to be shown (for instance {{#crossLink "AudioEditorGalleries/showGalleryInAudioEditor:method"}}{{/crossLink}}).
@method setBackAllZIndexesInAudioEditor
@for AudioEditorGraphics
**/
function setBackAllZIndexesInAudioEditor() {
  $('._audio_editor_component ._remove').css('z-index', 101);
  $('._audio_editor_component ._box_ghost').css('z-index', 100);
  $('._audio_editor_component ._media_player_slider_disabler').css('z-index', 99);
  $('._audio_editor_component ._double_slider').css('z-index', 98);
  $('._audio_editor_component ._under_double_slider').css('z-index', 97);
  $('._audio_editor_component ._media_player_slider').css('z-index', 96);
}

/**
Function that sets to zero the value to all the z-indexes: there are in total three hidden layers for each component, one global, plus two sliders in each cutter, and each of them needs its specific z-index. Used at any time the components are shown and need to be hidden (for instance {{#crossLink "AudioEditorGalleries/closeGalleryInAudioEditor:method"}}{{/crossLink}}).
@method setToZeroAllZIndexesInAudioEditor
@for AudioEditorGraphics
**/
function setToZeroAllZIndexesInAudioEditor() {
  $('._audio_editor_component ._remove').css('z-index', 0);
  $('._audio_editor_component ._box_ghost').css('z-index', 0);
  $('._audio_editor_component ._media_player_slider_disabler').css('z-index', 0);
  $('._audio_editor_component ._double_slider').css('z-index', 0);
  $('._audio_editor_component ._under_double_slider').css('z-index', 0);
  $('._audio_editor_component ._media_player_slider').css('z-index', 0);
}





/**
Deselects all the components in preview mode (it corresponds to {{#crossLink "AudioEditorComponents/deselectAllAudioEditorComponents:method"}}{{/crossLink}}).
@method deselectAllAudioEditorComponentsInPreviewMode
@for AudioEditorPreview
**/
function deselectAllAudioEditorComponentsInPreviewMode() {
  $('._audio_editor_component ._audio_component_icon').css('visibility', 'hidden');
  $('._audio_editor_component').each(function() {
    deselectAllAudioEditorCursors(getAudioComponentIdentifier($(this)));
  });
  $('._audio_editor_component ._media_player_slider .ui-slider-handle').hide();
  $('._audio_editor_component').css('opacity', 0.2);
  $('._audio_editor_component ._content').removeClass('current');
  $('._audio_editor_component').removeClass('_selected');
}

/**
Function that sets all the graphical details that characterize the preview mode. It automatically calls the function {{#crossLink "AudioEditorPreview/startAudioEditorPreview:method"}}{{/crossLink}}, passing it as parameter the selected component, or the first one if there is no selected component.
@method enterAudioEditorPreviewMode
@for AudioEditorPreview
**/
function enterAudioEditorPreviewMode() {
  $('#info_container').data('in-preview', true);
  $('#audio_editor_box_ghost').show();
  $('._commit_media_element_editor').hide();
  $('#add_new_audio_component_in_audio_editor').addClass('disabled');
  $('#start_audio_editor_preview').addClass('disabled');
  $('#rewind_audio_editor_preview').addClass('disabled');
  scrollToFirstSelectedAudioEditorComponent(function() {
    $('#audio_editor_timeline .jspVerticalBar').css('visibility', 'hidden');
    var current_global_preview_time = getAudioEditorGlobalPreviewTime();
    $('#info_container').data('current-preview-time', current_global_preview_time);
    var selected_component = $('._audio_editor_component._selected');
    if(selected_component.length == 0) {
      selected_component = $('._audio_editor_component').first();
    }
    selected_component = $('#' + selected_component.attr('id'));
    deselectAllAudioEditorComponents();
    switchAudioComponentsToPreviewMode();
    $('#visual_audio_editor_current_time').show();
    $('#visual_audio_editor_current_time').html(secondsToDateString(current_global_preview_time));
    $('#start_audio_editor_preview').hide();
    $('#start_audio_editor_preview').removeClass('disabled');
    $('#stop_audio_editor_preview').show();
    $('#visual_audio_editor_total_length').css('color', '#787575');
    $('#visual_audio_editor_current_time').css('color', 'white');
    if(current_global_preview_time == 0) {
      var first_component_from = selected_component.data('from');
      selected_component.find('._media_player_slider').slider('value', first_component_from);
      selected_component.find('._current_time').html(secondsToDateString(first_component_from));
    }
    loadAudioComponentIfNotLoadedYet(selected_component);
    setCurrentTimeToMedia(selected_component.find('audio'), selected_component.find('._media_player_slider').slider('value'));
    startAudioEditorPreview(selected_component);
  });
}

/**
Gets the current time in the global preview, using the information relative to the selected component and the position of the cursor inside its cutter.
@method getAudioEditorGlobalPreviewTime
@for AudioEditorPreview
**/
function getAudioEditorGlobalPreviewTime() {
  var selected_component = $('._audio_editor_component._selected');
  if(selected_component.length == 0) {
    return 0;
  } else {
    var flag = true;
    var tot = 0;
    $('._audio_editor_component').each(function() {
      if($(this).hasClass('_selected')) {
        flag = false;
        tot += ($(this).find('._media_player_slider').slider('value') - $(this).data('from'));
      } else if(flag) {
        tot += $(this).data('duration');
      }
    });
    return tot;
  }
}

/**
Increases of one second the global preview timer.
@method increaseAudioEditorPreviewTimer
@for AudioEditorPreview
**/
function increaseAudioEditorPreviewTimer() {
  var data_container = $('#info_container');
  var global_time = data_container.data('current-preview-time');
  $('#visual_audio_editor_current_time').html(secondsToDateString(global_time + 1));
  data_container.data('current-preview-time', global_time + 1);
}

/**
Function that sets back to the regular value all the graphical details that characterize the preview mode.
@method leaveAudioEditorPreviewMode
@for AudioEditorPreview
@param forced_component {Object} the component that must be selected after leaving the preview mode: if not specified, the function selects the first component.
**/
function leaveAudioEditorPreviewMode(forced_component) {
  var selected_component = $('#' + $('._audio_editor_component._selected').attr('id'));
  selected_component.find('audio')[0].pause();
  deselectAllAudioEditorComponentsInPreviewMode();
  switchBackAudioComponentsFromPreviewMode();
  $('#info_container').data('current-preview-time', 0);
  $('#visual_audio_editor_current_time').html(secondsToDateString(0));
  $('#visual_audio_editor_current_time').css('color', '#787575');
  $('#visual_audio_editor_total_length').css('color', 'white');
  $('#visual_audio_editor_current_time').hide();
  $('._commit_media_element_editor').show();
  $('#add_new_audio_component_in_audio_editor').removeClass('disabled');
  $('#start_audio_editor_preview').show();
  $('#stop_audio_editor_preview').hide();
  $('#rewind_audio_editor_preview').removeClass('disabled');
  $('#audio_editor_timeline .jspVerticalBar').css('visibility', 'visible');
  if(forced_component != undefined) {
    scrollToFirstSelectedAudioEditorComponent(function() {
      selectAudioEditorComponent($('#' + forced_component));
    });
  } else {
    selectAudioEditorComponent(selected_component);
  }
  $('#audio_editor_box_ghost').hide();
  $('#info_container').data('in-preview', false);
}

/**
Selects a component in preview mode (it corresponds to {{#crossLink "AudioEditorComponents/selectAudioEditorComponent:method"}}{{/crossLink}}).
@method selectAudioEditorComponentInPreviewMode
@for AudioEditorPreview
@param component {Object} the component to be selected
**/
function selectAudioEditorComponentInPreviewMode(component) {
  component.addClass('_selected');
  component.find('._content').addClass('current');
  component.css('opacity', 1);
  component.find('._audio_component_icon').css('visibility', 'visible');
  component.find('._media_player_slider .ui-slider-handle').show();
  selectAudioEditorCursor(getAudioComponentIdentifier(component));
}

/**
Starts the preview from a given component.
@method startAudioEditorPreview
@for AudioEditorPreview
@param component {Object} the component from which the preview starts.
**/
function startAudioEditorPreview(component) {
  selectAudioEditorComponentInPreviewMode(component);
  followPreviewComponentsWithVerticalScrollInAudioEditor();
  var audio = component.find('audio');
  if(audio[0].error) {
    showLoadingMediaErrorPopup(audio[0].error.code, 'audio');
    $('#stop_audio_editor_preview').click();
  } else {
    audio[0].play();
  }
}

/**
Switches all the components in preview mode.
@method switchAudioComponentsToPreviewMode
@for AudioEditorPreview
**/
function switchAudioComponentsToPreviewMode() {
  $('._audio_editor_component ._player_content').css('opacity', 1);
  $('.msie ._audio_editor_component ._double_slider .ui-slider-range').css('opacity', 1);
  $('._audio_editor_component').css('opacity', 0.2);
  $('._audio_editor_component ._remove').hide();
  $('._audio_editor_component ._media_player_slider .ui-slider-handle').hide();
  $('._audio_editor_component ._audio_component_icon').css('visibility', 'hidden');
}

/**
Switches all the components back to regular mode.
@method switchBackAudioComponentsFromPreviewMode
@for AudioEditorPreview
**/
function switchBackAudioComponentsFromPreviewMode() {
  $('._audio_editor_component').css('opacity', 1);
  $('._audio_editor_component ._player_content').css('opacity', 0.2);
  $('.msie ._audio_editor_component ._double_slider .ui-slider-range').css('opacity', 0.4);
  $('._audio_editor_component ._remove').show();
  $('._audio_editor_component ._media_player_slider .ui-slider-handle').show();
  $('._audio_editor_component ._audio_component_icon').css('visibility', 'visible');
}





/**
Function used to keep updated the position of the scroll with the current component played in the global preview. It checks a condition and then uses {{#crossLink "AudioEditorScrollpain/scrollToFirstSelectedAudioEditorComponent:method"}}{{/crossLink}}.
@method followPreviewComponentsWithVerticalScrollInAudioEditor
@for AudioEditorScrollpain
**/
function followPreviewComponentsWithVerticalScrollInAudioEditor() {
  if($('._audio_editor_component._selected').data('position') - parseInt($('#audio_editor_timeline').data('jsp').getContentPositionY() / 113) == 4) {
    scrollToFirstSelectedAudioEditorComponent();
  }
}

/**
Hand made function that simply scrolls to a component and executes a callback. This function needed to be written since the original JScrollPain doesn't provide it (!).
@method scrollToFirstSelectedAudioEditorComponent
@for AudioEditorScrollpain
@param callback {Function} the callback to be executed after scrolling
**/
function scrollToFirstSelectedAudioEditorComponent(callback) {
  var selected_component = $('._audio_editor_component._selected');
  var scroll_pain = $('#audio_editor_timeline');
  if(scroll_pain.find('.jspVerticalBar').length == 0) {
    if(callback != undefined) {
      callback();
    }
    return;
  }
  if(selected_component.length == 0) {
    if($('#info_container').data('in-preview')) {
      if(scroll_pain.data('jsp').getPercentScrolledY() != 0) {
        if(callback != undefined) {
          scroll_pain.jScrollPane().bind('panescrollstop', function() {
            callback();
            scroll_pain.jScrollPane().unbind('panescrollstop');
          });
        }
        scroll_pain.data('jsp').scrollToPercentY(0, true);
      } else if(callback != undefined) {
        callback();
      }
    } else {
      if(scroll_pain.data('jsp').getPercentScrolledY() != 1) {
        if(callback != undefined) {
          scroll_pain.jScrollPane().bind('panescrollstop', function() {
            callback();
            scroll_pain.jScrollPane().unbind('panescrollstop');
          });
        }
        scroll_pain.data('jsp').scrollToPercentY(100, true);
      } else if(callback != undefined) {
        callback();
      }
    }
  } else {
    var scroll_target = (selected_component.data('position') - 1) * 113;
    if(scroll_pain.data('jsp').getContentPositionY() != scroll_target) {
      if(callback != undefined) {
        scroll_pain.jScrollPane().bind('panescrollstop', function() {
          callback();
          scroll_pain.jScrollPane().unbind('panescrollstop');
        });
      }
      scroll_pain.data('jsp').scrollToY(scroll_target, true);
    } else if(callback != undefined) {
      callback();
    }
  }
}
