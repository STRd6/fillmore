module.exports =
  readFile: (file, method="readAsText") ->
    return new Promise (resolve, reject) ->
      reader = new FileReader()
  
      reader.onloadend = ->
        resolve(reader.result)
      reader.onerror = reject
      reader[method](file)
