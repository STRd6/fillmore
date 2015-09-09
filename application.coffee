require "cornerstone"
Widget = require "./templates/widget"

module.exports = ->
  self =
    launch: ->
      if url = prompt "URL", "http://www.danielx.net/pixel-editor"
        document.getElementsByTagName("desktop")[0].appendChild Widget
          title: "Yolo"
          url: url
          zIndex: topIndex
    launchers: Observable [{
      fn: ->
        self.launch()
      text: "Launch"
    }, {
      fn: ->
        self.launchers.push this
      text: "Test"
    }]

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

  return self
