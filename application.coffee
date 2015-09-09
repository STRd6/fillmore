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
          save: true
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

  sendData = (contentWindow, data) ->
    contentWindow.postMessage
      method: "value"
      params: [data]
    , "*"

  TextFile = (name, content) ->
    fn: ->
      addWidget "http://distri.github.io/text/",
        title: "notepad.exe"
        save: true
        value: content
        width: 400
        height: 300

    icon: "http://files.softicons.com/download/application-icons/sleek-xp-software-icons-by-deleket/png/32/Notepad.png"
    text: name

  addWidget = (url, params) ->
    content = Widget
      url: url

    textValue = ""
    initialValue = params.value

    if params.save
      window.addEventListener "message", (e) ->
        if e.source is content.contentWindow
          if e.data.status is "ready"
            sendData content.contentWindow, initialValue

          value = e.data.value
          if value
            textValue = value

      # Add a save dealy
      params.saveStyle =
        "background-image: url(data:image/gif;base64,R0lGODlhEAAQAOZ3AP///9z//994/wBiycjI/+3y9PXy8/v7+8jH//X49wCQ+wAijgBfygBgyQBkyj60/wBiyjGv/wAqk9bZ+gCO+QBlzOvx88bG/6rW/wAplABfx7ft/wBky8XF/wBlywAvlgBmzRKh//T39/P//+l5/wBjyfr7+vTx8gKd/wFFqgBMsgBgyAAslNbQ/7De/wt83gB13uDe/AB15ABjyv72/wBnzwBlzwB75ySq/zyz/23M/+fm+QBq0wCB6eTj/wAqlB111ACS+ka5/wBhyR+B2tvf9wBozu7w+gBmzAAhjKrX/wAulAAulQBm0QBn0wCJ8QBizefp/ACK9gAfiwAaiwRGqT+2/87P/QCN+fHp/zOv/xSm/+fg/wCJ8AAhje7u9wBkzP7++AArlAAljwAYiABy26zX/9HS/QCU/wBSvQFJreLd/xKg/wB04ODa/wB649vW/4G59DO0/wBt2AAZiAec/xKi/////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAHcALAAAAAAQABAAAAfVgBUaJAKFhockGhUQGyMBj5CRIxsQIHQAJgeam5omAGQgM3IAHQimp6YdADoQAxEAIgmys7IiAEJDrgAXBL2+vRcAOAO6FgXHyMcWACglA1oAJwbT1NMnAGjOOXVSFArf4BRYQEEOAw9sXWlJC+0LXhwrcU/mDyE3APn6AAwNZj31QrQBQEXGGgJXYvTD8MYDByt25gAYA6PFmQk7FpbxkILIliY0pjiBM6HIl35KeCC5U+WFjSxuuPiIciQMFDAuahi5c0cNEzESgmbI8OPDBxZLVAQCADs=)"
      params.save = ->
        name = prompt "File name", "untitled.txt"

        if name
          self.launchers.push TextFile(name, textValue)

    params.content = content

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
