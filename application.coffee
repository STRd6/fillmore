require "cornerstone"
Folder = require "./templates/folder"
Widget = require "./templates/widget"
Window = require "./templates/window"

module.exports = ->
  self =
    launch: ->
      if url = prompt "URL", "http://www.danielx.net/pixel-editor"
        addWidget url,
          title: url
          width: 640
          height: 480

    launchers: Observable [{
      fn: ->
        self.launch()
      icon: "http://iconizer.net/files/Toolbar_icon_set_2/orig/car.png"
      text: "Launch"
    }, {
      fn: ->
        addWidget "http://distri.github.io/synth",
          title: "Theremin"
      icon: "http://osx.iusethis.com/icon/osx/theremin.png"
      text: "Theremin"
    }, {
      fn: ->
        addWidget "http://www.danielx.net/pixel-editor",
          title: "Pixel Editor"
          width: 640
          height: 480
      icon: "http://dist.alternativeto.net/icons/microsoft-paint_3495.png?width=50&height=50&mode=crop&anchor=middlecenter"
      text: "Pixel Editor"
    }, {
      fn: ->
        addWidget "http://distri.github.io/text/",
          title: "notepad.exe"
          width: 400
          height: 300
      icon: "http://files.softicons.com/download/application-icons/sleek-xp-software-icons-by-deleket/png/32/Notepad.png"
      text: "notepad.exe"
    }, {
      fn: ->
        openFolder
          title: "Games"
          width: 400
          height: 300
          zIndex: topIndex
      icon: "http://findicons.com/files/icons/2256/hamburg/32/folder.png"
      text: "Games"
    }]

  games = [{
    icon: "http://0.pixiecdn.com/sprites/26528/original.png"
    url: "http://contrasaur.us"
    params:
      width: 640
      height: 600
    text: "Contrasaurus [Broken]"
  }, {
    icon: "http://0.pixiecdn.com/sprites/131792/original."
    url: "http://danielx.net/ld33"
    params:
      width: 650
      height: 520
    text: "Dungeon of Sadness"
  }].map (data) ->
    fn: ->
      params = extend
        title: data.text
      , data.params
  
      addWidget data.url, params
    text: data.text
    icon: data.icon

  openFolder = (params) ->
    console.log games

    params.content = Folder
      launchers: games

    addWindow params

  addWidget = (url, params) ->
    params.content = Widget
      url: url

    addWindow params

  addWindow = (params) ->
    console.log params
    params.zIndex ?= topIndex

    if typeof params.width is "number"
      params.width = params.width + "px"

    if typeof params.height is "number"
      params.height = params.height + "px"

    document.getElementsByTagName("desktop")[0].appendChild Window params

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
