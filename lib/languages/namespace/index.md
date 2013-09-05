
Language Namespaces
================================

The namespace json-files provide information to determine how to link a type. 
It consists either of an Object, an Array or an String.  The Object is mapping
type-names (eg. `Package.ClassName` or `String`) or namespaces (eg. `Package.`,
mind the trailing dot) to an URL as String or an Array containing the definition
of how to link the namespace or specific type in the generated documentation.


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
  may be substituted by `null` to disable linking completly.


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
  
  - If the Array is empty the value to process is used as link without touching it
    at all.
  
  - The Array may be substituted by null to disable linking the namespace or
    specific type completly.
  


- **urlPrefixOrFunction** :  
  
  Default: `""`
  
  If this String is a property of `LANGUAGES.….namespace` and this property
  is a function, the function will be called with the value to process, the
  `namespace.separator` and the remaining `"typeOrNamespace"`-Array elements
  as arguments.
  
  The function can either return the URL as string or `null` if the value to
  process shall not be linked.
  
  Otherwise the value is prepended to the generated URL, if it is not `null`.

- **stripNamespacePrefix** :  
  
  Default: `""`
  
  A string which will be stripped of the start of the type's value

- **addUrlSuffix** :  
  
  Default: `".html"`
  
  A string which will be appended to the end of the URL to generate.  

- **splitNamespaceString** :  
  
  Default: `LANGUAGES.….namespace.separator`
  
  A string to split the type's value or `null` to skip splitting.  The resulting
  Array will be joined with the *joinNamespaceString* described below.

- **joinNamespaceString** :  
  
  Default: `"/"`
  
  A string to join the splitted the type's value, as described above in
  *splitNamespaceString*.


### Variant (3): *Array*

    [ "functionName", "more", "arguments", … ]

- **functionName** :  
  
  The Arrays first element must be a String refering to a property of
  `LANGUAGES.….namespace` and this property must be a function.  The function
  will be called with the type's value, the `namespace.separator` and the
  remaining `"functionName"`-Array elements as arguments.
  
  The function can either return the URL as string or `null` if the function
  does not know how to link the type's value. **ATTENTION: This differs from
  the *urlPrefixOrFunction*-function in variant (1) above**


### Variant (4): *String*

    "functionName"

- **functionName** :  
  
  This String must refer to a property of `LANGUAGES.….namespace` and this
  property must be a function.  The function will be called with the type's
  value and `namespace.separator` as arguments.
  
  The function can either return the URL as string or `null` if the function
  does not know how to link the type's value. **ATTENTION: This differs from
  the *urlPrefixOrFunction*-function in variant (1) above**


Example: 1:1 type translations
--------------------------------

namespace :

    {
        "Exact.Match": "http://…/ExactMatch.html"
    }

input     :

    "Exact.Match"

output    :

    "http://…/ExactMatch.html"

--------------------------------

namespace :

    {
        "Exact.Match": "http://…/docs?type={type}"
    }

input     :

    "Exact.Match"

output    :

    "http://…/docs?type=Exact%2EMatch"


Example: Namespaces
--------------------------------

namespace :

    {
        "Package.": "http://…/docs.html#{type}"
    }

input     :

    "Package.ClassName"

output    :

    "http://…/docs.html#Package%2EClassName"


--------------------------------

namespace :

    {
        "Package.": "http://…/docs?type={type}"
    }

input     :

    "Package.ClassName"

output    :

    "http://…/docs?type=Package%2EClassName"


--------------------------------

namespace :

    {
        "link.branch.": []
    }

input     :

    "link.branch.subbranch.leaf"

output    :

    "link/branch/subbranch/leaf.html"

input     :

    "link.another.branch.subbranch.leaf"

output    :

    null

--------------------------------

namespace :

    {
        "root.branch.": ["something-to-prepend-to/"]
    }

input     :

    "root.branch.subbranch.leaf"

output    :

    "something-to-prepend-to/root/branch/subbranch/leaf.html"

input     :

    "root.another.branch.subbranch.leaf"

output    :

    null

--------------------------------

namespace :

    {
        "root.branch.": [
            "http://absolute.url/to/prepend/to/",
            "root."
        ]
    }

input     :

    "root.branch.subbranch.leaf"

output    :

    "http://absolute.url/to/prepend/to/branch.subbranch.leaf"

--------------------------------

namespace :

    {
        "root.branch.": [
            "http://absolute.url/to/prepend/to/",
            null,
            ".html"
        ]
    }

input     :

    "root.branch.subbranch.leaf"

output    :

    "http://absolute.url/to/prepend/to/root/branch/subbranch/leaf.html"

--------------------------------

namespace :

    {
        "root.branch.": [
            "relative/path/to/prepend/to/",
            null,
            "/index.html"
        ]
    }

input     :

    "root.branch.subbranch.leaf"

output    :

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

input     :

    "root.branch.subbranch.leaf"

output    :

    "path/to/prepend/to/file.subbranch.leaf.html"

--------------------------------

namespace :

    {
        "root.branch.": [
            "relative/path/to/prepend/to/file-",
            "root.branch.",
            ".html",
            "."
            "-"
        ]
    }

input     :

    "root.branch.subbranch.leaf"

output    :

    "path/to/prepend/to/file-subbranch-leaf.html"

--------------------------------

namespace :

    {
        "root.branch.": [
            "relative/path/to/prepend/to/",
             "root.",
             ".html",
             ".split.here.",
             "/path/../to/subbranch/../"
         ]
    }

input     :

    "root.branch.split.here.leaf"

output    :

    "path/to/prepend/to/branch/path/../to/subbranch/../leaf.html"


Example: skip a namespace
--------------------------------

namespace :

    {
        "skip.branch.": null
    }

input      :

    "skip.branch.link"

output     :

    null


Example: call a function
--------------------------------

namespace :

    {
        "root.branch." : [ "camelizeFunction", "more", "arguments" ]
    }

input     :

    "root.branch.subbranch.leaf"

calls     :

    LANGUAGES.….namespace.camelizeFunction(
        "root.branch.subbranch.leaf",
        LANGUAGES.….namespace.separator,
        "more", "arguments"
    )

output    :

Whatever the hypothetic function spits out, eg.:

    "More/Aruments/RootBranchSubbranchLeaf.html"

Hint: This may also be `null` to skip the link-generation.

--------------------------------

namespace :

    [ "camelizeFunction", "more", "arguments" ]

input     :

    "root.branch.subbranch.leaf"

calls     :

    LANGUAGES.….namespace.camelizeFunction(
        "root.branch.subbranch.leaf",
        LANGUAGES.….namespace.separator,
        "more", "arguments"
    )

output    :

Whatever the hypothetic function spits out, eg.:

    "More/Arguments/RootBranchSubbranchLeaf.html"

Hint: This may also be `null` if the function does not know how to handle the
given values. In this case further processing will be applied.

--------------------------------

namespace :

    "camelizeFunction"

input     :

    "root.branch.subbranch.leaf"

calls     :

    LANGUAGES.….namespace.camelizeFunction(
        "root.branch.subbranch.leaf",
        LANGUAGES.….namespace.separator
    )

output    :

Whatever the hypothetic function spits out, eg.:

    "RootBranchSubbranchLeaf.html"

Hint: This may also be `null` if the function does not know how to handle the
given values. In this case further processing will be applied.
