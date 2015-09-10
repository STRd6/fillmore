require "cornerstone"

File = (I={}, self=Model(I)) ->
  self.attrObservable "path", "content", "type"

  self.extend
    extension: ->
      self.extensions().last()

    extensions: ->
      pieces = self.path().split('.')
      pieces.shift()

      pieces.map (piece, index) ->
        pieces[index...].join(".")

  return self

module.exports = Filesystem = (I={}, self=Model(I)) ->
  defaults I,
    files: [{
      path: "pixel.launch"
      content: JSON.stringify
        title: "Paint"
        url: "http://www.danielx.net/pixel-editor"
        icon: "http://dist.alternativeto.net/icons/microsoft-paint_3495.png"
        width: 800
        height: 600
      type: "application/json"
    }, {
      path: "theremin.launch"
      content: JSON.stringify
        title: "Theremin"
        url: "http://distri.github.io/synth"
        icon: "http://osx.iusethis.com/icon/osx/theremin.png"
    }, {
      path: "text.launch"
      content: JSON.stringify
        title: "notepad.exe"
        url:"http://distri.github.io/text/",
        icon: "http://files.softicons.com/download/application-icons/sleek-xp-software-icons-by-deleket/png/32/Notepad.png"
        save: true
        width: 400
        height: 300
    }, {
      path: "Games/contrasaurus.launch"
      content: JSON.stringify
        icon: "http://0.pixiecdn.com/sprites/26528/original.png"
        url: "http://contrasaur.us"
        width: 640
        height: 600
        title: "Contrasaurus [Broken]"
    }, {
      path: "Games/Ludum Dare/dungeon.launch"
      content: JSON.stringify
        icon: "http://0.pixiecdn.com/sprites/131792/original."
        url: "http://danielx.net/ld33"
        width: 650
        height: 520
        title: "Dungeon of Sadness"
    }]

  self.attrModels "files", File

  self.extend
    filesIn: (directory) ->
      self.files().filter (file) ->
        path = file.path()

        if path.startsWith(directory)
          rest = path.replace(directory, '')

          rest.indexOf('/') is -1

    foldersIn: (directory) ->
      dirHash = self.files().map (file) ->
        file.path()
      .filter (path) ->
        if path.startsWith(directory)
          rest = path.replace(directory, '')

          rest.indexOf('/') > 0

      .eachWithObject {}, (path, hash) ->
        hash[path.replace(directory, '').split('/')[0]] = true

      Object.keys(dirHash)

  return self

Filesystem.File = File
