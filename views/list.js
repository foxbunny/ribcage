// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var define;

define = (function(root) {
  var require;
  if (typeof root.define === 'function' && root.define.amd) {
    return root.define;
  } else {
    require = function(dep) {
      return (function() {
        switch (dep) {
          case 'underscore':
            return root._;
          case 'ribcage/views/template':
            return ribcage.views.templateView;
          default:
            return null;
        }
      })() || (function() {
        throw new Error("Unmet dependency " + dep);
      })();
    };
    return function(factory) {
      var module;
      module = factory(require);
      ribcage.views.listView = module;
      ribcage.views.ListView = module.View;
      return ribcage.viewMixins.ListView = module.mixin;
    };
  }
})(this);

define(function(require) {
  var ListView, TemplateView, listViewMixin, _;
  _ = require('underscore');
  TemplateView = require('ribcage/views/template').View;
  return {
    mixin: listViewMixin = {
      templateSource: "<ul><%= items.join('') %></ul>",
      useRawModel: false,
      itemTemplateSource: '',
      itemTemplate: function(data) {
        return _.template(this.itemTemplateSource, data);
      },
      getModels: function() {
        return this.collection.models;
      },
      getItemData: function(model) {
        if (this.useRawModel) {
          return {
            item: model
          };
        } else {
          return model.toJSON();
        }
      },
      getTemplateContext: function() {
        var item;
        return {
          items: (function() {
            var _i, _len, _ref, _results;
            _ref = this.getModels();
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              _results.push(this.itemTemplate(this.getItemData(item)));
            }
            return _results;
          }).call(this)
        };
      }
    },
    View: ListView = TemplateView.extend(listViewMixin)
  };
});
