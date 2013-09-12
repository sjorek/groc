Supported Namespaces
================================

    # ^ import the type-link generating function for testing purposes
    {link_type} = require './utils/doctag_helpers'
    
    # ^ … and some pretty colors
    colors = require 'colors'


--------------------------------
## Important notice

This file has been written for documentation and testing purposes only.  This
might change in future.  So, if you're reading this file's source instead of the
generated documentation, you should (mentally) replace every occurence of
`# } @…` below this comment with `# @…` (mind the stripped `}`-bracket).


--------------------------------
## Objectives

The namespace json-files provide information used to determine how to link a
type.  It consists of a list of Objects, Arrays, Strings or a mix of these
three variants.

The Object-variant maps types (eg. `Package.ClassName` or `String`) or
namespaces (eg. `Package.`, mind the trailing dot) to an URL as String or 
an Array containing the definition of how to link the namespace or specific
type in the generated documentation.

The Array and the String-variants provide a subset of (or shortcut to) the
Object-variant's capabilities, as documented below.


--------------------------------
## Language definitions

    # This is stub coffee-script providing a reduced reference of the related
    # [language definition file](../languages.html)'s structure.  Also required
    # to make this file run without failures, if one tries to do so.
    LANGUAGES =
      language:
        namespace:
          types    : []
          separator: '.'
          
          # Convert “a.property.name” to “A/Property/Name.html”
          #
          # @public
          # @method camelize
          # @param  {String}    type        Input property string
          # @param  {String}    separator   A namespace-separator string
          # @param  {String...} [args]      Some payload
          # @return {String}                Camelized URL-string
          camelize : do ->
            
            _regexp = /(^|\.)([a-z0-9])/gi
            
            _camelize = (match, dot, char) ->
              "#{if dot then '/' else ''}#{char.toUpperCase()}"
            
            (type, separator, args...) ->
              return false if /force/.test type
              return null if /skip/.test type
              url = args.concat(type.split separator).join(separator)
              "#{url.replace(_regexp, _camelize)}.html"

    # ^ define a test-counter to ease indentifing the tests below
    test_counter = 0

    # ^ define a test-function to prove that `link_type` is working porperly
    test_link_type = (input, output) ->
      result = link_type input, LANGUAGES # ATTENTION: Here it's meant to be a faked fileInfo-object !
      console.log "---- test no. #{++test_counter} ----"
      if result is output
        console.info colors['green']("""
    Success:
        input           : #{input}
        desired output  : #{output}
        result          : #{result}
        namespace.types :
    
    """), LANGUAGES.language.namespace.types
      else
        console.error colors['red']("""
    Failure:
        input           : #{input}
        desired output  : #{output}
        result          : #{result}
        namespace.types :
    
    """), LANGUAGES.language.namespace.types


--------------------------------
## Synopsis

There are four variants to define how to link a type

### Variant (1): A list of *Object-String-Maps*

    LANGUAGES.language.namespace.types = [
      "typeOrNamespace": "url?type={type}&firstPart={type.0}&secondPart={type.1}"
    ]

- **typeOrNamespace** :  
  
  This key is used to match the value to process.  May either match exactly with
  the given value …  
  
  >     "typeOrNamespace" === "value"
  
  … or if the processed language knows namespaces and has a `namespace.separator`
  and the value ends with this separator …  
  
  >     "typeOrNamespace".lastIndexOf(separator) === \
  >     "typeOrNamespace".length - separator.length
  
  … it can also match the start of the value …
  
  >     "value".indexOf("typeOrNamespace") === 0

- **optionalUrl?type={type}** :  
  
  This String-value represents the URL to link to.  Any occurence of `{type}`
  will be substituted with the urlencoded value of the type.  The type name's
  fragments replace any occurence of `{type.positionOfFragment-1}`.  Any of 
  those placeholders being left after substition, will be stripped from the
  resulting string.
  
  The whole string may be substituted by `false` to disable linking completly.


### Variant (2): A list *Object-Array-Maps*

    LANGUAGES.language.namespace.types = [
      "typeOrNamespace": [
        "urlPrefixOrFunction"  ,
        "stripNamespacePrefix" ,
        "addUrlSuffix"         ,
        "splitNamespaceString" ,
        "joinNamespaceString"
      ]
    ]

- **typeOrNamespace** :  
  
  See *typeOrNamespace* in variant (1) above.
  
  - If the Array is empty the value to process is used as link without touching
    it at all.
  
  - The Array may be substituted by `false` to disable linking the namespace or
    specific type completly.

- **urlPrefixOrFunction** :  
  
  Default: `""`
  
  If this String is a property of `LANGUAGES.language.namespace` and this
  property is a function, the function will be called with the value to process,
  the `namespace.separator` and the remaining `"typeOrNamespace"`-Array elements
  as arguments.
  
  The function can either return the URL as string, `false` if the value to
  process shall not be linked, or `null` if the function can not handle the
  value.
  
  Otherwise the value is prepended to the generated URL.

- **stripNamespacePrefix** :  
  
  Default: `""`
  
  A string which will be stripped of the start of the type's value

- **addUrlSuffix** :  
  
  Default: `".html"`
  
  A string which will be appended to the end of the URL to generate.  

- **splitNamespaceString** :  
  
  Default: `LANGUAGES.language.namespace.separator`
  
  A string to split the type's value or `null` to skip splitting.  The resulting
  Array will be joined with the *joinNamespaceString* described below.

- **joinNamespaceString** :  
  
  Default: `"/"`
  
  A string to join the splitted the type's value, as described above in
  *splitNamespaceString*.


### Variant (3): A list of *Arrays*

    LANGUAGES.language.namespace.types = [
      [
        "urlPrefixOrFunction"  ,
        "stripNamespacePrefix" ,
        "addUrlSuffix"         ,
        "splitNamespaceString" ,
        "joinNamespaceString"
      ]
    ]

See variant (2) above.  The difference is that every type-value will be
processed by this definition, no matter which type or namespace it is.


### Variant (4): A list of *Strings*

    LANGUAGES.language.namespace.types = [
      "urlPrefixOrFunction"
    ]

See variant (2) above.  The difference is that every type-value will be
processed by this definition, no matter which type or namespace it is.


--------------------------------
## Example: 1:1 type translations

A namespace like …

    LANGUAGES.language.namespace.types = [
      "Exact.Match": "http://…/ExactMatch.html"
    ]

… with an input like …

    # } @property dummy
    # } @type {Exact.Match}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[Exact.Match](http://…/ExactMatch.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'Exact.Match', '[Exact.Match](http://…/ExactMatch.html)'

--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "Exact.Match": "http://…/docs?type={type}"
    ]

… with an input like …

    # } @property dummy
    # } @type {Exact.Match}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[Exact.Match](http://…/docs?type=Exact%2EMatch)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'Exact.Match', '[Exact.Match](http://…/docs?type=Exact%2EMatch)'

--------------------------------
## Example: Namespaces

A namespace like …

    LANGUAGES.language.namespace.types = [
      "Package.": "http://…/docs.html#doc-{type}"
    ]

… with an input like …

    # } @property dummy
    # } @type {Package.ClassName}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[Package.ClassName](http://…/docs.html#doc-Package%2EClassName)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'Package.ClassName', '[Package.ClassName](http://…/docs.html#doc-Package%2EClassName)'

--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "Package.": "http://…/docs?package={type.0}&amp;class={type.1}{type.2}"
    ]

… with an input like …

    # } @property dummy
    # } @type {Package.ClassName}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[Package.ClassName](http://…/docs?package=Package&amp;class=ClassName)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'Package.ClassName', '[Package.ClassName](http://…/docs?package=Package&amp;class=ClassName)'

--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": []
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](root/branch/subbranch/leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](root/branch/subbranch/leaf.html)'

… or with an input like …

    # } @property dummy
    # } @type {another.branch.subbranch.leaf}
    dummy: null

… outputs if no other namespace- or type-definition matches …

    # **Property *dummy* is of type *another.branch.subbranch.leaf***
    dummy: null

    # ^ let's prove it …
    test_link_type 'another.branch.subbranch.leaf', 'another.branch.subbranch.leaf'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": ["something-to-prepend-to/"]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](something-to-prepend-to/root/branch/subbranch/leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](something-to-prepend-to/root/branch/subbranch/leaf.html)'

… or with an input like …

    # } @property dummy
    # } @type {another.branch.subbranch.leaf}
    dummy: null

… outputs if no other namespace- or type-definition matches …

    # **Property *dummy* is of type *another.branch.subbranch.leaf***
    dummy: null

    # ^ let's prove it …
    test_link_type 'another.branch.subbranch.leaf', 'another.branch.subbranch.leaf'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "http://absolute.url/to/prepend/to/",
        "root."
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](http://absolute.url/to/prepend/to/branch/subbranch/leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](http://absolute.url/to/prepend/to/branch/subbranch/leaf.html)'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "http://absolute.url/to/prepend/to/",
        null,
        ".html"
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](http://absolute.url/to/prepend/to/root/branch/subbranch/leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](http://absolute.url/to/prepend/to/root/branch/subbranch/leaf.html)'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "relative/path/to/prepend/to/",
        null,
        "/index.html"
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](relative/path/to/prepend/to/root/branch/subbranch/leaf/index.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](relative/path/to/prepend/to/root/branch/subbranch/leaf/index.html)'


--------------------------------

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "path/to/prepend/to/file",
        "root.branch",
        ".html"
        false
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](path/to/prepend/to/file.subbranch.leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](path/to/prepend/to/file.subbranch.leaf.html)'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "path/to/prepend/to/file-",
        "root.branch.",
        ".html",
        "."
        "-"
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](path/to/prepend/to/file-subbranch-leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](path/to/prepend/to/file-subbranch-leaf.html)'


--------------------------------

A namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch.": [
        "path/to/prepend/to/",
        "root.",
        ".html",
        ".split.here.",
        "/path/../to/subbranch/../"
      ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.split.here.leaf}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[root.branch.split.here.leaf](path/to/prepend/to/branch/path/../to/subbranch/../leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.split.here.leaf', '[root.branch.split.here.leaf](path/to/prepend/to/branch/path/../to/subbranch/../leaf.html)'


--------------------------------
## Example: skip linking a type or namespace

A namespace like …

    LANGUAGES.language.namespace.types = [
      "branch.to.skip": false
      "branch.to."    : "http://…/"
    ]

… with an input like …

    # } @property dummy
    # } @type {branch.to.link}
    dummy: null

… outputs …

    # **Property *dummy* is of type *[branch.to.link](http://…/)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'branch.to.link', '[branch.to.link](http://…/)'

… with an input like …

    # } @property dummy
    # } @type {branch.to.skip}
    dummy: null

… outputs …

    # **Property *dummy* is of type *branch.to.skip***
    dummy: null

    # ^ let's prove it …
    test_link_type 'branch.to.skip', 'branch.to.skip'


--------------------------------
## Example: call a function

If …

    LANGUAGES.language.namespace.camelize

… is a function, then a namespace like …

    LANGUAGES.language.namespace.types = [
      "root.branch." : [ "camelize", "more", "arguments" ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… calls …

    LANGUAGES.language.namespace.camelize(
      "root.branch.subbranch.leaf",
      LANGUAGES.language.namespace.separator,
      "more", "arguments"
    )

… and outputs whatever the hypothetic `camelize`-function spits out …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](More/Arguments/Root/Branch/Subbranch/Leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](More/Arguments/Root/Branch/Subbranch/Leaf.html)'

… or with an input like …

    # } @property dummy
    # } @type {root.branch.to.force}
    dummy: null

… it's result is `false` to skip the link-generation, so the process outputs …

    # **Property *dummy* is of type *root.branch.to.force***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.to.force', 'root.branch.to.force'

… or with an input like …

    # } @property dummy
    # } @type {root.branch.to.skip}
    dummy: null

… the process simply skips this input and goes on with the next namespace entry,
so the process outputs …

    # **Property *dummy* is of type *root.branch.to.skip***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.to.skip', 'root.branch.to.skip'

--------------------------------

If …

    LANGUAGES.language.namespace.camelize

… is a function, then a namespace like …

    LANGUAGES.language.namespace.types = [
      [ "camelize", "more", "arguments" ]
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… calls …

    LANGUAGES.language.namespace.camelize(
      "root.branch.subbranch.leaf",
      LANGUAGES.language.namespace.separator,
      "more", "arguments"
    )

… and outputs whatever the hypothetic `camelize`-function spits out …

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](More/Aruments/Root/Branch/Subbranch/Leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](More/Arguments/Root/Branch/Subbranch/Leaf.html)'

… or if it's result is `false` to skip the link-generation, the process outputs …

    # **Property *dummy* is of type *root.branch.to.force***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.to.force', 'root.branch.to.force'

… or if it's result is `null` to indicate that the function does not know how to
handle the given type, then further processing will be applied.

    # ^ let's prove it …
    test_link_type 'root.branch.to.skip', 'root.branch.to.skip'


--------------------------------

If …

    LANGUAGES.language.namespace.camelize

… is a function, then a namespace like …

    LANGUAGES.language.namespace.types = [
      "camelize"
    ]

… with an input like …

    # } @property dummy
    # } @type {root.branch.subbranch.leaf}
    dummy: null

… calls …

    LANGUAGES.language.namespace.camelize(
      "root.branch.subbranch.leaf",
      LANGUAGES.language.namespace.separator
    )

… which outputs whatever the hypothetic `camelize`-function spits out, eg.:

    # **Property *dummy* is of type *[root.branch.subbranch.leaf](Root/Branch/Subbranch/Leaf.html)***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.subbranch.leaf', '[root.branch.subbranch.leaf](Root/Branch/Subbranch/Leaf.html)'

… or if it's result is `false` to skip the link-generation, the process outputs …

    # **Property *dummy* is of type *root.branch.to.force***
    dummy: null

    # ^ let's prove it …
    test_link_type 'root.branch.to.force', 'root.branch.to.force'

… or if it's result is `null` to indicate that the function does not know how to
handle the given type, then further processing will be applied.

    # ^ let's prove it …
    test_link_type 'root.branch.to.skip', 'root.branch.to.skip'

