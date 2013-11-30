'use strict'

define (require) ->

  require! 'ribcage/collections/base'.Collection
  require! 'ribcage/models/base'.Model
  require! BackboneCollection: 'backbone'.Collection

  proto = Collection.prototype

  describe 'BaseCollection' !-> ``it``

    .. 'should inherit directly from Backbone.Collection' !->
      for k, v of BackboneCollection.prototype
        expect proto[k] .to.equal v

    .. 'should have cleanup' !->
      expect proto .to.have.property \cleanup .that.is.a \function

    .. 'should reset the collection' !->
      models = [
        new Model foo: 'bar'
        new Model bar: 'baz'
      ]
      c = new Collection models
      expect c.length .to.equal 2
      expect c.models .to.deep.equal models
      c.cleanup!
      expect c.length .to.equal 0
      expect c .to.not.have.own-property \models

    .. 'should remove properties' !->
      models = [
        new Model foo: 'bar'
        new Model bar: 'baz'
      ]
      c = new Collection models
      c.model = Model
      expect c .to.have.own-property \model
      expect c .to.have.own-property \models
      c.cleanup!
      expect c .to.not.have.own-property \model
      expect c .to.not.have.own-property \models
      expect Object.isFrozen c .to.be.true if Object.isFrozen?

    .. 'should remove event listeners' !->
      fn = sinon.spy!
      c = new Collection!
      c.on 'add', fn
      c.trigger 'add'
      expect fn .to.be.called-once
      c.cleanup!
      c.trigger 'add'
      expect fn .to.not.be.called-twice

    .. 'should remove handlers' !->
      fn = sinon.spy!
      c1 = new Collection!
      c2 = new Collection!
      c1.listen-to c2, 'add', fn
      c2.trigger 'add'
      expect fn .to.be.called-once
      c1.cleanup!
      c2.trigger 'add'
      expect fn .to.not.be.called-twice

