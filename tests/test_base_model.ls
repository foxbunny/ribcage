define (require) ->

  require! 'ribcage/models/base'.Model
  require! BackboneModel: backbone.Model

  proto = Model.prototype

  describe 'BaseModel' -> ``it``

    .. 'should inherit directly from Backbone.Model' ->
      for k, v of BackboneModel.prototype
        expect proto[k] .to.equal v

    .. 'should have expose method' ->
      expect proto .to.have.property \expose .that.is.a \function

    .. 'expose should expose attributes' ->
      m = new Model foo: 'bar'
      expect m .to.not.have.property 'foo'
      m.expose 'foo'
      expect m .to.have.property 'foo'
      expect m.foo .to.equal 'bar'
      expect m.foo .to.equal m.get 'foo'

    .. 'expose exposes a setter' ->
      m = new Model foo: 'bar'
      m.expose 'foo'
      m.foo = 'baz'
      expect m.foo .to.equal 'baz'
      expect m.foo .to.equal m.get 'foo'

    .. 'should have exposeReadOnly method' ->
      expect proto .to.have.property \exposeReadOnly .that.is.a \function

    .. 'exposeReadOnly should expose attributes' ->
      m = new Model foo: 'bar'
      expect m .to.not.have.property 'foo'
      m.exposeReadOnly 'foo'
      expect m .to.have.property 'foo'
      expect m.foo .to.equal 'bar'
      expect m.foo .to.equal m.get 'foo'

    .. 'exposeReadOnly should not expose a setter' ->
      m = new Model foo: 'bar'
      m.exposeReadOnly 'foo'
      expect (->
        m.foo = 'baz'
      ) .to.throw 'Attribute foo cannot be set.'

    .. 'should have cleanup method' ->
      expect proto .to.have.property \cleanup .that.is.a \function

    .. 'should clean up all properties' ->
      m = new Model foo: 'bar'
      expect m .to.have.own-property \attributes
      expect m .to.have.own-property \_previousAttributes
      expect m .to.have.own-property \changed
      m.cleanup!

      ## Test removal of attributes and listeners
      expect m.foo .to.equal void
      expect m .to.not.have.own-property \attributes
      expect m .to.not.have.own-property \_previousAttributes
      expect m .to.not.have.own-property \changed
      expect Object.isFrozen m .to.be.true if Object.isFrozen?

    .. 'should clean up event listeners' ->
      fn = sinon.spy!
      m = new Model foo: 'bar'
      m.on \change, fn
      m.trigger \change
      expect fn .to.be.called-once
      m.cleanup!
      m.trigger \change
      expect fn .to.not.be.called-twice

    .. 'should clear handlers' ->
      m1 = new Model foo: 'bar'
      m2 = new Model bar: 'baz'

      fn = sinon.spy!
      m1.listenTo m2, 'change', fn

      m2.trigger 'change'
      expect fn .to.be.called-once

      m1.cleanup!
      m2.trigger 'change'
      expect fn .to.not.be.called-twice

