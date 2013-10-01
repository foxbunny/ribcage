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
# This module (main module) acts as namespace creator when not used with an AMD
# loader such as RequireJS. Please load it _before_ any other Ribcage modules.
#
# ::TOC::
#

if typeof define isnt 'function' or not define.amd
  @define = (factory) =>
    @ribcage or= {}
    @ribcage.models or= {}
    @ribcage.collections or= {}
    @ribcage.views or= {}
    @ribcage.routers or= {}
    @ribcage.modelMixins or= {}
    @ribcage.collectionMixins or= {}
    @ribcage.viewMixins or= {}
    @ribcage.routerMixins or= {}
    @ribcage.validators or= {}
    @ribcage.utils or= {}

define (require) ->

  ## Models
  baseModel = require './models/base'
  localStorageModel = require './models/localstorage'

  ## Collections
  baseCollection = require './collections/base'

  ## Views
  baseView = require './views/base'
  formErrorView = require './views/formerror'
  formExtraView = require './views/formextra'
  baseFormView = require './views/form'
  modelFormView = require './views/modelform'
  createView = require './views/create'
  collectionCreateView = require './views/collectioncreate'
  templateBaseView = require './views/templatebase'
  templateView = require './views/template'
  modalView = require './views/modal'
  modelView = require './views/model'
  redirectView = require './views/redirect'
  loadingView = require './views/loading'
  tabbedView = require './views/tabbed'

  ## Routers
  baseRouter = require './routers/base'
  statefulRouter = require './routers/stateful'

  ## Validators
  methods = require './validators/methods'
  mixins = require './validators/mixins'

  ## Utils
  serializeObject = require './utils/serializeobject'
  deserializeForm = require './utils/deserializeform'
  randString = require './utils/randstring'
  LocalStorage = require './utils/localstorage'
  LocalStore = require './utils/localstore'

  # ## Models
  #
  # The models are accessible through the `ribcage.models` object. There are
  # two models that you can use:
  #
  #  + [`BaseModel`](models/base.mkd) - Provides the base mode functionality
  #    common to all Ribcage models (currently same as stock Backbone model).
  #  + [`LocalStorageModel`](models/localstorage.mkd) - Uses the browser's
  #   `localStorage` API to persist the model data
  #
  models:
    BaseModel: baseModel.Model
    LocalStorageModel: localStorageModel.Model

  # ## Collections
  #
  # The `ribcage.collections` object exposes the Ribcage collections. These are
  # the available collections:
  #
  #  + [`BaseCollection`](collections/base.mkd) - Base collection functionality
  #    for all Ribcage collections.
  #
  collections:
    BaseCollection: baseCollection.Collection

  # ## Views
  #
  # All view constructors are accessible through the `ribcage.views` object.
  # These include:
  #
  #  + [`BaseView`](views/base.mkd) - A view that provides the base
  #    functionality of all Ribcage views
  #  + [`FormErrorView`](views/formerror.mkd) - Provides hooks for displaying
  #    and clearing form error messages
  #  + [`FormExtraView`](views/formextra.mkd) - Provides utitlities for
  #    manipulating form behavior.
  #  + [`BaseFormView`](views/form.mkd) - Provides
  #    basic form manipulation and error handling
  #  + [`ModelFormView`](views/modelform.mkd) - Provides model-specific form
  #    behavior such as data-binding
  #  + [`CreateView`](views/create.mkd) - Simplifies creation of new model
  #    instances server-side
  #  + [`CollectionCreateView`](views/collectioncreate.mkd) - Create view that
  #    uses the collection object to crate a new model.
  #  + [`TempalteBaseView`](views/templatebase.mkd) - Base template view that
  #    provides basic template-handling and nothing else
  #  + [`TemplateView`](views/template.mkd) - Simplifies rendering of templates
  #  + [`ModalView`](views/modal.mkd) - Modal dialog view
  #  + [`ModelView`](views/model.mkd) - Augments `TemplateView` by passing
  #    model data to templates
  #  + [`RedirectView`](views/redirect.mkd) - Simply redirects to a specified
  #    path
  #  + [`LoadingView`](views/loading.mkd) - Displays an AJAX loading spinner
  #  + [`TabbedView`](views/tabbed.mkd) - Subview container with tabbed
  #    navigation.
  #
  views:
    BaseView: baseView.View
    FormError: formErrorView.View
    FormExtraView: formExtraView.View
    BaseFormView: baseFormView.View
    ModelFormView: modelFormView.View
    CreateView: createView.View
    CollectionCreateView: collectionCreateView.View
    TemplateBaseView: templateBaseView.View
    TemplateView: templateView.View
    ModalView: modalView.View
    ModelView: modelView.View
    RedirectView: redirectView.View
    LoadingView: loadingView.View
    TabbedView: tabbedView.View

  # ## Routers
  #
  # All router constructors are accessible thorugh `ribcage.routers` object.
  # These include:
  #
  #  + [`BaseRouter`](routers/base.mkd) - A simple router with view
  #    registration and cleanup logic.
  #  + [`StatefulRouter`](routers/stateful.mkd) - Router that adds support for
  #    application state persistence using localStorage API
  #
  routers:
    BaseRouter: baseRouter.Router
    StatefulRouter: statefulRouter.Router

  # ## Model mixins
  #
  # The `ribcage.modelMixins` object provides access to model mixins. These
  # mixins implement the APIs for matching models, and allow you to easily add
  # their features to other models in your application.
  #
  modelMixins:
    BaseModel: baseModel.mixin
    LocalStorageModel: localStorageModel.mixin

  # ## Collection mixins
  #
  # The `ribcage.collectionMixins` object contains collection mixins. These
  # mixins implement the APIs of matching collections, and you can use them to
  # add their features to your own collections.
  #
  collectionMixins:
    BaseCollection: baseCollection.Collection

  # ## View mixins
  #
  # The `ribcage.viewMixins` object provides access to view mixins. The mixins
  # implement the core APIs for all of the views, and mixins allow you to
  # combine such functionality with your own custom views.
  #
  viewMixins:
    BaseView: baseView.mixin
    FormErrorView: formErrorView.mixin
    FormExtraView: formExtraView.mixin
    BaseFormView: baseFormView.mixin
    ModelFormView: modelFormView.mixin
    CreateView: createView.mixin
    CollectionCreateView: collectionCreateView.mixin
    TemplateBase: templateBaseView.mixin
    TemplateView: templateView.mixin
    ModalView: modalView.mixin
    ModelView: modelView.mixin
    RedirectView: redirectView.mixin
    LoadingView: loadingView.mixin
    TabbedView: tabbedView.mixin

  # ## Router mixins
  #
  # The `ribcage.routerMixins` object contains router mixins. The mixins
  # implement the base APIs for respective Ribcage routers. You can use them to
  # create your own routers with features from different built-in routers.
  #
  routerMixins:
    BaseRouter: baseRouter.mixin
    StatefulRouter: statefulRouter.mixin

  # ## Validators
  #
  # The validation tools are accessible through `ribcage.validators` object.
  # The object contains validation methods (functions that perform
  # validation), and two [validator mixins](validators/mixins.mkd):
  #
  #  + `ValidatingMixin` - Generic mixin that can be used on views.
  #  + `ModelValidatingMixin` - A mixin specific to models.
  #
  # Note that validation methods can also be used to clean up and format your
  # data since they return the data in the format that validator expect it to
  # be in. For example, a `numeric` validator will return a number, regardless
  # of the input value, if the input value can be successfully converted to a
  # number.
  #
  validators:
    methods: methods
    ValidatingMixin: mixins.validatingMixin
    ModelValidatingMixin: mixins.modelValidatingMixin

  # ## Utilities
  #
  # The `ribcage.utils` object gives you access to utility methods. Those are:
  #
  #  + [`serializeObject`](utils/serializeobject.mkd) - Serializes form data
  #    into an object
  #  + [`deserializeForm`](utils/deserializeform.mkd) - Deserializes an object
  #    into a form (fills in the form)
  #  + [`randString`](utils/randstring.mkd) - Random string generator
  #  + [`LocalStorage`](utils/localstorage.mkd) - Wrapper for localStorage API
  #  + [`LocalStore`](utils/localstore.mkd) - REST-like interface for
  #    localStorage API that provides `jQuery.ajax`-compatible interface
  #
  #
  utils:
    serializeObject: serializeObject
    deserializeForm: deserializeForm
    randString: randString
    LocalStorage: LocalStorage
    LocalStore: LocalStore
