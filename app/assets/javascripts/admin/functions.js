/**
Functions used in the Administration section: only for this section, <b>it's generated a separate file</b> which doesn't merge with the regular one. The only external module loaded is {{#crossLinkModule "ajax-loader"}}{{/crossLinkModule}}.
@module admin
**/





/**
Initializer for jQueryUI autocomplete on users serch into Admin Notifications.
@method initNotificationsAutocomplete
@for AdminAutocomplete
**/
function initNotificationsAutocomplete() {
  $(function() {
    function log(message, _id) {
      if($('#' + _id).length === 0) {
        $('<div class="label label-info" id="+_id+">').text(message).prependTo('#log').append('<a href="#" class="del">x</a>');
        $('#log').scrollTop(0);
        if($('#search_users_ids').val().length > 0) {
          $('#search_users_ids').val($( '#search_users_ids').val() + ',' + _id);
        } else {
          $('#search_users_ids').val(_id);
        }
        $('#filter-users').submit();
        var dup = $('#contact-recipients').clone();
        $('#contact-recipients').remove();
        $(dup).appendTo('.recipients_input');
        $(dup).val('');
        initNotificationsAutocomplete();
        $('#contact-recipients').focus();
      }
    }
    $('#contact-recipients').autocomplete({
      source: '/admin/users/get_full_names',
      minLength: 2,
      select: function(event, ui) {
        log(ui.item ? ui.item.value : 'No match' , ui.item.id);
      }
    });
  });
}





/**
Browser support checking, supported browsers version. It is empty. The not supported browsers version is implemented in {{#crossLink "BrowserSupportMain/browserSupportMain:method"}}{{/crossLink}}
@method adminBrowserSupport
@for AdminBrowserSupport
**/
function browserSupport() {
}





/**
Open a collapsed table row with extra content, tipically clicking on previous collapsable table row.
@method openAndLoadNextTr
@for AdminCollapsed
@param prevTr {Object} the previous element in the table
**/
function openAndLoadNextTr(prevTr) {
  var next_tr = prevTr.next('tr.collapsed');
  var thumb = next_tr.find('.element-thumbnail');
  if((thumb.length > 0) && !thumb.data('loaded')) {
    var el_id = next_tr.find('.element-thumbnail').data('param');
    $.ajax({
      url: '/admin/media_elements/' + el_id + '/load',
      type: 'get'
    });
  }
  next_tr.slideToggle('slow');
}





/**
Initializes the browser classes in the tag html. Same functionality as {{#crossLink "GeneralDocumentReady/browsersDocumentReady:method"}}{{/crossLink}}.
@method adminBrowsersDocumentReady
@for AdminDocumentReady
**/
function adminBrowsersDocumentReady() {
  if(!$.browser.msie) {
    $('#admin-media-elements-quick-upload-form').fileupload();
  } else {
    $('#admin-media-elements-quick-upload-form').append($('<input name="from_ie" value="true" style="display:none" />'));
    $('#hint_not_for_ie').hide();
    $('#qume_file').change(function() {
      $('#admin-media-elements-quick-upload-form').submit();
    });
  }
}

/**
Initializes the effects of collapse and change date.
@method adminEffectsDocumentReady
@for AdminDocumentReady
**/
function adminEffectsDocumentReady() {
  var nowTemp = new Date();
  var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), nowTemp.getDate(), 0, 0, 0, 0);
  var checkin = $('#dpd1').datepicker({
    onRender: function(date) {
      return date.valueOf() < now.valueOf() || (checkout && date.valueOf() < checkout.date.valueOf()) ? 'disabled' : '';
    }
  }).on('changeDate', function(ev) {
    if (ev.date.valueOf() > checkout.date.valueOf()) {
      $('#alert').show();
      $('#alert .start').show();
      $('#alert .end').hide();
    } else {
      $('#alert').hide();
    }
    checkin.hide();
    $('#dpd1')[0].blur();
    $('#dpd2')[0].blur();
  }).data('datepicker');
  var checkout = $('#dpd2').datepicker({
    onRender: function(date) {
      return date.valueOf() <= checkin.date.valueOf() ? 'disabled' : '';
    }
  }).on('changeDate', function(ev) {
    if (ev.date.valueOf() < checkin.date.valueOf()) {
      $('#alert').show();
      $('#alert .end').show();
      $('#alert .start').hide();
    } else {
      $('#alert').hide();
    }
    checkout.hide();
    $('#dpd1')[0].blur();
    $('#dpd2')[0].blur();
  }).data('datepicker');
  $('.dropdown').click(function(e) {
    e.stopPropagation();
  });
  $body.on('click', 'tr.collapse', function(e) {
    var t = $(e.target);
    if(!(t.hasClass('icon-eye-open') || t.hasClass('icon-remove') || t.hasClass('icon-globe') || t.hasClass('_user_link_in_admin') || t.hasClass('_link_in_admin') || t.hasClass('_report_item') || t.hasClass('_dont_report_item'))) {
      openAndLoadNextTr($(this));
    }
  });
  $body.on('click', '#expand-all', function(e) {
   e.preventDefault();
   $('tr.collapsed').slideDown('slow');
  });
  $body.on('click', '#collapse-all', function(e) {
   e.preventDefault();
   $('tr.collapsed').slideUp('slow');
  });
}

/**
Initializes the locations filling. See similar {{#crossLink "GeneralDocumentReady/locationsDocumentReady:method"}}{{/crossLink}}.
@method adminLocationsDocumentReady
@for AdminDocumentReady
**/
function adminLocationsDocumentReady() {
  $('._select_locations_admin').on('change', function() {
    if(!$(this).data('is-last')) {
      if($(this).val() == '0') {
        $(this).parents('.control-group').nextAll().find('select').html('');
      } else {
        $.ajax({
          url: '/admin/locations/' + $(this).val() + '/find',
          type: 'get'
        });
      }
    }
  });
  $body.on('click', '.edit_admin_location', function() {
    var father = $('#admin_location_' + $(this).data('location-id'));
    father.find('.name_write').show();
    father.find('.name_readonly').hide();
    father.find('.code_write').show();
    father.find('.code_readonly').hide();
    father.find('.edit_admin_location_done').show();
    father.find('.edit_admin_location').hide();
  });
  $body.on('click', '.edit_admin_location_done', function() {
    var father = $('#admin_location_' + $(this).data('location-id'));
    $.ajax({
      url: '/admin/settings/locations/' + $(this).data('location-id') + '/update?name=' + father.find('.name_write').val() + '&code=' + father.find('.code_write').val(),
      type: 'put'
    });
  });
  $body.on('click', '.create_admin_location', function() {
    $('#create_admin_location_' + $(this).data('location-type') + ' .create_admin_location_form').show();
    $(this).hide();
  });
  $body.on('click', '.create_admin_location_form_done', function() {
    var father = $('#create_admin_location_' + $(this).data('location-type'));
    $.ajax({
      url: '/admin/settings/locations/create?name=' + father.find('.create_admin_location_name').val() + '&code=' + father.find('.create_admin_location_code').val() + '&sti_type=' + $(this).data('location-type-for-form') + '&parent=' + $(this).data('location-parent'),
      type: 'post'
    });
  });
  $body.on('change', '#admin_purchase_choose_location_kind', function() {
    if($(this).val() == '0') {
      $('#admin_purchase_choose_location_wrapper select').each(function() {
        $(this).attr('disabled', 'disabled').addClass('disabled').removeClass('eletto');
      });
      $('#hidden_messages_for_admin_purchase_choose_location').hide();
      var first = true;
      $('._admin_purchase_choose_location_select_box').each(function() {
        if(first) {
          $(this).find('option').not('.dont_delete_me').removeAttr('selected');
          $(this).find('option.dont_delete_me').attr('selected', 'selected');
        } else {
          $(this).find('option').not('.dont_delete_me').remove();
        }
        first = false;
      });
    } else {
      var me = $('#admin_purchase_choose_location_' + $(this).val());
      me.removeAttr('disabled').removeClass('disabled').addClass('eletto');
      if(me.val() != '0') {
        $('#purchase_location_id').val(me.val());
      }
      var prev = me.prevUntil('._admin_purchase_choose_location_select_box').prev();
      while(prev.length > 0) {
        prev.removeAttr('disabled').removeClass('disabled').removeClass('eletto');
        prev = prev.prevUntil('._admin_purchase_choose_location_select_box').prev();
      }
      var next = me.nextUntil('._admin_purchase_choose_location_select_box').next();
      var first_next = true;
      while(next.length > 0) {
        next.attr('disabled', 'disabled').addClass('disabled').removeClass('eletto');
        if(first_next) {
          next.find('option.dont_delete_me').attr('selected', 'selected');
        } else {
          next.find('option').not('.dont_delete_me').remove();
        }
        next = next.nextUntil('._admin_purchase_choose_location_select_box').next();
        first_next = false
      }
      $('#hidden_messages_for_admin_purchase_choose_location').show();
      var translated_location = $(this).find('option.' + $(this).val()).data('translated');
      $('#hidden_messages_for_admin_purchase_choose_location .location').html(translated_location);
      $('#get_location_by_code_or_id').data('type', $(this).val());
    }
  });
  $body.on('change', '._admin_purchase_choose_location_select_box', function() {
    var me = $(this);
    if(me.val() != '0') {
      if(!me.data('last')) {
        $.ajax({
          type: 'get',
          url: '/admin/purchases/locations/' + me.val() + '/find'
        });
      }
      if(me.hasClass('eletto')) {
        $('#purchase_location_id').val(me.val());
      } else {
        $('#open_location_administrator').attr('href', '/admin/settings/locations?selected=' + me.val());
      }
    }
  });
  $body.on('click', '#get_location_by_code_or_id', function() {
    $.ajax({
      type: 'get',
      url: '/admin/purchases/locations/fill?' + $('#get_location_code_type').val() + '=' + $('#get_location_code').val() + '&sti_type=' + $(this).data('type')
    });
  });
}

/**
Initializes effects for MediaElement.
@method adminMediaElementsDocumentReady
@for AdminDocumentReady
**/
function adminMediaElementsDocumentReady() {
  $body.on('focus', '._quick_load_creation_form ._qume_title', function() {
    var placeholder = $(this).parents('._quick_load_creation_form').find('._qume_title_placeholder');
    if(placeholder.val() != '') {
      placeholder.val('');
      $(this).val('');
    }
  });
  $body.on('focus', '._quick_load_creation_form ._qume_description', function() {
    var placeholder = $(this).parents('._quick_load_creation_form').find('._qume_description_placeholder');
    if(placeholder.val() != '') {
      placeholder.val('');
      $(this).val('');
    }
  });
  $body.on('focus', '._quick_load_creation_form ._qume_tags', function() {
    var placeholder = $(this).parents('._quick_load_creation_form').find('._qume_tags_placeholder');
    if(placeholder.val() != '') {
      placeholder.val('');
      $(this).val('');
    }
  });
  $body.on('click', '._create_new_element', function() {
    $.ajax({
      type: 'post',
      data: $(this).parents('._quick_load_creation_form').serialize(),
      url: '/admin/media_elements/' + $(this).data('param') + '/create'
    });
  });
  $body.on('click', '._delete_new_element', function() {
    $.ajax({
      type: 'delete',
      url: '/admin/media_elements/quick_upload/' + $(this).data('param') + '/delete'
    });
  });
  $body.on('click','.action._publish_list_element i', function(e) {
    e.preventDefault();
    $.ajax({
      type: 'put',
      url: '/admin/media_elements/' + $(this).parent('a').data('param') + '?is_public=true',
      timeout: 5000,
      success: function() {
        var btn = $(e.target);
        btn.remove();
      }
    });
  });
  $body.on('click', '._publish_private_admin_element', function() {
    $.ajax({
      type: 'put',
      data: $(this).parents('._quick_load_creation_form').serialize(),
      url: '/admin/media_elements/' + $(this).data('param') + '/update?is_public=true'
    });
  });
  $body.on('click', '._update_private_admin_element', function() {
    $.ajax({
      type: 'put',
      data: $(this).parents('._quick_load_creation_form').serialize(),
      url: '/admin/media_elements/' + $(this).data('param') + '/update'
    });
  });
  initNotificationsAutocomplete();
  $body.on('click', '#log .del', function(e) {
    e.preventDefault();
    var my_div = $(this).parent('div')
    var ids_val = $('#search_users_ids').val().split(',');
    ids_val.splice(ids_val.indexOf(my_div.attr('id')), 1);
    $('#search_users_ids').val(ids_val);
    my_div.remove();
    $('#filter-users').submit();
  });
  $body.on('click','._filter_and_send', function(e) {
    e.preventDefault();
    if(!$(this).hasClass('disabled')) {
      $form = $(this).parents('form');
      $form.find('#send_message').val(true);
      $form.submit();
      $form.find('#send_message').val('');
    }
  });
}

/**
Initializes actions for less important tables, such as Tag, Subject, SchoolLevel 
@method adminMiscellaneaDocumentReady
@for AdminDocumentReady
**/
function adminMiscellaneaDocumentReady() {
  $body.on('click', 'ul.subjects li a i.icon-remove', function() {
    var _id = $(this).parents('li').data('param');
    $.ajax({
      type: 'delete',
      url: '/admin/settings/subjects/' + _id + '/delete'
    });
  });
  $body.on('click', 'ul.school_levels li a i.icon-remove', function() {
    $.ajax({
      type: 'delete',
      url: '/admin/settings/school_levels/' + $(this).parents('li').data('param') + '/delete'
    });
  });
  $body.on('click', '._dont_report_item', function() {
    $.ajax({
      type: 'delete',
      url: 'reports/' + $(this).data('report-id') + '/decline'
    });
  });
  $body.on('click', '._report_item', function() {
    $.ajax({
      type: 'delete',
      url: 'reports/' + $(this).data('report-id') + '/accept'
    });
  });
  $body.on('click', '#new_purchase #renewed', function() {
    $('#purchase_accounts_number').val($(this).data('accounts-number'));
    $('#renewed_id').val($(this).data('renewed-id'));
  });
  $body.on('focus', '#purchase_accounts_number', function() {
    $('#renewed_id').val('');
  });
}

/**
Initializes effects for the administration search engine.
@method adminSearchDocumentReady
@for AdminDocumentReady
**/
function adminSearchDocumentReady() {
  if($('#search_date_range').find('option:selected').val() && ($('#search_date_range').find('option:selected').val().length > 0)) {
    $('.datepick').removeAttr('disabled');
  }
  $('#search_date_range').on('change', function() {
    var selected = $(this).find('option:selected').val();
    if(selected.length > 0) {
      $('.datepick').removeAttr('disabled');
    } else {
      $('.datepick').attr('disabled', 'disabled');
    }
  });
  $body.on('change', '#filter-users select', function() {
    var selected = $(this).find('option:selected').first();
    var text = selected.text().replace(/\s+/g, ' ');
    var select_id = $(this).attr('id');
    if($('._filter_select.' + select_id).length > 0){
      if(selected.val().length > 0) {
        if(selected.val() != 0){
          $('.' + select_id + ' span').text(text);
        } else {
          $('#' + select_id).parents('.control-group').nextAll().find('select').each(function(){
            $('.' + $(this).attr('id')).remove();
          });
          $('.' + select_id).remove();
        }
      } else {
        $('.' + select_id).remove();
      }
    } else {
      $('<div class="label _filter_select ' + select_id + '">').html('<span>' + text + '</span>').prependTo('#log');
    }
    $('#filter-users').submit();
  });
  $('#all_users').change(function() {
      if(this.checked) {
        $('._filter_and_send').removeClass('disabled');
        $('input#contact-recipients').val('');
        $('input#contact-recipients').attr('disabled',true);
        $('#log').html('');
        $('._users_count_label').text($('._users_count_label').data('all-selected'));
        $('#filter-users select').each(function(){
          $this = $(this);
          $this.find('option:selected').removeAttr('selected');
          $this.attr('disabled',true);
        });
        $('#log').html('');
      } else {
        $('._filter_and_send').addClass('disabled');
        $('input#contact-recipients').attr('disabled', false);
        $('#filter-users select').attr('disabled', false);
        $('._users_count_label').text($('._users_count_label').data('zero-selected'));
      }
  });
}

/**
Initializes effects for sorting in administration search engine.
@method adminSortingDocumentReady
@for AdminDocumentReady
**/
function adminSortingDocumentReady() {
  $body.on('click', 'table#lessons-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-lessons').submit();
  });
  $body.on('click', 'table#elements-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-elements').submit();
  });
  $body.on('click', 'table#users-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-users').submit();
  });
  $body.on('click', 'table#tags-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-tags').submit();
  });
  $body.on('click', 'table#documents-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-documents').submit();
  });
  $body.on('click', 'table#purchases-list thead tr th a', function(e) {
    e.preventDefault();
    $('input#search_ordering').val($(this).data('ordering'));
    $('input#search_desc').val($(this).data('desc'));
    $('#admin-search-purchases').submit();
  });
}

/**
Initializes effects for User.
@method adminUsersDocumentReady
@for AdminDocumentReady
**/
function adminUsersDocumentReady() {
  $body.on('click', '._active_status', function(e) {
    e.preventDefault();
    var link = $(this);
    var status = true;
    if(link.hasClass('ban')) {
      status = false;
    }
    $.ajax({
      url: '/admin/users/' + link.data('param') + '/set_status?active=' + status,
      type: 'put'
    });
  });
}
