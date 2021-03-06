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
        case './formerror':
          return _this.ribcage.views.formErrorView;
        case './formextra':
          return _this.ribcage.views.formExtraView;
        case '../utils/searializeobject':
          return _this.ribcage.utils.serializeObject;
        case '../utils/deserializeform':
          return _this.ribcage.utils.deserializeForm;
        case '../validation/mixins':
          return _this.ribcage.validation.mixins;
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
    module = _this.ribcage.views.baseFormView = factory(_this.require);
    _this.ribcage.views.BaseFormView = module.View;
    return _this.ribcage.viewMixins.BaseFormView = module.mixin;
  };
}

define(function(require) {
  var BaseFormView, TemplateView, baseFormViewMixin, deserializeForm, extend, formErrorMixin, formExtraMixin, serializeObject, validatingMixin;
  extend = require('dahelpers').extend;
  serializeObject = require('../utils/serializeobject');
  deserializeForm = require('../utils/deserializeform');
  validatingMixin = require('../validators/mixins').validatingMixin;
  formErrorMixin = require('./formerror').mixin;
  formExtraMixin = require('./formextra').mixin;
  TemplateView = require('./template').View;
  baseFormViewMixin = extend({}, validatingMixin, formErrorMixin, formExtraMixin, {
    validateOnInput: false,
    __form: null,
    getForm: function() {
      return this.__form || (this.__form = this.$('form'));
    },
    getFormData: function() {
      return serializeObject(this.getForm());
    },
    setFormData: function(data) {
      return deserializeForm(this.getForm(), data);
    },
    validate: function() {
      return this.clean(this.getFormData());
    },
    fieldInvalid: function(input, errors) {
      this.clearFieldErrors(input);
      return this.insertErrorMessage(input, errors);
    },
    validateField: function(input, name, value, data) {
      var errors, _ref;
      _ref = this.applyValidators(name, value), errors = _ref[0], value = _ref[1];
      if (errors.length) {
        return this.fieldInvalid(input, name, value, errors);
      }
    },
    formInvalid: function(err) {
      return this.insertErrorMessages(this.getForm(), err);
    },
    formValid: function(data) {},
    beforeSubmit: function() {
      return this.disableButtons(this.getForm());
    },
    afterSubmit: function() {
      return this.enableButtons(this.getForm());
    },
    events: {
      'submit form': 'submit',
      'change :input': 'onFieldChange',
      'input :input': 'onFieldChange'
    },
    submit: function(e) {
      var data, err, _ref;
      e.preventDefault();
      this.clearErrors(this.getForm());
      this.beforeSubmit();
      _ref = this.validate(), err = _ref[0], data = _ref[1];
      if (err) {
        this.formInvalid(err, data);
      } else {
        this.formValid(data);
      }
      this.afterSubmit();
      return false;
    },
    onFieldChange: function(e) {
      var formData, input, name, value;
      if (!this.validateOnInput) {
        return true;
      }
      input = this.$(e.target);
      name = input.attr('name');
      value = input.val();
      if (input.attr('type') === 'checkbox') {
        value = input.prop('checked');
      }
      formData = this.getFormData();
      this.validateField(input, name, value, formData);
      return true;
    }
  });
  BaseFormView = TemplateView.extend(baseFormViewMixin);
  return {
    mixin: baseFormViewMixin,
    View: BaseFormView
  };
});
