/**
 * @author Branko Vukelic <branko@brankovukelic.com>
 * @license MIT
 */

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

define = ((root) ->
  if typeof root.define is 'function' && root.define.amd
    root.define
  else
    require = (dep) ->
      do ->
        switch dep
        | 'backbone' => root.Backbone
        | otherwise  => null
      or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory require
      r = root.{}ribcage
      r.{}collections.base-collection = module
      r.collections.BaseCollection = module.Collection
      r.{}collection-mixins.BaseCollection = module.mixin
) this


define (require) ->

  # This module depends on Backbone
  #
  require! backbone.Collection

  # ::TOC::
  #

  # ## `mixin`
  #
  # Mixin that implements the functionality of the `BaseCollection`
  # constructor.
  #
  # It is currently just a stub, but you should generally extend
  # `BaseCollection` constructor to build all Ribcage constructors.
  #
  mixin: BaseCollectionMixin =

    # ### `cleanup()`
    #
    # Cleans the collection up after use.
    #
    # This method is borrowed from Chaplin.
    #
    cleanup: ->
      ## Reset the collection.
      @reset [] silent: true

      ## Remove all listeners.
      @stop-listening!

      ## Stop listening to events.
      @off!

      ## Remove properties that point to other objects
      for k in ['model' 'models']
        delete this[k]

      ## Freeze the object
      Object.freeze? this

  # ## `Collection` (`BaseCollection`)
  #
  # Please see the documentation on the [`mixin`](#mixin) for more information
  # about this collection.
  #
  Collection: class BaseCollection extends Collection
    implements BaseCollectionMixin

