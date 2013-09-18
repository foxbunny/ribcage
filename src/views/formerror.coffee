###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Form error view
#
# This view provides the basic error display in your view's forms. It doesn't
# do much by itself other than providing methods that perofrm the grunt work of
# inserting and clearing error messages. It is generally expected that mixin
# would be more useful in conjunction with your views. The view constructor is
# provided simply for the sake of consistency with the rest of Ribcage.
#
# This module is in UMD format and will create `ribcage.views.formErrorView`,
# `ribcage.views.FormErrorView` and `ribacage.mixins.formErrorView` global if
# not used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'dahelpers' then @dahelpers
        when './template' then @ribcage.views.templateView
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.formErrorView = factory @require
    @ribcage.views.FormErrorView = module.View
    @ribcage.viewMixins.FormErrorView = module.mixin

define (require) ->

  # This module depends on DaHelpers, `ribcage.views.BaseView`.
  #
  {toArray} = require 'dahelpers'
  {View: BaseView} = require './base'

  # ::TOC::
  #

  # ## `formErrorViewMixin`
  #
  # This mixin implements the API for the [`FormErrorView`](#formerrorview).
  #
  # The format of the error objects that are passed to this mixin's methods are
  # expected to follow the Ribcage's validation output.
  #
  formErrorViewMixin =
    # ### `#errorClass`
    #
    # This is a HTML class added to all form and field errors displayed in the
    # form.
    #
    errorClass: 'error'

    # ### `#formErrorClass`
    #
    # This is a HTML class that is added to all form errors.
    #
    formErrorClass: 'error-form'

    # ### `#fieldErrorClass`
    #
    # This is a HTML class added to all field errors.
    #
    fieldErrorClass: 'error-field'

    # ### `#inputErrorClass`
    #
    # This is a HTML class added to individual inputs that have errors.
    #
    inputErrorClass: 'error-input'

    # ### `#errorMessage(data)`
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
    #
    errorMessage: ({id, msg, cls}) ->
      cls or= 'error'
      s = '<span'
      s += " id=\"#{id}\"" if id?
      s + " class=\"#{cls}\">#{msg}</span>"

    # ### `#clearErrors(form)`
    #
    # Remove all errors from the `form`. It is assumed that all error messages
    # have a wrapper element wit the class matching `this.errorClass`.
    #
    # It also removes the error class from inputs.
    #
    clearErrors: (form) ->
      form = @$ form
      form.find(".#{@errorClass}").remove()
      form.find(".#{@inputErrorClass}").removeClass @inputErrorClass
      form

    # ### `#clearFieldErrors(input)`
    #
    # Removes all errors that are siblings of a given input. This doesn't work
    # if all inputs and all errors are siblings. Please be sure to add
    # appropriate structure to your form.
    #
    cleanFieldErrors: (input) ->
      input = @$ input
      input.siblings(".#{errorClass}").remove()

    # ### `#insertErrorMessage(input, [msgs])`
    #
    # Insert a list of error messages after the specified input. The `msgs`
    # argument is optional, and defaults to ['Invalid value']. Otherwise, it
    # should be an array of error messages for the field.
    #
    # The `msgs` argument can also be a single string.
    #
    insertErrorMessage: (input, msgs=['Invalid value']) ->
      msgs = toArray msgs
      input = @$ input

      ## We need to iterate the reversed array because each message is rendered
      ## right below the input, and therefore ends up at the top.
      for msg in msgs.reverse()
        input.after @errorMessage
          msg: msg
          cls: "#{@fieldErrorClass} #{@errorClass}"

        input.addClass @inputErrorClass

    # ### `#insertFormErrors(form, msgs)`
    #
    # Insert a list of error messages after the specified input.
    #
    # `forms` is required, and should be a valid jQuery selector or object.
    #
    # `msgs` is required, and should be an array of messages. If it is not an
    # array, it will be converted to one.
    #
    insertFormErrors: (form, msgs) ->
      form = @$ form
      msgs = toArray msgs

      ## We need to iterate the reversed array because each message is rendered
      ## right at the top of the form.
      for msg in msgs.reverse()
        form.prepend @errorMessage
          msg: msg
          cls: "#{@formErrorClass} #{@errorClass}"

    # ### `#insertErrorMessages(form, err)`
    #
    # `forms` is required, and should be a valid jQuery selector or object.
    #
    # Takes an object with error messages for the given form, and renders them
    # next to the fields.
    #
    # The `err` object is expected to map field names to an array of error
    # messages. A special `__all` key can be used to specify messages that
    # apply to the entire form.
    #
    insertErrorMessages: (form, err) ->
      form = @$ form

      @clearErrors form

      return if not err?

      if err.__all
        @insertFormErrors form, err.__all

      form.find(':input').each (idx, el) =>
        input = $ el
        name = input.attr 'name'
        if err[name]
          @insertErrorMessage input, err[name]

      this # return this for chaining

  # ## `FormErrorView`
  #
  # Please see the documentation for the [`formErrorMixin`](#formerrormixin)
  # for more information on the API that this view provides.
  #
  FormErrorView = BaseView.extend formErrorMixin

  mixin: formErrorViewMixin
  View: FormErrorView
