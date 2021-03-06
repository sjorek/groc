# # groc API

fs   = require 'fs'
path = require 'path'

spate = require 'spate'

CompatibilityHelpers = require './utils/compatibility_helpers'
Logger               = require './utils/logger'
Utils                = require './utils'
styles               = require './styles'


# A core concept of `groc` is that your code is grouped into a project, and that there is a certain
# amount of context that it lends to your documentation.
#
# @class Project
# @namespace groc
module.exports = class Project
  constructor: (root, outPath, minLogLevel=Logger::INFO) ->
    @options = {}
    @log     = new Logger minLogLevel

    # * Has a single root directory that contains (most of) it.
    @root = path.resolve root
    # * Generally wants documented generated somewhere within its tree.  We default the output path
    #   to be relative to the project root, unless you pass an absolute path.
    @outPath = path.resolve @root, outPath
    # * Contains a set of files to generate documentation from, source code or otherwise.
    @files = []
    # * Should strip specific prefixes of a file's path when generating relative paths for
    #   documentation.  For example, this could be used to ensure that `lib/some/source.file` maps
    #   to `doc/some/source.file` and not `doc/lib/some/source.file`.
    @stripPrefixes = []

  # Annoyingly, we seem to be hitting a race condition within Node 0.10's
  # emulation for old-style streams.  For now, we're dropping concurrent doc
  # generation to play it safe.  People are still using groc with 0.6.
  oldNode = process.version.match /v0\.[0-8]\./
  # This is both a performance (over-)optimization and debugging aid.  Instead of spamming the
  # system with file I/O and overhead all at once, we only process a certain number of source files
  # concurrently.  This is similar to what [graceful-fs](https://github.com/isaacs/node-graceful-fs)
  # accomplishes.
  BATCH_SIZE: if oldNode then 10 else 1

  # Where the magic happens.
  #
  # Currently, the only supported option is:
  generate: (options, callback) ->
    @log.trace 'Project#Generate(%j, ...)', options
    @log.info 'Generating documentation …'

    # * style: The style prototype to use.  Defaults to `styles.Default`
    style = new (options.style || styles.Default) @

    # We need to ensure that the project root is a strip prefix so that we properly generate
    # relative paths for our files.  Since strip prefixes are relative, it must be the first prefix,
    # so that they can strip from the remainder.
    @stripPrefixes = [@root + CompatibilityHelpers.pathSep].concat @stripPrefixes

    fileMap   = Utils.mapFiles @root, @files, @stripPrefixes
    indexPath = path.resolve @root, @index

    pool = spate.pool (k for k of fileMap), maxConcurrency: @BATCH_SIZE, (currentFile, done) =>
      @log.debug "Processing %s", currentFile

      language = Utils.getLanguage currentFile, @options.languages
      unless language?
        @log.warn '%s is not in a supported language, skipping.', currentFile
        return done()

      fs.readFile currentFile, 'utf-8', (error, data) =>
        if error
          @log.error "Failed to process %s: %s", currentFile, error.message
          return callback error

        fileInfo =
          language:    language
          sourcePath:  currentFile
          projectPath: currentFile.replace ///^#{Utils.regexpEscape @root + CompatibilityHelpers.pathSep}///, ''
          targetPath:  if currentFile == indexPath then 'index' else fileMap[currentFile]
          pageTitle:   if currentFile == indexPath then (options.indexPageTitle || 'index') else fileMap[currentFile]

        markdownFile = "#{currentFile}.md" if language.codeOnly
        if markdownFile? and not fileMap[markdownFile]? and fs.existsSync(markdownFile)
          fs.readFile markdownFile, 'utf-8', (error, markdown) =>
            if error
              @log.error "Failed to process documentation %s of %s: %s", markdownFile, currentFile, error.message
              return callback error

            fileInfo.markdown = markdown
            style.renderFile data, fileInfo, done
        else
          style.renderFile data, fileInfo, done

    pool.exec (error) =>
      return callback error if error

      style.renderCompleted (error) =>
        return callback error if error

        @log.info ''
        @log.pass 'Documentation generated'
        @log.info ''
        @export style, options, callback

  # And where the magic is drilled into the disk.
  export: (style, options, callback) ->
    @log.trace 'Project#Export(%j, ...)', options
    @log.info 'Exporting documentation …'

    pool = spate.pool (k for k in style.docs), maxConcurrency: @BATCH_SIZE, (context, done) =>
      {
        docPath,
        sourcePath
      } = context
      @log.debug "Exporting %s", docPath

      docPage = style.renderTemplate context, sourcePath, docPath, callback

      if docPage?
        fs.writeFile docPath, docPage, 'utf-8', (error) =>
          if error
            @log.error 'Failed to export file %s: %s', docPath, error.message
            return callback error
          @log.pass "Exported “#{docPath}”"
          done()
      else
        @log.warn "Skipped “#{docPath}”"
        done()

    pool.exec (error) =>
      return callback error if error

      style.exportCompleted (error) =>
        return callback error if error

        @log.info ''
        @log.pass 'Documentation exported'
        @log.info ''
        callback()
