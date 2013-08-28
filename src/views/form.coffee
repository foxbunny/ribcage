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

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'jquery' then @$
        when 'underscore' then @_
        when '../utils/searializeobject' then @ribcage.utils.serializeObject
        when '../utils/deserializeform' then @ribcage.utils.deserializeForm
        when '../validation/mixins' then @ribcage.validation.mixins
        when './base' then @ribcage.views.baseView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@ribcage or= {}).views or= {}
    @ribcage.viewMixins or= {}
    @ribcage.views.createView = factory @require
    @ribcage.views.CreateView = @ribcage.views.createView.View
    @ribcage.viewMixins.CreateView = @ribcage.views.createView.mixin

define (require) ->
  $ = require 'jquery'
  _ = require 'underscore'
  serializeObject = require '../utils/serializeobject'
  deserializeForm = require '../utils/deserializeform'
  validationMixins = require '../validators/mixins'
  baseView = require './base'

  # ## `baseFormViewMixin`
  #
  # This mixin implements the `BaseFormView` view's API. It mixes in the
  # `validatingMixin` to provide input validation facilities.
  baseFormViewMixin = _.extend {}, validationMixins.validatingMixin,

    # ### `baseFormViewMixin.errorClass`
    #
    # This is a HTML class added to all form and field errors displayed in the
    # form.
    errorClass: 'error'

    # ### `baseFormViewMixin.formErrorClass`
    #
    # This is a HTML class that is added to all form errors.
    formErrorClass: 'error-form'

    # ### `baseFormViewMixin.fieldErrorClass`
    #
    # This is a HTML class added to all field errors.
    fieldErrorClass: 'error-field'

    # ### `baseFormViewMixin.inputErrorClass`
    #
    # This is a HTML class added to individual inputs that have errors.
    inputErrorClass: 'error-input'

    # ### `baseFormViewMixin.validateOnInput`
    #
    # Whether to perform validation immediately on field change. Defaults to
    # `false`.
    validateOnInput: false

    # ### `baseFormViewMixin.__form`
    #
    # Holds cached jQuery selector for the form.
    #
    # This is an internal implementation detail. Do not rely on presence or
    # internal usage of this property.
    __form: null

    # ### `baseFormViewMixin.getForm()
    #
    # Returns the form element rendered in this view
    getForm: () ->
      @__form or= @$ 'form'

    # ### `baseFormViewMixin.getFormData()`
    #
    # Serializes a form to a JavaScript object and returns the object.
    getFormData: () ->
      serializeObject @getForm()

    # ### `baseFormViewMixin.setFormData(data)`
    #
    # Deserializes `data` object into the form.
    setFormData: (data) ->
      deserializeForm @getForm(), data

    # ### `baseFormViewMixin.validateForm(form)`
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
    validate: () ->
      @clean @getFormData()

    # ### `baseFormViewMixin.fieldInvalid(input, errors)`
    #
    # Called when field fails validation. By default, it inserts error messages
    # next to fields.
    fieldInvalid: (input, errors) ->
      @clearFieldErrors input
      @insertErrorMessage input, errors

    # ### `baseFormViewMixin.validateField(input, name, value, data)`
    #
    # Validates a single field in a `change` or `input` callback (as the field)
    # value is updated. It calls the `validatingMixin`'s `#applyValidators()`
    # method, and then the `#fieldInvalid()` method if field has errors.
    validateField: (input, name, value, data) ->
      [errors, value] = @applyValidators name, value
      if errors.length
        @fieldInvalid(input, name, value, errors)

    # ### `baseFormViewMixin.errorMessage(data)`
    #
    # Generates HTML to be inserted as error message. The `data` argument should
    # be an object with three keys: `id`, `msg`, and `cls`. The `id` and `cls`
    # keys are optional, and will default to `null` and 'error' respectively.
    # The `msg` key is optional, too, but will be left `undefined` if you do not
    # provide it, and will show up as 'undefined' in the final HTML.
    #
    # The reason we use an object as the argument is to make the method
    # compatible with compiled Underscore.js templates. Naturally, you can
    # override this method with an actual template if you prefer. Keep in mind
    # that the default will no longer be used if you do so, unless you've
    # specified defaults in your template.
    errorMessage: ({id, msg, cls}) ->
      cls or= 'error'
      s = '<span'
      s += " id=\"#{id}\"" if id?
      s + " class=\"#{cls}\">#{msg}</span>"

    # ### `baseFormViewMixin.clearErrors()`
    #
    # Remove all errors from the form. It is assumed that all error messages
    # have a wrapper element wit the class matching `this.errorClass`.
    #
    # It also removes the error class from inputs.
    clearErrors: () ->
      form = @getForm()
      form.find(".#{@errorClass}").remove()
      form.find(".#{@inputErrorClass}").removeClass @inputErrorClass
      form

    # ### `baseFormViewMixin.clearFieldErrors(input)`
    #
    # Removes all errors that are siblings of a given input. This doesn't work
    # if all inputs and all errors are siblings. Please be sure to add
    # appropriate strucutre to your form.
    cleanFieldErrors: (input) ->
      input = $ input
      input.siblings(".#{errorClass}").remove()

    # ### `baseFormViewMixin.insertErrorMessage(input, [msgs])`
    #
    # Insert a list of error messages after the specified input. The `msgs`
    # argument is optional, and defaults to ['Invalid value']. Otherwise, it
    # should be an array of error messages for the field.
    #
    # The `msgs` argument can also be a single string.
    insertErrorMessage: (input, msgs=['Invalid value']) ->
      msgs = [msgs] if not _.isArray msgs
      input = $ input

      # We need to iterate the reversed array because each message is rendered
      # right below the input, and therefore ends up at the top.
      for msg in msgs.reverse()
        input.after @errorMessage
          msg: msg
          cls: "#{@fieldErrorClass} #{@errorClass}"

        input.addClass @inputErrorClass

    # ### `baseFormViewMixin.insertFormErrors(msgs)`
    #
    # Insert a list of error messages after the specified input.
    #
    # `msgs` is required, and should be an array of messages. If it is not an
    # array, it will be converted to one.
    insertFormErrors: (msgs) ->
      msgs = [msgs] if not _.isArray msgs
      form = @getForm()

      # We need to iterate the reversed array because each message is rendered
      # right at the top of the form.
      for msg in msgs.reverse()
        form.prepend @errorMessage
          msg: msg
          cls: "#{@formErrorClass} #{@errorClass}"

    # ### `baseFormViewMixin.insertErrorMessages(err)`
    #
    # Takes an object with error messages for the given form, and renders them
    # next to the fields.
    #
    # The `err` object is expected to map field names to an array of error
    # messages. A special `__all` key can be used to specify messages that
    # apply to the entire form.
    insertErrorMessages: (err) ->
      form = @getForm()

      @clearErrors()

      return if not err?

      if err.__all
        @insertFormErrors err.__all

      form.find(':input').each (idx, el) =>
        input = $ el
        name = input.attr 'name'
        if err[name]
          @insertErrorMessage input, err[name]

      this # return this for chaining

    # ### `baseFormViewMixin.formInvalid(err)`
    #
    # Handles the invalid form submission. By default, it simply renders the
    # form errors.
    formInvalid: (err) ->
      @insertErrorMessages err

    # ### `baseFormViewMixin.formValid(form, data)`
    #
    # Handles the valid form submission. Does nothing by default.
    #
    # You need to overload this method to make this entire view userful.
    formValid: (data) ->
      return

    # ### `baseFormViewMixin.disableButtons()`
    #
    # Disables form buttons (both button and input elements of type 'submit').
    disableButtons: () ->
      @$('button[type=submit]').prop 'disabled', true
      @$('input[type=submit]').prop 'disabled', true

    # ### `baseFormViewMixin.enableButtons()`
    #
    # Enables form buttons (both button and input elements of type 'submit').
    enableButtons: () ->
      @$('button[type=submit]').prop 'disabled', false
      @$('input[type=submit]').prop 'disabled', false

    # ### `baseFormViewMixin.beforeSubmit()`
    #
    # Called before form is submitted. Has no arguments, and return value is
    # not used by the view.
    beforeSubmit: () ->
      @disableButtons()

    # ### `baseFormViewMixin.afterSubmit()`
    #
    # Called after either `#formValid()` or `#formInvalid()` have returned.
    # Has no arguments, and return value is not used.
    afterSubmit: () ->
      @enableButtons()

    # ### `baseFormViewMixin.events`
    #
    # Event mappings.
    events:
      'submit form': 'submit'
      'change :input': 'onFieldChange'
      'input :input': 'onFieldChange'

    # ### `baseFormViewMixin.submit(e)`
    #
    # Form submit event handler.
    #
    # This is an internal implementation detail, and you generally should not
    # override this.
    submit: (e) ->
      e.preventDefault()
      @clearErrors()
      @beforeSubmit()
      form = @getForm()
      [err, data] = @validate()
      if err
        @formInvalid err, data
      else
        @formValid data
      @afterSubmit()
      false

    # ### `baseFormViewMixin.onFieldChange(e)`
    #
    # Form input change event handler.
    #
    # This is an internal implementation detail, and you generally should not
    # override this.
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
  # Please see the documentation for the `baseFormViewMixin` for more
  # information on the API that this view provides.
  BaseFormView = baseView.View.extend baseFormViewMixin


  mixin: baseFormViewMixin
  View: BaseFormView
