/**
The dashboard contains a list of suggested lessons and media elements. The dashboard is the first page shown to the logged user.
<br/><br/>
When the dashboard is opened at first, it's possible to see two subsections, one containing elements and the other one containing lessons. The number of items shown depends on the browser, this functionality is handled by the class {{#crossLink "DashboardResizing"}}{{/crossLink}}. At any time the user resizes the window, the application calls the server that responds with index.js (see {{#crossLink "DashboardAccessories/dashboardDocumentReady:method"}}{{/crossLink}}).
<br/><br/>
Clicking on a special icon, the section of lessons or media elements can be expanded or compressed: this functionality is handled in {{#crossLink "DashboardExpandedContents"}}{{/crossLink}}. Finally, a single lesson has its own expansion that opens a div containing description, author and subject: see functions in the class {{#crossLink "DashboardLessonDescriptions"}}{{/crossLink}}.
@module dashboard
**/





/**
Initializes the dashboard, and reactions to window resizing. To handle hover sensitive lessons and show a div containing the description, the method calls functions in {{#crossLink "DashboardLessonDescriptions"}}{{/crossLink}}.
@method dashboardDocumentReady
@for DashboardAccessories
**/
function dashboardDocumentReady() {
  dashboardResizeController();
  $window.resize(function() {
    dashboardResizeController();
  });
  initSearchTagsAutocomplete('#general_tag_reader_for_search', 'lesson');
  $body.on('mouseenter', '.lesson_dashboard_hover_sensitive', function() {
    var item = $(this).find('.literature_container');
    item.data('delaying', true);
    setTimeout(function() {
      if(item.data('delaying')) {
        openDescriptionDashboardLayer(item);
      }
    }, 500);
  });
  $body.on('mouseleave', '.lesson_dashboard_hover_sensitive', function() {
    var item = $(this).find('.literature_container');
    item.data('delaying', false);
    if(item.data('moving')) {
      item.data('moving', false);
    } else {
      item.animate({height: '80px'}, 200, function() {
        item.find('.description').hide();
      });
    }
  });
  $body.on('click', '#dashboard_container .title_lessons .expand_icon.off', function() {
    if(!$(this).data('moving')) {
      expandLessonsInDashboard();
    }
  });
  $body.on('click', '#dashboard_container .title_media_elements .expand_icon.off', function() {
    if(!$(this).data('moving')) {
      expandMediaElementsInDashboard();
    }
  });
  $body.on('click', '#dashboard_container .title_lessons .expand_icon.on', function() {
    if(!$(this).data('moving')) {
      compressLessonsInDashboard();
    }
  });
  $body.on('click', '#dashboard_container .title_media_elements .expand_icon.on', function() {
    if(!$(this).data('moving')) {
      compressMediaElementsInDashboard();
    }
  });
}

/**
Empties the pages, before loading new contents. This is used in the action index.js.erb.
@method emptyAllPagesInDashboard
@for DashboardAccessories
@param selector {String} either 'lessons' or 'media_elements'
**/
function emptyAllPagesInDashboard(selector) {
  var container = $('#dashboard_container .space_' + selector);
  container.find('.page1').html('');
  container.find('.page2').html('');
  container.find('.page3').html('');
  container.find('.page4').html('');
  container.find('.page5').html('');
  container.find('.page6').html('');
}

/**
Resets all the pages to invisible, and sets as visible the one selected by the user.
@method resetVisibilityOfAllPagesInDashboard
@for DashboardAccessories
@param selector {String} either 'lessons' or 'media_elements'
@param visible {Number} the number of the page to be shown
**/
function resetVisibilityOfAllPagesInDashboard(selector, visible) {
  var container = $('#dashboard_container .space_' + selector);
  container.find('.dashpage').hide();
  container.find('.page' + visible).show();
}





/**
Compresses the section 'lessons', using animate to have a graphical effect.
@method compressLessonsInDashboard
@for DashboardExpandedContents
**/
function compressLessonsInDashboard() {
  var container = $('#dashboard_container');
  container.find('.title_lessons .expand_icon.on').hide();
  container.find('.title_lessons .expand_icon.off').show().data('moving', true);
  $('#dashboard_container .pagination_lessons').animate({height: '0px'}, 40, function() {
    $('#dashboard_container .space_lessons').animate({height: '315px'}, 500, function() {
      container.data('lessons-expanded', false);
      unbindLoader();
      $.ajax({
        type: 'get',
        url: '/dashboard/lessons?for_row=' + container.data('lessons-in-space')
      }).always(bindLoader);
      if(container.find('.space_lessons .page1 .lesson_in_dashboard').length <= container.data('lessons-in-space')) {
        $('#dashboard_container .title_lessons .expand_icon.off').removeClass('off').addClass('disabled');
      }
    });
  });
}

/**
Compresses the section 'media elements', using animate to have a graphical effect.
@method compressMediaElementsInDashboard
@for DashboardExpandedContents
**/
function compressMediaElementsInDashboard() {
  var container = $('#dashboard_container');
  container.find('.title_media_elements .expand_icon.on').hide();
  container.find('.title_media_elements .expand_icon.off').show().data('moving', true);
  $('#dashboard_container .pagination_media_elements').animate({height: '0px'}, 40, function() {
    $('#dashboard_container .space_media_elements').animate({height: '315px'}, 500, function() {
      container.data('media-elements-expanded', false);
      unbindLoader();
      $.ajax({
        type: 'get',
        url: '/dashboard/media_elements?for_row=' + container.data('media-elements-in-space')
      }).always(bindLoader);
      if(container.find('.space_media_elements .page1 .boxViewExpandedMediaElement').length <= container.data('media-elements-in-space')) {
        $('#dashboard_container .title_media_elements .expand_icon.off').removeClass('off').addClass('disabled');
      }
    });
  });
}

/**
Expands the section 'lessons', using animate to have a graphical effect.
@method expandLessonsInDashboard
@for DashboardExpandedContents
**/
function expandLessonsInDashboard() {
  var container = $('#dashboard_container');
  container.find('.title_lessons .expand_icon.off').hide();
  container.find('.title_lessons .expand_icon.on').show().data('moving', true);
  $('#dashboard_container .space_lessons').animate({height: '660px'}, 500, function() {
    container.data('lessons-expanded', true);
    $('#dashboard_container .pagination_lessons').animate({height: '40px'}, 40);
    unbindLoader();
    $.ajax({
      type: 'get',
      url: '/dashboard/lessons?for_row=' + container.data('lessons-in-space') + '&expanded=true'
    }).always(bindLoader);
  });
}

/**
Expands the section 'media elements', using animate to have a graphical effect. The variable 'scroll_height' is calculated as follows: if the section lessons has been expanded (see {{#crossLink "DashboardExpandedContents/expandLessonsInDashboard:method"}}{{/crossLink}}) the overall height is 72px (header) + 61px (header menu) + 50px (margin of global content) + 70px (header of lessons) + 660px (height of lessons) + 40px (pagination of lessons) + 50px (margin of the section elements) + 70px (header of elements) + 660px (height of section elements, once it is expanded) + 40px (pagination of elements) + 50px (padding between main content and footer) = 1823px; if lessons are not expanded, the height of lessons is only 315, and it's not calculated the height of lessons pagination, obtaining a total of 1438px. The scroll is launched with a delay of 150 ms, to avoid overlapping with the expansion effect.
@method expandMediaElementsInDashboard
@for DashboardExpandedContents
**/
function expandMediaElementsInDashboard() {
  var container = $('#dashboard_container');
  container.find('.title_media_elements .expand_icon.off').hide();
  container.find('.title_media_elements .expand_icon.on').show().data('moving', true);
  var scroll_height = (container.data('lessons-expanded') ? 1823 : 1438) - $window.height() + $('.global-footer').height();
  setTimeout(function() {
    browserDependingScrollToTag().animate({scrollTop: (scroll_height + 'px')}, 500);
  }, 150);
  $('#dashboard_container .space_media_elements').animate({height: '660px'}, 500, function() {
    container.data('media-elements-expanded', true);
    $('#dashboard_container .pagination_media_elements').animate({height: '40px'}, 40);
    unbindLoader();
    $.ajax({
      type: 'get',
      url: '/dashboard/media_elements?for_row=' + container.data('media-elements-in-space') + '&expanded=true'
    }).always(bindLoader);
  });
}

/**
This function is used to initialize the paginator in the dashboard. It replaces the paginator, copying and pasting it from a hidden div. The method is called only for an expanded section, otherwise there is no pagination.
@method initializeDashboardPagination
@for DashboardExpandedContents
@param selector {String}  either 'lessons' or 'media_elements'
@param pos {Number} the current page
@param pages_amount {Number} the total amount of pages
**/
function initializeDashboardPagination(selector, pos, pages_amount) {
  $('#dashboard_container .pagination_' + selector + ' .dots_pagination_container').replaceWith($('#hidden_dashboard_pagination').html());
  var space = $('#dashboard_container .space_' + selector);
  var info = $('#info_container');
  var paginator = $('#dashboard_container .pagination_' + selector + ' .dots_pagination_container');
  var first_page = paginator.find('.pages a').first();
  var second_page = $(paginator.find('.pages a')[1]);
  var third_page = paginator.find('.pages a').last();
  first_page.data('page', (pos - 1));
  second_page.data('page', pos);
  third_page.data('page', (pos + 1));
  var next_space = $('#dashboard_container .space_' + selector + ' .page' + (pos + 1));
  if(pos != 1) {
    first_page.removeClass('disabled').attr('title', paginator.data('title-prev'));
  }
  if(next_space.length != 0 && next_space.find('div').length != 0) {
    third_page.removeClass('disabled').attr('title', paginator.data('title-next'));
  }
  var prevPage = function(prevPage) {
    space.find('.page' + pos).hide('fade', {}, 500, function() {
      space.find('.page' + (pos - 1)).show();
      info.data('currenturl', updateURLParameter(info.data('currenturl'), (selector + '_expanded'), (pos - 1)));
      initializeDashboardPagination(selector, pos - 1, pages_amount);
    });
    return true;
  }
  var nextPage = function(nextPage) {
    space.find('.page' + pos).hide('fade', {}, 500, function() {
      space.find('.page' + (pos + 1)).show();
      info.data('currenturl', updateURLParameter(info.data('currenturl'), (selector + '_expanded'), (pos + 1)));
      initializeDashboardPagination(selector, pos + 1, pages_amount);
    });
    return true;
  }
  new DotsPagination(paginator.find('.pages'), pages_amount, { 'complete': { 'prev': prevPage, 'next': nextPage } });
}





/**
This method calls {{#crossLink "DashboardLessonDescriptions/openDescriptionDashboardRecursionLayer:method"}}{{/crossLink}} after a certain delay of ms (this procedure is similar to the one defined in {{#crossLink "VideoEditorComponents/startVideoEditorPreviewClipWithDelay:method"}}{{/crossLink}}, in the module {{#crossLinkModule "video-editor"}}{{/crossLinkModule}}.
@method openDescriptionDashboardLayer
@for DashboardLessonDescriptions
@param item {Object} the div that expands, containing a hidden description
**/
function openDescriptionDashboardLayer(item) {
  var tot_time = 200;
  var h_i = item.height();
  var h_f = 263 - h_i;
  var k = h_f / (tot_time * tot_time);
  item.find('.description').show();
  item.data('moving', true);
  openDescriptionDashboardRecursionLayer(item, 0, h_i, h_f, tot_time);
}

/**
This method is used to open the special div containing description, author and subject of a lesson. It doesn't use animate so it's possible to reverse the expansion just firing mouseleave on the lesson.
@method openDescriptionDashboardRecursionLayer
@for DashboardLessonDescriptions
@param item {Object} the div that expands, containing a hidden description
@param t {Number} the current time in the animation
@param h_i {Number} the current height
@param h_f {Number} the final height of the div
@param tot_time {Number} the total time available to achieve the animation
**/
function openDescriptionDashboardRecursionLayer(item, t, h_i, h_f, tot_time) {
  var height = h_i + ((t * h_f) / tot_time);
  item.css('height', (height + 'px'));
  if(t < tot_time) {
    if(item.data('moving')) {
      setTimeout(function() {
        openDescriptionDashboardRecursionLayer(item, (t + 5), h_i, h_f, tot_time);
      }, 5);
    } else {
      item.animate({height: '80px'}, t, function() {
        item.find('.description').hide();
      });
    }
  } else {
    item.data('moving', false);
  }
}





/**
This method makes decisions about how to react to a resize event. First it centers the lessons, calculating the maximum number that fits the available horizontal space, and the margin-left to apply. Then, it uses such a margin left to calculate the available space for media elements (these must be aligned with the lessons on both left and right sides). After the correct number of lessons and media elements has been calculated, the method decides if it's necessary to call the server and fetch new items: if this is not necessary, it's called {{#crossLink "DashboardResizing/resizeLessonsAndMediaElementsInDashboard:method}}{{/crossLink}}.
@method dashboardResizeController
@for DashboardResizing
**/
function dashboardResizeController() {
  var container = $('#dashboard_container');
  var width = container.width();
  var lessons_in_space = parseInt((width - 20) / 320);
  var media_elements_in_space = parseInt((width - 20) / 222);
  var lessons_margin = (width - lessons_in_space * 300) / (lessons_in_space + 1);
  var lessons_width = lessons_in_space * (300 + lessons_margin) - lessons_margin;
  media_elements_in_space = parseInt((lessons_width - 207) / 207) + 1;
  var condition_lessons = (lessons_in_space <= 50 && lessons_in_space != container.data('lessons-in-space'));
  var condition_media_elements = (media_elements_in_space <= 50 && media_elements_in_space != container.data('media-elements-in-space'));
  if(condition_lessons || condition_media_elements) {
    var dashboard_url = '/dashboard?media_elements_for_row=' + media_elements_in_space + '&lessons_for_row=' + lessons_in_space;
    if(container.data('lessons-expanded')) {
      var current_lessons_page = container.find('.pagination_lessons .pages a').first().data('page') + 1;
      var new_lessons_page = calculateTheNewVisiblePage(container.data('lessons-in-space') * 2, current_lessons_page, lessons_in_space * 2);
      resetVisibilityOfAllPagesInDashboard('lessons', new_lessons_page);
      dashboard_url += '&lessons_expanded=' + new_lessons_page;
    }
    if(container.data('media-elements-expanded')) {
      var current_media_elements_page = container.find('.pagination_media_elements .pages a').first().data('page') + 1;
      var new_media_elements_page = calculateTheNewVisiblePage(container.data('media-elements-in-space') * 2, current_media_elements_page, media_elements_in_space * 2);
      resetVisibilityOfAllPagesInDashboard('media_elements', new_media_elements_page);
      dashboard_url += '&media_elements_expanded=' + new_media_elements_page;
    }
    container.data('lessons-in-space', lessons_in_space);
    container.data('media-elements-in-space', media_elements_in_space);
    resizeLessonsAndMediaElementsInDashboard(lessons_in_space, media_elements_in_space, true);
    unbindLoader();
    $.ajax({
      type: 'get',
      url: dashboard_url
    }).always(bindLoader);
  } else {
    resizeLessonsAndMediaElementsInDashboard(lessons_in_space, media_elements_in_space, false);
  }
}

/**
This method resizes lessons and media elements without calling the server to add new ones.
@method resizeLessonsAndMediaElementsInDashboard
@for DashboardResizing
@param lessons {Number} how many lessons fit horizontally the screen
@param media_elements {Number} how many media elements fit horizontally the screen
@param with_vertical_margin {Boolean} if true, sets temporarily the vertical margin to adapt to the new pagination: this is used in case the server is too slow, to visualize in a good way the items while waiting for an answer
**/
function resizeLessonsAndMediaElementsInDashboard(lessons, media_elements, with_vertical_margin) {
  var container = $('#dashboard_container');
  var lessons_margin = (container.width() - lessons * 300) / (lessons + 1);
  container.find('.space_lessons .lesson_in_dashboard').css('margin-left', lessons_margin + 'px');
  container.find('.title_lessons .icon').css('margin-left', lessons_margin + 'px');
  if(with_vertical_margin) {
    container.find('.space_lessons .dashpage').each(function() {
      var second_row_lesson = $($(this).find('.lesson_in_dashboard')[lessons]);
      var first_row_lesson = second_row_lesson.prev();
      while(second_row_lesson.length != 0) {
        second_row_lesson.css('margin-top', '30px');
        second_row_lesson = second_row_lesson.next();
      }
      while(first_row_lesson.length != 0) {
        first_row_lesson.css('margin-top', '0px');
        first_row_lesson = first_row_lesson.prev();
      }
    });
    container.find('.space_media_elements .dashpage').each(function() {
      var second_row_media_element = $($(this).find('.boxViewExpandedMediaElement')[media_elements]);
      var first_row_media_element = second_row_media_element.prev();
      while(second_row_media_element.length != 0) {
        second_row_media_element.css('margin-top', '30px');
        second_row_media_element = second_row_media_element.next();
      }
      while(first_row_media_element.length != 0) {
        first_row_media_element.css('margin-top', '0px');
        first_row_media_element = first_row_media_element.prev();
      }
    });
  }
  var new_calc = 2 * lessons_margin + 90;
  container.find('.title_lessons .icon').next().css('width', 'calc(100% - ' + new_calc + 'px)');
  container.find('.space_media_elements .dashpage').each(function() {
    var first_media_element = $(this).find('.boxViewExpandedMediaElement').first();
    first_media_element.css('margin-left', lessons_margin + 'px');
    var first_media_element_of_second_row = $($(this).find('.boxViewExpandedMediaElement')[media_elements]);
    first_media_element_of_second_row.css('margin-left', lessons_margin + 'px');
    var media_elements_margin = (container.width() - (2 * lessons_margin) - media_elements * 202) / (media_elements - 1);
    $(this).find('.boxViewExpandedMediaElement').each(function() {
      if($(this).attr('id') != first_media_element.attr('id') && $(this).attr('id') != first_media_element_of_second_row.attr('id')) {
        $(this).css('margin-left', media_elements_margin + 'px');
      }
    });
  });
  container.find('.title_media_elements .icon').css('margin-left', lessons_margin + 'px');
  var new_calc = 2 * lessons_margin + 90;
  container.find('.title_media_elements .icon').next().css('width', 'calc(100% - ' + new_calc + 'px)');
}
