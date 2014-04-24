$(document).on("page:load ready", function() {
    bindCallbackForPostComment($('.comments-form'));
    bindCtrlEnterForSubmit($('.comment-text-area'));
    $.getJSON("/api/users", function(allusers) {
        allusers.unshift({name: "All Users", username: "all"});
        $('.comment-text-area').mention({
            emptyQuery: true,
            delimiter: '@',
            users: allusers
        });
    })
});


var bindCallbackForPostComment = function(selector){
  selector.on('ajax:success', function(xhr, data, status) {
    var textarea = $(this).find('.comment-text-area');
    textarea.val("").attr("disabled", false);
    $.get(textarea.attr('post_comments_path'));
  })
};

var bindCtrlEnterForSubmit = function(selector){
  selector.on('keypress', function(event) {
    var node = $(this);
    if (event.which == 13 && event.ctrlKey) {
      $(this).closest('form').submit();
      node.attr("disabled", true);
    }
  });
};

