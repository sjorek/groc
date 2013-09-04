
humanize = require './utils/humanize'
type_urls_global = require '../types/javascript_globals.json'
type_urls_dom = require '../types/javascript_dom.json'


# This function collapses... spaces
#
# @private
# @method  collapse_space
#
# @param  {String} value This is the value which will be collapsed. The primary
#                        purpose of this method is to allow multiline parameter
#                        descriptions, just like this one.
#
# @return {String}
collapse_space = (value) ->
  value.replace /\s+/g, ' '

# This function creates links to JavaScript-types
#
# @param  {String} type
# @return {String}
link_type = (type, caption, url) ->

  caption ?= type

  url = get_namespace_type_url type unless url?
  url = get_known_type_url type unless url?

  if url?
    "[#{caption}](#{url})"
  else
    caption

# This function returns the URL of a well-known JavaScript-type matching `type`.
#
# @param  {String} type
# @return {String}
get_known_type_url = (type) ->
  return type_urls_global[type] if type_urls_global[type]?
  return type_urls_dom[type] if type_urls_dom[type]?
  null

# This function returns the URL determined by the `type`'s namespace.  Needs a
# namespace-url-map specified in project properties.
# 
# @param  {String} type
# @return {String}
get_namespace_type_url = (type) ->
  # TODO implement `get_namespace_type_url`
  null

# This function converts type names for return-doctags
#
# @param  {String} type
# @return {String}
convert_type = (type) ->
  if type is 'null' or type is 'undefined'
    "*#{link_type type}*"
  else if type.match /\[\]$/
    type = type.replace /\[\]$/, ""
    "an *#{link_type 'Array'}* of *#{link_type type, humanize.pluralize type}*"
  else if subtype = type.match /^(Array|Object)\.<([^>]+)>/
    subtypes = for subtypes in subtype[2].replace(/^(Array|Object)\.<|>$/g, "").split(/,/)
      "*#{link_type subtypes, humanize.pluralize subtypes}*"
    "an *#{link_type subtype[1]}* of #{humanize.joinSentence subtypes, 'or'}"
  else
    "#{humanize.article type} *#{link_type type}*"

# This function translates type names for return(s)-doctags
#
# @param  {String} type
# @return {String}
translate_type = (type) ->
  if type == 'a *mixed*' or type == 'a ***'
    'any type'
  else if type == "an *#{link_type 'Array'}* of *mixeds*" or type == "an *#{link_type 'Array'}* of ***"
    "an *#{link_type 'Array'}* of any type"
  else if type == "an *#{link_type 'Object'}* of *mixeds*" or type == "an *#{link_type 'Object'}* of ***"
    "an *#{link_type 'Object'}* with properties of any type"
  else
    type

# This function converts type names for param(s)-doctags
#
# @param  {String} type
# @return {String}
convert_parameter_type = (type) ->
  if type.match /^\.\.\.|\.\.\.$/
    type = type.replace /^\.\.\.|\.\.\.$/, ""
    "any number of *#{link_type type, humanize.pluralize type}*"
  else
    convert_type type

# This function translates type names for param(s)-doctags
#
# @param  {String} type
# @return {String}
translate_parameter_type = (type) ->
  if type == 'any number of *mixeds*'
    type = 'any number of arguments of any type'
  else
    translate_type type

# JSDOC3
#
# @access
# @alias
# @augments
# @author
# @borrows
# @callback
# @classdesc
# @constant
# @constructor
# @constructs
# @copyright
# @default
# @deprecated
# @desc
# @enum
# @event
# @example
# @exports
# @extends
# @external
# @file
# @fires
# @global
# @ignore
# @inner
# @instance
# @kind
# @lends
# @license
# @link
# @member
# @memberof
# @method
# @mixes
# @mixin
# @module
# @name
# @namespace
# @param
# @private
# @property
# @protected
# @public
# @readonly
# @requires
# @returns
# @see
# @since
# @static
# @summary
# @this
# @throws
# @todo
# @tutorial
# @type
# @typedef
# @variation
# @version

# This is a sample doc tagged block comment
#
# @public
# @module DOC_TAGS
# @type   {Object}
module.exports = DOC_TAGS =
  description:
    section:     'description'
    markdown:    '{value}'

  abstract:
    section:     'access'
  constant:
    section:     'access'
  deprecated:
    section:     'access'
  internal:
    section:     'access'
  'private':
    section:     'access'
  'protected':
    section:     'access'
  'public':
    valuePrefix: 'as'
    section:     'access'
  'static':
    section:     'access'

  constructor:
    section:     'special'
  destructor:
    section:     'special'

  'class':
    section:     'type'
    markdown:    'class *{value}*'
  event:
    section:     'type'
    # renders event-doctags
    #
    # @private
    # @method markdown
    #
    # @param  {String}   value
    # @return {String} should be in markdown syntax
    markdown:    (value) ->
      if match = collapse_space(value).match ///^\s*(.*)#(.*)\s*$///
        "event *#{link_type match[2]} of class *#{link_type match[1]}*"
      else
        "event *#{link_type value}*"
  method:
    section:     'type'
    markdown:    'method *{value}*'
  mixin:
    section:     'type'
    markdown:    'mixin *{value}*'
  module:
    section:     'type'
    markdown:    'module *{value}*'
  'package':
    section:     'type'
    markdown:    'package *{value}*'
  property:
    section:     'type'
    markdown:    'property *{value}*'

  accessor:
    section:     'flag'
    markdown:    'is an accessor'
  async:
    section:     'flag'
    markdown:    'is asynchronous'
  asynchronous:  'async'
  getter:
    section:     'flag'
    markdown:    'is a getter'
  recursive:
    section:     'flag'
    markdown:    'is recursive'
  refactor:
    section:     'flag'
    markdown:    'needs to be refactored'
  setter:
    section:     'flag'
    markdown:    'is a setter'

  alias:
    valuePrefix: 'as'
    section:     'metadata'
    markdown:    'is aliased as *{value}*'
  alias:
    valuePrefix: 'as'
    section:     'metadata'
    markdown:    'is aliased as *{value}*'
  augments:
    section:     'metadata'
    markdown:    'extends *{value}*'
  'extends':
    section:     'metadata'
    markdown:    'extends *{value}*'
  fires:
    section:     'metadata'
    # renders @fires-doctags
    #
    # @private
    # @method markdown
    #
    # @param  {String}   value
    # @return {String} should be in markdown syntax
    markdown:    (value) ->
      if match = collapse_space(value).match ///^\s*(.*)#(.*)\s*$///
        "fires #{humanize.article match[2]} *#{link_type match[2]}* event on class *#{link_type match[1]}*"
      else
        "fires #{humanize.article value} *#{link_type value}* event"
  memberof:
    section:     'metadata'
    markdown:    'is a member of *{value}*'
  mixes:
    section:     'metadata'
    markdown:    'mixes *{value}* in'
  namespace:
    section:     'metadata'
    markdown:    'is in namespace *{value}*'
  publishes:
    section:     'metadata'
  requests:
    section:     'metadata'
    markdown:    'makes an ajax request to <{value}>'
  since:
    section:     'metadata'
    markdown:    'is available since version {value}'
  subscribes:
    valuePrefix: 'to'
    section:     'metadata'
    markdown:    'subscribes to {value}'
  type:
    section:     'metadata'
    # render type-doctags
    #
    # Alternative: `markdown:    'is of type *{value}*'`
    #
    # @param  {String}  value
    # @return {String}
    markdown:     (value) ->
      value = translate_type convert_type value
      if value is 'any type'
        "is of #{value}"
      else
        "is #{value}"
  version:
    section:     'metadata'
    markdown:    'has version {value}'

  author:
    section:     'authors'
    # renders author-doctags
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @return {String}          Should be in markdown syntax
    # @author Stephan Jorek <stephan.jorek@gmail.com>
    markdown:    (value) ->
      value = collapse_space value
      # the other alternatives, as [text](link) do not (yet) encode email
      # addresses - that sucks, so we leave it as it is, for now …
      if author = value.match /^\s*(.*)<([^>]+)>\s*$/
        "* #{author[1]} (<#{author[2]}>)"
      else
        "* #{value}"

  see:
    section:     'references'
    # renders @see references
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @return {String}          Should be in markdown syntax
    # @see https://github.com/nevir/groc
    markdown:    (value) ->
      value = collapse_space value
      if /^\s*(\[[^\]]+\]\([^\)]+\)|<[^>]+>|\`[^\`]+\`)\s*$/.test value
        "* #{value}"
      else
        "* <#{value}>"

  todo:
    section:     'todo'
    markdown:    'TODO: {value}'

  example:
    section:     'example'
    markdown:    '{value}'
  examples:      'example'
  usage:         'example'

  howto:
    section:     'howto'
    markdown:    '{value}'

  # A comment that does not have doc tags in it
  note:
    section:     'discard'
  notes:         'note'

  param:
    section:     'params'
    # parses function parameters
    #
    # @public
    # @method parseValue
    #
    # @param  {String} value Text that follows @param
    #
    # @return {Object}
    parseValue:  (value) ->
      parts = collapse_space(value).match /^\{([^\}]+)\}\s+(\[?)([\w\.\$]+)(?:=([^\s\]]+))?(\]?)\s*(.*)$/
      types:        (parts[1]?.split /\|{1,2}/g)
      isOptional:   (parts[2] == '[' and parts[5] == ']')
      varName:      parts[3]
      isSubParam:   /\./.test parts[3]
      defaultValue: parts[4]
      description:  parts[6]

    # converts parsed values to markdown text
    #
    # @private
    # @method markdown
    #
    # @param  {Object}   value
    # @param  {String[]} value.types
    # @param  {Boolean}  value.isOptional=false
    # @param  {String}   value.varName
    # @param  {Boolean}  value.isSubParam=false
    # @param  {String}   [value.defaultValue]
    # @param  {String}   [value.description]
    #
    # @return {String} should be in markdown syntax
    markdown:    (value) ->
      types = (convert_parameter_type type for type in value.types)
      fragments = []

      fragments.push 'is optional' if value.isOptional
      verb = 'must'

      if types.length > 1
        verb = 'can'
      else
        type = translate_parameter_type types[0]
        if type isnt types[0]
          verb = 'can'
          types[0] = if type is 'any type' then "of #{type}" else type

      fragments.push "#{verb} be #{humanize.joinSentence types, 'or'}"
      fragments.push "has a default value of #{value.defaultValue}" if value.defaultValue?

      "#{if value.isSubParam then "    *" else "*"} ***#{value.varName}* #{humanize.joinSentence fragments}.**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  params:        'param'
  parameters:    'param'

  'return':
    section:     'returns'
    parseValue:  (value) ->
      parts = collapse_space(value).match /^\{([^\}]+)\}\s*(.*)$/
      types:       parts[1].split /\|{1,2}/g
      description: parts[2]
    markdown:     (value) ->
      types = (convert_type type for type in value.types)
      if types.length is 1
        type = translate_type types[0]
        if type isnt types[0]
          types[0] = type
      "**returns #{humanize.joinSentence types, 'or'}**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  returns:       'return'
  throw:
    section:     'returns'
    parseValue:  (value) ->
      parts = collapse_space(value).match /^\{([^\}]+)\}\s*(.*)$/
      types:       parts[1].split /\|{1,2}/g
      description: parts[2]
    markdown:    (value) ->
      types = ("#{humanize.article type} *#{link_type type}*" for type in value.types)
      "**can throw #{humanize.joinSentence types, 'or'}**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  throws:        'throw'

  defaultNoValue:
    section:     'flag'
  defaultHasValue:
    section:     'metadata'

