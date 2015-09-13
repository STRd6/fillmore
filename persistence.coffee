Uploader = require "s3-uploader"

{SHA256} = CryptoJS = require "./lib/crypto"

POLICY_STORAGE_KEY = "WHIMSY_POLICY"

module.exports = (I, self) ->
  self.extend
    uploadPolicy: ->
      getLocalPolicy()
      .fail ->
        getToken()
        .then (token) ->
          refreshPolicy(token)

    saveDataBlob: (blob) ->
      blobTypedArray(blob)
      .then (arrayBuffer) ->
        path = "data/#{urlSafeBase64EncodedSHA256(arrayBuffer)}"

        saveBlob path, blob, 31536000
        .then ->
          path

    saveBlob: (path, blob, cacheControl=0) ->
      self.uploadPolicy()
      .then (policy) ->
        uploader = Uploader(policy)
        uploader.upload
          key: path
          blob: blob
          cacheControl: cacheControl

    saveIndexHtml: ->
      blob = new Blob ["Hello"], type: "text/html"

      self.saveBlob "index.html", blob

urlSafeBase64EncodedSHA256 = (arrayBuffer) ->
  hash = SHA256(CryptoJS.lib.WordArray.create(arrayBuffer))
  base64 = hash.toString(CryptoJS.enc.Base64)
  urlSafeBase64 = base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/\=+$/, "")

blobTypedArray = (blob) ->
  return new Promise (resolve, reject) ->
    reader = new FileReader()

    reader.onloadend = ->
      resolve(reader.result)

    reader.onerror = reject

    reader.readAsArrayBuffer(blob)

getToken = ->
  Q.fcall ->
    if token = localStorage.WHIMSY_TOKEN
      token
    else
      localStorage.WHIMSY_TOKEN = token = prompt "Your ticket to Whimsy:"

    console.log token

    token

getLocalPolicy = ->
  Q.fcall ->
    policy = JSON.parse(localStorage[POLICY_STORAGE_KEY])
  .then validatePolicyExpiration

validatePolicyExpiration = (policy) ->
  expiration = JSON.parse(atob(policy.policy)).expiration

  if (Date.parse(expiration) - new Date) <= 30
    throw "Policy expired"
  else
    return policy

refreshPolicy = (token) ->
  getJSON "http://api.whimsy.space/policy.json",
    headers:
      Authorization: token
  .then (policyJSON) ->
    localStorage[POLICY_STORAGE_KEY] = JSON.stringify(policyJSON)

    policyJSON

getJSON = (path, options={}) ->
  deferred = Q.defer()

  xhr = new XMLHttpRequest()

  xhr.open('GET', path, true)

  headers = options.headers
  if headers
    Object.keys(headers).forEach (header) ->
      value = headers[header]
      xhr.setRequestHeader header, value

  xhr.onload = (e) ->
    if (200 <= this.status < 300) or this.status is 304
      try
        deferred.resolve JSON.parse this.responseText
      catch error
        deferred.reject error
    else
      deferred.reject e

  xhr.onprogress = deferred.notify
  xhr.onerror = deferred.reject
  xhr.send()

  deferred.promise
