###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Base collection
#
# This module implements the common API for all Ribcage collections. All
# Ribcage collections should extend this collection.
#
# This module is in UMD format and will create
# `ribcage.collections.baseCollection`, `ribcage.collections.BaseCollection`,
# and `ribcage.collectionMixins.BaseCollection` globals if not used with an AMD
# loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.collections.baseCollection = factory @require
    @ribcage.collections.BaseCollection = module.Collection
    @ribcage.collectionMixins.BaseCollection = module.mixin

define (require) ->

  # This module depends on Backbone
  #
  Backbone = require 'backbone'

  # ::TOC::
  #

  # ## `baseCollectionMixin`
  #
  # Mixin that implements the functionality of the `BaseCollection`
  # constructor.
  #
  # It is currently just a stub, but you should generally extend
  # `BaseCollection` constructor to build all Ribcage constructors.
  #
  baseCollectionMixin = {}

  # ## `BaseCollection`
  #
  # Please see the documentation on
  # [`baseCollectionMixin`](#basecollectionmixin) for more information about
  # this collection.
  #
  BaseCollection = Backbone.Collection.extend baseCollectionMixin

  # ## Exports
  #
  # This module exports `mixin` and `Collection` properties.
  #
  mixin: baseCollectionMixin
  Collection: BaseCollection
