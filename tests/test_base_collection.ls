'use strict'

define (require) ->

  require! 'ribcage/collections/base'.Collection
  require! BackboneCollection: 'backbone'.Collection

  proto = Collection.prototype

  describe 'BaseCollection' !-> ``it``

    .. 'should inherit directly from Backbone.Collection' !->
      for k, v of BackboneCollection.prototype
        expect proto[k] .to.equal v

    .. 'should have cleanup' !->
      expect proto .to.have.property 'cleanup' .that.is.a 'function'

    ## TODO: Implement the model first, and then work on collection
