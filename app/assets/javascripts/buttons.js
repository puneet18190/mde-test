/**
Lessons and Elements actions triggered via buttons.
@module buttons
**/





/**
Add the url parameter 'delete_item' to an url (this parameter is used to delete an item while reloading the page).
@method addDeleteItemToCurrentUrl
@for ButtonsAccessories
@param current_url {String} the initial url
@param delete_item {String} the value to be assigned to the url parameter 'delete_item'
@return {String} updated url
**/
function addDeleteItemToCurrentUrl(current_url, delete_item) {
  var point_start_params = current_url.indexOf('?');
  var resp = current_url;
  if(point_start_params == -1) {
    resp = resp + '?delete_item=' + delete_item;
  } else {
    resp = resp + '&delete_item=' + delete_item;
  }
  return resp;
}





/**
Initializes all the buttons available for lessons.
@method lessonButtonsDocumentReady
@for ButtonsDocumentReady
**/
function lessonButtonsDocumentReady() {
  $body.on('click', '._Lesson_button_add', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var reload = $(this).data('reload');
      var current_url = $('#info_container').data('currenturl');
      addLesson(my_param, destination, current_url, reload);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_copy', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      copyLesson(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_destroy', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var current_url = $('#info_container').data('currenturl');
      destroyLesson(my_param, destination, current_url);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_dislike', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      dislikeLesson(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_like', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      likeLesson(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_preview', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var redirect_back_to = $("#info_container").data('currenturl');
      previewLesson(my_param, redirect_back_to);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_publish', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      publishLesson(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_remove', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var reload = $(this).data('reload');
      var current_url = $('#info_container').data('currenturl');
      removeLesson(my_param, destination, current_url, reload);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_unpublish', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var lesson_parent = $('#found_lesson_' + my_param + ', #compact_lesson_' + my_param + ', #expanded_lesson_' + my_param);
      if(lesson_parent.hasClass('_lesson_change_not_notified')) {
        showLessonNotificationPopUp(destination + '_' + my_param);
      } else {
        unpublishLesson(my_param, destination);
      }
    }
    return false;
  });
  $body.on('click', '._Lesson_button_add_virtual_classroom', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      addLessonToVirtualClassroom(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_remove_virtual_classroom', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      removeLessonFromVirtualClassroom(my_param, destination);
    }
    return false;
  });
  $body.on('click', '._Lesson_button_edit', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      window.location = '/lessons/' + my_param + '/slides/edit';
    }
    return false;
  });
}

/**
Initializes all the buttons for media elements.
@method mediaElementButtonsDocumentReady
@for ButtonsDocumentReady
**/
function mediaElementButtonsDocumentReady() {
  $body.on('click', '._Video_button_add, ._Audio_button_add, ._Image_button_add', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var reload = $(this).data('reload');
      var current_url = $('#info_container').data('currenturl');
      addMediaElement(my_param, destination, current_url, reload);
    }
  });
  $body.on('click', '._Video_button_destroy, ._Audio_button_destroy, ._Image_button_destroy', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var current_url = $('#info_container').data('currenturl');
      var used_in_private_lessons = $(this).parents('._media_element_item').data('used-in-private-lessons');
      destroyMediaElement(my_param, destination, current_url, used_in_private_lessons);
    }
  });
  $body.on('click', '._Video_button_preview, ._Audio_button_preview, ._Image_button_preview', function(e) {
    if(!$(this).parents('._media_element_item').hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      showMediaElementInfoPopUp(my_param);
    }
  });
  $body.on('click', '._Video_button_edit', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      e.preventDefault();
      var video_id = $(this).data('clickparam');
      var redirect_back_to = $("#info_container").data('currenturl');
      var parser = document.createElement('a');
      parser.href = redirect_back_to;
      window.location = '/videos/' + video_id + '/edit?back=' + encodeURIComponent(parser.pathname + parser.search+parser.hash);
      return false;
    }
  });
  $body.on('click', '._Audio_button_edit', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      e.preventDefault();
      var audio_id = $(this).data('clickparam');
      var redirect_back_to = $("#info_container").data('currenturl');
      var parser = document.createElement('a');
      parser.href = redirect_back_to;
      window.location = '/audios/' + audio_id + '/edit?back=' + encodeURIComponent(parser.pathname + parser.search+parser.hash);
      return false;
    }
  });
  $body.on('click', '._Image_button_edit', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      e.preventDefault();
      var image_id = $(this).data('clickparam');
      var redirect_back_to = $("#info_container").data('currenturl');
      var parser = document.createElement('a');
      parser.href = redirect_back_to;
      window.location = '/images/' + image_id + '/edit?back=' + encodeURIComponent(parser.pathname + parser.search+parser.hash);
      return false;
    }
  });
  $body.on('click', '._Video_button_remove, ._Audio_button_remove, ._Image_button_remove', function(e) {
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('clickparam');
      var destination = $(this).data('destination');
      var reload = $(this).data('reload');
      var current_url = $('#info_container').data('currenturl');
      removeMediaElement(my_param, destination, current_url, reload);
    }
  });
}





/**
Calls the url to add the link of a lesson. It can either reload the item or remove it from the page.
@method addLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
@param current_url {String} url where the lesson is added from
@param reload {Boolean} true if the item must be reloaded, false if it must be removed
**/
function addLesson(lesson_id, destination, current_url, reload) {
  if(reload) {
    $.ajax({
      type: 'post',
      url: '/lessons/' + lesson_id + '/add?destination=' + destination
    });
  } else {
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + lesson_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/lessons/' + lesson_id + '/add?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $captions.data('temporary-msg', data.msg);
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
  }
}

/**
Calls the url to add a lesson to my Virtual Classroom. It reloads the item.
@method addLessonToVirtualClassroom
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function addLessonToVirtualClassroom(lesson_id, destination) {
  $.ajax({
    type: 'post',
    url: '/virtual_classroom/' + lesson_id + '/add_lesson?destination=' + destination
  });
}

/**
Calls the url to copy a lesson.
@method copyLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function copyLesson(lesson_id, destination) {
  $.ajax({
    type: 'post',
    url: '/lessons/' + lesson_id + '/copy?destination=' + destination
  });
}

/**
Calls the url to destroy a lesson. It removes the lesson from the page.
@method destroyLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
@param current_url {String} url where the lesson is added from
**/
function destroyLesson(lesson_id, destination, current_url) {
  var captions = $captions;
  showConfirmPopUp(captions.data('destroy-lesson-title'), captions.data('destroy-lesson-confirm'), captions.data('destroy-lesson-yes'), captions.data('destroy-lesson-no'), function() {
    $('#dialog-confirm').hide();
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + lesson_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/lessons/' + lesson_id + '/destroy?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
    closePopUp('dialog-confirm');
  }, function() {
    closePopUp('dialog-confirm');
  });
}

/**
Calls the url to remove the 'I like it' from a lesson. It reloads the item.
@method dislikeLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function dislikeLesson(lesson_id, destination) {
  $.ajax({
    type: 'post',
    url: '/lessons/' + lesson_id + '/dislike?destination=' + destination
  });
}

/**
Calls the url to add a 'I like it' to a lesson. It reloads the item.
@method likeLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function likeLesson(lesson_id, destination) {
  $.ajax({
    type: 'post',
    url: '/lessons/' + lesson_id + '/like?destination=' + destination
  });
}

/**
Calls the url that opens the lesson viewer for this lesson.
@method previewLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param redirect_to {String} url to be redirected when leaving the Lesson Viewer
**/
function previewLesson(lesson_id, redirect_to) {
  var parser = UrlParser.parse(redirect_to);
  var back = '';
  if(parser) {
    var pathname = parser.pathname || '';
    var search = parser.search || '';
    var hash = parser.hash || '';
    var encodedBack = encodeURIComponent(pathname+search+hash);
    if ( encodedBack) {
      back = '?back=' + encodedBack;
    }
  }
  window.location.href = '/lessons/' + lesson_id + '/view' + back;
}

/**
Calls the url to publish a lesson. It reloads the item.
@method publishLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function publishLesson(lesson_id, destination) {
  var captions = $captions;
  showConfirmPopUp(captions.data('publish-title'), captions.data('publish-confirm'), captions.data('publish-yes'), captions.data('publish-no'), function() {
    $('#dialog-confirm').hide();
    $.ajax({
      type: 'post',
      url: '/lessons/' + lesson_id + '/publish?destination=' + destination
    });
    closePopUp('dialog-confirm');
  }, function() {
    closePopUp('dialog-confirm');
  });
}

/**
Calls the url to remove a link of a lesson. It can either reload the item or remove it from the page.
@method removeLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
@param current_url {String} url where the lesson is added from
@param reload {Boolean} true if the item must be reloaded, false if it must be removed
**/
function removeLesson(lesson_id, destination, current_url, reload) {
  if(reload) {
    $.ajax({
      type: 'post',
      url: '/lessons/' + lesson_id + '/remove?destination=' + destination
    });
  } else {
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + lesson_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/lessons/' + lesson_id + '/remove?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $captions.data('temporary-msg', data.msg);
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
  }
}

/**
Calls the url to remove a lesson from my Virtual Classroom. It reloads the item.
@method removeLessonFromVirtualClassroom
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function removeLessonFromVirtualClassroom(lesson_id, destination) {
  $.ajax({
    type: 'post',
    url: '/virtual_classroom/' + lesson_id + '/remove_lesson?destination=' + destination
  });
}

/**
Calls the url to unpublish a lesson. It reloads the item.
@method unpublishLesson
@for ButtonsLesson
@param lesson_id {Number} id of the lesson in the database
@param destination {String} destination (used to pick the HTML id of the lesson)
**/
function unpublishLesson(lesson_id, destination) {
  var captions = $captions;
  showConfirmPopUp(captions.data('unpublish-title'), captions.data('unpublish-confirm'), captions.data('unpublish-yes'), captions.data('unpublish-no'), function() {
    $('#dialog-confirm').hide();
    $.ajax({
      type: 'post',
      url: '/lessons/' + lesson_id + '/unpublish?destination=' + destination
    });
    closePopUp('dialog-confirm');
  }, function() {
    closePopUp('dialog-confirm');
  });
}





/**
Calls the url to add the link of a media element. It can either reload the item or remove it from the page.
@method addMediaElement
@for ButtonsMediaElement
@param media_element_id {Number} id of the element in the database
@param destination {String} destination (used to pick the HTML id of the element)
@param current_url {String} url where the element is added from
@param reload {Boolean} true if the item must be reloaded, false if it must be removed
**/
function addMediaElement(media_element_id, destination, current_url, reload) {
  if(reload) {
    $.ajax({
      type: 'post',
      url: '/media_elements/' + media_element_id + '/add?destination=' + destination
    });
  } else {
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + media_element_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/media_elements/' + media_element_id + '/add?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $captions.data('temporary-msg', data.msg);
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
  }
}

/**
Calls the url to destroy a media element. It removes the element from the page.
@method destroyMediaElement
@for ButtonsMediaElement
@param media_element_id {Number} id of the element in the database
@param destination {String} destination (used to pick the HTML id of the element)
@param current_url {String} url where the element is added from
@param used_in_private_lessons {Boolean} if true, the application writes in the confirmation popup that the user is going to remove the same element from his private lessons
**/
function destroyMediaElement(media_element_id, destination, current_url, used_in_private_lessons) {
  var captions = $captions;
  var title = captions.data('destroy-media-element-title');
  var confirm = captions.data('destroy-media-element-confirm');
  var yes = captions.data('destroy-media-element-yes');
  var no = captions.data('destroy-media-element-no');
  if(used_in_private_lessons) {
    confirm = captions.data('destroy-media-element-confirm-bis');
  }
  showConfirmPopUp(title, confirm, yes, no, function() {
    $('#dialog-confirm').hide();
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + media_element_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/media_elements/' + media_element_id + '/destroy?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
    closePopUp('dialog-confirm');
  }, function() {
    closePopUp('dialog-confirm');
  });
}

/**
Calls the url to remove a link of an element. It can either reload the item or remove it from the page.
@method removeMediaElement
@for ButtonsMediaElement
@param media_element_id {Number} id of the element in the database
@param destination {String} destination (used to pick the HTML id of the element)
@param current_url {String} url where the element is added from
@param reload {Boolean} true if the item must be reloaded, false if it must be removed
**/
function removeMediaElement(media_element_id, destination, current_url, reload) {
  if(reload) {
    $.ajax({
      type: 'post',
      url: '/media_elements/' + media_element_id + '/remove?destination=' + destination
    });
  } else {
    var redirect_url = addDeleteItemToCurrentUrl(current_url, (destination + '_' + media_element_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/media_elements/' + media_element_id + '/remove?destination=' + destination,
      success: function(data) {
        if(data.ok) {
          $captions.data('temporary-msg', data.msg);
          $.ajax({
            type: 'get',
            url: redirect_url
          });
        } else {
          showErrorPopUp(data.msg);
        }
      }
    });
  }
}
