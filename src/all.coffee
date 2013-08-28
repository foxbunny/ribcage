###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Ribcage
#
# This module is a one-stop-shop for all the Ribcage modules. It imports all
# modules in the `ribcage` directory and makes them available through a single
# object. If you only need to access parts of the Ribcage library, you should
# instead manually require individual modules.
#
# This module is in UMD format, and will only be useful if used with an AMD
# loader such as RequireJS. For convenience and compatibility, it will simply
# return the `ribcage` global when used without the loader.

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    # If we are not using AMD, we assume that all the dependencies have already
    # been loaded, and that they have created their respective property trees
    # under the `ribcage` global, so we simply return it.
    @ribcage

define (require) ->

  # Models
  SoapModel = require './models/soap'
  LocalStorageModel = require './models/localstorage'

  # Views
  baseFormView = require './views/form'
  modelFormView = require './views/modelform'
  createView = require './views/create'
  templateView = require './views/template'
  modelView = require './views/model'
  redirectView = require './views/redirect'
  loadingView = require './views/loading'

  # Validators
  methods = require './validators/methods'
  mixins = require './validators/mixins'

  # Utils
  serializeObject = require './utils/serializeobject'
  deserializeForm = require './utils/deserializeForm'


  models:
    SoapModel: SoapModel
    LocalStorageModel: LocalStorageModel
  views:
    BaseFormView: baseFormView.View
    ModelFormView: modelFormView.View
    CreateView: createView.View
    TemplateView: templateView.View
    ModelView: modelView.View
    RedirectView: redirectView.View
    LoadingView: loadingView.View
  viewMixins:
    BaseFormView: baseFormView.mixin
    ModelFormView: modelFormView.mixin
    CreateView: createView.mixin
    TemplateView: templateView.mixin
    ModelView: modelView.mixin
    RedirectView: redirectView.mixin
    LoadingView: loadingView.mixin
  validators:
    methods: methods
    ValidatingMixin: mixins.validatingMixin
    ModelValidatingMixin: mixins.modelValidatingMixin
  utils:
    serializeObject: serializeObject
    deserializeForm: deserializeForm

