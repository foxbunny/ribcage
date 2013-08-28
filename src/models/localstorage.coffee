###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Local storage model
#
# Backbone model with localStorage support
#
# This model is in UMD format, and will create a
# `ribcage.models.LocalStorageModel` global if not used with an AMD loader such
# as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        when '../utils/localstorage' then @ribcage.utils.LocalStorage
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@ribcage or= {}).models or= {}
    @ribcage.models.LocalStorageModel = factory @require

define (require) ->
  Backbone = require 'backbone'
  LocalStorage = require '../utils/localstorage'

  # The `LocalStorageModel` model uses  `LocalStorage` utiltiy class as an
  # abstraction layer for `localStorage` API.
  storage = new LocalStorage()

  # ## `LocalStorageModel`
  #
  # This model extends the native Backbone model.
  LocalStorageModel = Backbone.Model.extend

    # ### `LocalStorageModel.prototype.store`
    #
    # The storage object is accessible through the storage property. It
    # provides the `localStorage`-compatible API for manipulating the HTML5
    # local storage. You can provide a different abstraction layer by
    # overriding this property.
    store: storage

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
      @fetch()

    # ### `LocalStorageModel.prototype.sync(method, model)`
    #
    # This is a customized version of `Backbone.sync()` which stores the data
    # in the `localStorage`. Internally, it communicates with the `#store`
    # object.
    sync: (method, model) ->
      if not @persistent and method in ['create', 'update', 'delete']
        @toJSON()
      else
        switch method
          when 'create', 'update'
            @store.setItem @storageKey, model.toJSON()
          when 'read'
            @attributes = @store.getItem(@storageKey) or @defaults or {}
          when 'delete'
            @store.removeItem @storageKey
            @clear silent: true

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
      @store.removeItem @storageKey



