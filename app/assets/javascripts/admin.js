/* Initable jquery vars */
var semi_static_file_name_input = null;

function semiStaticPrepareUploadFromInput(e){
  semiStaticPrepareSingleUpload(e.target.files);
}

function semiStaticPrepareSingleUpload(files){
  /* Only one file can be attached per input */
  if(!(semi_static_file_name_input == null) && !(semi_static_file_name_input.val().length > 0)){
    semi_static_file_name_input.val(files[0].name);
  };

  /* Display file */
  if (files && files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
      $('#semi_static_image_for_upload').attr('title', files[0].name);
      $('#semi_static_image_for_upload').attr('src', e.target.result);
    }
    reader.readAsDataURL(files[0]);
  }
  // file_for_upload = files[0];
}

$(document).ready(function() {
  $('.infomarker').click(function() {
    $(this).prev('.infobox').show();
  });
});

