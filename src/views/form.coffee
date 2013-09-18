###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Base form view
#
# This view provides the basic form-handling functionality. It handles the
# form's submit method, and provides hooks for validation and error display.
#
# This module is in UMD format and will create `ribcage.views.baseFormView`,
# `ribcage.views.BaseFormView`, and `ribcage.viewMixins.BaseFormView` globals
# if not used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'dahelpers' then @dahelpers
        when './formerror' then @ribcage.views.formErrorView
        when './formextra' then @ribcage.views.formExtraView
        when '../utils/searializeobject' then @ribcage.utils.serializeObject
        when '../utils/deserializeform' then @ribcage.utils.deserializeForm
        when '../validation/mixins' then @ribcage.validation.mixins
        when './template' then @ribcage.views.templateView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.baseFormView = factory @require
    @ribcage.views.BaseFormView = module.View
    @ribcage.viewMixins.BaseFormView = module.mixin

define (require) ->

  # This module depends on jQuery, DaHelpers, `ribcage.utils.serializeobject`,
  # `ribcage.utils.deserializeform`, `ribcage.validators.mixins`, and
  # `ribcage.views.TemplateView`.
  #
  {extend} = require 'dahelpers'
  serializeObject = require '../utils/serializeobject'
  deserializeForm = require '../utils/deserializeform'
  {validatingMixin} = require '../validators/mixins'
  {mixin: formErrorMixin} = require './formerror'
  {mixin: formExtraMixin} = require './formextra'
  {View: TemplateView} = require './template'

  # ::TOC::
  #

  # ## `baseFormViewMixin`
  #
  # This mixin implements the [`BaseFormView`](#baseformview) view's API. It
  # mixes in the `validatingMixin` to provide input validation facilities.
  #
  baseFormViewMixin = extend {},
    validatingMixin,
    formErrorMixin,
    formExtraMixin,

    # ### `#validateOnInput`
    #
    # Whether to perform validation immediately on field change. Defaults to
    # `false`.
    #
    validateOnInput: false

    # ### `#__form`
    #
    # Holds cached jQuery selector for the form.
    #
    # This is an internal implementation detail. Do not rely on presence or
    # internal usage of this property.
    #
    __form: null

    # ### `#getForm()`
    #
    # Returns the form element rendered in this view
    #
    getForm: () ->
      @__form or= @$ 'form'

    # ### `#getFormData()`
    #
    # Serializes a form to a JavaScript object and returns the object.
    #
    getFormData: () ->
      serializeObject @getForm()

    # ### `#setFormData(data)`
    #
    # Deserializes `data` object into the form.
    #
    setFormData: (data) ->
      deserializeForm @getForm(), data

    # ### `#validateForm(form)`
    #
    # Perform validation on the form and return an array containing the error
    # object and form data.
    #
    # The error object is expected to map field names to an array of error
    # messages. A special `__all` key can be used to specify messages that
    # apply to the entire form.
    #
    # Internally, this method calls the `#clean()` method, which is part of the
    # `validatingMixin` mixin and passes it the serialized form data.
    #
    validate: () ->
      @clean @getFormData()

    # ### `#fieldInvalid(input, errors)`
    #
    # Called when field fails validation. By default, it inserts error messages
    # next to fields.
    #
    fieldInvalid: (input, errors) ->
      @clearFieldErrors input
      @insertErrorMessage input, errors

    # ### `#validateField(input, name, value, data)`
    #
    # Validates a single field in a `change` or `input` callback (as the field)
    # value is updated. It calls the `validatingMixin`'s `#applyValidators()`
    # method, and then the `#fieldInvalid()` method if field has errors.
    #
    validateField: (input, name, value, data) ->
      [errors, value] = @applyValidators name, value
      if errors.length
        @fieldInvalid(input, name, value, errors)

    # ### `#formInvalid(err)`
    #
    # Handles the invalid form submission. By default, it simply renders the
    # form errors.
    #
    formInvalid: (err) ->
      @insertErrorMessages @getForm(), err

    # ### `#formValid(form, data)`
    #
    # Handles the valid form submission. Does nothing by default.
    #
    # You need to overload this method to make this entire view useful.
    #
    formValid: (data) ->
      return

    # ### `#beforeSubmit()`
    #
    # Called before form is submitted. Has no arguments, and return value is
    # not used by the view.
    #
    beforeSubmit: () ->
      @disableButtons @getForm()

    # ### `#afterSubmit()`
    #
    # Called after either [`#formValid()`](#formvalid-data) or
    # [`#formInvalid()`](#forminvalid-err) have returned.  Has no arguments,
    # and return value is not used.
    #
    # This function is called at the end of the [`#submit()`](#submit-e) call.
    # This is by no means a guarantee that any asynchronous operations in the
    # callback have finished. For example, if you are doing an AJAX request in
    # [`#formValid()`](#formvalid-data), this method will likely be invoked
    # well before the AJAX request has completed.
    #
    afterSubmit: () ->
      @enableButtons @getForm()

    # ### `#events`
    #
    # Event mappings.
    #
    events:
      'submit form': 'submit'
      'change :input': 'onFieldChange'
      'input :input': 'onFieldChange'

    # ### `#submit(e)`
    #
    # Form submit event handler.
    #
    # This is an internal implementation detail, and you generally should not
    # override this.
    #
    submit: (e) ->
      e.preventDefault()
      @clearErrors @getForm()
      @beforeSubmit()
      [err, data] = @validate()
      if err
        @formInvalid err, data
      else
        @formValid data
      @afterSubmit()
      false

    # ### `#onFieldChange(e)`
    #
    # Form input change event handler.
    #
    # This is an internal implementation detail, and you generally should not
    # override this.
    #
    onFieldChange: (e) ->
      return true if not @validateOnInput
      input = @$ e.target
      name = input.attr 'name'
      value = input.val()
      if input.attr('type') is 'checkbox'
        value = input.prop 'checked'
      formData = @getFormData()
      @validateField input, name, value, formData
      true

  # ## `BaseFormView`
  #
  # Please see the documentation for the
  # [`baseFormViewMixin`](#baseformviewmixin) for more
  # information on the API that this view provides.
  #
  BaseFormView = TemplateView.extend baseFormViewMixin


  mixin: baseFormViewMixin
  View: BaseFormView
