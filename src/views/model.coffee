###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Model view
#
# This module implements a view for rendering a single module using the
# template view.
#
# This module is in UMD format and creates `ribcage.views.modelView`,
# `ribcage.view.ModelView` and `ribcage.viewMixins.ModelView` globals if not
# used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when './template' then @ribcage.views.templateView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.modelView = factory @require
    @ribcage.views.ModelView = module.View
    @ribcage.viewMixins.ModelView = module.mixin

define (require) ->

  # This module depends on `ribcage.views.TemplateView`.
  #
  templateView = require './template'

  # ::TOC::
  #

  # ## `modelViewMixin`
  #
  # This mixin implements the API for the `ModelView`.
  #
  # The view is almost identical to `TemplateView`, except that it adds the
  # model to the template context.
  #
  modelViewMixin =

    # ### `#getTemplateContext()`
    #
    # Adds the model attributes to template context.
    #
    getTemplateContext: () ->
      @model.toJSON()

  # ## `ModelView`
  #
  # Please see the documentation for the `modelViewMixin` for more
  # information on the API that this view provides.
  #
  ModelView = templateView.View.extend modelViewMixin

  mixin: modelViewMixin
  View: ModelView
