Uploader = require "s3-uploader"

module.exports = ->
  self.extend
    # TODO
    saveToS3: () ->
      policy = JSON.parse(localStorage.whimsyPolicy)
      uploader = Uploader(policy)

      uploader.upload
        key: path
        blob: new Blob [content], type: type
        cacheControl: cacheControl
