require "cornerstone"
WindowTemplate = require "./templates/window"

module.exports = (I={}, self=Model(I)) ->
  self.attrObservable "width", "height"

  element = null

  self.extend
    close: ->
      element?.remove()

    title: Observable I.title

    drop: (e) ->
      e.preventDefault()

    element: ->
      element ?= WindowTemplate self

      return element

    popOut: ->
      self.app().popOut()

  return self
