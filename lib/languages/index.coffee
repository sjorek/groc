# # Supported Languages

module.exports = LANGUAGES =
  Markdown            : 
    nameMatchers      : ['.md']
    commentsOnly      : true

  C                   : 
    nameMatchers      : ['.c', '.h']
    pygmentsLexer     : 'c'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  CSharp              : 
    nameMatchers      : ['.cs']
    pygmentsLexer     : 'csharp'
    singleLineComment : ['//']
    multiLineComment  : ['/*', '*', '*/']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  'C++'               : 
    nameMatchers      : ['.cpp', '.hpp', '.c++', '.h++', '.cc', '.hh', '.cxx', '.hxx']
    pygmentsLexer     : 'cpp'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '::'
      types           : []

  Clojure             : 
    nameMatchers      : ['.clj']
    pygmentsLexer     : 'clojure'
    singleLineComment : [';;']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  CoffeeScript        : 
    nameMatchers      : ['.coffee', 'Cakefile']
    pygmentsLexer     : 'coffee-script'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    doctags           : require './doctags'
    namespace         :
      separator       : '.'
      types           : [
        require './namespace/javascript_globals.json'
        require './namespace/javascript_dom.json'
      ]

  Go                  : 
    nameMatchers      : ['.go']
    pygmentsLexer     : 'go'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Handlebars          : 
    nameMatchers      : ['.handlebars', '.hbs']
    pygmentsLexer     : 'html' # TODO: is there a handlebars/mustache lexer? Nope. Lame.
    multiLineComment  : [
      '<!--', '', '-->', # HTML block comments go first, for code highlighting / segment splitting purposes
      '{{!',  '', '}}'   # Actual handlebars block comments
    ]
    ignorePrefix      : '#'
    foldPrefix        : '-'

  Haskell             : 
    nameMatchers      : ['.hs']
    pygmentsLexer     : 'haskell'
    singleLineComment : ['--']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Jade                : 
    nameMatchers      : ['.jade']
    pygmentsLexer     : 'jade'
    singleLineComment : ['//', '//-']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Java                : 
    nameMatchers      : ['.java']
    pygmentsLexer     : 'java'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  JavaScript          : 
    nameMatchers      : ['.js']
    pygmentsLexer     : 'javascript'
    singleLineComment : ['//']
    multiLineComment  : ['/*', '*', '*/']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    doctags           : require './doctags'
    namespace         :
      separator       : '.'
      types           : [
        require './namespace/javascript_globals.json'
        require './namespace/javascript_dom.json'
      ]

  Jake                : 
    nameMatchers      : ['.jake']
    pygmentsLexer     : 'javascript'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  JSON          : 
    nameMatchers      : ['.json']
    pygmentsLexer     : 'json'
    # actually this is nonsense, but we need it to render the output
    singleLineComment : ['//']
    # actually this is nonsense, but we need it to render the output
    multiLineComment  : ['/*', '*', '*/']
    # actually this is nonsense, but we need it to render the output
    ignorePrefix      : '}'
    # actually this is nonsense, but we need it to render the output
    foldPrefix        : '-'

  LaTeX               : 
    nameMatchers      : ['.tex', '.latex', '.sty']
    pygmentsLexer     : 'latex'
    singleLineComment : ['%']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  LESS                : 
    nameMatchers      : ['.less']
    pygmentsLexer     : 'sass' # TODO: is there a less lexer? No. Maybe in the future.
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Lua                 : 
    nameMatchers      : ['.lua']
    pygmentsLexer     : 'lua'
    singleLineComment : ['--']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  Make                : 
    nameMatchers      : ['Makefile']
    pygmentsLexer     : 'make'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Mustache            : 
    nameMatchers      : ['.mustache']
    pygmentsLexer     : 'html' # TODO: is there a handlebars/mustache lexer? Nope. Lame.
    multiLineComment  : ['{{!', '', '}}']
    ignorePrefix      : '#'
    foldPrefix        : '-'

  'Objective-C'       : 
    nameMatchers      : ['.m', '.mm']
    pygmentsLexer     : 'objc'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Perl                : 
    nameMatchers      : ['.pl', '.pm']
    pygmentsLexer     : 'perl'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '::'
      types           : []

  PHP                 : 
    nameMatchers      : [/\.php\d?$/, '.fbp']
    pygmentsLexer     : 'php'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '\\'
      types           : []

  Puppet              : 
    nameMatchers      : ['.pp']
    pygmentsLexer     : 'puppet'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Python              : 
    nameMatchers      : ['.py']
    pygmentsLexer     : 'python'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  Ruby                : 
    nameMatchers      : ['.rb', '.ru', '.gemspec']
    pygmentsLexer     : 'ruby'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'
    namespace         :
      separator       : '.'
      types           : []

  Sass                : 
    nameMatchers      : ['.sass']
    pygmentsLexer     : 'sass'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  SCSS                : 
    nameMatchers      : ['.scss']
    pygmentsLexer     : 'scss'
    singleLineComment : ['//']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  Shell               : 
    nameMatchers      : ['.sh']
    pygmentsLexer     : 'sh'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  SQL                 : 
    nameMatchers      : ['.sql']
    pygmentsLexer     : 'sql'
    singleLineComment : ['--']
    ignorePrefix      : '}'
    foldPrefix        : '-'

  YAML                : 
    nameMatchers      : ['.yml', '.yaml']
    pygmentsLexer     : 'yaml'
    singleLineComment : ['#']
    ignorePrefix      : '}'
    foldPrefix        : '-'
