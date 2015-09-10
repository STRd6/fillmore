require "cornerstone"
Folder = require "./templates/folder"
Widget = require "./templates/widget"
Window = require "./templates/window"

Filesystem = require "./filesystem"

module.exports = ->
  self =
    launch: ->
      if url = prompt "URL", "http://www.danielx.net/pixel-editor"
        addWidget url,
          title: url
          width: 640
          height: 480

    filesystem: ->
      filesystem

  handlers =
    folder: (file) ->
      openFolder JSON.parse(file.content())

    launch: (file) ->
      openWidget JSON.parse(file.content())

    txt: (file) ->
      console.log file
      # Launch text editor
      # Initialize with value
      ;

  filePresenters =
    folder: (file) ->
      data = JSON.parse(file.content())

      title: data.title
      icon: "http://findicons.com/files/icons/2256/hamburg/32/folder.png"

    launch: (file) ->
      data = JSON.parse(file.content())

      title: data.title
      icon: data.icon

    txt: (file) ->
      icon: "http://files.softicons.com/download/application-icons/sleek-xp-software-icons-by-deleket/png/32/Notepad.png"
      title: file.path()

  open = (file) ->
    if handler = handlers[file.extension()]
      handler(file)
    else
      alert "Don't know about this kind of file"

  presentFile = (file) ->
    if presenter = filePresenters[file.extension()]
      extend presenter(file),
        fn: ->
          open file
    else
      title: file.path
      icon: "https://cdn2.iconfinder.com/data/icons/glossy_ecommerce_icons/question.png"
      fn: ->
        open file

  filesystem = Filesystem()
  self.launchers = Observable ->
    filesystem.files.map presentFile

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

  openWidget = (params) ->
    content = Widget
      url: params.url

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
          self.filesystem().files.push Filesystem.File
            path: name
            content: textValue

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
