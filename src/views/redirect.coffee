###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Redirect View
#
# This view simply redirects to another location and provides hooks for
# executing code while doing so.
#
# This module is in UMD format and creates `ribcage.views.redirectView`,
# `ribcage.views.RedirectView` and `ribcage.viewMixins.RedirectView` globals if
# not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'ribcage/views/base' then @ribcage.views.baseView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@ribcage or= {}).views or= {}
    @ribcage.viewMixins or= {}
    @ribcage.views.redirectView = factory @require
    @ribcage.views.RedirectView = @ribcage.views.redirectView.View
    @ribcage.viewMixins.RedirectView = @ribcage.views.redirectView.mixin

define (require) ->
  baseView = require 'ribcage/views/base'

  # ## `redirectViewMixin`
  #
  # This mixin implements the API for the `RedirectView`.
  redirectViewMixin =
    # ### `redirectViewMixin.redirectPath`
    #
    # The redirect path.
    redirectPath: ''

    # ### `redirectViewMixin.getRedirectPath()`
    #
    # Returns the path to which view will redirect. By default, it returns the
    # value of `#redirectPath`.
    getRedirectPath: () ->
      @redirectPath

    # ### `redirectViewMixin.beforeRedirect()`
    #
    # Called before the redirect is performed. Has no arguments and return value
    # is not used.
    beforeRedirect: () ->
      this

    # ### `redirectViewMixin.redirect()`
    #
    # Performs the actual redirect. By default, it simply assigns to
    # `window.location.hash`.
    redirect: () ->
      @beforeRedirect()
      window.location.hash = @getRedirectPath()

    # ### `redirectViewMixin,render()`
    #
    # This overrides the default `#render()` method to immediately redirect.
    render: () ->
      @redirect()
      this

  # ## `RedirectView`
  #
  # Please see the documentation for the `redirectViewMixin` for more
  # information on the API that this view provides.
  RedirectView = Backbone.View.extend redirectViewMixin

  mixin: redirectViewMixin
  View: RedirectView
