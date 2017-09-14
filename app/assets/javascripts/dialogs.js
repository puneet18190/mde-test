/**
This module contains the javascript functions that use JQueryUi dialogs. Some of them are closed with a time delay (class {{#crossLink "DialogsTimed"}}{{/crossLink}}), other are closed with buttons by the user (class {{#crossLink "DialogsConfirmation"}}{{/crossLink}}), and other ones contain a form to be filled in by the user (class {{#crossLink "DialogsWithForm"}}{{/crossLink}}).
@module dialogs
**/





/**
Close a dialog with given HTML id.
@method closePopUp
@for DialogsAccessories
@param id {String} HTML id of the dialog
**/
function closePopUp(id) {
  $('#' + id).dialog('close');
}

/**
Adds the class <i>close on click out</i> to the widget overlay: this function is called on the callbacks of dialog functions, to allow the user to close the dialog directly clicking out.
@method customOverlayClose
@for DialogsAccessories
**/
function customOverlayClose() {
  $('.ui-widget-overlay').show().css('height', (2 * $window.height()) + 'px');
  $('.ui-widget-overlay').addClass('_close_on_click_out');
}

/**
Close and successively remove HTML for all media element poopups. It calls {{#crossLink "DialogsAccessories/removeCompletelyDocumentPopup:method"}}{{/crossLink}}.
@method removeCompletelyAllDocumentPopups
@for DialogsAccessories
**/
function removeCompletelyAllDocumentPopups() {
  $('.boxViewSingleDocument .menuController .preview').each(function() {
    removeCompletelyDocumentPopup($(this).data('document-id'));
  });
}

/**
Close and successively remove HTML for all media element poopups. It calls {{#crossLink "DialogsAccessories/removeCompletelyMediaElementPopup:method"}}{{/crossLink}}.
@method removeCompletelyAllMediaElementPopups
@for DialogsAccessories
**/
function removeCompletelyAllMediaElementPopups() {
  $('._media_element_item .menuController .preview').each(function() {
    removeCompletelyMediaElementPopup($(this).data('clickparam'));
  });
}

/**
Close and successively remove HTML for a given document popup.
@method removeCompletelyDocumentPopup
@for DialogsAccessories
@param document_id {Number} id of the document in the database, used to extract the HTML id of the dialog
**/
function removeCompletelyDocumentPopup(document_id) {
  var obj = $('#dialog-document-' + document_id);
  if(obj.length == 0) {
    return;
  }
  if(obj.data('dialog')) {
    obj.dialog('destroy');
  }
  obj.remove();
}

/**
Close and successively remove HTML for a given media element popup.
@method removeCompletelyMediaElementPopup
@for DialogsAccessories
@param media_element_id {Number} id of the element in the database, used to extract the HTML id of the dialog
**/
function removeCompletelyMediaElementPopup(media_element_id) {
  var obj = $('#dialog-media-element-' + media_element_id);
  if(obj.length == 0) {
    return;
  }
  if(obj.data('dialog')) {
    obj.dialog('destroy');
  }
  obj.remove();
}

/**
Opposite of {{#crossLink "DialogsAccessories/customOverlayClose:method"}}{{/crossLink}}. Remember that the widget-overlay object is unique for every dialog built with JQueryUi, thus it's compulsory to remove the class <i>close on click out</i> before opening a new dialog.
@method removeCustomOverlayClose
@for DialogsAccessories
**/
function removeCustomOverlayClose() {
  $('.ui-widget-overlay').removeClass('_close_on_click_out');
}





/**
Generic confirmation dialog.
@method showConfirmPopUp
@for DialogsConfirmation
@param title {String} title
@param content {String} text
@param msg_ok {String} caption for the button 'ok' (on the left side of the dialog)
@param msg_no {String} caption for the button 'cancel' (on the right side of the dialog)
@param callback_ok {Function} callback associated to the button 'ok'
@param callback_no {Function} callback associated to the button 'cancel'
**/
function showConfirmPopUp(title, content, msg_ok, msg_no, callback_ok, callback_no) {
  var obj = $('#dialog-confirm');
  content = '<img src="/assets/alert.png"/><h1>' + title + '</h1><p>' + content + '</p>';
  var dialog_buttons = {};
  dialog_buttons[msg_ok] = callback_ok;
  dialog_buttons[msg_no] = callback_no;
  if(obj.data('dialog')) {
    obj.html(content);
    obj.dialog('option', 'buttons', dialog_buttons);
    obj.dialog('open');
  } else {
    obj.show();
    obj.html(content);
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 485,
      show: 'fade',
      hide: {effect: 'fade'},
      buttons: dialog_buttons
    });
  }
}

/**
Dialog used in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}} and in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}, that asks the user if he wants to restore the cache or not. Specificly, it's used in the generic function {{#crossLink "MediaElementEditorCache/startCacheLoop:method"}}{{/crossLink}}.
@method showRestoreCacheMediaElementEditorPopUp
@for DialogsConfirmation
@param callback_ok {Function} callback function to restore the cache
@param callback_no {Function} callback function that removes the cache and opens the requested page
**/
function showRestoreCacheMediaElementEditorPopUp(callback_ok, callback_no) {
  var obj = $('#dialog-restore-cache-media-element-editor');
  var caption = $captions.data('restore-cache-media-element-editor-message');
  var msg_ok = $captions.data('restore-cache-media-element-editor-yes');
  var msg_no = $captions.data('restore-cache-media-element-editor-no');
  content = '<p class="upper">' + caption + '</p>';
  var dialog_buttons = {};
  dialog_buttons[msg_ok] = callback_ok;
  dialog_buttons[msg_no] = callback_no;
  if(obj.data('dialog')) {
    obj.html(content);
    obj.dialog('option', 'buttons', dialog_buttons);
    obj.dialog('open');
  } else {
    obj.show();
    obj.html(content);
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 520,
      show: 'fade',
      hide: {effect: 'fade'},
      buttons: dialog_buttons,
      open: function(event, ui) {
        var overlay = obj.parent().prev();
        overlay.addClass('dialog_opaco');
        $('.ui-widget-overlay').css('opacity', 0.9);
      },
      beforeClose: function() {
        $('.dialog_opaco').removeClass('dialog_opaco');
        $('.ui-widget-overlay').css('opacity', 0);
      },
      create:function () {
        $(this).closest('.ui-dialog').find('.ui-button').addClass('upper').addClass('schiacciato');
      }
    });
  }
}





/**
Dialog for the image gallery.
@method showImageInGalleryPopUp
@for DialogsGalleries
@param image_id {Number} id in the database of the image, which is used to extract the HTML id of the dialog
@param callback {Object} callback function (it depends on the gallery, see module {{#crossLinkModule "galleries"}}{{/crossLinkModule}}
**/
function showImageInGalleryPopUp(image_id, callback) {
  var obj = $('#dialog-image-gallery-' + image_id);
  var my_width = resizedWidthForImageGallery(obj.find('a').data('width'), obj.find('a').data('height'));
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      closeOnEscape: true,
      modal: true,
      width: my_width,
      resizable: false,
      draggable: false,
      show: 'fade',
      hide: {
        effect: 'fade',
        duration: 500
      },
      open: function() {
        customOverlayClose();
      },
      beforeClose: function() {
        removeCustomOverlayClose();
      },
      close: function() {
        if(typeof(callback) != 'undefined') {
          callback();
        }
      }
    });
  }
}

/**
Dialog for the video gallery (notice that the video is initialized in the moment the dialog gets opened.
@method showVideoInGalleryPopUp
@for DialogsGalleries
@param video_id {Number} id in the database of the video, which is used to extract the HTML id of the dialog
**/
function showVideoInGalleryPopUp(video_id) {
  var obj = $('#dialog-video-gallery-' + video_id);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      closeOnEscape: true,
      modal: true,
      resizable: false,
      draggable: false,
      width: 446,
      height: 360,
      show: 'fade',
      hide: {
        effect: 'fade',
        duration: 500
      },
      open: function() {
        customOverlayClose();
        var instance_id = $('#dialog-video-gallery-' + video_id + ' ._empty_video_player, #dialog-video-gallery-' + video_id + ' ._instance_of_player').attr('id');
        if(!$('#' + instance_id).data('initialized')) {
          var button = $(this).find('._select_video_from_gallery');
          var duration = button.data('duration');
          $('#' + instance_id + ' source[type="video/mp4"]').attr('src', button.data('mp4'));
          $('#' + instance_id + ' source[type="video/webm"]').attr('src', button.data('webm'));
          $('#' + instance_id + ' video').load();
          $('#' + instance_id + ' ._media_player_total_time').html(secondsToDateString(duration));
          $('#' + instance_id).data('duration', duration);
          $('#' + instance_id).removeClass('_empty_video_player').addClass('_instance_of_player');
          initializeMedia(instance_id, 'video');
        }
      },
      beforeClose: function() {
        stopMedia('#dialog-video-gallery-' + video_id + ' video');
        removeCustomOverlayClose();
      }
    });
  }
}





/**
Timed dialog for errors. It uses the general {{#crossLink "DialogsTimed/showTimedPopUp:method"}}{{/crossLink}}.
@method showErrorPopUp
@for DialogsTimed
@param content {String} the text content of the dialog
**/
function showErrorPopUp(content) {
  var new_content = '<img src="/assets/unsuccess.png"/><h1>' + content + '</h1>';
  showTimedPopUp(new_content, 'dialog-error');
}

/**
Timed dialog for success. It uses the general {{#crossLink "DialogsTimed/showTimedPopUp:method"}}{{/crossLink}}.
@method showOkPopUp
@for DialogsTimed
@param content {String} the text content of the dialog
**/
function showOkPopUp(content) {
  var new_content = '<img src="/assets/success.png"/><h1>' + content + '</h1>';
  showTimedPopUp(new_content, 'dialog-ok');
}

/**
General function that opens a dialog, fills it with HTML content and closes it after a configured time.
@method showTimedPopUp
@for DialogsTimed
@param content {String} HTML content
@param id {String} HTML id of the dialog
**/
function showTimedPopUp(content, id) {
  var obj = $('#' + id);
  obj.html(content);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 485,
      show: 'fade',
      hide: {effect: 'fade'},
      open: function(event, ui) {
        setTimeout(function() {
          closePopUp(id);
        }, $parameters.data('timeout'));
      }
    });
  }
}





/**
Dialog containing a form used to send a notification about modifications of a public lesson.
@method showLessonNotificationPopUp
@for DialogsWithForm
@param lesson_id {Number} id in the database of the lesson
**/
function showLessonNotificationPopUp(lesson_id) {
  var lesson_id_number = lesson_id.split('_');
  lesson_id_number = lesson_id_number[lesson_id_number.length - 1];
  var obj = $('#lesson-notification');
  $('#lesson-notification form').attr('action', ('/lessons/' + lesson_id_number + '/notify_modification'));
  var html_cover_content = $('._lesson_thumb._lesson_' + lesson_id_number).html();
  $('._lesson_notification_cover').html(html_cover_content);
  obj.data('lesson-id', lesson_id);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 710,
      height: 300,
      hide: {effect: 'fade'},
      show: 'fade',
      open: function() {
        $('#lesson-notification #lesson_notify_modification_details').blur();
        $('#lesson-notification #lesson_notify_modification_details').val($('#lesson-notification').data('message-placeholder'));
        $('#lesson-notification #lesson_notify_modification_details_placeholder').val('');
      }
    });
  }
}

/**
Dialog containing the form to upload a new document or media element. This function interacts with the module {{#crossLinkModule "uploader"}}{{/crossLinkModule}}.
@method showLoadPopUp
@param type {String} either 'document' or 'media-element'
@for DialogsWithForm
**/
function showLoadPopUp(type) {
  var obj = $('#load-' + type);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 760,
      height: 440,
      show: 'fade',
      hide: {effect: 'fade'},
      open: function(event, ui) {
        setTimeout(function() {
          obj.find('input').blur();
          obj.find('.title').val(obj.data('placeholder-title'));
          obj.find('.description').val(obj.data('placeholder-description'));
          obj.find('.title_placeholder').val('');
          obj.find('.description_placeholder').val('');
          obj.find('.tags_value').val('');
          obj.find('._tags_container span').remove();
          obj.find('._tags_container ._placeholder').show();
          obj.find('._tags_container .tags').val('').show();
          obj.find('.part1 .attachment .media').val(obj.data('placeholder-media'));
          obj.find('.form_error').removeClass('form_error');
          obj.find('.errors_layer').hide();
          obj.find('.part1 .attachment .file').val('');
        }, 100);
      }
    });
  }
}

/**
Dialog containing the document general information. This dialog contains also the form to change title and description (see the method {{#crossLink "MediaElementEditorForms/resetDocumentChangeInfo:method"}}{{/crossLink}}).
@method showDocumentInfoPopUp
@for DialogsWithForm
@param document_id {Number} id in the database of the document
**/
function showDocumentInfoPopUp(document_id) {
  var obj = $('#dialog-document-' + document_id);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 760,
      height: 440,
      show: 'fade',
      hide: {effect: 'fade'},
      open: function() {
        customOverlayClose();
        var word = $('#search_documents ._word_input').val()
        $('#dialog-document-' + document_id + ' .hidden_word').val(word);
      },
      beforeClose: function() {
        removeCustomOverlayClose();
      },
      close: function() {
        var container = $('#dialog-document-' + document_id);
        resetDocumentChangeInfo(container.find('.wrapper .change-info'));
        container.find('.preview').show();
        container.find('.wrapper .change-info').hide();
        container.find('.menu .change-info').removeClass('encendido');
      }
    });
  }
}

/**
Dialog containing the media element general information. If the element is private, this same dialog contains the form to change title, description and tags (see the method {{#crossLink "MediaElementEditorForms/resetMediaElementChangeInfo:method"}}{{/crossLink}}).
@method showMediaElementInfoPopUp
@for DialogsWithForm
@param media_element_id {Number} id in the database of the media element
**/
function showMediaElementInfoPopUp(media_element_id) {
  var obj = $('#dialog-media-element-' + media_element_id);
  if(obj.length > 0 && $('#dashboard_container .literature_container').length > 0) {
    $('#dashboard_container .literature_container, #dashboard_container .lesson_dashboard_thumb').css('z-index', 0);
  }
  if(!$('._media_element_item_id_' + media_element_id).data('preview-loaded')) {
    $.ajax({
      type: 'get',
      url: '/media_elements/' + media_element_id + '/preview/load'
    });
  } else {
    if(obj.data('dialog')) {
      obj.dialog('open');
    } else {
      obj.show();
      obj.dialog({
        modal: true,
        resizable: false,
        draggable: false,
        width: 760,
        height: 440,
        show: 'fade',
        hide: {effect: 'fade'},
        open: function() {
          customOverlayClose();
        },
        beforeClose: function() {
          removeCustomOverlayClose();
        },
        close: function() {
          var container = $('#dialog-media-element-' + media_element_id);
          var player = container.find('.preview .content ._instance_of_player');
          if(player.length > 0) {
            stopMedia('#dialog-media-element-' + media_element_id + ' ' + player.data('media-type'));
          }
          resetMediaElementChangeInfo(container.find('.wrapper .change-info'));
          container.find('.preview').show();
          container.find('._report_form_content').hide();
          container.find('.menu .report').removeClass('encendido');
          container.find('.wrapper .change-info').hide();
          container.find('.menu .change-info').removeClass('encendido');
        }
      });
    }
  }
}

/**
Dialog containing the form to send the public link of a lesson. Used in {{#crossLink "VirtualClassroomSendLink"}}{{/crossLink}}.
@method showSendLessonLinkPopUp
@for DialogsWithForm
@param lesson_id {Number} id in the database of the lesson
**/
function showSendLessonLinkPopUp(lesson_id) {
  var obj = $('#dialog-virtual-classroom-send-link');
  $('#dialog-virtual-classroom-send-link form').attr('action', ('/virtual_classroom/' + lesson_id + '/send_link'));
  var html_cover_content = $('#virtual_classroom_lesson_' + lesson_id + ' ._lesson_thumb').html();
  $('#dialog-virtual-classroom-send-link ._lesson_thumb').html(html_cover_content);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 690,
      height: 410,
      show: 'fade',
      hide: {effect: 'fade'},
      beforeClose: function() {
        $('#virtual_classroom_send_link_mails_box').data('jsp').destroy();
      },
      open: function() {
        $('#virtual_classroom_emails_selector').blur();
        $('#virtual_classroom_send_link_message').blur();
        $('#virtual_classroom_emails_selector').val(obj.data('emails-placeholder'));
        $('#virtual_classroom_send_link_message').val(obj.data('message-placeholder'));
        $('#virtual_classroom_emails_selector').data('placeholdered', true);
        $('#virtual_classroom_send_link_message_placeholder').val('');
        $('#virtual_classroom_send_link_hidden_emails').val('');
        $('#virtual_classroom_send_link_mails_box').html('');
        $('#select_mailing_list option[selected]').removeAttr('selected');
        var placeholder_select_box = $('#select_mailing_list option').first();
        placeholder_select_box.attr('selected', 'selected');
        $($('#select_mailing_list').next().find('a')[1]).html(placeholder_select_box.html());
      }
    });
  }
}

/**
Dialog containing a list of lessons to be loaded in the Virtual Classroom. Used in {{#crossLink "VirtualClassroomMultipleLoading"}}{{/crossLink}}.
@method showVirtualClassroomQuickSelectPopUp
@for DialogsWithForm
@param content {Object} HTML content for the list of lessons
**/
function showVirtualClassroomQuickSelectPopUp(content) {
  var obj = $('#dialog-virtual-classroom-quick-select');
  obj.html(content);
  if(obj.data('dialog')) {
    obj.dialog('open');
  } else {
    obj.show();
    obj.dialog({
      modal: true,
      resizable: false,
      draggable: false,
      width: 920,
      show: 'fade',
      hide: {effect: 'fade'},
      open: function(event, ui) {
        var overlay = obj.parent().prev();
        overlay.addClass('dialog_opaco');
        $('.ui-widget-overlay').css('opacity', 0.9);
      },
      close: function() {
        if(obj.data('loaded')) {
          var loaded_msg = obj.data('loaded-msg');
          if(obj.data('loaded-correctly')) {
            showOkPopUp(loaded_msg);
          } else {
            showErrorPopUp(loaded_msg);
          }
        }
        obj.data('loaded', false);
      }
    });
  }
}
