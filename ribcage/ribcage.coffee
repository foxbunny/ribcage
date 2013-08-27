# # Ribcage
#
# This module is a one-stop-shop for all the Ribcage modules. It imports all
# modules in the Ribcage directory and makes them available through a single
# object. If you only need to access parts of the Ribcage library, you should
# instead manually require individual modules.
#
# This module is in UMD format, and will only be useful if used with an AMD
# loader such as RequireJS. For convenience and compatibility, it will simply
# return the `Ribcage` global when used without the loader.

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    # If we are not using AMD, we assume that all the dependencies have already
    # been loaded, and that they have created their respective property trees
    # under the `Ribcage` global, so we simply return it.
    @Ribcage

define (require) ->

  # Models
  SoapModel = require 'ribcage/models/soap'
  LocalStorageModel = require 'ribcage/models/localstorage'

  # Views
  baseFormView = require 'ribcage/views/form'
  modelFormView = require 'ribcage/views/modelform'
  createView = require 'ribcage/views/create'
  templateView = require 'ribcage/views/template'
  redirectView = require 'ribcage/views/redirect'
  loadingView = require 'ribcage/views/loading'

  # Validators
  methods = require 'ribcage/validators/methods'
  mixins = require 'ribcage/validators/mixins'

  # Utils
  serializeObject = require 'ribcage/utils/serializeobject'
  deserializeForm = require 'ribcage/utils/deserializeForm'


  models:
    SoapModel: SoapModel
    LocalStorageModel: LocalStorageModel
  views:
    BaseFormView: baseFormView.View
    ModelFormView: modelFormView.View
    CreateView: createView.View
    TemplateView: templateView.View
    RedirectView: redirectView.View
    LoadingView: loadingView.View
  viewMixins:
    BaseFormView: baseFormView.mixin
    ModelFormView: modelFormView.mixin
    CreateView: createView.mixin
    TemplateView: templateView.mixin
    RedirectView: redirectView.mixin
    LoadingView: loadingView.mixin
  validators:
    methods: methods
    ValidatingMixin: mixins.validatingMixin
    ModelValidatingMixin: mixins.modelValidatingMixin
  utils:
    serializeObject: serializeObject
    deserializeForm: deserializeForm

