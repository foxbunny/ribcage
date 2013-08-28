# # Model form view
#
# Extends the BaseFormView to add support for model handling. It updates the
# model automatically when form is updated, and also validates the model using
# the model's own `#validate()` method.
#
# This module is in UMD format and it will create
# `ribcage.views.modelFormView`, `ribcage.views.ModelFormView`, and
# `ribcage.viewMixins.modelFormViewMixin` globals if not used with an AMD
# loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'jquery' then @$
        when 'underscore' then @_
        when 'ribcage/views/form' then @ribcage.views.baseFormView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@ribcage or= {}).views or= {}
    @ribcage.viewMixins or= {}
    @ribcage.views.modelFormView = factory @require
    @ribcage.views.ModelFormView = @ribcage.views.modelFormView.View
    @ribcage.viewMixins.ModelFormView = @ribcage.views.modelFormView.mixin

define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  baseForm = require 'ribcage/views/form'

  # ## `modelFormViewMixin`
  #
  # This mixin implements the API for the `ModelFormView` view.
  modelFormViewMixin =

    # ### `modelFormViewMixin.validate()`
    #
    # Validates the model.
    #
    # The model's validate method should return an error object that conforms
    # to the `BaseFormView`'s error object format.
    #
    # The method should return and array in [errorObject, data] format.
    validate: () ->
      err = @model.validate @model.attributes
      [err, @model.toJSON()]

    # ### `modelFormViewMixin.events`
    #
    #
    events:
      'submit form': 'submit'
      'change :input': 'inputChange'
      'input :input': 'inputChange'

    # ### `modelFormViewMixin.inputChange(e)`
    #
    # Wrapper function to call the change and input events handlers for form
    # inputs on both this model and the `BaseFormView`.
    inputChange: (e) ->
      @onFieldChange(e)
      @updateModel(e)

    # ### `modelFormViewMixin.updateModel(e)`
    #
    # Update the model by setting serialized form data.
    updateModel: (e) ->
      # First also call the change event on the FormClass
      input = @$ e.target
      val = input.val()
      name = input.attr 'name'
      [err, cleaned] = @clean(name: val)
      return if err
      @model.set input.attr('name'), input.val()
      true

  # ## `ModelFormView`
  #
  # Please see the documentation for the `modelFormViewMixin` for more
  # information on the API that this view provides.
  ModelFormView = baseForm.View.extend modelFormViewMixin

  mixin: modelFormViewMixin
  View: ModelFormView
