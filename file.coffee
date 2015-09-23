require "cornerstone"

module.exports = File = (I={}, self=Model(I)) ->
  self.attrObservable "path", "content", "type", "url"

  self.extend
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
