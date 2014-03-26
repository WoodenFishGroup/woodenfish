# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class PostList
  constructor: () ->
    @collapsed = false
    @animating = false
    @animate_timeout = 300

  callback_if_present: (cb) =>
    if (cb && typeof(cb) == 'function')
      cb()

  collapse: (cb) =>
    if (!@animating)
      @animating = true
      $(".post-body-content, .post-comment").hide(@animate_timeout).promise().done(() => 
        @animating = false
        @collapsed = true
        @callback_if_present(cb)
      )

  expand: (cb) =>
    if (!@animating)
      @animating = true
      $(".post-body-content, .post-comment").show(@animate_timeout).promise().done(() =>
        @animating = false
        @collapsed = false
        @callback_if_present(cb)
      )

  toggleCollapse: (cb) =>
    toggle_cb = false 
    if (cb && typeof(cb) == 'function')
      toggle_cb = () => cb(!@collapsed)
    if (@collapsed) 
      @expand(toggle_cb)
    else 
      @collapse(toggle_cb)

  togglePost: (post_id) =>
    node = $("#post-"+post_id).find(".post-body-content, .post-comment")
    if (node.data("hide") == true) 
      node.show(@animate_timeout).promise().done(() =>
        node.data("hide", false)
      )
    else
      node.hide(@animate_timeout).promise().done(() =>
        node.data("hide", true)
      )

(($) -> 
  $(() ->
    post_list = new PostList()

    $(".post .post-subject").click(() ->
      post_id = $(this).data("post-id")
      post_list.togglePost(post_id))

    buttons = $("#post-list-control-button .btn")
    buttons.click((event) ->
      $node = $(this)
      if (!$node.hasClass("active"))
        post_list[$node.data("action")](()->
          buttons.select(".active").add($node).toggleClass("active")
        )
    )
))(jQuery)
