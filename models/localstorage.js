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
        case './base':
          return _this.ribcage.models.baseModel;
        case '../utils/localstorage':
          return _this.ribcage.utils.LocalStorage;
        default:
          return null;
      }
    })() || (function() {
      throw new Error("Unmet dependency " + dep);
    })();
  };
  this.define = function(factory) {
    var mixins, models, module, _base, _base1;
    models = (_base = (_this.ribcage || (_this.ribcage = {}))).models || (_base.models = {});
    mixins = (_base1 = _this.ribcage).modelMixins || (_base1.modelMixins = {});
    module = models.localStorageModel = factory(_this.require);
    models.LocalStorageModel = module.Model;
    return mixins.LocalStorageModel = module.mixin;
  };
}

define(function(require) {
  var LocalStorage, LocalStorageModel, baseModel, localStorageModelMixin, storage;
  baseModel = require('./base');
  LocalStorage = require('../utils/localstorage');
  storage = new LocalStorage();
  localStorageModelMixin = {
    store: storage,
    storageKey: null,
    persistent: true,
    initialize: function() {
      return this.fetch();
    },
    sync: function(method, model) {
      if (!this.persistent && (method === 'create' || method === 'update' || method === 'delete')) {
        return this.toJSON();
      } else {
        switch (method) {
          case 'create':
          case 'update':
            return this.store.setItem(this.storageKey, model.toJSON());
          case 'read':
            return this.attributes = this.store.getItem(this.storageKey) || this.defaults || {};
          case 'delete':
            this.store.removeItem(this.storageKey);
            return this.clear({
              silent: true
            });
        }
      }
    },
    destroy: function() {
      return this.sync('delete', this);
    },
    makePersistent: function() {
      this.persistent = true;
      return this.save();
    },
    unpersist: function() {
      this.persistent = false;
      return this.store.removeItem(this.storageKey);
    }
  };
  LocalStorageModel = baseModel.Model.extend;
  return {
    mixin: localStorageModelMixin,
    Model: LocalStorageModel
  };
});
