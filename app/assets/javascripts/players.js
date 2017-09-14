/**
This module contains the javascript functions and initializers used in the <b>media players</b> all over the application. The model can be divided into three main classes:
<ul>
  <li>{{#crossLink "PlayersGeneral"}}{{/crossLink}}, used in the generic players, for instance in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}} and {{#crossLinkModule "lesson-viewer"}}{{/crossLinkModule}}</li>
  <li>{{#crossLink "PlayersAudioEditor"}}{{/crossLink}}, used in the players of the module {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}} (only players of kind <b>audio</b>)</li>
  <li>{{#crossLink "PlayersVideoEditor"}}{{/crossLink}}, used in the players of the module {{#crossLinkModule "video-editor"}}{{/crossLinkModule}} (mainly players of kind <b>video</b>, but also of kind <b>audio</b> for the background audio track).</li>
</ul>
@module players
**/





/**
This method is fired each time the audio component player receives an event of <b>timeupdate</b>. There are two cases of use of this method:
<ul>
  <li>if the Audio Editor <b>is not in preview mode</b>, it operates as a normal player (see {{#crossLink "PlayersGeneral/initializeActionOfMediaTimeUpdater:method"}}{{/crossLink}}), with very slight differences due to the different environment</li>
  <li>if we are <b>in preview mode</b>, the method acts as a counterpart of {{#crossLink "AudioEditorPreview/startAudioEditorPreview:method"}}{{/crossLink}}: at any time the seconds increase, the method updates the timer using {{#crossLink "AudioEditorPreview/increaseAudioEditorPreviewTimer:method"}}{{/crossLink}}; when the audio is over, if it's not playing the last component, the method calls {{#crossLink "AudioEditorPreview/startAudioEditorPreview:method"}}{{/crossLink}} for the following one.</li>
</ul>
@method initializeActionOfMediaTimeUpdaterInAudioEditor
@for PlayersAudioEditor
@param media {String} HTML selector for the audio
@param identifier {Number} unique identifier for the audio component (see {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}})
@param force_parsed_int {Boolean} forces the last second of the audio; normally it's <i>false</i>, except the case in which the duration of the audio is very close to the biggest lower integer (for instance, the duration is 10.01, which is very close to 10): in this case, the signal that the audio ended <b>is not received directly by the current method</b>, but rather by the event handler <b>ended</b> initialized in the end of {{#crossLink "PlayersAudioEditor/initializeAudioEditorCutter:method"}}{{/crossLink}}
**/
function initializeActionOfMediaTimeUpdaterInAudioEditor(media, identifier, force_parsed_int) {
  var component = $('#audio_component_' + identifier);
  var audio_cut_to = component.data('to');
  var parsed_int = parseInt(media.currentTime);
  if(force_parsed_int) {
    parsed_int = audio_cut_to;
  }
  if($('#info_container').data('in-preview')) {
    if(parsed_int > component.find('._media_player_slider').slider('value')) {
      increaseAudioEditorPreviewTimer();
      if(parsed_int == audio_cut_to) {
        var old_start = component.data('from');
        component.find('audio')[0].pause();
        component.find('._current_time').html(secondsToDateString(old_start));
        component.find('._media_player_slider').slider('value', old_start);
        setCurrentTimeToMedia(component.find('audio'), old_start);
        var next_component = component.next();
        if(next_component.length > 0) {
          deselectAllAudioEditorComponentsInPreviewMode();
          var new_start = next_component.data('from');
          next_component.find('._media_player_slider').slider('value', new_start);
          next_component.find('._current_time').html(secondsToDateString(new_start));
          loadAudioComponentIfNotLoadedYet(next_component);
          setCurrentTimeToMedia(next_component.find('audio'), new_start);
          startAudioEditorPreview(next_component);
        } else {
          leaveAudioEditorPreviewMode($('._audio_editor_component').first().attr('id'));
        }
      } else {
        component.find('._current_time').html(secondsToDateString(parsed_int));
        component.find('._media_player_slider').slider('value', parsed_int);
      }
    }
  } else if(component.data('playing')) {
    if(parsed_int == (audio_cut_to)) {
      var initial_time = component.data('from');
      component.find('._media_player_pause_in_audio_editor_preview').click();
      component.find('._media_player_slider').slider('value', initial_time);
      component.find('._current_time').html(secondsToDateString(initial_time));
      setCurrentTimeToMedia($(media), initial_time);
    } else if(!component.find('._media_player_play_in_audio_editor_preview').is(':visible')) {
      component.find('._current_time').html(secondsToDateString(parsed_int));
      component.find('._media_player_slider').slider('value', parsed_int);
    }
  }
}

/**
Initializes two sliders: one (JQueryUi single slider) for the <b>cursor</b>, and one (JQueryUi double slider) for the <b>cutting handles</b>. It also initializes how to handle the event <b>ended</b> associated to the audio.
@method initializeAudioEditorCutter
@for PlayersAudioEditor
@param identifier {Number} the unique identifier of the audio component (see {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}})
**/
function initializeAudioEditorCutter(identifier) {
  var component = $('#audio_component_' + identifier);
  var single_slider = component.find('._media_player_slider');
  var double_slider = component.find('._double_slider');
  var audio_max_to = component.data('max-to');
  var play = component.find('._media_player_play_in_audio_editor_preview');
  single_slider.slider({
    min: 0,
    max: audio_max_to,
    value: component.data('from'),
    slide: function(event, ui) {
      if(play.is(':visible')) {
        component.find('._current_time').html(secondsToDateString(0));
        setCurrentTimeToMedia(component.find('audio'), ui.value);
      }
    }
  });
  double_slider.slider({
    min: 0,
    max: audio_max_to,
    range: true,
    values: [component.data('from'), component.data('to')],
    start: function(event, ui) {
      if($(ui.handle).next('.ui-slider-handle').length == 0) {
        selectAudioEditorRightHandle(identifier);
      } else {
        selectAudioEditorLeftHandle(identifier);
      }
    },
    slide: function(event, ui) {
      var left_val = ui.values[0];
      var right_val = ui.values[1];
      var cursor_val = component.find('._media_player_slider').slider('value');
      if(left_val != component.data('from')) {
        if(cursor_val < left_val) {
          selectAudioComponentCutterHandle(component, left_val);
        }
        component.find('._cutter_from').html(secondsToDateString(left_val));
      } else {
        if(cursor_val > right_val) {
          selectAudioComponentCutterHandle(component, right_val);
        }
        component.find('._cutter_to').html(secondsToDateString(right_val));
      }
    },
    stop: function(event, ui) {
      var left_val = ui.values[0];
      var right_val = ui.values[1];
      if(left_val != component.data('from')) {
        if(left_val == right_val) {
          component.find('._double_slider').slider('values', 0, left_val - 1);
          left_val -= 1;
        }
        cutAudioComponentLeftSide(identifier, left_val);
      }
      if(right_val != component.data('to')) {
        if(left_val == right_val) {
          component.find('._double_slider').slider('values', 1, right_val + 1);
          right_val += 1;
        }
        cutAudioComponentRightSide(identifier, right_val);
      }
    }
  });
  double_slider.find('.ui-slider-range').mousedown(function(e) {
    return false;
  });
  initializeMediaTimeUpdaterInAudioEditor(identifier);
  component.find('audio').bind('ended', function() {
    if($('#info_container').data('in-preview')) {
      initializeActionOfMediaTimeUpdaterInAudioEditor(component.find('audio')[0], identifier, true);
    } else {
      try {
        var initial_time = component.data('from');
        component.find('._media_player_pause_in_audio_editor_preview').click();
        component.find('._media_player_slider').slider('value', initial_time);
        component.find('._current_time').html(secondsToDateString(initial_time));
        setCurrentTimeToMedia($(component.find('audio')), initial_time);
      } catch(err) {
        console.log('error stopping media: ' + err);
      }
    }
  });
}

/**
This is the method that associates {{#crossLink "PlayersAudioEditor/initializeActionOfMediaTimeUpdaterInAudioEditor:method"}}{{/crossLink}} to the event of <b>timeupdate</b>. Notice that the method waits until he receives the event <b>loadedmetadata</b> before working.
@method initializeMediaTimeUpdaterInAudioEditor
@for PlayersAudioEditor
@param identifier {Number} the unique identifier of the audio component (see {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}})
**/
function initializeMediaTimeUpdaterInAudioEditor(identifier) {
  media = $('#audio_component_' + identifier + ' audio');
  if(media.readyState != 0) {
    media[0].addEventListener('timeupdate', function() {
      initializeActionOfMediaTimeUpdaterInAudioEditor(this, identifier, false);
    }, false);
  } else {
    media.on('loadedmetadata', function() {
      media[0].addEventListener('timeupdate', function() {
        initializeActionOfMediaTimeUpdaterInAudioEditor(this, identifier, false);
      }, false);
    });
  }
}

/**
Method that <b>updates the audio cursor</b>, in case one of the two handles passes over the cursor (the cursor must follow the handle).
@method selectAudioComponentCutterHandle
@for PlayersAudioEditor
@param component {Object} the JQuery object representing the component
@param val {Number} the value to be assigned
**/
function selectAudioComponentCutterHandle(component, val) {
  setCurrentTimeToMedia(component.find('audio'), val);
  component.find('._media_player_slider').slider('value', val);
  component.find('._current_time').html(secondsToDateString(val));
}





/**
Method that logs all the possible events of a given media.
@method mediaEventsLogger
@for PlayersCommon
@param media {Object} the jquery object representing a <b>video</b> or an <b>audio</b> tag
**/
function mediaEventsLogger(media) {
  media.on('loadstart', function() {console.log('loadstart');});
  media.on('progress', function() {console.log('progress');});
  media.on('suspend', function() {console.log('suspend');});
  media.on('abort', function() {console.log('abort');});
  media.on('error', function() {console.log('error');});
  media.on('emptied', function() {console.log('emptied');});
  media.on('stalled', function() {console.log('stalled');});
  media.on('loadedmetadata', function() {console.log('loadedmetadata');});
  media.on('loadeddata', function() {console.log('loadeddata');});
  media.on('canplay', function() {console.log('canplay');});
  media.on('canplaythrough', function() {console.log('canplaythrough');});
  media.on('playing', function() {console.log('playing');});
  media.on('waiting', function() {console.log('waiting');});
  media.on('seeking', function() {console.log('seeking');});
  media.on('seeked', function() {console.log('seeked');});
  media.on('ended', function() {console.log('ended');});
  media.on('durationchange', function() {console.log('durationchange');});
  media.on('timeupdate', function() {console.log('timeupdate');});
  media.on('play', function() {console.log('play');});
  media.on('pause', function() {console.log('pause');});
  media.on('ratechange', function() {console.log('ratechange');});
  media.on('volumechange', function() {console.log('volumechange');});
}

/**
Sets a time to any media in any environment. Notice that the method waits until he receives the event <b>loadedmetadata</b> before working.
@method setCurrentTimeToMedia
@for PlayersCommon
@param media {Object} the jquery object representing a <b>video</b> or an <b>audio</b> tag
@param seek {Float} the time to be set
**/
function setCurrentTimeToMedia(media, seek) {
  if(media[0].readyState != 0) {
    media[0].currentTime = validSeek(media, seek);
  } else {
    media.on('loadedmetadata', function() {
      media[0].currentTime = validSeek(media, seek);
    });
  }
}

/**
It shows an alert with error details, in case a media returned error.
@method showLoadingMediaErrorPopup
@for PlayersCommon
@param code {Number} the code associated to the error (it can be 1, 2, 3 or 4)
@param type {String} either <b>'audio'</b> or <b>'video'</b>
**/
function showLoadingMediaErrorPopup(code, type) {
  var captions = $captions;
  var message = captions.data('media-error-code-' + code);
  var popup = captions.data('media-error-' + type);
  popup = popup.replace('%{code}', '' + code);
  popup = popup.replace('%{message}', message);
  alert(popup);
}

/**
Stops all media in the page.
@method stopAllMedia
@for PlayersCommon
**/
function stopAllMedia() {
  $('audio, video').each(function() {
    stopMedia(this);
  });
}

/**
Submethod of {{#crossLink "PlayersCommon/setCurrentTimeToMedia:method"}}{{/crossLink}}, used because some browsers (Internet Explorer for instance), get broken if the value of seek is not included in the <b>seekable interval</b>.
@method validSeek
@for PlayersCommon
@param media {Object} the jquery object representing a <b>video</b> or an <b>audio</b> tag
@param seek {Float} the value to be assigned to the media
**/
function validSeek(media, seek) {
  var confidence = 0.001;
  var minStart = media[0].seekable.start(0);
  var maxEnd = media[0].seekable.end(0);
  if (seek < minStart) {
    seek = minStart + confidence;
  } else if (seek > maxEnd) {
    seek = maxEnd - confidence;
  }
  return seek;
}





/**
Initializer for buttons inside a cutter in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}.
@method playersDocumentReadyAudioEditor
@for PlayersDocumentReady
**/
function playersDocumentReadyAudioEditor() {
  $body.on('click', '._media_player_play_in_audio_editor_preview', function() {
    var component = $(this).parents('._audio_editor_component');
    var identifier = getAudioComponentIdentifier(component);
    var audio = component.find('audio');
    if(audio[0].error) {
      showLoadingMediaErrorPopup(audio[0].error.code, 'audio');
    } else {
      $(this).hide();
      $('#start_audio_editor_preview').addClass('disabled');
      $('#rewind_audio_editor_preview').addClass('disabled');
      component.data('playing', true);
      component.find('._media_player_slider_disabler').show();
      component.find('._media_player_rewind_in_audio_editor_preview').hide();
      component.find('._media_player_pause_in_audio_editor_preview').show();
      deselectAllAudioEditorCursors(identifier);
      var single_slider = component.find('._media_player_slider');
      if(audio[0].currentTime < single_slider.slider('value')) {
        setCurrentTimeToMedia(audio, single_slider.slider('value'));
      }
      audio[0].play();
    }
  });
  $body.on('click', '._media_player_pause_in_audio_editor_preview', function() {
    $(this).hide();
    $('#start_audio_editor_preview').removeClass('disabled');
    $('#rewind_audio_editor_preview').removeClass('disabled');
    var component = $(this).parents('._audio_editor_component');
    var identifier = getAudioComponentIdentifier(component);
    component.data('playing', false);
    component.find('._media_player_slider_disabler').hide();
    component.find('._media_player_rewind_in_audio_editor_preview').show();
    component.find('._media_player_play_in_audio_editor_preview').show();
    selectAudioEditorCursor(identifier);
    component.find('audio')[0].pause();
    if(component.data('to') != parseInt(component.find('audio')[0].currentTime)) {
      setCurrentTimeToMedia(component.find('audio'), component.find('._media_player_slider').slider('value'));
    }
  });
  $body.on('click', '._media_player_rewind_in_audio_editor_preview', function() {
    var component = $(this).parents('._audio_editor_component');
    var initial_time = component.data('from');
    component.find('._media_player_slider').slider('value', initial_time);
    setCurrentTimeToMedia(component.find('audio'), initial_time);
    component.find('._current_time').html(secondsToDateString(initial_time));
  });
  $body.on('click', '._audio_editor_component ._double_slider .ui-slider-range', function(e) {
    var component = $(this).parents('._audio_editor_component');
    var identifier = getAudioComponentIdentifier(component);
    var percent = component.data('max-to') * (e.pageX - component.find('._double_slider').offset().left) / component.find('._double_slider').width();
    resp = parseInt(percent);
    if(percent - parseInt(percent) > 0.5) {
      resp += 1;
    }
    selectAudioEditorCursor(identifier);
    selectAudioComponentCutterHandle(component, resp);
  });
}

/**
Initializer for buttons inside any player.
@method playersDocumentReadyGeneral
@for PlayersDocumentReady
**/
function playersDocumentReadyGeneral() {
  $body.on('click', '._media_player_play', function() {
    var container_id = $(this).parent().attr('id');
    var type = $(this).parent().data('media-type');
    var media = $('#' + container_id + ' ' + type);
    if(media[0].error) {
      showLoadingMediaErrorPopup(media[0].error.code, type);
    } else {
      $('#' + container_id + ' ._media_player_slider_disabler').show();
      $('#' + container_id + ' ._media_player_pause').show();
      $(this).hide();
      media[0].play();
    }
  });
  $body.on('click', '._media_player_pause', function() {
    $(this).hide();
    var container_id = $(this).parent().attr('id');
    var type = $(this).parent().data('media-type');
    $('#' + container_id + ' ._media_player_slider_disabler').hide();
    $('#' + container_id + ' ._media_player_play').show();
    $('#' + container_id + ' ' + type)[0].pause();
  });
  $body.on('click', '._video_full_screen', function() {
    var container_id = $(this).parent().attr('id');
    $('#' + container_id + ' video').fullScreen(true);
  });
}

/**
Initializer for buttons inside a cutter in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}.
@method playersDocumentReadyVideoEditor
@for PlayersDocumentReady
**/
function playersDocumentReadyVideoEditor() {
  $body.on('click', '._media_player_play_in_video_editor_preview', function() {
    var identifier = getVideoComponentIdentifier($(this).parents('._video_component_cutter').attr('id'));
    var video = $('#video_component_' + identifier + '_preview video');
    if(video[0].error){
      showLoadingMediaErrorPopup(video[0].error.code, 'video');
    } else {
      $(this).hide();
      $(this).parents('._video_component_cutter').data('playing', true);
      $('#video_component_' + identifier + '_cutter ._media_player_rewind_in_video_editor_preview').hide();
      $('#video_component_' + identifier + '_cutter ._media_player_slider_disabler').show();
      $('#video_component_' + identifier + '_cutter ._media_player_pause_in_video_editor_preview').show();
      $('#video_component_' + identifier + '_cutter .ui-slider-handle').removeClass('selected');
      video[0].play();
    }
    var actual_audio_track_time = calculateVideoComponentStartSecondInVideoEditor(identifier);
    if(videoEditorWithAudioTrack() && actual_audio_track_time < $('#full_audio_track_placeholder_in_video_editor').data('duration')) {
      var audio_track = $('#video_editor_preview_container audio');
      if(audio_track[0].error) {
        showLoadingMediaErrorPopup(audio_track[0].error.code, 'audio');
      } else {
        setCurrentTimeToMedia(audio_track, actual_audio_track_time);
        audio_track[0].play();
      }
    }
  });
  $body.on('click', '._media_player_pause_in_video_editor_preview', function() {
    $(this).hide();
    $(this).parents('._video_component_cutter').data('playing', false);
    var cutter_id = $(this).parents('._video_component_cutter').attr('id');
    var preview_id = cutter_id.replace('cutter', 'preview');
    $('#' + cutter_id + ' ._media_player_rewind_in_video_editor_preview').show();
    $('#' + cutter_id + ' ._media_player_slider_disabler').hide();
    $('#' + cutter_id + ' ._media_player_play_in_video_editor_preview').show();
    $('#' + cutter_id + ' ._media_player_slider .ui-slider-handle').addClass('selected');
    $('#' + preview_id + ' video')[0].pause();
    if(videoEditorWithAudioTrack()) {
      $('#video_editor_preview_container audio')[0].pause();
    }
    if(parseInt($('#' + preview_id + ' video')[0].currentTime) != $('#' + cutter_id).data('to')) {
      setCurrentTimeToMedia($('#' + preview_id + ' video'), $('#' + cutter_id + ' ._media_player_slider').slider('value'));
    }
  });
  $body.on('click', '._media_player_rewind_in_video_editor_preview', function() {
    var identifier = getVideoComponentIdentifier($(this).parents('._video_component_cutter').attr('id'));
    var initial_time = $('#video_component_' + identifier + '_cutter').data('from');
    $('#video_component_' + identifier + '_cutter ._media_player_slider').slider('value', initial_time);
    setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), initial_time);
  });
  $body.on('click', '._video_component_cutter ._double_slider .ui-slider-range', function(e) {
    var cutter = $(this).parents('._video_component_cutter');
    var percent = cutter.data('max-to') * (e.pageX - cutter.find('._double_slider').offset().left) / cutter.find('._double_slider').width();
    resp = parseInt(percent);
    if(percent - parseInt(percent) > 0.5) {
      resp += 1;
    }
    cutter.find('.ui-slider-handle').removeClass('selected');
    cutter.find('._media_player_slider .ui-slider-handle').addClass('selected');
    selectVideoComponentCutterHandle(cutter, resp);
  });
}





/**
Method that handles the event <b>timeupdate</b> for general audio or video players: if we got to the last second, the method rewinds the media, otherwise sets the time to the slider (this happens even if the slider already had that value, unlike the methods {{#crossLink "PlayersAudioEditor/initializeActionOfMediaTimeUpdaterInAudioEditor:method"}}{{/crossLink}} and {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}} during <b>preview mode</b>).
@method initializeActionOfMediaTimeUpdater
@for PlayersGeneral
@param media {String} HTML selector for the audio or video
@param reference_id {String} HTML id of the unique container of the audio or video
**/
function initializeActionOfMediaTimeUpdater(media, reference_id) {
  var duration = $('#' + reference_id).data('duration');
  var container_id = $(media).parent().attr('id');
  var parsed_int = parseInt(media.currentTime);
  if(parsed_int == (duration)) {
    $('#' + container_id + ' ._media_player_pause').click();
    $('#' + container_id + ' ._media_player_slider').slider('value', 0);
    $('#' + container_id + ' ._media_player_current_time').html(secondsToDateString(0));
    setCurrentTimeToMedia($(media), 0);
  } else if(!$('#' + container_id + ' ._media_player_play').is(':visible')) {
    $('#' + container_id + ' ._media_player_current_time').html(secondsToDateString(parsed_int));
    $('#' + container_id + ' ._media_player_slider').slider('value', parsed_int);
  }
}

/**
Initializes the media player for a generic audio or video.
@method initializeMedia
@for PlayersGeneral
@param content_id {String} the HTML id of the unique container of the media
@param type {String} it can be either <b>'audio'</b> or <b>'video'</b>
**/
function initializeMedia(content_id, type) {
  var duration = $('#' + content_id).data('duration');
  $('#' + content_id + ' ._media_player_slider').slider({
    min: 0,
    max: duration,
    range: 'min',
    value: 0,
    slide: function(event, ui) {
      if($('#' + content_id + ' ._media_player_play').is(':visible')) {
        setCurrentTimeToMedia($('#' + content_id + ' ' + type), ui.value);
        $('#' + content_id + ' ._media_player_current_time').html(secondsToDateString(ui.value));
      }
    }
  });
  initializeMediaTimeUpdater('#' + content_id + ' ' + type, content_id);
  $('#' + content_id + ' ' + type).bind('ended', function() {
    stopMedia(this);
  });
  $('#' + content_id).data('initialized', true);
}

/**
This is the method that associates {{#crossLink "PlayersGeneral/initializeActionOfMediaTimeUpdater:method"}}{{/crossLink}} to the event of <b>timeupdate</b>. Notice that the method waits until he receives the event <b>loadedmetadata</b> before working.
@method initializeMediaTimeUpdater
@for PlayersGeneral
@param media {String} HTML selector for the audio or video
@param reference_id {String} HTML id of the unique container of the audio or video
**/
function initializeMediaTimeUpdater(media, reference_id) {
  media = $(media);
  if(media.readyState != 0) {
    media[0].addEventListener('timeupdate', function() {
      initializeActionOfMediaTimeUpdater(this, reference_id);
    }, false);
  } else {
    media.on('loadedmetadata', function() {
      media[0].addEventListener('timeupdate', function() {
        initializeActionOfMediaTimeUpdater(this, reference_id);
      }, false);
    });
  }
}

/**
Stops a generic media, logging errors in the console.
@method stopMedia
@for PlayersGeneral
@param media {String} HTML selector for the audio or video
**/
function stopMedia(media) {
  try {
    if($(media).length != 0) {
      var has_source = false;
      $(media).find('source').each(function() {
        if($(this).attr('src') != '') {
          has_source = true;
        }
      });
      if(has_source) {
        var container_id = $(media).parent().attr('id');
        $('#' + container_id + ' ._media_player_pause').click();
        $('#' + container_id + ' ._media_player_slider').slider('value', 0);
        $('#' + container_id + ' ._media_player_current_time').html(secondsToDateString(0));
        setCurrentTimeToMedia($(media), 0);
      }
    }
  } catch(err) {
    console.log('error stopping media: ' + err);
  }
}





/**
This method has the same cases of use of {{#crossLink "PlayersAudioEditor/initializeActionOfMediaTimeUpdaterInAudioEditor:method"}}{{/crossLink}}, with a couple of details more due to the more complicated environment present in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}:
<ul>
  <li>the passage from a component to another (the method called in this case is {{#crossLink "VideoEditorPreview/playVideoEditorComponent:method"}}{{/crossLink}}) must handle a <b>transition</b> of one second</li>
  <li>it's necessary to hide and show the preview <b>progress bar</b> (see {{#crossLink "VideoEditorPreviewAccessories/showVideoEditorPreviewComponentProgressBar:method"}}{{/crossLink}}) positioning it with the help of the methods in {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}}</li>
  <li>the method needs also to update the <b>background audio track</b>, but only if it's present and if the <b>global preview time</b> is not greater than its duration.</li>
</ul>
@method initializeActionOfMediaTimeUpdaterInVideoEditor
@for PlayersVideoEditor
@param media {String} HTML selector for the video
@param identifier {Number} unique identifier for the video component (see {{#crossLinkModule "video-editor"}}{{/crossLinkModule}})
@param force_parsed_int {Boolean} forces the last second of the video; normally it's <i>false</i>, except the case in which the duration of the video is very close to the biggest lower integer (for instance, the duration is 10.01, which is very close to 10): in this case, the signal that the video ended <b>is not received directly by the current method</b>, but rather by the event handler <b>ended</b> initialized in the end of {{#crossLink "PlayersVideoEditor/initializeVideoInVideoEditorPreview:method"}}{{/crossLink}}
**/
function initializeActionOfMediaTimeUpdaterInVideoEditor(media, identifier, force_parsed_int) {
  var video_cut_to = $('#video_component_' + identifier + '_cutter').data('to');
  var not_parsed_int = media.currentTime;
  var parsed_int = parseInt(not_parsed_int);
  if(force_parsed_int || (not_parsed_int < video_cut_to && (video_cut_to - not_parsed_int) <= 0.2)) {
    parsed_int = video_cut_to;
    $(media).data('dont-update-time', true);
    setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), video_cut_to);
  }
  if($('#video_editor_global_preview').data('in-use')) {
    var component = $('#video_component_' + identifier);
    if(parsed_int > component.data('current-preview-time') + $('#video_component_' + identifier + '_cutter').data('from')) {
      if(parsed_int == video_cut_to) {
        $('#video_component_' + identifier + '_preview video')[0].pause();
        var next_component = component.next();
        var next_identifier = getVideoComponentIdentifier(next_component.attr('id'));
        if(next_component.hasClass('_video_editor_component')) {
          increaseVideoEditorPreviewTimer(true);
          $('#video_editor_global_preview').data('current-component', next_identifier);
          $('#video_component_' + identifier + '_preview').hide('fade', {}, 1000);
          component.find('._video_component_transition').removeClass('current');
          next_component.find('._video_editor_component_hover, ._video_component_icon').removeClass('selected');
          $('#video_component_' + next_identifier + '_preview').show('fade', {}, 1000, function() {
            hideVideoEditorPreviewComponentProgressBar();
            setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), $('#video_component_' + identifier + '_cutter').data('from'));
            $('#video_component_' + identifier + ' ._video_component_icon ._right').html(secondsToDateString(0));
            if(!$('#video_editor_global_preview').data('in-use')) {
              $('._video_component_transition').addClass('current');
            }
            increaseVideoEditorPreviewTimer(false);
            component.find('._video_editor_component_hover, ._video_component_icon').addClass('selected');
            if($('#video_editor_global_preview').data('in-use')) {
              playVideoEditorComponent(next_component, true);
            } else {
              var how_many_hidden_to_left = getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186);
              showVideoEditorPreviewComponentProgressBar(next_identifier, next_component.data('position') - how_many_hidden_to_left);
            }
          });
        } else {
          var first_component = getFirstVideoEditorComponent();
          selectVideoComponentInPreview(first_component);
          hideVideoEditorPreviewComponentProgressBar();
          if(videoEditorWithAudioTrack()) {
            $('#video_editor_preview_container audio')[0].pause();
          }
          $('#video_editor_global_preview_pause').trigger('click');
          if($('._video_editor_component').length > 5) {
            $('#media_elements_list_in_video_editor').jScrollPane().bind('panescrollstop', function() {
              showVideoEditorPreviewComponentProgressBar(getVideoComponentIdentifier(first_component.attr('id')), 1);
              $('#media_elements_list_in_video_editor').jScrollPane().unbind('panescrollstop');
            });
            $('#media_elements_list_in_video_editor').data('jsp').scrollToX(0, true, 500);
          } else {
            showVideoEditorPreviewComponentProgressBar(getVideoComponentIdentifier(first_component.attr('id')), 1);
          }
        }
      } else {
        increaseVideoEditorPreviewTimer(true);
      }
    }
  } else if($('#video_component_' + identifier + '_cutter').data('playing')) {
    if(parsed_int == (video_cut_to)) {
      var initial_time = $('#video_component_' + identifier + '_cutter').data('from');
      $('#video_component_' + identifier + '_cutter ._media_player_pause_in_video_editor_preview').click();
      $('#video_component_' + identifier + '_cutter ._media_player_slider').slider('value', initial_time);
      setCurrentTimeToMedia($(media), initial_time);
    } else if(!$('#video_component_' + identifier + '_cutter ._media_player_play_in_video_editor_preview').is(':visible')) {
      $('#video_component_' + identifier + '_cutter ._media_player_slider').slider('value', parsed_int);
    }
  }
  $(media).data('dont-update-time', false);
}

/**
This is the method that associates {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}} to the event of <b>timeupdate</b>. Notice that the method waits until he receives the event <b>loadedmetadata</b> before working.
@method initializeMediaTimeUpdaterInVideoEditor
@for PlayersVideoEditor
@param media {String} HTML selector for the audio or video
@param identifier {Number} unique identifier of a video component (see {{#crossLinkModule "video-editor"}}{{/crossLinkModule}})
**/
function initializeMediaTimeUpdaterInVideoEditor(media, identifier) {
  media = $(media);
  if(media.readyState != 0) {
    media[0].addEventListener('timeupdate', function() {
      if(!$(media).data('dont-update-time')) {
        initializeActionOfMediaTimeUpdaterInVideoEditor(this, identifier, false);
      }
    }, false);
  } else {
    media.on('loadedmetadata', function() {
      media[0].addEventListener('timeupdate', function() {
        if(!$(media).data('dont-update-time')) {
          initializeActionOfMediaTimeUpdaterInVideoEditor(this, identifier, false);
        }
      }, false);
    });
  }
}

/**
Initializes two sliders: one (JQueryUi single slider) for the <b>cursor</b>, and one (JQueryUi double slider) for the <b>cutting handles</b>. It also initializes how to handle the event <b>ended</b> associated to the video.
@method initializeVideoInVideoEditorPreview
@for PlayersVideoEditor
@param identifier {Number} the unique identifier of the video component (see {{#crossLinkModule "video-editor"}}{{/crossLinkModule}})
**/
function initializeVideoInVideoEditorPreview(identifier) {
  var my_cutter = $('#video_component_' + identifier + '_cutter');
  $('#video_component_' + identifier + '_preview video').on('loadeddata', function() {
    setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), my_cutter.data('from'));
  });
  var video_max_to = my_cutter.data('max-to');
  my_cutter.find('._media_player_slider').slider({
    min: 0,
    max: video_max_to,
    value: my_cutter.data('from'),
    slide: function(event, ui) {
      if(my_cutter.find('._media_player_play_in_video_editor_preview').is(':visible')) {
        setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), ui.value);
      }
    }
  });
  my_cutter.find('._double_slider').slider({
    min: 0,
    max: video_max_to,
    range: true,
    values: [my_cutter.data('from'), my_cutter.data('to')],
    start: function(event, ui) {
      my_cutter.find('.ui-slider-handle').removeClass('selected');
      $(ui.handle).addClass('selected');
    },
    slide: function(event, ui) {
      var left_val = ui.values[0];
      var right_val = ui.values[1];
      var cursor_val = my_cutter.find('._media_player_slider').slider('value');
      if(left_val != my_cutter.data('from')) {
        if(cursor_val < left_val) {
          selectVideoComponentCutterHandle(my_cutter, left_val);
        }
      } else {
        if(cursor_val > right_val) {
          selectVideoComponentCutterHandle(my_cutter, right_val);
        }
      }
    },
    stop: function(event, ui) {
      my_cutter.data('changed', true);
      var left_val = ui.values[0];
      var right_val = ui.values[1];
      if(left_val != my_cutter.data('from')) {
        if(left_val == right_val) {
          my_cutter.find('._double_slider').slider('values', 0, left_val - 1);
          left_val -= 1;
        }
        cutVideoComponentLeftSide(identifier, left_val);
      }
      if(right_val != my_cutter.data('to')) {
        if(left_val == right_val) {
          my_cutter.find('._double_slider').slider('values', 1, right_val + 1);
          right_val += 1;
        }
        cutVideoComponentRightSide(identifier, right_val);
      }
    }
  });
  my_cutter.find('._double_slider .ui-slider-range').mousedown(function(e) {
    return false;
  });
  $('#video_component_' + identifier + '_cutter ._media_player_slider .ui-slider-handle').addClass('selected');
  initializeMediaTimeUpdaterInVideoEditor('#video_component_' + identifier + '_preview video', identifier);
  $('#video_component_' + identifier + '_preview video').bind('ended', function() {
    if($('#video_editor_global_preview').data('in-use')) {
      initializeActionOfMediaTimeUpdaterInVideoEditor($('#video_component_' + identifier + '_preview video')[0], identifier, true);
    } else {
      stopVideoInVideoEditorPreview(identifier);
    }
  });
}

/**
Method that <b>updates the video cursor</b>, in case one of the two handles passes over the cursor (the cursor must follow the handle).
@method selectVideoComponentCutterHandle
@for PlayersVideoEditor
@param cutter {Object} the JQuery object representing the cutter for that particular component (see {{#crossLinkModule "video-editor"}}{{/crossLinkModule}})
@param val {Number} the value to be assigned
**/
function selectVideoComponentCutterHandle(cutter, val) {
  setCurrentTimeToMedia($('#' + cutter.attr('id').replace('cutter', 'preview') + ' video'), val);
  cutter.find('._media_player_slider').slider('value', val);
}

/**
Specific method to call if the event <b>ended</b> is fired on the video and we are not in the {{#crossLinkModule "video-editor"}}{{/crossLinkModule}} preview mode (unlike in {{#crossLink "PlayersAudioEditor"}}{{/crossLink}}, in this case it's separated by the method {{#crossLink "PlayersVideoEditor/initializeVideoInVideoEditorPreview:method"}}{{/crossLink}}, since it's more complicated.
@method stopVideoInVideoEditorPreview
@for PlayersVideoEditor
@param identifier {Number} the unique identifier of the video component
**/
function stopVideoInVideoEditorPreview(identifier) {
  try {
    if($('#video_component_' + identifier + '_preview video').length != 0) {
      var has_source = true;
      $('#video_component_' + identifier + '_preview video').find('source').each(function() {
        if($(this).attr('src') == '') {
          has_source = false;
        }
      });
      if(has_source) {
        $('#video_component_' + identifier + '_cutter ._media_player_pause_in_video_editor_preview').click();
        var initial_time = $('#video_component_' + identifier + '_cutter').data('from');
        $('#video_component_' + identifier + '_cutter ._media_player_slider').slider('value', initial_time);
        setCurrentTimeToMedia($('#video_component_' + identifier + '_preview video'), initial_time);
      }
    }
  } catch(err) {
    console.log('error stopping media: ' + err);
  }
}
