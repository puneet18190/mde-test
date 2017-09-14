// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require underscore
//= require url_parser
//= require jquery
//= require jquery_browser
//= require jquery_patches
//= require jquery_ujs
//= require jquery.mousewheel
//= require jquery.jscrollpane
//= require jquery.fullscreen
//= require jquery.event.move
//= require jquery.event.swipe
//= require jquery.selectbox-0.2.custom
//= require jquery-ui-1.9.0.custom
//= require jquery.imgareaselect
//= require jquery.peity
//= require jquery-fileupload/basic
//= require tinymce-jquery
//= require dots_pagination
//= require jquery.formparams
//= require ajax_loader
//= require audio_editor
//= require buttons
//= require dashboard
//= require dialogs
//= require galleries
//= require general
//= require image_editor
//= require lesson_editor
//= require lesson_viewer
//= require media_element_editor
//= require notifications
//= require players
//= require profile
//= require search
//= require tags
//= require uploader
//= require video_editor
//= require virtual_classroom


$(document).ready(function() {
  initializeGlobalVariables();
  browsersDocumentReady();
  globalDocumentReady();
  if($('#audio_editor').length > 0) { // (1) in audio editor
    initTagsAutocomplete($('#new-media-element .part2 ._tags_container .tags'), 'media_element');
    initTagsAutocomplete($('#edit-media-element .part2 ._tags_container .tags'), 'media_element');
    audioEditorDocumentReady();
    galleriesDocumentReady();
    mediaElementEditorDocumentReady();
    playersDocumentReadyAudioEditor();
    playersDocumentReadyGeneral();
    tagsDocumentReady();
  }
  if($('#dashboard_container').length > 0) { // (2) in dashboard
    commonLessonsDocumentReady();
    commonMediaElementsDocumentReady();
    dashboardDocumentReady();
    initTagsAutocomplete($('#load-media-element .part2 ._tags_container .tags'), 'media_element');
    lessonButtonsDocumentReady();
    mediaElementButtonsDocumentReady();
    notificationsDocumentReady();
    playersDocumentReadyGeneral();
    reportsDocumentReady();
    searchDocumentReadyPlaceholders();
    sectionNotificationsDocumentReady();
    tagsDocumentReady();
    uploaderDocumentReady();
  }
  if($('#my_documents').length > 0) { // (3) in section documents
    sectionDocumentsDocumentReady();
    notificationsDocumentReady();
    sectionNotificationsDocumentReady();
    uploaderDocumentReady();
  }
  if($('#image_editor').length > 0 || $('#image_gallery_for_image_editor').length > 0) { // (4) in image editor
    initTagsAutocomplete($('#new-media-element .part2 ._tags_container .tags'), 'media_element');
    initTagsAutocomplete($('#edit-media-element .part2 ._tags_container .tags'), 'media_element');
    galleriesDocumentReady();
    imageEditorDocumentReady();
    mediaElementEditorDocumentReady();
    tagsDocumentReady();
  }
  if($('.lesson-editor-container').length > 0) { // (5) in lesson editor
    if($('#new-lesson').length > 0) {
      initTagsAutocomplete($('#new-lesson .part2 ._tags_container .tags'), 'lesson');
    }
    if($('#edit-lesson').length > 0) {
      initTagsAutocomplete($('#edit-lesson .part2 ._tags_container .tags'), 'lesson');
    }
    galleriesDocumentReady();
    lessonEditorDocumentReady();
    playersDocumentReadyGeneral();
    tagsDocumentReady();
  }
  if($('#my_lessons').length > 0) { // (6) in section lessons
    commonLessonsDocumentReady();
    lessonButtonsDocumentReady();
    notificationsDocumentReady();
    notificationsDocumentReadyLessonModification();
    reportsDocumentReady();
    searchDocumentReadyPlaceholders();
    sectionLessonsDocumentReady();
    sectionNotificationsDocumentReady();
  }
  if($('.lesson-viewer-layout').length > 0) { // (7) in lesson viewer
    initializeLessonViewer('lesson-viewer');
    lessonViewerDocumentReadyPlaylist();
    lessonViewerDocumentReadySlidesNavigation();
    lessonViewerDocumentReadySocialNetworks();
    lessonViewerDocumentReadyDocuments();
    lessonViewerDocumentReadySeparated();
    playersDocumentReadyGeneral();
  }
  if($('#my_media_elements').length > 0) { // (8) in section elements
    commonMediaElementsDocumentReady();
    initTagsAutocomplete($('#load-media-element .part2 ._tags_container .tags'), 'media_element');
    mediaElementButtonsDocumentReady();
    notificationsDocumentReady();
    playersDocumentReadyGeneral();
    reportsDocumentReady();
    searchDocumentReadyPlaceholders();
    sectionMediaElementsDocumentReady();
    sectionNotificationsDocumentReady();
    tagsDocumentReady();
    uploaderDocumentReady();
  }
  if($html.hasClass('prelogin-layout')) { // (9) in prelogin
    locationsDocumentReady();
    preloginDocumentReady();
    purchaseCodeRegistrationDocumentReady();
  }
  if($('#profile_title_bar').length > 0) { // (10) in section profile
    locationsDocumentReady();
    notificationsDocumentReady();
    profileDocumentReady();
    sectionNotificationsDocumentReady();
  }
  if($('#search_lessons_main_page').length > 0 && $('#search_media_elements_main_page').length > 0) { // (11) in search engine
    commonLessonsDocumentReady();
    commonMediaElementsDocumentReady();
    lessonButtonsDocumentReady();
    mediaElementButtonsDocumentReady();
    notificationsDocumentReady();
    notificationsDocumentReadyLessonModification();
    playersDocumentReadyGeneral();
    reportsDocumentReady();
    searchDocumentReady();
    searchDocumentReadyPlaceholders();
    sectionNotificationsDocumentReady();
    sectionSearchDocumentReady();
    tagsDocumentReady();
  }
  if($('#video_editor').length > 0) { // (12) in video editor
    initTagsAutocomplete($('#new-media-element .part2 ._tags_container .tags'), 'media_element');
    initTagsAutocomplete($('#edit-media-element .part2 ._tags_container .tags'), 'media_element');
    galleriesDocumentReady();
    mediaElementEditorDocumentReady();
    playersDocumentReadyGeneral();
    playersDocumentReadyVideoEditor();
    tagsDocumentReady();
    videoEditorDocumentReady();
  }
  if($('#my_virtual_classroom').length > 0) { // (13) in virtual classroom
    notificationsDocumentReady();
    sectionNotificationsDocumentReady();
    virtualClassroomDocumentReady();
  }
});
