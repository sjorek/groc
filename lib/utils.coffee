# Miscellaneous code fragments reside here.
Utils =
  # Map a list of file paths to relative target paths by stripping prefixes off of them.
  mapFiles: (files, stripPrefixes) ->
    # Prefixes are stripped in order of most specific to least (# of directories deep)
    prefixes = stripPrefixes.sort (a,b) => @pathDepth(b) - @pathDepth(a)

    result = {}

    for absPath in files
      file = absPath

      for stripPath in stripPrefixes
        file = file[stripPath.length..] if file[0...stripPath.length] == stripPath

      # We also strip the extension under the assumption that the consumer of this path map is going
      # to substitute in their own.  Plus, if they care about the extension, they can get it from
      # the keys of the map.
      result[absPath] = file[0...-path.extname(file).length]

    result

  # How many directories deep is a given path?
  pathDepth: (path) ->
    path.split(/[\/\\]/).length

  # Split source code into segments (comment + code pairs)
  splitSource: (data, language) ->
    lines = data.split /\r?\n/

    # Always strip shebangs - but don't shift it off the array to avoid the perf hit of walking the
    # array to update indices.
    lines[0] = '' if lines[0][0..1] == '#!'

    segments = []
    currSegment = new @Segment

    # We only support single line comments for the time being.
    singleLineMatcher = ///^\s*(#{language.singleLineComment.join('|')})\s?(.*)$///

    for line in lines
      if match = line.match singleLineMatcher
        if currSegment.code.length > 0
          segments.push currSegment
          currSegment = new @Segment

        currSegment.comments.push match[2]
      else
        currSegment.code.push line

    segments.push currSegment
    segments

  # Just a convenient prototype for building segments
  Segment: class Segment
    constructor: (code=[], comments=[]) ->
      @code     = code
      @comments = comments

  # Annotate an array of segments by running their code through [Pygments](http://pygments.org/).
  highlightCode: (segments, language, callback) ->
    pygmentize = childProcess.spawn 'pygmentize', [
      '-l', language.pygmentsLexer
      '-f', 'html'
      '-O', 'encoding=utf-8,tabsize=2'
    ]
    pygmentize.stderr.addListener 'data', (data)  -> callback data.toString()
    pygmentize.stdin.addListener 'error', (error) -> callback error

    # We'll just split the output at the end.  pygmentize doesn't stream its output, and a given
    # source file is small enough that it shouldn't matter.
    result = ''
    pygmentize.stdout.addListener 'data', (data) =>
      result += data.toString()

    # Rather than spawning pygments for each segment, we stream it all in, separated by 'magic'
    # comments so that we can split the highlighted source back into segments.
    segmentDivider = "\n#{language.singleLineComment[0]} SEGMENT DIVIDER\n"

    pygmentize.addListener 'exit', (args...) =>
      # pygments spits it out wrapped in <div class="highlight"><pre>...</pre></div>.  We want to
      # manage the styling ourselves, so remove that.
      result = result.replace('<div class="highlight"><pre>', '').replace('</pre></div>', '')
      # Extract our segments from the pygmentized source.
      highlighted = "\n#{result}\n".split /\n[^\n]*SEGMENT DIVIDER[^\n]*\n/

      if highlighted.length != segments.length
        error = new Error util.format 'pygmentize rendered %d of %d segments; expected to be equal',
          highlighted.length, segments.length

        error.pygmentsOutput = result
        return callback error

      # Attach highlighted source to the highlightedCode property of a Segment.
      for segment, i in segments
        segment.highlightedCode = highlighted[i]

      callback()

    # pygmentize does not stream, so we need delimeters
    pygmentize.stdin.write (s.code.join "\n" for s in segments).join segmentDivider
    pygmentize.stdin.end()

  # Annotate an array of segments by running their comments through
  # [showdown](https://github.com/coreyti/showdown).
  markdownComments: (segments, project, callback) ->
    converter = new showdown.Showdown.converter()

    try
      for segment in segments
        markdown = converter.makeHtml segment.comments.join '\n'
        headers  = []

        # showdown generates header ids by lowercasing & dropping non-word characters.  We'd like
        # something a bit more readable.
        markdown = @gsub markdown, /<h(\d) id="[^"]+">([^<]+)<\/h\d>/g, (match) =>
          header =
            level: parseInt match[1]
            title: match[2]
            slug:  @slugifyTitle match[2]

          headers.push header

          "<h#{header.level} id=\"#{header.slug}\">#{header.title}</h#{header.level}>"

        # We attach the rendered markdown to the comment
        segment.markdownedComments = markdown
        # As well as the extracted headers to aid in outline building.
        segment.headers = headers

    catch error
      return callback error

    callback()

  # Given an array of markdowned segments, convert their list of headers into a hierarchical
  # outline (table of contents!)
  outlineHeaders: (segments) ->
    headers = segments.reduce ( (a, s) -> a.concat s.headers ), []
    return [] unless headers.length > 0

    result = []
    stack  = []

    for header in headers
      node = header: header, children: []

      # Unwind the stack until we get to the first node that is at a lower level value - we want to
      # append to that guy
      stack.pop() while stack.slice(-1)[0]?.header.level >= header.level

      # Are we starting a new top level node?
      if stack.length == 0
        result.push node
      else
        stack.slice(-1)[0].children.push node

      stack.push node

    result

  # Sometimes you just don't want any of them hanging around.
  trimBlankLines: (string) ->
    string.replace(/^[\r\n]+/, '').replace(/[\r\n]+$/, '')

  # Given a title, convert it into a URL-friendly slug.
  slugifyTitle: (string) ->
    string.split(/\s+/).map( (s) -> s.replace(/[^\w]/g, '').toLowerCase() ).join '-'

  # replacer is a function that is given the match object, and returns the string to replace with.
  gsub: (string, matcher, replacer) ->
    throw new Error 'You must pass a global RegExp to gsub!' unless matcher.global?

    result = ''
    matcher.lastIndex = 0
    furthestIndex = 0

    while (match = matcher.exec string) != null
      result += string[furthestIndex...match.index] + replacer match

      furthestIndex = matcher.lastIndex

    result + string[furthestIndex...]
