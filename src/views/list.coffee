###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # ListView
#
# This is a generic collection list view. It renders individual models in a
# list using a list template and a list item template.
#
# This module is in UMD format and will create `ribcage.views.ListView`,
# `ribcage.viewMixins.ListView` and `ribcage.views.listView` globals if not
# used with an AMD loader such as RequireJS.
#
define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) ->
      (() ->
        switch dep
          when 'underscore' then root._
          when 'ribcage/views/template' then ribcage.views.templateView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory(require)
      ribcage.views.listView = module
      ribcage.views.ListView = module.View
      ribcage.viewMixins.ListView = module.mixin
)(this)

define (require) ->

  # This module depends on Underscore and `ribcage.views.TemplateView`
  #
  _ = require 'underscore'
  {View: TemplateView} = require 'ribcage/views/template'

  # ::TOC::
  #

  # ## `listViewMixin`
  #
  # This mixin implements the API for the `ListView`
  mixin: listViewMixin =
    # ### `#templateSource`
    #
    # Default list template. This template is a `<ul>` tag that contains all
    # list items.
    templateSource: "<ul><%= items.join('') %></ul>"

    # ### `#useRawModel`
    #
    # Whether to use raw model object instead of converting it to JSON. Default
    # is `false`.
    #
    useRawModel: false

    # ### `#itemTemplateSource`
    #
    # The template source for the list item. Each list item is rendered with
    # the item data as context (see [`#getItemData()`](#getitemdata-model) for
    # more information on how the context is calculated.
    itemTemplateSource: ''

    # ### `#itemTemplate(data)`
    #
    # This method takes item data and renders the `#itemTemplateSource`,
    # returning a HTML fragment for the list item.
    itemTemplate: (data) ->
      _.template @itemTemplateSource, data

    # ### `#getModels()`
    #
    # Returns the model items. By defualt this is `this.collection.models`.
    getModels: () ->
      @collection.models

    # ### `#getItemdata(model)`
    #
    # Takes a model and returns the data to be used as template context for
    # list item template. This is either pass-through or conversion of the
    # model to an object depending on [`#useRawModel`](#userawmodel) setting.
    #
    # Raw object will be named `item` in the context. Otherwise, model fields
    # will be added as context variables.
    getItemData: (model) ->
      if @useRawModel then {item: model} else model.toJSON()

    # ### `#getTemplateContext()`
    #
    # Returns the template context object containing a single `item` key which
    # is an array of rendered list items.
    getTemplateContext: () ->
      items: (@itemTemplate @getItemData(item) for item in @getModels())

  View: ListView = TemplateView.extend listViewMixin

