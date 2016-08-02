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