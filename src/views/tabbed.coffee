###!
@author Branko Vukelic <branko@brankovukelic.com>
@license MIT
###

# # Tabbed view
#
# This view implements a container view with tabbed navigation. It extends the
# `TemplateView` constructor and simplifies rendering of tabbed layout. Each
# tab's content is rendered using a separate subview.
#
# The view only handles the activation of the content areas based on tab
# navigation interaction, but the actual content interactions are handled by
# subviews.
#
# This module is in UMD format and will export `ribcage.views.tabbedView`,
# `ribcage.views.TabbedView`, and `ribcage.viewMixins.TabbedView` globals if
# not used with an AMD loader such as RequrieJS.
#

define = ((root) ->
  if typeof root.define is 'function' and root.define.amd
    root.define
  else
    require = (dep) =>
      (() =>
        switch dep
          when 'ribcage/views/template' then @ribcage.views.templateView
          else null
      )() or throw new Error "Unmet dependency #{dep}"
    (factory) =>
      module = factory require
      root.ribcage.views.tabbedView = module
      root.ribcage.views.TabbedView = module.View
      root.ribcage.viewMixins.TabbedView = module.mixin
) this

define (require) ->

  # This module depends on `ribcage.views.TemplateView`.
  #
  {View: TemplateView} = require 'ribcage/views/template'

  # ## `tabbedViewMixin`
  #
  # This mixin implements the API for the `TabbedView`. To has a few attributes
  # that define the HTML for the various moving parts, and renders each subview
  # into its designated content area
  #
  # Since this view's job is to handle tabbed navigation and not manage the
  # actual subviews, you should generally not try to add event handlers to this
  # view, but instead handle everything in your subviews.
  #
  tabbedViewMixin =

    # ### `#MAIN_TEMPLATE`
    #
    # Main container template. By default it renders a single `<ul>` that will
    # contain the navigation, and a single `<div>` that will contain the tab
    # contents.
    #
    # The tab navigation container must have a class attribute of
    # `tabnav-tabs`, and the content container element must have a class of
    # `tabnav-container`.
    #
    # The template must have `TABS` and `TCONTENTS` placeholders.
    #
    MAIN_TEMPLATE: """
      <ul class="tabnav-tabs">TABS</ul>
      <div class="tabnav-container">TCONTENTS</div>
      """

    # ### `#TAB_TEMPLATE`
    #
    # Template for a single item in the tab navigation list. By default this is
    # a `<li>` item.
    #
    # The template must contain `ID` and `LABEL` placeholders.
    #
    # The outermost element must also have a class attribute of `tabnav-tab`.
    # The outermost element must also have an `id` attribute with the value of
    # `ID_tab`, where `ID` is the placeholder that will be replaced by actual
    # tab id.
    #
    TAB_TEMPLATE: """<li class="tabnav-tab" id="ID_tab">
      <a href="javascript:void(0)">LABEL</a>
      </li>"""

    # ### `#CONTENT_TEMPLATE`
    #
    # The template for single tab content container. By default it is a `<div>`
    # element.
    #
    # The content container template must have `ID` and `PLACEHOLDER`
    # placeholders. The `ID` must be rendered as an `id` attribute of the
    # container element.
    #
    # The container must have a class of `tabnav-content` and must have an `id`
    # attribute with value of `ID` (which is the placeholder that will be
    # replaced by the actual content id.
    #
    CONTENT_TEMPLATE: """<div class="tabnav-content" id="ID">
      PLACEHOLDER
      </div>"""

    # ### `#tabs`
    #
    # Array of tab meta data. Each tab meta data item should be an object that
    # looks like this:
    #
    #     {
    #       label: 'My tab',
    #       id: 'mytab',
    #       show: function() { /* ... */ },    // optional
    #     }
    #
    # The `label` attribute is the tab's label that is used in the navigation
    # buttons.
    #
    # The `id` attribute sets the tab's HTML `id` attribute.
    #
    # The `view` attribute is a view that should be rendered in the tab. The
    # view's element will be appended to its tab container.
    #
    # The `show` and `hide` callbacks are triggered each time a tab is shown or
    # hidden. These callbacks are passed this object. If you wish to include
    # any extra information that should be available to `show` and `hide`
    # callbacks, you can add it to this object.
    #
    tabs: []

    # ### `#views`
    #
    # A mapping of views for each tab. The key in the `#views` object should be
    # the tab ID, and the value should be a view instance (not constructor).
    #
    # Views are optional. If they are specified, they will be rendered into
    # designated areas.
    #
    views: {}

    # ### `#contentPlaceholder`
    #
    # Static HTML to be used as content placeholder. Usually this is some sort
    # of spinner icon to let users know that something will be loaded into the
    # tab. By default, this is an empty string.
    #
    contentPlaceholder: ''

    # ### `#getContentPlaceholder()`
    #
    # Returns HTML to be used as content placeholder. The default
    # implementation simply returns the `#contentPlaceholder` property.
    #
    getContentPlaceholder: () ->
      @contentPlaceholder

    # ### `initialize(settings)`
    #
    # The settings should contain a `views` key which will be assigned to the
    # `#views` property.
    #
    initialize: (settings) ->
      @views = settings.views if settings?.views

    # ### `#template()`
    #
    # Renders the tabs and tab content containers (but does not insert any
    # content into them.
    #
    template: () ->
      ## Render tempalte for each navigation item
      navs = (
        @TAB_TEMPLATE.replace(/ID/g, tab.id).
        replace('LABEL', tab.label) for tab in @tabs
      ).join ''

      ## Render template for each content area
      contents = (
        @CONTENT_TEMPLATE.replace('ID', tab.id).
        replace('PLACEHOLDER', @getContentPlaceholder()) for tab in @tabs
      ).join ''

      ## Insert navigation items and content areas into main template
      @MAIN_TEMPLATE.replace('TABS', navs).replace 'TCONTENTS', contents

    # ### `#afterRender()`
    #
    # After rendering the tabs and content containers, caches necessary
    # selectors and renders any views into their containers.
    #
    afterRender: () ->
      for tab, idx in @tabs
        ## Cache the selected elements.
        tab.nav = @$el.find '#' + tab.id + '_tab'
        tab.container = @$el.find '#' + tab.id

        ## First tab is active by default
        if idx is 0
          tab.nav.addClass 'active'
          tab.container.show()
        else
          tab.nav.removeClass 'active'
          tab.container.hide()


        ## If there is an associated view, render it into its container.
        if @view?[tab.id]
          @views[tab.id].render().$el.appendTo tab.container

        ## Store all the meta information on the tab button itself as data-
        ## attribute.
        tab.nav.data 'meta', tab

      @tabnavContents = @$ 'div.tabnav-content'
      @tabnavTabsLi = @$ 'li.tabnav-tab'
      @tabnavTabs = @$ 'li.tabnav-tab a'

    # ### `#onTabClick()`
    #
    # Tab click handler. Deactivates active tabs and shows the selected tab.
    #
    onTabClick: (e) ->
      @tabnavTabsLi.removeClass 'active'
      @tabnavContents.hide()

      clickTarget = @$ e.target

      ## Find the correct target
      if clickTarget.hasClass 'tabnav-tab'
        nav = clickTarget
      else
        nav = clickTarget.parents('.tabnav-tab')

      ## Get original meta data from the target
      tab = nav.data 'meta'

      nav.addClass 'active'
      tab.container.show()

      if typeof tab.show is 'function'
        tab.show tab

    events:
      'click .tabnav-tab': 'onTabClick'

  # ## `TabbedView`
  #
  # Please see the documentation on [`tabbedViewMixin`](#tabbedviewmixin) for
  # more information about this view's API.
  #
  TabbedView = TemplateView.extend tabbedViewMixin

  mixin: tabbedViewMixin
  View: TabbedView
