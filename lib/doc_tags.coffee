# # Known Doc Tags

humanize = require './utils/humanize'

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
  event:
    section:     'type'
    # converts parsed values to markdown text
    #
    # @private
    # @method markdown
    #
    # @param  {String}   value
    # @return {String} should be in markdown syntax
    markdown:    (value) ->
      if match = collapse_space(value).match ///^\s*(.*)#(.*)\s*$///
        "event #{match[2]} of class #{match[1]}"
      else
        "event #{value}"
  method:
    section:     'type'
  mixin:
    section:     'type'
  module:
    section:     'type'
  'package':
    section:     'type'
  property:
    section:     'type'

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
    markdown:    'is aliased as _{value}_'
  fires:
    section:     'metadata'
    # converts parsed values to markdown text
    #
    # @private
    # @method markdown
    #
    # @param  {String}   value
    # @return {String} should be in markdown syntax
    markdown:    (value) ->
      if match = collapse_space(value).match ///^\s*(.*)#(.*)\s*$///
        "fires #{humanize.article match[2]} _#{match[2]}_ event on class _#{match[1]}_"
      else
        "fires #{humanize.article value} _#{value}_ event"
  memberof:
    section:     'metadata'
    markdown:    'is a member of _{value}_'
  mixes:
    section:     'metadata'
    markdown:    'mixes _{value}_ in'
  namespace:
    section:     'metadata'
    markdown:    'is in namespace _{value}_'
  publishes:
    section:     'metadata'
  requests:
    section:     'metadata'
    markdown:    'makes an ajax request to <{value}>'
  see:
    section:     'metadata'
    markdown:    'refers to <{value}>'
  since:
    section:     'metadata'
    markdown:    'is available since version {value}'
  subscribes:
    valuePrefix: 'to'
    section:     'metadata'
    markdown:    'subscribes to {value}'
  type:
    section:     'metadata'
    markdown:    'is of type _{value}_'
  version:
    section:     'metadata'
    markdown:    'has version {value}'


  author:
    section:     'authoring'

    # renders author names, optionally hyper-linked
    #
    # @public
    # @method markdown
    #
    # @param  {String}  value
    # @return {String}          Should be in markdown syntax
    markdown:    (value) ->
      if match = collapse_space(value).match /^\s*([^<]+)\s+<([^>]+)>\s*$/
        # the other alternatives, as [text](link) do not (yet) encode email
        # addresses - that sucks, so adding braces simply looks and reads
        # better in the resulting output
        "#{match[1]} (<#{match[2]}>)"
      else
        "#{value}"

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
      types = (
        for type in value.types
          if type.match /^\.\.\.|\.\.\.$/
            "any number of #{humanize.pluralize type.replace(/^\.\.\.|\.\.\.$/, "")}"
          else if type.match /\[\]$/
            "an Array of #{humanize.pluralize type.replace(/\[\]$/, "")}"
          else if type.match /^Array<[^>]+>/
            values = for value in type.replace(/^Array<|>$/, "").split(/,|\|/)
              humanize.pluralize value
            "an Array of #{humanize.joinSentence values, 'or'}"
          else
            "#{humanize.article type} #{type}"
      )

      fragments = []

      fragments.push 'is optional' if value.isOptional
      verb = 'must'

      if types.length > 1
        verb = 'can'
      else if types[0] == 'a Mixed'
        verb = 'can'
        types[0] = 'of any type'
      else if types[0] == 'an Array of Mixeds'
        verb = 'can'
        types[0] = 'an Array of any type'
      else if types[0] == 'any number of Mixeds'
        verb = 'can'
        types[0] = 'any number of arguments of any type'

      fragments.push "#{verb} be #{humanize.joinSentence types, 'or'}"
      fragments.push "has a default value of #{value.defaultValue}" if value.defaultValue?

      "#{if value.isSubParam then "    *" else "*"} **#{value.varName} #{humanize.joinSentence fragments}.**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  params:        'param'
  parameters:    'param'

  'return':
    section:     'returns'
    parseValue:  (value) ->
      parts = collapse_space(value).match /^\{([^\}]+)\}\s*(.*)$/
      types:       parts[1].split /\|{1,2}/g
      description: parts[2]
    markdown:     (value) ->
      types = ("#{humanize.article type} #{type}" for type in value.types)
      "**returns #{types.join ' or '}**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  returns:       'return'
  throw:
    section:     'returns'
    parseValue:  (value) ->
      parts = collapse_space(value).match /^\{([^\}]+)\}\s*(.*)$/
      types:       parts[1].split /\|{1,2}/g
      description: parts[2]
    markdown:    (value) ->
      types = ("#{humanize.article type} #{type}" for type in value.types)
      "**can throw #{types.join ' or '}**#{if value.description.length then '<br/>(' else ''}#{value.description}#{if value.description.length then ')' else ''}"
  throws:        'throw'

  defaultNoValue:
    section:     'flag'
  defaultHasValue:
    section:     'metadata'

