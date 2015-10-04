Window = require "../window"
Folder = require "../templates/folder"

module.exports = FolderPresenter = (filesystem, path) ->
  if path.length
    path = path.replace /\/*$/, "/"

  filePresenters =
    launch: (file) ->
      data = JSON.parse(file.content())

      title: data.title
      icon: data.icon
      drop: (e) ->
        params = JSON.parse(file.content())

        if system.drag
          e.stopPropagation()
          e.preventDefault()

          params.file = system.drag
          system.run params
        else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
          e.stopPropagation()
          e.preventDefault()

          params.file = File JSON.parse(fileData)
          system.run params
        else
          ;# TODO: Handle dropped HTML5 files

  fileDrag = (file) ->
    (e) ->
      system.drag = file
      e.dataTransfer.setData("application/whimsy-file+json", JSON.stringify(file.I))

  folderDrop = (path) ->
    (e) ->
      if folderPath = system.dragFolder
        e.stopPropagation()
        e.preventDefault()
        [..., name, unused] = folderPath.split('/')
        filesystem.moveFolder(folderPath, path + name + "/")
      else if file = system.drag
        e.stopPropagation()
        e.preventDefault()
        file.path path + file.name()
      else if fileData = e.dataTransfer.getData("application/whimsy-file+json")
        e.stopPropagation()
        e.preventDefault()
        file = File JSON.parse(fileData)
        file.path path + file.name()
        filesystem.files.push file

  presentFolder = (path, basePath="") ->
    title: path.split('/').last()
    icon: "http://findicons.com/files/icons/2256/hamburg/32/folder.png"
    fn: ->
      openFolder(basePath + path)
    dragstart: (e) ->
      system.dragFolder = basePath + path + "/"
      e.dataTransfer.setData("application/whimsy-folder", basePath + path)
    drop: folderDrop(basePath + path + "/")

  presentFile = (file) ->
    if presenter = filePresenters[file.extension()]
      extend presenter(file),
        fn: ->
          system.open file
        dragstart: fileDrag(file)

    else
      title: file.path().split('/').last()
      icon: "http://files.softicons.com/download/toolbar-icons/iconza-grey-icons-by-turbomilk/png/32x32/document.png"
      fn: ->
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
    filesystem.foldersIn(path).map (folderName) ->
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
