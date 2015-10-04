module.exports =
  html: (pkg) ->
    """
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          #{dependencyScripts(pkg.remoteDependencies)}
        </head>
        <body>
          "<script>#{system.require.executePackageWrapper(pkg)}<\/script>"
        </body>
      </html>
    """

# `makeScript` returns a string representation of a script tag that has a src
# attribute.
makeScript = (src) ->
  "<script src=#{JSON.stringify(src)}><\/script>"

# `dependencyScripts` returns a string containing the script tags that are the
# remote script dependencies of this build.
dependencyScripts = (remoteDependencies=[]) ->
  remoteDependencies.map(makeScript).join("\n")
