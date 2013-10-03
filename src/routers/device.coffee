###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # DeviceRouter
#
# This router provides device-specific hooks and behaviors.
#
# This module is in UMD format and will create `ribcage.routers.deviceRouter`,
# `ribcage.routers.DeviceRouter`, and `ribcage.routerMixins.DeviceRouter`
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
          when 'ua-parser-js' then root.UAParser
          when './base' then root.ribcage.baseRouter
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      r = ribcage.routers
      r.routers.deviceRouter = module
      r.routers.deviceRouter = module.Router
      r.routerMixins.DeviceRouter = module.mixin
) this


define (require) ->

  # This module depends on DaHelpers, UA-Parser and
  # `ribcage.routers.BaseRouter`.
  #
  {type, subset, extend} = require 'dahelpers'
  UAParser = require 'ua-parser-js'
  {Router: BaseRouter} = require './base'
  uaParser = new UAParser()

  # ::TOC::
  #

  # ## `deviceRouterMixin`
  #
  # Mixin that implements the `DeviceRouter`'s API.
  #
  # This mixin will allow the router to parse out the User-Agent string on init
  # and store the results, as well as allowing the developer to define
  # device-specific overrides for all router methods.
  #
  # Since most of the logic of this router lies in the `#initialize()` method,
  # please take care to not overload it in a way that prevents its invocation.
  #
  deviceRouterMixin =

    # ### `#userAgent`
    #
    # Stores the parsed User-Agent string. The object is in the same format as
    # the return value of UA-Parser's [`#getResult()`
    # method](https://github.com/faisalman/ua-parser-js/blob/master/readme.md).
    #
    # The `#initialize` method creates additional keys that are not part of the
    # UA-Parser output.
    #
    # `native`, which is currently set to `true` only in PhoneGap native
    # application.
    #
    # `standalone` which is only set to True on mobile Safari when the browser
    # is in application/full-screen mode.
    #
    userAgent: {}

    # ### `#deviceOverrides`
    #
    # An object containing a mapping between router instance methods and
    # alternatives that should be used instead of the method defined directly
    # on the prototype.
    #
    # Each override has a key that matches the prototype method name, and a
    # value that represents the mapping between alternative method names and
    # matchers.
    #
    # Matches are object with the same format as the output of UA-Parser's
    # [`#getResult()`
    # method](https://github.com/faisalman/ua-parser-js/blob/master/readme.md)
    # where only the keys of interest are specified. As long as the specified
    # keys exist in the parsing result, and the values of those keys match, the
    # alternative method will be considered a match.
    #
    # The matcher can also be an object which takes the parsed UA string, and
    # rerturns `true` if override should take place.
    #
    # For practical reasons, only the _first_ matched method will be used.
    #
    # Example:
    #
    #     var MyRouter = DeviceRouter.extend({
    #       foo: function() { console.log('foo'); },
    #       fooIOS7: function() { console.log('foo from iOS7'); }
    #       deviceOverrides: {
    #         foo: {
    #           fooIOS7: {os: {name: 'iOS', version: '7'}},
    #           fooIOSlt7: function(ua) {
    #             reurn ua.os.name === 'iOS' && parseInt(ua.os.version, 10) < 7
    #           }
    #         }
    #       }
    #     });
    #
    deviceOverrides: {}

    # ### `#remapOverrides(overrides, actualState)`
    #
    # Takes an `overrides` mapping and an object representing the current
    # actual state (`actualState`) and remaps methods where the matcher
    # matches the current state.
    #
    # The `overrides` object maps method names to objects containing the
    # mapping between alternative method names to be used, and the matcher
    # objects which must be a subset of the actual state for the override to
    # take place.
    #
    # This method is normally used in conjunction with `#deviceOverrides`
    # mapping and `userAgent` object, but you can use it for other overrides as
    # well, with the descibed rules.
    #
    # The matcher object can also be a function which takes the `actualState`
    # and returns `true` if the override should take place.
    #
    # Returns the router instance for further chaining.
    #
    # Example:
    #
    #     var MyRouter = DeviceRouter.extend({
    #       greeting: function() { console.log('Hi!'); },
    #       greetingMorning: function() { console.log('Good morning!'); },
    #       greetingEvening: function() { console.log('Good evening!'); },
    #     });
    #
    #     var  customOverrides = {
    #       greeting: {
    #         greetingMorning: { timeofDay: 'morning' },
    #         greetingEvening: { timeofDay: 'evening' }
    #       }
    #     };
    #
    #     var actualConditions = {
    #       timeOfDay: 'evening'
    #     };
    #
    #     var router = new MyRouter();
    #     router.remapOverrides(customOverrides, actualConditions);
    #     router.greeting(); // logs: 'Good evening!'
    #
    #
    remapOverrides: (overrides, actualState) ->
      for method, alternatives of overrides
        for alternative, matcher of alternatives
          if type matcher, 'function'
            cond = matcher actualState
          else
            cond = subset matcher, actualState
          @[method] = @[alternative] if cond
          break
      @

    # ### `#initialize()`
    #
    # Sets up `#userAgent` property and performs any device-specific overrides.
    #
    # When adding this mixin to other routers, you should generally overload
    # the `#initialize()` method of the new router and make sure
    # `DeviceRouter`'s `#initialize()` method gets called first. That makes it
    # possible to override any methods that are called within the
    # `#initialize()` methods of other mixins (e.g., `#init()`).
    #
    initialize: () ->
      @userAgent = uaParser.getResult()
      @userAgent.native = false
      @userAgent.standalone = false
      document.addEventListener "deviceready", () =>
        @userAgent.native = true
      if 'standalone' of window.navigator
        @userAgent.standalone = window.navigator.standalone
      @remapOverrides @deviceOverrides, @userAgent
      return

  # ## `DeviceRouter`
  #
  # Please see the documentation on [`deviceRouterMixin`](#deviceroutermixin)
  # for more information about this router's API.
  #
  DeviceRouter = BaseRouter.extend extend {}, deviceRouterMixin,
    initialize: () ->
      deviceRouterMixin.initialize.apply @, arguments
      BaseRouter::initialize.apply @, arguments

  mixin: deviceRouterMixin
  Router: DeviceRouter
