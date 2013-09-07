###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Validating mixins for views and models
#
# This module defines two mixin objects that expose the validation methods and
# provide a simplified API for their consumption in views and models.
#
# This module is in UMD format, and will create a `ribcage.validators.mixins`
# global if not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'underscore' then @_
        when './methods' then @ribcage.validators.methods
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    @ribcage.validators.mixins = factory(@require)

define (require) ->

  # This module depends on Underscore and `ribcage.validators.methods`.
  #
  _ = require 'underscore'
  methods = require './methods'

  # ::TOC::
  #

  # ## `validatingMixin`
  #
  # This mixin adds validation logic to constructors such as view and model
  # constructors. Note that adding this mixin to a model does not automatically
  # cause it to be used. This is because the mixin does not provide the
  # `#validate()` method. A mixin that adds that method on top of this mixin is
  # the [`modelValidatingMixin`](#modelvalidatingmixin).
  #
  validatingMixin =
    # ### `#validators`
    #
    # An object containig name-method pairs of validators. You can add your
    # custom validators here. It defaults to validators found in
    # `ribcage/validators/methods` module.
    #
    # You can use Underscore.js's `#extend()` method to add yours:
    #
    #   validators: _.extend(methods, {
    #     myValidator: function(s) { .... }
    #   })
    #
    # Each custom validator method must take a single string value, and return
    # an array containing the cleaned value (value converted to appropraite
    # format usable by your application) and and status. The status is a
    # boolean value which should be `true` if the value is valid, or `false` if
    # it's not.
    #
    validators: methods

    # ### `#rules`
    #
    # This object describes the validation rules. Each rule maps an attribute
    # name to an object that contains validation mappings. For example:
    #
    #     rules: {
    #       name: {
    #         required: 'Name is required'
    #       },
    #       email: {
    #         required: 'Email is required',
    #         email: 'Email must be a valid email'
    #       }
    #     }
    #
    # A special key `__all` is used to validate the entire form data.
    #
    #    rules: {
    #      password: {
    #        required: 'Password cannot be blank'
    #      },
    #      passwordConfirm: {
    #        required: 'Please type in your password again'
    #      },
    #      __all: {
    #        customValidator: 'Passwords do not match'
    #      }
    #    }
    #
    # Key in the validation mapping represents the name of the validator
    # method.  Valid methods are:
    #
    #  + required
    #  + email
    #  + numeric
    #  + integer
    #
    # Note that none of the default validator methods work with entire data
    # sets, so be sure to add your own validators if you want to validate sets
    # of data.
    rules: {}

    # ### `#applyValidators(name, val)`
    #
    # Applies validators to a single value. The errors are either `null` if
    # value is valid, or an array of messages for invalid value.
    #
    applyValidators: (name, val) ->
      errors = null
      for method, msg of @rules[name]
          if not method of @validators
            throw new Error "#{method} is not a validator method"
          [val, valid] = @validators[method] val
          if not valid
            errors or= []
            errors.push(msg)
      [errors, val]

    # ### `#cleanFields(dada)`
    #
    # Validates fields using given rules in the `#rules` object. The return
    # value maps attribute names to an Array of error messages.
    #
    cleanFields: (data) ->
      cleaned = {}
      errors = null
      if _.isEmpty @rules
        return [errors, data]
      for attribute, val of data
        continue if not attribute of @rules
        [messages, val] = @applyValidators attribute, val
        if messages is null
          cleaned[attribute] = val
        else
          errors or= {}
          errors[attribute] = messages
      [errors, cleaned]

    # ### `#clean(data)`
    #
    # Cleans fields and entire data set.
    #
    clean: (data) ->
      [errors, cleaned] = @cleanFields(data)
      return [errors, cleaned] if errors or not '__all' of @rules
      @applyValidators '__all', data


  # ## `modelValidatingMixin`
  #
  # This mixin enhances [`validatingMixin`](#validatingmixin) and adds the
  # `#validate()` method which takes over the taks of validatnig model data.
  #
  # Note that this mixin will also modify the model's attributes. It does so
  # _directly_ without causing any events. If that is not what you want, you
  # should use the plain [`validatingMixin`](#validatingmixin) and add your own
  # `#validate()` method instead.
  #
  modelValidatingMixin = _.extend validatingMixin,

    # ### `#validate(attributes)`
    #
    # Validates and cleans the model attributes and resets the
    # `this.attributes` to cleaned data.
    #
    validate: (attributes) ->
      [errors, data] = @clean attributes
      if not _.isEmpty errors
        errors
      else
        @attributes = data
        null

  validatingMixin: validatingMixin
  modelValidatingMixin: modelValidatingMixin
