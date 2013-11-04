###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # BaseRouter
#
# This is a basic router that handles the most traditional case of routing
# different routes to matching handlers.
#
# Apart from standard Backbone router, this router also adds hooks for view
# registration and cleanup.
#
# This module is in UMD format and will create `ribcage.routers.BaseRouter`,
# `ribcage.routers.BaseRouter`, and `ribcage.routerMixins.BaseRouter`
# globals if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'dahelpers' then root.dahelpers
          when 'backbone' then root.Backbone
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.routers.baseRouter = module
      root.ribcage.routers.BaesRouter = module.Router
      root.ribcage.routerMixins.BaseRouter = module.mixin
) this

define (require) ->

  # This module depends on DaHelpers and Backbone.
  #
  {type} = require 'dahelpers'
  {Router} = require 'backbone'

  # ::TOC::
  #

  # ## `baseRouterMixin`
  #
  # This mixin implements the API of the `BaseRouter`.
  #
  baseRouterMixin =

    # ### `#_activeViews`
    #
    # An array containing currently registered views.
    #
    _activeViews: []

    # ### `#autoCleanup`
    #
    # Whether cleanup should be performed automatically. Default is `false`.
    #
    autoCleanup: false

    # ### `#init(jQuery)`
    #
    # Called when router is starting. Use this to perform initialization.
    # jQuery is passed to init for convenience.
    #
    # Default implementation does not do anything.
    #
    init: () ->
      return

    # ### `#initialize(settings)`
    #
    # During initialization, router sets up event handlers and calls the
    # `#init()` method. You generally don't want to overload this method.
    # Instead, use `#init()`.
    #
    # The settings may include an `autoCleanup` key which will override the
    # `#autoCleanup` property given a non-null value.
    #
    initialize: (settings) ->
      @autoCleanup = autoCleanup if settings?.autoCleanup?

      if @autoCleanup
        ## Set up the event handler for the `route` event and perofrm cleanup.
        @on 'beforeRoute', () => @cleanup()

      if @routing
        for routeName, route of @routing
          @route route.re, routeName, route.fn

      @init Backbone.$

    # ### `#routing`
    #
    # Object that maps route names to regexes and callback functions. This is
    # an alternative to `routes` object.
    #
    # In general, try to keep the route regexps as simple as possible. The
    # parameters that will be passed to route handlers are those that are in
    # the capture groups. Try to avoid using regexp features outside them as
    # much as possible, if you plant to use the `#reverse()` feature.
    #
    # Example:
    #
    #     var MyRouter = BaseRouter.extend({
    #       routing: {
    #         'route1': {re: /^home$/, fn: myCallback},
    #         'route2': {re: /^about$/, fn: myOtherCallback}
    #       }
    #     });
    #

    # ### `#reverse(route, [param...])`
    #
    # Interpolates 0 or more parameters into the regexp matching the route name
    # provided as `route` argument, and returns the resulting path.
    #
    # Code is based on [one of the StackOverflow
    # answers](http://stackoverflow.com/questions/17325690/javascript-reverse-match-process).
    #
    # Note that this only works for routes that are listed in `routing`
    # property.
    #
    reverse: (route, params...) ->
      re = @routing[route].re
      re = ('' + re).slice 1, -1
      components = re.split(/\([^)]\)/)
      components = (c.replace(/\\\//g, '/') for c in components)
      results = components[0]
      for param, i in params
        results += "#{param}#{components[i + 1]}"
      return results

    # ### `#beforeRoute(router, name)`
    #
    # This method is called before each route handler is invoked.
    #
    # The method takes `router` and `name` arguments which corresponds to the
    # `Router` instance, and route's name. The name may be an empty string if
    # the routing is done by mapping functions directly.
    #
    # Default implementation doesn't do anything.
    #
    beforeRoute: (router, name) ->
      return

    route: (route, name, callback) ->
      if arguments.length is 2
        callback = name
        name = ''

      ## Wrap the callback to trigger the 'beforeRoute' event
      wrapped = (args...) =>
        @beforeRoute(@, name)
        @trigger('beforeRoute', @, name)
        callback.apply @, args

      ## Now call the superclass' `route` method with wrapped callback
      Router::route.call @, route, name, wrapped

    # ### `#giveAccess(view)`
    #
    # During view registration, this method is called to give the view access
    # to anything that view may need.
    #
    # The default implementation is rather liberal and simply adds a `router`
    # attribute to the view which points to this router object. This gives
    # views full access to the router, but the tradeoff is that it has more
    # access than usually needed.
    #
    # You should generally consider overloading this method to give views just
    # enough access to get the job done.
    #
    giveAccess: (view) ->
      view.router = this

    # ### `#register(view)`
    #
    # Registers a view object as active view.
    #
    # This method can be used to register your views. All registered views can
    # be accessed by the router to perform such tasks as cleanup when changing
    # routes.
    #
    register: (view) ->
      @_activeViews.push(view)
      @giveAccess view
      view

    # ### `#cleanup()`
    #
    # Cleans up all registered views. Returns the router instance for chaining.
    # You should generally call this whenever you are setting up a blank page
    # from scratch.
    #
    # If the view implements a `#cleanup()` method, it will be called. You do
    # not need to call view's `#remove()` method since that will be taken care
    # of by the router's cleanup.
    #
    cleanup: () ->
      for view in @_activeViews
        if view.cleanup?
          view.cleanup()

        # Model cleanup
        if view.model and type view.model.off, 'function'
          view.model.off()

        view.model = null  # Dereference just in case

        # Collection cleanup
        if view.collection

          for model in view.collection.models
            if type model.off, 'function'
              model.off()

          if type view.collection.off, 'function'
            view.collection.off()

          view.collection.reset()
          view.collection = null  # Dereference just in case

        view.off()
        view.stopListening()
        view.remove()

      @_activeViews = []  # Dereference all views

      this

    # ### `#go(hash)`
    #
    # Simple wrapper for Router.navigate that also passes `{trigger: true}`.
    #
    go: (hash) ->
      @navigate hash, trigger: true

    # ### `#back()`
    #
    # Go back one step in browser history.
    #
    # This is just a wrapper around the `window.history.back()` method.
    #
    back: () ->
      window.history?.back()

    # ### `#swapPath(hash)`
    #
    # Replace the current path with `hash` without updating history. This is
    # another wrapper for Router.navigate which passes `{trigger:true,
    # replace:true}`.
    #
    swapPath: (hash) ->
      @navigate hash,
        trigger: true
        replace: true

    # ### `#back()`
    #
    # Simple alias for `window.history.back()`.
    #
    back: () ->
      window.history.back()

    # ### `#start()`
    #
    # Shortcut for `Backbone.history.start()`. Any arguments are passed to
    # `Backbone.history.start()` method.
    #
    start: () ->
      Backbone.history.start arguments...

  # ## `BaseRouter`
  #
  # Please see the documentation on [`simpleRouterMixin`](#simpleroutermixin)
  # for more information about this router's API.
  #
  BaseRouter = Router.extend baseRouterMixin

  mixin: baseRouterMixin
  Router: BaseRouter
