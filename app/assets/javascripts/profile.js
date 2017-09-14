/**
This module contains the initialization methods for <b>profiling</b> and <b>registration</b> of new users.
@module profile
**/





/**
Initializes the handler of the login form.
@method preloginDocumentReady
@for ProfilePrelogin
**/
function preloginDocumentReady() {
  $body.on('click', '._show_login_form_container', function() {
    var form = $('#login_form_container');
    if(!form.is(':visible')) {
      form.show('fade', {}, 500);
      $('#email').focus();
    } else {
      form.hide('fade', {}, 500);
    }
  });
  $document.bind('click', function (e) {
    var my_login = $('#login_form_container:visible');
    if(my_login.length > 0 && $(e.target).parents('#login_form_container').length == 0 && !$(e.target).hasClass('_show_login_form_container')) {
      $('._show_login_form_container').click();
    }
  });
  $body.on('click', '#submit_login_form', function() {
    $('#new_users_session_form').submit();
  });
  $body.on('click', '#registration-subjects label', function() {
    $('#registration-subjects label').removeClass('true');
  });
  $body.on('click', '.profile-subject-cathegory-container .profile-element label', function() {
    if($(this).hasClass('unchecked')) {
      $(this).removeClass('unchecked');
    } else {
      $(this).addClass('unchecked');
    }
  });
  $body.on('click', '.checkAllSubjects', function() {
    $(this).parent().find('.profile-element label.unchecked').click();
  });
  $body.on('keydown', '#registration-general input', function() {
    $(this).removeClass('true');
  });
  $body.on('click', '#registration-policies label', function() {
    $(this).removeClass('true');
  });
  $('.policy-verticalScroll').jScrollPane({autoReinitialise: true});
  var parsedLocation = UrlParser.parse(window.location.href);
  if(_.contains(_.keys(parsedLocation.searchObj), 'login')) {
    $('._show_login_form_container').click();
  }
}

/**
Initializes handler of purchase code in prelogin registration.
@method purchaseCodeRegistrationDocumentReady
@for ProfilePrelogin
**/
function purchaseCodeRegistrationDocumentReady() {
  $body.on('keydown', '#registration_purchase_id', function() {
    $(this).removeClass('error');
  });
  $body.on('blur', '#registration_purchase_id', function() {
    var token = $(this).val();
    $.ajax({
      type: 'get',
      url: 'sign_up/purchase_code?token=' + token
    });
  });
  $body.on('click', '#registration_trial', function() {
    var me = $(this);
    if(!me.hasClass('checked')) {
      me.addClass('checked').val('1');
      $('#registration_purchase_id').val('').removeClass('error').attr('disabled', 'disabled');
      $('#registration_ok').hide();
    } else {
      me.removeClass('checked').val('0');
      $('#registration_purchase_id').removeAttr('disabled');
    }
  });
  $body.on('click', '#locations_disclaimer', function() {
    var me = $(this);
    if(!me.hasClass('checked')) {
      me.addClass('checked');
      var last_not_select = $('#registration-locations .profile-element select').first().parent();
      var depth = 0;
      while(last_not_select.length > 0) {
        last_not_select = last_not_select.prev();
        depth += 1;
      }
      $.ajax({
        type: 'get',
        url: 'locations/toggle?on=false&depth=' + depth
      });
    } else {
      me.removeClass('checked');
      var last_not_selected = $('#registration-locations .profile-element.locked').last();
      var which_selected = 0;
      if(last_not_selected.length > 0) {
        which_selected = last_not_selected.find('input').data('selected');
      }
      $.ajax({
        type: 'get',
        url: 'locations/toggle?on=true&location_id=' + which_selected
      });
    }
  });
}





/**
Initializes the javascript effects of the registration / modify profile form.
@method profileDocumentReady
@for ProfileUsers
**/
function profileDocumentReady() {
  $body.on('keypress', '#mailing_lists_accordion .group-title', function(event) {
    if (event.keyCode == 10 || event.keyCode == 13) {
      event.preventDefault();
    }
  });
  $body.on('keypress', '#mailing_lists_accordion .group-title', function(event) {
     if(event.which === 32) {
       event.stopPropagation();
     }
  });
  $body.on('blur', '#mailing_lists_accordion .group-title', function() {
    var group = $(this);
    $.ajax({
      type: 'put',
      url: '/mailing_lists/' + group.data('param') + '/update/' + group.text()
    });
  });
  $body.on('click', '#fake_save_mailing_list', function() {
    $('.group-title').effect('highlight', {color: '#41A62A'}, 1500);
  });
  $body.on('focus', '._input_in_mailing_list', function() {
    if($(this).data('placeholder')) {
      $(this).val('');
      $(this).data('placeholder', false);
    }
  });
  $body.on('keydown', '#profile-general-edit input', function() {
    $(this).removeClass('true');
  });
}
