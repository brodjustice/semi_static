//
// Draft Javascript for the Entry _form. Still relies on jQuery
//

var semi_static_entry = (function () {

  // This is a fied URL for system_path()
  const system_path = '/system';

  // semi_static_entry_side_bar checkbox
  var side_bar_cbox;

  // semi_static_entry_merge_with_previous checkbox
  var merge_cbox;

  // entry_partial input
  var partial_input;

  // entry_position_select
  var position_select;

  // Input that tags a Tag id
  var acts_as_tag_input;

  // Main HTML text area
  var entry_body;

  // Raw HTML checkbox
  var entry_raw_html;

  //
  // Start of local helper functions
  //
  function show(e, t){
    if(t == undefined){
      e.style.display = 'block';
    } else {
      e.style.display = t;
    }
  }
  function hide(e){
    e.style.display = 'none';
  }
  //
  // End of local helper functions
  //

  function convertToEditor(){
    var valuesToSubmit = $('form').serialize();
    $.ajax({
      type: "POST",
      url: $('form').attr('action') + '?convert=true',
      data: valuesToSubmit,
      dataType: "script"
    }).fail(function(jqXHR, textStatus, errorThrown){
      alert('Error: ' + errorThrown);
    });
    return false; // prevents normal behaviour
  }

  function enableEditor(){
    if (entry_raw_html && entry_raw_html.getAttribute('checked') != true) {
      CKEDITOR.replace('entry_body', {extraAllowedContent: 'b;i;strong (*); em (*)', format_tags: 'p;h2;h3;h4;h5;h6;pre;address;div'});
    } else {
      CKEDITOR.replace('entry_body', {allowedContent: true, format_tags: 'p;h2;h3;h4;h5;h6;pre;address;div'});
    }
    hide(document.getElementById('enable_editor'));
    hide(document.getElementById('convert_and_enable_editor'));
    document.getElementById('entry_simple_text').setAttribute('val', 'false');
    document.getElementById('entry_text_area').style.marginBottom = '6px';
  }

  function loadBannerPreview(banner_id){
    $.ajax({
      url: "/banners/" + banner_id,
      dataType: 'script'
    });
  }

  function checkTagLine(){
    if( document.getElementById('entry_banner_id').value == 'none') {
      hide(document.getElementById('tag_line_override'));
    } else {
      show(document.getElementById('tag_line_override'), 'flex');
    }
  }

  function checkSideBar(){
    if (side_bar_cbox.checked === true)
      show(document.getElementById('side_bar_options'));
    else
      hide(document.getElementById('side_bar_options'));
  }

  function checkComments(){
    if (document.getElementById('semi_static_entry_enable_comments').checked === true){
      show(document.getElementById('comment_strategy'));
    } else {
      hide(document.getElementById('comment_strategy'));
    }
  }

  function checkHeaderHtml(){
    if (merge_cbox.checked === true){
      hide(document.getElementById('headerHTML'));
    } else {
      show(document.getElementById('headerHTML'));
    }
  }

  function checkEntryPartial(){
    var params = {'cmd':{'partial_description': partial_input.value}}

    $.ajax({
      url: system_path,
      data: params,
      type: 'PUT',
      dataType: 'script'
    });
    if ( partial_input.value == 'none') {
      hide(position_select);
    } else {
      show(position_select, 'flex');
    }
  }

  function checkActsAsTag(){
    if(acts_as_tag_input.value == ''){
      entry_body.readOnly = false; 
      $('.sScontentSection').show();
    } else {
      entry_body.readOnly = true; 
      $('.sScontentSection').hide();
    }
  }

  // Show extra checkboxes is non-default image is loaded
  function checkImageControls(){
    if(document.querySelector('#semi_static_entry_image img').getAttribute('title') == 'Placeholder'){
      hide(document.getElementById('semi_static_entry_image_control'));
    } else {
      show(document.getElementById('semi_static_entry_image_control'));
    }
  }


  function initFormAndVars(){
    // Set vars
    side_bar_cbox = document.getElementById('semi_static_entry_side_bar');
    merge_cbox = document.getElementById('semi_static_entry_merge_with_previous');
    entry_body = document.getElementById('entry_body');
    entry_img = document.getElementById('entry_img');
    partial_input = document.getElementById('entry_partial');
    position_select = document.getElementById('entry_position_select');
    acts_as_tag_input = document.getElementById('entry_acts_as_tag_id');
    entry_raw_html = document.getElementById('entry_raw_html');
    entry_banner_id = document.getElementById('entry_banner_id');

    checkTagLine();

    // Watch for side_bar checkbox change
    side_bar_cbox.addEventListener('change', checkSideBar);
    checkSideBar();

    // Watch for comments checkbox change
    document.getElementById('semi_static_entry_enable_comments').addEventListener('change', checkComments);
    checkComments();

    // Enable editor button
    document.getElementById('enable_editor').addEventListener('click', enableEditor);

    // Convert to editor button
    document.getElementById('convert_and_enable_editor').addEventListener('click', convertToEditor);

    // Watch for merge checkbox change
    merge_cbox.addEventListener('change', checkHeaderHtml);
    checkHeaderHtml();

    // Watch acts as tag input
    acts_as_tag_input.addEventListener('change', checkActsAsTag);
    checkActsAsTag();
    
    const event = new Event('change');
    checkEntryPartial();
    partial_input.addEventListener('change', checkEntryPartial);
    partial_input.dispatchEvent(event);

    // Watch for banner selected and then load banner if required
    entry_banner_id.addEventListener('change', function(){
      checkTagLine();
      loadBannerPreview(this.value);
    }, false);
    checkTagLine();
    if(entry_banner_id.value != 'none'){
      loadBannerPreview(entry_banner_id.value);
    }

    // Entry image stuff
    checkImageControls();
    entry_img.onchange = semiStaticPrepareUploadFromInput;
    document.getElementById('semi_static_image_for_upload').onload = checkImageControls;

    // Should the editor be automatically enabled?
    if(($('#entry_simple_text').val() == 'false') && ($('#entry_raw_html').prop('checked') != true)){
      enableEditor();
    };
  }

  return {
    init: function() {
      initFormAndVars();
    },
    enable_editor: function(){
      enableEditor();
    },
    convert_to_editor: function(){
      convertToEditor();
    },
  }

})();

$(document).ready(semi_static_entry.init());
