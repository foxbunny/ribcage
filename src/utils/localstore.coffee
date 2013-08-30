###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # REST interface for localStorage
#
# This module implements a `LocalStore` constructor which provides an API
# similar to `jQuery.ajax`.
#
# This module is in UMD format and will create a `ribcage.utils.LocalStore`
# global if not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'underscore' then @_
        when './localstorage' then @ribcage.utils.LocalStorage
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    @ribcage.utils.LocalStore = factory @require

define (require) ->
  _ = require 'underscore'
  LocalStorage = require './localstorage'
  randString = require './randstring'

  EMPTY =
    data: []
    index: {}

  # ## `LocalStore(key, storage, [idProperty])`
  #
  # The store is initialized with `key` to be used to store the data,
  # `idProperty` to be used to look up object's ID, and `storage` which is an
  # object that implements localStorage API.
  #
  # `storage` can be `window.localStorage`, but we use `LocalStorage`
  # constructor by default.
  #
  # Internally all data is stored under the specified key as an object with two
  # properties:
  #
  #     {
  #       data: [...],
  #       index: {...}
  #     }
  #
  # The index is a simple look-up table that maps IDs to array indices. The
  # index is used to look up objects by ID, while the actual data is stored in
  # the data array.
  class LocalStore
    constructor: (@key, @storage, @idProperty='id') ->
      @restorePoint = null

    # ### `LocalStore.prototype.getStore()`
    #
    # Returns the store object with `data` and `index` keys. New one is
    # returned if the key does not contain one yet.
    getStore: () ->
      @storage.getItem(@key) or EMPTY

    # ### `LocalStore.prototype.setRestorePoint()`
    #
    # Saves the current state of the localStorage key in `#restorePoint`
    # property.
    setRestorePoint: () ->
      @restorePoint = @getStore()

    # ### `LocalStore.prototype.clearRestorePoint()`
    #
    # Removes the saved localStorage state.
    clearRestorePoint: () ->
      @restorePoint = null

    # ### `LocalStore.prototype.restore()`
    #
    # Restores saved localStorage key to localStorage.
    restore: () ->
      throw new Error "No restore point found" if not @restorePoint
      @storage.setItem @key @restorePoint

    # ### `LocalStore.prototype.destroyStore()`
    #
    # Removes all data from localStorage.
    destroyStore: () ->
      @storage.removeItem @key

    # ### `LocalStore.prototype.getAll()`
    #
    # Returns all data.
    getAll: () ->
      @getStore().data

    # ### `LocalStore.prototype.idIsUnique(id)`
    #
    # Returns `false` if `id` is found in the index.
    idIsUnique: (id) ->
      {index} = @getStore()
      id not of index

    # ### `LocalStore.prototype.addItem(item)`
    #
    # Adds a single item to the store and updates the index.
    addItem: (item) ->
      store = @getStore()
      store.data.push(item)
      store.index[item[@idProperty]] = store.data.length - 1
      @storage.setItem @key, store
      item

    # ### `LocalStore.prototype.removeItem(idx)`
    #
    # Removes an item with index of `idx` and updates the index.
    removeItem: (idx) ->
      store = @getStore()
      id = store.data[idx][@idProperty]
      store.data = store.data.splice idx, 1
      delete store.index[id]
      @storage.setItem @key, store

    # ### `LocalStore.prototype.updateItem(idx, data)`
    #
    # Updates an item with index of `idx` with `data`. Existing keys are
    # overwritten or removed if not present in the `data` object.
    updateItem: (idx, data) ->
      store = @getStore()
      store.data[idx] = data
      @storage.setItem @key, store
      data

    # ### `LocalStore.prototype.patchItem(idx, data)`
    #
    # Patches a single item using `data` object. The existing keys that do not
    # exist in `data` are retained.
    patchItem: (idx, data) ->
      store = @getStore()
      patchedData = _.extend store.data[idx], data
      store.data[idx] = patchedData
      @storage.setItem @key, store
      patchedData

    # ### `LocalStore.prototype.getIndexOf(id)`
    #
    # Returns the index of an item with an ID of `id`.
    getIndexOf: (id) ->
      {index} = @getStore()
      index[id]

    # ### `LocalStore.prototype.getIndexSafe(id)`
    #
    # Wraps around `#getIndexOf()` and throws an exception if the `id` does not
    # exist in the index.
    getIndexSafe: (id) ->
      idx = @getIndexOf(id)
      throw new Error "Object with ID #{id} not found" if not idx?
      idx

    # ### `LocalStore.prototype.getOne(id)
    #
    # Return an item with the ID of `id`. If no such item is found, an
    # exception is thrown.
    getOne: (id) ->
      items = @getAll()
      items[@getIndexSafe id]

    # ### `LocalStore.prototype.createOne(data)`
    #
    # Create a single item and return its data. If the `data` contains a valid
    # ID, and the ID is not unique (it already exists in the index),
    createOne: (data, noFail) ->
      id = data[@idProperty] or= randString.generateRandStr()
      if id and not @idIsUnique id
        if noFail
          return @getOne(id)
        else
          throw new Error "Object with ID #{id} already exists"
      @addItem data

    # ### `LocalStore.prototype.createAll(data)`
    #
    # If passed an array of items to create, it will create them one by one. It
    # rolls back the changes if any of the items fail to create.
    createAll: (data, noFail) ->
      data = [data] if not _.isArray data
      @setRestorePoint()
      createdData = []
      try
        for item, index in data
          createdData.push @createOne item, noFail
      catch e
        @restore()
        throw new Error "Create operation failed for item #{index}"
      @clearRestorePoint()
      createdData

    # ### `LocalStore.prototype.updateOne(id, data)`
    #
    # Updates an item with an ID of `id` using `data`. If the `id` does not
    # exist, an exception will be thrown.
    updateOne: (id, data) ->
      @updateItem @getIndexSafe(id), data

    # ### `LocalStore.prototype.updateAll(data)`
    #
    # Takes an array of item data and updates each item. It is assumed that
    # data for each item also contains the item's ID.
    #
    # The store will be rolled back if an item fails to update.
    updateAll: (data) ->
      data = [data] if not _.isArray data
      @setRestorePoint()
      updatedData = []
      try
        for item, index in data
          id = item[@idProperty]
          updatedData.push @updateOne id, item
      catch e
        @restore()
        throw new Error "Updated failed for item with ID #{id}"
      @clearRestorePoint()
      updatedData

    # ### `LocalStore.prototype.patchOne(id, data)`
    #
    # Patches an item with ID of `id` using `data`. If the `id` is not found in
    # the index, an exception is thrown.
    patchOne: (id, data) ->
      @patchItem @getIndexSafe(id), data

    # ### `LocalStore.prototype.patchAll(data)`
    #
    # Patches multiple items using an array of `data`. It is assumed that each
    # item in the `data` array contains the ID of the item.
    patchAll: (data) ->
      data = [data] if not _.isArray data
      @setRestorePoint()
      patchedData = []
      try
        for item in data
          id = data[@idProperty]
          patchedData.push @patchOne id, item
      catch e
        @restore()
        throw new Error "Patch failed for item with ID #{id}"
      @clearRestorePoint()
      patchedData

    # ### `LocalStore.prototype.deleteOne(id)`
    #
    # Deletes an item with an ID of `id`. An exception will be thrown if the
    # `id` is not found in the index.
    deleteOne: (id) ->
      index = @getIndexOf id
      throw new Error "Object with ID #{id} not found" if not index
      @deleteItem index

    # ### `LocalStore.prototype.deleteAll([ids])`
    #
    # Deletes multiple items, or clears the store. The optional `ids` argument
    # should be an array of IDs. If not specified, the store is cleared.
    #
    # If IDs are specified, each item with matching ID is removed. If an item
    # fails to delete, the store will be rolled back.
    deleteAll: (ids=null) ->
      if not ids
        return @destroyStore()

      @setRestorePoint()
      try
        for id in ids
          index = @getIndexOf id
          @deleteItem index
      catch e
        @restore()
        throw new Error "Could not delete object with ID #{id}"
      @clearRestorePoint()

    # ### `LocalStore.prototype.GET`
    #
    # Handles the pretend GET request.
    GET: (id) ->
      if id? then @getOne key, id
      else @getAll key

    # ### `LocalStore.prototype.PUT`
    #
    # Handles the pretend PUT request.
    PUT: (id, data) ->
      if id? then @updateOne id, data
      else @updateAll data

    # ### `LocalStore.prototype.POST`
    #
    # Handles the pretend POST request.
    POST: (id, data, noFail) ->
      if _.isArray data then @createAll data, noFail
      else @createOne data, noFail

    # ### `LocalStore.prototype.PATCH`
    #
    # Handles the pretend PATCH request.
    PATCH: (id, data) ->
      if id? then @patchOne id, data
      else @patchAll data

    # ### `LocalStore.prototype.DELETE`
    #
    # Handles the pretend DELETE request.
    DELETE: (id, data) ->
      if id? then @deleteOne id
      else @deleteAll data

    # ### `LocalStorage.prototype.query(url, settings)`
    #
    # jQuery.ajax-compatible API for `LocalStorage`.
    #
    # The URL of the request is used as the ID. You can set it to `null` to
    # operate on the whole collection.
    #
    # The settings accepted by `#query()` are following:
    #
    #  + `data` - Request data
    #  + `type` - Request method (GET, POST, PUT, PATCH, DELETE)
    #  + `noFail` - Whether to fail silently on POST if record exists
    #  + `error` - Error callback
    #  + `success` - Success callback
    #
    # `noFail` is a non-standard argument that essentially turns POST into a
    # GET if record already exists. Note that it does not try to update any
    # data, and does not trigger any errors. You will not be able to
    # programmatically determine if the record has been created or retrieved
    # simply by looking at the response.
    #
    # Error callback takes a single argument which is the error message.
    #
    # The success callback takes a single argument which is usually the data
    # that has been changed and/or persisted.
    #
    # Also note that the callbacks are all synchronous.
    query: (url, {data, type, noFail, error, success}) ->
      id = url

      try
        success this[type.toUpperCase()] id, data, noFail
      catch e
        error e
