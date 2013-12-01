/**
 * @author Branko Vukelic <branko@brankovukelic.com>
 * @license MIT
 */

# # Local storage interface
#
# This is a simple `localStorage` API interface that falls back on memory
# storage.
#
# This module is in UMD format and will return a `ribcage.utils.LocalStorage`
# global if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' && root.define.amd
    root.define
  else
    (factory) ->
      module = factory!
      root.{}ribcage.{}utils.LocalStorage = module
) this

define ->

  # This module has no external dependencies.
  #
  # ::TOC::
  #

  ## Object used to store data for in-memory storage
  store = {}

  # ## `LocalStorage`
  #
  # This constructor implements the `localStorage` API that wraps around native
  # `localStorage` object with fallback on in-memory storage. It implements
  # only a subset of the localStorage API needed for use in Ribcage.
  #
  # All data is internally stored as JSON and deserialized on retrieval.
  #
  # Example:
  #
  #     var ls = new LocalStorage();
  #     ls.setItem('foo', {a: 12, b: 'bar'});
  #     ls.get-item('foo');        // returns {a: 12, b: 'bar'}
  #     ls.get-item('foo', true);  // returns '{"a": 12, "b": "bar"}'
  #
  class LocalStorage
    ->
      @has-native = window.local-storage?

      if @has-native
        @local-storage = window.local-storage
      else
        @local-storage = @@memory-storage!

    # ### `LocalStorage.memoryStorage()`
    #
    # Returns an object that implements memory-based sotrage with the interface
    # similar to localStorage.
    #
    @memory-storage = ->
      get-item: (key) ->
        store[key]
      set-item: (key, value) ->
        store[key] = value
      remove-item: (key) ->
        delete store[key]
      clear: ->
        for key of store
          delete store[key]

    # ### `#getItem(key, [raw])
    #
    # Gets data with given key.
    #
    # The `raw` argument is a boolean and data is returned raw without
    # deserialization if it's set to `true`.
    #
    get-item: (key, raw=false) ->
      val = @local-storage.get-item key

      return val if raw

      try
        JSON.parse val
      catch e
        return null

    # ### `#setItem(key, value, [raw])`
    #
    # Sets `val` as data for given key.
    #
    # The `raw` argument is a boolean and data is set raw without serialization
    # if it's set to `true`.
    #
    set-item: (key, val, raw=false) ->
      val = if raw then val else JSON.stringify val
      @local-storage.set-item key, val

    # ### `#removeItem(key)`
    #
    # Removes data with given key from local storage.
    #
    remove-item: (key) ->
      @local-storage.remove-item key
      true

    # ### `#empty()`
    #
    # Removes all keys in local storage.
    #
    empty: ->
      if @has-native
        for key of @local-storage
          local-storage.remove-item key
      else
        @local-storage.clear!
