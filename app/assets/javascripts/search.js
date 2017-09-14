/**
Collection of initializers for the graphical effects of the <b>search engine</b>.
@module search
**/





/**
Global initializer for the search engine.
@method searchDocumentReady
@for SearchDocumentReady
**/
function searchDocumentReady() {
  searchDocumentReadyGeneral();
  searchDocumentReadyFilterByTag();
}

/**
Initializes the <b>clickable tags</b> allowing a filter on a research.
@method searchDocumentReadyFilterByTag
@for SearchDocumentReady
**/
function searchDocumentReadyFilterByTag() {
  $body.on('click', '._clickable_tag_for_lessons, ._clickable_tag_for_media_elements', function() {
    if(!$(this).hasClass('current')) {
      var url = $('#info_container').data('currenturl');
      url = updateURLParameter(url, 'tag_id', '' + $(this).data('param'));
      url = updateURLParameter(url, 'page', '1');
      window.location = url;
    }
  });
  $body.on('click', '._clickable_tag_for_lessons.current, ._clickable_tag_for_media_elements.current', function() {
    var url = $('#info_container').data('currenturl');
    url = removeURLParameter(url, 'tag_id');
    url = updateURLParameter(url, 'page', '1');
    window.location = url;
  });
}

/**
Initializer for generic effects.
@method searchDocumentReadyGeneral
@for SearchDocumentReady
**/
function searchDocumentReadyGeneral() {
  $body.on('click', '#which_item_to_search_switch_media_elements', function() {
    $('#search_lessons_main_page').hide('fade', {}, 500, function() {
      $('#search_media_elements_main_page').show();
      $('#search_lessons_main_page').hide();
      if($('#general_pagination').is(':visible')) {
        $('#general_pagination').hide();
      } else {
        $('#general_pagination').show();
      }
    });
  });
  $body.on('click', '#which_item_to_search_switch_lessons', function() {
    $('#search_media_elements_main_page').hide('fade', {}, 500, function() {
      $('#search_media_elements_main_page').hide();
      $('#search_lessons_main_page').show();
      if($('#general_pagination').is(':visible')) {
        $('#general_pagination').hide();
      } else {
        $('#general_pagination').show();
      }
    });
  });
  $body.on('click', '._keep_searching', function() {
    $(this).data('opened', true);
    var form = $(this).parent();
    $('.advanced-search-content').animate({height: '995px'}, 500);
    form.animate({
      height: '210'
    }, 500, function() {
      form.find('._search_engine_form').show();
      form.find('._keep_searching').hide();
    });
  });
}

/**
Initializer for <b>search keyword</b> placeholders.
@method searchDocumentReadyPlaceholders
@for SearchDocumentReady
**/
function searchDocumentReadyPlaceholders() {
  $body.on('focus', '#lessons_tag_reader_for_search', function() {
    if($('#lessons_tag_kind_for_search').val() == '') {
      $(this).val('');
      $(this).css('color', '#939393');
      $('#lessons_tag_kind_for_search').val('0');
    }
  });
  $body.on('focus', '#media_elements_tag_reader_for_search', function() {
    if($('#media_elements_tag_kind_for_search').val() == '') {
      $(this).val('');
      $(this).css('color', '#939393');
      $('#media_elements_tag_kind_for_search').val('0');
    }
  });
  $body.on('focus', '#general_tag_reader_for_search', function() {
    $(this).val('');
    $(this).css('color', '#939393');
    $('#general_tag_kind_for_search').val('0');
    $('#search_general_submit').removeClass('current');
  });
  $body.on('click', '#search_general_submit', function() {
    if(!$(this).hasClass('current')) {
      $('#search_general').submit();
      $(this).addClass('current');
    }
  });
}
