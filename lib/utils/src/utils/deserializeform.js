// Generated by CoffeeScript 1.6.1
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var _this = this;

if (typeof define !== 'function' || !define.amd) {
  this.require = function(dep) {
    return (function() {
      switch (dep) {
        case 'jquery':
          return _this.jQuery;
        case 'underscore':
          return _this._;
        default:
          return null;
      }
    })() || (function() {
      throw new Error("Unmet dependency " + dep);
    })();
  };
  this.define = function(factory) {
    var _base;
    (_base = (_this.ribcage || (_this.ribcage = {}))).utils || (_base.utils = {});
    return _this.ribcage.utils.deserializeForm = factory(_this.require);
  };
}

define(function(require) {
  var $, _;
  $ = require('jquery');
  _ = require('underscore');
  $.deserializeForm = function(form, data) {
    form = $(form);
    form.find(':input').each(function() {
      var currentValue, input, name, type;
      input = $(this);
      name = input.attr('name');
      type = input.attr('type');
      currentValue = input.val();
      if (!name) {
        return;
      }
      switch (type) {
        case 'checkbox':
          return input.prop('checked', data[name] === 'on');
        case 'radio':
          return input.prop('checked', data[name] === currentValue);
        default:
          return input.val(data[name]);
      }
    });
    return form;
  };
  $.fn.deserializeForm = function(data) {
    return $.deserializeForm(this, data);
  };
  return $.deserializeForm;
});