###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # CreateView
#
# This is an extension of the ModelView which automatically saves form data
# using the model's `#save()` method.
#
# The create view is used when there is a one-to-one corellation between the
# form and the model, and the goal of form submission is creation of a model
# and its persistence on the server.
#
# This module is in UDM format, and will create `ribcage.views.createView`,
# `ribcage.views.CreateView`, and `ribcage.viewMixins.CreateView` globals if
# not used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when './modelform' then @ribcage.views.modelForm
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.views.createView = factory @require
    @ribcage.views.CreateView = module.View
    @ribcage.viewMixins.CreateView = module.mixin

define (require) ->

  # This module depends on `ribcage.views.modelform`.
  #
  modelForm = require './modelform'

  # ::TOC::
  #

  # ## `createViewMixin`
  #
  # This mixin implements the crate view API.
  #
  # CreateView will handle validation, saving, and post-save operation in
  # conjunction with a model assigned to the view. The general flow is to
  # interrupt the submit method on a rendered form, validate the data, save the
  # model, and then redirect to a specific path.
  #
  # Most aspects of the flow can be customized.
  #
  createViewMixin =

    # ### `#redirectPath`
    #
    # Path to redirect to on successful creation of a model.
    #
    redirectPath: '#'

    # ### `#saveErrorMessage`
    #
    # Default save error message. This message is shown to in the form if the
    # object cannot be saved (e.g., because of a server error or because the
    # connection is down).
    #
    saveErrorMessage: 'The form could not be saved'

    # ### `#getRedirectPath()`
    #
    # Returns the redirect path to which form will redirect on success. By
    # default it returns `this.redirectPath` which in turn defaults to '#'.
    #
    getRedirectPath: () ->
      @redirectPath

    # ### `#getSaveErrorMessage(xhr, status, msg)`
    #
    # Returns the error message displayed to the form on save error. By default
    # it returns the value of [`#saveErrorMessage`](#saveerrormessage).
    #
    # This method is called with the same arguments as the jQuery.ajax error
    # callback.
    #
    getSaveErrorMessage: (xhr, status, msg) ->
      @saveErrorMessage

    # ### `#onSaveSuccess()`
    #
    # Called when model is successfully saved. This is basically a success
    # callback passed to `Backbone.sync` (or a version of it defined in the
    # model), so the signature is the same.
    #
    # The default implementation redirects the app to a location defined by
    # the [`#getRedirectPath()`](#getredirectpath) method.
    #
    onSaveSuccess: () ->
      window.location.hash = @getRedirectPath()

    # ### `#onSaveError()`
    #
    # Called when model could not be saved. This is basically an error callback
    # passed to `Backbone.sync` (or a version of it defined in the model), so
    # the signature is the same.
    #
    # Default implementation shows a form error message which is obtained by
    # calling the
    # [`#getSaveErrorMessage()`](#getsaveerrormessage-xhr-status-msg) method.
    #
    onSaveError: (xhr, status, msg) ->
      @insertErrorMessages
        __all: [@getSaveErrorMessage xhr, status, msg]

    # ### `#afterSubmit()`
    #
    # Called asynchronously after all the callbacks have been called. You
    # should not assume that this method is called after requests are complted.
    # In fact it is usually not. If you want to be sure that requests were
    # finished, overload the [`#afterRequest()`](#afterrequest) method.
    #
    afterSubmit: () ->
      this

    # ### `#afterRequest()`
    #
    # Called after AJAX calls have been completed. This method has no
    # arguments, and return value is not used.
    #
    # Also, it is called after both a successful and unsuccessful request.
    #
    afterRequest: () ->
      @enableButtons()

    # ### `#formInvalid(err)`
    #
    # Handles the invalid form submission. By default, it simply renders the
    # form input.
    formInvalid: (err) ->
      @afterRequest()
      modelForm.View::formInvalid.call this, err

    # ### `#formValid(data)`
    #
    # Saves the serialized form data using model's save method, and calls the
    # [`#onSaveSuccess()`](#onsavesuccess) or
    # [`#onSaveError()`](#onsaveerror-xhr-status-msg) method depending on the
    # result.
    #
    formValid: (data) ->
      @model.save data,
        success: (args...) =>
            @afterRequest()
            @onSaveSuccess.apply this, args  # Bind to this view
        error: (args...) =>
            @afterRequest()
            @onSaveError.apply this, args  # Bind to this view

  # ## `CreateView`
  #
  # Please see the documentation for the `createViewMixin` for more information
  # on the API that this view provides.
  #
  CreateView = modelForm.View.extend createViewMixin

  mixin: createViewMixin
  View: CreateView
