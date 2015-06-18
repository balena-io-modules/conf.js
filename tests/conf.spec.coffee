_ = require('lodash-contrib')
path = require('path')
sinon = require('sinon')
chai = require('chai')
expect = chai.expect
mockFs = require('mock-fs')

ConfJS = require('../lib/conf')

mockfsInit = (filesystemConfig = {}) ->
	mockFsOptions = {}
	for key, value of filesystemConfig
		mockFsOptions[value.name] = value.contents
	mockFs(mockFsOptions)

describe 'ConfJS:', ->

	describe 'given an empty conf', ->

		beforeEach ->
			@conf = new ConfJS()

		describe '#set()', ->

			it 'should be able to set values', ->
				key = 'foo'
				value = 'bar'
				expect(@conf.get(key)).to.not.exist
				@conf.set(key, value)
				expect(@conf.get(key)).to.exist

		describe '#get()', ->

			it 'should be able to get values', ->
				key = 'foo'
				value = 'bar'
				@conf.set(key, value)
				expect(@conf.get(key)).to.equal(value)

			it 'should be able to get nested values', ->
				@conf._data.nested =
					value: 'ok'

				expect(@conf.get('nested.value')).to.equal('ok')

			it 'should return undefined if not nested value', ->
				expect(@conf.get('unexistent.nested.value')).to.be.undefined

			it 'should return undefined if value does not exist', ->
				expect(@conf.get('unknownKey')).to.be.undefined

			it 'should return all keys if no key', ->
				@conf._data =
					foo: 'bar'
					baz:
						quz: 'hey'

				expect(@conf.get()).to.deep.equal
					foo: 'bar'
					baz:
						quz: 'hey'

		describe '#has()', ->

			it 'should return check if data has key', ->
				key = 'foo'
				value = 'bar'

				expect(@conf.has(key)).to.be.false
				@conf.set(key, value)
				expect(@conf.has(key)).to.be.true

		describe '#extendWithFile()', ->

			filesystem =
				userConfig:
					name: '/userConfig'
					contents: JSON.stringify
						remoteUrl: 'https://google.com'
				notJSONUserConfig:
					name: '/notJSONUserConfig'
					contents: 'Just a plain file'

			beforeEach ->
				mockfsInit(filesystem)

			afterEach ->
				mockFs.restore()

			describe 'if no file is passed', ->

				it 'should return undefined', ->
					expect(@conf.extendWithFile()).to.be.undefined

				it 'should keep the content unmodified', ->
					data = _.cloneDeep(@conf._data)
					@conf.extendWithFile()
					expect(@conf._data).to.deep.equal(data)

			describe 'if file does not exist', ->

				it 'should return undefined', ->
					expect(@conf.extendWithFile('/unexistent_file')).to.be.undefined

				it 'should keep the content unmodified', ->
					data = _.cloneDeep(@conf._data)
					@conf.extendWithFile('/unexistent_file')
					expect(@conf._data).to.deep.equal(data)

			it 'should throw an error if file is not a json file', ->
				func = _.partial(@conf.extendWithFile, filesystem.notJSONUserConfig.name)
				expect(func).to.throw(Error)

			it 'should extend data with a file', ->
				expect(@conf.isEmpty()).to.be.true
				@conf.extendWithFile(filesystem.userConfig.name)
				expectedContent = JSON.parse(filesystem.userConfig.contents)
				expect(@conf._data).to.deep.equal(expectedContent)

		describe '#isEmpty()', ->

			it 'should return true', ->
				expect(@conf.isEmpty()).to.be.true

	describe 'given a conf with default values', ->

		object =
			one: 'first'
			two: 'second'

		beforeEach ->
			@conf = new ConfJS(default: object)

		it 'should have the data', ->
			expect(@conf._data).to.deep.equal(object)

		describe '#isEmpty()', ->

			it 'should return false', ->
				expect(@conf.isEmpty()).to.be.false

	describe '#extend()', ->

		beforeEach ->
			@conf = new ConfJS
				default:
					greeting: 'Hi'

		it 'should override data values', ->
			object =
				greeting: 'Hola'
				name: 'John Doe'

			@conf.extend(object)
			expect(@conf._data).to.deep.equal(object)

		it 'should handle multiple overrides', ->
			@conf.extend {
				greeting: 'Hola'
				name: 'John Doe'
			}, {
				greeting: 'Pronto'
			}

			expect(@conf._data).to.deep.equal
				greeting: 'Pronto'
				name: 'John Doe'

	describe 'given a supplied user config default', ->

		beforeEach ->

			@options =
				userConfig: '/Users/johndoe/.conf/config'
				default:
					remoteUrl: 'https://google.com'

			@filesystem =
				userConfig:
					name: @options.userConfig
					contents: JSON.stringify
						remoteUrl: 'https://yahoo.com'

		it 'should load that file and extend _data', ->
			mockfsInit(@filesystem)
			conf = new ConfJS(@options)
			parsedUserConfig = JSON.parse(@filesystem.userConfig.contents)
			expectedResult = _.extend(_.cloneDeep(@options.default), parsedUserConfig)
			expect(conf._data).to.deep.equal(expectedResult)
			expect(conf._data.remoteUrl).to.equal('https://yahoo.com')
			expect(conf._options.default.remoteUrl).to.equal('https://google.com')
			mockFs.restore()

	describe 'given a supplied user and local config', ->

		options =
			userConfig: '/Users/johndoe/.conf/config'
			localConfig: '.localconf'
			default:
				remoteUrl: 'https://google.com'

		filesystem =
			localConfig:
				name: path.join(process.cwd(), options.localConfig)
				contents: JSON.stringify
					remoteUrl: 'https://facebook.com'
			userConfig:
				name: options.userConfig
				contents: JSON.stringify
					remoteUrl: 'https://apple.com'

		beforeEach ->
			mockfsInit(filesystem)
			@conf = new ConfJS(options)

		afterEach ->
			mockFs.restore()

		it 'local config should have precedence', ->
			parsedUserConfig = JSON.parse(filesystem.userConfig.contents)
			parsedLocalConfig = JSON.parse(filesystem.localConfig.contents)
			defaultsCopy = _.cloneDeep(options.default)

			expectedResult = _.extend(defaultsCopy, parsedUserConfig, parsedLocalConfig)
			expect(@conf._data).to.deep.equal(expectedResult)

	describe '#parse()', ->

		beforeEach ->
			@conf = new ConfJS()

		it 'should use parse JSON by default', ->
			input = '{ "hello": 123 }'
			result = @conf.parse(input)
			parsedInput = JSON.parse(input)
			expect(result).to.deep.equal(parsedInput)

		it 'should be able to replace parse function with options', ->
			parseFunction = _.identity
			@conf = new ConfJS(parse: parseFunction)

			expect(@conf._options.parse).to.equal(parseFunction)
			input = 'Hello'
			result = @conf.parse(input)
			expect(result).to.equal(input)

	describe '#_getLocalConfigPath()', ->

		it 'should contruct the path correctly', ->
			filename = 'localconfig'
			@conf = new ConfJS
				localConfig: filename

			expectedPath = path.join(process.cwd(), filename)
			expect(@conf._getLocalConfigPath()).to.equal(expectedPath)

		it 'should return undefined if no local path', ->
			@conf = new ConfJS()
			expect(@conf._getLocalConfigPath()).to.be.undefined
