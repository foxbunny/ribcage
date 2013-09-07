###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Random string generator
#
# This module implements a very crude pseudo-random string generator. The
# random number generator used for randomization is the plain-old
# `Math.random`.
#
# This module is in UMD format and will create `ribcage.utils.randString`
# global if not used with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    @ribcage.utils.randString = factory()

define () ->

  # This module has no external dependencies.
  #
  # ::TOC::
  #

  # ### `getRandChar([charPool])`
  #
  # Returns a random character from the `charPool` string. The `charPool` is
  # optional and defaults to 'abcdef0123456789' (hex digits)
  #
  getRandChar: (charPool='abcdef0123456789') ->
    charPool[Math.floor Math.random() * charPool.length]

  # ### `generateRandStr([len, charPool])`
  #
  # Returns a string of `len` length that consists of characters from
  # the `charPool` string.
  #
  # Both arguments are optional. `len` defaults to 20, and `charPool` defaults
  # to `null` (internally, `getRandChar` is called, so its defaults are
  # used).
  #
  generateRandStr: (len=20, charPool=null) ->
    (@getRandChar(charPool) for i in [0..len]).join ''
