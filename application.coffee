###
Application
-----------

An application is some running process. It may have a window. That window can
be popped in or out of the desktop if the application implements `saveState` and
`restoreState`.

This application class provides an interface for the code to interact with the
rest of the operating system. Using `postMessage` the application can read files,
write files, and communicate with other applications.

Applications should use `Postmaster` for easy remote procedure calling across
windows and frames. When the application loads it should post the `childLoaded`
message. This will allow it to restore state and to load an initial file (like
when someone drags a file onto an app to open it). The application should
respond to the `loadFile` message to allow this functionality.

###

require "cornerstone"
Postmaster = require "postmaster"

Ajax = require "./lib/ajax"
Runner = require "./lib/runner"
Window = require "./window"

module.exports = (I={}, self=Model(I)) ->
  self.attrObservable "title"

  # TODO: Handle popping-out of windows
  # To pop in or out need to
  # saveState
  # switch from iframe <=> child window
  # restoreState
  # it is up to the app to respond to the saveState/restoreState messages correctly

  iframe = document.createElement 'iframe'
  savedState = null
  externalWindow = null

  appWindow = Window(I).extend
    app: ->
      self

    content: ->
      iframe

    poppable: ->
      true

    drop: (e) ->
      e.preventDefault()
      e.stopPropagation()

      if file = system.drag
        system.drag = null
        self.loadWhimsyFile(file)

    title: self.title

  self.extend
    remoteTarget: ->
      iframe.contentWindow

    popOut: ->
      return if externalWindow
      externalWindow = window.open("", "", "width=#{I.width},height=#{I.height}")

      unless externalWindow # Pop up blocked
        alert "Pop out was blocked"
        return

      initContent()

      # Get State
      self.invokeRemote "saveState"
      .then (state) ->
        appWindow.close()
        console.log state
        savedState = state
        self.remoteTarget = -> externalWindow
        self.invokeRemote "restoreState", state
      .catch (e) ->
        console.error e

    childLoaded: ->
      file = self.dataFile()

      # Only do this the first time?
      # Pop-out will cause childLoaded to be called again later...
      if savedState
        self.invokeRemote "restoreState", savedState
      else if file
        self.loadWhimsyFile(file)

    loadWhimsyFile: (file) ->
      file.asFile()
      .then (file) ->
        console.log file
        self.loadFile file
      .done()

    loadFile: (file) ->
      self.invokeRemote "loadFile", file

    saveFile: (file, path) ->
      if path
        file.name = path

      system.writeFile(file)

    system: (method, params...) ->
      system[method](params...)

    focus: ->
      system.raiseToTop(self.window())

    window: ->
      appWindow

  # TODO: apps should respond to `loadFile` messages
  # when opening the app with a file as data or
  # dropping a file from the fileSystem on to the app
  # A file object will be passed

  self.include Postmaster

  writePackage = (pkg) ->
    html = Runner.html(pkg)
    if externalWindow
      externalWindow.document.write(html)
    else
      iframe.contentWindow.document.write(html)

  writeUrl = (url) ->
    if externalWindow
      externalWindow.document.location = url
    else
      iframe.src = url

  initContent = ->
    if I.url
      writeUrl(I.url)
    else if I.package
      setTimeout ->
        writePackage(I.package)
      , 0
    else if I.packagePath
      file = system.filesystem().find(I.packagePath)
      if file
        file.asJSON()
        .then writePackage
        .catch error
        .done()
      else
        error "Could not find file at path: #{I.packagePath}"
    else if I.packageUrl
      Ajax.getJSON(I.packageUrl)
      .then writePackage
      .catch error

  initContent()

  return self
