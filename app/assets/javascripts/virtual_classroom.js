/**
The <b>Virtual Classroom</b> is a container where the user can collect and visualize lessons. In the left part of the screen is located the list of lessons (with pagination), on the right there is the playlist.
<br/><br/>
On each lesson, there are buttons to perform actions (see {{#crossLink "VirtualClassroomDocumentReady/virtualClassroomDocumentReadyIconsAndButtons:method"}}{{/crossLink}}). Furthermore, each lesson can be dragged using <i>JQueryUi draggable</i> and dropped inside the playlist (see {{#crossLink "VirtualClassroomJavaScriptAnimations/initializeDraggableVirtualClassroomLesson:method"}}{{/crossLink}}).
<br/><br/>
One of the buttons in the header opens a popup for loading multiple lessons (initialized in {{#crossLink "VirtualClassroomDocumentReady/virtualClassroomDocumentReadyMultipleLessonLoading:method"}}{{/crossLink}}, see also {{#crossLink "VirtualClassroomMultipleLoading"}}{{/crossLink}}); another functionality is the popup to send the public link of a lesson (initialized in {{#crossLink "VirtualClassroomDocumentReady/virtualClassroomDocumentReadySendLink:method"}}{{/crossLink}}, see also {{#crossLink "VirtualClassroomSendLink"}}{{/crossLink}}).
@module virtual-classroom
**/





/**
Global initializer.
@method virtualClassroomDocumentReady
@for VirtualClassroomDocumentReady
**/
function virtualClassroomDocumentReady() {
  initializeVirtualClassroom();
  virtualClassroomDocumentReadyPlaylist();
  virtualClassroomDocumentReadyMultipleLessonLoading();
  virtualClassroomDocumentReadyIconsAndButtons();
  virtualClassroomDocumentReadySendLink();
}

/**
Initializer for icons and buttons.
@method virtualClassroomDocumentReadyIconsAndButtons
@for VirtualClassroomDocumentReady
**/
function virtualClassroomDocumentReadyIconsAndButtons() {
  $body.on('click', '._remove_lesson_from_inside_virtual_classroom', function() {
    var lesson_id = $(this).data('clickparam');
    var current_url = $('#info_container').data('currenturl');
    var redirect_url = addDeleteItemToCurrentUrl(current_url, ('virtual_classroom_lesson_' + lesson_id));
    $.ajax({
      type: 'post',
      dataType: 'json',
      url: '/virtual_classroom/' + lesson_id + '/remove_lesson_from_inside',
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
  });
  $body.on('click', '#empty_virtual_classroom', function() {
    if(!$(this).hasClass('disabled')) {
      var captions = $captions;
      var title = captions.data('empty-virtual-classroom-title');
      var confirm = captions.data('empty-virtual-classroom-confirm');
      var yes = captions.data('empty-virtual-classroom-yes');
      var no = captions.data('empty-virtual-classroom-no');
      showConfirmPopUp(title, confirm, yes, no, function() {
        closePopUp('dialog-confirm');
        $.ajax({
          type: 'post',
          url: '/virtual_classroom/empty_virtual_classroom'
        });
      }, function() {
        closePopUp('dialog-confirm');
      });
    }
  });
  $body.on('click', '._virtual_classroom_preview', function(e) {
    e.preventDefault();
    if(!$(this).parent().hasClass('_disabled')) {
      var my_param = $(this).data('lesson-id');
      var redirect_back_to = $("#info_container").data('currenturl');
      previewLesson(my_param, redirect_back_to);
    }
    return false;
  });
}

/**
Initializer for multiple lessons loading.
@method virtualClassroomDocumentReadyMultipleLessonLoading
@for VirtualClassroomDocumentReady
**/
function virtualClassroomDocumentReadyMultipleLessonLoading() {
  $body.on('click', '#open_quick_load_lessons_popup_in_virtual_classroom', function() {
    if(!$(this).hasClass('current')) {
      $.ajax({
        type: 'get',
        url: '/virtual_classroom/select_lessons'
      });
    }
  });
  $body.on('click', '._virtual_classroom_quick_loaded_lesson', function() {
    var cover = $('#' + this.id + ' ._lesson_thumb');
    if(!cover.hasClass('current')) {
      var appended = $('#' + this.id + ' ._current_inserted');
      if(appended.length == 0) {
        $('#virtual_classroom_quick_select_submit').removeClass('current');
        $('#' + this.id + ' input').val('1');
        cover.append('<div class="currentInserted _current_inserted"><a></a></div>');
      } else {
        $('#' + this.id + ' input').val('0');
        appended.remove();
        if($('#dialog-virtual-classroom-quick-select ._current_inserted').length == 0) {
          $('#virtual_classroom_quick_select_submit').addClass('current');
        }
      }
    }
  });
  $body.on('mouseover', '._virtual_classroom_quick_loaded_lesson ._current_inserted', function() {
    $(this).children('a').addClass('with_x');
  });
  $body.on('mouseout', '._virtual_classroom_quick_loaded_lesson ._current_inserted', function() {
    $(this).children('a').removeClass('with_x');
  });
  $body.on('click', '#virtual_classroom_quick_select_submit', function() {
    if(!$(this).hasClass('current')) {
      $('#virtual_classroom_quick_select_container form').submit();
    }
  });
  $body.on('click', '#virtual_classroom_quick_select_close', function() {
    $('.dialog_opaco').removeClass('dialog_opaco');
    $('.ui-widget-overlay').css('opacity', 0);
    closePopUp('dialog-virtual-classroom-quick-select');
  });
}

/**
Initializer for playlist.
@method virtualClassroomDocumentReadyPlaylist
@for VirtualClassroomDocumentReady
**/
function virtualClassroomDocumentReadyPlaylist() {
  $body.on('click', '._playlist_play', function() {
    window.location = '/lessons/view/playlist';
  });
  $body.on('mouseover', '._lesson_in_playlist', function() {
    $('#' + this.id + ' ._remove_lesson_from_playlist').show();
  });
  $body.on('mouseout', '._lesson_in_playlist', function() {
    $('#' + this.id + ' ._remove_lesson_from_playlist').hide();
  });
  $body.on('click', '._remove_lesson_from_playlist', function() {
    var lesson_id = $(this).data('clickparam');
    $.ajax({
      type: 'post',
      url: '/virtual_classroom/' + lesson_id + '/remove_lesson_from_playlist'
    });
  });
  $body.on('click', '._empty_playlist_button', function() {
    var captions = $captions;
    var title = captions.data('empty-virtual-classroom-playlist-title');
    var confirm = captions.data('empty-virtual-classroom-playlist-confirm');
    var yes = captions.data('empty-virtual-classroom-playlist-yes');
    var no = captions.data('empty-virtual-classroom-playlist-no');
    showConfirmPopUp(title, confirm, yes, no, function() {
      closePopUp('dialog-confirm');
      $.ajax({
        type: 'post',
        url: '/virtual_classroom/empty_playlist'
      });
    }, function() {
      closePopUp('dialog-confirm');
    });
  });
}

/**
Initializer for popup sending the public link of a lesson.
@method virtualClassroomDocumentReadySendLink
@for VirtualClassroomDocumentReady
**/
function virtualClassroomDocumentReadySendLink() {
  $body.on('click', '._send_lesson_link', function() {
    if($('#info_container').data('user-trial')) {
      showErrorPopUp($captions.data('trial-user-lock-virtual-classroom-send-link'));
      return
    }
    var lesson_id = $(this).data('lesson-id');
    showSendLessonLinkPopUp(lesson_id);
    $('#virtual_classroom_send_link_mails_box').jScrollPane({
      autoReinitialise: true
    });
  });
  $body.on('focus', '#virtual_classroom_emails_selector', function() {
    if($(this).data('placeholdered')) {
      $(this).val('');
      $(this).data('placeholdered', false);
    }
  });
  $body.on('focus', '#virtual_classroom_send_link_message', function() {
    var placeholder = $('#virtual_classroom_send_link_message_placeholder');
    if(placeholder.val() === '') {
      $(this).val('');
      placeholder.val('0');
    }
  });
  $body.on('click', '#virtual_classroom_emails_submitter', function() {
    addEmailToVirtualClassroomSendLessonLinkSelector();
  });
  $body.on('keydown', '#virtual_classroom_emails_selector', function(e) {
    if(e.which === 186) {
      e.preventDefault();
      var value = $(this).val();
      value += '@';
      $(this).val(value);
    }
    if(e.which === 13) {
      e.preventDefault();
      addEmailToVirtualClassroomSendLessonLinkSelector();
    }
  });
  $body.on('click', '#virtual_classroom_send_link_mails_box ._remove', function() {
    $(this).parent().remove();
    resetVirtualClassroomSendLinkLines();
    setTimeout(function() {
      resetVirtualClassroomSendLinkLines();
    }, 700);
  });
  $('#select_mailing_list').selectbox({
    onChange: function(val, inst) {
      if(val != '') {
        var emails = $('#virtual_classroom_hidden_mailing_lists ._mailing_list_' + val + ' div');
        for(var i = 0; i < emails.length; i++) {
          $('#virtual_classroom_send_link_mails_box .jspPane').append(emails[i].outerHTML);
          resetVirtualClassroomSendLinkLines();
          setTimeout(function() {
            resetVirtualClassroomSendLinkLines();
          }, 700);
        }
      }
    }
  });
  $body.on('click', '#dialog-virtual-classroom-send-link ._no', function() {
    var obj = $('#dialog-virtual-classroom-send-link');
    closePopUp('dialog-virtual-classroom-send-link');
  });
  $body.on('click', '#dialog-virtual-classroom-send-link ._yes', function() {
    var obj = $('#dialog-virtual-classroom-send-link');
    obj.dialog('option', 'hide', null);
    var emails_input = '';
    $('#virtual_classroom_send_link_mails_box .jspPane ._email ._text').each(function() {
      emails_input += ($(this).html() + ',');
    });
    emails_input = emails_input.substr(0, emails_input.length - 1);
    $('#virtual_classroom_send_link_hidden_emails').val(emails_input);
    closePopUp('dialog-virtual-classroom-send-link');
    obj.dialog('option', 'hide', {effect: "fade"});
    $('#dialog-virtual-classroom-send-link form').submit();
  });
}





/**
Gets the highest zIndex value among elements of a given class.
@method getMaximumZIndex
@for VirtualClassroomJavaScriptAnimations
@param a_class {String} HTML class name
@return {Number} highest zIndex value
**/
function getMaximumZIndex(a_class) {
  var index_highest = 0;
  $('.' + a_class).each(function() {
    var index_current = parseInt($(this).css("zIndex"), 10);
    if(index_current > index_highest) {
      index_highest = index_current;
    }
  });
  return index_highest;
}

/**
Initializes the functionality of dragging a single lesson into the playlist.
@method initializeDraggableVirtualClassroomLesson
@for VirtualClassroomJavaScriptAnimations
@param id {String} HTML id of the lesson
**/
function initializeDraggableVirtualClassroomLesson(id) {
  var lesson_cover = $('#' + id + ' ._lesson_thumb');
  var object = $('#' + id);
  if(object.hasClass('ui-draggable')) {
    object.draggable('enable');
  } else {
    object.draggable({
      revert: true,
      handle: '._lesson_thumb',
      cursor: 'move',
      containment: '.griglia-contenuti',
      helper: function() {
        var current_z_index = getMaximumZIndex('_virtual_classroom_lesson') + 1;
        var div_to_return = $('#' + this.id + ' ._lesson_thumb')[0].outerHTML;
        div_to_return = '<div ' + 'style="' + current_z_index + ';outline:1px solid white" ' + div_to_return.substr(5, div_to_return.length);
        return div_to_return;
      },
      start: function() {
        lesson_cover.addClass('current');
      },
      stop: function(event, ui) {
        if(!ui.helper.hasClass('_lesson_dropped')) {
          lesson_cover.removeClass('current');
        }
      }
    });
  }
  if(lesson_cover.hasClass('current')) {
    lesson_cover.removeClass('current');
  }
  if(object.data('in-playlist')) {
    object.data('in-playlist', false);
  }
}

/**
Initialize playlist container (using <i>JQueryUi sortable</i>)and jScrollPane.
@method initializePlaylist
@for VirtualClassroomJavaScriptAnimations
**/
function initializePlaylist() {
  $('#lessons_list_in_playlist').jScrollPane({
    autoReinitialise: true
  });
  $('#virtual_classroom_playlist').droppable({
    accept: '._virtual_classroom_lesson',
    drop: function(event, ui) {
      ui.helper.hide();
      ui.helper.addClass('_lesson_dropped');
      $.ajax({
        type: 'post',
        url: '/virtual_classroom/' + ui.draggable.data('lesson-id') + '/add_lesson_to_playlist'
      });
    },
    hoverClass: 'current'
  });
  $('#virtual_classroom_playlist .jspPane').sortable({
    scroll: true,
    handle: '._lesson_in_playlist',
    axis: 'y',
    cursor: 'move',
    cancel: '._remove_lesson_from_playlist',
    helper: function(event, ui) {
      var current_z_index = getMaximumZIndex('_lesson_in_playlist') + 1;
      var div_to_return = $($('#' + ui.attr('id'))[0].outerHTML);
      div_to_return.addClass('current');
      div_to_return = div_to_return[0].outerHTML;
      var my_index = div_to_return.indexOf('<div class="_remove_lesson_from_playlist');
      var second_half_string = div_to_return.substring(my_index, div_to_return.length);
      var my_second_index = my_index + second_half_string.indexOf('</div>') + 6;
      return div_to_return.substring(0, (my_index - 1)) + div_to_return.substring((my_second_index + 1), div_to_return.length);
    },
    stop: function(event, ui) {
      var previous = ui.item.prev();
      var new_position = 0;
      var old_position = ui.item.data('position');
      if(previous.length == 0) {
        new_position = 1;
      } else {
        var previous_item_position = previous.data('position');
        if(old_position > previous_item_position) {
          new_position = previous_item_position + 1;
        } else {
          new_position = previous_item_position;
        }
      }
      if(old_position != new_position) {
        $.ajax({
          type: 'post',
          url: '/virtual_classroom/' + ui.item.data('lesson-id') + '/playlist/' + new_position + '/change_position'
        });
      }
    }
  });
}

/**
Uses together {{#crossLink "VirtualClassroomJavaScriptAnimations/initializeDraggableVirtualClassroomLesson:method"}}{{/crossLink}} and {{#crossLink "VirtualClassroomJavaScriptAnimations/initializePlaylist:method"}}{{/crossLink}}.
@method initializeVirtualClassroom
@for VirtualClassroomJavaScriptAnimations
**/
function initializeVirtualClassroom() {
  $('._virtual_classroom_lesson').each(function() {
    if($(this).data('in-playlist')) {
      $('#' + this.id + ' ._lesson_thumb').addClass('current');
    } else {
      initializeDraggableVirtualClassroomLesson(this.id);
    }
  });
  initializePlaylist();
}





/**
Initializer for lessons that can't be loaded from the multiple lessons loader.
@method initializeNotAvailableLessonsToLoadQuick
@for VirtualClassroomMultipleLoading
**/
function initializeNotAvailableLessonsToLoadQuick() {
  $('._virtual_classroom_quick_loaded_lesson').each(function() {
    if(!$(this).data('available')) {
      $('#' + this.id + ' ._lesson_thumb').addClass('current');
    }
  });
}

/**
Initializer for the JScrollPain in the multiple lessons loader (event infinite scroll to load more lessons).
@method initializeScrollPaneQuickLessonSelector
@for VirtualClassroomMultipleLoading
**/
function initializeScrollPaneQuickLessonSelector() {
  $('#virtual_classroom_quick_select_container.scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var page = $('#virtual_classroom_quick_select_container').data('page');
    var tot_pages = $('#virtual_classroom_quick_select_container').data('tot-pages');
    if(isAtBottom && (page < tot_pages)) {
      $.get('/virtual_classroom/select_lessons_new_block?page=' + (page + 1));
    }
  });
}





/**
Add email to recipients list on email add button (+).
@method addEmailToVirtualClassroomSendLessonLinkSelector
@for VirtualClassroomSendLink
**/
function addEmailToVirtualClassroomSendLessonLinkSelector() {
  var selector = $('#virtual_classroom_emails_selector');
  if(!selector.data('placeholdered') && selector.val() != '') {
    $('#virtual_classroom_send_link_mails_box .jspPane').append('<div class="_email"><span class="_text">' + selector.val() + '</span><a class="_remove"></a></div>');
    selector.val('');
    resetVirtualClassroomSendLinkLines();
    setTimeout(function() {
      resetVirtualClassroomSendLinkLines();
    }, 700);
  }
}

/**
Resets the spaces between the emails sent.
@method resetVirtualClassroomSendLinkLines
@for VirtualClassroomSendLink
**/
function resetVirtualClassroomSendLinkLines() {
  var container = $('#virtual_classroom_send_link_mails_box .jspPane');
  var must_first_line = true;
  container.find('._email').removeClass('first_line');
  container.find('._email').each(function() {
    if(must_first_line) {
      var me = $(this);
      var prev = me.prev();
      if(prev.length > 0) {
        if(me.position().top != prev.position().top) {
          must_first_line = false;
        } else {
          me.addClass('first_line');
        }
      } else {
        me.addClass('first_line');
      }
    }
  });
}
