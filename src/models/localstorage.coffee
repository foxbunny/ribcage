###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Local storage model
#
# Backbone model with localStorage support
#
# This model is in UMD format, and will create a
# `ribcage.models.localStorageModel`, `ribcage.models.LocalStorageModel`, and
# `ribcage.modelMixins.LocalStorageModel` globals if not used with an AMD
# loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'underscore' then @_
        when './base' then @ribcage.models.baseModel
        when '../utils/localstorage' then @ribcage.utils.LocalStorage
        when '../utils/localstore' then @ribcage.utils.LocalStore
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    module = @ribcage.models.localStorageModel = factory @require
    @ribcage.models.LocalStorageModel = module.Model
    @ribcage.modelMixins.LocalStorageModel = module.mixin

# This model depends on `ribcage.models.base`, and `ribcage.utils.localstorage`
# modules.
define (require) ->
  _ = require 'underscore'
  baseModel = require './base'
  LocalStorage = require '../utils/localstorage'
  LocalStore = require '../utils/localstore'

  # The `LocalStorageModel` model uses  `LocalStorage` utiltiy class as an
  # abstraction layer for `localStorage` API.
  storage = new LocalStorage()

  # ## `localStorageModelmixin`
  #
  # This mixin implements the API of the `LocalStorageModel`.
  localStorageModelMixin =

    # ### `LocalStorageModel.prototype.store`
    #
    # The storage object is accessible through the storage property. It will be
    # initialized when model is initialized, so overriding this property does
    # nothing.
    store: null

    # ### `LocalStorageModel.prototype.storageKey`
    #
    # The `localStorage` key for this model.
    storageKey: null

    # ### `LocalStorageModel.prototype.persistent`
    #
    # A flag that tells the model to persist its data in the storage when
    # `#sync()` is called. If this flag is set to `false`, syncing will be
    # disabled for all operations except reads.
    persistent: true

    # ### `LocalStorageModel.prototype.initialize()`
    #
    # The model data is automatically fetched when model is initialized.
    initialize: () ->
      @store = new LocalStore(@storageKey, storage, @idProperty)

    # ### `LocalStorageModel.prototype.sync(method, model, options)`
    #
    # This is a customized version of `Backbone.sync()` which stores the data
    # in the `localStorage`. Internally, it communicates with the `#store`
    # object.
    sync: (method, model, options={}) ->
      methodMap =
        read: 'GET'
        create: 'POST'
        update: 'PUT'
        patch: 'PATCH'
        delete: 'DELETE'

      # If the `forceCreate` option has been passed, we will allow the 'update'
      # method to be converted to 'create', and a `noFail` setting to be
      # passed. This is useful in cases where you want to create a record and
      # set the ID yourself.
      if options.forceCreate and method is 'update'
        method = 'create'
        options.noFail = true

      dataMethods = ['create', 'update', 'patch']
      alterMethods = dataMethods.concat ['delete']

      if not @persistent and method in alterMethods
        options.success(model.attributes)

      if method in dataMethods
        options.data = if model then model.attributes or null

      # Add dummy callbacks if option is not specified
      options.success or= () ->
      options.error or= () ->

      url = options.url = model.id or null
      options.type = methodMap[method]
      @store.query url, options

    # ### `LocalStorageModel.prototype.destroy()`
    #
    # Rewired to call `#sync()`. This seems to be necessary for the
    # `#destroy()` call to work at all.
    destroy: () ->
      @sync 'delete', this

    # ### `LocalStorageModel.prototype.makePersistent()`
    #
    # Makes the model persistent by setting its `#persistent` flag, and saving
    # it immediately afterwards.
    #
    # Note that calling this method does _not_ trigger the 'change' event.
    makePersistent: () ->
      @persistent = true
      @save()

    # ### `LocalStorageModel.prototype.unpersist()`
    #
    # Makes the model non-persistent by setting its `#persistent` flag to
    # `false`, and by removing the stored data.
    #
    # Note that calling this method does _not_ trigger the 'change' event.
    unpersist: () ->
      @persistent = false
      @store.destroyStore()

  # ## `LocalStorageModel`
  #
  # Please see the documentation on the `localStorageModelMixin` for more
  # information about this model's API.
  LocalStorageModel = baseModel.Model.extend localStorageModelMixin

  mixin: localStorageModelMixin
  Model: LocalStorageModel

