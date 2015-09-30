{readFile} = require "../util"

module.exports = Ajax =
  getJSON: (path, options={}) ->
    Ajax.getBlob(path, options)
    .then readFile
    .then JSON.parse

  getBlob: (path, options={}) ->
    new Promise (resolve, reject) ->

      xhr = new XMLHttpRequest()
      xhr.open('GET', path, true)
      xhr.responseType = "blob"

      headers = options.headers
      if headers
        Object.keys(headers).forEach (header) ->
          value = headers[header]
          xhr.setRequestHeader header, value

      xhr.onload = (e) ->
        if (200 <= this.status < 300) or this.status is 304
          try
            resolve this.response
          catch error
            reject error
        else
          reject e

      xhr.onerror = reject
      xhr.send()
