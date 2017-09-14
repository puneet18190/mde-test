/**
Generic javascript functions user throughout the application.
@module general
**/





/**
Calculates in which page the user is going to be redirected when he is watching a paginated list of items, and he resizes the screen. Used for example in the dashboard, and in the section of media elements.
@method calculateTheNewVisiblePage
@for GeneralCentering
@param for_page {Number} items for page before resizing
@param page {Number} page the user was visualizing before resizing
@param new_for_page {Number} items for page after resizing
**/
function calculateTheNewVisiblePage(for_page, page, new_for_page) {
  if(page == 1) {
    return 1;
  }
  var selected_item = for_page * (page - 1) + 1;
  return parseInt(selected_item / new_for_page) + 1;
}

/**
Centers a div into the current window.
@method centerThis
@for GeneralCentering
@param div {String} HTML selector to be centered
**/
function centerThis(div) {
  var winH = $window.height();
  var winW = $window.width();
  var centerDiv = $(div);
  centerDiv.css('top', winH/2 - centerDiv.height()/2);
  centerDiv.css('left', winW/2 - centerDiv.width()/2);
}

/**
Centers a div into a given container.
@method centerThisInContainer
@for GeneralCentering
@param div {String} HTML selector to be centered
@param container {String} HTML selector that represents the container in which the div must be centered
**/
function centerThisInContainer(div, container) {
  var contH = $(container).height();
  var contW = $(container).width();
  var centerDiv = $(div);
  centerDiv.css('top', (contH/2 - centerDiv.height()/2) + $(container).position().top);
  centerDiv.css('left', (contW/2 - centerDiv.width()/2) + $(container).position().left);
}

/**
Same structure of {{#crossLink "DashboardResizing/dashboardResizeController:method"}}{{/crossLink}}.
@method mediaElementsResizeController
@for GeneralCentering
@param resize_before {Boolean} if true, it resizes the elements also before calling the server
@param with_fade {Boolean} if true, it resizes with a fade
@param new_page {Number} forced page if any
**/
function mediaElementsResizeController(resize_before, with_fade, new_page) {
  if(!$('#display_expanded_media_elements').hasClass('current')) {
    return;
  }
  var info = $('#info_container');
  var width = $('#media_elements_title_bar').outerWidth();
  width = width - (width * 6 / 1000);
  var in_space = parseInt((width - 200) / 207) + 1;
  if(new_page == undefined) {
    var current_page = $('#general_pagination .pages a').first().data('page') + 1;
    var new_page = calculateTheNewVisiblePage(info.data('in-space') * 2, current_page, in_space * 2);
  }
  if(in_space <= 50 && in_space != info.data('in-space')) {
    info.data('in-space', in_space);
    if(resize_before) {
      resizeExpandedMediaElements(in_space);
    }
    var additional = with_fade ? '' : '&resizing=true';
    unbindLoader();
    $.ajax({
      type: 'get',
      url: '/media_elements?display=expanded&filter=' + $('#filter_media_elements option:selected').val() + '&page=' + new_page + '&for_row=' + in_space + additional
    }).always(bindLoader);
  } else {
    resizeExpandedMediaElements(in_space);
  }
}

/**
Same structure of {{#crossLink "DashboardResizing/resizeLessonsAndMediaElementsInDashboard:method"}}{{/crossLink}}.
@method resizeExpandedMediaElements
@for GeneralCentering
@param for_row {Number} how many media elements fit horizontally the screen
**/
function resizeExpandedMediaElements(for_row) {
  var width = $('#media_elements_title_bar').outerWidth();
  var percent_margin_width = width * 3 / 1000;
  var margin = (width - 2 * percent_margin_width - for_row * 200) / (for_row - 1);
  var counter = 1;
  var one_row = ($('#my_media_elements ._media_element_item').length <= for_row);
  $('#my_media_elements ._media_element_item').each(function() {
    if(counter == 1 || counter == (for_row + 1)) {
      $(this).css('margin-left', (percent_margin_width + 'px'));
    } else {
      $(this).css('margin-left', (margin + 'px'));
    }
    if(counter > for_row) {
      $(this).css('margin-top', '30px');
      $(this).css('margin-bottom', '10px');
    } else {
      $(this).css('margin-top', '0');
      if(one_row) {
        $(this).css('margin-bottom', '355px');
      }
    }
    counter += 1;
  });
}





/**
This function guesses the browser and writes it in a class of the tag 'html'.
@method browsersDocumentReady
@for GeneralDocumentReady
**/
function browsersDocumentReady() {
  var name = $.grep(_.keys($.browser), function(el, i) {
    return el !== 'version';
  })[0];
  if(name) {
    $html.addClass(name);
  }
}

/**
Initializer for functionalities which are common to sections containing media elements.
@method commonMediaElementsDocumentReady
@for GeneralDocumentReady
**/
function commonMediaElementsDocumentReady() {
  $body.on('keydown', '.dialogMediaElement .wrapper .change-info .part2 .title, .dialogMediaElement .wrapper .change-info .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('keydown', '.dialogMediaElement .wrapper .change-info .part2 .tags_container .tags', function() {
    $(this).parents('._tags_container').removeClass('form_error');
  });
  $body.on('click', '.dialogMediaElement .menu .close', function() {
    closePopUp($(this).parents('.dialogMediaElement').attr('id'));
  });
  $body.on('click', '.dialogMediaElement .menu .change-info', function() {
    var container = $(this).parents('.dialogMediaElement');
    var form = container.find('.wrapper .change-info');
    if($(this).hasClass('encendido')) {
      form.hide();
      container.find('.preview').show();
      resetMediaElementChangeInfo(form);
      $(this).removeClass('encendido');
    } else {
      container.find('.preview').hide();
      form.show();
      $(this).addClass('encendido');
      disableTagsInputTooHigh(form.find('.part2 ._tags_container'));
    }
  });
  $body.on('click', '.dialogMediaElement .wrapper .change-info .part3 .close', function() {
    var container = $(this).parents('.dialogMediaElement');
    var form = container.find('.wrapper .change-info');
    form.hide();
    container.find('.preview').show();
    container.find('.menu .change-info').removeClass('encendido');
    resetMediaElementChangeInfo(form);
  });
  $body.on('click', '.dialogMediaElement .wrapper .change-info .part3 .submit', function() {
    var container = $(this).parents('.dialogMediaElement');
    container.find('form').submit();
  });
  $body.on('click', '.dialogMediaElement .wrapper .change-info .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.dialogMediaElement').find('.wrapper .change-info');
    myself.hide();
    container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
  });
  $body.on('mouseenter', '.boxViewCompactMediaElement', function() {
    var item = $(this);
    item.data('loading-mini-thumb', true);
    setTimeout(function() {
      if(item.data('loading-mini-thumb')) {
        showMiniThumbnailForMediaElementCompact(item);
      }
    }, 500);
  });
  $body.on('mouseleave', '.boxViewCompactMediaElement', function() {
    var item = $(this);
    item.data('loading-mini-thumb', false);
    if(item.data('loaded-mini-thumb')) {
      hideMiniThumbnailForMediaElementCompact(item);
    }
  });
}

/**
Initializer for functionalities which are common to sections containing lessons.
@method commonLessonsDocumentReady
@for GeneralDocumentReady
**/
function commonLessonsDocumentReady() {
  $body.on('click','._lesson_compact', function() {
    if(!$(this).parent().hasClass('_disabled')) {
      var lessons_content = $('.lessons-content');
      var advanced_search_content = $('.advanced-search-content');
      var my_id = $(this).parent().attr('id');
      var my_expanded = $('#' + my_id + ' ._lesson_expanded');
      if(my_expanded.is(':visible')) {
        my_expanded.hide('blind', {}, 500, function() {
          my_expanded.hide();
        });
        if(lessons_content.length > 0) {
          lessons_content.animate({height: '665px'}, 500);
        } else {
          if ($('form#search_lessons ._keep_searching').data('opened')) {
            advanced_search_content.animate({height: '995px'}, 500);
          } else {
            advanced_search_content.animate({height: '805px'}, 500);
          }
        }
      } else {
        var there_is_expanded = $('._lesson_expanded:visible');
        if(there_is_expanded.length > 0) {
          there_is_expanded.hide('blind', {}, 500, function() {
            there_is_expanded.hide();
          });
        }
        my_expanded.show('blind', {}, 500, function() {
          my_expanded.show();
        });
        if(lessons_content.length > 0) {
          lessons_content.animate({height: '863px'}, 500);
        } else {
          if ($('form#search_lessons ._keep_searching').data('opened')) {
            advanced_search_content.animate({height: '1193px'}, 500);
          } else {
            advanced_search_content.animate({height: '1003px'}, 500);
          }
        }
      }
    }
  });
}

/**
Initializer for global functionalities, used throughout the application.
@method globalDocumentReady
@for GeneralDocumentReady
**/
function globalDocumentReady() {
  $body.on('click', '._close_on_click_out', function() {
    $('.ui-dialog-content:visible').each(function() {
      closePopUp($(this).attr('id'));
    });
  });
  $body.on('mouseenter', '.empty-situation-container a', function() {
    $(this).find('.plus').addClass('encendido');
  });
  $body.on('mouseleave', '.empty-situation-container a', function() {
    $(this).find('.plus').removeClass('encendido');
  });
  $body.on('mouseenter', '.highlight-with-text a', function() {
    $(this).find('.plus, .prompt').addClass('encendido');
  });
  $body.on('mouseleave', '.highlight-with-text a', function() {
    $(this).find('.plus, .prompt').removeClass('encendido');
  });
  $('#user_school_level_id').selectbox();
  $body.on('keyup blur', 'input[maxlength], textarea[maxlength]', function () {
    var myself = $(this);
    var len = myself.val().length;
    var maxlength = myself.attr('maxlength')
    if (maxlength && len > maxlength) {
      myself.val(myself.val().slice(0, maxlength));
    }
  });
  ajaxLoaderDocumentReady();
}

/**
Initializer for locations automatic filling.
@method locationsDocumentReady
@for GeneralDocumentReady
**/
function locationsDocumentReady() {
  $('._location_select_box').each(function() {
    $('#' + $(this).attr('id')).selectbox();
  });
  $body.on('change', '._location_select_box', function() {
    if(!$(this).data('is-last')) {
      var locations_url = '/locations/' + $(this).val() + '/find';
      if($(this).val() == '0') {
        var container = $(this).parents('.profile-element').prev();
        if(container.length > 0) {
          var sub_inputs = container.find('input');
          if(sub_inputs.length > 0) {
            locations_url = '/locations/' + sub_inputs.data('selected') + '/find?empty_children=true';
          } else {
            locations_url = '/locations/' + container.find('select').val() + '/find?empty_children=true';
          }
        } else {
          locations_url = '/locations/0/find';
        }
      }
      $.ajax({
        url: locations_url,
        type: 'get'
      });
    }
  });
}

/**
Initializes reports forms for both lessons and media elements.
@method reportsDocumentReady
@for GeneralDocumentReady
**/
function reportsDocumentReady() {
  $body.on('mouseenter', '._lesson_expanded .report', function() {
    $(this).addClass('encendido');
  });
  $body.on('mouseleave', '._lesson_expanded .report', function() {
    $(this).removeClass('encendido');
  });
  $body.on('click', '._lesson_expanded .report', function() {
    var button = $(this).find('.icon');
    var form = $(this).next();
    if(!button.hasClass('encendido')) {
      button.addClass('encendido');
      form.show();
    } else {
      button.removeClass('encendido');
      form.hide();
    }
    return false;
  });
  $body.on('click', '.dialogMediaElement .menu .report', function() {
    var button = $(this);
    var form = button.next();
    if(!button.hasClass('encendido')) {
      button.addClass('encendido');
      form.show();
    } else {
      button.removeClass('encendido');
      form.hide();
    }
    return false;
  });
  $body.on('click', '._report_form_content', function(e) {
    e.preventDefault();
    return false;
  });
  $body.on('click', '._report_form_content ._send', function(e) {
    $(this).closest('form').submit();
  });
}

/**
Functionalities necessary only for the section 'my documents'.
@method sectionDocumentsDocumentReady
@for GeneralDocumentReady
**/
function sectionDocumentsDocumentReady() {
  $body.on('click', '#my_documents .buttons .preview', function() {
    showDocumentInfoPopUp($(this).data('document-id'));
  });
  $body.on('click', '#my_documents .buttons .destroy', function() {
    var current_url = $('#info_container').data('currenturl');
    var document_id = $(this).data('document-id');
    var captions = $captions;
    var title = captions.data('destroy-document-title');
    var confirm = captions.data('destroy-document-confirm');
    var yes = captions.data('destroy-document-yes');
    var no = captions.data('destroy-document-no');
    if($(this).data('used-in-your-lessons')) {
      confirm = captions.data('destroy-document-confirm-bis');
    }
    showConfirmPopUp(title, confirm, yes, no, function() {
      $('#dialog-confirm').hide();
      var redirect_url = addDeleteItemToCurrentUrl(current_url, 'document_' + document_id);
      $.ajax({
        type: 'delete',
        dataType: 'json',
        url: '/documents/' + document_id,
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
  });
  $body.on('change', '#order_documents', function() {
    var order = $('#order_documents option:selected').val();
    var word = $('#search_documents ._word_input').val();
    var word_placeholder = $('#search_documents_placeholder').val();
    $('#search_documents_hidden_order').val(order);
    $.get('/documents?word=' + word + '&word_placeholder=' + word_placeholder + '&order=' + order);
  });
  $body.on('keydown', '.dialogDocument .wrapper .change-info .part2 .title, .dialogDocument .wrapper .change-info .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('click', '.dialogDocument .menu .close', function() {
    closePopUp($(this).parents('.dialogDocument').attr('id'));
  });
  $body.on('click', '.dialogDocument .menu .change-info', function() {
    var container = $(this).parents('.dialogDocument');
    var form = container.find('.wrapper .change-info');
    if($(this).hasClass('encendido')) {
      form.hide();
      container.find('.preview').show();
      resetDocumentChangeInfo(form);
      $(this).removeClass('encendido');
    } else {
      container.find('.preview').hide();
      form.show();
      $(this).addClass('encendido');
      disableTagsInputTooHigh(form.find('.part2 ._tags_container'));
    }
  });
  $body.on('click', '.dialogDocument .wrapper .change-info .part3 .close', function() {
    var container = $(this).parents('.dialogDocument');
    var form = container.find('.wrapper .change-info');
    form.hide();
    container.find('.preview').show();
    container.find('.menu .change-info').removeClass('encendido');
    resetDocumentChangeInfo(form);
  });
  $body.on('click', '.dialogDocument .wrapper .change-info .part3 .submit', function() {
    var container = $(this).parents('.dialogDocument');
    container.find('form').submit();
  });
  $body.on('click', '.dialogDocument .wrapper .change-info .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.dialogDocument').find('.wrapper .change-info');
    myself.hide();
    container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
  });
  $('#order_documents option[selected]').first().attr('selected', 'selected');
  $('#order_documents').selectbox();
  $body.on('keydown', '#search_documents ._word_input', function(e) {
    if(e.which == 13) {
      e.preventDefault();
    } else if(e.which != 39 && e.which != 37) {
      var letters = $(this).data('letters');
      letters += 1;
      $(this).data('letters', letters);
      $('#search_documents ._loader').show();
      setTimeout(function() {
        if($('#search_documents ._word_input').data('letters') == letters) {
          $('#search_documents ._loader').hide();
          $('#search_documents').submit();
        }
      }, 1500);
    }
  });
}

/**
Functionalities necessary only for the section 'my lessons'.
@method sectionLessonsDocumentReady
@for GeneralDocumentReady
**/
function sectionLessonsDocumentReady() {
  initSearchTagsAutocomplete('#general_tag_reader_for_search', 'lesson');
  $('#filter_lessons option[selected]').first().attr('selected', 'selected');
  $body.on('change', '#filter_lessons', function() {
    var filter = $('#filter_lessons option:selected').val();
    var redirect_url = '/lessons?filter=' + filter;
    $.get(redirect_url);
  });
  $('#filter_lessons').selectbox();
}

/**
Functionalities necessary only for the section 'my media elements'.
@method sectionMediaElementsDocumentReady
@for GeneralDocumentReady
**/
function sectionMediaElementsDocumentReady() {
  initSearchTagsAutocomplete('#general_tag_reader_for_search', 'media_element');
  $('#filter_media_elements option[selected]').first().attr('selected', 'selected');
  $body.on('change', '#filter_media_elements', function() {
    var filter = $('#filter_media_elements option:selected').val();
    if($('#display_expanded_media_elements').hasClass('current')) {
      $('#info_container').data('in-space', 0);
      mediaElementsResizeController(false, true, 1);
    } else {
      $.get('/media_elements?display=compact&filter=' + filter);
    }
  });
  $body.on('click', '#display_expanded_media_elements', function() {
    if(!$(this).hasClass('current')) {
      $(this).addClass('current');
      $('#display_compact_media_elements').removeClass('current');
      $('#info_container').data('in-space', 0);
      browserDependingScrollToTag().animate({scrollTop: ((1150 - $window.height() + $('.global-footer').height()) + 'px')}, 500);
      var last_item_compact = $('.boxViewCompactMediaElement').last();
      last_item_compact.animate({'margin-bottom': (102 + parseInt(last_item_compact.css('margin-bottom'))) + 'px'}, 500);
      $('.elements-content').animate({height: '767px'}, 500, function() {
        $(this).removeClass('fixed-compact-height').addClass('fixed-expanded-height');
      });
      mediaElementsResizeController(false, true, 1);
    }
  });
  $body.on('click', '#display_compact_media_elements', function() {
    if(!$(this).hasClass('current')) {
      $(this).addClass('current');
      $('#display_expanded_media_elements').removeClass('current');
      $.ajax({
        type: 'get',
        url: '/media_elements?display=compact',
        success: function (r) {
          $('.elements-content').animate({height: '665px'}, 500, function() {
            $(this).removeClass('fixed-expanded-height').addClass('fixed-compact-height')
          });
        }
      });
    }
  });
  $('#filter_media_elements').selectbox();
  mediaElementsResizeController(false, false);
  $window.resize(function() {
    mediaElementsResizeController(true, false);
  });
}

/**
Functionalities necessary only for the sections containing notifications.
@method sectionNotificationsDocumentReady
@for GeneralDocumentReady
**/
function sectionNotificationsDocumentReady() {
  $('#notifications_list').jScrollPane({
    autoReinitialise: true
  });
  $document.bind('click', function (e) {
    var click_id = $(e.target).attr('id');
    var my_report = $('.tooltipForm:visible');
    if($('#tooltip_content').length > 0) {
      if($('#tooltip_content').is(':visible')) {
        if(click_id != 'tooltip_content' && click_id != 'expanded_notification' && click_id != 'notifications_button' && $(e.target).parents('#tooltip_content').length == 0 && $(e.target).parents('#expanded_notification').length == 0) {
          $('#notifications_button').trigger('click');
        }
      }
    }
    if($('#tooltip_help').length > 0) {
      if($('#tooltip_help').is(':visible')) {
        if(click_id != 'tooltip_help' && click_id != 'help' && $(e.target).parents('#tooltip_help').length == 0) {
          $('#help').trigger('click');
        }
      }
    }
    if(my_report.length > 0 && $(e.target).parents('#' + my_report.attr('id')).length == 0) {
      my_report.parent().find('.report').click();
    }
  });
  $('#which_item_to_search option[selected]').first().attr('selected', 'selected');
  $('#which_item_to_search').selectbox();
}

/**
Functionalities necessary only for the section 'search'.
@method sectionSearchDocumentReady
@for GeneralDocumentReady
**/
function sectionSearchDocumentReady() {
  $('._which_item_to_search_switch[checked]').first().attr('checked', 'checked');
  $('._order_lessons_radio_input[checked]').first().attr('checked', 'checked');
  $('._order_media_elements_radio_input[checked]').first().attr('checked', 'checked');
  $('#filter_search_lessons option[selected]').first().attr('selected', 'selected');
  $('#filter_search_media_elements option[selected]').first().attr('selected', 'selected');
  $('#filter_search_lessons_subject option[selected]').first().attr('selected', 'selected');
  $('#filter_search_lessons_school_level option[selected]').first().attr('selected', 'selected');
  $('#filter_search_lessons').selectbox();
  $('#filter_search_media_elements').selectbox();
  $('#filter_search_lessons_subject').selectbox();
  $('#filter_search_lessons_school_level').selectbox();
  initSearchTagsAutocomplete('#lessons_tag_reader_for_search', 'lesson');
  initSearchTagsAutocomplete('#media_elements_tag_reader_for_search', 'media_element');
}





/**
Browser support checking, supported browsers version. It is empty. The not supported browsers version is implemented in {{#crossLink "BrowserSupportMain/browserSupportMain:method"}}{{/crossLink}}
@method browserSupport
@for GeneralMiscellanea
**/
function browserSupport() {
}

/**
Hides the mini thumbnail of a compact media element.
@method hideMiniThumbnailForMediaElementCompact
@for GeneralMiscellanea
@param item {Object} the compact media element
**/
function hideMiniThumbnailForMediaElementCompact(item) {
  item.data('loaded-mini-thumb', false);
  var mini = item.find('.mini_thumb');
  mini.hide('fade', {}, 200, function() {
    if(mini.hasClass('audio') || mini.hasClass('video')) {
      type = 'video';
      if(mini.hasClass('audio')) {
        type = 'audio';
      }
      var media = mini.find(type);
      media[0].pause();
      setCurrentTimeToMedia(media, 0);
    }
  });
}

/**
Initializes global variables used throughout the javascripts.
@method initializeGlobalVariables
@for GeneralMiscellanea
**/
function initializeGlobalVariables() {
  window.$body = $('body');
  window.$captions = $('#popup_captions_container');
  window.$document = $(document);
  window.$html = $('html');
  window.$loaderVisible = true;
  window.$loading = $('#loading');
  window.$parameters = $('#popup_parameters_container');
  window.$window = $(window);
}

/**
Shows a red error icon when somethings goes wrong. Widely used in {{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}} and in {{#crossLinkModule "image-editor"}}{{/crossLinkModule}}.
@method redError
@for GeneralMiscellanea
**/
function redError() {
  $body.prepend('<span class="_slide_error"></span>');
  centerThis('._slide_error');
  $('._slide_error').fadeTo('fast', 0).fadeTo('fast', 0.7).fadeTo('fast', 0.3).fadeOut();
}

/**
Function to convert seconds into a time string of the kind <i>02:35</i>; used in {{#crossLinkModule "video-editor"}}{{/crossLinkModule}} and in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}.
@method secondsToDateString
@for GeneralMiscellanea
@param seconds {Number} the seconds to be converted
**/
function secondsToDateString(seconds) {
  var mm = parseInt(seconds / 60);
  var ss = seconds % 60;
  var hh = parseInt(mm / 60);
  mm = mm % 60;
  var resp = '';
  if(hh > 0) {
    resp = hh + ':';
  }
  if(mm > 9) {
    resp = mm + ':';
  } else {
    resp = '0' + mm + ':';
  }
  if(ss > 9) {
    resp = resp + ss;
  } else {
    resp = resp + '0' + ss;
  }
  return resp;
}

/**
Handles the errors inside standard forms.
@method showFormErrors
@for GeneralMiscellanea
@param container {Object} JQuery object for the specific uploader (audio, video, image or document)
@param errors {Hash} a hash of the kind 'field': 'error'. It can't be undefined!
**/
function showFormErrors(container, errors) {
  container.find('.form_error').removeClass('form_error');
  container.find('.errors_layer').hide();
  $.each(errors, function(key, value) {
    if(key == 'full') {
      container.find('form').hide();
      container.find('.full_folder .msge').text(value);
      container.find('.full_folder').show();
    } else {
      var layer = container.find('.errors_layer.' + key);
      layer.text(value).show();
      container.find(layer.data('form-error-selector')).addClass('form_error');
    }
  });
  container.data('loader-can-move', false).data('loader-with-errors', true);
}

/**
Shows the mini thumbnail of a compact media element.
@method showMiniThumbnailForMediaElementCompact
@for GeneralMiscellanea
@param item {Object} the compact media element
**/
function showMiniThumbnailForMediaElementCompact(item) {
  item.data('loaded-mini-thumb', true);
  var position = 'below';
  var prev = item.prev();
  if(prev.length > 0) {
    prev = prev.prev();
    if(prev.length > 0 && prev.prev().length > 0) {
      position = 'above';
    }
  }
  var mini = item.find('.mini_thumb');
  mini.removeClass('above below').addClass(position).show('fade', {}, 200, function() {
    if(mini.hasClass('audio') || mini.hasClass('video')) {
      type = 'video';
      type_src_1 = 'mp4';
      type_src_2 = 'webm';
      if(mini.hasClass('audio')) {
        type = 'audio';
        type_src_1 = 'm4a';
        type_src_2 = 'ogg';
      }
      media = mini.find(type);
      if(!media.data('loaded')) {
        media.find('source[type="' + type + '/' + type_src_1 + '"]').attr('src', media.data(type_src_1));
        media.find('source[type="' + type + '/' + type_src_2 + '"]').attr('src', media.data(type_src_2));
        media.load();
        media.data('loaded', true);
      }
      media[0].play();
    }
  });
}





/**
Removes a parameter from an url.
@method removeURLParameter
@for GeneralUrls
@param url {String} initial url
@param param {String} param to remove
@return {String} updated url
**/
function removeURLParameter(url, param) {
  var newAdditionalURL = '';
  var tempArray = url.split('?');
  var baseURL = tempArray[0];
  var additionalURL = tempArray[1];
  var temp = '';
  if (additionalURL) {
    tempArray = additionalURL.split('&');
    for (i=0; i < tempArray.length; i++) {
      if(tempArray[i].split('=')[0] != param) {
        newAdditionalURL += (temp + tempArray[i]);
        temp = '&';
      }
    }
  }
  return (baseURL + '?' + newAdditionalURL);
}

/**
Adds or update new parameters to an url.
@method updateURLParameter
@for GeneralUrls
@param url {String} initial url
@param param {String} parameter
@param paramVal {String} new value for the parameter
@return {String} updated url
**/
function updateURLParameter(url, param, paramVal) {
  var newAdditionalURL = '';
  var tempArray = url.split('?');
  var baseURL = tempArray[0];
  var additionalURL = tempArray[1];
  var temp = '';
  if (additionalURL) {
    tempArray = additionalURL.split('&');
    for (i=0; i < tempArray.length; i++) {
      if(tempArray[i].split('=')[0] != param) {
        newAdditionalURL += (temp + tempArray[i]);
        temp = '&';
      }
    }
  }
  var rows_txt = temp + '' + param + '=' + paramVal;
  return (baseURL + '?' + newAdditionalURL + rows_txt);
}
