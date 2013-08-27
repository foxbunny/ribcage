# # Generic SOAP client model
#
# This model hooks the model layer to SOAP service in a generic way. It cannot
# be used as is, since using a SOAP service requires parsing the response.
#
# This model requires two dependencies:
#
#  + [jquery.soap](http://plugins.jquery.com/soap/)
#  + [jquery.xml2json](http://code.google.com/p/jquery-xml2json-plugin/)
#
# This model is in UMD format, and will create a `Ribcage.models.SoapModel`
# global if not used with an AMD loader such as RequireJS.

if typeof define isnt 'function' or not define.amd
  @require = (dep) =>
    (() =>
      switch dep
        when 'backbone' then @Backbone
        when 'jquery' then @jQuery
        when 'underscore' then @_
        else null
    )() or throw new Error "Unmet dependency #{dep}"
  @define = (factory) =>
    (@Ribcage or= {}).models or= {}
    @Ribcage.models.SoapModel = factory @require

define (require) ->
  Backbone = require 'backbone'
  $ = require 'jquery'
  _ = require 'underscore'
  require 'jquery.soap'
  require 'jquery.xml2json'


  # ## `SoapModel`
  #
  # This model maps the model's CRUD methods to SOAP methods. With a bit of
  # customization, you can perform an infinite number of different SOAP
  # requests depending on the circumstances, so you are not limited to a
  # one-to-one mapping between CRUD and SOAP methods.
  #
  # The actual SOAP requests are made by jquery.soap plugin which is required
  # for this model to function correctly. If you keep the default
  # implementation, all response data is converted to JSON by jquery.xml2json
  # plugin.
  SoapModel = Backbone.Model.extend

    # ### `SoapModel.prototype.baseUrl`
    #
    # You must override this property to set the base URL of the SOAP
    # endpoints. You can also override the property right on the model's
    # prototype to have to changed globally for all your SOAP models.
    #
    # By default, it's 'http://example.com'.
    baseUrl: 'http://example.com'

    # ### `SoapModel.prototype.namespace`
    #
    # Change this property to set the napespace for your SOAP requests. Again,
    # you can change this on the model's prototype if needed.
    #
    # By default, it's 'http://example.com'.
    namespace: 'http://example.com'

    # ### `SoapModel.prototype.debug`
    #
    # Whether to log request information. This value is relayed to jquery.soap
    # as is.
    #
    # Default is `false`.
    debug: false

    # ### `SoapModel.prototype.appendMethod`
    #
    # Whether to build the URL of an endpoint by appending the SOAP method name
    # to the base URL. This value is relayed to jquery.soap as is.
    #
    # Default is `false`.
    appendMethod: false

    # ### `SoapModel.prototype.soap12`
    #
    # Whether to use SOAP v1.2. This setting is relayed to jquery.soap as is.
    #
    # Default is `false`.
    soap12: false

    # ### `SoapModel.prototype.soapCreateMethod`
    #
    # A string property that represents the method name for the model's create
    # method.
    #
    # By default, it's 'Create'.
    soapCreateMethod: 'Create'

    # ### `SoapModel.prototype.soapReadMethod`
    #
    # A string property that represents the method name for the model's read
    # method.
    #
    # By default, it's 'Read'
    soapReadMethod: 'Read'

    # ### `SoapModel.prototype.soapUpdateMethod`
    #
    # A string property that represents the method name for the model's update
    # method.
    #
    # By default, it's 'Update'
    soapUpdateMethod: 'Update'

    # ### `SoapModel.prototype.soapDeleteMethod`
    #
    # A string property that represents the method name for the model's delete
    # method.
    #
    # By default, it's 'Delete'
    soapDeleteMethod: 'Delete'

    # ### `SoapModel.prototype.getSoapCreateMethod()
    #
    # This method returns the name of the SOAP method used for model's create
    # method.
    #
    # Overload if you wish to set the method name at runtime
    getSoapCreateMethod: () ->
      @soapCreateMethod

    # ### `SoapModel.prototype.getSoapReadMethod()
    #
    # This method returns the name of the SOAP method used for model's read
    # method.
    #
    # Overload if you wish to set the method name at runtime
    getSoapReadMethod: () ->
      @soapReadMethod

    # ### `SoapModel.prototype.getSoapUpdateMethod()
    #
    # This method returns the name of the SOAP method used for model's update
    # method.
    #
    # Overload if you wish to set the method name at runtime
    getSoapUpdateMethod: () ->
      @soapUpdateMethod

    # ### `SoapModel.prototype.getSoapDeleteMethod()
    #
    # This method returns the name of the SOAP method used for model's delete
    # method.
    #
    # Overload if you wish to set the method name at runtime
    getSoapDeleteMethod: () ->
      @soapDeleteMethod

    # ### `SoapModel.prototype.soapCreateTemplate(data)`
    #
    # The template used for model's create method.
    #
    # This property should be a function that accepts the model data as an
    # object, and returns either an object, or a string that will be used as
    # `param` argument in the jquery.soap call.
    #
    # By default, this property is `null`, and that will trigger an exception
    # during `#sync()` call.
    soapCreateTemplate: null

    # ### `SoapModel.prototype.soapReadTemplate(data)`
    #
    # The template used for model's read method.
    #
    # This property should be a function that accepts the model data as an
    # object, and returns either an object, or a string that will be used as
    # `param` argument in the jquery.soap call.
    #
    # By default, this property is `null`, and that will trigger an exception
    # during `#sync()` call.
    soapReadTemplate: null

    # ### `SoapModel.prototype.soapUpdateTemplate(data)`
    #
    # The template used for model's update method.
    #
    # This property should be a function that accepts the model data as an
    # object, and returns either an object, or a string that will be used as
    # `param` argument in the jquery.soap call.
    #
    # By default, this property is `null`, and that will trigger an exception
    # during `#sync()` call.
    soapUpdateTemplate: null

    # ### `SoapModel.prototype.soapDeleteTemplate(data)`
    #
    # The template used for model's delete method.
    #
    # This property should be a function that accepts the model data as an
    # object, and returns either an object, or a string that will be used as
    # `param` argument in the jquery.soap call.
    #
    # By default, this property is `null`, and that will trigger an exception
    # during `#sync()` call.
    soapDeleteTemplate: null

    # ### `SoapModel.prototype.soapCreate(model)
    #
    # Prepares jquery.soap settings for model's create method. The default
    # implementation calls the `#getSoapCreateMethod()` and
    # `#soapCreateTemplate()`, adding them to return value's `method` and
    # `params` keys respectively.
    #
    # If the `model` argument is not passed, it will use `this`.
    soapCreate: (model=null) ->
      method: @getSoapCreateMethod()
      params: @soapCreateTemplate (model or this).toJSON()

    # ### `SoapModel.prototype.soapRead(model)
    #
    # Prepares jquery.soap settings for model's read method. The default
    # implementation calls the `#getSoapReadMethod()` and
    # `#soapReadTemplate()`, adding them to return value's `method` and
    # `params` keys respectively.
    #
    # If the `model` argument is not passed, it will use `this`.
    soapRead: (model=null) ->
      method: @getSoapReadMethod()
      params: @soapReadTemplate (model or this).toJSON()

    # ### `SoapModel.prototype.soapUpdate(model)
    #
    # Prepares jquery.soap settings for model's update method. The default
    # implementation calls the `#getSoapUpdateMethod()` and
    # `#soapUpdateTemplate()`, adding them to return value's `method` and
    # `params` keys respectively.
    #
    # If the `model` argument is not passed, it will use `this`.
    soapUpdate: (model=null) ->
      method: @getSoapUpdateMethod()
      params: @soapUpdateTemplate (model or this).toJSON()

    # ### `SoapModel.prototype.soapDelete(model)
    #
    # Prepares jquery.soap settings for model's delete method. The default
    # implementation calls the `#getSoapDeleteMethod()` and
    # `#soapDeleteTemplate()`, adding them to return value's `method` and
    # `params` keys respectively.
    #
    # If the `model` argument is not passed, it will use `this`.
    soapDelete: (model=null) ->
      method: @getSoapDeleteMethod()
      params: @soapDeleteTemplate (model or this).toJSON()

    # ### `SoapModel.prototype.getUrl(method, action)`
    #
    # Returns the full URL of the SOAP request. Note that this URL is used as
    # the base when `#appendMethod` is set to `true`, so there is no need to
    # append the method to the URL here if you wish to use that option.
    #
    # The default implementation returns the value of the `#baseUrl` property.
    getUrl: (method, action) ->
      @baseUrl

    # ### `SoapModel.prototype.getSoapActionName(method, soapMethod)`
    #
    # Returns the action name used in 'SOAPAction' HTTP header.
    #
    # The `method` argument is the model's CRUD method name, and the
    # `soapMethod` is the SOAP method name.
    #
    # Default implementation returns the concatenation of `#namespace` and
    # `soapMethod`.
    getSoapActionName: (method, soapMethod) ->
      "#{@namespace}#{soapMethod}"

    # ### `SoapModel.prototype.sync(method, model, [options])`
    #
    # Performs the soap call using jquery.soap. You generally shouldn't need to
    # override this method.
    sync: (method, model, options={}) ->
      # Capitalized method name
      capMethod = "#{method[0].toUpperCase()}#{method.slice 1}"

      # Add the method to options so it can be relayed to `#parse()`
      options.crudMethod = capMethod

      # Alias the method
      fn = this["soap#{capMethod}"]

      # Prepare parameters by calling the request handler
      params = fn.call this, model # use .call since it's a dangling method

      # Send out the request using jquery.soap
      $.soap _.extend params, options, {
        enableLogging: @debug
        url: @getUrl(method, params.method)
        appendMethodToURL: @appendMethod
        namespaceURL: @namespace
        SOAPAction: @getSoapActionName(method, params.method)
        soap12: @soap12
      }

    # ### `SoapModel.prototype.convertCreateResponse(json)
    #
    # Process the response JSON data and return an object. The return value is
    # returned untouched by the `#parse()` method.
    #
    # Default implementation simply throws an exception. You must override this
    # method, or `#convertResponse()`, or `#parse()` method.
    convertCreateResponse: (json) ->
      throw new Error 'convertCreateResponse method is not implemented'

    # ### `SoapModel.prototype.convertReadResponse(json)
    #
    # Process the response JSON data and return an object. The return value is
    # returned untouched by the `#parse()` method.
    #
    # Default implementation simply throws an exception. You must override this
    # method, or `#convertResponse()`, or `#parse()` method.
    convertReadResponse: (json) ->
      throw new Error 'convertReadResponse method is not implemented'

    # ### `SoapModel.prototype.convertUpdateResponse(json)
    #
    # Process the response JSON data and return an object. The return value is
    # returned untouched by the `#parse()` method.
    #
    # Default implementation simply throws an exception. You must override this
    # method, or `#convertResponse()`, or `#parse()` method.
    convertUpdateResponse: (json) ->
      throw new Error 'convertUpdateResponse method is not implemented'

    # ### `SoapModel.prototype.convertDeleteResponse(json)
    #
    # Process the response JSON data and return an object. The return value is
    # returned untouched by the `#parse()` method.
    #
    # Default implementation simply throws an exception. You must override this
    # method, or `#convertResponse()`, or `#parse()` method.
    convertDeleteResponse: (json) ->
      throw new Error 'convertDeleteResponse method is not implemented'

    # ### convertResponse(json, options)
    #
    # This gets passed JSON data created in the `#parse()` method. The return
    # value of this method is returned from `#parse()` directly. If you are not
    # happy with JSON, consider overriding the `#parse()` method instead.
    #
    # The `options` argument contains the options originally passed to `sync`.
    # Note that the name of the method is added to the original request options
    # as `crudMethod` key, should you need to access it to change the way your
    # data is converted.
    #
    # By default, this method will delegate to one of the `#convertXResponse()`
    # methods depending on the CRUD method.
    convertResponse: (json, options) ->
      this["convert#{options.crudMethod}Response"](json)

    # ### `SoapModel.prototype.parse(response, options)`
    #
    # The `#parse()` method is overridden to convert the response to JSON and
    # pass its `Body` property to the `#convertResponse()` method. You you want
    # to change the way response is converted to an object, you should override
    # this method.
    parse: (response, options) ->
      @convertResponse response.toJSON().Body, options

