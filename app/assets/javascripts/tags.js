/**
The functions in this module handle two different functionalities of <b>autocomplete</b> for tags: suggestions for a research (<b>search autocomplete</b>), and suggestions for tagging lessons and media elements (<b>tagging autocomplete</b>). Both modes use the same JQuery plugin called <i>JQueryAutocomplete</i> (the same used in {{#crossLink "AdminAutocomplete/initNotificationsAutocomplete:method"}}{{/crossLink}}).
<br/><br/>
The <b>search</b> autocomplete mode requires a simple initializer (method {{#crossLink "TagsInitializers/initSearchTagsAutocomplete:method"}}{{/crossLink}}), which is called for three different keyword inputs of the search engine (the general one, the one for elements and the one for lessons).
<br/><br/>
The <b>tagging</b> autocomplete mode is slightly more complicated, because it must show to the user a friendly view of the tags he added (small boxes with an 'x' to remove it) and at the same time store a string value to be send to the rails backend. The implemented solution is a <b>container</b> div that contains a list of tag <b>boxes</b> (implemented with span, see {{#crossLink "TagsAccessories/createTagSpan:method"}}{{/crossLink}}) and an <b>tag input</b> where the user writes; when he inserts a new tag and presses <i>enter</i> or <i>comma</i>, the tag is added to the previous line in the container; if such a line is full, the tag input is moved to the next line; when the lines in the container are over, the tag input gets disabled (see {{#crossLink "TagsAccessories/disableTagsInputTooHigh:method"}}{{/crossLink}}). During this whole process, a <b>hidden input</b> gets updated with a string representing the current tags separated by comma ({{#crossLink "TagsAccessories/addToTagsValue:method"}}{{/crossLink}}, {{#crossLink "TagsAccessories/removeFromTagsValue:method"}}{{/crossLink}}).
<br/><br/>
The system also checks if the inserted tag is not repeated (using {{#crossLink "TagsAccessories/checkNoTagDuplicates:method"}}{{/crossLink}}), and assigns a different color for tags already in the database and for new ones ({{#crossLink "TagsAccessories/addTagWithoutSuggestion:method"}}{{/crossLink}}).
<br/><br/>
The <b>tagging autocomplete mode</b> is initialized using the scope class '_tags_container' which is unique (see method {{#crossLink "TagsInitializers/tagsDocumentReady:method"}}{{/crossLink}}).
@module tags
**/





/**
Adds a tag without using the suggestion (the case with the suggestion is handled by {{#crossLink "TagsInitializers/initTagsAutocomplete:method"}}{{/crossLink}}). In the particular case in which the user adds the tag <b>before</b> the autocomplete has shown the list of matches, this method calls a route from the backend that checks if the tag was present in the database: if yes, the tag gets colored differently.
@method addTagWithoutSuggestion
@for TagsAccessories
@param input {Object} JQuery object for the tag input
@param container {Object} JQuery object for the container
@param tags_value {Object} JQuery object for the hidden input
**/
function addTagWithoutSuggestion(input, container, tags_value) {
  var my_val = $.trim(input.val()).toLowerCase();
  if(my_val.length >= $parameters.data('min-tag-length') && checkNoTagDuplicates(my_val, container)) {
    addToTagsValue(my_val, tags_value);
    createTagSpan(my_val).insertBefore(input);
    unbindLoader();
    $.ajax({
      type: 'get',
      url: '/tags/' + my_val + '/check_presence',
      dataType: 'json',
      success: function(data) {
        if(data.ok) {
          container.find('span.' + getUnivoqueClassForTag(my_val)).removeClass('new_tag');
        }
      }
    }).always(bindLoader);
    disableTagsInputTooHigh(container);
  }
  $('.ui-autocomplete').hide();
  input.val('');
}

/**
Adds a tag to the <b>hidden input</b>.
@method addToTagsValue
@for TagsAccessories
@param word {String} tag to be inserted
@param value_input {Object} JQuery object for the hidden input
**/
function addToTagsValue(word, value_input) {
  var old_value = value_input.val();
  if(old_value.indexOf(',') == -1) {
    old_value = (',' + word + ',');
  } else {
    old_value += (word + ',');
  }
  value_input.val(old_value);
}

/**
Checks if a tag is already present in the hidden input.
@method checkNoTagDuplicates
@for TagsAccessories
@param word {String} tag to be checked
@param container {Object} JQuery object for the container
@return {Boolean}
**/
function checkNoTagDuplicates(word, container) {
  var flag = true;
  container.find('span').each(function() {
    if($(this).text() === word) {
      flag = false;
    }
  });
  return flag;
}

/**
Creates a new span box for a tag.
@method createTagSpan
@for TagsAccessories
@param word {String} tag to be created
@return {Object} span element
**/
function createTagSpan(word) {
  var span = $('<span>').text(word);
  var a = $('<a>').addClass('remove').appendTo(span);
  span.addClass('new_tag ' + getUnivoqueClassForTag(word));
  return span;
}

/**
Disables the tag input if the container is full.
@method disableTagsInputTooHigh
@for TagsAccessories
@param container {Object} JQuery object for the container
**/
function disableTagsInputTooHigh(container) {
  var line = 1;
  var curr_width = 12;
  container.find('span a.remove').each(function() {
    var mywidth = $(this).parent().outerWidth(true)
    curr_width += mywidth;
    if(curr_width > container.data('max-width')) {
      curr_width = mywidth + 12;
      line += 1;
    }
  });
  if(line > container.data('lines')) {
    container.find('.tags').hide();
  }
}

/**
Generates a unique class for a given tag (containing underscores, and taking into consideration special characters).
@method getUnivoqueClassForTag
@for TagsAccessories
@param word {String} tag
@return {String} unique class for that tag
**/
function getUnivoqueClassForTag(word) {
  var resp = '';
  for(var i = 0; i < word.length; i++) {
    resp += '_' + word.charCodeAt(i);
  }
  return resp
}

/**
Removes a tag from the <b>hidden input</b>.
@method removeFromTagsValue
@for TagsAccessories
@param word {String} tag to be removed
@param value_input {Obbject} Jquery object for the hidden input
**/
function removeFromTagsValue(word, value_input) {
  var old_value = value_input.val();
  old_value = old_value.replace((',' + word + ','), ',');
  value_input.val(old_value);
}





/**
Initializer for search autocompĺete.
@method initSearchTagsAutocomplete
@for TagsInitializers
@param input {String} HTML selector for the input
@param item {String} lesson or media_element
**/
function initSearchTagsAutocomplete(input, item) {
  var cache = {};
  $(input).autocomplete({
    minLength: 2,
    source: function(request, response) {
      var term = request.term;
      if(term in cache) {
        response(cache[term]);
        return;
      }
      unbindLoader();
      $.ajax({
        dataType: 'json',
        url: '/tags/get_list',
        data: {
          term: request.term,
          item: item
        },
        success: function(data, status, xhr) {
          cache[term] = data;
          response(data);
        }
      }).always(bindLoader);
    }
  });
}

/**
Initializer for tagging autocompĺete.
@method initTagsAutocomplete
@for TagsInitializers
@param container {Object} JQuery object for the tags container
@param item {String} lesson or media_element
**/
function initTagsAutocomplete(container, item) {
  container.autocomplete({
    source: function(request, response) {
      unbindLoader();
      $.ajax({
        dataType: 'json',
        url: '/tags/get_list',
        data: {
          term: request.term,
          item: item
        },
        success: response
      }).always(bindLoader);
    },
    search: function() {
      if(this.value.length < $parameters.data('min-length-search-tags')) {
        return false;
      }
    }
  });
}

/**
Global document ready for tags functionality.
@method tagsDocumentReady
@for TagsInitializers
**/
function tagsDocumentReady() {
  $body.on('click', '._tags_container .remove', function() {
    var container = $(this).parents('._tags_container');
    var span = $(this).parent();
    var tags = container.find('.tags');
    removeFromTagsValue(span.text(), container.find('.tags_value'));
    span.remove();
    if(tags.not(':visible')) {
      tags.show();
      disableTagsInputTooHigh(container);
    }
  });
  $body.on('click', '._tags_container', function() {
    $(this).find('.tags').focus();
    $(this).find('._placeholder').hide();
    $(this).find('.tags').show();
  });
  $body.on('keydown', '._tags_container .tags', function(e) {
    var container = $(this).parents('._tags_container');
    if(e.which === 13 || e.which === 188) {
      e.preventDefault();
      addTagWithoutSuggestion($(this), container, container.find('.tags_value'));
    } else if(e.which == 8 && $(this).val() == '') {
      $(this).prev().find('.remove').trigger('click');
    }
  });
  $body.on('blur', '._tags_container #tags', function(e) {
    var container = $(this).parents('._tags_container');
    addTagWithoutSuggestion($(this), container, container.find('.tags_value'));
  });
}
