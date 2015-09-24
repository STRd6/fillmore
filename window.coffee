require "cornerstone"

module.exports = (I={}, self=Model(I)) ->
  self.attrObservable "width", "height", "zIndex"

  self.extend
    close: (e) ->
      e.target.parentNode.parentNode.remove()

    title: Observable I.title

    drop: (e) ->
      e.preventDefault()

  return self
