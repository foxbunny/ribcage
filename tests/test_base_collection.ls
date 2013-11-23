'use strict'

define (require) ->

  {Collection} = require 'ribcage/collections/base'
  Backbone = require 'backbone'

  proto = Collection.prototype

  describe 'BaseCollection' !-> ``it``

    .. 'should inherit directly from Backbone.Collection' !->
      for k, v of Backbone.Collection.prototype
        assert.equal Collection.prototype[k], v

    .. 'should have cleanup' !->
      assert.typeOf proto.cleanup, 'function'

    ## TODO: Implement the model first, and then work on collection
