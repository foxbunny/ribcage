###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Base model
#
# This module implements common API for all Ribcage models. All ribcage models
# should extend this model.
#
# This module is in UMD format and creates `Ribcage.models.baseModel`,
# `Ribcage.models.BaseModel`, and `Ribcage.modelMixins.BaseModel` globals if
# not used with with an AMD loader such as RequireJS.
#

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.models.baseModel = factory @require
    @ribcage.models.BaseModel = module.Model
    @ribcage.modelMixins.BaseModel = module.mixin

define (require) ->

  # This module depends on Backbone.
  #
  Backbone = require 'backbone'

  # ::TOC::
  #

  # ## `baseModelMixin`
  #
  # Mixin that implements the common functionality of all Ribcage models.
  #
  # It is currently a stub, but you should generally extend the `BaseModel`
  # constructor to build all Ribcage models.
  #
  baseModelMixin = {}

  # ## `BaseModel`
  #
  # Please see the documentation on [`baseModelMixin`](#basemodelmixin) for
  # more information about this model.
  #
  BaseModel = Backbone.Model.extend baseModelMixin

  # ## Exports
  #
  # This module exports `mixin` and `Model` properties.
  #
  mixin: baseModelMixin
  Model: BaseModel
