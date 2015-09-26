require "cornerstone"

Ajax = require "./lib/ajax"

module.exports = File = (I={}, self=Model(I)) ->
  self.attrObservable "path", "content", "type", "url"

  self.extend
    asFile: ->
      Q.fcall ->
        url = self.url()
        if url # remote file
          Ajax.getBlob(url + "?O_o")
          .then (blob) ->
            blob.name = self.path()

            return blob
        else
          new window.File [self.content()], self.path(),
            type: self.type()

    name: ->
      self.path().split('/').last()

    extension: ->
      self.extensions().last()

    extensions: ->
      pieces = self.path().split('.')
      pieces.shift()

      pieces.map (piece, index) ->
        pieces[index...].join(".")

  return self
