_ = require('lodash-contrib')
fs = require('fs')
path = require('path')

class ConfJS
	constructor: (@_options = {}) ->
		_.defaults @_options,
			parse: JSON.parse
			encoding: 'utf8'

		@_data = @_options.default or {}

		# Ordering is important here. We give precendece
		# to local config over user config and defaults.
		@extendWithFile(@_options.userConfig)
		@extendWithFile(@_getLocalConfigPath())

	extendWithFile: (file) ->
		return if not fs.existsSync(file)
		fileContents = @_readFile(file)
		@extend(fileContents)

	set: (key, value) ->
		@_data[key] = value

	get: (key) ->
		return if not key?
		return _.getPath(@_data, key)

	has: (key) ->
		return _.has(@_data, key)

	extend: (objects...) ->
		return _.extend(@_data, objects...)

	isEmpty: ->
		return _.isEmpty(@_data)

	parse: (input) ->
		return @_options.parse(input)

	# Private functions

	_getLocalConfigPath: ->
		localConfigFile = @_options.localConfig
		return if not localConfigFile?
		return path.join(process.cwd(), localConfigFile)

	_readFile: (file) ->
		fileContents = fs.readFileSync(file, @_options.encoding)
		return @parse(fileContents)

module.exports = ConfJS
