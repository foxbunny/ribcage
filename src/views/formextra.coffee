###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Form extras view
#
# This view provides methods for manipulating the forms' behavior. This
# includes such things as disabling and enabling submit buttons and similar.
#
# This module is in UMD format and will create `ribcage.views.formExtraView`,
# `ribcage.views.FormExtraView`, and `ribcage.viewMixins.FormExtraView` globals
# if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when './base' then root.ribcage.views.baseView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.views.formExtraView = module
      root.ribcage.views.FormExtraView = module.View
      root.ribcage.viewMixins.FormExtraView = module.mixin
) this

define (require) ->

  # This module depends on `ribcage.views.BaseView`.
  #
  {View: BaseView} = require './base'

  # ## `formExtraViewMixin`
  #
  # This mixin implements the API for [`FormExtraView`](#formextraview).
  #
  formExtraViewMixin =

    # ### `#FOCUSABLE_INPUTS`
    #
    # Defines the jQuery selector for focusable inputs. These are the inputs
    # that can be safely focused without the focus even affecting their value
    # (provided that the input is visible).
    #
    # The default includes the following inputs:
    #
    #  + `input[type=text]`
    #  + `input[type=date]`
    #  + `input[type=number]`
    #  + `input[type=email]`
    #  + `textarea`
    #  + `select`
    #
    FOCUSABLE_INPUTS: 'input[type=text],input[type=date],input[type=number],input[type=email],textara,select'

    # ### `#focusFirst(form)`
    #
    # Focus the first input in a form.
    #
    # The `form` argument should be a valid jQuery selector or object.
    #
    focusFirst: (form) ->
      form = @$ form
      form.find(FOCUSABLE_INPUTS + ':visible:first').focus()

    # ### `#disableButtons(form)`
    #
    # Disables form buttons (both button and input elements of type 'submit').
    #
    # The `form` argument should be a valid jQuery selector or object.
    #
    disableButtons: (form) ->
      form = @$ form
      form.find(':submit').prop 'disabled', true

    # ### `#enableButtons(form)`
    #
    # Enables form buttons (both button and input elements of type 'submit').
    #
    # The `form` argument should be a valid jQuery selector or object.
    #
    enableButtons: (form) ->
      form = @$ form
      form.find(':submit').prop 'disabled', false

  # ## `FormExtraView`
  #
  # Please see the documentation on [`formExtraViewMixin`](#formextraviewmixin)
  # for more information about this view's API.
  #
  FormExtraView = BaseView.extend formExtraViewMixin

  mixin: formExtraViewMixin
  View: FormExtraView


