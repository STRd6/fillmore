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

global.application = require("./application")()

document.body.appendChild require("./templates/main")(application)
