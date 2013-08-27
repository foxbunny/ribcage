# # Ribcage validator helper functions
#
# This module defines a few functions used to simplify code in the validator
# methods.
#
# This module is in UMD format and will create a `Ribcage.validators.helpers`
# global if not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    (@Ribcage or= {}).validators or= {}
    @Ribcage.validators.helpers = factory()

define (require) ->

  # ## `notRequired(fn)`
  #
  # Returns a wrapped validator function which returns a positive result if the
  # value is undefined or an empty string.
  notRequired: (fn) ->
    (s) ->
      if not s? or s is ''
        [s, true]
      else
        fn(s)

  # ## `mustPass(fn)`
  #
  # Returns a function that takes the output of `fn` and returns a properly
  # formatted validator result.
  #
  # The result is in `[value, result]` format, where `value` is the cleaned up
  # and formatted value returned by `fn`, and `result` a boolean that is `true`
  # unless `value` is undefined.
  #
  # Writing of validator functions is simplified by providing a function to
  # `mustPass` that will try to convert the value into an appropriate format
  # without having to worry about formatting the result.
  mustPass: (fn) ->
    (s) ->
      s = fn(s)
      [s, s isnt undefined]
