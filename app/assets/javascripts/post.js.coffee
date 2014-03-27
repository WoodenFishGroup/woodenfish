# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# TODO CJ: this code style is not good!!!
class PostList
  constructor: () ->
    @collapsed = false
    @animating = false
    @animate_timeout = 300
    @cookie_key = "_wf_post_view"
    @cookie_expire = 365 # 1 year

  callbackIfPresent: (cb) =>
    if (cb && typeof(cb) == 'function')
      cb()

  setConfigToCookie: () =>
    if (@collapsed) 
      $.cookie(@cookie_key, "c", {expires: @cookie_expire})
    else
      $.cookie(@cookie_key, "e", {expires: @cookie_expire})

  # return true if the config is "collapsed"
  getConfigFromCookie: () =>
    $.cookie(@cookie_key) == "c"


  collapse: (cb) =>
    if (!@animating)
      @animating = true
      $(".post-body-content, .post-comment").hide(@animate_timeout, () ->
        $(this).data("hide", true)
      ).promise().done(() => 
        @animating = false
        @collapsed = true
        @setConfigToCookie()
        @callbackIfPresent(cb)
      )

  expand: (cb) =>
    if (!@animating)
      @animating = true
      $(".post-body-content, .post-comment").show(@animate_timeout, () ->
        $(this).data("hide", false)
      ).promise().done(() =>
        @animating = false
        @collapsed = false
        @setConfigToCookie()
        @callbackIfPresent(cb)
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
  $(document).on("page:load ready", () ->
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
    
    if (post_list.getConfigFromCookie())
      buttons.select("[data-action=collapse]").click()

))(jQuery)
