require "cornerstone"
Folder = require "./templates/folder"

Ajax = require "./lib/ajax"
Application = require "./application"
Filesystem = require "./filesystem"
File = require "./file"
Window = require "./window"

{readFile} = require "./util"

module.exports = (I={}, self=Model(I)) ->
  defaults I,
    filesystem: {}

  self.attrModel "filesystem", Filesystem

  self.extend
    # Expose PACKAGE and require so scripts can really dig in!
    PACKAGE: PACKAGE
    Require: require "require"
    require: require

    runningApplications: Observable []

    # Execute JavaScript code in a fresh context
    # with `system` available
    exec: (code) ->
      try
        return Function("system", code)(self)
      catch e
        console.error e

      return

    execCoffee: (source) ->
      code = CoffeeScript.compile(source, bare: true)
      self.exec(code)

    handleFileDrop: (file) ->
      self.writeFile(file)

    # Write an HTML5 file object to our file system
    writeFile: (file) ->
      # TODO: Handle more text types
      if (file.type is "text/plain") and (file.size <= 4 * 1024)
        readFile(file)
        .then (text) ->
          self.filesystem().writeFile
            content: text
            path: file.name
            type: file.type
      else
        # TODO: Prompt for overwrite?
        self.saveDataBlob file
        .then (url) ->
          self.filesystem().writeFile
            url: url
            path: file.name
            type: file.type

    registerHandler: (extension, fn) ->
      handlers[extension] = fn

    filePresentersIn: (path) ->
      self.filesystem().foldersIn(path).map (folderName) ->
        presentFolder folderName, path
      .concat self.filesystem().filesIn(path).map presentFile

    # Drop on desktop
    drop: (e) ->
      console.log "desktop drop"
      if folderPath = system.dragFolder
        [..., name, unused] = folderPath.split('/')
        self.filesystem().moveFolder(folderPath, name + "/")
      else if file = system.drag
        file.path file.name()
      else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
        file = File JSON.parse(fileData)
        file.path file.name()
        self.filesystem().files.push file

    boot: (filesystem) ->
      self.filesystem Filesystem filesystem

      # Run init scripts
      self.filesystem().filesIn("System/Boot/").forEach (file) ->
        if file.path().endsWith(".js")
          self.exec(file.content())
        else if file.path().endsWith(".coffee")
          file.asText()
          .then self.execCoffee
          .done()

    netBoot: (url) ->
      Ajax.getJSON(url)
      .then self.boot

    reboot: ->
      self.boot(self.filesystem().I)

    open: (file) ->
      if handler = handlers[file.extension()]
        handler(file)
      else
        alert "Don't know about this kind of file"

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

  presentFolder = (path, basePath="") ->
    title: path.split('/').last()
    icon: "http://findicons.com/files/icons/2256/hamburg/32/folder.png"
    fn: ->
      openFolder(basePath + path)
    dragstart: (e) ->
      system.dragFolder = basePath + path + "/"
      e.dataTransfer.setData("application/whimsy-folder", basePath + path)
    drop: folderDrop(basePath + path)

  fileDrag = (file) ->
    (e) ->
      self.drag = file
      e.dataTransfer.setData("application/whimsy-file+json", JSON.stringify(file.I))

  folderDrop = (path) ->
    (e) ->
      console.log "folder drop"
      if folderPath = system.dragFolder
        e.stopPropagation()
        e.preventDefault()
        [..., name, unused] = folderPath.split('/')
        self.filesystem().moveFolder(folderPath, path + "/" + name + "/")
      else if file = system.drag
        e.stopPropagation()
        e.preventDefault()
        file.path path + "/" + file.name()
      else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
        e.stopPropagation()
        e.preventDefault()
        file = File JSON.parse(fileData)
        file.path path + "/" + file.name()
        self.filesystem().files.push file

  presentFile = (file) ->
    if presenter = filePresenters[file.extension()]
      extend presenter(file),
        fn: ->
          self.open file
        dragstart: fileDrag(file)

    else
      title: file.path().split('/').last()
      icon: "http://files.softicons.com/download/toolbar-icons/iconza-grey-icons-by-turbomilk/png/32x32/document.png"
      fn: ->
        self.open file
      dragstart: fileDrag(file)

  openFolder = (path) ->
    window = Window
      title: path.split('/').last()
    .extend
      content: Folder
        system: self
        path: path + "/"
      drop: folderDrop(path)

    self.addWindow window

  openWidget = (params) ->
    if file = params.file
      delete params.file

    app = Application(params)
    app.dataFile = -> file

    self.runningApplications.push app

    self.addWindow app.window()

  self.registerHandler "txt", (file) ->
    openWidget
      url: "http://distri.github.io/text/whimsy2"
      file: file
      title: file.name()

  self.registerHandler "pkg", (file) ->
    console.log file.content()
    openWidget
      url: "http://danielx.net/editor"
      value: file.content()
      title: file.name()

  self.registerHandler "js", (file) ->
    self.exec(file.content())

  self.registerHandler "coffee", (file) ->
    file.asText()
    .then self.execCoffee

  imageViewer = (file) ->
    img = document.createElement "img"
    img.src = file.url()

    window = Window
      title: file.path
    .extend
      content: img

    self.addWindow window

  self.registerHandler "jpg", imageViewer
  self.registerHandler "png", imageViewer
  self.registerHandler "gif", imageViewer

  return self
