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
        case 'dahelpers':
          return _this.dahelpers;
        case './template':
          return _this.ribcage.views.templateView;
        default:
          return null;
      }
    })() || (function() {
      throw new Error("Unmet dependency " + dep);
    })();
  };
  this.define = function(factory) {
    var module;
    module = _this.ribcage.views.formErrorView = factory(_this.require);
    _this.ribcage.views.FormErrorView = module.View;
    return _this.ribcage.viewMixins.FormErrorView = module.mixin;
  };
}

define(function(require) {
  var BaseView, FormErrorView, formErrorViewMixin, toArray;
  toArray = require('dahelpers').toArray;
  BaseView = require('./base').View;
  formErrorViewMixin = {
    errorClass: 'error',
    formErrorClass: 'error-form',
    fieldErrorClass: 'error-field',
    inputErrorClass: 'error-input',
    errorMessage: function(_arg) {
      var cls, id, msg, s;
      id = _arg.id, msg = _arg.msg, cls = _arg.cls;
      cls || (cls = 'error');
      s = '<span';
      if (id != null) {
        s += " id=\"" + id + "\"";
      }
      return s + (" class=\"" + cls + "\">" + msg + "</span>");
    },
    clearErrors: function(form) {
      form = this.$(form);
      form.find("." + this.errorClass).remove();
      form.find("." + this.inputErrorClass).removeClass(this.inputErrorClass);
      return form;
    },
    cleanFieldErrors: function(input) {
      input = this.$(input);
      return input.siblings("." + errorClass).remove();
    },
    insertErrorMessage: function(input, msgs) {
      var msg, _i, _len, _ref, _results;
      if (msgs == null) {
        msgs = ['Invalid value'];
      }
      msgs = toArray(msgs);
      input = this.$(input);
      _ref = msgs.reverse();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        msg = _ref[_i];
        input.after(this.errorMessage({
          msg: msg,
          cls: "" + this.fieldErrorClass + " " + this.errorClass
        }));
        _results.push(input.addClass(this.inputErrorClass));
      }
      return _results;
    },
    insertFormErrors: function(form, msgs) {
      var msg, _i, _len, _ref, _results;
      form = this.$(form);
      msgs = toArray(msgs);
      _ref = msgs.reverse();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        msg = _ref[_i];
        _results.push(form.prepend(this.errorMessage({
          msg: msg,
          cls: "" + this.formErrorClass + " " + this.errorClass
        })));
      }
      return _results;
    },
    insertErrorMessages: function(form, err) {
      var _this = this;
      form = this.$(form);
      this.clearErrors(form);
      if (err == null) {
        return;
      }
      if (err.__all) {
        this.insertFormErrors(form, err.__all);
      }
      form.find(':input').each(function(idx, el) {
        var input, name;
        input = $(el);
        name = input.attr('name');
        if (err[name]) {
          return _this.insertErrorMessage(input, err[name]);
        }
      });
      return this;
    }
  };
  FormErrorView = BaseView.extend(formErrorViewMixin);
  return {
    mixin: formErrorViewMixin,
    View: FormErrorView
  };
});
