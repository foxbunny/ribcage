// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var _this = this;

if (typeof define !== 'function' || !define.amd) {
  this.define = function(factory) {
    return _this.ribcage.utils.randString = factory();
  };
}

define(function() {
  return {
    getRandChar: function(charPool) {
      if (charPool == null) {
        charPool = 'abcdef0123456789';
      }
      return charPool[Math.floor(Math.random() * charPool.length)];
    },
    generateRandStr: function(len, charPool) {
      var i;
      if (len == null) {
        len = 20;
      }
      if (charPool == null) {
        charPool = null;
      }
      return ((function() {
        var _i, _results;
        _results = [];
        for (i = _i = 0; 0 <= len ? _i <= len : _i >= len; i = 0 <= len ? ++_i : --_i) {
          _results.push(this.getRandChar(charPool));
        }
        return _results;
      }).call(this)).join('');
    }
  };
});
