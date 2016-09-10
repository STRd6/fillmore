require "cornerstone"

Ajax = require "./lib/ajax"
Application = require "./application"
Filesystem = require "./filesystem"
File = require "./file"
Window = require "./window"

{readFile} = require "./util"

Require = require "require"

global.log = console.log.bind(console)
global.error = console.error.bind(console)

module.exports = (I={}, self=Model(I)) ->
  defaults I,
    filesystem: {}

  self.attrModel "filesystem", Filesystem

  self.include Bindable

  self.extend
    # Expose PACKAGE and require so scripts can really dig in!
    PACKAGE: PACKAGE
    Require: Require
    require: Require.generateFor PACKAGE

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

      # TODO: Return PID or an app data object
      return

    boot: (filesystem) ->
      self.filesystem Filesystem filesystem

      # Attach to filesystem events
      ["write", "remove", "rename"].forEach (eventType) ->
        self.filesystem().on eventType, (args...) ->
          self.trigger "filesystem", eventType, args...

      # Run init scripts
      self.filesystem().filesIn("System/Boot/").forEach (file) ->
        if file.path().endsWith(".js")
          self.exec(file.content())
        else if file.path().endsWith(".coffee")
          file.asText()
          .then self.execCoffee

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
    # TODO: This is only so we can test from the IDE, should be removed later
    coffee: (file) ->
      file.asText()
      .then system.execCoffee
      .catch(console.error.bind(console))

    launch: (file) ->
      self.run JSON.parse(file.content())

  return self
