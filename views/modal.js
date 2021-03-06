// Generated by CoffeeScript 1.6.3
/*!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
*/

var define;

define = (function(root) {
  var require;
  if (typeof root.define === 'function' && define.amd) {
    return root.define;
  } else {
    require = function(dep) {
      return (function() {
        switch (dep) {
          case './templatebase':
            return root.ribcage.views.templateBaseView;
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
      root.ribcage.views.modalView = module;
      root.ribcage.views.ModalView = module.View;
      return root.ribcage.viewMixins.ModalView = module.mixin;
    };
  }
})(this);

define(function(require) {
  var ModalView, TemplateBaseView, modalViewMixin, _;
  _ = require('underscore');
  TemplateBaseView = require('./templatebase').View;
  modalViewMixin = {
    setTemplate: function(templateSource) {
      var _ref;
      this.templateSource = templateSource;
      if ((_ref = this.contentElement) != null) {
        _ref.html(this.renderTemplate(this.getTemplateContext()));
      }
      return this;
    },
    title: '',
    getTitle: function() {
      return this.title;
    },
    setTitle: function(title) {
      var _ref;
      this.title = title;
      if ((_ref = this.titleElement) != null) {
        _ref.text(title);
      }
      return this;
    },
    overlayStyles: {
      position: 'fixed',
      top: '0',
      left: '0',
      width: '100%',
      height: '100%',
      background: 'rgba(0,0,0,0.5)',
      'z-index': 16777271
    },
    closeIcon: '<span class="icon-remove"></span>',
    getCloseIcon: function() {
      return this.closeIcon;
    },
    setCloseIcon: function(icon) {
      this.closeIcon = icon;
      if (this.closeIconElement != null) {
        return this.closeIconElement.html(this.closeIcon);
      }
    },
    modalTemplate: "<div class=\"modal-dialog\">\n  <h2 class=\"modal-title\">\n    <span class=\"modal-title-text\"><%= title %></span>\n    <span class=\"modal-title-close-icon close\"><%= closeIcon %></span>\n  </h2>\n  <div class=\"modal-content\"><%= content %></div>\n  <% if (buttons) { %>\n    <div class=\"modal-buttons\"><%= buttons %></div>\n  <% } %>\n</div>",
    buttons: '<button class="close">OK</button>',
    getButtons: function() {
      return this.buttons;
    },
    setButtons: function(buttons) {
      var _ref;
      this.buttons = buttons;
      if ((_ref = this.buttonsElements) != null) {
        _ref.html(this.buttons);
      }
      return this;
    },
    dismiss: function(e) {
      var callback;
      this.$el.hide();
      callback = this.onDismissed;
      this.onDismissed = null;
      if (callback) {
        return callback();
      }
    },
    show: function(title, templateSource, callback) {
      if (title != null) {
        this.setTitle(title);
      }
      if (templateSource != null) {
        this.setTemplate(templateSource);
      }
      if (callback != null) {
        this.onDismissed = callback;
      }
      return this.$el.show();
    },
    onDismissed: null,
    createContainer: function() {
      return _.template(this.modalTemplate, {
        title: this.getTitle(),
        content: this.template(this.getTemplateContext()),
        buttons: this.getButtons(),
        closeIcon: this.getCloseIcon()
      });
    },
    render: function() {
      this.modal = this.$el;
      if (this.overlayStyles != null) {
        this.modal.css(this.overlayStyles);
      }
      this.modal.hide();
      this.modal.html(this.createContainer());
      this.titleElement = this.modal.find('.modal-title-text');
      this.contentElement = this.modal.find('.modal-content');
      this.buttonsElement = this.modal.find('.modal-buttons');
      this.closeIconElement = this.modal.find('.modal-title-close-icon');
      return this;
    },
    events: {
      'click .close': 'dismiss'
    }
  };
  ModalView = TemplateBaseView.extend(modalViewMixin);
  return {
    mixin: modalViewMixin,
    View: ModalView
  };
});
