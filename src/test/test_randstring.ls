define (require) ->

  require! rand-string: 'ribcage/utils/randstring'

  describe 'randString module' !-> ``it``

    .. 'should return characters from specified char pool' !->
      pool = <[ a b c ]>
      for i in [0 til 100]
        expect pool .to.contain rand-string.rchar pool

    .. 'should return random strings with given length' !->
      for i in [1 til 10]
        expect rand-string.rstr i .to.have.length-of i

    .. 'should return random strings with characters from specified pool' !->
      pool = <[ a b c ]>
      for i in [0 til 100]
        expect pool .to.contain rand-string.rstr 1, pool

    .. 'should be sufficiently random' !->
      seen = []
      for i in [0 til 1000]
        s = rand-string.rstr!
        expect seen .to.not.include s
        seen.push s

