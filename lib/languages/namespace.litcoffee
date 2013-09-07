Language Namespaces
================================

The namespace json-files provide information to determine how to link a type. 
It consists either of an Object, an Array or an String.  The Object is mapping
type-names (eg. `Package.ClassName` or `String`) or namespaces (eg. `Package.`,
mind the trailing dot) to an URL as String or an Array containing the definition
of how to link the namespace or specific type in the generated documentation.

    # - some stub coffee-script to make this file run …
    LANGUAGES =
        language:
            namespace:
                types    : []
                seperator: '.'
                camelize : ->


--------------------------------
Synopsis
--------------------------------

There are four variants to define how to link a type

### Variant (1): *Object-String-Map*

    {
        "typeOrNamespace": "optionalUrl?type={type}"
    }

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
  will be substituted with the urlencoded value of the type.  The whole string
  may be substituted by `false` to disable linking completly.


### Variant (2): *Object-Array-Map*

    {
        "typeOrNamespace": [
            "urlPrefixOrFunction"  ,
            "stripNamespacePrefix" ,
            "addUrlSuffix"         ,
            "splitNamespaceString" ,
            "joinNamespaceString"
        ]
    }

- **typeOrNamespace** :  
  
  See *typeOrNamespace* in variant (1) above.
  
  - If the Array is empty the value to process is used as link without touching
    it at all.
  
  - The Array may be substituted by `false` to disable linking the namespace or
    specific type completly.

- **urlPrefixOrFunction** :  
  
  Default: `""`
  
  If this String is a property of `LANGUAGES["language"].namespace` and this
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
  
  Default: `LANGUAGES["language"].namespace.separator`
  
  A string to split the type's value or `null` to skip splitting.  The resulting
  Array will be joined with the *joinNamespaceString* described below.

- **joinNamespaceString** :  
  
  Default: `"/"`
  
  A string to join the splitted the type's value, as described above in
  *splitNamespaceString*.


### Variant (3): *Array*

    [ "functionName", "more", "arguments", "…" ]

- **functionName** :  
  
  The Arrays first element must be a String refering to a property of
  `LANGUAGES["language"].namespace` and this property must be a function.  The
  function will be called with the type's value, the `namespace.separator` and
  the remaining `"functionName"`-Array elements as arguments.
  
  The function can either return the URL as string, `false` if the value to
  process shall not be linked, or `null` if the function can not handle the
  value.


### Variant (4): *String*

    "functionName"

- **functionName** :  
  
  This String must refer to a property of `LANGUAGES["language"].namespace` and
  this property must be a function.  The function will be called with the type's
  value and `namespace.separator` as arguments.
  
  The function can either return the URL as string, `false` if the value to
  process shall not be linked, or `null` if the function can not handle the
  value.


--------------------------------
Example: 1:1 type translations
--------------------------------

A namespace like …

    {
        "Exact.Match": "http://…/ExactMatch.html"
    }

… with an input like …

    # } @property dummy
    # } @type {Exact.Match}
    dummy: null

… outputs:

    # **Property *dummy* is of type [*Exact.Match*](http://…/ExactMatch.html)**
    dummy: null

--------------------------------

A namespace like …

    {
        "Exact.Match": "http://…/docs?type={type}"
    }

… with an input like …

    "Exact.Match"

… outputs:

    "http://…/docs?type=Exact%2EMatch"


Example: Namespaces
--------------------------------

A namespace like …

    {
        "Package.": "http://…/docs.html#doc-{type}"
    }

… with an input like …

    "Package.ClassName"

… outputs:

    "http://…/docs.html#doc-Package%2EClassName"


--------------------------------

A namespace like …

    {
        "Package.": "http://…/docs?type={type}"
    }

… with an input like …

    "Package.ClassName"

… outputs:

    "http://…/docs?type=Package%2EClassName"


--------------------------------

A namespace like …

    {
        "link.branch.": []
    }

… with an input like …

    "link.branch.subbranch.leaf"

… outputs:

    "link/branch/subbranch/leaf.html"

… with an input like …

    "link.another.branch.subbranch.leaf"

… outputs:

    null

--------------------------------

A namespace like …

    {
        "root.branch.": ["something-to-prepend-to/"]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "something-to-prepend-to/root/branch/subbranch/leaf.html"

… with an input like …

    "root.another.branch.subbranch.leaf"

… outputs:

    null

--------------------------------

A namespace like …

    {
        "root.branch.": [
            "http://absolute.url/to/prepend/to/",
            "root."
        ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "http://absolute.url/to/prepend/to/branch/subbranch/leaf.html"

--------------------------------

A namespace like …

    {
        "root.branch.": [
            "http://absolute.url/to/prepend/to/",
            null,
            ".html"
        ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "http://absolute.url/to/prepend/to/root/branch/subbranch/leaf.html"

--------------------------------

A namespace like …

    {
        "root.branch.": [
            "relative/path/to/prepend/to/",
            null,
            "/index.html"
        ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "relative/path/to/prepend/to/root/branch/subbranch/leaf/index.html"

--------------------------------

    {
        "root.branch.": [
            "relative/path/to/prepend/to/file",
            "root.branch",
            ".html"
            null
        ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "path/to/prepend/to/file.subbranch.leaf.html"

--------------------------------

A namespace like …

    {
        "root.branch.": [
            "relative/path/to/prepend/to/file-",
            "root.branch.",
            ".html",
            "."
            "-"
        ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… outputs:

    "path/to/prepend/to/file-subbranch-leaf.html"

--------------------------------

A namespace like …

    {
        "root.branch.": [
            "relative/path/to/prepend/to/",
             "root.",
             ".html",
             ".split.here.",
             "/path/../to/subbranch/../"
         ]
    }

… with an input like …

    "root.branch.split.here.leaf"

… outputs:

    "path/to/prepend/to/branch/path/../to/subbranch/../leaf.html"


--------------------------------
Example: skip a namespace
--------------------------------

A namespace like …

    {
        "skip.branch.": false
    }

… with an input like …

    "skip.branch.link"

… outputs:

    false


--------------------------------
Example: call a function
--------------------------------

If …

    LANGUAGES["language"].namespace.camelize

… is a function, then a namespace like …

    {
        "root.branch." : [ "camelize", "more", "arguments" ]
    }

… with an input like …

    "root.branch.subbranch.leaf"

… calls …

    LANGUAGES["language"].namespace.camelize(
        "root.branch.subbranch.leaf",
        LANGUAGES["language"].namespace.separator,
        "more", "arguments"
    )

… which outputs whatever the hypothetic `camelize`-function spits out, eg.:

    "More/Aruments/RootBranchSubbranchLeaf.html"

Hint: This may also be `false` to skip the link-generation.

And with an input like …

    "root.another.branch.subbranch.leaf"

… the process simply skips this input and goes on with the next namespace entry.

--------------------------------

If …

    LANGUAGES["language"].namespace.camelize

… is a function, then a namespace like …

    [ "camelize", "more", "arguments" ]

… with an input like …

    "root.branch.subbranch.leaf"

… calls …

    LANGUAGES["language"].namespace.camelize(
        "root.branch.subbranch.leaf",
        LANGUAGES["language"].namespace.separator,
        "more", "arguments"
    )

… which outputs whatever the hypothetic `camelize`-function spits out, eg.:

    "More/Arguments/RootBranchSubbranchLeaf.html"

Hint: This may also be `null` if the function does not know how to handle the
given values. In this case further processing will be applied.

--------------------------------

If …

    LANGUAGES["language"].namespace.camelize

… is a function, then a namespace like …

    "camelize"

… with an input like …

    "root.branch.subbranch.leaf"

… calls …

    LANGUAGES["language"].namespace.camelize(
        "root.branch.subbranch.leaf",
        LANGUAGES["language"].namespace.separator
    )

… which outputs whatever the hypothetic `camelize`-function spits out, eg.:

    "RootBranchSubbranchLeaf.html"

Hint: This may also be `null` if the function does not know how to handle the
given values. In this case further processing will be applied.
