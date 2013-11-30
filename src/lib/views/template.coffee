###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Template view
#
# This module implements the template view. It extends the `TemplateBaseView`
# to make the view actually render the template and also provides post- and
# pre-render hooks.
#
# This module is in UMD module and creates `ribcage.views.templateView`,
# `ribcage.views.TemplateView`, `ribcage.viewMixins.TemplateView` if not used
# with an AMD module loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and define.amd
    root.define
  else
    require = (dep) ->
      (() ->
        switch dep
          when './templatebase' then root.ribcage.views.templateBaseView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory(require)
      ribcage.views.templateView = module
      ribcage.views.TemplateView = module.View
      ribcage.viewMixins.TemplateView = module.mixin
)(this)


define (require) ->

  # This module depends on Underscore and `ribcage.views.BaseView`.
  #
  {View: TemplateBaseView} = require './templatebase'

  # ::TOC::
  #

  # ## `templateViewMixin`
  #
  # This mixin implements the API for the `TemplateView`.
  #
  templateViewMixin =
    # ### `#beforeRender()`
    #
    # Called before render performs its magic. Does nothing by default.
    #
    beforeRender: () ->
      this

    # ### `#afterRender()`
    #
    # Called after rendering is finished. Does nothing by default.
    #
    afterRender: (context) ->
      this

    # ### `#insertTemplate()`
    #
    # Insert rendered template to DOM.
    #
    insertTemplate: (html) ->
      @$el.html html

    # ### `#render()`
    #
    # Calls the pre- and post-rendering hooks, compiles the template, and
    # attaches it to the DOM tree.
    #
    render: () ->
      @beforeRender()
      context = @getTemplateContext()
      @insertTemplate @renderTemplate context
      @afterRender context
      @

  # ## `TemplateView`
  #
  # Please see the documentation for the
  # [`templateViewMixin`](#templateviewmixin) for more information on the API
  # that this view provides.
  #
  TemplateView = TemplateBaseView.extend templateViewMixin

  mixin: templateViewMixin
  View: TemplateView
