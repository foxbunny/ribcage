###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Base model
#
# This module implements the base model. This model implements the API that is
# common to all Ribcage models, and should be extended to build all other
# models.
#
# This module is in UMD format and creates `Ribcage.models.baseModel`,
# `Ribcage.models.BaseModel`, and `Ribcage.modelMixins.BaseModel` globals if
# not used with with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    models = (@ribcage or= {}).models or= {}
    mixins = @ribcage.modelMixins or= {}
    module = models.baseModel = factory @require
    models.BaseModel = module.Model
    mixins.BaseModel = module.mixin

# This module depends on Backbone.

define (require) ->
  Backbone = require 'backbone'

  # ## `baseModelMixin`
  #
  # This mixin is a placeholder for future functionality that will be mixed
  # into all Ribcage models.
  baseModelMixin = {}

  # ## `BaseModel`
  #
  # The model that is extended by all Ribcage models. Currently it is identical
  # to normal Backbone model.
  BaseModel = Backbone.Models.extend baseModelMixin

  mixin: baseModelMixin
  Model: BaseModel
