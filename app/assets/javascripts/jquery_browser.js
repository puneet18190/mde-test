/**
This module contains browser matcher for JQuery.
<br/><br/>
It is used in the module {{#crossLinkModule "jquery-patches"}}{{/crossLinkModule}} where it's defined a set of functions that handle different behaviors depending on the browser (the patches are based on the variable $.browser defined in this module).
<br/><br/>
It is used also in the module {{#crossLinkModule "browser-support"}}{{/crossLinkModule}}, where it's defined the function {{#crossLink "BrowserSupportMain/browserSupportMain:method"}}{{/crossLink}}, which handles the browsers not supported by the application.
<br/><br/>
Finally, the two empty functions {{#crossLink "AdminBrowserSupport/adminBrowserSupport:method"}}{{/crossLink}} and {{#crossLink "GeneralMiscellanea/browserSupport:method"}}{{/crossLink}} are the links in the respective files application.js (one for admin and one for general / lesson_archive) of the function above.
<br/><br/>
Important: in lesson_scorm application.js there are not any calls to any of the modules {{#crossLinkModule "jquery-browsers"}}{{/crossLinkModule}}, {{#crossLinkModule "jquery-patches"}}{{/crossLinkModule}}, nor {{#crossLinkModule "browser-support"}}{{/crossLinkModule}}.
<br/><br/>
Note by the developer: "Limit scope pollution from any deprecated API".
@module jquery-browsers
**/
(function() {
  var matched, browser;





/**
Use of jQuery.browser is frowned upon. More details: http://api.jquery.com/jQuery.browser. jQuery.uaMatch maintained for back-compat
@method browsersDetectionGeneral
@for JqueryBrowsersDetection
**/
jQuery.uaMatch = function( ua ) {
  var match = [];
  ua = ua.toLowerCase();
  if(ua.indexOf('ipad') >= 0) {
    match[ 0 ] = 'ipad';
  } else if(ua.indexOf('iphone') >= 0) {
    match[ 0 ] = 'iphone';
  } else {
    match = /(chrome)[ \/]([\w.]+)/.exec( ua ) ||
      /(webkit)[ \/]([\w.]+)/.exec( ua ) ||
      /(opera)(?:.*version|)[ \/]([\w.]+)/.exec( ua ) ||
      // Internet Explorer < 11
      /(msie) ([\w.]+)/.exec( ua ) ||
      // Internet Explorer >= 11
      /(trident)(?:.*? rv:([\w.]+)|)/.exec( ua ) ||
      ( ua.indexOf("compatible") < 0 && /(mozilla)(?:.*? rv:([\w.]+)|)/.exec( ua ) );
    if ( match[ 1 ] === "trident" ) {
      match[ 1 ] = "msie";
    }
  }
  return {
    browser: match[ 1 ] || "",
    version: match[ 2 ] || "0"
  };
};
matched = jQuery.uaMatch( navigator.userAgent );
browser = {};
if ( matched.browser ) {
  browser[ matched.browser ] = true;
  browser.version = matched.version;
}

/**
Chrome is Webkit, but Webkit is also Safari.
@method browsersDetectionSafariAndChrome
@for JqueryBrowsersDetection
**/
if ( browser.chrome ) {
  browser.webkit = true;
} else if ( browser.webkit ) {
  browser.safari = true;
}





  jQuery.browser = browser;
})();
