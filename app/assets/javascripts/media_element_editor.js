/**
This module contains javascript functions common to all the editors ({{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, {{#crossLinkModule "image-editor"}}{{/crossLinkModule}}, {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}).
@module media-element-editor
**/





/**
One step of the repeated <b>cache</b> saving (used in {{#crossLinkModule "image-editor"}}{{/crossLinkModule}} and {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}).
@method saveCacheLoop
@for MediaElementEditorCache
**/
function saveCacheLoop() {
  var cache_form = $('#video_editor_form, #audio_editor_form');
  var time = $parameters.data('cache-time');
  if(cache_form.length > 0 && $('#info_container').data('save-cache')) {
    submitMediaElementEditorCacheForm(cache_form);
    setTimeout(function() {
      saveCacheLoop();
    }, time);
  }
}

/**
Initializes the <b>cache loop</b> and starts it calling {{#crossLink "MediaElementEditorCache/saveCacheLoop:method"}}{{/crossLink}}.
@method startCacheLoop
@for MediaElementEditorCache
**/
function startCacheLoop() {
  $('#info_container').data('save-cache', true);
  saveCacheLoop();
}

/**
Stops the cache loop.
@method stopCacheLoop
@for MediaElementEditorCache
**/
function stopCacheLoop() {
  $('#info_container').data('cache-enabled-first-time', false);
  $('#info_container').data('save-cache', false);
}

/**
Submethod of {{#crossLink "MediaElementEditorCache/saveCacheLoop:method"}}{{/crossLink}}.
@method submitMediaElementEditorCacheForm
@for MediaElementEditorCache
**/
function submitMediaElementEditorCacheForm(form) {
  unbindLoader();
  $.ajax({
    type: 'post',
    url: form.attr('action'),
    timeout: 5000,
    data: form.serialize()
  }).always(bindLoader);
}





/**
Function that checks the conversion of the unconverted media elements in the page. Same structure of {{#crossLink "MediaElementEditorConversion/mediaElementLoaderConversionOverview:method"}}{{/crossLink}}.
@method lessonEditorConversionOverview
@for MediaElementEditorConversion
@param list {Array} list of media elements that are being checked
@param time {Number} time to iterate the loop
**/
function lessonEditorConversionOverview(list, time) {
  $('#lesson-title').show();
  $('#error-footer-disclaimer').hide();
  $('._audio_gallery_thumb._disabled, ._video_gallery_thumb._disabled').each(function() {
    var my_id = $(this).hasClass('_video_gallery_thumb') ? $(this).data('video-id') : $(this).data('audio-id');
    if(list.indexOf(my_id) == -1) {
      list.push(my_id);
    }
  });
  var black_list = $('#info_container').data('media-elements-not-anymore-in-conversion');
  for(var i = 0; i < black_list.length; i ++) {
    var j = list.indexOf(black_list[i]);
    if(j != -1) {
      list.splice(j, 1);
    }
  }
  if(list.length > 0) {
    var ajax_url = '/lesson_editor/check_conversion?';
    for(var i = 0; i < list.length; i ++) {
      ajax_url += ('me' + list[i] + '=true');
      if(i != list.length - 1) {
        ajax_url += '&';
      }
    }
    unbindLoader();
    $.ajax({
      url: ajax_url,
      type: 'get'
    }).always(bindLoader);
  }
  setTimeout(function() {
    lessonEditorConversionOverview(list, time);
  }, time);
}

/**
Function that checks the conversion of the unconverted media elements in the page. Same structure of {{#crossLink "MediaElementEditorConversion/lessonEditorConversionOverview:method"}}{{/crossLink}}.
@method mediaElementLoaderConversionOverview
@for MediaElementEditorConversion
@param list {Array} list of media elements that are being checked
@param time {Number} time to iterate the loop
**/
function mediaElementLoaderConversionOverview(list, time) {
  $('._media_element_item._disabled').each(function() {
    var my_id = $(this).find('._Image_button_preview, ._Audio_button_preview, ._Video_button_preview').data('clickparam');
    if(list.indexOf(my_id) == -1) {
      list.push(my_id);
    }
  });
  var black_list = $('#info_container').data('media-elements-not-anymore-in-conversion');
  for(var i = 0; i < black_list.length; i ++) {
    var j = list.indexOf(black_list[i]);
    if(j != -1) {
      list.splice(j, 1);
    }
  }
  if(list.length > 0) {
    var ajax_url = '/media_elements/conversion/check?';
    for(var i = 0; i < list.length; i ++) {
      ajax_url += ('me' + list[i] + '=true');
      if(i != list.length - 1) {
        ajax_url += '&';
      }
    }
    unbindLoader();
    $.ajax({
      url: ajax_url,
      type: 'get'
    }).always(bindLoader);
  }
  setTimeout(function() {
    mediaElementLoaderConversionOverview(list, time);
  }, time);
}

/**
Shows the message after the conversion ended inside Lesson Editor.
@method uploaderConversionChecker
@for MediaElementEditorConversion
@param selector {String} selector for the correct translation to be shown
@param title {String} the title of the item
**/
function uploaderConversionChecker(selector, title) {
  var message = $captions.data('lesson-editor-conversion-' + selector);
  if(title != undefined) {
    message = message.replace('%{item}', title);
  }
  var delayed = function() {
    $('#lesson-title').hide();
    $('#error-footer-disclaimer').text(message).removeClass('true false').addClass(selector.split('-')[1]).show();
  }
  if($('#error-footer-disclaimer').is(':visible')) {
    setTimeout(delayed, 5000);
  } else {
    delayed();
  }
}





/**
Initializes the placeholder of the <b>commit forms</b> used in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, {{#crossLinkModule "image-editor"}}{{/crossLinkModule}} and {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}.
@method mediaElementEditorDocumentReady
@for MediaElementEditorDocumentReady
**/
function mediaElementEditorDocumentReady() {
  $body.on('click', '._exit_media_element_editor', function() {
    stopCacheLoop();
    var type = $(this).data('type');
    var captions = $captions;
    var title = captions.data('exit-' + type + '-editor-title');
    var confirm = captions.data('exit-' + type + '-editor-confirm');
    var yes = captions.data('exit-' + type + '-editor-yes');
    var no = captions.data('exit-' + type + '-editor-no');
    showConfirmPopUp(title, confirm, yes, no, function() {
      $('dialog-confirm').hide();
      unbindLoader();
      $.ajax({
        type: 'post',
        url: '/' + type + 's/cache/empty',
        success: function() {
          window.location = '/media_elements';
        }
      }).always(bindLoader);
    }, function() {
      if($('.formMediaElement').is(':visible')) {
        startCacheLoop();
      }
      closePopUp('dialog-confirm');
    });
  });
  $body.on('click', '._commit_media_element_editor', function() {
    var type = $(this).data('type');
    if(type != 'image') {
      stopCacheLoop();
      submitMediaElementEditorCacheForm($('#' + type + '_editor_form'));
    }
    if($(this).hasClass('_with_choice')) {
      var captions = $captions;
      var title = captions.data('save-media-element-editor-title');
      var confirm = captions.data('save-media-element-editor-confirm');
      var yes = captions.data('save-media-element-editor-yes');
      var no = captions.data('save-media-element-editor-no');
      showConfirmPopUp(title, confirm, yes, no, function() {
        closePopUp('dialog-confirm');
        showCommitMediaElementEditorForm(type, 'edit')
        disableTagsInputTooHigh($('#edit-media-element ._tags_container'));
      }, function() {
        closePopUp('dialog-confirm');
        $('#' + type + '_editor_title ._titled').hide();
        $('#' + type + '_editor_title ._untitled').show();
        showCommitMediaElementEditorForm(type, 'new')
      });
    } else {
      showCommitMediaElementEditorForm(type, 'new')
    }
  });
  $body.on('click', '.formMediaElement .part3 .submit', function() {
    var container = $(this).parents('.formMediaElement');
    var action = container.data('form-action');
    var type = container.data('form-type');
    if(action == 'overwrite' && $('#info_container').data('used-in-private-lessons')) {
      var captions = $captions;
      var title = captions.data('overwrite-media-element-editor-title');
      var confirm = captions.data('overwrite-media-element-editor-confirm');
      var yes = captions.data('overwrite-media-element-editor-yes');
      var no = captions.data('overwrite-media-element-editor-no');
      showConfirmPopUp(title, confirm, yes, no, function() {
        $('dialog-confirm').hide();
        $('#' + type + '_editor_form').attr('action', '/' + type + 's/commit/overwrite').submit();
      }, function() {
        closePopUp('dialog-confirm');
      });
    } else {
      $('#' + type + '_editor_form').attr('action', ('/' + type + 's/commit/' + action)).submit();
    }
  });
  $body.on('click', '#new-media-element.formMediaElement .part3 .on-left .reuse-old-data', function() {
    var reuse = $(this);
    var container = reuse.parents('.formMediaElement');
    var reuse_hidden = container.find('.part3 .on-left .hidden-data');
    if(!reuse.hasClass('disabled')) {
      reuse.addClass('disabled');
      reuse.find('#reuse-old-data').attr('checked', 'checked').attr('disabled', 'disabled');
      container.find('.part2 .title').val(reuse_hidden.data('title'));
      container.find('.part2 .title_placeholder').val('0');
      container.find('.part2 .description').val(reuse_hidden.data('description'));
      container.find('.part2 .description_placeholder').val('0');
      var tags_container = container.find('.part2 ._tags_container');
      container.find('.part2 ._tags_container span').remove();
      container.find('.part2 ._tags_container ._placeholder').hide();
      reuse_hidden.find('span').each(function() {
        var copy = $(this)[0].outerHTML;
        tags_container.prepend(copy);
      });
      container.find('.part2 ._tags_container .tags_value').val(reuse_hidden.data('tags'));
      container.find('.form_error').removeClass('form_error');
      container.find('.errors_layer').hide();
      disableTagsInputTooHigh(tags_container);
    }
  });
  $body.on('click', '.formMediaElement .part3 .close', function() {
    var container = $(this).parents('.formMediaElement');
    var type = container.data('form-type');
    var action = container.data('form-action');
    if(type != 'image') {
      $('#' + type + '_editor_form').attr('action', '/' + type + 's/cache/save');
      startCacheLoop();
    }
    if(action == 'new') {
      if($('#' + type + '_editor_title ._titled').length > 0) {
        $('#' + type + '_editor_title ._titled').show();
        $('#' + type + '_editor_title ._untitled').hide();
      }
      hideCommitMediaElementEditorForm(type, 'new');
      container.find('.part3 .on-left .reuse-old-data').removeClass('disabled');
      container.find('.part3 .on-left .reuse-old-data #reuse-old-data').removeAttr('disabled').removeAttr('checked');
      container.find('.part2 .title').val(container.data('placeholder-title'));
      container.find('.part2 .title_placeholder').val('');
      container.find('.part2 .description').val(container.data('placeholder-description'));
      container.find('.part2 .description_placeholder').val('');
      container.find('.part2 ._tags_container span').remove();
      container.find('.part2 ._tags_container ._placeholder').show();
      container.find('.part2 .tags_value').val('');
      container.find('.part2 .tags').val('');
    } else {
      hideCommitMediaElementEditorForm(type, 'edit');
      container.find('.part2 .title').val(container.data('title'));
      container.find('.part2 .title_placeholder').val('');
      container.find('.part2 .description').val(container.data('description'));
      container.find('.part2 .description_placeholder').val('');
      container.find('.part2 ._tags_container span').remove();
      container.find('.part2 .hidden-tags span').each(function() {
        var copy = $(this)[0].outerHTML;
        container.find('.part2 ._tags_container').prepend(copy);
      });
      container.find('.part2 ._tags_container .tags_value').val(container.data('tags'));
      container.find('.part2 .tags').val('').show();
    }
    container.find('.form_error').removeClass('form_error');
    container.find('.errors_layer').hide();
  });
  $body.on('focus', '#new-media-element.formMediaElement .part2 .title', function() {
    var container = $(this).parents('.formMediaElement');
    container.find('.part3 .on-left .reuse-old-data').removeClass('disabled');
    container.find('.part3 .on-left .reuse-old-data #reuse-old-data').removeAttr('disabled').removeAttr('checked');
    if(container.find('.part2 .title_placeholder').val() == '') {
      $(this).val('');
      container.find('.part2 .title_placeholder').val('0');
    }
  });
  $body.on('focus', '#new-media-element.formMediaElement .part2 .description', function() {
    var container = $(this).parents('.formMediaElement');
    container.find('.part3 .on-left .reuse-old-data').removeClass('disabled');
    container.find('.part3 .on-left .reuse-old-data #reuse-old-data').removeAttr('disabled').removeAttr('checked');
    if(container.find('.part2 .description_placeholder').val() == '') {
      $(this).val('');
      container.find('.part2 .description_placeholder').val('0');
    }
  });
  $body.on('focus', '#new-media-element.formMediaElement .part2 ._tags_container .tags', function() {
    var container = $(this).parents('.formMediaElement');
    container.find('.part3 .on-left .reuse-old-data').removeClass('disabled');
    container.find('.part3 .on-left .reuse-old-data #reuse-old-data').removeAttr('disabled').removeAttr('checked');
  });
  $body.on('keydown', '.formMediaElement .part2 .title, .formMediaElement .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('keydown', '.formMediaElement .part2 ._tags_container .tags', function() {
    $(this).parent().removeClass('form_error');
  });
  $body.on('click', '.formMediaElement .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.formMediaElement');
    myself.hide();
    container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
  });
}





/**
Hides the commit form for overwrite or for new element (depending on the parameter).
@method hideCommitMediaElementEditorForm
@for MediaElementEditorForms
@param type {String} 'audio', 'image', or 'video'
@param scope {String} it can be either 'edit' or 'new'
**/
function hideCommitMediaElementEditorForm(type, scope) {
  $('#' + scope + '-media-element').hide();
  $('#' + type + '_editor .hideMe').show();
  if(type == 'audio') {
    setBackAllZIndexesInAudioEditor();
  }
}

/**
Resets the media element loading form; used in {{#crossLink "DialogsWithForm/showDocumentInfoPopUp:method"}}{{/crossLink}}.
@method resetDocumentChangeInfo
@for MediaElementEditorForms
@param container {Object} JQuery object of the form
**/
function resetDocumentChangeInfo(container) {
  container.find('.part2 .title').val(container.data('title'));
  container.find('.part2 .description').val(container.data('description'));
  container.find('.form_error').removeClass('form_error');
  container.find('.errors_layer').hide();
}

/**
Resets the media element loading form; used in {{#crossLink "DialogsWithForm/showMediaElementInfoPopUp:method"}}{{/crossLink}}.
@method resetMediaElementChangeInfo
@for MediaElementEditorForms
@param container {Object} JQuery object of the form
**/
function resetMediaElementChangeInfo(container) {
  var tags_container = container.find('.part2 ._tags_container');
  container.find('.part2 .title').val(container.data('title'));
  container.find('.part2 .description').val(container.data('description'));
  container.find('.part2 ._tags_container span').remove();
  container.find('.part2 .hidden-tags span').each(function() {
    var copy = $(this)[0].outerHTML;
    tags_container.prepend(copy);
  });
  container.find('.part2 ._tags_container .tags_value').val(container.data('tags'));
  container.find('.form_error').removeClass('form_error');
  container.find('.errors_layer').hide();
  container.find('.part2 .tags').val('').show();
}

/**
Shows the commit form for overwrite or for new element (depending on the parameter).
@method showCommitMediaElementEditorForm
@for MediaElementEditorForms
@param type {String} 'audio', 'image', or 'video'
@param scope {String} it can be either 'edit' or 'new'
**/
function showCommitMediaElementEditorForm(type, scope) {
  $('#' + scope + '-media-element').show();
  $('#' + type + '_editor .hideMe').hide();
  if(type == 'audio') {
    setToZeroAllZIndexesInAudioEditor();
  }
}





/**
Submethod used in the methods of {{#crossLink "VideoEditorScrollPain"}}{{/crossLink}}: calculates the correct movement that a horizontal <b>left</b> scroll must do taking into consideration the space available (thing that obviously JScrollPain doesn't do itself).
@method calculateCorrectMovementHorizontalScrollLeft
@for MediaElementEditorHorizontalTimelines
@param hidden {Float} the portion of the scroll hidden on the left
@param movement {Float} the required movement
@return {Float} the correct movement to do
**/
function calculateCorrectMovementHorizontalScrollLeft(hidden, movement) {
  if(movement > hidden) {
    return hidden;
  } else {
    return movement;
  }
}

/**
Submethod used in the methods of {{#crossLink "VideoEditorScrollPain"}}{{/crossLink}}: calculates the correct movement that a horizontal <b>right</b> scroll must do taking into consideration the space available (thing that obviously JScrollPain doesn't do itself).
@method calculateCorrectMovementHorizontalScrollRight
@for MediaElementEditorHorizontalTimelines
@param hidden {Float} the portion of the scroll hidden on the left
@param movement {Float} the required movement
@return {Float} the correct movement to do
**/
function calculateCorrectMovementHorizontalScrollRight(hidden, movement, tot, visible) {
  return calculateCorrectMovementHorizontalScrollLeft(tot - hidden - visible, movement);
}

/**
Submethod used in the methods of {{#crossLink "VideoEditorScrollPain"}}{{/crossLink}}: calculates the absolute position to be assigned to <b>a div that must be aligned to the component</b> after having been moved to first position.
@method getAbsolutePositionTimelineHorizontalScrollPane
@for MediaElementEditorHorizontalTimelines
@param jscrollpane_id {String} the HTML id of the scroll pane
@param component_width {Number} the width in pixels of a single component
@param component_position {Number} the position among the other components
@param components_visible_number {Number} how many components are visible at the same time in the scroll pane
@return {Number} the correct position of the div in pixels (it's not float because we pass to the method only integers, unlike {{#crossLink "MediaElementEditorHorizontalTimelines/calculateCorrectMovementHorizontalScrollRight:method"}}{{/crossLink}} and {{#crossLink "MediaElementEditorHorizontalTimelines/calculateCorrectMovementHorizontalScrollRight:method"}}{{/crossLink}} that are defined generally)
**/
function getAbsolutePositionTimelineHorizontalScrollPane(jscrollpane_id, component_width, component_position, components_visible_number) {
  var how_many_hidden_to_left = getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane(jscrollpane_id, component_width);
  if($('#' + jscrollpane_id).data('jsp').getPercentScrolledX() == 1) {
    how_many_hidden_to_left += 1;
  }
  var resp = (components_visible_number - 1);
  if(how_many_hidden_to_left + components_visible_number >= component_position) {
   resp = (component_position - how_many_hidden_to_left - 1);
  }
  return resp * component_width;
}

/**
Submethod used in the methods of {{#crossLink "VideoEditorScrollPain"}}{{/crossLink}}: gets how many components are hidden to the left of the scroll pane.
@method getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane
@for MediaElementEditorHorizontalTimelines
@param jscrollpane_id {String} the HTML id of the scroll pane
@param component_width {Number} the width in pixels of a single component
@return {Number} the number of components hidden to the left
**/
function getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane(jscrollpane_id, component_width) {
  var hidden_to_left = $('#' + jscrollpane_id).data('jsp').getContentPositionX();
  return parseInt(hidden_to_left / component_width);
}

/**
Submethod used in the methods of {{#crossLink "VideoEditorScrollPain"}}{{/crossLink}}: exactly the same as {{#crossLink "MediaElementEditorHorizontalTimelines/getAbsolutePositionTimelineHorizontalScrollPane:method"}}{{/crossLink}}, but <b>it returns the position of the scroll pane</b> instead of the absolute pixels for an external div.
@method getNormalizedPositionTimelineHorizontalScrollPane
@for MediaElementEditorHorizontalTimelines
@param jscrollpane_id {String} the HTML id of the scroll pane
@param component_width {Number} the width in pixels of a single component
@param component_position {Number} the position among the other components
@param components_visible_number {Number} how many components are visible at the same time in the scroll pane
@return {Number} the correct position of the scroll in pixels
**/
function getNormalizedPositionTimelineHorizontalScrollPane(jscrollpane_id, component_width, component_position, components_visible_number) {
  var how_many_hidden_to_left = getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane(jscrollpane_id, component_width);
  var resp = how_many_hidden_to_left * component_width;
  if(how_many_hidden_to_left + components_visible_number < component_position) {
    resp += component_width;
  }
  return resp;
}
