# # AJAX loder mixin
#
# This module implements a simple mixin that provides methods for displaying a
# spinning loader icon.
#
# This module is in UMD format and will create `Ribcage.views.loadingView`,
# `Ribcage.views.LoadingView`, and `Ribcage.viewMixins.LoadingView` if not used
# with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'jquery' then @$
        when 'underscore' then @_
        when 'ribcage/views/template' then @Ribcage.views.templateView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@Ribcage or= {}).views or= {}
    @Ribcage.viewMixins or= {}
    @Ribcage.views.loadingView = factory @require
    @Ribcage.views.LoadingView = @Ribcage.views.loadingView.View
    @Ribcage.viewMixins.LoadingView = @Ribcage.views.loadingView.mixin

define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  templateView = require 'ribcage/views/template'

  # ## `OVERLAY_FADE_SPEED`
  #
  # The overlay fade speed is controlled by this constant. It is set to 225ms.
  OVERLAY_FADE_SPEED = 225

  tLoader = _.template """
  <div class="loader-container">
    <div class="loader-spinner">
      <span class="loader-icon">
        <span class="icon-refresh icon-spin icon-2x"></span>
      </span>
      <span class="loader-label">loading</span>
    </div>
  </div>
  """

  # Set up the loader widget globally in the viewport
  $('body').append tLoader
  loader = $ 'div.loader-container'
  loaderSpinner = loader.find 'span.loader-icon'
  loaderLabel = loader.find 'span.loader-label'
  loader.hide()

  # ## `loadingMixin`
  #
  # This mixin implements the API for displaying and hiding the loader.
  loadingMixin =
    # ### `loadingMixin.loaderInitialized`
    #
    # Internal flag that tells the view if the loader has been initialized.
    #
    # Do not change the value of this property directly.
    loaderInitialized: false

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

    # ### `loadingMixin.initLoader()`
    #
    # If you've set your custom spinner and/or label, you must call this once
    # before showing the loader.
    initLoader: () ->
      return if @loaderInitialized
      if @spinner
        loaderSpinner.html @spinner
      if typeof @loadingLabel is 'function'
        label = @loadingLabel()
      else
        label = @loadingLabel
      if label
        loaderLabel.text label
      @loaderInitialized = true

    # ### `loadingMixin.showLoader()`
    #
    # Shows the loader
    showLoader: () =>
      loader.stop().fadeIn OVERLAY_FADE_SPEED

    # ### `loadingMixin.hideLoader()`
    #
    # Hides the loader.
    hideLoader: () =>
      loader.stop().fadeOut OVERLAY_FADE_SPEED

    # ### `loadingMixin.toggleLoader()`
    #
    # Toggles the loader.
    toggleLoader: () =>
      loader.stop().toggleFade OVERLAY_FADE_SPEED

  # ## `LoadingView`
  #
  # For details of this view's API, see the documentation for `loadingMixin`.
  LoadingView = templateView.View.extend _.extend {},
    loadingMixin,

  mixin: loadingMixin
  View: LoadingView
