require "cornerstone"
File = require "./file"

module.exports = Filesystem = (I={}, self=Model(I)) ->
  defaults I,
    files: [{
      path: "netboot.coffee"
      content: """
        url = prompt "URL:", "http://danielx.whimsy.space/index.json"
        if url
          system.netBoot(url)
      """
    }]

  self.attrModels "files", File

  self.extend
    find: (path) ->
      [file] = self.files().filter (file) ->
        file.path() is path

      return file

    writeFile: (fileData) ->
      if file = self.find(fileData.path)
        file.content fileData.content
        file.url fileData.url
        file.type fileData.type
      else
        self.files.push File fileData

    # Ex: moveFolder "Games/", "Cool Stuff/Games/"
    moveFolder: (from, to) ->
      self.files().forEach (file) ->
        path = file.path()

        if path.startsWith from
          file.path to + path.slice(from.length)

    filesIn: (directory) ->
      self.files().filter (file) ->
        path = file.path()

        if path.startsWith(directory)
          rest = path.replace(directory, '')

          rest and (rest.indexOf('/') is -1)

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
