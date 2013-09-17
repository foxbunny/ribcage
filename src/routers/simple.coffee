###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # SimpleRouter
#
# This is a basic router that handles the most traditional case of routing
# different routes to matching handlers.
#
# Apart from standard Backbone router, this router also adds hooks for view
# registration and cleanup.
#
# This module is in UMD format and will create `ribcage.routers.simpleRouter`,
# `ribcage.routers.SimpleRouter`, and `ribcage.routerMixins.SimpleRouter`
# globals if not used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'backbone' then root.Backbone
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.routers.simpleRouter = module
      root.ribcage.routers.SimpleRouter = module.Router
      root.ribcage.routerMixins.SimpleRouter = module.mixin
) this

define (require) ->

  # This module depends on Backbone.
  #
  Backbone = require 'backbone'

  # ::TOC::
  #

  # ## `simpleRouterMixin`
  #
  # This mixin implements the API of the `SimpleRouter`.
  #
  simpleRouterMixin =

    # ### `#_activeViews`
    #
    # An array containing currently registered views.
    #
    _activeViews: []

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
          view.model.off();

        view.model = null  # Dereference just in case

        # Collection cleanup
        if view.collection

          for model in view.collection.models
            if type model.off, 'function'
              model.off();

          if type view.collection.off, 'function'
            view.collection.off()

          view.collection.reset()
          view.collection = null  # Dereference just in case

        view.off()
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

  # ## `SimpleRouter`
  #
  # Please see the documentation on [`simpleRouterMixin`](#simpleroutermixin)
  # for more information about this router's API.
  #
  SimpleRouter = Backbone.Router.extend simpleRouterMixin

  mixin: simpleRouterMixin
  Router: SimpleRouter
