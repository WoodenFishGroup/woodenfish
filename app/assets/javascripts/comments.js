$(document).on("page:load ready", function() {
	$('.comments-form').on('ajax:success', function(xhr, data, status) {
		var textarea = $(this).find('.comment-text-area');
		textarea.val("").attr("disabled", false);
		$.get(textarea.attr('post_comments_path'));
	})
	$('.comment-text-area').on('keypress', function(event) {
		var node = $(this);
		if (event.which == 13 && event.ctrlKey) {
			$(this).closest('form').submit();
			node.attr("disabled", true);
		}
	});
	$.getJSON("/api/users", function(allusers) {
			$('.comment-text-area').mention({
			delimiter: '@',
			users: allusers
		});
	})
});