###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # AJAX loder mixin
#
# This module implements a simple view that provides methods for displaying a
# spinning loader icon. This view is best used as an omni-present view whose
# methods are triggered though events (full-screen spinner).
#
# This module is in UMD format and will create `ribcage.views.loadingView`,
# `ribcage.views.LoadingView`, and `ribcage.viewMixins.LoadingView` if not used
# with an AMD loader such as RequireJS.
#

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
    module = @ribcage.views.loadingView = factory @require
    @ribcage.views.LoadingView = module.View
    @ribcage.viewMixins.LoadingView = module.mixin

define (require) ->

  # This module depends on jQuery, Underscore, and `ribcage.views.baseView`.
  #
  $ = require 'jquery'
  _ = require 'underscore'
  baseView = require 'ribcage/views/base'

  # ::TOC::
  #

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
  #
  # The general idea is to set up the view once during application's
  # initialization, and then toggle the loader on and off as needed.
  #
  # The view currently does not implement any custom events or listeners, so if
  # you want to toggle the loader using events, you will have to add the
  # functionality yourself. Events will be added in a later version, but
  # weren't needed thus far, so they are a low-priority target.
  #
  loadingMixin =

    # ## `#fadeTime``
    #
    # The overlay fade speed is controlled by this constant. It is set to
    # 225ms by default.
    #
    fadeTime: 225

    # ### `#spinner`
    #
    # Defines the HTML for the spinner. By default, it's a FontAewsome spinning
    # spinner icon. If you leave this property as `null`, it will retain the
    # default spinner.
    #
    spinner: null

    # ### `#loadingLabel`
    #
    # Defines the text to use as the loading label. By default, it's
    # 'loading...'. Leave this as `null` to keep it. You can also set it to a
    # function which would be evaluated to obtain the label (e.g., if you need
    # i18n support.
    #
    loadingLabel: null

    # ### `#initialize(settings)`
    #
    # Sets `spinner` and `loadingLabel` properties from the same-named keys
    # passed in through the `settings` argument.
    #
    initialize: ({@spinner, @loadingLabel}) ->

    # ### `#render()`
    #
    # Renders the loader HTML and customizes the spinner and label, and hides
    # the loader.
    #
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

    # ### `#showLoader()`
    #
    # Shows the loader
    #
    showLoader: () ->
      @$el.stop().fadeIn @fadeTime

    # ### `#hideLoader()`
    #
    # Hides the loader.
    #
    hideLoader: () ->
      @$el.stop().fadeOut @fadeTime

    # ### `#toggleLoader()`
    #
    # Toggles the loader.
    #
    toggleLoader: () ->
      @$el.stop().toggleFade @fadeTime

  # ## `LoadingView`
  #
  # For details of this view's API, see the documentation for
  # [`loadingMixin`](#loadingmixin).
  #
  LoadingView = baseView.View.extend loadingMixin

  mixin: loadingMixin
  View: LoadingView
