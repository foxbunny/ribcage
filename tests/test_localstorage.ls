define (require) ->

  require! LocalStorage: 'ribcage/utils/localstorage'

  describe 'LocalStorage' !-> ``it``

    .. 'memory storage implements localStorage API' !->
      ms = LocalStorage.memory-storage!
      expect ms .to.have.property 'getItem' .that.is.a 'function'
      expect ms .to.have.property 'setItem' .that.is.a 'function'
      expect ms .to.have.property 'removeItem' .that.is.a 'function'

      o = foo: 'bar'
      ms.set-item 'foo', o
      expect ms.get-item 'foo' .to.deep.equal o
      ms.remove-item 'foo'
      expect ms.get-item 'foo' .to.equal void

    describe 'memory storage' !-> ``it``

      class MemOnlyStorage extends LocalStorage
        ->
          @has-native = false
          @local-storage = @@memory-storage!

      after-each ->
        LocalStorage.memory-storage!clear!

      .. 'should set data' !->
        l = new MemOnlyStorage!
        l.set-item 'foo', foo: 'bar'
        expect l.get-item 'foo' .to.deep.equal foo: 'bar'

      .. 'should return null for non-existent keys' !->
        l = new MemOnlyStorage!
        expect l.get-item 'foo' .to.equal null

      .. 'should remove data' !->
        l = new MemOnlyStorage!
        l.set-item 'foo', foo: 'bar'
        l.remove-item 'foo'
        expect l.get-item 'foo' .to.equal null

    if window.local-storage?

      describe 'native local storage' !-> ``it``
        ## Tests with native storage

        after-each !->
          for key of local-storage
            local-storage.remove-item key

        .. 'should store data as JSON' !->
          l = new LocalStorage!
          l.set-item 'foo', foo: 'bar'
          data = local-storage.get-item 'foo'
          expect data .to.equal '{"foo":"bar"}'

        .. 'should retrieve as JSON' !->
          l = new LocalStorage!
          local-storage.set-item 'foo', '{"foo":"bar"}'
          data = l.get-item 'foo'
          expect data .to.deep.equal foo: 'bar'

        .. 'returns null for undefined keys' !->
          l = new LocalStorage!
          expect l.get-item 'foo' .to.equal null

        .. 'should remove items' !->
          l = new LocalStorage!
          l.set-item 'foo', foo: 'bar'
          l.remove-item 'foo'
          expect l.get-item 'foo' .to.equal null

        .. 'should return null stored data is broken' !->
          l = new LocalStorage!
          local-storage.set-item 'foo', 'not JSON'
          expect l.get-item 'foo' .to.equal null
