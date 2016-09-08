// Admin page script to hide/show left/right brain posts and change the create form respectively.
$('.admin-container').ready(function(){
	var feeds = $('.left-feed-container, .right-feed-container');
	var formGroups = $('.form-group');
	$(feeds[0]).show();
	$('input[type=radio]').change(function(){
		if (this.checked && this.id === 'option1'){
			$('#brain-creation-header').text('LeftBrain Creation');
			$('form').attr('action', 'leftbrain/create');
			$(formGroups[1]).children().first().text('LeftBrain Title:');
			$(formGroups[2]).children().first().text('LeftBrain Body:');
			$(feeds[0]).show();
			$(feeds[1]).hide();
		}
		else if (this.checked && this.id === 'option2') {
			$('#brain-creation-header').text('RightBrain Creation');
			// change action destination
			$('form').attr('action', 'rightbrain/create');
			// change form title and body fields
			$(formGroups[1]).children().first().text('RightBrain Title:');
			$(formGroups[2]).children().first().text('RightBrain Body:');

			$(feeds[1]).show();
			$(feeds[0]).hide();
		}
	});
});

// File upload handling:
$(function() {
  $('.directUpload').find("input:file").each(function(i, elem) {
    var fileInput    = $(elem);
    var form         = $(fileInput.parents('form:first'));
    var submitButton = form.find('input[type="submit"]');
    var progressBar  = $("<div class='progress-bar'></div>");
    var barContainer = $("<div class='progress'></div>").append(progressBar);
    barContainer.hide();
    fileInput.after(barContainer);
    // ^^ iterates through all files and creates a progress bar for each.

    //Need to parse JSON because fileUpload expects an object!!! Below:

    var formdata = JSON.parse( $("input[name='form-data']").attr('value'));

    fileInput.fileupload({
      formData:        formdata,

      fileInput:       fileInput,

      url:             $("input[name='fileurl']").attr('value'),

      type:            'POST',

      autoUpload:       true,

      paramName:        'file', // S3 does not like nested name fields i.e. name="user[avatar_url]"

      dataType:         'XML',  // S3 returns XML if success_action_status is set to 201

      replaceFileInput: false,

      //progress bar and submission functionality below:
      progressall: function (e, data) {
        var progress = parseInt(data.loaded / data.total * 100, 10);
        progressBar.css('width', progress + '%')
      },

      start: function (e) {
        submitButton.prop('disabled', true);
        barContainer.show();
        progressBar.
          toggleClass('progress-bar-info').
          css('display', 'block').
          css('width', '0%').
          text("Loading...");
      },

      done: function(e, data) {
        submitButton.prop('disabled', false);
        progressBar.text("Uploading done");
        progressBar.toggleClass('progress-bar-info').toggleClass('progress-bar-success');

        // extract key and generate URL from response
        var key   = $(data.jqXHR.responseXML).find("Key").text();
        var url   = '//' + $("input[name='host']").attr('value') + '/' + key;

        // create hidden field
        var input = $("<input />", { type:'hidden', name: fileInput.attr('name'), value: url })
        form.append(input);
      },

      fail: function(e, data) {
        submitButton.prop('disabled', false);

        progressBar.toggleClass('progress-bar-info').
          toggleClass('progress-bar-danger').
          text("Failed");
      }
    });
  });
});







$().ready(function(){
  $('img').each(function() {
    var src = this.src;
    if (!this.complete || typeof this.naturalWidth == "undefined" || this.naturalWidth == 0) {
      // image was broken, replace with your new image
      $(this).before("<br>").before(
        "<a href='" + src + "'<h2 class='f'>" + src + "</h2></a><br><div class='file'><span class='glyphicon glyphicon-file'></span></div>"
      );
      var name = $('.f').text().split('/').pop();
      $('.f').text(name);
      $(this).remove();
    }
  });
});












