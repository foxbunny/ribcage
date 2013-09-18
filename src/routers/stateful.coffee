###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Stateful router
#
# This is a router that extends the `BaseRouter` adding application state
# management facilities. The application state is persisted using local
# storage.
#
# This module is in UMD format and will create
# `ribcage.routers.statefulRouter`, `ribcage.routers.StatefulRouter`, and
# `ribcage.routerMixins.StatefulRouter` globals if not used with an AMD loader
# such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'dahelpers' then root.dahelpers
          when './base' then root.ribcage.routers.baseRouter
          when '../models/localstorage' then root.ribcage.models.localStorageModel
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.routers.statefulRouter = module
      root.ribcage.routers.StatefulRouter = module.Router
      root.ribcage.routerMixins.StatefulRouter = module.mixin
) this

define (require) ->

  # This module depends on DaHelpers, `ribcage.routers.BaseRouter` and
  # `ribcage.models.LocalStorageModel`.
  #
  {extend} = require 'dahelpers'
  {Router: BaseRouter} = require './base'
  {Model: LocalStorageModel} = require '../models/localstorage'

  # ::TOC::
  #

  # ## `statefulRouterMixin`
  #
  # This mixin implements the API for the `StatefulRouter`. During
  # initialization it creates a state model instance which is then assigned to
  # the `state` property.
  #
  statefulRouterMixin =

    # ### `#defaultState`
    #
    # The default application state. This property should be an object that
    # contains the default state of the application.
    #
    # The default value is `{started: false}`.
    #
    defaultState:
      started: false

    # ### `#stateStorageKey`
    #
    # The storage key used to store the application state. The default value is
    # 'appState'.
    #
    stateStorageKey: 'appState'

    # ### `#stateModel`
    #
    # The constructor used to create the application state. Default is
    # `ribcage.models.LocalStorageModel`.
    #
    stateModel: LocalStorageModel

    # ### `#getStateModel()`
    #
    # Returns the model constructor that that will be used to create the
    # application state.
    #
    # The default implementation returns the `#stateModel` property.
    #
    # The return value must have an API compatible with that of
    # LocalStorageModel. If you wish to use an incompatible model constructor,
    # overload the `#initState()` method instad of this one.
    #
    getStateModel: () ->
      @stateModel

    # ### `#stateId`
    #
    # The `id` attribute of the application state model object. Default value
    # is `state`.
    #
    stateId: 'state'

    # ### `#getStateId()`
    #
    # Returns the `id` attribute to be used in the application state model
    # object.
    #
    # The default implementation returns the `#stateId` property.
    #
    # You can overload this attribute to provide a different `id` for each
    # instance of this router. Keep in mind that application state cannot be
    # restored from the storage unless it uses the same `id` that was used to
    # persist it.
    #
    getStateId: () ->
      @stateId

    # ### `initState([data])`
    #
    # Initializes the application state. If the `data` argument is supplied, it
    # is added to the default state.
    #
    # Note that if application already has a state persisted by the state
    # model, and the state model is the default `LocalStorageModel`, the
    # default and additional data supplied to this method will not be added to
    # the stored state.
    #
    # This method should return the created state model object.
    #
    initState: (data={}) ->
      Model = @getStateModel()
      State = Mode.extend
        storageKey: @storageKey
        defaults: extend {}, @defaultState, data
      state = new State id: @getStateId
      state.save null, forceCreate: true
      state.on 'change', () => @state.save()
      state

    # ### `initialize(settings)`
    #
    # Initializes the application state and calls the `BaseRouter`'s
    # `#initialize()` method.
    #
    # The same settings can be passed as for the `BaseRouter`.
    #
    initialize: () ->
      @state = initState()
      BaseRouter::initialize.apply this, arguments

  # ## `StatefulRouter`
  #
  # Please see the documentation on
  # [`statefulRouterMixin`](#statefulroutermixin) for more information on this
  # router's API.
  #
  StatefulRouter = BaseRouter.extend statefulRouterMixin

  mixin: statefulRouterMixin
  Router: StatefulRouter

