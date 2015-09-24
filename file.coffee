require "cornerstone"

module.exports = File = (I={}, self=Model(I)) ->
  self.attrObservable "path", "content", "type", "url"

  self.extend
    asFile: ->
      Q.fcall ->
        if self.url() # remote file
          ;# TODO: ajax get array buffer and return promise for file
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
