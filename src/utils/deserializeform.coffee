###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Deserialize object to form
#
# This module provides a helper method to deserialize an object into a form.
# The helper method is also attached to jQuery as both a `$.deserializeForm`
# method as well `$.fn.deserializeForm` method.
#
# This model is in UMD format, and will create a
# `ribcage.utils.deserializeForm` global if not used with an AMD loader such as
# RequireJS.

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
  $ = require 'jquery'
  _ = require 'underscore'

  # ## `$.deserializeForm(form, data)`
  #
  # Uses `data` object to fill a form found under `form` selector or jQuery
  # object.
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
  # is a wrapper around `$.deserializeForm()`.
  $.fn.deserializeForm = (data) ->
    $.deserializeForm this, data

  $.deserializeForm
