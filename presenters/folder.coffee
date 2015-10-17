Window = require "../window"
Folder = require "../templates/folder"
File = require "../file"

module.exports = FolderPresenter = (filesystem, path) ->
  if path.length
    path = path.replace /\/*$/, "/"

  filePresenters =
    launch: (file) ->
      title = Observable()
      icon = Observable()

      file.asJSON()
      .then (data) ->
        title data.title
        icon data.icon

      title: title
      icon: icon
      drop: (e) ->
        dropFile = null

        if system.drag
          e.stopPropagation()
          e.preventDefault()

          dropFile = system.drag
        else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
          e.stopPropagation()
          e.preventDefault()

          dropFile = File JSON.parse(fileData)
        else
          ;# TODO: Handle dropped HTML5 files

        file.asJSON()
        .then (params) ->
          params.file = dropFile
          system.run params

  fileDrag = (file) ->
    (e) ->
      system.drag = file
      e.dataTransfer.setData("application/whimsy-file+json", JSON.stringify(file.I))

  folderDrop = (path) ->
    (e) ->
      if folderPath = system.dragFolder
        system.dragFolder = null
        e.stopPropagation()
        [..., name, unused] = folderPath.split('/')
        filesystem.moveFolder(folderPath, path + name + "/")
      else if file = system.drag
        system.drag = null
        e.stopPropagation()
        newPath = path + file.name()
        unless file.path() is newPath
          filesystem.moveFile file, newPath
      else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
        e.stopPropagation()
        file = File JSON.parse(fileData)
        file.path path + file.name()

        filesystem.writeFile file.I

  presentFolder = (path, basePath="") ->
    if path is "Trash"
      classes = "folder trash"
    else
      classes = "folder"

    classes: classes
    title: path.split('/').last()
    click: ->
      openFolder(basePath + path)
    dragstart: (e) ->
      system.dragFolder = basePath + path + "/"
      e.dataTransfer.setData("application/whimsy-folder", basePath + path)
    drop: folderDrop(basePath + path + "/")
    mousedown: ->

  presentFile = (file) ->
    customPresenter = filePresenters[file.extension()]
    if customPresenter
      presenter = customPresenter file
    else
      presenter =
        title: file.name

    defaults presenter,
      drop: ->

    extend presenter,
      classes: ->
        file.extension()

      mousedown: (e) ->
        if e.which is 3
          e.preventDefault()
          system.displayContextMenu(e, file)
      click: (e) ->
        e.preventDefault()

        system.open file
      dragstart: fileDrag(file)

  openFolder = (path) ->
    f = FolderPresenter(filesystem, path)

    window = Window
      title: path.split('/').last()
    .extend
      content: Folder f
      drop: f.drop

    system.addWindow window

  filePresentersIn = (path) ->
    filesystem.foldersIn(path).sort().map (folderName) ->
      presentFolder folderName, path
    .concat filesystem.filesIn(path).map presentFile

  drop: folderDrop(path)
  items: ->
    filePresentersIn(path)
  style: ->
    file = filesystem.find("#{path}.style")

    if file
      file.content()
    else
      ""
