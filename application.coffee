require "cornerstone"
Postmaster = require "postmaster"

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

  appWindow = Window(I).extend
    content: ->
      iframe

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

    childLoaded: ->
      file = self.dataFile()

      # Only do this the first time?
      # Pop-out will cause childLoaded to be called again later...
      if file
        self.loadWhimsyFile(file)

    loadWhimsyFile: (file) ->
      file.asFile()
      .then (file) ->
        console.log file
        self.loadFile file
      .done()

    loadFile: (file) ->
      self.invokeRemote "loadFile", file

    saveFile: (file) ->
      system.writeFile(file)

    window: ->
      appWindow

  # TODO: apps should respond to `loadFile` messages
  # when opening the app with a file as data or
  # dropping a file from the fileSystem on to the app
  # A file object will be passed

  self.include Postmaster

  if I.url
    iframe.src = I.url

  return self
