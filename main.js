// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var _this = this;

if (typeof define !== 'function' || !define.amd) {
  this.define = function(factory) {
    var _base, _base1, _base2, _base3, _base4, _base5, _base6, _base7;
    _this.ribcage || (_this.ribcage = {});
    (_base = _this.ribcage).models || (_base.models = {});
    (_base1 = _this.ribcage).collections || (_base1.collections = {});
    (_base2 = _this.ribcage).views || (_base2.views = {});
    (_base3 = _this.ribcage).modelMixins || (_base3.modelMixins = {});
    (_base4 = _this.ribcage).collectionMixins || (_base4.collectionMixins = {});
    (_base5 = _this.ribcage).viewMixins || (_base5.viewMixins = {});
    (_base6 = _this.ribcage).validators || (_base6.validators = {});
    return (_base7 = _this.ribcage).utils || (_base7.utils = {});
  };
}

define(function(require) {
  var LocalStore, baseCollection, baseFormView, baseModel, baseView, createView, deserializeForm, formErrorView, loadingView, localStorageModel, methods, mixins, modelFormView, modelView, randString, redirectView, serializeObject, tabbedView, templateView;
  baseModel = require('./models/base');
  localStorageModel = require('./models/localstorage');
  baseCollection = require('./collections/base');
  baseView = require('./views/base');
  formErrorView = require('./views/formerror');
  baseFormView = require('./views/form');
  modelFormView = require('./views/modelform');
  createView = require('./views/create');
  templateView = require('./views/template');
  modelView = require('./views/model');
  redirectView = require('./views/redirect');
  loadingView = require('./views/loading');
  tabbedView = require('./views/tabbed');
  methods = require('./validators/methods');
  mixins = require('./validators/mixins');
  serializeObject = require('./utils/serializeobject');
  deserializeForm = require('./utils/deserializeform');
  randString = require('./utils/randstring');
  LocalStore = require('./utils/localstore');
  return {
    models: {
      BaseModel: baseModel.Model,
      LocalStorageModel: localStorageModel.Model
    },
    collections: {
      BaseCollection: baseCollection.Collection
    },
    views: {
      BaseView: baseView.View,
      FormError: formErrorView.View,
      BaseFormView: baseFormView.View,
      ModelFormView: modelFormView.View,
      CreateView: createView.View,
      TemplateView: templateView.View,
      ModelView: modelView.View,
      RedirectView: redirectView.View,
      LoadingView: loadingView.View,
      TabbedView: tabbedView.View
    },
    modelMixins: {
      BaseModel: baseModel.mixin,
      LocalStorageModel: localStorageModel.mixin
    },
    collectionMixins: {
      BaseCollection: baseCollection.Collection
    },
    viewMixins: {
      BaseView: baseView.mixin,
      FormErrorView: formErrorView.mixin,
      BaseFormView: baseFormView.mixin,
      ModelFormView: modelFormView.mixin,
      CreateView: createView.mixin,
      TemplateView: templateView.mixin,
      ModelView: modelView.mixin,
      RedirectView: redirectView.mixin,
      LoadingView: loadingView.mixin,
      TabbedView: tabbedView.mixin
    },
    validators: {
      methods: methods,
      ValidatingMixin: mixins.validatingMixin,
      ModelValidatingMixin: mixins.modelValidatingMixin
    },
    utils: {
      serializeObject: serializeObject,
      deserializeForm: deserializeForm,
      randString: randString,
      LocalStore: LocalStore
    }
  };
});
