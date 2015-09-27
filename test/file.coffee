describe "File", ->
  it "should be able to create pretty big files", (done) ->
    data = "12345678"

    [0..20].forEach (i) ->
      file = new File [data], "data.txt", type: "text/plain"
      data = data + data
      console.log i, file.size, file
      assert file

    done()
