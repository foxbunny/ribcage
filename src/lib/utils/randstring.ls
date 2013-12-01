/**
 * @author Branko Vukelic <branko@brankovukelic.com>
 * @license MIT
 */

# # Random string generator
#
# This module implements a very crude pseudo-random string generator. The
# random number generator used for randomization is the plain-old
# `Math.random`.
#
# This module is in UMD format and will create `ribcage.utils.randString`
# global if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' || root.define.amd
    root.define
  else
    (factory) ->
      root.{}ribcage.{}utils.rand-string = factory!
) this

define ->

  # This module has no external dependencies.
  #
  # ::TOC::
  #

  # ### `rchar([charPool])`
  #
  # Returns a random character from the `charPool` string. The `charPool` is
  # optional and defaults to 'abcdef0123456789' (hex digits)
  #
  rchar: (char-pool = 'abcdef0123456789') ->
    char-pool[Math.floor Math.random! * char-pool.length]

  # ### `rstr([len, charPool])`
  #
  # Returns a string of `len` length that consists of characters from
  # the `charPool` string.
  #
  # Both arguments are optional. `len` defaults to 20, and `charPool` defaults
  # to `null` (internally, `rchr` is called, so its defaults are
  # used).
  #
  rstr: (len = 20chars, char-pool = null) ->
    [@rchar char-pool for i in [0 til len]].join ''
