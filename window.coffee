require "cornerstone"
WindowTemplate = require "./templates/window"

module.exports = (I={}, self=Model(I)) ->
  defaults I,
    top: 20
    left: 20
    width: 400
    height: 200
    zIndex: 1

  self.attrObservable "width", "height", "top", "left", "zIndex"

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

    style: ->
      "width: #{@width()}px; height: #{@height()}px; top: #{@top()}px; left: #{@left()}px; z-index: #{@zIndex()};"

  return self
