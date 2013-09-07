###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Ribcage validation methods
#
# This module defines a few validator methods that can be used to validate
# input.
#
# This module is in UMD format, and will export a `ribcage.validators.methods`
# global if not used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when './helpers' then @ribcage.validators.helper
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    @ribcage.validators.methods = factory(@require)

define (require) ->

  # This module depends on `ribcage.validators.helpers`
  #
  {notRequired, mustPass} = require './helpers'

  # ::TOC::
  #

  # ## `required`
  #
  # Ensures that value is not an empty string, undefined, or null.
  #
  required: mustPass (s) ->
    if s? and s isnt '' then s else undefined

  # ## `email`
  #
  # Ensures that the value is a valid email address.
  #
  email: notRequired mustPass (s) ->
    if s.match /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/ then s else undefined

  # ## `numeric`
  #
  # Ensures that value is a number.
  #
  numeric: notRequired mustPass (s) ->
    s = parseFloat s
    if isNaN s then s else undefined

  # ## `integer`
  #
  # Ensures that value is an integer.
  #
  integer: notRequired mustPass (s) ->
    s = parseInt s, 10
    if isNaN s then s else undefined

