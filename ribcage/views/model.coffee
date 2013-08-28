# # Model view
#
# This module implements a view for rendering a single module using the
# template view.
#
# This module is in UMD format and creates `Ribcage.views.modelView`,
# `Ribcage.view.ModelView` and `Ribcage.viewMixins.ModelView` globals if not
# used with an AMD loader such as RequireJS

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'ribcage/views/template' then @Ribcage.views.templateView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@Ribcage or= {}).views or= {}
    @Ribcage.viewMixins or= {}
    @Ribcage.views.modelView = factory @require
    @Ribcage.views.ModelView = @Ribcage.views.modelView.View
    @Ribcage.viewMixins.ModelView = @Ribcage.views.modelView.mixin

define (require) ->
  templateView = require 'ribcage/views/template'

  # ## `modelViewMixin`
  #
  # This mixin implements the API for the `ModelView`.
  modelViewMixin =

    # ### `modelViewMixin.getTemplateContext()`
    #
    # Adds the model attributes to template context.
    getTemplateContext: () ->
      @model.toJSON()

  # ## `ModelView`
  #
  # Please see the documentation for the `modelViewMixin` for more
  # information on the API that this view provides.
  ModelView = templateView.View.extend modelViewMixin

  mixin: modelViewMixin
  View: ModelView
