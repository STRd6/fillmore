require "cornerstone"
Folder = require "./templates/folder"

Application = require "./application"
Filesystem = require "./filesystem"

module.exports = (I={}, self=Model(I)) ->
  self.attrModel "filesystem", Filesystem

  self.extend
    # Execute JavaScript code in a fresh context
    # with `system` available
    exec: (code) ->
      Function("system", code)(self)

    registerHandler: (extension, fn) ->
      handlers[extension] = fn

    filePresentersIn: (path) ->
      self.filesystem().foldersIn(path).map (folderName) ->
        presentFolder folderName, path
      .concat self.filesystem().filesIn(path).map presentFile

  self.include require("./window-ui")
  self.include require("./persistence")

  handlers =
    folder: (file) ->
      openFolder JSON.parse(file.content())

    launch: (file) ->
      openWidget JSON.parse(file.content())

  filePresenters =
    launch: (file) ->
      data = JSON.parse(file.content())

      title: data.title
      icon: data.icon

  open = (file) ->
    if handler = handlers[file.extension()]
      handler(file)
    else
      alert "Don't know about this kind of file"

  presentFolder = (path, basePath="") ->
    title: path.split('/').last()
    icon: "http://findicons.com/files/icons/2256/hamburg/32/folder.png"
    fn: ->
      openFolder(basePath + path)
    dragstart: (e) ->
      e.dataTransfer.files =
      e.dataTransfer.setData("application/whimsy-folder", basePath + path)

  presentFile = (file) ->
    if presenter = filePresenters[file.extension()]
      extend presenter(file),
        fn: ->
          open file
        dragstart: (e) ->
          console.log e
          e.dataTransfer.setData("application/whimsy-file", JSON.stringify(file.I))

    else
      title: file.path().split('/').last()
      icon: "http://files.softicons.com/download/toolbar-icons/iconza-grey-icons-by-turbomilk/png/32x32/document.png"
      fn: ->
        open file
      dragstart: (e) ->
        console.log e
        e.dataTransfer.setData("application/whimsy-file", JSON.stringify(file.I))

  openFolder = (path) ->
    self.addWindow
      title: path.split('/').last()
      content: Folder
        system: self
        path: path + "/"

  openWidget = (params) ->
    app = Application(params)

    self.addWindow app

  self.filesystem().writeFile("System/system.pkg", JSON.stringify(PACKAGE))

  self.registerHandler "txt", (file) ->
    openWidget
      url: "http://distri.github.io/text/whimsy"
      data: file.content()
      title: file.name()
      save: true

  self.registerHandler "pkg", (file) ->
    console.log file.content()
    openWidget
      url: "http://danielx.net/editor"
      value: file.content()
      title: file.name()

  self.registerHandler "js", (file) ->
    self.exec(file.content())

  return self
