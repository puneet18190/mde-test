/**
The Video Editor is structured as follows: centered in the middle of the Editor is located the <b>preview screen</b>, below it the <b>components timeline</b> and the <b>audio track</b>, and on the right the <b>preview column</b> which contains also global statistics about the video.
<br/><br/>
A video created with the Video Editor can be composed by <b>three types of components</b> (and optionally an <b>audio track</b>):
<ul>
  <li>a <b>video component</b> is an element of type video extracted from the user's gallery, associated to an <b>initial</b> and <b>final time</b></li>
  <li>a <b>image component</b> is an element of type image extracted from the user's gallery, associated to a <b>duration</b> in seconds (the image is held in the video for a number of seconds equal to the component's duration); the image is centered and cropped maintaining its original proportions, to make it fit in the video screen (which has proportions 16/9)</li>
  <li>a <b>text component</b> is a centered title for which the user chooses a <b>background color</b>, a <b>font color</b> and a <b>duration</b> (which has the same interpretation as for image components).</li>
</ul>
The resulting video will be the concatenation of all the components inside the timeline, with optionally the chosen audio track as background audio. On the <b>timeline</b> the user may perform the following actions:
<ul>
  <li><b>add</b> a new component (see class {{#crossLink "VideoEditorAddComponents"}}{{/crossLink}}) or <b>replace</b> an existing one, even without maintaining its original type (see class {{#crossLink "VideoEditorReplaceComponents"}}{{/crossLink}}): these functionalities are initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}</li>
  <li><b>remove</b> a component from the timeline (initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyRemoveComponent:method"}}{{/crossLink}})</li>
  <li><b>sort</b> and change the order of the components (initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyInitialization:method"}}{{/crossLink}})</li>
  <li><b>cut</b> a video component (change its initial and final point) or <b>change duration</b> of an image or text compoent (both these functionalities are initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyCutters:method"}}{{/crossLink}} and implemented in the class {{#crossLink "VideoEditorCutters"}}{{/crossLink}}).</li>
</ul>
Each component is provided of its own <b>identifier</b> (similar to the one used in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}), that is unique and doesn't change on any operation performed by the user. Moreover, regardless of its type, a component is strictly linked with two <b>external accessories</b>:
<ul>
  <li>a <b>cutter</b> (whose HTML id is <i>video component [identifier] cutter</i>): this item is normally hidden, when requested it appears below the timeline and is used to cut a video component or change the duration of an image or text component (class {{#crossLink "VideoEditorCutters"}}{{/crossLink}})</li>
  <li>a <b>preview clip</b> (whose HTML id is <i>video component [identifier] preview</i>): this item is hidden inside the <b>preview screen</b>, and it's used
    <ul>
      <li>to provide the user of a big clip of the component while handling it (functionality initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyComponentsCommon:method"}}{{/crossLink}})</li>
      <li>to play a video component while cutting it (initialized in the method {{#crossLink "PlayersDocumentReady/playersDocumentReadyVideoEditor:method"}}{{/crossLink}} in the module {{#crossLinkModule "players"}}{{/crossLinkModule}})</li>
      <li>to be shown in the <b>global preview</b> (see class {{#crossLink "VideoEditorPreview"}}{{/crossLink}}).</li>
    </ul>
  </li>
</ul>
The method that <b>extracts the identifier from a component</b> is {{#crossLink "VideoEditorGeneral/getVideoComponentIdentifier:method"}}{{/crossLink}} (it works receiving as parameter either the component or its cutter or preview clip).
<br/><br/>
While the user is working, the <b>preview clip</b> visible in the preview screen corresponds to the last component <b>selected</b> by the user. A component gets selected either if the user keeps the mouse on it for more than half a second (using the method {{#crossLink "VideoEditorComponents/startVideoEditorPreviewClipWithDelay:method"}}{{/crossLink}}, which avoids compulsive changes inside the preview screen when the user passes with the mouse over the timeline), or immediately on the actions of <b>sorting</b> and <b>cutting</b> (using the method {{#crossLink "VideoEditorCutters/startVideoEditorPreviewClip:method"}}{{/crossLink}}): both behaviors are initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyComponentsCommon:method"}}{{/crossLink}}. To the <b>preview clip</b> of a video component is also associated a method ({{#crossLink "VideoEditorGeneral/loadVideoComponentIfNotLoadedYet:method"}}{{/crossLink}}) that loads the HTML5 video tag only when necessary: this, similarly to {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, avoids overloading of the HTML.
<br/><br/>
The <b>component gallery</b> used inside the Video Editor (initialized in {{#crossLink "GalleriesInitializers/initializeMixedGalleryInVideoEditor:method"}}{{/crossLink}}) is the only gallery in the application which contains mixed types of elements. It's divided into three sections, one for each kind of component: the sections for <b>video</b> and <b>image</b> components have the same external behavior of normal image and video galleries (see the module {{#crossLinkModule "galleries"}}{{/crossLinkModule}}), whereas the section for <b>text</b> components is a peculiar text editor (see the class {{#crossLink "VideoEditorTextComponentEditor"}}{{/crossLink}}). The component gallery (together with the regular audio gallery for the <b>audio track</b>) is initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyGalleries:method"}}{{/crossLink}}, and its functionality defined in the methods of {{#crossLink "VideoEditorGalleries"}}{{/crossLink}} (for instance, the method to switch from a section to another).
<br/><br/>
The method {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}} initializes the general procedure to <b>add or replace a component</b>. The system sets a HTML <i>data</i> that records if the component gallery was opened to <b>replace</b> or <b>add</b> a component: depending on this data, when the user picks a component from the gallery it's called the corresponding method in {{#crossLink "VideoEditorAddComponents"}}{{/crossLink}} or in {{#crossLink "VideoEditorReplaceComponents"}}{{/crossLink}}.
<br/><br/>
When the user adds a component, the system makes a copy of an <b>empty hidden component</b> and fills it with the new data. This behavior is quite similar to the one in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, but in the case of Video Editor the procedure is slightly more complicated, due to the following reasons:
<ul>
  <li>there are <b>three empty items</b> (empty component, empty cutter, empty preview clip) for each type of component, <b>for a total of nine</b></li>
  <li>unlike {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, in the Video Editor each component needs a <b>miniature</b>, that necessarily must be inserted in the empty component <b>together with the rest of the data</b>. For text components, the miniature is built in the moment of the component's creation (there is an <b>empty text miniature</b> hidden in the template of text component editor, see {{#crossLink "VideoEditorTextComponentEditor"}}{{/crossLink}}); for video and image components, the miniatures are loaded together with the <b>mixed gallery</b> and stored <b>in the popup of each element</b> (see module {{#crossLinkModule "galleries"}}{{/crossLinkModule}}, and especially the <i>js.erb</i> templates associated to the routes of the mixed gallery)
  <li>in the Video Editor it's possible to <b>replace</b> a component: when the system does this, it's not enough to fill the inputs of the previous component (with {{#crossLink "VideoEditorComponents/fillVideoEditorSingleParameter:method"}}{{/crossLink}}): it's additionally necessary to <b>reset the inputs</b> of the previous component, thing done by the method {{#crossLink "VideoEditorComponents/clearSpecificVideoEditorComponentParameters:method"}}{{/crossLink}}. Moreover, when replacing a component, the duration is updated using {{#crossLink "VideoEditorComponents/changeDurationVideoEditorComponent:method"}}{{/crossLink}}.</li>
</ul>
Besides the durations, two graphical details are peculiar to each component: the <b>position</b>, handled by {{#crossLink "VideoEditorComponents/reloadVideoEditorComponentPositions:method"}}{{/crossLink}}; and the <b>transition</b>, a small icon representing the <b>fade transition</b> of one second between a component and the following, that must be visible <i>after all components except for the last one</i> (see {{#crossLink "VideoEditorComponents/resetVisibilityOfVideoEditorTransitions:method"}}{{/crossLink}}). The operations in which callback it's necessary to reset transitions and positions are <b>sorting</b> ({{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyInitialization:method"}}{{/crossLink}}) and <b>removing</b> ({{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyRemoveComponent:method"}}{{/crossLink}}).
<br/><br/>
A video component cutter (or simply <b>cutter</b>) is an instrument used to change the initial and final second of a component of type video: it's very similar to the audio cutter, and its functionalities (JQueryUi sliders, players, etc) are defined in {{#crossLink "PlayersVideoEditor/initializeVideoInVideoEditorPreview:method"}}{{/crossLink}} and {{#crossLink "PlayersDocumentReady/playersDocumentReadyVideoEditor:method"}}{{/crossLink}}. A property that is worth mentioning is the <b>automatic return to the previous integer second</b> when pausing: this is a functionality of both cutters and global reproduction (see {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyPreview:method"}}{{/crossLink}} and {{#crossLink "VideoEditorPreview"}}{{/crossLink}}), necessary to set with precision the current time of the <b>preview screen</b>, in order to simulate faithfully the effect of transitions and the correspondance with the optional audio track.
<br/><br/>
For image and text components, a cutter is simply a small form where the user may insert a new duration (the associated callback is {{#crossLink "VideoEditorComponents/changeDurationVideoEditorComponent:method"}}{{/crossLink}}. Since it doesn't fit the whole timeline, this paraticular cutter must be aligned to the JScrollPain: this is done with the functions of the class {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}}.
<br/><br/>
All the cutters are initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyCutters:method"}}{{/crossLink}}, and their functionalities included in the class {{#crossLink "AudioEditorCutters"}}{{/crossLink}}.
<br/><br/>
The <b>text component editor</b> can be opened clicking on the icon 'T' in the header of the component editor (see method {{#crossLink "VideoEditorGalleries/switchToOtherGalleryInMixedGalleryInVideoEditor:method"}}{{/crossLink}}). The user can insert a text and choose background and text color: the functionality is initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyTextComponentEditor:method"}}{{/crossLink}}, and the main methods are contained in the class {{#crossLink "VideoEditorTextComponentEditor"}}{{/crossLink}}. Notice that, unlike image and video components, the <b>miniature</b> of a text component is created in the moment of the insertion of the compoent (see both {{#crossLink "VideoEditorAddComponents/addTextComponentInVideoEditor:method"}}{{/crossLink}} and {{#crossLink "VideoEditorReplaceComponents/replaceTextComponentInVideoEditor:method"}}{{/crossLink}}).
<br/><br/>
The <b>optional audio track</b> is added clicking on the button on the bottom. When the user opens the audio gallery and selects an audio, the system automatically sets <i>muted</i> as <i>true</i> in all the video components ({{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAudioTrack:method"}}{{/crossLink}}); when adding or replacing a video component (see both {{#crossLink "VideoEditorAddComponents/addVideoComponentInVideoEditor:method"}}{{/crossLink}} and {{#crossLink "VideoEditorReplaceComponents/replaceVideoComponentInVideoEditor:method"}}{{/crossLink}}) the attribute <i>muted</i> is inserted if an audio track is present.
<br/><br/>
The audio track is handled while playing a video component inside the video cutter (class {{#crossLink "VideoEditorCutters"}}{{/crossLink}}): the system ensures that the starting of the audio corresponds to the position of the selected video component inside the whole video, using the methods {{#crossLink "PlayersDocumentReady/playersDocumentReadyVideoEditor:method"}}{{/crossLink}} and {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}} of the module {{#crossLinkModule "players"}}{{/crossLinkModule}}.
<br/><br/>
Unlike the {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, in Video Editor the <b>preview mode</b> is not left automatically when the user stops the global preview: The system has different behaviors for each item in the editor while being in preview mode. While the global preview is playing it sets to true the HTML data <b>preview mode in-use</b>.
<br/><br/>
While in preview mode, the <b>preview</b> button in the right column is substituted by a button <b>play / pause</b>; the <i>arrow</i> on the bottom used to commit changes (see {{#crossLink "MediaElementEditorDocumentReady/mediaElementEditorDocumentReady:method"}}{{/crossLink}}) is replaced by <b>a button 'X'</b> that is used to leave the preview mode. Furthermore, in preview mode many graphical details are slightly changed respect to the normal mode (for instance it's not possible to open the cutters, remove components, etc).
<br/><br/>
The general methods relative to the preview mode are contained in {{#crossLink "VideoEditorPreview"}}{{/crossLink}}; the method to enter in preview mode is {{#crossLink "VideoEditorPreview/openPreviewModeInVideoEditor:method"}}{{/crossLink}}; the initializer, which contains also the functionality of <b>leaving</b> the preview mode, is {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyPreview:method"}}{{/crossLink}}.
<br/><br/>
While in preview mode, it's possible to start the global preview (starting <b>from the selected component at the selected second</b>) using the method {{#crossLink "VideoEditorPreview/startVideoEditorGlobalPreview:method"}}{{/crossLink}}: this method is automatically fired with the first component selectedm when the user opens the preview mode for the first time. The method to <b>play a component</b> is {{#crossLink "VideoEditorPreview/playVideoEditorComponent:method"}}{{/crossLink}}; the functionality of passing from a component to another is placed in the last method (if the last component was of type <b>image</b> or <b>text</b>), and in {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}} (it it's of type <b>video</b>, in which case the behavior differs slightly).
<br/><br/>
Unlike in {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}, there are <b>two methods for increasing the global time</b>: the regular one is {{#crossLink "VideoEditorPreview/increaseVideoEditorPreviewTimer:method"}}{{/crossLink}} (used to increase the time according to the <b>currentTime</b> of a video component), and the automatic one is {{#crossLink "VideoEditorPreview/automaticIncreaseVideoEditorPreviewTimer:method"}}{{/crossLink}} (used for automatic increase while playing image and text components).
<br/><br/>
Another important difference with {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}} is the reproduction of the <b>one second transitions</b> between two components: if the user clicks on <i>pause</i> while the global preview is playing a transition, the method that is playing the component (as we have already seen, it can be either {{#crossLink "VideoEditorPreview/playVideoEditorComponent:method"}}{{/crossLink}} or {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}}) waits until the transition is over to stop the reproduction.
<br/><br/>
In the class {{#crossLink "VideoEditorPreviewAccessories"}}{{/crossLink}} are stored the methods to handle the instruments available for the user to get to a specific position inside the timeline during preview mode. Such instruments (initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyPreview:method"}}{{/crossLink}}) are:
<ul>
  <li>the <b>arrows</b> that allow the user to pass from a component to another</li>
  <li>the <b>precision bar</b> that allows the user to select a specific point inside the selected component: notice that this bar is implemented with a <i>JQueryUi slider</i> which is destroyed and re-initialized at each component change (using the methods {{#crossLink "VideoEditorPreviewAccessories/showVideoEditorPreviewComponentProgressBar:method"}}{{/crossLink}} and {{#crossLink "VideoEditorPreviewAccessories/hideVideoEditorPreviewComponentProgressBar:method"}}{{/crossLink}}).</li>
</ul>
Both precision instruments use the general method {{#crossLink "VideoEditorPreviewAccessories/selectVideoComponentInPreview:method"}}{{/crossLink}}, that allows to select a component at a specific time.
<br/><br/>
To include the <b>background audio track</b> in the global preview, the system uses the method {{#crossLink "VideoEditorPreviewAccessories/calculateVideoComponentStartSecondInVideoEditor:method"}}{{/crossLink}}, which calculates <b>the total amount of seconds</b> until the selected point, including the time necessary for the transitions.
<br/><br/>
Finally, let's have a look at the functionalities of the JScrollPain: the method {{#crossLink "VideoEditorScrollPain/followPreviewComponentsWithHorizontalScrollInVideoEditor:method"}}{{/crossLink}} is called at any time the selected component changes inside the preview mode (that is, either while reproducing the global preview, or if the user changes component using the arrows); this method re-implements many functionalities that were badly implemented or absent in the original plugin, such as for instance the uniform speed to scroll different amounts of components. The method uses the class {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}}
<br/><br/>
As for the other Element Editors ({{#crossLinkModule "image-editor"}}{{/crossLinkModule}}, {{#crossLinkModule "audio-editor"}}{{/crossLinkModule}}) the core of the process of committing changes is handled in the module {{#crossLinkModule "media-element-editor"}}{{/crossLinkModule}} (more specificly in the class {{#crossLink "MediaElementEditorForms"}}{{/crossLink}}); the part of this functionality specific for the Video Editor is handled in {{#crossLink "MediaElementEditorDocumentReady/mediaElementEditorDocumentReady:method"}}{{/crossLink}}.
@module video-editor
**/





/**
Adds an image component to the timeline, contructing an empty <b>preview</b>, <b>cutter</b> and <b>component</b>, and then filling them (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method addImageComponentInVideoEditor
@for VideoEditorAddComponents
@param image_id {Number} the id of the image in the database
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the image
@param preview {String} HTML code corresponding to the already built <b>content of the preview</b> for the image
@param duration {Number} the duration in seconds of the image component
**/
function addImageComponentInVideoEditor(image_id, component, preview, duration) {
  $('._new_component_in_video_editor_hover a').removeClass('current');
  var next_position = $('#info_container').data('last-component-id') + 1;
  var new_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', '')) + 186;
  $('#media_elements_list_in_video_editor').data('jsp').destroy();
  $('#video_editor_timeline').css('width', new_timeline_width + 'px');
  $('#media_elements_list_in_video_editor').jScrollPane({
    autoReinitialise: true
  });
  $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'hidden');
  $('#info_container').data('last-component-id', next_position);
  // build preview
  var empty_preview = $('#empty_image_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_editor_preview_container').append(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_image_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_editor_cutters').append(empty_cutter);
  // build component
  var empty_component = $('#empty_image_component_for_video_editor').html();
  empty_component = '<div id="temporary_empty_component" ' + empty_component.substr(empty_component.indexOf('div') + 3, empty_component.length);
  $('#add_new_video_component').before(empty_component);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  current_preview.attr('id', ('video_component_' + next_position + '_preview'));
  current_preview.html(preview);
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + next_position + '_cutter'));
  current_cutter.find('._old').html(secondsToDateString(duration));
  // edit component
  current_component = $('#temporary_empty_component');
  current_component.attr('id', ('video_component_' + next_position));
  current_component.removeClass('_video_editor_empty_component').addClass('_video_editor_component');
  current_component.data('duration', 0);
  current_component.data('position', next_position);
  current_component.find('._video_component_icon ._left').html(next_position);
  current_component.find('._video_editor_component_hover').append(component);
  var to_be_appended = fillVideoEditorSingleParameter('type', next_position, 'image');
  to_be_appended += fillVideoEditorSingleParameter('image_id', next_position, image_id);
  to_be_appended += fillVideoEditorSingleParameter('duration', next_position, duration);
  to_be_appended += fillVideoEditorSingleParameter('position', next_position, next_position);
  current_component.find('._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(('video_component_' + next_position), duration);
  reloadVideoEditorComponentPositions();
  resetVisibilityOfVideoEditorTransitions();
  if(!$('#video_editor_global_preview').hasClass('_enabled')) {
    $('#video_editor_global_preview').addClass('_enabled');
    $('#video_editor_global_preview a').removeClass('disabled');
    $('._commit_media_element_editor').css('visibility', 'visible');
  }
  setTimeout(function() {
    highlightAndUpdateVideoComponentIcon(('video_component_' + next_position));
    $('#media_elements_list_in_video_editor').data('jsp').scrollToPercentX(100, true);
  }, 1100);
}

/**
Adds a text component to the timeline, contructing an empty <b>preview</b>, <b>cutter</b> and <b>component</b>, and then filling them (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method addTextComponentInVideoEditor
@for VideoEditorAddComponents
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the text
@param content {String} the text content
@param duration {Number} the duration in seconds of the image component
@param background_color {String} the class corresponding to the color chosen for the background
@param text_color {String} the class corresponding to the color chosen for the text font
**/
function addTextComponentInVideoEditor(component, content, duration, background_color, text_color) {
  $('._new_component_in_video_editor_hover a').removeClass('current');
  var next_position = $('#info_container').data('last-component-id') + 1;
  var new_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', '')) + 186;
  $('#media_elements_list_in_video_editor').data('jsp').destroy();
  $('#video_editor_timeline').css('width', new_timeline_width + 'px');
  $('#media_elements_list_in_video_editor').jScrollPane({
    autoReinitialise: true
  });
  $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'hidden');
  $('#info_container').data('last-component-id', next_position);
  // build preview
  var empty_preview = $('#empty_text_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_editor_preview_container').append(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_text_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_editor_cutters').append(empty_cutter);
  // build component
  var empty_component = $('#empty_text_component_for_video_editor').html();
  empty_component = '<div id="temporary_empty_component" ' + empty_component.substr(empty_component.indexOf('div') + 3, empty_component.length);
  $('#add_new_video_component').before(empty_component);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  current_preview.attr('id', ('video_component_' + next_position + '_preview'));
  current_preview.removeClass('background_color_white').addClass('background_color_' + background_color);
  current_preview.find('p').removeClass('color_black').addClass('color_' + text_color);
  current_preview.find('p').html(content);
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + next_position + '_cutter'));
  current_cutter.find('._old').html(secondsToDateString(duration));
  // edit component
  current_component = $('#temporary_empty_component');
  current_component.attr('id', ('video_component_' + next_position));
  current_component.removeClass('_video_editor_empty_component').addClass('_video_editor_component');
  current_component.data('duration', 0);
  current_component.data('position', next_position);
  current_component.find('._video_component_icon ._left').html(next_position);
  current_component.find('._video_editor_component_hover').append(component);
  $('#video_component_' + next_position + ' ._video_component_thumb ._text_content').html(content);
  $('#video_component_' + next_position + ' ._video_component_thumb ._text_content').removeClass('color_black').addClass('color_' + text_color);
  $('#video_component_' + next_position + ' ._video_component_thumb').removeClass('background_color_white').addClass('background_color_' + background_color);
  var to_be_appended = fillVideoEditorSingleParameter('type', next_position, 'text');
  to_be_appended += fillVideoEditorSingleParameter('content', next_position, content);
  to_be_appended += fillVideoEditorSingleParameter('duration', next_position, duration);
  to_be_appended += fillVideoEditorSingleParameter('background_color', next_position, background_color);
  to_be_appended += fillVideoEditorSingleParameter('text_color', next_position, text_color);
  to_be_appended += fillVideoEditorSingleParameter('position', next_position, next_position);
  current_component.find('._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(('video_component_' + next_position), duration);
  reloadVideoEditorComponentPositions();
  resetVisibilityOfVideoEditorTransitions();
  if(!$('#video_editor_global_preview').hasClass('_enabled')) {
    $('#video_editor_global_preview').addClass('_enabled');
    $('#video_editor_global_preview a').removeClass('disabled');
    $('._commit_media_element_editor').css('visibility', 'visible');
  }
  setTimeout(function() {
    highlightAndUpdateVideoComponentIcon(('video_component_' + next_position));
    $('#media_elements_list_in_video_editor').data('jsp').scrollToPercentX(100, true);
  }, 1100);
}

/**
Adds a video component to the timeline, contructing an empty <b>preview</b>, <b>cutter</b> and <b>component</b>, and then filling them (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method addVideoComponentInVideoEditor
@for VideoEditorAddComponents
@param video_id {Number} the id of the video in the database
@param webm {String} path of the webm attached of the video
@param mp4 {String} path of the mp4 attached of the video
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the video
@param duration {Number} the duration in seconds of the video component (initially the values <b>from</b> and <b>to</b> are respectively <b>0</b> and <b>duration</b>)
**/
function addVideoComponentInVideoEditor(video_id, webm, mp4, component, duration) {
  $('._new_component_in_video_editor_hover a').removeClass('current');
  var next_position = $('#info_container').data('last-component-id') + 1;
  var new_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', '')) + 186;
  $('#media_elements_list_in_video_editor').data('jsp').destroy();
  $('#video_editor_timeline').css('width', new_timeline_width + 'px');
  $('#media_elements_list_in_video_editor').jScrollPane({
    autoReinitialise: true
  });
  $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'hidden');
  $('#info_container').data('last-component-id', next_position);
  // build preview
  var empty_preview = $('#empty_video_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_editor_preview_container').append(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_video_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_editor_cutters').append(empty_cutter);
  // build component
  var empty_component = $('#empty_video_component_for_video_editor').html();
  empty_component = '<div id="temporary_empty_component" ' + empty_component.substr(empty_component.indexOf('div') + 3, empty_component.length);
  $('#add_new_video_component').before(empty_component);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  if(videoEditorWithAudioTrack()) {
    current_preview.find('video').prop('muted', true);
  }
  current_preview.attr('id', ('video_component_' + next_position + '_preview'));
  current_preview.find('source[type="video/webm"]').attr('src', webm);
  current_preview.find('source[type="video/mp4"]').attr('src', mp4);
  current_preview.find('video').load();
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + next_position + '_cutter'));
  current_cutter.find('._video_editor_cutter_total_time').html(secondsToDateString(duration));
  current_cutter.find('._video_editor_cutter_selected_time').html(secondsToDateString(duration));
  current_cutter.data('to', duration);
  current_cutter.data('max-to', duration);
  initializeVideoInVideoEditorPreview(next_position);
  // edit component
  current_component = $('#temporary_empty_component');
  current_component.attr('id', ('video_component_' + next_position));
  current_component.removeClass('_video_editor_empty_component').addClass('_video_editor_component');
  current_component.data('duration', 0);
  current_component.data('position', next_position);
  current_component.find('._video_component_icon ._left').html(next_position);
  current_component.find('._video_editor_component_hover').append(component);
  var to_be_appended = fillVideoEditorSingleParameter('type', next_position, 'video');
  to_be_appended += fillVideoEditorSingleParameter('video_id', next_position, video_id);
  to_be_appended += fillVideoEditorSingleParameter('from', next_position, 0);
  to_be_appended += fillVideoEditorSingleParameter('to', next_position, duration);
  to_be_appended += fillVideoEditorSingleParameter('position', next_position, next_position);
  current_component.find('._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(('video_component_' + next_position), duration);
  reloadVideoEditorComponentPositions();
  resetVisibilityOfVideoEditorTransitions();
  if(!$('#video_editor_global_preview').hasClass('_enabled')) {
    $('#video_editor_global_preview').addClass('_enabled');
    $('#video_editor_global_preview a').removeClass('disabled');
    $('._commit_media_element_editor').css('visibility', 'visible');
  }
  setTimeout(function() {
    highlightAndUpdateVideoComponentIcon(('video_component_' + next_position));
    $('#media_elements_list_in_video_editor').data('jsp').scrollToPercentX(100, true);
  }, 1100);
}





/**
Changes the duration of a given component, and updates all the global durations and data.
@method changeDurationVideoEditorComponent
@for VideoEditorComponents
@param component_id {String} the HTML id of the component
@param new_duration {Number} the new duration (the old one is stored as data inside the HTML of the component)
**/
function changeDurationVideoEditorComponent(component_id, new_duration) {
  var old_duration = $('#' + component_id).data('duration');
  var total_length = $('#info_container').data('total-length');
  total_length -= old_duration;
  total_length += new_duration;
  if($('._video_editor_component').length > 1) {
    if(old_duration == 0) {
      total_length += 1;
    }
    if(new_duration == 0) {
      total_length -= 1;
    }
  }
  $('#' + component_id).data('duration', new_duration);
  $('#' + component_id + ' ._video_component_icon ._right').html(secondsToDateString(new_duration));
  $('#info_container').data('total-length', total_length);
  $('#visual_video_editor_total_length').html(secondsToDateString(total_length));
}

/**
Clears all the inputs of a component which refer to specific types (this is used in {{#crossLink "VideoEditorReplaceComponents"}}{{/crossLink}}, when the user replaces a component with another of a different type).
@method clearSpecificVideoEditorComponentParameters
@for VideoEditorComponents
@param component_id {String} the HTML id of the component
**/
function clearSpecificVideoEditorComponentParameters(component_id) {
  var huge_selector = '#' + component_id + ' ._video_component_input_content';
  huge_selector += ', #' + component_id + ' ._video_component_input_background_color';
  huge_selector += ', #' + component_id + ' ._video_component_input_text_color';
  huge_selector += ', #' + component_id + ' ._video_component_input_duration';
  huge_selector += ', #' + component_id + ' ._video_component_input_image_id';
  huge_selector += ', #' + component_id + ' ._video_component_input_video_id';
  huge_selector += ', #' + component_id + ' ._video_component_input_from';
  huge_selector += ', #' + component_id + ' ._video_component_input_to';
  $(huge_selector).remove();
}

/**
Function that creates a single input field to be inserted in the empty audio component during the process of construction of a new one (similar to {{#crossLink "AudioEditorComponents/fillAudioEditorSingleParameter:method"}}{{/crossLink}}).
@method fillVideoEditorSingleParameter
@for VideoEditorComponents
@param input {String} the specific input to be filled (for example, <i>video_id</i>, <i>from</i>, <i>duration</i>, or <i>to</i>)
@param identifier {Number} the identifier of the component
@param value {String} the HTML value to be assigned to the input
@return {String} the resulting input written in HTML
**/
function fillVideoEditorSingleParameter(input, identifier, value) {
  return '<input id="' + input + '_' + identifier + '" class="_video_component_input_' + input + '" type="hidden" value="' + value + '" name="' + input + '_' + identifier + '"/>';
}

/**
Highlights the small header of a component.
@method highlightAndUpdateVideoComponentIcon
@for VideoEditorComponents
@param component_id {string} the HTML id of the component
**/
function highlightAndUpdateVideoComponentIcon(component_id) {
  $('#' + component_id + ' ._video_component_icon').effect('highlight', {color: '#41A62A'}, 1500);
}

/**
Reloads all the positions of components in the timeline; used in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyRemoveComponent:method"}}{{/crossLink}} (removing a component) and in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyInitialization:method"}}{{/crossLink}} (sorting components).
@method reloadVideoEditorComponentPositions
@for VideoEditorComponents
**/
function reloadVideoEditorComponentPositions() {
  var components = $('._video_editor_component');
  components.each(function(index) {
    $(this).data('position', (index + 1));
    $(this).find('._video_component_input_position').val(index + 1);
    $(this).find('._video_component_icon ._left').html(index + 1);
  });
}

/**
Resets the visibility of all the transitions between components (because the last transition is not visible); used in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyRemoveComponent:method"}}{{/crossLink}} (removing a component) and in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyInitialization:method"}}{{/crossLink}} (sorting components).
@method resetVisibilityOfVideoEditorTransitions
@for VideoEditorComponents
**/
function resetVisibilityOfVideoEditorTransitions() {
  var components = $('._video_editor_component');
  components.each(function(index) {
    if(index < (components.length - 1)) {
      $(this).find('._video_component_transition').removeClass('current');
    } else {
      $(this).find('._video_component_transition').addClass('current');
    }
  });
}

/**
Selects the component with a delay, after passing with the mouse. Used in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyComponentsCommon:method"}}{{/crossLink}}.
@method startVideoEditorPreviewClipWithDelay
@for VideoEditorComponents
@param component_id {string} the HTML id of the component
**/
function startVideoEditorPreviewClipWithDelay(component_id) {
  setTimeout(function() {
    var obj = $('#' + component_id);
    if(obj.data('preview-selected') && !$('#' + component_id + '_preview').is(':visible')) {
      startVideoEditorPreviewClip(component_id);
    }
  }, 500);
}





/**
Closes the cutter that is visible at the moment, regardless of its type.
@method closeGenericVideoComponentCutter
@for VideoEditorCutters
**/
function closeGenericVideoComponentCutter() {
  $('._video_component_cutter_arrow').hide('fade', {}, 250);
  $('._video_component_cutter').hide('fade', {}, 250, function() {
    $('._commit_media_element_editor').show();
    $('#video_editor_global_preview a').removeClass('disabled');
    $('._video_editor_bottom_bar').css('visibility', 'visible');
    resetVisibilityOfVideoEditorTransitions();
    $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'visible');
    $('._video_editor_bottom_bar').show();
    $('#video_editor_box_ghost').hide();
    $('._video_editor_component_hover').removeClass('selected');
    $('._new_component_in_video_editor_hover').removeClass('selected');
    $('._video_component_icon').removeClass('selected');
  });
}

/**
Commits the changes of a generic cutter.
@method commitVideoComponentVideoCutter
@for VideoEditorCutters
@param identifier {Number} the unique identifier of the component
**/
function commitVideoComponentVideoCutter(identifier) {
  var from = $('#video_component_' + identifier + '_cutter').data('from');
  var to = $('#video_component_' + identifier + '_cutter').data('to');
  $('#video_component_' + identifier + ' ._video_component_input_from').val(from);
  $('#video_component_' + identifier + ' ._video_component_input_to').val(to);
  changeDurationVideoEditorComponent('video_component_' + identifier, to - from);
  if($('#video_component_' + identifier + '_cutter').data('changed')) {
    highlightAndUpdateVideoComponentIcon('video_component_' + identifier);
    $('#video_component_' + identifier + '_cutter').data('changed', false);
  }
}

/**
Cuts the left side of a video component.
@method cutVideoComponentLeftSide
@for VideoEditorCutters
@param identifier {Number} the unique identifier of the video component
@param pos {Number} the new value for the input <i>from</i>
**/
function cutVideoComponentLeftSide(identifier, pos) {
  $('#video_component_' + identifier + '_cutter').data('from', pos);
  var new_duration = $('#video_component_' + identifier + '_cutter').data('to') - pos;
  $('#video_component_' + identifier + '_cutter ._video_editor_cutter_selected_time').html(secondsToDateString(new_duration));
}

/**
Cuts the right side of a video component.
@method cutVideoComponentRightSide
@for VideoEditorCutters
@param identifier {Number} the unique identifier of the video component
@param pos {Number} the new value for the input <i>to</i>
**/
function cutVideoComponentRightSide(identifier, pos) {
  $('#video_component_' + identifier + '_cutter').data('to', pos);
  var new_duration = pos - $('#video_component_' + identifier + '_cutter').data('from');
  $('#video_component_' + identifier + '_cutter ._video_editor_cutter_selected_time').html(secondsToDateString(new_duration));
}

/**
Scrolls (using {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}}) and shows the cutter for a <b>video</b> component. The similar functionality for <b>image</b> and <b>text</b> components is initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyCutters:method"}}{{/crossLink}}.
@method showVideoEditorCutter
@for VideoEditorCutters
@param component_id {String} the HTML id of the component
**/
function showVideoEditorCutter(component_id) {
  $('._video_editor_bottom_bar').css('visibility', 'hidden');
  $('._commit_media_element_editor').hide();
  $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'hidden');
  $('#' + component_id + ' ._video_component_cutter_arrow').show('fade', {}, 250);
  $('#' + component_id + '_cutter').show('fade', {}, 250, function() {
    $('#video_editor_global_preview a').addClass('disabled');
    $('._video_component_transition').addClass('current');
    $('._video_editor_component:not(#' + component_id + ') ._video_editor_component_hover').addClass('selected');
    $('._video_component_icon').addClass('selected');
    $('#' + component_id + ' ._video_component_icon').removeClass('selected');
    $('._new_component_in_video_editor_hover').addClass('selected');
  });
}

/**
Similar to {{#crossLink "VideoEditorComponents/startVideoEditorPreviewClipWithDelay:method"}}{{/crossLink}}, but without delay (used for sorting and opening cutter).
@method startVideoEditorPreviewClip
@for VideoEditorCutters
@param component_id {String} the HTML id of the component
**/
function startVideoEditorPreviewClip(component_id) {
  $('._video_component_preview').hide();
  loadVideoComponentIfNotLoadedYet(component_id);
  $('#' + component_id + '_preview').show('fade', {}, 250);
}





/**
Global initializer.
@method videoEditorDocumentReady
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReady() {
  videoEditorDocumentReadyPreview();
  videoEditorDocumentReadyCutters();
  videoEditorDocumentReadyRemoveComponent();
  videoEditorDocumentReadyComponentsCommon();
  videoEditorDocumentReadyGalleries();
  videoEditorDocumentReadyTextComponentEditor();
  videoEditorDocumentReadyAddComponent();
  videoEditorDocumentReadyAudioTrack();
  videoEditorDocumentReadyInitialization();
}

/**
Initializer for adding components (this method calls both classes {{#crossLink "VideoEditorAddComponents"}}{{/crossLink}} and {{#crossLink "VideoEditorReplaceComponents"}}{{/crossLink}}).
@method videoEditorDocumentReadyAddComponent
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyAddComponent() {
  $body.on('click', '._add_video_component_to_video_editor', function() {
    var video_id = $(this).data('video-id');
    var popup_id = 'dialog-video-gallery-' + video_id;
    var component = $('#' + popup_id + ' ._temporary').html();
    var webm = $('#' + popup_id + ' source[type="video/webm"]').attr('src');
    var mp4 = $('#' + popup_id + ' source[type="video/mp4"]').attr('src');
    var duration = $(this).data('duration');
    closePopUp(popup_id);
    setTimeout(function() {
      closeGalleryInVideoEditor('mixed');
    }, 700);
    if($('#info_container').data('replacing-component')) {
      var current_component = $('#info_container').data('current-component');
      setTimeout(function() {
        highlightAndUpdateVideoComponentIcon(current_component);
      }, 1400);
      replaceVideoComponentInVideoEditor(video_id, webm, mp4, component, current_component, duration);
    } else {
      addVideoComponentInVideoEditor(video_id, webm, mp4, component, duration);
    }
  });
  $body.on('keydown', '.imageInGalleryPopUp ._duration_selector input', function(e) {
    if(e.which === 13) {
      $(this).parents('._duration_selector').find('._add_image_component_to_video_editor_after_select_duration').click();
    }
  });
  $body.on('click', '._add_image_component_to_video_editor', function() {
    var popup_id = 'dialog-image-gallery-' + $(this).data('image-id');
    $('#' + popup_id + ' ._bottom_of_image_popup_in_gallery').hide();
    $('#' + popup_id + ' ._duration_selector').show();
    $('#' + popup_id + ' ._duration_selector input').val('');
    $('#' + popup_id + ' ._duration_selector input').focus();
  });
  $body.on('click', '._add_image_component_to_video_editor_after_select_duration', function() {
    var image_id = $(this).data('image-id')
    var popup_id = 'dialog-image-gallery-' + image_id;
    var duration = parseInt($('#' + popup_id + ' input').val());
    if(isNaN(duration) || duration < 1) {
      showErrorPopUp($captions.data('invalid-component-duration-in-video-editor'));
    } else {
      var component = $('#' + popup_id + ' ._temporary ._video_component_thumb')[0].outerHTML;
      var preview = $('#' + popup_id + ' ._temporary ._image_preview_in_video_editor_gallery').html();
      closePopUp(popup_id);
      setTimeout(function() {
        closeGalleryInVideoEditor('mixed');
      }, 700);
      if($('#info_container').data('replacing-component')) {
        var current_component = $('#info_container').data('current-component');
        setTimeout(function() {
          highlightAndUpdateVideoComponentIcon(current_component);
        }, 1400);
        replaceImageComponentInVideoEditor(image_id, component, preview, current_component, duration);
      } else {
        addImageComponentInVideoEditor(image_id, component, preview, duration);
      }
    }
  });
  $body.on('click', '#insert_text_component_in_video_editor', function() {
    var preview = $('#text_component_preview');
    var background_color = preview.data('background-color');
    var text_color = preview.data('text-color');
    var duration = parseInt($('#video_editor_mixed_gallery_container ._texts ._duration_selector input').val());
    if(isNaN(duration) || duration < 1) {
      showErrorPopUp($captions.data('invalid-component-duration-in-video-editor'));
    } else if(preview.data('placeholder')) {
      showErrorPopUp($captions.data('empty-text-component-in-video-editor'));
    } else {
      var content = $('#text_component_preview textarea').val().split("\n").join('<br/>');
      var component = $('#video_editor_mixed_gallery_container ._texts ._temporary').html();
      closeGalleryInVideoEditor('mixed');
      if($('#info_container').data('replacing-component')) {
        var current_component = $('#info_container').data('current-component');
        setTimeout(function() {
          highlightAndUpdateVideoComponentIcon(current_component);
        }, 700);
        replaceTextComponentInVideoEditor(component, content, current_component, duration, background_color, text_color);
      } else {
        addTextComponentInVideoEditor(component, content, duration, background_color, text_color);
      }
    }
  });
}

/**
Initializes functionality for audio track.
@method videoEditorDocumentReadyAudioTrack
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyAudioTrack() {
  $body.on('click', '._add_audio_track_to_video_editor', function() {
    $('#video_editor_preview_container ._audio_track_preview').remove();
    if(!$('#video_editor_preview_container video').prop('muted')) {
      $('#video_editor_preview_container video').prop('muted', true);
    }
    var audio_id = $(this).data('audio-id');
    closeGalleryInVideoEditor('audio');
    stopMedia('._audio_expanded_in_gallery audio');
    $('._audio_expanded_in_gallery ._expanded').hide();
    $('._audio_expanded_in_gallery').removeClass('_audio_expanded_in_gallery');
    $('#audio_track_in_video_editor_input').val(audio_id);
    $('#empty_audio_track_placeholder_in_video_editor').hide();
    $('#full_audio_track_placeholder_in_video_editor').show();
    $('#full_audio_track_placeholder_in_video_editor').data('duration', $(this).data('duration'));
    var new_html_title = $('#gallery_audio_' + audio_id + ' ._compact p').html();
    new_html_title += ('<br/>' + secondsToDateString($(this).data('duration')));
    $('#full_audio_track_placeholder_in_video_editor ._title').html(new_html_title);
    $('#video_editor_preview_container').append($('#empty_audio_track_preview_for_video_editor').html());
    var new_audio_track = $('#video_editor_preview_container ._audio_track_preview');
    new_audio_track.data('duration', $(this).data('duration'));
    new_audio_track.find('source[type="audio/mp4"]').attr('src', $(this).data('m4a'));
    new_audio_track.find('source[type="audio/ogg"]').attr('src', $(this).data('ogg'));
    new_audio_track.find('audio').load();
  });
  $body.on('click', '#full_audio_track_placeholder_in_video_editor ._remove', function() {
    $('#video_editor_preview_container video').prop('muted', false);
    var audio_id = $('#audio_track_in_video_editor_input').val();
    $('#video_editor_preview_container ._audio_track_preview').remove();
    $('#audio_track_in_video_editor_input').val('');
    $('#full_audio_track_placeholder_in_video_editor').hide();
    $('#empty_audio_track_placeholder_in_video_editor').show();
  });
}

/**
Initializer for functionalities common to all types of components.
@method videoEditorDocumentReadyComponentsCommon
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyComponentsCommon() {
  $body.on('mouseover', '._video_editor_component_hover', function() {
    var father = $(this).parent();
    if(father.data('rolloverable')) {
      father.data('preview-selected', true);
      startVideoEditorPreviewClipWithDelay(father.attr('id'));
      $('#' + father.attr('id') + ' ._video_editor_component_menu').show();
    }
  });
  $body.on('mouseout', '._video_editor_component_hover', function() {
    var father = $(this).parent();
    father.data('preview-selected', false);
    if(father.data('rolloverable')) {
      $('#' + father.attr('id') + ' ._video_editor_component_menu').hide();
    }
  });
  $body.on('mouseover', '._new_component_in_video_editor_hover', function() {
    $('._new_component_in_video_editor_hover a').addClass('current');
  });
  $body.on('mouseout', '._new_component_in_video_editor_hover', function() {
    $('._new_component_in_video_editor_hover a').removeClass('current');
  });
}

/**
Initializer for cutters.
@method videoEditorDocumentReadyCutters
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyCutters() {
  $body.on('click', '._video_component_cutter_button', function() {
    var component_id = $(this).parents('._video_editor_component').attr('id');
    if(!$('#' + component_id + '_preview').is(':visible')) {
      startVideoEditorPreviewClip(component_id);
    }
    $('#video_editor_box_ghost').show();
    $('#video_editor_global_preview').removeClass('_enabled');
    var pos = $('#' + component_id).data('position');
    var scroll_to = getNormalizedPositionTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186, pos, 5);
    if($('#' + component_id + '_cutter').hasClass('_mini_cutter')) {
      $('#' + component_id + '_cutter').css('left', (3 + getAbsolutePositionTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186, pos, 5)));
    }
    var jsp_handler = $('#media_elements_list_in_video_editor').data('jsp');
    if(scroll_to != jsp_handler.getContentPositionX() && jsp_handler.getPercentScrolledX() != 1) {
      $('#media_elements_list_in_video_editor').jScrollPane().bind('panescrollstop', function() {
        showVideoEditorCutter(component_id);
        $('#media_elements_list_in_video_editor').jScrollPane().unbind('panescrollstop');
      });
      jsp_handler.scrollToX(scroll_to, true);
    } else {
      showVideoEditorCutter(component_id);
    }
  });
  $body.on('click', '._media_player_done_video_component_in_video_editor_preview', function() {
    closeGenericVideoComponentCutter();
    var component_id = $(this).parents('._video_component_cutter').attr('id');
    var identifier = getVideoComponentIdentifier(component_id);
    $('#video_component_' + identifier + '_cutter ._double_slider .ui-slider-handle').removeClass('selected');
    stopVideoInVideoEditorPreview(identifier);
    commitVideoComponentVideoCutter(identifier);
    $('#video_editor_global_preview').addClass('_enabled');
  });
  $body.on('click', '._media_player_done_other_component_in_video_editor_preview', function() {
    var component_id = $(this).parents('._video_component_cutter').attr('id');
    var identifier = getVideoComponentIdentifier(component_id);
    var duration = $('#' + component_id + ' ._duration_selector input').val();
    if(duration == '') {
      closeGenericVideoComponentCutter();
    } else {
      duration = parseInt(duration);
      if(isNaN(duration) || duration < 1) {
        showErrorPopUp($captions.data('invalid-component-duration-in-video-editor'));
      } else {
        closeGenericVideoComponentCutter();
        changeDurationVideoEditorComponent(('video_component_' + identifier), duration);
        $('#' + component_id + ' ._duration_selector input').val('');
        $('#' + component_id + ' ._old').html(secondsToDateString(duration));
        $('#video_component_' + identifier + ' ._video_component_input_duration').val(duration);
        highlightAndUpdateVideoComponentIcon('video_component_' + identifier);
      }
    }
    $('#video_editor_global_preview').addClass('_enabled');
  });
  $body.on('click', '._video_component_cutter ._precision_arrow_left', function() {
    var cutter = $(this).parents('._video_component_cutter');
    var identifier = getVideoComponentIdentifier(cutter.attr('id'));
    var single_slider = cutter.find('._media_player_slider');
    var double_slider = cutter.find('._double_slider');
    if(single_slider.find('.ui-slider-handle').hasClass('selected')) {
      var resp = single_slider.slider('value');
      if(resp > 0 && resp > double_slider.slider('values', 0)) {
        selectVideoComponentCutterHandle(cutter, resp - 1);
      }
    } else if(double_slider.find('.ui-slider-handle').first().hasClass('selected')) {
      var resp = double_slider.slider('values', 0);
      if(resp > 0) {
        double_slider.slider('values', 0, resp - 1);
        cutVideoComponentLeftSide(identifier, resp - 1);
      }
    } else {
      var resp = double_slider.slider('values', 1);
      if(resp > double_slider.slider('values', 0) + 1) {
        if(single_slider.slider('value') == resp) {
          selectVideoComponentCutterHandle(cutter, resp - 1);
        }
        double_slider.slider('values', 1, resp - 1);
        cutVideoComponentRightSide(identifier, resp - 1);
      }
    }
  });
  $body.on('click', '._video_component_cutter ._precision_arrow_right', function() {
    var cutter = $(this).parents('._video_component_cutter');
    var identifier = getVideoComponentIdentifier(cutter.attr('id'));
    var duration = cutter.data('max-to');
    var single_slider = cutter.find('._media_player_slider');
    var double_slider = cutter.find('._double_slider');
    if(single_slider.find('.ui-slider-handle').hasClass('selected')) {
      var resp = single_slider.slider('value');
      if(resp < duration && resp < double_slider.slider('values', 1)) {
        selectVideoComponentCutterHandle(cutter, resp + 1);
      }
    } else if(double_slider.find('.ui-slider-handle').first().hasClass('selected')) {
      var resp = double_slider.slider('values', 0);
      if(resp < double_slider.slider('values', 1) - 1) {
        if(single_slider.slider('value') == resp) {
          selectVideoComponentCutterHandle(cutter, resp + 1);
        }
        double_slider.slider('values', 0, resp + 1);
        cutVideoComponentLeftSide(identifier, resp + 1);
      }
    } else {
      var resp = double_slider.slider('values', 1);
      if(resp < duration) {
        double_slider.slider('values', 1, resp + 1);
        cutVideoComponentRightSide(identifier, resp + 1);
      }
    }
  });
}

/**
Initializer for galleries.
@method videoEditorDocumentReadyGalleries
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyGalleries() {
  $body.on('click', '._close_mixed_gallery_in_video_editor', function() {
    closeGalleryInVideoEditor('mixed');
  });
  $body.on('click', '._close_audio_gallery_in_video_editor', function() {
    closeGalleryInVideoEditor('audio');
    var expanded_audio = $('._audio_expanded_in_gallery');
    if(expanded_audio.length > 0) {
      expanded_audio.removeClass('_audio_expanded_in_gallery');
      var audio_id = expanded_audio.attr('id');
      stopMedia('#' + audio_id + ' audio');
      $('#' + audio_id + ' ._expanded').hide();
    }
  });
  $body.on('click', '._new_component_in_video_editor_button', function() {
    var father = $(this).parent().parent().parent().parent();
    var infos = $('#info_container');
    if($(this).hasClass('_replace_component')) {
      infos.data('replacing-component', true);
      infos.data('current-component', father.attr('id'));
    } else {
      infos.data('replacing-component', false);
    }
    if($('#video_editor_mixed_gallery_container').data('loaded')) {
      showGalleryInVideoEditor('mixed');
      resetVideoEditorTextComponent();
    } else {
      $.ajax({
        type: 'get',
        url: '/videos/galleries'
      });
    }
  });
  $body.on('click', '._show_audio_gallery_in_video_editor', function() {
    if($('#video_editor_audio_gallery_container').data('loaded')) {
      showGalleryInVideoEditor('audio');
    } else {
      $.ajax({
        type: 'get',
        url: '/videos/galleries/audio'
      });
    }
  });
  $body.on('click', '#video_editor_mixed_gallery_container ._switch_video', function() {
    $('._switch_image, ._switch_text').removeClass('current');
    $(this).addClass('current');
    switchToOtherGalleryInMixedGalleryInVideoEditor('._videos');
  });
  $body.on('click', '#video_editor_mixed_gallery_container ._switch_image', function() {
    $('._switch_video, ._switch_text').removeClass('current');
    $(this).addClass('current');
    switchToOtherGalleryInMixedGalleryInVideoEditor('._images');
  });
  $body.on('click', '#video_editor_mixed_gallery_container ._switch_text', function() {
    $('._switch_image, ._switch_video').removeClass('current');
    $(this).addClass('current');
    switchToOtherGalleryInMixedGalleryInVideoEditor('._texts');
  });
  $body.on('click', '._image_gallery_thumb_in_mixed_gallery_video_editor', function(e) {
    e.preventDefault();
    var image_id = $(this).data('image-id');
    showImageInGalleryPopUp(image_id, function() {
      var popup_id = 'dialog-image-gallery-' + image_id;
      $('#' + popup_id + ' ._bottom_of_image_popup_in_gallery').show();
      $('#' + popup_id + ' ._duration_selector').hide();
    });
  });
}

/**
Initializer for sorting and other JQueryUi plugins.
@method videoEditorDocumentReadyInitialization
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyInitialization() {
  $('#media_elements_list_in_video_editor').jScrollPane({
    autoReinitialise: true
  });
  calculateNewPositionGalleriesInVideoEditor();
  $('#video_editor_timeline').sortable({
    scroll: true,
    handle: '._video_editor_component_hover',
    axis: 'x',
    cursor: 'move',
    cancel: '._video_editor_component_menu',
    containment: 'parent',
    start: function(event, ui) {
      my_item = $(ui.item);
      if(!$('#' + my_item.attr('id') + '_preview').is(':visible')) {
        startVideoEditorPreviewClip(my_item.attr('id'));
      }
      my_item.find('._video_editor_component_menu').hide();
      my_item.data('rolloverable', false);
      my_item.find('._video_component_icon').addClass('current');
      my_item.find('._video_component_thumb').addClass('current');
      $('._video_editor_component ._video_component_transition').addClass('current');
    },
    stop: function(event, ui) {
      my_item = $(ui.item);
      my_item.data('rolloverable', true);
      my_item.find('._video_component_icon').removeClass('current');
      my_item.find('._video_component_thumb').removeClass('current');
      resetVisibilityOfVideoEditorTransitions();
      var boolean1 = (my_item.next().attr('id') == 'add_new_video_component');
      var boolean2 = (my_item.data('position') != $('._video_editor_component').length);
      var boolean3 = (my_item.next().data('position') != (my_item.data('position') + 1));
      if(boolean1 && boolean2 || !boolean1 && boolean3) {
        reloadVideoEditorComponentPositions();
        $('._video_component_icon').effect('highlight', {color: '#41A62A'}, 1500);
      }
    }
  });
}

/**
Initializer for preview mode (see {{#crossLink "VideoEditorPreview"}}{{/crossLink}} and {{#crossLink "VideoEditorPreviewAccessories"}}{{/crossLink}}).
@method videoEditorDocumentReadyPreview
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyPreview() {
  $body.on('click', '#video_editor_preview_go_to_left_component', function() {
    if($('#video_editor_global_preview').data('arrows')) {
      var prev_component = $('#video_component_' + $('#video_editor_global_preview').data('current-component')).prev();
      loadVideoComponentIfNotLoadedYet(prev_component.attr('id'));
      selectVideoComponentInPreview(prev_component);
      showVideoEditorPreviewArrowToComponents();
      hideVideoEditorPreviewComponentProgressBar();
      followPreviewComponentsWithHorizontalScrollInVideoEditor();
    }
  });
  $body.on('click', '#video_editor_preview_go_to_right_component', function() {
    if($('#video_editor_global_preview').data('arrows')) {
      var next_component = $('#video_component_' + $('#video_editor_global_preview').data('current-component')).next();
      loadVideoComponentIfNotLoadedYet(next_component.attr('id'));
      selectVideoComponentInPreview(next_component);
      showVideoEditorPreviewArrowToComponents();
      hideVideoEditorPreviewComponentProgressBar();
      followPreviewComponentsWithHorizontalScrollInVideoEditor();
    }
  });
  $body.on('click', '#video_editor_global_preview_play', function() {
    if(!$(this).data('temporarily-disabled')) {
      $(this).hide();
      $('#video_editor_preview_slider_box_ghost').show();
      $('#video_editor_preview_go_to_left_component, #video_editor_preview_go_to_right_component').hide();
      $('#video_editor_global_preview_pause').show();
      $('#visual_video_editor_current_time').css('color', 'white');
      $('#visual_video_editor_total_length').css('color', '#787575');
      $('#exit_video_editor_preview').hide();
      startVideoEditorGlobalPreview();
    }
  });
  $body.on('click', '#exit_video_editor_preview', function() {
    hideVideoEditorPreviewComponentProgressBar();
    $('#info_container').data('forced-kevin-luck-style', '');
    $('#video_editor_global_preview_pause').removeClass('_enabled');
    $('#video_editor_preview_go_to_left_component, #video_editor_preview_go_to_right_component').hide();
    $('._video_component_preview').hide();
    $('._video_editor_component_hover, ._video_component_icon').removeClass('selected');
    setVisualTimesVideoEditorPreview(getFirstVideoEditorComponent(), 0);
    resetVisibilityOfVideoEditorTransitions();
    $('._video_editor_component').each(function() {
      $(this).find('._video_component_icon ._right').html(secondsToDateString($(this).data('duration')));
    });
    $('#full_audio_track_placeholder_in_video_editor, #empty_audio_track_placeholder_in_video_editor').css('visibility', 'visible');
    $('#media_elements_list_in_video_editor').data('jsp').destroy();
    $('#add_new_video_component').show();
    $('#add_new_video_component').prev().find('._video_component_transition').show();
    $('#add_new_video_component').prev().css('width', '186');
    var new_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', '')) + 184;
    $('#video_editor_timeline').css('width', new_timeline_width + 'px');
    $('#media_elements_list_in_video_editor').jScrollPane({
      autoReinitialise: true,
    });
    $('#visual_video_editor_current_time').css('visibility', 'hidden')
    $('#video_editor_global_preview').show();
    $('#video_editor_global_preview_play').hide();
    $('._commit_media_element_editor').show();
    $('#exit_video_editor_preview').hide();
    $('#video_editor_box_ghost').hide();
  });
  $body.on('click', '#video_editor_global_preview_pause._enabled', function() {
    $('#video_editor_global_preview_play').data('temporarily-disabled', true);
    setTimeout(function() {
      $('#video_editor_global_preview_play').data('temporarily-disabled', false);
    }, 1000);
    $('#video_editor_preview_slider_box_ghost').hide();
    $('#video_editor_global_preview').data('in-use', false);
    showVideoEditorPreviewArrowToComponents();
    $(this).hide();
    $('#video_editor_global_preview_play').show();
    $('#exit_video_editor_preview').show();
    $('#visual_video_editor_current_time').css('color', '#787575');
    $('#visual_video_editor_total_length').css('color', 'white');
    var current_identifier = $('#video_editor_global_preview').data('current-component');
    var current_component = $('#video_component_' + current_identifier);
    if($('#video_component_' + current_identifier + '_preview video').length > 0) {
      $('#video_component_' + current_identifier + '_preview video')[0].pause();
      setCurrentTimeToMedia($('#video_component_' + current_identifier + '_preview video'), ($('#video_component_' + current_identifier + '_cutter').data('from') + current_component.data('current-preview-time')));
    }
    if(videoEditorWithAudioTrack()) {
      $('#video_editor_preview_container audio')[0].pause();
    }
  });
  $body.on('click', '#video_editor_global_preview._enabled', function() {
    loadVideoComponentIfNotLoadedYet(getFirstVideoEditorComponent().attr('id'));
    $('#info_container').data('forced-kevin-luck-style', 'visibility:hidden');
    var jsp_handler = $('#media_elements_list_in_video_editor').data('jsp');
    if(jsp_handler.getContentPositionX() > 0) {
      $('#media_elements_list_in_video_editor').jScrollPane().bind('panescrollstop', function() {
        openPreviewModeInVideoEditor();
        $('#media_elements_list_in_video_editor').jScrollPane().unbind('panescrollstop');
      });
      $('#media_elements_list_in_video_editor').data('jsp').scrollToPercentX(0, true);
    } else {
      openPreviewModeInVideoEditor();
    }
  });
}

/**
Initializer for the functionality of <b>removing a component</b> from the timeline (is uses {{#crossLink "VideoEditorComponents/changeDurationVideoEditorComponent:method"}}{{/crossLink}} passing <i>new duration = 0</i>).
@method videoEditorDocumentReadyRemoveComponent
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyRemoveComponent() {
  $body.on('click', '._remove_component_from_video_editor_button', function() {
    var component = $(this).parents('._video_editor_component');
    var identifier = getVideoComponentIdentifier(component.attr('id'));
    $('#video_component_' + identifier).hide('fade', {}, 500, function() {
      $('#video_component_' + identifier + '_preview').remove();
      $('#video_component_' + identifier + '_cutter').remove();
      changeDurationVideoEditorComponent(('video_component_' + identifier), 0);
      $('#media_elements_list_in_video_editor').data('jsp').destroy();
      $(this).remove();
      reloadVideoEditorComponentPositions();
      var old_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', ''));
      $('#video_editor_timeline').css('width', ((old_timeline_width - 186) + 'px'));
      $('#media_elements_list_in_video_editor').jScrollPane({
        autoReinitialise: true
      });
      resetVisibilityOfVideoEditorTransitions();
      if($('._video_editor_component').length == 0) {
        $('#video_editor_global_preview').removeClass('_enabled');
        $('#video_editor_global_preview a').addClass('disabled');
        $('._commit_media_element_editor').css('visibility', 'hidden');
      }
    });
  });
}

/**
Initializes the <b>text component editor</b> (see {{#crossLink "VideoEditorTextComponentEditor"}}{{/crossLink}}).
@method videoEditorDocumentReadyTextComponentEditor
@for VideoEditorDocumentReady
**/
function videoEditorDocumentReadyTextComponentEditor() {
  $body.on('click', '._text_component_in_video_editor_background_color_selector ._color', function() {
    var old_background_color = $('#text_component_preview').data('background-color');
    var new_background_color = $(this).data('color');
    switchTextComponentBackgroundColor(old_background_color, new_background_color);
  });
  $body.on('click', '._text_component_in_video_editor_text_color_selector ._color', function() {
    var old_text_color = $('#text_component_preview').data('text-color');
    var new_text_color = $(this).data('color');
    switchTextComponentTextColor(old_text_color, new_text_color);
  });
  $body.on('focus', '#text_component_preview textarea', function() {
    var preview = $('#text_component_preview');
    if(preview.data('placeholder')) {
      preview.data('placeholder', false);
      $(this).val('');
    }
  });
}





/**
Centers the gallery when shown.
@method calculateNewPositionGalleriesInVideoEditor
@for VideoEditorGalleries
**/
function calculateNewPositionGalleriesInVideoEditor() {
  $('#video_editor_mixed_gallery_container').css('left', (($window.width() - 940) / 2) + 'px');
  $('#video_editor_audio_gallery_container').css('left', (($window.width() - 940) / 2) + 'px');
}

/**
Opposite of {{#crossLink "VideoEditorGalleries/showGalleryInVideoEditor:method"}}{{/crossLink}}.
@method closeGalleryInVideoEditor
@for VideoEditorGalleries
@param type {String} it can be either 'mixed' or 'audio'
**/
function closeGalleryInVideoEditor(type) {
  $('#video_editor_' + type + '_gallery_container').hide('fade', {}, 250, function() {
    $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'visible');
    $('._video_editor_bottom_bar').show();
    calculateNewPositionGalleriesInVideoEditor();
  });
}

/**
Opens a chosen gallery.
@method showGalleryInVideoEditor
@for VideoEditorGalleries
@param type {String} it can be either 'mixed' or 'audio'
**/
function showGalleryInVideoEditor(type) {
  $('#media_elements_list_in_video_editor .jspHorizontalBar').css('visibility', 'hidden');
  $('#video_editor_' + type + '_gallery_container').show();
  $('._video_editor_bottom_bar').hide();
  calculateNewPositionGalleriesInVideoEditor();
  $('._video_editor_component_menu').hide();
}

/**
Switches between <b>video gallery</b>, <b>image gallery</b> and <b>text component editor</b> in the component editor.
@method switchToOtherGalleryInMixedGalleryInVideoEditor
@for VideoEditorGalleries
@param type {String} it can be either 'mixed' or 'audio'
**/
function switchToOtherGalleryInMixedGalleryInVideoEditor(type) {
  if(!$('#video_editor_mixed_gallery_container ' + type).is(':visible')) {
    var big_selector = '#video_editor_mixed_gallery_container ._videos, #video_editor_mixed_gallery_container ._images, #video_editor_mixed_gallery_container ._texts';
    $(big_selector).each(function() {
      if($(this).is(':visible')) {
        big_selector = this;
      }
    });
    $(big_selector).hide();
    if(type == '._texts') {
      resetVideoEditorTextComponent();
    }
    $('#video_editor_mixed_gallery_container ' + type).show();
  }
}





/**
Returns the first component in the timeline.
@method getFirstVideoEditorComponent
@for VideoEditorGeneral
@return {Object} the first component
**/
function getFirstVideoEditorComponent() {
  return $('._video_editor_component').first();
}

/**
Returns the last component in the timeline.
@method getLastVideoEditorComponent
@for VideoEditorGeneral
@return {Object} the last component
**/
function getLastVideoEditorComponent() {
  var components = $('._video_editor_component');
  return $(components[components.length - 1]);
}

/**
Method that extracts the <b>unique identifier</b> of a component, starting indifferently from the component id, the cutter id, or the preview id.
@method getVideoComponentIdentifier
@for VideoEditorGeneral
@param item_id {String} the HTML id of either the <i>component</i>, the <i>preview</i> or the <i>cutter</i>
@return {Number} the unique identifier of the component
**/
function getVideoComponentIdentifier(item_id) {
  var resp = item_id.split('_');
  if($('#' + item_id).hasClass('_video_editor_component')) {
    return resp[resp.length - 1];
  } else {
    return resp[resp.length - 2];
  }
}

/**
Checks if the HTML5 video inside a <b>video component</b> has been loaded, and if not it loads it.
@method loadVideoComponentIfNotLoadedYet
@for VideoEditorGeneral
@param component_id {String} the HTML id of the video component
**/
function loadVideoComponentIfNotLoadedYet(component_id) {
  if(!$('#' + component_id + '_preview').data('loaded')) {
    var mp4 = $('#' + component_id + '_preview').data('mp4');
    var webm = $('#' + component_id + '_preview').data('webm');
    $('#' + component_id + '_preview video source[type="video/mp4"]').attr('src', mp4);
    $('#' + component_id + '_preview video source[type="video/webm"]').attr('src', webm);
    $('#' + component_id + '_preview video').load();
    $('#' + component_id + '_preview').data('loaded', true);
  }
}

/**
Checks if an optional audio track has been set by the user.
@method videoEditorWithAudioTrack
@for VideoEditorGeneral
@return {Boolean} true if there is an audio track
**/
function videoEditorWithAudioTrack() {
  return $('#audio_track_in_video_editor_input').val() != '';
}





/**
Automatic increase for the global preview current time (used when playing image or text components).
@method automaticIncreaseVideoEditorPreviewTimer
@for VideoEditorPreview
@param time {Number} the global time before calling the method
@param total_length {Number} the total length of the component
@param callback {Function} the callback to be executed after the time update
**/
function automaticIncreaseVideoEditorPreviewTimer(time, total_length, callback) {
  setTimeout(function() {
    if($('#video_editor_global_preview').data('in-use')) {
      if(time < total_length) {
        increaseVideoEditorPreviewTimer(true);
        automaticIncreaseVideoEditorPreviewTimer(time + 1, total_length, callback);
      } else {
        callback();
      }
    }
  }, 1000);
}

/**
Increases of one step the global preview time (typically used in {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}}).
@method increaseVideoEditorPreviewTimer
@for VideoEditorPreview
@param with_component {Boolean} if true, it updates also the local time of the selected component
**/
function increaseVideoEditorPreviewTimer(with_component) {
  var data_container = $('#video_editor_global_preview');
  var global_time = data_container.data('current-time');
  $('#visual_video_editor_current_time').html(secondsToDateString(global_time + 1));
  data_container.data('current-time', global_time + 1);
  if(with_component) {
    var identifier = data_container.data('current-component');
    var component = $('#video_component_' + identifier);
    var component_time = component.data('current-preview-time');
    component.find('._video_component_icon ._right').html(secondsToDateString(component_time + 1));
    component.data('current-preview-time', component_time + 1);
    if($('#video_editor_preview_slider').is(':visible')) {
      $('#video_editor_preview_slider').slider('value', component_time + 1);
    }
  }
}

/**
Opens the preview mode with all its graphical effects. The similar functionality to close the preview mode is initialized in {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyPreview:method"}}{{/crossLink}}.
@method openPreviewModeInVideoEditor
@for VideoEditorPreview
**/
function openPreviewModeInVideoEditor() {
  var first_component = getFirstVideoEditorComponent();
  var first_identifier = getVideoComponentIdentifier(first_component.attr('id'));
  $('._video_component_preview').hide();
  $('#full_audio_track_placeholder_in_video_editor, #empty_audio_track_placeholder_in_video_editor').css('visibility', 'hidden');
  $('#visual_video_editor_current_time').css('visibility', 'visible').css('color', 'white');
  $('#visual_video_editor_total_length').css('color', '#787575');
  $('#video_editor_global_preview').hide();
  $('#video_editor_global_preview_pause').show();
  $('._commit_media_element_editor').hide();
  $('#video_editor_box_ghost').show();
  $('._video_editor_component_hover, ._video_component_icon').addClass('selected');
  $('#media_elements_list_in_video_editor').data('jsp').destroy();
  $('#add_new_video_component').hide();
  $('#add_new_video_component').prev().find('._video_component_transition').hide();
  $('#add_new_video_component').prev().css('width', '159');
  var new_timeline_width = parseInt($('#video_editor_timeline').css('width').replace('px', '')) - 184;
  $('#video_editor_timeline').css('width', new_timeline_width + 'px');
  $('#video_editor_preview_slider_box_ghost').show();
  $('#media_elements_list_in_video_editor').jScrollPane({
    autoReinitialise: true,
    initialHorizontalStyles: 'visibility:hidden'
  });
  $('._video_component_transition').addClass('current');
  setVisualTimesVideoEditorPreview(first_component, 0);
  $('#video_editor_preview_container ._loader').show();
  $('#video_editor_global_preview_pause a').addClass('disabled');
  setTimeout(function() {
    $('#video_editor_global_preview_pause').addClass('_enabled');
    $('#video_editor_global_preview_pause a').removeClass('disabled');
    $('#video_editor_preview_container ._loader').hide();
    $('#video_component_' + first_identifier + '_preview').show();
    showVideoEditorPreviewComponentProgressBar(first_identifier, 1);
    first_component.find('._video_editor_component_hover, ._video_component_icon').removeClass('selected');
    startVideoEditorGlobalPreview();
  }, 1500);
}

/**
Plays a component and handles the transition to the next one (if there is any). In case the component is of type <b>image</b> or <b>text</b>, the time increase is handled by {{#crossLink "VideoEditorPreview/automaticIncreaseVideoEditorPreviewTimer:method"}}{{/crossLink}}; if the component is of type <b>video</b> the transition is handled by {{#crossLink "PlayersVideoEditor/initializeActionOfMediaTimeUpdaterInVideoEditor:method"}}{{/crossLink}} and the time increase by {{#crossLink "VideoEditorPreview/increaseVideoEditorPreviewTimer:method"}}{{/crossLink}}.
@method playVideoEditorComponent
@for VideoEditorPreview
@param component {Object} the component to be played
@param with_scroll {Boolean} if true, it uses {{#crossLink "VideoEditorScrollPain/followPreviewComponentsWithHorizontalScrollInVideoEditor:method"}}{{/crossLink}} to follow the timeline with the scroll.
**/
function playVideoEditorComponent(component, with_scroll) {
  if(with_scroll) {
    followPreviewComponentsWithHorizontalScrollInVideoEditor();
  }
  var identifier = getVideoComponentIdentifier(component.attr('id'));
  $('._video_component_transition').addClass('current');
  var next_component_to_load = component.next();
  if(next_component_to_load.hasClass('_video_editor_component')) {
    loadVideoComponentIfNotLoadedYet(next_component_to_load.attr('id'));
  }
  if(component.hasClass('_video')) {
    var video = $('#video_component_' + identifier + '_preview video');
    if(video[0].error) {
      showLoadingMediaErrorPopup(video[0].error.code, 'video');
      $('#video_editor_global_preview_pause').click();
    } else {
      video[0].play();
    }
  } else {
    automaticIncreaseVideoEditorPreviewTimer(component.data('current-preview-time') + 1, component.data('duration'), function() {
      var next_component = component.next();
      var next_identifier = getVideoComponentIdentifier(next_component.attr('id'));
      if(next_component.hasClass('_video_editor_component')) {
        increaseVideoEditorPreviewTimer(true);
        $('#video_editor_global_preview').data('current-component', getVideoComponentIdentifier(next_component.attr('id')));
        $('#video_component_' + identifier + '_preview').hide('fade', {}, 1000);
        component.find('._video_component_transition').removeClass('current');
        next_component.find('._video_editor_component_hover, ._video_component_icon').removeClass('selected');
        $('#video_component_' + next_identifier + '_preview').show('fade', {}, 1000, function() {
          hideVideoEditorPreviewComponentProgressBar();
          $('#video_component_' + identifier + ' ._video_component_icon ._right').html(secondsToDateString(0));
          if(!$('#video_editor_global_preview').data('in-use')) {
            $('._video_component_transition').addClass('current');
          }
          increaseVideoEditorPreviewTimer(false);
          component.find('._video_editor_component_hover, ._video_component_icon').addClass('selected');
          if($('#video_editor_global_preview').data('in-use')) {
            playVideoEditorComponent(next_component, true);
          } else {
            var how_many_hidden_to_left = getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186);
            showVideoEditorPreviewComponentProgressBar(next_identifier, next_component.data('position') - how_many_hidden_to_left);
          }
        });
      } else {
        var first_component = getFirstVideoEditorComponent();
        selectVideoComponentInPreview(first_component);
        hideVideoEditorPreviewComponentProgressBar();
        if(videoEditorWithAudioTrack()) {
          $('#video_editor_preview_container audio')[0].pause();
        }
        $('#video_editor_global_preview_pause').trigger('click');
        if($('._video_editor_component').length > 5) {
          $('#media_elements_list_in_video_editor').jScrollPane().bind('panescrollstop', function() {
            showVideoEditorPreviewComponentProgressBar(getVideoComponentIdentifier(first_component.attr('id')), 1);
            $('#media_elements_list_in_video_editor').jScrollPane().unbind('panescrollstop');
          });
          $('#media_elements_list_in_video_editor').data('jsp').scrollToX(0, true, 500);
        } else {
          showVideoEditorPreviewComponentProgressBar(getVideoComponentIdentifier(first_component.attr('id')), 1);
        }
      }
    });
  }
}

/**
Starts the preview from the selected component.
@method startVideoEditorGlobalPreview
@for VideoEditorPreview
**/
function startVideoEditorGlobalPreview() {
  $('#video_editor_global_preview').data('in-use', true);
  var current_identifier = $('#video_editor_global_preview').data('current-component');
  var current_component = $('#video_component_' + current_identifier);
  var actual_audio_track_time = calculateVideoComponentStartSecondInVideoEditor(current_identifier) + current_component.data('current-preview-time');
  if(videoEditorWithAudioTrack() && actual_audio_track_time < $('#full_audio_track_placeholder_in_video_editor').data('duration')) {
    var audio_track = $('#video_editor_preview_container audio');
    if(audio_track[0].error) {
      showLoadingMediaErrorPopup(audio_track[0].error.code, 'audio');
    } else {
      setCurrentTimeToMedia(audio_track, actual_audio_track_time);
      audio_track[0].play();
    }
  }
  if(current_component.data('position') == getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186) + 1) {
    playVideoEditorComponent(current_component, false);
  } else {
    hideVideoEditorPreviewComponentProgressBar();
    playVideoEditorComponent(current_component, true);
  }
}





/**
Calculates the amount of seconds before the current position in the global preview (used for {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAudioTrack:method"}}{{/crossLink}}).
@method calculateVideoComponentStartSecondInVideoEditor
@for VideoEditorPreviewAccessories
@param identifier {Number} the unique identifier of the current component in preview mode
@return {Number} the amount of seconds before the current global time in preview
**/
function calculateVideoComponentStartSecondInVideoEditor(identifier) {
  var duration = 0;
  var stop = false;
  $('._video_editor_component').each(function(index) {
    if(getVideoComponentIdentifier($(this).attr('id')) == identifier) {
      stop = true;
    } else if(!stop) {
      duration += ($(this).data('duration') + 1);
    }
  });
  var cutter = $('#video_component_' + identifier + '_cutter');
  if(!cutter.hasClass('_mini_cutter')) {
    duration += (cutter.find('._media_player_slider').slider('value') - cutter.data('from'));
  }
  return duration;
}

/**
Hides the component progress bar.
@method hideVideoEditorPreviewComponentProgressBar
@for VideoEditorPreviewAccessories
**/
function hideVideoEditorPreviewComponentProgressBar() {
  $('#video_editor_preview_slider').slider('destroy');
  $('#video_editor_preview_slider').hide();
}

/**
Selects a video component with a specific time in preview mode.
@method selectVideoComponentInPreview
@for VideoEditorPreviewAccessories
@param component {Object} the component
@param time {Number} the local time to be selected
**/
function selectVideoComponentInPreview(component, time) {
  $('._video_component_preview').hide();
  $('#' + component.attr('id') + '_preview').show();
  $('._video_editor_component_hover, ._video_component_icon').addClass('selected');
  component.find('._video_editor_component_hover, ._video_component_icon').removeClass('selected');
  if(time == undefined) {
    time = 0;
  }
  setVisualTimesVideoEditorPreview(component, time);
}

/**
Sets the times of all previous and following components. The normal status of the global preview is with time = 0 for each component which is not selected.
@method setVisualTimesVideoEditorPreview
@for VideoEditorPreviewAccessories
@param component {Object} the selected component
@param time {Object} the time to be set in the selected component
**/
function setVisualTimesVideoEditorPreview(component, time) {
  var identifier = getVideoComponentIdentifier(component.attr('id'));
  var global_time = calculateVideoComponentStartSecondInVideoEditor(identifier) + time;
  $('#visual_video_editor_current_time').html(secondsToDateString(global_time));
  $('#video_editor_global_preview').data('current-time', global_time);
  $('#video_editor_global_preview').data('current-component', identifier);
  $('._video_editor_component').each(function() {
    var my_identifier = getVideoComponentIdentifier($(this).attr('id'));
    if(my_identifier == identifier) {
      $(this).find('._video_component_icon ._right').html(secondsToDateString(time));
      $(this).data('current-preview-time', time);
      if($('#video_component_' + my_identifier + '_preview video').length > 0 && $('#video_component_' + my_identifier + '_preview').data('loaded')) {
        setCurrentTimeToMedia($('#video_component_' + my_identifier + '_preview video'), $('#video_component_' + my_identifier + '_cutter').data('from') + time);
      }
    } else {
      $(this).find('._video_component_icon ._right').html(secondsToDateString(0));
      $(this).data('current-preview-time', 0);
      if($('#video_component_' + my_identifier + '_preview video').length > 0 && $('#video_component_' + my_identifier + '_preview').data('loaded')) {
        setCurrentTimeToMedia($('#video_component_' + my_identifier + '_preview video'), $('#video_component_' + my_identifier + '_cutter').data('from'));
      }
    }
  });
}

/**
Shows the arrows to switch between components in preview mode.
@method showVideoEditorPreviewArrowToComponents
@for VideoEditorPreviewAccessories
**/
function showVideoEditorPreviewArrowToComponents() {
  if(getVideoComponentIdentifier(getFirstVideoEditorComponent().attr('id')) != $('#video_editor_global_preview').data('current-component')) {
    $('#video_editor_preview_go_to_left_component').show();
  } else {
    $('#video_editor_preview_go_to_left_component').hide();
  }
  if(getVideoComponentIdentifier(getLastVideoEditorComponent().attr('id')) != $('#video_editor_global_preview').data('current-component')) {
    $('#video_editor_preview_go_to_right_component').show();
  } else {
    $('#video_editor_preview_go_to_right_component').hide();
  }
}

/**
Shows the progress bar for a given component. This bar is used to set the time of the component (using {{#crossLink "VideoEditorPreviewAccessories/selectVideoComponentInPreview:method"}}{{/crossLink}}), and while the preview is playing to show the progress of the component. Remember that the progress bar is the same for each component, and it is initialized and destroyed each time. This method uses {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}} for the correct positioning of the progress bar.
@method showVideoEditorPreviewComponentProgressBar
@for VideoEditorPreviewAccessories
@param identifier {Number} the unique identifier of the component
@param position {Number} the position (1...5) of the progress bar
**/
function showVideoEditorPreviewComponentProgressBar(identifier, position) {
  var component = $('#video_component_' + identifier);
  var tool = $('#video_editor_preview_slider');
  if(!tool.is(':visible')) {
    tool.slider({
      min: 0,
      max: component.data('duration'),
      value: component.data('current-preview-time'),
      range: 'min',
      stop: function(event, ui) {
        var my_value = ui.value;
        if(my_value == component.data('duration')) {
          my_value = component.data('duration') - 1;
          tool.slider('value', my_value);
        }
        setVisualTimesVideoEditorPreview(component, my_value);
      }
    });
    tool.show();
    tool.css('left', (position - 1) * 186 + 3);
  }
}





/**
Replaces a generig component with an image component, contructing an empty <b>preview</b>, <b>cutter</b> and editing the <b>component</b> (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method replaceImageComponentInVideoEditor
@for VideoEditorReplaceComponents
@param image_id {Number} the id of the image in the database
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the image
@param preview {String} HTML code corresponding to the already built <b>content of the preview</b> for the image
@param position {String} HTML identifier for the replaced component
@param duration {Number} the duration in seconds of the image component
**/
function replaceImageComponentInVideoEditor(image_id, component, preview, position, duration) {
  var identifier = getVideoComponentIdentifier(position);
  // build preview
  var empty_preview = $('#empty_image_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_component_' + identifier + '_preview').replaceWith(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_image_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_component_' + identifier + '_cutter').replaceWith(empty_cutter);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  current_preview.attr('id', ('video_component_' + identifier + '_preview'));
  current_preview.html(preview);
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + identifier + '_cutter'));
  current_cutter.find('._old').html(secondsToDateString(duration));
  // edit component
  $('#' + position).removeClass('_video _image _text').addClass('_image');
  $('#' + position + ' ._video_component_thumb').replaceWith(component);
  clearSpecificVideoEditorComponentParameters(position);
  $('#' + position + ' ._video_component_input_type').val('image');
  var to_be_appended = fillVideoEditorSingleParameter('image_id', identifier, image_id);
  to_be_appended += fillVideoEditorSingleParameter('duration', identifier, duration);
  $('#' + position + ' ._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(position, duration);
}

/**
Replaces a generic component with a text component, contructing an empty <b>preview</b>, <b>cutter</b> and editing the <b>component</b> (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method replaceTextComponentInVideoEditor
@for VideoEditorReplaceComponents
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the text
@param content {String} the text content
@param position {String} HTML identifier for the replaced component
@param duration {Number} the duration in seconds of the image component
@param background_color {String} the class corresponding to the color chosen for the background
@param text_color {String} the class corresponding to the color chosen for the text font
**/
function replaceTextComponentInVideoEditor(component, content, position, duration, background_color, text_color) {
  var identifier = getVideoComponentIdentifier(position);
  // build preview
  var empty_preview = $('#empty_text_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_component_' + identifier + '_preview').replaceWith(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_text_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_component_' + identifier + '_cutter').replaceWith(empty_cutter);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  current_preview.attr('id', ('video_component_' + identifier + '_preview'));
  current_preview.removeClass('background_color_white').addClass('background_color_' + background_color);
  current_preview.find('p').removeClass('color_black').addClass('color_' + text_color);
  current_preview.find('p').html(content);
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + identifier + '_cutter'));
  current_cutter.find('._old').html(secondsToDateString(duration));
  // edit component
  $('#' + position).removeClass('_video _image _text').addClass('_text');
  $('#' + position + ' ._video_component_thumb').replaceWith(component);
  $('#' + position + ' ._video_component_thumb ._text_content').html(content);
  $('#' + position + ' ._video_component_thumb ._text_content').removeClass('color_black').addClass('color_' + text_color);
  $('#' + position + ' ._video_component_thumb').removeClass('background_color_white').addClass('background_color_' + background_color);
  clearSpecificVideoEditorComponentParameters(position);
  $('#' + position + ' ._video_component_input_type').val('text');
  var to_be_appended = fillVideoEditorSingleParameter('content', identifier, content);
  to_be_appended += fillVideoEditorSingleParameter('background_color', identifier, background_color);
  to_be_appended += fillVideoEditorSingleParameter('text_color', identifier, text_color);
  to_be_appended += fillVideoEditorSingleParameter('duration', identifier, duration);
  $('#' + position + ' ._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(position, duration);
}

/**
Replaces a generic component with a video component, contructing an empty <b>preview</b>, <b>cutter</b> and editing the <b>component</b> (see the commentaries inside the code). This method is called by {{#crossLink "VideoEditorDocumentReady/videoEditorDocumentReadyAddComponent:method"}}{{/crossLink}}.
@method replaceVideoComponentInVideoEditor
@for VideoEditorReplaceComponents
@param video_id {Number} the id of the video in the database
@param webm {String} path of the webm attached of the video
@param mp4 {String} path of the mp4 attached of the video
@param component {String} HTML code corresponding to the already built <b>miniature</b> of the video
@param position {String} HTML identifier for the replaced component
@param duration {Number} the duration in seconds of the video component (initially the values <b>from</b> and <b>to</b> are respectively <b>0</b> and <b>duration</b>)
**/
function replaceVideoComponentInVideoEditor(video_id, webm, mp4, component, position, duration) {
  var identifier = getVideoComponentIdentifier(position);
  // build preview
  var empty_preview = $('#empty_video_preview_for_video_editor').html();
  empty_preview = '<div id="temporary_empty_preview" ' + empty_preview.substr(empty_preview.indexOf('div') + 3, empty_preview.length);
  $('#video_component_' + identifier + '_preview').replaceWith(empty_preview);
  // build cutter
  var empty_cutter = $('#empty_video_cutter_for_video_editor').html();
  empty_cutter = '<div id="temporary_empty_cutter" ' + empty_cutter.substr(empty_cutter.indexOf('div') + 3, empty_cutter.length);
  $('#video_component_' + identifier + '_cutter').replaceWith(empty_cutter);
  // edit preview
  current_preview = $('#temporary_empty_preview');
  if(videoEditorWithAudioTrack()) {
    current_preview.find('video').prop('muted', true);
  }
  current_preview.attr('id', ('video_component_' + identifier + '_preview'));
  current_preview.find('source[type="video/webm"]').attr('src', webm);
  current_preview.find('source[type="video/mp4"]').attr('src', mp4);
  current_preview.find('video').load();
  // edit cutter
  current_cutter = $('#temporary_empty_cutter');
  current_cutter.attr('id', ('video_component_' + identifier + '_cutter'));
  current_cutter.find('._video_editor_cutter_total_time').html(secondsToDateString(duration));
  current_cutter.find('._video_editor_cutter_selected_time').html(secondsToDateString(duration));
  current_cutter.data('to', duration);
  current_cutter.data('max-to', duration);
  initializeVideoInVideoEditorPreview(identifier);
  // edit component
  $('#' + position).removeClass('_video _image _text').addClass('_video');
  $('#' + position + ' ._video_component_thumb').replaceWith(component);
  clearSpecificVideoEditorComponentParameters(position);
  $('#' + position + ' ._video_component_input_type').val('video');
  var to_be_appended = fillVideoEditorSingleParameter('video_id', identifier, video_id);
  to_be_appended += fillVideoEditorSingleParameter('from', identifier, 0);
  to_be_appended += fillVideoEditorSingleParameter('to', identifier, duration);
  $('#' + position + ' ._video_editor_component_hover').append(to_be_appended);
  // other things
  changeDurationVideoEditorComponent(position, duration);
}





/**
Method that uses the scroll to keep visible the current component in the timeline. It uses {{#crossLink "MediaElementEditorHorizontalTimelines"}}{{/crossLink}}.
@method followPreviewComponentsWithHorizontalScrollInVideoEditor
@for VideoEditorScrollPain
**/
function followPreviewComponentsWithHorizontalScrollInVideoEditor() {
  var jsp_handler = $('#media_elements_list_in_video_editor').data('jsp');
  var identifier = $('#video_editor_global_preview').data('current-component');
  var pos = $('#video_component_' + identifier).data('position');
  var how_many_hidden_to_left = getHowManyComponentsHiddenToLeftTimelineHorizontalScrollPane('media_elements_list_in_video_editor', 186);
  var movement = 0;
  var whole_movement = 0;
  if(pos - how_many_hidden_to_left == 5) {
    movement = calculateCorrectMovementHorizontalScrollRight(how_many_hidden_to_left, 4, $('._video_editor_component').length, 5);
    if(movement > 0) {
      whole_movement = (how_many_hidden_to_left + movement) * 186;
    }
  } else if(pos - how_many_hidden_to_left == 6) {
    movement = calculateCorrectMovementHorizontalScrollRight(how_many_hidden_to_left, 5, $('._video_editor_component').length, 5);
    if(movement > 0) {
      whole_movement = (how_many_hidden_to_left + movement) * 186;
    }
  } else if(pos == how_many_hidden_to_left) {
    movement = calculateCorrectMovementHorizontalScrollLeft(how_many_hidden_to_left, 5);
    if(movement > 0) {
      whole_movement = (how_many_hidden_to_left - movement) * 186;
    }
  } else if(pos == how_many_hidden_to_left + 1) {
    movement = calculateCorrectMovementHorizontalScrollLeft(how_many_hidden_to_left, 4);
    if(movement > 0) {
      whole_movement = (how_many_hidden_to_left - movement) * 186;
    }
  }
  if(movement != 0) {
    $('#video_editor_global_preview').data('arrows', false);
    $('#media_elements_list_in_video_editor').jScrollPane().bind('panescrollstop', function() {
      $('#video_editor_global_preview').data('arrows', true);
      showVideoEditorPreviewComponentProgressBar(identifier, pos - (whole_movement / 186));
      $('#media_elements_list_in_video_editor').jScrollPane().unbind('panescrollstop');
    });
    jsp_handler.scrollToX(whole_movement, true, (1000 * movement) / 4);
  } else {
    showVideoEditorPreviewComponentProgressBar(identifier, pos - how_many_hidden_to_left);
  }
}





/**
Resets the text component editor when it's closed.
@method resetVideoEditorTextComponent
@for VideoEditorTextComponentEditor
**/
function resetVideoEditorTextComponent() {
  $('#text_component_preview textarea').val($('#text_component_preview').data('placeholder-content'));
  $('#video_editor_mixed_gallery_container ._texts ._duration_selector input').val('');
  $('#text_component_preview').data('placeholder', true);
  var old_background_color = $('#text_component_preview').data('background-color');
  var old_text_color = $('#text_component_preview').data('text-color');
  switchTextComponentBackgroundColor(old_background_color, 'white');
  switchTextComponentTextColor(old_text_color, 'black');
}

/**
Switches to a different background color the text component editor.
@method switchTextComponentBackgroundColor
@for VideoEditorTextComponentEditor
@param old_color {String} the class corresponding to the old color chosen for the background
@param new_color {String} the class corresponding to the new color chosen for the background
**/
function switchTextComponentBackgroundColor(old_color, new_color) {
  $('#text_component_preview').removeClass('background_color_' + old_color).addClass('background_color_' + new_color);
  $('._text_component_in_video_editor_background_color_selector ._color').removeClass('current');
  $('._text_component_in_video_editor_background_color_selector .background_color_' + new_color).addClass('current');
  $('#text_component_preview').data('background-color', new_color);
}

/**
Switches to a different text color the text component editor.
@method switchTextComponentTextColor
@for VideoEditorTextComponentEditor
@param old_color {String} the class corresponding to the old color chosen for the text font
@param new_color {String} the class corresponding to the new color chosen for the text font
**/
function switchTextComponentTextColor(old_color, new_color) {
  $('#text_component_preview textarea').removeClass('color_' + old_color).addClass('color_' + new_color);
  $('._text_component_in_video_editor_text_color_selector ._color').removeClass('current');
  $('._text_component_in_video_editor_text_color_selector .background_color_' + new_color).addClass('current');
  $('#text_component_preview').data('text-color', new_color);
}
