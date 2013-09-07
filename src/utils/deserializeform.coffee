###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Deserialize object to form
#
# This module provides a helper method to deserialize an object into a form.
# The helper method is also attached to jQuery as both a
# `jQuery.deserializeForm` method as well `jQuery.fn.deserializeForm` method.
#
# This model is in UMD format, and will create a
# `ribcage.utils.deserializeForm` global if not used with an AMD loader such as
# RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'jquery' then @jQuery
        when 'underscore' then @_
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    @ribcage.utils.deserializeForm = factory @require

define (require) ->
  # This module depends on jQuery and Underscore.
  #
  $ = require 'jquery'
  _ = require 'underscore'

  # ::TOC::
  #

  # ## `jQuery.deserializeForm(form, data)`
  #
  # Uses `data` object to fill a form found under `form` selector or jQuery
  # object.
  #
  # Example:
  #
  #     <form id="myform">
  #       <input name="name" type="text">
  #       <input name="age" type="text">
  #     </form>
  #
  #     $.deserializeForm('#myform', {
  #       name: 'John Doe',
  #       age: 22
  #     });
  #
  $.deserializeForm = (form, data) ->
    form = $ form

    form.find(':input').each () ->
      input = $ this
      name = input.attr 'name'
      type = input.attr 'type'
      currentValue = input.val()

      # Cannot get data if there's no input name, can we?
      return if not name

      switch type
        when 'checkbox'
          input.prop 'checked', data[name] is 'on'
        when 'radio'
          input.prop 'checked', data[name] == currentValue
        else
          input.val data[name]

    form

  # ## `.deserializeForm(data)`
  #
  # Uses data object to fill all inputs found under the selected element. This
  # is a wrapper around `jQuery.deserializeForm()`.
  #
  # Example:
  #
  #     <form id="myform">
  #       <input name="name" type="text">
  #       <input name="age" type="text">
  #     </form>
  #
  #     $('#myform').deserializeForm({
  #       name: 'John Doe',
  #       age: 22
  #     });
  #
  $.fn.deserializeForm = (data) ->
    $.deserializeForm this, data

  $.deserializeForm
