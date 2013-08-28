// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var _this = this;

if (typeof define !== 'function' || !define.amd) {
  this.require = function(dep) {
    return (function() {
      switch (dep) {
        case 'backbone':
          return _this.Backbone;
        default:
          return null;
      }
    })() || (function() {
      throw new Error("Unmet dependency " + dep);
    })();
  };
  this.define = function(factory) {
    var _base, _base1;
    (_base = (_this.ribcage || (_this.ribcage = {}))).views || (_base.views = {});
    (_base1 = _this.ribcage).viewMixins || (_base1.viewMixins = {});
    _this.ribcage.views.baseView = factory(_this.require);
    _this.ribcage.views.BaseView = _this.ribcage._views.baseView.View;
    return _this.ribcage.viewMixins.BaseView = _this.ribcage._views.mixin;
  };
}

define(function(require) {
  var Backbone, BaseView, baseViewMixin;
  Backbone = require('backbone');
  baseViewMixin = {};
  BaseView = Backbone.View.extend(baseViewMixin);
  return {
    mixin: baseViewMixin,
    View: BaseView
  };
});