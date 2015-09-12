require "cornerstone"

module.exports = (I={}, self=Model(I)) ->
  self.extend
    save: ->
      ;# TODO: Display OS Save Prompt
    load: ->
      ;
    viewData: ->
      title: I.title
      content: iframe

  iframe = document.createElement 'iframe'

  sendData = (contentWindow, data) ->
    contentWindow.postMessage
      method: "load"
      params: [data]
    , "*"

  window.addEventListener "message", ({data, source}) ->
    if source is iframe.contentWindow
      if (data.status is "ready") and I.data
        sendData iframe.contentWindow, I.data

      if data.method
        Q(self[data.method]?(data.params...))
        .then ->
          ; #TODO: Reply with result, using id token
        .fail ->
          ; #TODO: Reply with error using id token
        .done()

  if I.url
    iframe.src = I.url

  return self
