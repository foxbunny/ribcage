/**
 * @author Branko Vukelic <branko@brankovukelic.com>
 * @license MIT
 */

# # Local storage model
#
# Model with localStorage support.
#
# This model is in UMD format, and will create a
# `ribcage.models.localStorageModel`, `ribcage.models.LocalStorageModel`, and
# `ribcage.modelMixins.LocalStorageModel` globals if not used with an AMD
# loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' && root.define.amd
    root.define
  else
    require = (dep) ->
      do ->
        switch dep
        | './base'                => root.ribcage.models.base-model
        | '../utils/localstorage' => root.ribcage.utils.LocalStorage
        | '../utils/localstore'   => root.ribcage.utils.LocalStore
        | otherwise               => null
      or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory require
      r = root.{}ribcage
      r.{}models.local-storage-model = module
      r.models.LocalStorageModel = module.Model
      r.{}model-mixins.LocalStorageModel = module.mixin
) this

define (require) ->

  # This model depends on `ribcage/models/base`, `ribcage/utils/localstore`,
  # and `ribcage/utils/localstorage` modules.
  #
  require! './base'.Model
  rqeuire! LocalStorage: '../utils/localstorage'
  require! LocalStore: '../utils/localstore'

  # The `LocalStorageModel` model uses  `LocalStorage` utiltiy class as an
  # abstraction layer for `localStorage` API.
  #
  storage = new LocalStorage()

  # ::TOC::
  #

  # ## `mixin`
  #
  # This mixin implements the API of the `LocalStorageModel`.
  #
  mixin: LocalStorageModelMixin =

    # ### `#store`
    #
    # The storage object is accessible through the storage property. It will be
    # initialized when model is initialized, so overriding this property does
    # nothing.
    #
    store: null

    # ### `#storageKey`
    #
    # The `localStorage` key for this model.
    #
    storage-key: null

    # ### `#persistent`
    #
    # A flag that tells the model to persist its data in the storage when
    # `#sync()` is called. If this flag is set to `false`, syncing will be
    # disabled for all operations except reads.
    #
    persistent: true

    # ### `#initialize()`
    #
    # It is extremely important to remember not to overload this method, or to
    # call the original one if you are overloading it. This method sets up a
    # store that will handle all the communication between the model and
    # localStorage.
    #
    # Here is a proper way to overload this method should you need to do so:
    #
    #     var MyLocalStorageModel = LocalStorageModel.extend({
    #       initialize: function() {
    #         // Do your thing
    #         LocalStorageModel.prototype.initialize.call this
    #       }
    #     });
    #
    # And same in CoffeeScript:
    #
    #     MyLocalStorageModel = LocalStorageModel.extend
    #       initialize: () ->
    #         # Do your thing
    #         LocalStorageModel::initialize.call this
    #
    # For more information on the low-level API of the store, look at the
    # documentation for `ribcage.utils.LocalStore`.
    #
    initialize: ->
      @store = new LocalStore @storage-key, storage, @id-property

    # ### `#sync(method, model, options)`
    #
    # This is a customized version of `Backbone.sync()` which stores the data
    # in the localStorage. Internally, it communicates with the `#store`
    # object.
    #
    # The options object can can be passed with `forceCreate` option which
    # essentially allows the `update` method to be converted to a `create` if
    # the object already exists. This can be used to create objects where the
    # ID has to be known in advance, or when you want to create an object 'just
    # in case' it doesn't already exist.
    #
    sync: (method, model, options={}) ->
      methodMap =
        read: 'GET'
        create: 'POST'
        update: 'PUT'
        patch: 'PATCH'
        delete: 'DELETE'

      if options.force-create and method is 'update'
        method = 'create'
        options.no-fail = true

      data-methods = ['create', 'update', 'patch']
      alter-methods = data-methods.concat ['delete']

      if (not @persistent) and (method in alter-methods)
        options.success model.attributes

      if method in dataMethods
        options.data = if model then model.attributes else null

      # Add dummy callbacks if option is not specified
      options.success ?= ->
      options.error ?= ->

      url = options.url = model.id or null
      options.type = methodMap[method]
      @store.query url, options

    # ### `#destroy()`
    #
    # Rewires the call to `#sync()` so it doesn't matter whether the object has
    # an ID or not (it doesn't matter whether it is new).
    #
    # Note that the current implementation does not trigger any events. This
    # will be fixed in future releases.
    #
    destroy: ->
      return if not @persistent
      @sync 'delete', this

    # ### `#makePersistent()`
    #
    # Makes the model persistent by setting its `#persistent` flag, and saving
    # it immediately afterwards.
    #
    # Note that calling this method does _not_ trigger the 'change' event.
    #
    makePersistent: ->
      @persistent = true
      @save!

    # ### `#unpersist()`
    #
    # Makes the model non-persistent by setting its `#persistent` flag to
    # `false`, and by removing the entire store (along with any previously
    # stored data).
    #
    # Note that calling this method does _not_ trigger the 'change' event.
    #
    unpersist: ->
      @persistent = false
      @store.destroy-store!

  # ## `LocalStorageModel`
  #
  # Please see the documentation on the # [mixin](#mixin) for more information
  # about this model's API.
  #
  Model: class LocalStorageModel extends Model
    implements LocalStorageModelMixin

