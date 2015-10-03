Uploader = require "s3-uploader"

{SHA256} = CryptoJS = require "./lib/crypto"

POLICY_STORAGE_KEY = "WHIMSY_POLICY"

{readFile} = require "./util"
{getJSON} = require "./lib/ajax"

module.exports = (I, self) ->
  self.extend
    uploadPolicy: ->
      getLocalPolicy()
      .fail ->
        getToken()
        .then (token) ->
          refreshPolicy(token)

    saveDataBlob: (blob) ->
      readFile(blob, "readAsArrayBuffer")
      .then (arrayBuffer) ->
        path = "data/#{urlSafeBase64EncodedSHA256(arrayBuffer)}"

        self.saveBlob path, blob, 31536000

    saveBlob: (path, blob, cacheControl=0) ->
      self.uploadPolicy()
      .then (policy) ->
        uploader = Uploader(policy)
        uploader.upload
          key: path
          blob: blob
          cacheControl: cacheControl

urlSafeBase64EncodedSHA256 = (arrayBuffer) ->
  hash = SHA256(CryptoJS.lib.WordArray.create(arrayBuffer))
  base64 = hash.toString(CryptoJS.enc.Base64)
  urlSafeBase64 = base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/\=+$/, "")

getToken = ->
  Q.fcall ->
    if token = localStorage.WHIMSY_TOKEN
      token
    else
      if token = prompt "Your ticket to Whimsy:"
        localStorage.WHIMSY_TOKEN = token
      else
        throw new Error("No token given")

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
