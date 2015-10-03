require "cornerstone"

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
      Function("system", code)(self)

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

    readFile: (path) ->
      file = self.filesystem().find(path)

      if file
        file.asFile()
      else
        throw new Error "File not found: #{path}"

    registerHandler: (extension, fn) ->
      handlers[extension] = fn

    run: (params) ->
      if file = params.file
        delete params.file

      app = Application(params)
      app.dataFile = -> file

      self.runningApplications.push app

      self.addWindow app.window()

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
    launch: (file) ->
      self.run JSON.parse(file.content())

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
