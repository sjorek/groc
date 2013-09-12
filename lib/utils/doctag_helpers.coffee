# Doctag Helpers
# ================================

# ^ imports …
_ = require 'underscore'
humanize = require './humanize'

# * * *
# Provides helper methods used by the `doctags`-implementation
#
# @package  DOCTAGHelpers
# @type     {Object}
# @see [Supported Doctags](../languages/doc_tags.html)
module.exports = DOCTAGHelpers =

  # * * *
  # This function collapses... spaces
  #
  # @public
  # @method  collapse_space
  #
  # @param  {String} value This is the value which will be collapsed. The primary
  #                        purpose of this method is to allow multiline parameter
  #                        descriptions, just like this one.
  #
  # @return {String}
  collapse_space: collapse_space = (value) ->
    value.replace /\s+/g, ' '

  # * * *
  # This function converts type names in `@return`- and `@type`-doctags
  #
  # @public
  # @method  convert_type
  #
  # @param  {String} type
  # @param  {Object} fileInfo
  # @return {String}
  convert_type: convert_type = (type, fileInfo) ->
    if type is 'null' or type is 'undefined'
      "*#{link_type type, fileInfo}*"
    else if subtype = type.match /^([^\[]+)\[\]$/
      "an *#{link_type 'Array', fileInfo}* of *#{link_type subtype[1], fileInfo, humanize.pluralize subtype[1]}*"
    else if subtype = type.match /^(Array|Object)\.<([^>]+)>/
      subtypes = for subtypes in subtype[2].replace(/^(Array|Object)\.<|>$/g, "").split(/,/)
        "*#{link_type subtypes, fileInfo, humanize.pluralize subtypes}*"
      "an *#{link_type subtype[1], fileInfo}* of #{humanize.joinSentence subtypes, 'or'}"
    else
      "#{humanize.article type} *#{link_type type, fileInfo}*"

  # * * *
  # This function translates type names in `@return`- and `@type`-doctags
  #
  # @public
  # @method  translate_type
  #
  # @param  {String} type
  # @param  {Object} fileInfo
  # @return {String}
  translate_type: translate_type = (type, fileInfo) ->
    if type == 'a *mixed*' or type == 'a ***'
      'any type'
    else if type == "an *#{link_type 'Array', fileInfo}* of *mixeds*" or \
            type == "an *#{link_type 'Array', fileInfo}* of ***"
      "an *#{link_type 'Array', fileInfo}* of any type"
    else if type == "an *#{link_type 'Object', fileInfo}* of *mixeds*" or \
            type == "an *#{link_type 'Object', fileInfo}* of ***"
      "an *#{link_type 'Object', fileInfo}* with properties of any type"
    else
      type

  # * * *
  # This function converts type names in `@param`-doctags
  #
  # @public
  # @method  convert_parameter_type
  #
  # @param  {String} type
  # @param  {Object} fileInfo
  # @return {String}
  convert_parameter_type: convert_parameter_type = (type, fileInfo) ->
    if type.match /^\.\.\.|\.\.\.$/
      type = type.replace /^\.\.\.|\.\.\.$/, ""
      "any number of *#{link_type type, fileInfo, humanize.pluralize type}*"
    else
      convert_type type, fileInfo

  # * * *
  # This function translates type names in `@param`-doctags
  #
  # @public
  # @method  translate_parameter_type
  #
  # @param  {String} type
  # @param  {Object} fileInfo
  # @return {String}
  translate_parameter_type: translate_parameter_type = (type, fileInfo) ->
    if type == 'any number of *mixeds*'
      type = 'any number of arguments of any type'
    else
      translate_type type, fileInfo

  # * * *
  # This function creates links to JavaScript-types for uses in `@doctags`
  #
  # @public
  # @method  link_type
  #
  # @param  {String}  type
  # @param  {Object}  [fileInfo]
  # @param  {Object}  [fileInfo.language]
  # @param  {Object}  [fileInfo.language.namespace]
  # @param  {String}  [fileInfo.language.namespace.separator]
  # @param  {Array.<Object,Array,String>} [fileInfo.language.namespace.types]
  # @param  {String}  [caption]
  # @param  {String}  [url]
  # @return {String}
  # @see    [Supported Languages](../languages.html)
  # @see    [Language Namespaces](../languages/namespace.html)
  link_type: link_type = (type, fileInfo, caption, url) ->
    if fileInfo?.language?.namespace? 
      namespace = fileInfo.language.namespace
    else
      namespace = null

    caption ?= type
    
    url ?= null

    if type and not url? and namespace?.types?
      for definition in namespace.types
        if _.isArray(definition) or _.isString(definition)
          url = create_type_url type, namespace, definition
        else if definition is false or definition is null
          url = definition
        else # should be an Object
          for own ns, subdef of definition
            if type isnt ns
              continue unless namespace.separator and
                              ns.lastIndexOf(namespace.separator) is \
                              ns.length - namespace.separator.length and \
                              type.indexOf(ns) is 0
            if _.isArray(subdef) or _.isString(subdef)
              url = create_type_url type, namespace, subdef
              break if url isnt null
            else if subdef is false or subdef is null
              url = subdef
              break
            else
              throw new Error 'An unsupported namespace type-definition “#{definition}” occured.'
        break if url?

      if url and /\{type(\.[0-9]+)?\}/.test url
        # replace the `{type}` marker
        url = url.replace '{type}', url_encode type
        if namespace.separator
          for fragment, index in type.split namespace.separator
            # replace the `{type.index}` marker
            url = url.replace "{type.#{index}}", url_encode fragment
        # strip all `{type.index}` markers that are left
        url = url.replace /\{type.[0-9]+\}/g, ''

    if url
      "[#{caption}](#{url})"
    else
      caption

  # * * *
  # create an URL or skip the URL for the given type, depending on the given
  # namespace and definition
  #
  # @public
  # @method create_type_url
  #
  # @param  {String}    type
  # @param  {Object.<Function,String,Array>}  namespace
  # @param  {String}    [namespace.separator]
  # @param  {Array}     [namespace.types]
  # @param  {Function}  [namespace.fn]  Functions will be called as:
  #                                     `fn(type, separator, args...)`
  # @param  {Array|String}  definition  An array as documented below or
  #                                     the URL to return
  # @param  {String}    [definition.0]  A Function in `namespace[definition.0]`
  #                                     or an URL-fragment prepended to the result
  # @param  {Array}     [definition.1]  A string to strip from the start of `type`
  #                                     or third argument of `namespace[definition.0](…)`
  # @param  {Array}     [definition.2]  A string to append to the URL or fourth
  #                                     argument of `namespace[definition.0](…)`
  # @param  {Array}     [definition.3]  A string to split `type` or fifth
  #                                     argument of `namespace[definition.0](…)`
  # @param  {Array}     [definition.4]  A string to join the splitted `type` or
  #                                     sixth argument of `namespace[definition.0](…)`
  # @return {String|Boolean|null}
  # @see [Type Namespaces](../languages/namespace.html)
  create_type_url: create_type_url = (type, namespace, definition) ->

    hasDefinition = _.isArray definition

    if hasDefinition
      [urlOrFn, strip, append, split, join] = definition
    else
      urlOrFn = "#{definition}"

    if urlOrFn and namespace[urlOrFn]? and _.isFunction namespace[urlOrFn]
      namespace[urlOrFn].apply(
        null,
        [type, namespace.separator].concat(
          if hasDefinition then definition[1..] else []
        )
      )
    else if hasDefinition
      urlOrFn ?= ''
      strip   ?= ''
      append  ?= '.html'
      split   ?= namespace.separator
      join    ?= '/'
      name     = if type.indexOf(strip) is 0 then "#{type[strip.length..]}" else "#{type}"

      "#{urlOrFn}#{if split then name.split(split).join(join) else name}#{append}"
    else
      urlOrFn

  # * * *
  # encode a string-fragment for URLs including some extra characters,
  # which might cause troubles under some circumstances:
  # > * `!` -> `%21`
  # > * `'` -> `%27`
  # > * `(` -> `%28`
  # > * `)` -> `%29`
  # > * `*` -> `%2A`
  # > * `.` -> `%2E`
  # > * `~` -> `%7E`
  # @todo Fix indent-detection and remove work-around citations as above …
  #
  # @public
  # @method url_encode
  # @param  {String}  fragment
  # @return {String}
  url_encode: url_encode = (fragment) ->
    encodeURIComponent(fragment) \
      .replace(/!/g,  '%21') \
      .replace(/'/g,  '%27') \
      .replace(/\(/g, '%28') \
      .replace(/\)/g, '%29') \
      .replace(/\*/g, '%2A') \
      .replace(/\./g, '%2E') \
      .replace(/~/g,  '%7E')
