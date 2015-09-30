Ajax = require "../lib/ajax"

describe "Ajax", ->
  it "should getJSON", (done) ->
    Ajax.getJSON("https://api.github.com/users")
    .then (data) ->
      done()
