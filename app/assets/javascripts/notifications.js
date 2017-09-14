/**
Javascript functions used to handle notifications.
@module notifications
**/





/**
Closes the div containig an expanded notification.
@method hideExpandedNotification
@for NotificationsAccessories
**/
function hideExpandedNotification() {
  $('#expanded_notification').html('');
  $('#expanded_notification').hide();
}

/**
Hides the help button.
@method hideHelpButton
@for NotificationsAccessories
**/
function hideHelpButton() {
  $('#help').removeClass('current');
}

/**
Hides the help tooltip.
@method hideHelpTooltip
@for NotificationsAccessories
**/
function hideHelpTooltip() {
  $('#tooltip_help').hide();
}

/**
Hides the notifications button.
@method hideNotificationsButton
@for NotificationsAccessories
**/
function hideNotificationsButton() {
  $('#notifications_button').removeClass('current');
}

/**
Hides the notifications orange icon over the notifications button.
@method hideNotificationsFumetto
@for NotificationsAccessories
**/
function hideNotificationsFumetto() {
  $('#tooltip_arancione').hide();
}

/**
Hides the notifications tooltip.
@method hideNotificationsTooltip
@for NotificationsAccessories
**/
function hideNotificationsTooltip() {
  $('#tooltip_content').hide();
  hideExpandedNotification();
}

/**
Shows the help button.
@method showHelpButton
@for NotificationsAccessories
**/
function showHelpButton() {
  $('#help').addClass('current');
}

/**
Shows the help tooltip.
@method showHelpTooltip
@for NotificationsAccessories
**/
function showHelpTooltip() {
  $('#tooltip_help').show();
}

/**
Shows the notifications button.
@method showNotificationsButton
@for NotificationsAccessories
**/
function showNotificationsButton() {
  $('#notifications_button').addClass('current');
}

/**
Shows the notifications orange icon over the notifications button.
@method showNotificationsFumetto
@for NotificationsAccessories
**/
function showNotificationsFumetto() {
  $('#tooltip_arancione').show();
}

/**
Shows the notifications tooltip.
@method showNotificationsTooltip
@for NotificationsAccessories
**/
function showNotificationsTooltip() {
  $('#tooltip_content').show();
}





/**
Component of document ready for notifications, used to initialize the action of reload on scroll.
@method initializeScrollAtBottomNewBlockNotification
@for NotificationsDocumentReady
**/

function initializeScrollAtBottomNewBlockNotification() {
  $('#tooltip_content .scroll-pane').bind('jsp-arrow-change', function(event, isAtTop, isAtBottom, isAtLeft, isAtRight) {
    var tot_number = $('#tooltip_content').data('tot-number');
    var offset = $('#tooltip_content').data('offset');
    if(isAtBottom && (offset < tot_number)) {
      $.get('/notifications/get_new_block?offset=' + offset);
    }
  });
}

/**
Global initializer for notifications and help. The function {{#crossLink "NotificationsDocumentReady/notificationsDocumentReadyLoop:method"}}{{/crossLink}} is called after a time of 2500 not to be called at the same time of {{#crossLink "MediaElementEditorConversion/mediaElementLoaderConversionOverview:method"}}{{/crossLink}}.
@method notificationsDocumentReady
@for NotificationsDocumentReady
**/
function notificationsDocumentReady() {
  notificationsDocumentReadyTooltips();
  if($('#notifications_main').length > 0) {
    setTimeout(function() {
      notificationsDocumentReadyLoop(5000);
    }, 2500);
  }
}

/**
Initializes the form for notifying a lesson's modifications. These actions are linked on the button {{#crossLink "ButtonsLesson/unpublishLesson:method"}}{{/crossLink}}, provided that it has the class <i>lesson change not notified</i>.
@method notificationsDocumentReadyLessonModification
@for NotificationsDocumentReady
**/
function notificationsDocumentReadyLessonModification() {
  $body.on('click', '#lesson-notification ._no', function(e) {
    e.preventDefault();
    closePopUp('lesson-notification');
    var lesson_id = $('#lesson-notification').data('lesson-id');
    $('#' + lesson_id).removeClass('_lesson_change_not_notified');
    $('#' + lesson_id + ' .unpublish').attr('title', $captions.data('title-unpublish'));
    var id = lesson_id.split('_');
    id = id[id.length - 1];
    unbindLoader();
    $.ajax({
      type: 'post',
      url: '/lessons/' + id + '/dont_notify_modification'
    }).always(bindLoader);
  });
  $body.on('focus', '#lesson-notification #lesson_notify_modification_details', function() {
    if($('#lesson-notification #lesson_notify_modification_details_placeholder').val() === '') {
      $(this).val('');
      $('#lesson-notification #lesson_notify_modification_details_placeholder').val('0');
    }
  });
}

/**
Initializer for the loop that updates the notifications
@method notificationsDocumentReadyLoop
@for NotificationsDocumentReady
@param time {Number} the time to iterate the loop
**/
function notificationsDocumentReadyLoop(time) {
  unbindLoader();
  $.ajax({
    url: '/notifications/reload',
    type: 'get'
  }).always(bindLoader);
  setTimeout(function() {
    notificationsDocumentReadyLoop(time);
  }, time);
}

/**
General initializer for help and notifications tooltips.
@method notificationsDocumentReadyTooltips
@for NotificationsDocumentReady
**/
function notificationsDocumentReadyTooltips() {
  initializeNotifications();
  initializeHelp();
  initializeScrollAtBottomNewBlockNotification();
  $body.on('click', '._destroy_notification', function(e) {
    e.stopImmediatePropagation();
    var my_id = $(this).data('param');
    var offset = $('#tooltip_content').data('offset');
    $.post('/notifications/' + my_id + '/destroy?offset=' + offset);
  });
}





/**
Initializes the graphical tools of the <b>help tooltip</b>.
@method initializeHelp
@for NotificationsGraphics
**/
function initializeHelp() {
  $body.on('click', '#help', function() {
    if(!$('#tooltip_help').is(':visible')) {
      hideNotificationsTooltip();
      $('#tooltip_help').show('fade', {}, 500, function() {
        showHelpTooltip();
      });
      showHelpButton();
      $body.css('overflow-x', 'hidden');
    } else {
      hideHelpTooltip();
      hideHelpButton();
    }
  });
}

/**
Initializes the graphical tools and the routes attached to the <b>notifications tooltip</b>.
@method initializeNotifications
@for NotificationsGraphics
**/
function initializeNotifications() {
  if($('#tooltip_arancione').data('number') > 0) {
    showNotificationsFumetto();
    showNotificationsButton();
  }
  $body.on('click', '#notifications_button', function() {
    if(!$('#tooltip_content').is(':visible')) {
      hideHelpTooltip();
      hideHelpButton();
      $('#tooltip_content').show('fade', {}, 500, function() {
        showNotificationsTooltip();
      });
      hideNotificationsFumetto();
      if(!$('#notifications_button').hasClass('current')) {
        showNotificationsButton();
      }
    } else {
      $('#tooltip_content, #expanded_notification').hide('fade', {}, 500, function() {
        hideNotificationsTooltip();
      });
      if($('#tooltip_arancione').data('number') > 0) {
        showNotificationsFumetto();
      } else {
        hideNotificationsButton();
      }
    }
  });
  $body.on('click', '._single_notification', function() {
    var closest_li = $(this).closest('._single_notification');
    var my_own_id = closest_li.attr('id')
    var my_content = $('#' + my_own_id + ' ._expanded_notification').html();
    var my_expanded = $('#expanded_notification');
    if(!my_expanded.is(':visible')) {
      my_expanded.html(my_content);
      my_expanded.data('contentid', my_own_id);
      my_expanded.show('fade', {}, 500, function() {
        my_expanded.show();
        if(!$(this).hasClass('current')) {
          unbindLoader();
          $.ajax({
            type: 'post',
            url: '/notifications/' + closest_li.data('param') + '/seen'
          }).always(bindLoader);
        }
      });
    } else {
      if(my_expanded.data('contentid') != my_own_id) {
        my_expanded.html(my_content);
        my_expanded.data('contentid', my_own_id);
        if(!$(this).hasClass('current')) {
          unbindLoader();
          $.ajax({
            type: 'post',
            url: '/notifications/' + closest_li.data('param') + '/seen'
          });
        }
      } else {
        my_expanded.hide('fade', {}, 500, function() {
          hideExpandedNotification();
        });
      }
    }
  });
}
