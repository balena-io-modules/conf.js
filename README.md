conf.js
========

[![npm version](https://badge.fury.io/js/conf.js.svg)](http://badge.fury.io/js/conf.js)

conf.js allows you to get per-user and per-project configuration files out of the box.

Look how easy it is to use:

```sh
# settings.coffee
path = require('path')
ConfJS = require('conf.js')

module.exports = new ConfJS
	keys:
		userConfig: 'configurationFiles.user'
		localConfig: 'configurationFiles.project'
	default:
		configurationFiles:
			user: path.join(process.env.HOME, '.myprojectrc.json')
			project: '.myprojectrc.json'

		# Your usual application settings
		port: '9999'
		name: 'My cool app!'
		...
```

Now if `$HOME/.myprojecrc` exists, it's settings will override the defaults.

If then create a `.myprojecrc` file inside one of your projects directory and run the application from within that directory, the contents will override `$HOME/.myprojecrc` and defaults.

Notice that you can set a custom local configuration file within your user configuration and it'll be correctly used.

You can now `get`/`set` your settings with:

```sh
settings = require('./settings')
settings.get('port') # 9999
settings.set('name', 'My really cool app!')
```

Features
--------

- Per-user configuration file:

Specify `keys.userConfig` to the defaults key that contains the user configuration file path.

- Per-project configuration files:

Specify `keys.localConfig` to the defaults key that contains the local configuration file path.

Installation
------------

Install conf.js by running:

```sh
$ npm install --save conf.js
```

Methods
-------

### constructor(options)

Create an instance of settings.

The following options are accepted:

- `configFileParse`: The function used to parse inputs (defaults to `JSON.parse`).
- `encoding`: The encoding to be used when reading files (defaults to `utf8`).
- `default`: Default settings.
- `keys`: Provide semantic meaning to settings values, so `conf.js` can interpret them accordingly.

### settings.extendWithFile(file)

Extend setting with the contents of a file.

### settings.set(key, value)

Set runtime value of a setting, or create a new one.

Notice you can set nested keys:

```coffee
settings.set('my.nested.key', 'value')
```

### settings.get(key)

Get the value of a setting.

Notice you can get nested keys:

```coffee
settings.get('my.nested.key')
```

### settings.has(key)

Check if settings has a specific key.

### settings.extend(objects...)

Extend settings with object/s.

### settings.isEmpty()

Check if settings object is empty.

### settings.parse(input)

Parse input given a function passed to `options.configFileParse`.

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/conf.js/issues](https://github.com/resin-io/conf.js/issues)
- Source Code: [github.com/resin-io/conf.js](https://github.com/resin-io/conf.js)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you are having any problem, please [raise an issue](https://github.com/resin-io/conf.js/issues).

TODO
-------

- Allow to set a custom configuration file with a command line option.

License
-------

The project is licensed under the MIT license.
