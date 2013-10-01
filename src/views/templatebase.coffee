###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Template base view
#
# This is a simple view that doesn't do anything on its own. It merely provides
# a standard interface for handling an underscore template with context data.
#
# This module is in UMD format and will create
# `ribcage.views.TemplateBaseView`, `ribcage.viewMixins.TemplateBaseView`, and
# `ribcage.views.templateBaseView` globals if not used with an AMD loader such
# as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and define.amd
    root.define
  else
    require = (dep) ->
      (() ->
        switch dep
          when 'underscore' then root._
          when './base' then ribcage.views.baseView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory(require)
      ribcage.views.templateBaseView = module
      ribcage.views.TemplateBaseView = module.View
      ribcage.viewMixins.TemplateBaseView = module.mixin
)(this)


define (require) ->

  # This module depends on Underscore and `ribacage.views.BaseView`.
  #
  _ = require 'underscore'
  {View: BaseView} = require './base'

  # ::TOC::
  #

  # ## `templateBaseViewMixin`
  #
  # This mixin implements the API of the TemplateBaseView.
  #
  # In addition to providing the API for the somewhat useless TemplateBaseView,
  # this mixin is also used in many views that require template handlign such
  # as `ribcage.views.TemplateView` and `ribcage.views.ModalView`.
  #
  templateBaseViewMixin =
    # ### `#templateSettings`
    #
    # This property is passed in as template settings. The default value is
    # `null`. If the template function you are using (default is Underscore
    # template) takes extra settings, you can use this property to specify it.
    #
    templateSettings: null

    # ### `#templateSource`
    #
    # The template source to render. It provides a simple default for debugging
    # purposes.
    #
    templateSource: '<p>Please override me</p>'

    # ### `#template`
    #
    # Template to render. This method takes data and passes it to Underscore's
    # `#template()` method. The default implementation renders the
    # `#templateSource` property.
    #
    template: (data) ->
      _.template @templateSource, data, @templateSettings

    # ### `#getContext()`
    #
    # Returns template context data. Should return an object whose keys will be
    # used in the template's scope.
    #
    getTemplateContext: () ->
      {}

    # ### `#renderTemplate()`
    #
    # Render the template given a context.
    #
    renderTemplate: (context) ->
      @template context

  # ## `TemplateBaseView`
  #
  # Please see the documentation on
  # [`templateBaseViewMixin`](#templateviewmixin) for more information about
  # this view's API.
  #
  TemplateBaseView = BaseView.extend templateBaseViewMixin

  mixin: templateBaseViewMixin
  View: TemplateBaseView

