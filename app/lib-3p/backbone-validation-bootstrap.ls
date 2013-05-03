# https://gist.github.com/driehle/2909552
_.extend Backbone.Validation.callbacks,
  valid: (view, attr, selector) ->
    control = view.$('[' + selector + '=' + attr + ']')
    group = control.parents(".control-group")
    group.removeClass("error")

    if control.data("error-style") == "tooltip"
      # CAUTION: calling tooltip("hide") on an uninitialized tooltip
      # causes bootstraps tooltips to crash somehow...
      control.tooltip "hide" if control.data("tooltip")
    else if control.data("error-style") == "inline"
      group.find(".help-inline.error-message").remove()
    else
      group.find(".help-block.error-message").remove()

  invalid: (view, attr, error, selector) ->
    control = view.$('[' + selector + '=' + attr + ']')
    group = control.parents(".control-group")
    group.addClass("error")

    if control.data("error-style") == "tooltip"
      position = control.data("tooltip-position") || "right"
      control.tooltip do
        placement: position
        trigger: "manual"
        title: error
      control.tooltip "show"
    else if control.data("error-style") == "inline"
      if group.find(".help-inline.error-message").length == 0
        group.find(".controls").append("<span class=\"help-inline error-message\"></span>")
      target = group.find(".help-inline.error-message")
      target.text(error)
    else
      if group.find(".help-block.error-message").length == 0
        group.find(".controls").append("<p class=\"help-block error-message\"></p>")
      target = group.find(".help-block.error-message")
      target.text(error)
