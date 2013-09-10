# Supported Doctags
# ================================
#
# This script tries to implement known doctags from jsdoc, jsdoc2 and jsdoc3. 
# Most of them are supported.  This implementation is mainly suitable for
# languages like *Javascript*, *Coffeescript* or even *PHP*, but certainly not
# for *Ruby* or *Python* as the later languages have their own conventions and
# thorough introspection capabilities.

# A list of doctag-candidates:  
#   
# _@access_  
# _@alias_  
# _@augments_  
# _@author_  
# _@borrows_  
# _@callback_  
# _@classdesc_  
# _@constant_  
# _@constructor_  
# _@constructs_  
# _@copyright_  
# _@default_  
# _@deprecated_  
# _@desc_  
# _@enum_  
# _@event_  
# _@example_  
# _@exports_  
# _@extends_  
# _@external_  
# _@file_  
# _@fires_  
# _@global_  
# _@ignore_  
# _@inner_  
# _@instance_  
# _@kind_  
# _@lends_  
# _@license_  
# _@link_  
# _@member_  
# _@memberof_  
# _@method_  
# _@mixes_  
# _@mixin_  
# _@module_  
# _@name_  
# _@namespace_  
# _@param_  
# _@private_  
# _@property_  
# _@protected_  
# _@public_  
# _@readonly_  
# _@requires_  
# _@returns_  
# _@see_  
# _@since_  
# _@static_  
# _@summary_  
# _@this_  
# _@throws_  
# _@todo_  
# _@tutorial_  
# _@type_  
# _@typedef_  
# _@variation_  
# _@version_  

# -imports
humanize = require '../utils/humanize'

{
  collapse_space,
  link_type,
  convert_type,
  translate_type,
  convert_parameter_type,
  translate_parameter_type
} = require '../utils/doctag_helpers'

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
    markdown:    'class *{type}*'
  event:
    section:     'type'
    # renders `@event`-doctags
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @param  {Object}  fileInfo
    # @return {String}  should be in markdown syntax
    markdown:    (value, fileInfo) ->
      if match = collapse_space(value).match ///^\s*(.*)#(.*)\s*$///
        "event *#{link_type match[2], fileInfo} of class *#{link_type match[1], fileInfo}*"
      else
        "event *#{link_type value, fileInfo}*"
  method:
    section:     'type'
    markdown:    'method *{type}*'
  mixin:
    section:     'type'
    markdown:    'mixin *{type}*'
  module:
    section:     'type'
    markdown:    'module *{type}*'
  'package':
    section:     'type'
    markdown:    'package *{type}*'
  property:
    section:     'type'
    markdown:    'property *{type}*'

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
    markdown:    'is aliased as *{type}*'
  augments:
    section:     'metadata'
    markdown:    'extends *{type}*'
  'extends':
    section:     'metadata'
    markdown:    'extends *{type}*'
  fires:
    section:     'metadata'
    # renders `@fires`-doctags
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @param  {Object}   fileInfo
    # @return {String}          should be in markdown syntax
    markdown:    (value, fileInfo) ->
      if match = collapse_space(value).match ///^\s*(.+)#(.+)\s*$///
        "fires #{humanize.article match[2]} *#{link_type match[2], fileInfo}* event on class *#{link_type match[1], fileInfo}*"
      else
        "fires #{humanize.article value} *#{link_type value, fileInfo}* event"
  memberof:
    section:     'metadata'
    markdown:    'is a member of *{type}*'
  mixes:
    section:     'metadata'
    markdown:    'mixes *{type}* in'
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
    markdown:    'subscribes to {type}'
  type:
    section:     'metadata'
    # render `@type`-doctags
    #
    # Alternative: `markdown:    'is of type *{value}*'`
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @param  {Object}   fileInfo
    # @return {String}
    markdown:     (value, fileInfo) ->
      value = translate_type convert_type(value, fileInfo), fileInfo
      if value is 'any type'
        "is of #{value}"
      else
        "is #{value}"
  version:
    section:     'metadata'
    markdown:    'has version {value}'

  author:
    section:     'authors'
    # renders `@author`-doctags
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
    # renders `@see`-doctags as hyperlink references
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
    # @public
    # @method markdown
    #
    # @param  {Object}   value
    # @param  {String[]} value.types
    # @param  {Boolean}  value.isOptional=false
    # @param  {String}   value.varName
    # @param  {Boolean}  value.isSubParam=false
    # @param  {String}   [value.defaultValue]
    # @param  {String}   [value.description]
    # @param  {Object}   fileInfo
    # @return {String} should be in markdown syntax
    markdown:    (value, fileInfo) ->
      types = (convert_parameter_type(type, fileInfo) for type in value.types)
      fragments = []

      fragments.push 'is optional' if value.isOptional
      verb = 'must'

      if types.length > 1
        verb = 'can'
      else
        type = translate_parameter_type types[0], fileInfo
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
    markdown:     (value, fileInfo) ->
      types = (convert_type(type, fileInfo) for type in value.types)
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
    markdown:    (value, fileInfo) ->
      types = ("#{humanize.article type} *#{link_type type, fileInfo}*" for type in value.types)
      "**can throw #{humanize.joinSentence types, 'or'}**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  throws:        'throw'

  defaultNoValue:
    section:     'flag'
  defaultHasValue:
    section:     'metadata'

