/**
Javascript functions used in the media element and document loader.
<br/><br/>
The class {{#crossLink "UploaderGlobal"}}{{/crossLink}} contains functions that handle uploading processes in regular sections, such as dashboard, my elements, my documents, and also Lesson Editor ({{#crossLinkModule "lesson-editor"}}{{/crossLinkModule}}, see the initializer {{#crossLink "LessonEditorDocumentReady/lessonEditorDocumentReadyUploaderInGallery:method"}}{{/crossLink}}).
@module uploader
**/





/**
Initializer for the loading form.
@method uploaderDocumentReady
@for UploaderDocumentReady
**/
function uploaderDocumentReady() {
  $body.on('click', '.openLoader', function() {
    showLoadPopUp($(this).data('type'));
  });
  $body.on('change', '.globalLoader .part1 .attachment .file', function() {
    var container = $(this).parents('.globalLoader');
    var file_name = $(this).val().replace("C:\\fakepath\\", '');
    if(file_name.replace(/^[\s\t]+/, '') != '') {
      if(file_name.length > 20) {
        file_name = file_name.substring(0, 20) + '...';
      }
      container.find('.part1 .attachment .media').val(file_name).removeClass('form_error');
    } else {
      container.find('.part1 .attachment .media').val(container.data('placeholder-media')).removeClass('form_error');
    }
  });
  $body.on('click', '.globalLoader .part3 .close', function() {
    if(!$(this).hasClass('disabled')) {
      var container = $(this).parents('.globalLoader');
      closePopUp(container.attr('id'));
    }
  });
  $body.on('click', '.globalLoader .part3 .submit', function(e) {
    var container = $(this).parents('.globalLoader');
    if(!$(this).hasClass('disabled')) {
      disableUploadForm(container, $captions.data('dont-leave-page-up' + container.attr('id')));
      recursionUploadingBar(container, 0);
      setTimeout(function() {
        container.find('form').submit();
      }, 1500);
    } else {
      e.preventDefault();
    }
  });
  $body.on('focus', '.globalLoader .part2 .title', function() {
    var container = $(this).parents('.globalLoader');
    if(container.find('.part2 .title_placeholder').val() == '') {
      $(this).val('');
      container.find('.part2 .title_placeholder').val('0');
    }
  });
  $body.on('focus', '.globalLoader .part2 .description', function() {
    var container = $(this).parents('.globalLoader');
    if(container.find('.part2 .description_placeholder').val() == '') {
      $(this).val('');
      container.find('.part2 .description_placeholder').val('0');
    }
  });
  $body.on('submit', '.globalLoader form', function() {
    var container = $(this).parents('.globalLoader');
    document.getElementById($(this).attr('id')).target = 'upload_target';
    document.getElementById('upload_target').onload = function() {
      uploadFileTooLarge(container);
    }
  });
  $body.on('keydown', '.globalLoader .part2 .title, .globalLoader .part2 .description', function() {
    $(this).removeClass('form_error');
  });
  $body.on('keydown', '.globalLoader .part2 ._tags_container .tags', function() {
    $(this).parent().removeClass('form_error');
  });
  $body.on('click', '.globalLoader .errors_layer', function() {
    var myself = $(this);
    var container = myself.parents('.globalLoader');
    if(!myself.hasClass('media')) {
      myself.hide();
      container.find(myself.data('focus-selector')).trigger(myself.data('focus-action'));
    }
  });
  $body.on('click', '.globalLoader .attachment label', function() {
    var container = $(this).parents('.globalLoader');
    container.find('.errors_layer.media').hide();
  });
  $body.on('click', '.globalLoader .full_folder .back_to_gallery', function() {
    var container = $(this).parents('.globalLoader');
    container.find('.part1 .attachment .media').val(container.data('placeholder-media'));
    container.find('.form_error').removeClass('form_error');
    container.find('.errors_layer').hide();
    container.find('.part1 .attachment .file').val('');
    container.find('form').show();
    container.find('.full_folder').hide();
  });
}





/**
Disables the loading form while uploading is working.
@method disableUploadForm
@for UploaderGlobal
@param container {Object} JQuery object representing the container
@param window_caption {String} message that is shown to the user if he tries to reload the window while the uploader is working
**/
function disableUploadForm(container, window_caption) {
  container.find('.part3 .submit').addClass('disabled');
  container.find('.part3 .close').addClass('disabled');
  container.find('.part1 .attachment .file').on('click', function(e) {
    e.preventDefault();
  });
  $window.on('beforeunload', function() {
    return window_caption;
  });
}

/**
Enables the loading form when uploading ended.
@method enableUploadForm
@for UploaderGlobal
@param container {Object} JQuery object representing the container
**/
function enableUploadForm(container) {
  $window.unbind('beforeunload');
  container.find('.part3 .close').removeClass('disabled');
  container.find('.part3 .submit').removeClass('disabled');
  container.find('.part1 .attachment .file').unbind('click');
}

/**
Handles correct uploading process (correct in the sense that the file is not too large and could correctly be received by the web server).
@method uploadDone
@for UploaderGlobal
@param selector {String} HTML selector representing the container
@param errors {Array} an array of strings to be shown on the bottom of the loading popup
@param callback {Function} success callback
**/
function uploadDone(selector, errors, callback) {
  var container = $(selector);
  enableUploadForm(container);
  if(errors != undefined) {
    showFormErrors(container, errors);
  } else {
    $(selector).data('loader-can-move', false);
    setTimeout(function() {
      var position_now = container.data('loader-position-stop');
      var coefficient = (100 - position_now) / 500;
      linearRecursionUploadingBar(container, 0, coefficient, position_now, function() {
        container.data('loader-position-stop', 0);
        callback();
      });
    }, 100);
  }
}

/**
Handles 413 status error, file too large.
@method uploadFileTooLarge
@for UploaderGlobal
@param container {Object} JQuery object for the specific uploader (audio, video, image or document)
**/
function uploadFileTooLarge(container) {
  var ret = document.getElementById('upload_target').contentWindow.document.title;
  if(ret && ret.match(/413/g)) {
    $window.unbind('beforeunload');
    unbindLoader();
    $.ajax({
      type: 'get',
      url: container.data('fake-url'),
      data: container.find('form').serialize()
    }).always(bindLoader);
  }
}





/**
Handles the recursion of uploading animation, in a linear way, until a fixed time which is defined as 500 seconds. It is called by {{#crossLink "UploaderLoadingBar/recursionUploadingBar:method"}}{{/crossLink}}.
@method linearRecursionUploadingBar
@for UploaderLoadingBar
@param container {Object} JQuery object for the specific uploader (audio, video, image or document)
@param time {Number} current time in the recursion
@param k {Number} linear coefficient of recursion
@param start {Number} starting point of recursion
@param callback {Function} function to be fired after the animation is over
**/
function linearRecursionUploadingBar(container, time, k, start, callback) {
  if(time <= 500) {
    showPercentUploadingBar(container, (k * time + start));
    setTimeout(function() {
      linearRecursionUploadingBar(container, time + 5, k, start, callback);
    }, 5);
  } else {
    setTimeout(callback, 500);
  }
}

/**
Handles the recursion of uploading animation.
@method recursionUploadingBar
@for UploaderLoadingBar
@param container {Object} JQuery object for the specific uploader (audio, video, image or document)
@param time {Number} current time in the recursion
**/
function recursionUploadingBar(container, time) {
  if(container.data('loader-can-move')) {
    if(time < 1500) {
      showPercentUploadingBar(container, 5 / 150 * time);
    } else {
      showPercentUploadingBar(container, ((100 * time + 1500) / (time + 1530)));
    }
    setTimeout(function() {
      recursionUploadingBar(container, time + 5);
    }, 5);
  } else {
    container.data('loader-can-move', true);
    if(!container.data('loader-with-errors')) {
      container.data('loader-position-stop', (100 * time + 1500) / (time + 1530));
    } else {
      container.data('loader-with-errors', false);
      showPercentUploadingBar(container, 0);
    }
  }
}

/**
Shows a percentage of the circular loading bar.
@method showPercentUploadingBar
@for UploaderLoadingBar
@param container {Object} JQuery object for the specific uploader (audio, video, image or document)
@param percent {Float} percentage of loading shown
**/
function showPercentUploadingBar(container, percent) {
  container.find('.loading-square').hide();
  var width = container.data('bar-width');
  var height = container.data('bar-height');
  var padding = container.data('bar-padding');
  var pixels = percent * (width * 2 + height * 2 + 4) / 100;
  if(pixels > (width / 2)) {
    container.find('.loading-square-1').css('width', ((width / 2) + 'px')).css('left', ('-' + padding + 'px')).show();
    pixels -= (width / 2);
    if(pixels > height) {
      container.find('.loading-square-2').css('height', (height + 'px')).css('top', ('-' + padding + 'px')).show();
      pixels -= height;
      if(pixels > width) {
        container.find('.loading-square-3').css('width', (width + 'px')).show();
        pixels -= width;
        if(pixels > height) {
          container.find('.loading-square-4').css('height', (height + 'px')).show();
          pixels -= height;
          container.find('.loading-square-5').css('width', (pixels + 'px')).css('left', ((width - padding - pixels) + 'px')).show();
        } else {
          container.find('.loading-square-4').css('height', (pixels + 'px')).show();
        }
      } else {
        container.find('.loading-square-3').css('width', (pixels + 'px')).show();
      }
    } else {
      container.find('.loading-square-2').css('height', (pixels + 'px')).css('top', ((height - padding - pixels) + 'px')).show();
    }
  } else {
    container.find('.loading-square-1').css('width', (pixels + 'px')).css('left', (((width / 2) - padding - pixels) + 'px')).show();
  }
}
