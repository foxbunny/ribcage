/**
 * @author Branko Vukelic <branko@brankovukelic.com>
 * @license MIT
 */

# # Base model
#
# This module implements common API for all Ribcage models. All ribcage models
# should extend this model.
#
# This module is in UMD format and creates `Ribcage.models.baseModel`,
# `Ribcage.models.BaseModel`, and `Ribcage.modelMixins.BaseModel` globals if
# not used with with an AMD loader such as RequireJS.
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
      r.{}models.base-model = module
      r.models.BaseModel = module.Model
      r.{}model-mixins.BaseModel = module.mixin
) this

define (require) ->

  # This module depends on Backbone.
  #
  require! backbone.Model

  # ::TOC::
  #

  # ## `mixin`
  #
  # Mixin that implements the common functionality of all Ribcage models.
  #
  mixin: BaseModelMixin =
    # ### `#expose(attr)`
    #
    # Create an accessor for the `attr` attribute.
    #
    expose: (attr) ->
      Object.define-property this, attr,
        get: -> @get attr
        set: (v) -> @set attr, v

    # ### `#exposeReadOnly(attr)`
    #
    # Create an accessor for `attr` attribute that only allows reading and
    # throws an exception on set.
    #
    exposeReadOnly: (attr) ->
      Object.define-property this, attr,
        get: -> @get attr
        set: -> throw new Error "Attribute #{attr} cannot be set."

    # ### `#cleanup()`
    #
    # Cleans up the model after use.
    #
    # This method is borrowed from Chaplin.
    #
    cleanup: ->
      ## Unbind all event listeners
      @stopListening!

      ## Stop listening to events
      @off!

      keys = <[
        collection
        attributes
        changed
        _events
        _previousAttributes
      ]>

      ## Remove all properties that point to objects or field values
      for k in keys
        delete this[k]

      ## Freeze the instance
      Object.freeze? this

  # ## `BaseModel`
  #
  # Please see the documentation on the [mixin](#mixin) for
  # more information about this model.
  #
  Model: class BaseModel extends Model implements BaseModelMixin

