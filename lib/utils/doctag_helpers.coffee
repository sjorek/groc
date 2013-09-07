# Doctag Helpers
# ================================

# -imports …
_ = require 'underscore'
humanize = require './humanize'

# @package  groc/lib/utils/doctag_helpers
# @type     {Object}
module.exports = DOCTAGHelpers =

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

  # This function creates links to JavaScript-types for uses in `@doctags`
  #
  # @public
  # @method  link_type
  #
  # @param  {String}                      type
  # @param  {String}                      [caption]
  # @param  {String}                      [url]
  # @param  {Object}                      [namespace] see [Supported Languages](../languages.html)
  #                                                   and [Language Namespaces](../languages/namespace.html)
  # @param  {String}                      [namespace.separator]
  # @param  {Array.<Object,Array,String>} namespace.types
  # @return {String}
  # @see    [Supported Languages](../languages.html)
  # @see    [Language Namespaces](../languages/namespace.html)
  link_type: link_type = (type, caption, url, namespace) ->

    caption ?= type

    if false and not url? and namespace?.types?
      url = null
      for types in namespace.types
        if _.isArray types
          url = create_type_link.apply null, [type, namespace.separator].concat types
        else if _.isString types
          url = create_type_link.apply null, [type, namespace.separator, types]
        else # should be an Object
          url = do ->
            url = null
            for own subtype, types of types
              if _.isArray types
              else if _.isString types
              else if types is null
                break
              else
                throw new Error 'An unsupported namespace type-definition “#{types}” occured.'
            url
        break if url?

    if url?
      "[#{caption}](#{url})"
    else
      caption
  
  # This function converts type names in `@return`- and `@type`-doctags
  #
  # @public
  # @method  convert_type
  #
  # @param  {String} type
  # @return {String}
  convert_type: convert_type = (type) ->
    if type is 'null' or type is 'undefined'
      "*#{link_type type}*"
    else if subtype = type.match /^([^\[]+)\[\]$/
      "an *#{link_type 'Array'}* of *#{link_type subtype[1], humanize.pluralize subtype[1]}*"
    else if subtype = type.match /^(Array|Object)\.<([^>]+)>/
      subtypes = for subtypes in subtype[2].replace(/^(Array|Object)\.<|>$/g, "").split(/,/)
        "*#{link_type subtypes, humanize.pluralize subtypes}*"
      "an *#{link_type subtype[1]}* of #{humanize.joinSentence subtypes, 'or'}"
    else
      "#{humanize.article type} *#{link_type type}*"
  
  # This function translates type names in `@return`- and `@type`-doctags
  #
  # @public
  # @method  translate_type
  #
  # @param  {String} type
  # @return {String}
  translate_type: translate_type = (type) ->
    if type == 'a *mixed*' or type == 'a ***'
      'any type'
    else if type == "an *#{link_type 'Array'}* of *mixeds*" or \
            type == "an *#{link_type 'Array'}* of ***"
      "an *#{link_type 'Array'}* of any type"
    else if type == "an *#{link_type 'Object'}* of *mixeds*" or \
            type == "an *#{link_type 'Object'}* of ***"
      "an *#{link_type 'Object'}* with properties of any type"
    else
      type
  
  # This function converts type names in `@param`-doctags
  #
  # @public
  # @method  convert_parameter_type
  #
  # @param  {String} type
  # @return {String}
  convert_parameter_type: convert_parameter_type = (type) ->
    if type.match /^\.\.\.|\.\.\.$/
      type = type.replace /^\.\.\.|\.\.\.$/, ""
      "any number of *#{link_type type, humanize.pluralize type}*"
    else
      convert_type type
  
  # This function translates type names in `@param`-doctags
  #
  # @public
  # @method  translate_parameter_type
  #
  # @param  {String} type
  # @return {String}
  translate_parameter_type: translate_parameter_type = (type) ->
    if type == 'any number of *mixeds*'
      type = 'any number of arguments of any type'
    else
      translate_type type
  
