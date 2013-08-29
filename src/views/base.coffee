###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Base view
#
# This is the base view for all Ribcage views. Every new Ribcage view should
# extend this view, and any API that is common to all views should be
# implemented by this view.
#
# Currently this view offers no special API. It merely serves as a placeholder.
#
# This module is in UMD format and will create `ribcage.views.BaseView`,
# `ribcage.viewMixins.BaseView`, and `ribcage.views.baseView` globals if
# not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.baseView = factory @require
    @ribcage.views.BaseView = module.View
    @ribcage.viewMixins.BaseView = module.mixin

define (require) ->
  Backbone = require 'backbone'

  # ## `baseViewMixin`
  #
  # The base view mixin. This mixin contains all the APIs that will be mixed
  # into all Ribcage views.
  baseViewMixin = {}

  # ## `BaseView`
  #
  # The `BaseView` view. This view is extended by all Ribcage views.
  BaseView = Backbone.View.extend baseViewMixin

  mixin: baseViewMixin
  View: BaseView
