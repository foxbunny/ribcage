# # Base collection
#
# This module implements the common API for all Ribcage collections. All
# Ribcage collections should extend this collection.
#
# This module is in UMD format and will create
# `ribcage.collections.baseCollection`, `ribcage.collections.BaseCollection`,
# and `ribcage.collectionMixins.BaseCollection` globals if not used with an AMD
# loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    collections = (@ribcage or= {}).collections or= {}
    mixins = @ribcage.collectionMixins or= {}
    module = collections.baseCollection = factory @require
    collections.BaseCollection = module.Collection
    mixins.BaseCollection = module.mixin

# This module depends on Backbone

define (require) ->
  Backbone = require 'backbone'

  # ## `baseCollectionMixin`
  #
  # This is a placeholder for future functionality.
  baseCollectionMixin = {}

  # ## `BaseCollection`
  #
  # Currently identical to Backbone collection.
  BaseCollection = Backbone.Collections.extend baseCollectionMixin

  mixin: baseCollectionMixin
  Collection: BaseCollection
