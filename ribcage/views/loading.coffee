# # AJAX loder mixin
#
# This module implements a simple view that provides methods for displaying a
# spinning loader icon. This view is best used as an omni-present view whose
# methods are triggered though events.
#
# This module is in UMD format and will create `ribcage.views.loadingView`,
# `ribcage.views.LoadingView`, and `ribcage.viewMixins.LoadingView` if not used
# with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'jquery' then @$
        when 'underscore' then @_
        when 'ribcage/views/base' then @ribcage.views.baseView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@ribcage or= {}).views or= {}
    @ribcage.viewMixins or= {}
    @ribcage.views.loadingView = factory @require
    @ribcage.views.LoadingView = @ribcage.views.loadingView.View
    @ribcage.viewMixins.LoadingView = @ribcage.views.loadingView.mixin

define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  baseView = require 'ribcage/views/base'

  # ## `OVERLAY_FADE_SPEED`
  #
  # The overlay fade speed is controlled by this constant. It is set to 225ms.
  OVERLAY_FADE_SPEED = 225

  tLoader = _.template """
  <div class="loader-spinner">
    <span class="loader-icon">
      <span class="icon-refresh icon-spin icon-2x"></span>
    </span>
    <span class="loader-label">loading</span>
  </div>
  """

  # ## `loadingMixin`
  #
  # This mixin implements the API for displaying and hiding the loader.
  loadingMixin =
    # ### `loadingMixin.spinner`
    #
    # Defines the HTML for the spinner. By default, it's a FontAewsome spinning
    # spinner icon. If you leave this property as `null`, it will retain the
    # default spinner.
    spinner: null

    # ### `loadingMixin.loadingLabel`
    #
    # Defines the text to use as the loading label. By default, it's
    # 'loading...'. Leave this as `null` to keep it. You can also set it to a
    # function which would be evaluated to obtain the label (e.g., if you need
    # i18n support.
    loadingLabel: null

    # ### `loadingMixin.initialize(options)`
    #
    # Sets `spinner` and `loadingLabel` properties from the same-named keys
    # passed in through the `options` argument.
    initialize: ({@spinner, @loadingLabel}) ->

    # ### `loadingMixin.render()`
    #
    # Renders the loader HTML and customizes the spinner and label, and hides
    # the loader.
    render: () ->
      @$el.append tLoader
      if @spinner
        @$el.find('.loader-spinner').html @spinner
      if typeof @loadingLabel is 'function'
        label = @loadingLabel()
      else
        label = @loadingLabel
      if label
        @$el.find('.loader-label').text label
      @$el.hide()
      this

    # ### `loadingMixin.showLoader()`
    #
    # Shows the loader
    showLoader: () ->
      @$el.stop().fadeIn OVERLAY_FADE_SPEED

    # ### `loadingMixin.hideLoader()`
    #
    # Hides the loader.
    hideLoader: () ->
      @$el.stop().fadeOut OVERLAY_FADE_SPEED

    # ### `loadingMixin.toggleLoader()`
    #
    # Toggles the loader.
    toggleLoader: () ->
      @$el.stop().toggleFade OVERLAY_FADE_SPEED

  # ## `LoadingView`
  #
  # For details of this view's API, see the documentation for `loadingMixin`.
  LoadingView = baseView.View.extend loadingMixin

  mixin: loadingMixin
  View: LoadingView
