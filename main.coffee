# Probably want a bunch of garish widgets... pop-out, drag to move

# Need to be able to launch the editor and create new applications/widgets

# Viewers for various media types

# It should be FUN!

# Sample Use Case
# Launch Editor
# Create Widget
# Save Widget
# Launch Widget

# What is a widget, a DOM node?
# Maybe an object with an element property?
# widget = Dealy(data, host)
# document.body.appendChild widget.element()

# How does a widget live in a package?

# Apps will need some awareness of the OS for things like popping
# up a save prompt or file picker.

style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Widget = require "./templates/widget"

global.application =
  launch: ->
    if url = prompt "URL", "http://www.danielx.net/pixel-editor"
      document.body.appendChild Widget
        title: "Yolo"
        url: url

document.body.appendChild require("./templates/main")(application)

activeDrag = null
initialPosition = null
initialMouse = null
document.addEventListener "mousedown", (e) ->
  console.log e
  target = e.target

  if target.classList.contains "handle"
    activeDrag = target.parentNode

    initialPosition = activeDrag.getBoundingClientRect()
    initialMouse = e

document.addEventListener "mousemove", (e) ->
  if activeDrag
    console.log activeDrag

    delta =
      x: e.pageX - initialMouse.pageX
      y: e.pageY - initialMouse.pageY

    activeDrag.style.left = initialPosition.left + delta.x + "px"
    activeDrag.style.top = initialPosition.top + delta.y + "px"

document.addEventListener "mouseup", (e) ->
  activeDrag = null
