Widget = require "./templates/widget"

module.exports = ->
  self =
    launch: ->
      if url = prompt "URL", "http://www.danielx.net/pixel-editor"
        document.body.appendChild Widget
          title: "Yolo"
          url: url
          zIndex: topIndex

  topIndex = 1
  raise = (appWindow) ->
    topIndex += 1
  
    appWindow.style.zIndex = topIndex
  
  activeDrag = null
  initialPosition = null
  initialMouse = null
  document.addEventListener "mousedown", (e) ->
    target = e.target
  
    if target.classList.contains "handle"
      activeDrag = target.parentNode
  
      raise(activeDrag)
  
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
    activeDrag = null

  return self
