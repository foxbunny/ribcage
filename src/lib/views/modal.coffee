###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Modal view
#
# This view presents a modal window with an overlay that fills the container.
#
# This module is in UMD format and will create `ribcage.views.ModalView`,
# `ribcage.viewMixins.ModalView`, and `ribcage.views.modalView` globals if not
# used with an AMD loader such as RequireJS.
#

define = ((root) ->
  if typeof root.define is 'function' and define.amd
    root.define
  else
    require = (dep) ->
      (() ->
        switch dep
          when './templatebase' then root.ribcage.views.templateBaseView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) ->
      module = factory require
      root.ribcage.views.modalView = module
      root.ribcage.views.ModalView = module.View
      root.ribcage.viewMixins.ModalView = module.mixin
)(this)


define (require) ->

  # This module depends on Underscore and `ribacage.views.BaseView`.
  #
  _ = require 'underscore'
  {View: TemplateBaseView} = require './templatebase'

  # ## `modalViewMixin`
  #
  modalViewMixin =
    # ## `#setTemplate(templateSource)`
    #
    # Sets the template source.
    #
    # Note that this does _not_ override the `#template()` function. Do that
    # directly on the object.
    #
    setTemplate: (templateSource) ->
      @templateSource = templateSource
      @contentElement?.html @renderTemplate @getTemplateContext()
      @

    # ## `#title`
    #
    # The dialog title.
    #
    # Default is ''.
    #
    title: ''

    # ## `#getTitle()`
    #
    # Returns the dialog title.
    #
    # Default implementation returns the value of the `#title` property.
    #
    getTitle: () ->
      @title

    # ## `#setTitle(title)`
    #
    # Sets the title of the modal dialog.
    #
    setTitle: (title) ->
      @title = title
      @titleElement?.text title
      @

    # ## `#overlayStyles`
    #
    # The styles to be used in the overlay element's `style` attribute. This is
    # an object that defines the CSS rules to be applied.
    #
    # Default is equivalent of the following CSS:
    #
    #     position: fixed;
    #     top: 0;
    #     left: 0;
    #     width: 100%;
    #     height: 100%;
    #     background: rgba(0,0,0,0.5);
    #     z-index: 16777271 (maximum allowed in older versions of Safari)
    #
    # Use jQuery-compatible style declarations.
    #
    # If you would rather set the overlay styles using CSS, simply create CSS
    # rules for the `div.modal-overlay` element, and set this property to
    # `null`.
    #
    overlayStyles:
      position: 'fixed'
      top: '0'
      left: '0'
      width: '100%'
      height: '100%'
      background: 'rgba(0,0,0,0.5)'
      'z-index': 16777271

    # ## `#closeIcon`
    #
    # The HTML fragment to be used as close icon.
    #
    # Default is '<span class="icon-remove"></span>'.
    #
    closeIcon: '<span class="icon-remove"></span>'

    # ## `#getCloseIcon()`
    #
    # Returns the HTML fragment to be used as close icon.
    #
    # Default implementation returns the value of `#closeIcon` property.
    #
    getCloseIcon: () ->
      @closeIcon

    # ## `#setCloseIcon(icon)`
    #
    # Sets the close icon HTML fragment.
    #
    setCloseIcon: (icon) ->
      @closeIcon = icon
      @closeIconElement.html(@closeIcon) if @closeIconElement?

    # ## `#modalTemplate`
    #
    # The main modal dialog container template. It defines an overlay,
    #
    modalTemplate: """
    <div class="modal-dialog">
      <h2 class="modal-title">
        <span class="modal-title-text"><%= title %></span>
        <span class="modal-title-close-icon close"><%= closeIcon %></span>
      </h2>
      <div class="modal-content"><%= content %></div>
      <% if (buttons) { %>
        <div class="modal-buttons"><%= buttons %></div>
      <% } %>
    </div>
    """

    # ## `#buttons`
    #
    # The buttons that appear in the button bar. Set this to `false` or other
    # falsy value to suppress rendering of the button bar itself.
    #
    # Default is '<button class="close">OK</button>'.
    #
    buttons: '<button class="close">OK</button>'

    # ## `#getButtons()`
    #
    # Returns the dialog buttons.
    #
    # Default implementation returns the value of the `#buttons` property.
    #
    getButtons: () ->
      @buttons

    # ## `#setButtons(buttons)`
    #
    # Sets the button bar buttons.
    #
    setButtons: (buttons) ->
      @buttons = buttons
      @buttonsElements?.html @buttons
      @

    # ## `#dismiss(e)`
    #
    # The event callback for close icon, overlay and button bar button click
    # events.
    #
    # Default implementation simply closes the dialog.
    #
    dismiss: (e) ->
      @$el.hide()
      callback = @onDismissed
      @onDismissed = null
      callback() if callback

    # ## `#show([title, templateSource, callback])`
    #
    # Shows the dialog.
    #
    # All arguments are optional. If supplied, they will set the appropraite
    # properties of the modal dialog before showing.
    #
    show: (title, templateSource, callback) ->
      @setTitle(title) if title?
      @setTemplate(templateSource) if templateSource?
      @onDismissed = callback if callback?
      @$el.show()

    # ## `#onDismissed`
    #
    # Callback function that is executed once when the alert is dismissed.
    #
    # The callback is dereferenced immediately after being called. Use the
    # `#onDismiss()` function to set a new one.
    #
    # The callback needs to be used if you want 'blocking' behavior, because
    # the blocking behavior of some of the native modal dialogs (e.g., `alert`,
    # `prompt`) cannot be simulated.
    #
    # Default value is `null`.
    #
    onDismissed: null

    # ## `#createContainer()`
    #
    # Creates the modal overlay container by rendering the `#modalTemplate`.
    #
    createContainer: () ->
      _.template @modalTemplate,
        title: @getTitle()
        content: @template @getTemplateContext()
        buttons: @getButtons()
        closeIcon: @getCloseIcon()

    # ## `#render()`
    #
    # Renders the overlay and sets the default content.
    #
    # Rendering _always_ hides the overlay, so please use another method to
    # re-render if hiding the overlay is not what you want. Usually, setting
    # the title and template should be enough for most use cases.
    #
    render: () ->
      @modal = @$el

      if @overlayStyles?
        @modal.css @overlayStyles

      @modal.hide()

      ## Insert the container into the overlay
      @modal.html @createContainer()

      ## Cache selectors for later use
      @titleElement = @modal.find '.modal-title-text'
      @contentElement = @modal.find '.modal-content'
      @buttonsElement = @modal.find '.modal-buttons'
      @closeIconElement = @modal.find '.modal-title-close-icon'
      @

    # ## `#events`
    #
    # The default mapping attaches the `#dismiss()` callback to `click` and
    # `touchend` events triggered on elements with `close` class (overlay,
    # close icon, and close button).
    #
    events:
      'click .close': 'dismiss'
      'touchend .close': 'dismiss'

  # ## `ModalView`
  #
  # Please see the documentation on [`modalViewMixin`](#modalviewmixin) for
  # more information about this view's API.
  #
  ModalView = TemplateBaseView.extend modalViewMixin

  mixin: modalViewMixin
  View: ModalView
