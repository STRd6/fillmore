ContextMenu = require "./templates/context_menu"

module.exports = (I, self) ->
  topIndex = 2

  raiseToTop = (window) ->
    return if window.zIndex() >= topIndex

    topIndex += 1
    window.zIndex topIndex

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
      raiseToTop window
      window.element().window = window

      document.getElementsByTagName("desktop")[0].appendChild window.element()

    raiseToTop: raiseToTop

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

      raiseToTop(activeDrag.window)
      document.getElementsByClassName("drag-fix")[0].style.zIndex = topIndex + 1

      initialPosition = activeDrag.getBoundingClientRect()
      initialMouse = e
    else
      # raise any window that a person clicked in
      # Apps that run in iframes need to raise themselves because
      # events don't bubble out of iframes
      # NOTE: Can't seem to capture the event when a resize control is pressed
      win = target.window
      while target and !win
        target = target.parentElement
        win = target.window if target

      if win
        raiseToTop(win)

  document.addEventListener "mousemove", (e) ->
    if activeDrag
      delta =
        x: e.pageX - initialMouse.pageX
        y: e.pageY - initialMouse.pageY

      window = activeDrag.window
      window.left initialPosition.left + delta.x
      window.top initialPosition.top + delta.y

  document.addEventListener "mouseup", (e) ->
    document.getElementsByClassName("drag-fix")[0].style.zIndex = -1
    activeDrag = null

  document.addEventListener "mouseup", (e) ->
    {target} = e

    if target.nodeName is "WINDOW"
      {width, height} = target.style

      win = target.window

      win.width(width.slice(0, -2))
      win.height(height.slice(0, -2))
      raiseToTop(win)

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
      system.drag = system.dragFolder = null

  document.addEventListener "dragover", cancel
  document.addEventListener "dragenter", cancel

  dropper = require "./lib/drop"
  dropper document, (e) ->
    Array::forEach.call e.dataTransfer.files, (file) ->
      self.handleFileDrop(file)

  window.addEventListener "click", ->
    contextFile null

  window.addEventListener "contextmenu", (e) ->
    unless e.target.nodeName is "IMG"
      cancel(e)
