/**
Browser support checking functions
@module browser-support
**/





/**
Browser support checking, not supported browsers version. It substitutes the page body with the not supported browser HTML. Implements two empty functions, one in {{#crossLink "AdminBrowserSupport/adminBrowserSupport:method"}}{{/crossLink}}, and one in {{#crossLink "GeneralMiscellanea/browserSupport:method"}}{{/crossLink}}.
@method browserSupportMain
@for BrowserSupportMain
**/
function browserSupport() {
  document.body.style.visibility = 'hidden';
  document.body.onload = function() {
    document.body.innerHTML = '';
    var xmlhttp;
    if (window.XMLHttpRequest) {
      xmlhttp = new XMLHttpRequest();
    } else {
      xmlhttp = new ActiveXObject('Microsoft.XMLHTTP');
    }
    xmlhttp.onreadystatechange = function() {
      if (xmlhttp.readyState === 4 && xmlhttp.status === 200) {
        document.body.innerHTML = xmlhttp.responseText;
        document.body.style.visibility = 'visible';
      }
    }
    var csrfToken = document.getElementsByName('csrf-token')[0].content;
    xmlhttp.open('POST', '/browser_not_supported?authenticity_token=' + csrfToken, true);
    xmlhttp.send();
    return false;
  }
}
