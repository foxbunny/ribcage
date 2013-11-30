###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Collection create view
#
# This is an extension of the `CreateView` that uses a collection to create a
# new model, rather than saving a model object.
#
# This module is in UMD format and will create
# `ribcage.views.collectionCrateView`, `ribcage.views.CollectionCreateView`,
# and `ribcage.viewMixins.CollectionCreateView` globals if not used with an AMD
# loader such as RequrieJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'ribcage/views/create' then root.ribcage.views.createView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.views.collectionCreateView = module
      root.ribcage.views.CollectionCreateView = module.View
      root.ribcage.viewMixins.CollectionCreateView = module.mixin
) this

define (require) ->

  # This module depends on `ribcage.views.CreateView`.
  #
  {View: CreateView} = require 'ribcage/views/create'

  # ::TOC::
  #

  # ## `collectionCreateViewMixin`
  #
  # This mixin implements the API of the
  # [`CollectionCreateView`](#collectioncreateview).
  #
  # It will perform validation using model's `#validate()` method and will
  # crate the model using collection's `#create()` shortcut method.
  #
  collectionCreateViewMixin =

    # ### `#validate()`
    #
    # Validates the form data using the model stored in `this.model` property.
    #
    validate: () ->
      data = @getFormData()
      err = @model::validate data
      [err, data]

    # ### `#initialize(settings)`
    #
    # The settings may contain a `model` key which will be used as the model
    # constructor. The constructor will not be used to instantiate a new model
    # object, but will still be used to validate the form data. This setting is
    # not required if collection has a `model` attribute which points to a
    # valid model constructor.
    #
    # If this setting is specified, and the collection does not have a `model`
    # attribute, the specified setting will be assigned to the collection's
    # attribute.
    #
    # If neither collection's `model` attribute nor the `model` setting are
    # defined, an exception will be thrown.
    #
    initialize: ({@model}) ->
      ## The below or= may seem a bit weird, but it's there so we have either
      ## of them assigned to the other one, whichever happens to be defined.
      @model or= @collection.model
      @collection.model or= @model

      ## We can't have this view without a model
      if not @model
        throw new Error "No model associated with collection or view"
      return

    # ### `#getModelData(data)`
    #
    # Returns the attributes that will be used to create the model. This
    # method can be used to clean the data before it is finally passed to
    # collection's `#create()` method. Note that no validation will be
    # performed on the data that is returned from this method. It is assumed
    # that the validation performed on the form data is enough.
    #
    # Default implementation of this method simply returns the input.
    #
    getModelData: (data) ->
      data

    # ### `#formValid(data)`
    #
    # Crates the model by calling the collection's `#create()`.
    #
    formValid: (data) ->
      @collection.create @getModelData(data),
        success: (args...) =>
          @afterRequest()
          @onSaveSuccess args...
        error: (args...) =>
          @afterRequest()
          @onSaveError args...
        wait: true
        validate: false # Already validated

    # ### `#inputChange(e)`
    #
    # Overloads the `ModelView`'s `#inputChange()` handler and removes the
    # model update hoook. Since this view is not tied to a model instance,
    # there is no need to update the model on input change.
    #
    inputChange: (e) ->
      @onFieldChange(e)

  # ## `CollectionCreateView`
  #
  # Please see the documentation on
  # [`collectionCreateViewMixin`](#collectioncreateviewmixin) for more
  # information about this view's API.
  #
  CollectionCreateView = CreateView.extend collectionCreateViewMixin

  mixin: collectionCreateViewMixin
  View: CollectionCreateView
