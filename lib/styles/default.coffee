fs   = require 'fs'
path = require 'path'

_            = require 'underscore'
coffeeScript = require 'coffee-script'
fsTools      = require 'fs-tools'
jade         = require 'jade'
uglifyJs     = require 'uglify-js'
humanize     = require '../utils/humanize'
Base = require './base'


module.exports = class Default extends Base
  STATIC_ASSETS: ['style.css']

  constructor: (args...) ->
    super(args...)

    @sourceAssets = path.join __dirname, 'default'
    @targetAssets = path.resolve @project.outPath, 'assets'

    templateData  = fs.readFileSync path.join(@sourceAssets, 'docPage.jade'), 'utf-8'
    @templateFunc = jade.compile templateData

  exportCompleted: (callback) ->
    @log.trace 'styles.Default#exportCompleted(...)'

    super (error) =>
      return error if error
      @copyAssets callback

  copyAssets: (callback) ->
    @log.trace 'styles.Default#copyAssets(...)'

    # Even though fsTools.copy creates directories if they're missing - we want a bit more control
    # over it (permissions), as well as wanting to avoid contention.
    fsTools.mkdir @targetAssets, '0755', (error) =>
      if error
        @log.error 'Unable to create directory %s: %s', @targetAssets, error.message
        return callback error
      @log.trace 'mkdir: %s', @targetAssets

      numCopied = 0
      for asset in @STATIC_ASSETS
        do (asset) =>
          assetTarget = path.join @targetAssets, asset
          fsTools.copy path.join(@sourceAssets, asset), assetTarget, (error) =>
            if error
              @log.error 'Unable to copy %s: %s', assetTarget, error.message
              return callback error
            @log.trace 'Copied %s', assetTarget

            numCopied += 1
            @compileScript callback unless numCopied < @STATIC_ASSETS.length

  compileScript: (callback) ->
    @log.trace 'styles.Default#compileScript(...)'

    scriptPath = path.join @sourceAssets, 'behavior.coffee'
    fs.readFile scriptPath, 'utf-8', (error, data) =>
      if error
        @log.error 'Failed to read %s: %s', scriptPath, error.message
        return callback error

      try
        scriptSource = _.template data, @
      catch error
        @log.error 'Failed to interpolate %s: %s', scriptPath, error.message
        return callback error

      try
        scriptSource = coffeeScript.compile scriptSource
        @log.trace 'Compiled %s', scriptPath
      catch error
        @log.debug scriptSource
        @log.error 'Failed to compile %s (%s): %s', scriptPath, scriptSource, error.message
        return callback error

      #@compressScript scriptSource, callback
      @concatenateScripts scriptSource, callback

  compressScript: (scriptSource, callback) ->
    @log.trace 'styles.Default#compressScript(..., ...)'

    try
      ast = uglifyJs.parser.parse scriptSource
      ast = uglifyJs.uglify.ast_mangle  ast
      ast = uglifyJs.uglify.ast_squeeze ast

      compiledSource = uglifyJs.uglify.gen_code ast

    catch error
      @log.error 'Failed to compress assets/behavior.js: %s', error.message
      return callback error

    @concatenateScripts compiledSource, callback

  concatenateScripts: (scriptSource, callback) ->
    @log.trace 'styles.Default#concatenateScripts(..., ...)'

    sources           = []
    jqueryPath        = path.join @sourceAssets, 'jquery.min.js'
    jqueryCookiePath  = path.join @sourceAssets, 'jquery.cookie.js'
    outputPath        = path.join @targetAssets, 'behavior.js'

    fs.readFile jqueryPath, 'utf-8', (error, data) =>
      if error
        @log.error 'Failed to read %s: %s', jqueryPath, error.message
        return callback error

      sources.push data

      fs.readFile jqueryCookiePath, 'utf-8', (error, data) =>
        if error
          @log.error 'Failed to read %s: %s', jqueryCookiePath, error.message
          return callback error

        sources.push data
        sources.push scriptSource

        fs.writeFile outputPath, sources.join("\n"), (error) =>
          if error
            @log.error 'Failed to write %s: %s', outputPath, error.message
            return callback error
          @log.trace 'Wrote %s', outputPath
  
          callback()

  renderDocTags: (segments, fileInfo) ->
    for segment, segmentIndex in segments when segment.tagSections?

      sections = segment.tagSections
      output = ''
      metaOutput = ''
      accessClasses = 'doc-section'

      accessClasses += " doc-section-#{tag.name}" for tag in sections.access if sections.access?

      segment.accessClasses = accessClasses

      firstPart = []
      firstPart.push tag.markdown for tag in sections.access if sections.access?
      firstPart.push tag.markdown for tag in sections.special if sections.special?
      firstPart.push tag.markdown for tag in sections.type if sections.type?

      metaOutput += "#{humanize.capitalize firstPart.join(' ')}"

      if sections.flags? or sections.metadata?
        secondPart = []
        secondPart.push tag.markdown for tag in sections.flags if sections.flags?
        secondPart.push tag.markdown for tag in sections.metadata if sections.metadata?
        metaOutput += " #{humanize.joinSentence secondPart}"

      output += "<span class='doc-section-header'>#{metaOutput}</span>\n\n" if metaOutput isnt ''

      output += "#{tag.markdown}\n\n" for tag in sections.description if sections.description?

      output += "#{tag.markdown}\n\n" for tag in sections.todo if sections.todo?

      if sections.params?
        output += "**Parameter#{if 1 < sections.params.length then 's' else ''}:**\n\n"
        output += "#{tag.markdown}\n\n" for tag in sections.params

      if sections.returns?
        output += (
          for tag, index in sections.returns
            if index is 0
              humanize.capitalize tag.markdown
            else
              tag.markdown
        ).join("<br/>**and** ") + "\n\n"

      if sections.throws?
        output += (
          for tag, index in sections.throws
            if index is 0
              humanize.capitalize tag.markdown
            else
              tag.markdown
        ).join("<br/>**and** ") + "\n\n"

      if sections.howto?
        output += "How-To:\n\n#{humanize.gutterify tag.markdown, 0}\n\n" for tag in sections.howto

      if sections.example?
        output += "Example:\n\n#{humanize.gutterify tag.markdown, 4}\n\n" for tag in sections.example

      if sections.authors?
        output += "Author#{if sections.authors.length is 1 then '' else 's'}:\n\n"
        output += "#{tag.markdown}\n\n" for tag in sections.authors

      if sections.references?
        output += "Reference#{if sections.references.length is 1 then '' else 's'}:\n\n"
        output += "#{tag.markdown}\n\n" for tag in sections.references

      output += "<br/><br/>\n\n" if 0 < output.length

      segment.comments = output.split '\n'
