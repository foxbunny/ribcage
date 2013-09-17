###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # REST interface for localStorage
#
# This module implements a `LocalStore` constructor which provides an API
# similar to, and mostly compatible with `jQuery.ajax`.
#
# This module is in UMD format and will create a `ribcage.utils.LocalStore`
# global if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'dahelpers' then root.dahelpers
          when './localstorage' then root.ribcage.utils.LocalStorage
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      root.ribcage.utils.LocalStore = factory require
) this

define (require) ->

  # This module depends on DaHelpers, `ribcage.utils.LocalStorage`, and
  # `ribcage.utils.randString`.
  #
  {extend, toArray, type} = require 'dahelpers'
  LocalStorage = require './localstorage'
  randString = require './randstring'

  # ::TOC::
  #

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
  #
  # All operations are atomic, meaning that operations over multiple items at
  # once will be committed for each item. Because the operations can sometimes
  # fail, the state of the storage before the bulk operation had started is
  # backed up and then restored if exceptions are thrown. While this works well
  # when access to localStorage is serial (meaning only one instance is being
  # accessed at any given time), it has a high probability of causing all kinds
  # of problems when accessed in multiple 'threads'.
  #
  # You should keep in mind that this is not a proper database server, and does
  # not have the robustness or guarantees that proper databases provide.
  #
  class LocalStore
    constructor: (@key, @storage, @idProperty='id') ->
      @restorePoint = null

    # ### `#getStore()`
    #
    # Returns the store object with `data` and `index` keys. New one is
    # returned if the key does not contain one yet.
    #
    getStore: () ->
      @storage.getItem(@key) or EMPTY

    # ### `#setRestorePoint()`
    #
    # Saves the current state of the localStorage key in `#restorePoint`
    # property.
    #
    setRestorePoint: () ->
      @restorePoint = @getStore()

    # ### `#clearRestorePoint()`
    #
    # Removes the saved localStorage state.
    #
    clearRestorePoint: () ->
      @restorePoint = null

    # ### `#restore()`
    #
    # Restores saved localStorage state from `#restorePoint` to localStorage.
    #
    restore: () ->
      throw new Error "No restore point found" if not @restorePoint
      @storage.setItem @key @restorePoint

    # ### `#destroyStore()`
    #
    # Removes all data from localStorage.
    #
    destroyStore: () ->
      @storage.removeItem @key

    # ### `#getAll()`
    #
    # Returns all data.
    #
    getAll: () ->
      @getStore().data

    # ### `#idIsUnique(id)`
    #
    # Returns `true` if `id` is not found in the index.
    #
    idIsUnique: (id) ->
      {index} = @getStore()
      id not of index

    # ### `#addItem(item)`
    #
    # Adds a single item to the store and updates the index.
    #
    addItem: (item) ->
      store = @getStore()
      store.data.push(item)
      store.index[item[@idProperty]] = store.data.length - 1
      @storage.setItem @key, store
      item

    # ### `#removeItem(idx)`
    #
    # Removes an item with array index of `idx` and updates the index.
    #
    removeItem: (idx) ->
      store = @getStore()
      id = store.data[idx][@idProperty]
      store.data = store.data.splice idx, 1
      delete store.index[id]
      @storage.setItem @key, store

    # ### `#updateItem(idx, data)`
    #
    # Updates an item with array index of `idx` with `data`. Existing keys are
    # overwritten or removed if not present in the `data` object.
    #
    updateItem: (idx, data) ->
      store = @getStore()
      store.data[idx] = data
      @storage.setItem @key, store
      data

    # ### `#patchItem(idx, data)`
    #
    # Patches a single item using `data` object. The existing keys that do not
    # exist in `data` are retained.
    #
    patchItem: (idx, data) ->
      store = @getStore()
      patchedData = extend store.data[idx], data
      store.data[idx] = patchedData
      @storage.setItem @key, store
      patchedData

    # ### `#getIndexOf(id)`
    #
    # Returns the index of an item with an ID of `id`.
    #
    getIndexOf: (id) ->
      @getStore().index[id]

    # ### `#getIndexSafe(id)`
    #
    # Wraps around `#getIndexOf()` and throws an exception if the `id` does not
    # exist in the index.
    #
    getIndexSafe: (id) ->
      idx = @getIndexOf(id)
      throw new Error "Object with ID #{id} not found" if not idx?
      idx

    # ### `#getOne(id)
    #
    # Return an item with the ID of `id`. If no such item is found, an
    # exception is thrown.
    #
    getOne: (id) ->
      items = @getAll()
      items[@getIndexSafe id]

    # ### `#createOne(data, noFail)`
    #
    # Create a single item and return its data. If the `data` contains a valid
    # ID, and the ID is not unique (it already exists in the index) an
    # exception is thrown.
    #
    # If no ID is specified in `data`, a random ID is created. The generated ID
    # is a 20-digit hexadecimal number.
    #
    # If the `noFail` argument is `true`, and the ID of the new object is not
    # unique, the existing object is returned instead of throwing an exception.
    #
    # The `noFail` argument is generally used to create a model where id has to
    # be known in advance, and existing data can be used instead of the
    # specified data if object had been crated before.
    #
    createOne: (data, noFail) ->
      id = data[@idProperty] or= randString.generateRandStr()
      if id and not @idIsUnique id
        if noFail
          return @getOne(id)
        else
          throw new Error "Object with ID #{id} already exists"
      @addItem data

    # ### `#createAll(data)`
    #
    # If passed an array of items to create, it will create them one by one. It
    # rolls back the changes if any of the items fail to create.
    #
    # The `noFail` argument can be passed, and works the same way as in
    # [`#createOne()`](#createone-data-nofail).
    #
    # If an exception is thrown during creation, the storage will be rolled
    # back to the state before creation of the first item.
    #
    createAll: (data, noFail) ->
      data = toArray data
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

    # ### `#updateOne(id, data)`
    #
    # Updates an item with an ID of `id` using `data`. If the `id` does not
    # exist, an exception will be thrown.
    #
    updateOne: (id, data) ->
      @updateItem @getIndexSafe(id), data

    # ### `#updateAll(data)`
    #
    # Takes an array of item data and updates each item. It is assumed that
    # data for each item also contains the item's ID.
    #
    # The store will be rolled back if an item fails to update.
    #
    updateAll: (data) ->
      data = toArray data
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

    # ### `#patchOne(id, data)`
    #
    # Patches an item with ID of `id` using `data`. If the `id` is not found in
    # the index, an exception is thrown.
    #
    patchOne: (id, data) ->
      @patchItem @getIndexSafe(id), data

    # ### `#patchAll(data)`
    #
    # Patches multiple items using an array of `data`. It is assumed that each
    # item in the `data` array contains the ID of the item.
    #
    # If an exception is thrown during patching, the storage will be rolled
    # back to the state before patching of the first item.
    #
    patchAll: (data) ->
      data = toArray data
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

    # ### `#deleteOne(id)`
    #
    # Deletes an item with an ID of `id`. An exception will be thrown if the
    # `id` is not found in the index.
    #
    deleteOne: (id) ->
      index = @getIndexOf id
      throw new Error "Object with ID #{id} not found" if not index
      @deleteItem index

    # ### `#deleteAll([ids])`
    #
    # Deletes multiple items, or clears the store. The optional `ids` argument
    # should be an array of IDs. If not specified, the store is cleared.
    #
    # If IDs are specified, each item with matching ID is removed. If an item
    # fails to delete, the store will be rolled back.
    #
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

    # ### `#GET(id)`
    #
    # Handles the pretend GET request.
    #
    # If no `id` is specified, all data is returned. Otherwise, only an item
    # with matching `id` will be returned.
    #
    GET: (id) ->
      if id? then @getOne key, id
      else @getAll key

    # ### `#PUT(id, data)`
    #
    # Handles the pretend PUT request.
    #
    # If `id` is specified, a single object is patched. Otherwise, `data` will
    # be treated as an array, and each array item will be expected to contain
    # the ID.
    #
    PUT: (id, data) ->
      if id? then @updateOne id, data
      else @updateAll data

    # ### `#POST(id, data, noFail)`
    #
    # Handles the pretend POST request.
    #
    # The `id` parameter is disregarded. It exists simply to provide an uniform
    # signature across all methods.
    #
    # `data` can either be an object or an array. If an array is specified,
    # multiple objects will be created.
    #
    # The `noFail` flag works the same way as in
    # [`#createOne()`](#createone-data-nofail) method.
    #
    POST: (id, data, noFail) ->
      if type(data, 'array') then @createAll data, noFail
      else @createOne data, noFail

    # ### `#PATCH(id, data)`
    #
    # Handles the pretend PATCH request.
    #
    # If `id` is specified, a single object is patched. Otherwise, `data` will
    # be treated as an array, and each array item will be expected to contain
    # the ID.
    #
    PATCH: (id, data) ->
      if id? then @patchOne id, data
      else @patchAll data

    # ### `#DELETE(id, data)`
    #
    # Handles the pretend DELETE request.
    #
    # If `id` is specified, a single object is patched. Otherwise, `data` will
    # be treated as an array, and each array item will be expected to contain
    # the ID.
    #
    DELETE: (id, data) ->
      if id? then @deleteOne id
      else @deleteAll data

    # ### `#query(url, settings)`
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
    # It is important to note that the callbacks are all _synchronous_. This
    # means that a call to `#query()` will block until all operations are
    # completed.
    #
    query: (url, {data, type, noFail, error, success}) ->
      id = url

      try
        success this[type.toUpperCase()] id, data, noFail
      catch e
        error e

  # ## Exports
  #
  # This module exports the `LocalStore` constructor.
  #
