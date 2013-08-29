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
  baseModel = require './models/base'
  soapModel = require './models/soap'
  localStorageModel = require './models/localstorage'

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

  # ## Models
  #
  # The models are accessible thorugh the `ribcage.models` object. There are
  # two moedels that you can use:
  #
  #  + `BaseModel` - Provides the base mode functionality common to all Ribcage
  #    models (currently same as stock Backbone model).
  #  + `SoapModel` - Provides functionality for consuiming SOAP services
  #  + `LocalStorageModel` - Uses the browser's `localStorage` API to persist
  #    the model data
  models:
    BaseModel: baseModel.Model
    SoapModel: soapModel.Model
    LocalStorageModel: localStorageModel.Model

  # ## Views
  #
  # All view constructors are accessible through the `ribcage.views` object.
  # These include:
  #
  #  + `BaseFormView` - Provides basic form manipulation and error handling
  #  + `ModelFormView` - Provides model-specific form behavior such as
  #    data-binding
  #  + `CreateView` - Simplifies creation of new model instances server-side
  #  + `TemplateView` - Simplifies rendering of templates
  #  + `ModelView` - Augments `TemplateView` by passing model data to templates
  #  + `RedirectView` - Simply redirects to a specified path
  #  + `LoadingView` - Displays an AJAX loading spinner
  views:
    BaseFormView: baseFormView.View
    ModelFormView: modelFormView.View
    CreateView: createView.View
    TemplateView: templateView.View
    ModelView: modelView.View
    RedirectView: redirectView.View
    LoadingView: loadingView.View

  # ## Model mixins
  #
  # The `ribcage.modelMixins` object provides access to model mixins. These
  # mixins implement the APIs for matching models, and allow you to easily add
  # their features to other models in your application.
  modelMixins:
    BaseModel: baseModel.mixin
    SoapModel: soapModel.mixin
    LocalStorageModel: localStorageModel.mixin

  # ## View mixins
  #
  # The `ribcage.viewMixins` object provides access to view mixins. The mixins
  # implement the core APIs for all of the views, and mixins allow you to
  # combine such functionality with your own custom views.
  viewMixins:
    BaseFormView: baseFormView.mixin
    ModelFormView: modelFormView.mixin
    CreateView: createView.mixin
    TemplateView: templateView.mixin
    ModelView: modelView.mixin
    RedirectView: redirectView.mixin
    LoadingView: loadingView.mixin

  # ## Validators
  #
  # The validation tools are accessible through `ribcage.validators` object.
  # The object contains validation methods (fucntions that peroform
  # validation), and two validator mixins:
  #
  #  + `ValidatingMixin` - Generic mixin that can be used on views.
  #  + `ModelValidatingMixin` - A mixin specific to models.
  #
  # Note that validation methods can also be used to clean up and format your
  # data since they return the data in the format that validator expect it to
  # be in. For example, a `numeric` validator will return a number, regardless
  # of the input value, if the input value can be successfully converted to a
  # number.
  validators:
    methods: methods
    ValidatingMixin: mixins.validatingMixin
    ModelValidatingMixin: mixins.modelValidatingMixin

  # ## Utilities
  #
  # The `ribcage.utils` object gives you access to utility methods. Those are:
  #
  #  + `serializeObject` - Serializes form data into an object
  #  + `deserializeForm` - Deserializes an object into a form (fills in the
  #    form)
  utils:
    serializeObject: serializeObject
    deserializeForm: deserializeForm

