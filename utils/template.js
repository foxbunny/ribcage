// Generated by CoffeeScript 1.6.3
var define,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __slice = [].slice;

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
      return root.ribcage.utils.template = module;
    };
  }
})(this);

define(function(require) {
  var CompileError, TemplateError, dh;
  dh = require('dahelpers');
  TemplateError = (function(_super) {
    __extends(TemplateError, _super);

    function TemplateError(message, originalError, source) {
      this.message = message;
      this.originalError = originalError;
      this.source = source;
      this.name = 'TemplateError';
    }

    return TemplateError;

  })(Error);
  CompileError = (function(_super) {
    __extends(CompileError, _super);

    function CompileError(message, originalError, source, template) {
      this.message = message;
      this.originalError = originalError;
      this.source = source;
      this.template = template;
      this.name = 'CompileError';
    }

    return CompileError;

  })(Error);
  return {
    syntaxSet: 'underscore',
    syntaxSets: {
      underscore: {
        escaped: /<%-([\s\S]+?)%>/,
        literal: /<%=([\s\S]+?)%>/,
        code: /<%([^-=][\s\S]*?)%>/,
        partial: /<: *([a-zA-Z0-9_$]+(?: (?:[$a-zA-Z0-9_$]+|\{[\s\S]+?\}))?) *:>/,
        comment: /<#([\s\S]+?)#>/
      },
      ribcage: {
        escaped: /\{\{([^=][\s\S]*?)\}\}/,
        literal: /\{{=([\s\S]+?)\}\}/,
        code: /\{%([\s\S]+?)%\}/,
        partial: /\{: *([a-zA-Z0-9_$]+(?: (?:[$a-zA-Z0-9_$]+|\{[\s\S]+?\}))?) *:\}/,
        comment: /\{#([\s\S]+?)#\}/
      }
    },
    partials: {},
    registerPartial: function(name, template) {
      if (typeof template === 'function') {
        return this.partials[name] = template;
      } else {
        return this.partials[name] = this.render(template);
      }
    },
    makeLocal: true,
    extraArguments: {},
    htmlEscape: function(html) {
      return html.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    },
    stringEscape: {
      "'": "'",
      '\\': '\\',
      '\r': 'r',
      '\n': 'n',
      '\t': 't',
      '\u2028': 'u2028',
      '\u2029': 'u2029'
    },
    stringEscapeRe: /\\|'|\r|\n|\t|\u2028|\u2029/g,
    bind: dh,
    render: function(template, data, settings) {
      var args, e, fn, htmlEscape, index, render, s, source, stringEscape, stringEscapeRe, tokensRe;
      if (data == null) {
        data = null;
      }
      if (settings == null) {
        settings = {};
      }
      settings = dh.mixin({}, settings, {
        escaped: this.syntaxSets[this.syntaxSet].escaped,
        literal: this.syntaxSets[this.syntaxSet].literal,
        code: this.syntaxSets[this.syntaxSet].code,
        partial: this.syntaxSets[this.syntaxSet].partial,
        comment: this.syntaxSets[this.syntaxSet].comment,
        partials: this.syntaxSets[this.syntaxSet].partials,
        makeLocal: this.makeLocal,
        htmlEscape: this.htmlEsacpe,
        extraArguments: this.extraArguments,
        bind: this.bind
      });
      htmlEscape = this.htmlEscape;
      tokensRe = new RegExp([settings.escaped.source, settings.literal.source, settings.code.source, settings.partial.source, settings.comment.source].join('|') + '|$', 'g');
      stringEscapeRe = this.stringEscapeRe;
      stringEscape = this.stringEscape;
      source = "    __s += '";
      index = 0;
      template.replace(tokensRe, function(m, escaped, literal, code, partial, comment, offset) {
        var args, name, _ref;
        source += template.slice(index, offset).replace(stringEscapeRe, function(m) {
          return '\\' + stringEscape[m];
        });
        if (escaped) {
          source += "' +\n    ((__v=('' + " + escaped + ")) == null ? '' : __e(__v)) +\n'";
        }
        if (literal) {
          source += "' +\n    ((__v=('' + " + literal + ")) == null ? '' : __v) +\n'";
        }
        if (code) {
          source += "';\n    " + code + "\n__s += '";
        }
        if (partial) {
          _ref = partial.trim().split(' '), name = _ref[0], args = 2 <= _ref.length ? __slice.call(_ref, 1) : [];
          args = args.join(' ');
          source += "' +\n    ((__p['" + name.trim() + "'] || __d).apply('" + name + "', ";
          if (args) {
            source += "[" + args + "].concat([].slice.call(arguments, 1))";
          } else {
            source += "arguments";
          }
          source += ")) +\n    '";
        }
        if (comment) {
          source += "';\n/*" + comment + "*/\n    __s += '";
        }
        index = offset + m.length;
        return m;
      });
      s = "var __s = '';\n";
      s += "var __v;\n";
      s += "var __d = function () { return ''; };\n";
      s += "var self = this;\n";
      s += "var print = function () { __s += [].join.call(arguments, ''); };\n";
      s += 'try {\n';
      if (settings.makeLocal) {
        s += '  with (ctx) {\n';
      }
      s += source;
      s += "';\n";
      s += "    return __s;\n";
      if (settings.makeLocal) {
        s += '  }\n';
      }
      s += '} catch (e) {\n';
      s += "    var __templateError__ = new TemplateError(\n";
      s += "      '' + e + '\\nin template:\\n\\n' + __source__, e, __source__);\n";
      s += '    throw __templateError__;\n';
      s += '}\n';
      args = ['ctx', '__e', '__p', '__source__', 'TemplateError'];
      args = args.concat(Object.keys(settings.extraArguments));
      args = args.concat(s);
      try {
        fn = Function.apply(null, args);
      } catch (_error) {
        e = _error;
        throw new CompileError('template could not be compiled', e, s, template);
      }
      render = function(ctx) {
        var ctxArgs, extras;
        extras = settings.extraArguments;
        ctxArgs = [data, htmlEscape, settings.partials, template, TemplateError];
        ctxArgs = ctxArgs.concat(Object.keys(extras).map(function(k) {
          return extras[k];
        }));
        return fn.apply(settings.bind, ctxArgs);
      };
      if (data != null) {
        return render(data);
      } else {
        return function(data) {
          return render(data);
        };
      }
    },
    template: function() {
      return this.render.apply(this, arguments);
    }
  };
});