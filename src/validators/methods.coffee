# # Ribcage validation methods
#
# This module defines a few validator methods that can be used to validate
# input.
#
# This module is in UMD format, and will export a `ribcage.validators.methods`
# global if not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    (@ribcage or= {}).validators or= {}
    @ribcage.validators.methods = factory()

define (require) ->

  {notRequired, mustPass} = require 'ribcage/validators/helpers'

  required: mustPass (s) ->
    if s? and s isnt '' then s else undefined

  email: notRequired mustPass (s) ->
    if s.match /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/ then s else undefined

  numeric: notRequired mustPass (s) ->
    s = parseFloat s
    if isNaN s then s else undefined

  integer: notRequired mustPass (s) ->
    s = parseInt s, 10
    if isNaN s then s else undefined
