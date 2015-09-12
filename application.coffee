require "cornerstone"

module.exports = (I={}, self=Model(I)) ->
  self.attrObservable "title"

  self.extend
    save: (data) ->
      filename = prompt "Filename"

      if filename
        system.filesystem().writeFile(filename, data)

    content: ->
      iframe

    drop: (e) ->
      e.preventDefault()

      if system.drag
        system.drag = null
        sendData system.drag.content()

  iframe = document.createElement 'iframe'

  sendData = (data) ->
    iframe.contentWindow.postMessage
      method: "load"
      params: [data]
    , "*"

  window.addEventListener "message", ({data, source}) ->
    if source is iframe.contentWindow
      if (data.status is "ready") and I.data
        sendData I.data

      if data.method
        id = data.id
        Q(self[data.method]?(data.params...))
        .then ->
          ; #TODO: Reply with result, using id token
        .fail ->
          ; #TODO: Reply with error using id token
        .done()

  if I.url
    iframe.src = I.url

  return self
