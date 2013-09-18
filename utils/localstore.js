// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var define;

define = (function(root) {
  var require,
    _this = this;
  if (typeof root.define === 'function' && root.define.amd) {
    return root.define;
  } else {
    require = function(dep) {
      return (function() {
        switch (dep) {
          case 'dahelpers':
            return root.dahelpers;
          case './localstorage':
            return root.ribcage.utils.LocalStorage;
          default:
            return null;
        }
      })() || (function() {
        throw new Error("Unmet dependency " + dep);
      })();
    };
    return function(factory) {
      return root.ribcage.utils.LocalStore = factory(require);
    };
  }
})(this);

define(function(require) {
  var EMPTY, LocalStorage, LocalStore, extend, randString, toArray, type, _ref;
  _ref = require('dahelpers'), extend = _ref.extend, toArray = _ref.toArray, type = _ref.type;
  LocalStorage = require('./localstorage');
  randString = require('./randstring');
  EMPTY = {
    data: [],
    index: {}
  };
  return LocalStore = (function() {
    function LocalStore(key, storage, idProperty) {
      this.key = key;
      this.storage = storage;
      this.idProperty = idProperty != null ? idProperty : 'id';
      this.restorePoint = null;
    }

    LocalStore.prototype.getStore = function() {
      return this.storage.getItem(this.key) || EMPTY;
    };

    LocalStore.prototype.setRestorePoint = function() {
      return this.restorePoint = this.getStore();
    };

    LocalStore.prototype.clearRestorePoint = function() {
      return this.restorePoint = null;
    };

    LocalStore.prototype.restore = function() {
      if (!this.restorePoint) {
        throw new Error("No restore point found");
      }
      return this.storage.setItem(this.key(this.restorePoint));
    };

    LocalStore.prototype.destroyStore = function() {
      return this.storage.removeItem(this.key);
    };

    LocalStore.prototype.getAll = function() {
      return this.getStore().data;
    };

    LocalStore.prototype.idIsUnique = function(id) {
      var index;
      index = this.getStore().index;
      return !(id in index);
    };

    LocalStore.prototype.addItem = function(item) {
      var store;
      store = this.getStore();
      store.data.push(item);
      store.index[item[this.idProperty]] = store.data.length - 1;
      this.storage.setItem(this.key, store);
      return item;
    };

    LocalStore.prototype.removeItem = function(idx) {
      var id, store;
      store = this.getStore();
      id = store.data[idx][this.idProperty];
      store.data = store.data.splice(idx, 1);
      delete store.index[id];
      return this.storage.setItem(this.key, store);
    };

    LocalStore.prototype.updateItem = function(idx, data) {
      var store;
      store = this.getStore();
      store.data[idx] = data;
      this.storage.setItem(this.key, store);
      return data;
    };

    LocalStore.prototype.patchItem = function(idx, data) {
      var patchedData, store;
      store = this.getStore();
      patchedData = extend(store.data[idx], data);
      store.data[idx] = patchedData;
      this.storage.setItem(this.key, store);
      return patchedData;
    };

    LocalStore.prototype.getIndexOf = function(id) {
      return this.getStore().index[id];
    };

    LocalStore.prototype.getIndexSafe = function(id) {
      var idx;
      idx = this.getIndexOf(id);
      if (idx == null) {
        throw new Error("Object with ID " + id + " not found");
      }
      return idx;
    };

    LocalStore.prototype.getOne = function(id) {
      var items;
      items = this.getAll();
      return items[this.getIndexSafe(id)];
    };

    LocalStore.prototype.createOne = function(data, noFail) {
      var id, _name;
      id = data[_name = this.idProperty] || (data[_name] = randString.generateRandStr());
      if (id && !this.idIsUnique(id)) {
        if (noFail) {
          return this.getOne(id);
        } else {
          throw new Error("Object with ID " + id + " already exists");
        }
      }
      return this.addItem(data);
    };

    LocalStore.prototype.createAll = function(data, noFail) {
      var createdData, e, index, item, _i, _len;
      data = toArray(data);
      this.setRestorePoint();
      createdData = [];
      try {
        for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
          item = data[index];
          createdData.push(this.createOne(item, noFail));
        }
      } catch (_error) {
        e = _error;
        this.restore();
        throw new Error("Create operation failed for item " + index);
      }
      this.clearRestorePoint();
      return createdData;
    };

    LocalStore.prototype.updateOne = function(id, data) {
      return this.updateItem(this.getIndexSafe(id), data);
    };

    LocalStore.prototype.updateAll = function(data) {
      var e, id, index, item, updatedData, _i, _len;
      data = toArray(data);
      this.setRestorePoint();
      updatedData = [];
      try {
        for (index = _i = 0, _len = data.length; _i < _len; index = ++_i) {
          item = data[index];
          id = item[this.idProperty];
          updatedData.push(this.updateOne(id, item));
        }
      } catch (_error) {
        e = _error;
        this.restore();
        throw new Error("Updated failed for item with ID " + id);
      }
      this.clearRestorePoint();
      return updatedData;
    };

    LocalStore.prototype.patchOne = function(id, data) {
      return this.patchItem(this.getIndexSafe(id), data);
    };

    LocalStore.prototype.patchAll = function(data) {
      var e, id, item, patchedData, _i, _len;
      data = toArray(data);
      this.setRestorePoint();
      patchedData = [];
      try {
        for (_i = 0, _len = data.length; _i < _len; _i++) {
          item = data[_i];
          id = data[this.idProperty];
          patchedData.push(this.patchOne(id, item));
        }
      } catch (_error) {
        e = _error;
        this.restore();
        throw new Error("Patch failed for item with ID " + id);
      }
      this.clearRestorePoint();
      return patchedData;
    };

    LocalStore.prototype.deleteOne = function(id) {
      var index;
      index = this.getIndexOf(id);
      if (index == null) {
        throw new Error("Object with ID " + id + " not found");
      }
      return this.removeItem(index);
    };

    LocalStore.prototype.deleteAll = function(ids) {
      var e, id, index, _i, _len;
      if (ids == null) {
        ids = null;
      }
      if (!ids) {
        return this.destroyStore();
      }
      this.setRestorePoint();
      try {
        for (_i = 0, _len = ids.length; _i < _len; _i++) {
          id = ids[_i];
          index = this.getIndexOf(id);
          this.removeItem(index);
        }
      } catch (_error) {
        e = _error;
        this.restore();
        throw new Error("Could not delete object with ID " + id);
      }
      return this.clearRestorePoint();
    };

    LocalStore.prototype.GET = function(id) {
      if (id != null) {
        return this.getOne(key, id);
      } else {
        return this.getAll(key);
      }
    };

    LocalStore.prototype.PUT = function(id, data) {
      if (id != null) {
        return this.updateOne(id, data);
      } else {
        return this.updateAll(data);
      }
    };

    LocalStore.prototype.POST = function(id, data, noFail) {
      if (type(data, 'array')) {
        return this.createAll(data, noFail);
      } else {
        return this.createOne(data, noFail);
      }
    };

    LocalStore.prototype.PATCH = function(id, data) {
      if (id != null) {
        return this.patchOne(id, data);
      } else {
        return this.patchAll(data);
      }
    };

    LocalStore.prototype.DELETE = function(id, data) {
      if (id != null) {
        return this.deleteOne(id);
      } else {
        return this.deleteAll(data);
      }
    };

    LocalStore.prototype.query = function(url, _arg) {
      var data, e, error, id, noFail, success, type;
      data = _arg.data, type = _arg.type, noFail = _arg.noFail, error = _arg.error, success = _arg.success;
      id = url;
      try {
        return success(this[type.toUpperCase()](id, data, noFail));
      } catch (_error) {
        e = _error;
        return error(e);
      }
    };

    return LocalStore;

  })();
});
