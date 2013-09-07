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
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when './base' then @ribcage.views.baseView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.redirectView = factory @require
    @ribcage.views.RedirectView = module.View
    @ribcage.viewMixins.RedirectView = module.mixin

define (require) ->

  # This module depends on `ribcage.views.BaseView`
  #
  baseView = require './base'

  # ::TOC::
  #

  # ## `redirectViewMixin`
  #
  # This mixin implements the API for the `RedirectView`.
  #
  redirectViewMixin =
    # ### `#redirectPath`
    #
    # The redirect path. Default value is an empty string, which will cause a
    # redirect to '#' fragment identifier.
    #
    redirectPath: ''

    # ### `#getRedirectPath()`
    #
    # Returns the path to which view will redirect. By default, it returns the
    # value of [`#redirectPath`](#redirectpath).
    #
    getRedirectPath: () ->
      @redirectPath

    # ### `#beforeRedirect()`
    #
    # Called before the redirect is performed. Has no arguments and return value
    # is not used.
    #
    beforeRedirect: () ->
      this

    # ### `#redirect()`
    #
    # Performs the actual redirect. By default, it simply assigns to
    # `window.location.hash`.
    #
    redirect: () ->
      @beforeRedirect()
      window.location.hash = @getRedirectPath()

    # ### `redirectViewMixin,render()`
    #
    # This overrides the default `#render()` method to immediately redirect.
    #
    render: () ->
      @redirect()
      this

  # ## `RedirectView`
  #
  # Please see the documentation for the
  # [`redirectViewMixin`](#redirectviewmixin) for more information on the API
  # this view provides.
  #
  RedirectView = Backbone.View.extend redirectViewMixin

  mixin: redirectViewMixin
  View: RedirectView
