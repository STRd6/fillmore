ContextMenu = require "./templates/context_menu"

module.exports = (I, self) ->
  topIndex = 1

  raise = (appWindow) ->
    topIndex += 1

    appWindow.style.zIndex = topIndex

  contextFile = Observable null
  contextMenu = ContextMenu
    classes: ->
      "hidden" unless contextFile()
    delete: ->
      file = contextFile()
      file.path "Trash/" + file.name()

    rename: ->
      file = contextFile()
      newName = prompt "Rename", file.path()

      if newName
        file.path(newName)

    properties: ->
      console.log contextFile().I

  document.body.appendChild contextMenu

  self.extend
    addWindow: (window) ->
      raise window.element()
      document.getElementsByTagName("desktop")[0].appendChild window.element()

    displayContextMenu: (e, file) ->
      contextMenu.style.top = e.pageY + "px"
      contextMenu.style.left = e.pageX + "px"
      contextFile file

  activeDrag = null
  initialPosition = null
  initialMouse = null
  document.addEventListener "mousedown", (e) ->
    target = e.target

    if target.classList.contains "handle"
      activeDrag = target.parentNode

      raise(activeDrag)
      document.getElementsByClassName("drag-fix")[0].style.zIndex = topIndex + 1

      initialPosition = activeDrag.getBoundingClientRect()
      initialMouse = e

  document.addEventListener "mousemove", (e) ->
    if activeDrag
      delta =
        x: e.pageX - initialMouse.pageX
        y: e.pageY - initialMouse.pageY

      activeDrag.style.left = initialPosition.left + delta.x + "px"
      activeDrag.style.top = initialPosition.top + delta.y + "px"

  document.addEventListener "mouseup", (e) ->
    document.getElementsByClassName("drag-fix")[0].style.zIndex = -1
    activeDrag = null

  cancel = (e) ->
    e.preventDefault()
    return false

  document.addEventListener "dragstart", (e) ->
    setTimeout ->
      $('window').addClass "drop-hover"

  # Note: We're doing drag cleanup in the mouseup event
  # with a timeout
  # This is so we can stopPropagation on drop events and
  # still get cleanup
  # We also don't need to worry about dragend being
  # weird
  document.addEventListener "mouseup", (e) ->
    setTimeout ->
      $('window').removeClass "drop-hover"
      system.drag = null

  document.addEventListener "dragover", cancel
  document.addEventListener "dragenter", cancel

  dropper = require "./lib/drop"
  dropper document, (e) ->
    Array::forEach.call e.dataTransfer.files, (file) ->
      self.handleFileDrop(file)

  window.addEventListener "click", ->
    contextFile null

  window.addEventListener "contextmenu", cancel
