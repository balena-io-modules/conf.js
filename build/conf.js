var ConfJS, _, fs, path,
  slice = [].slice;

_ = require('lodash-contrib');

fs = require('fs');

path = require('path');

ConfJS = (function() {
  function ConfJS(_options) {
    this._options = _options != null ? _options : {};
    _.defaults(this._options, {
      parse: JSON.parse,
      encoding: 'utf8'
    });
    this._data = this._options["default"] || {};
    this.extendWithFile(this._options.userConfig);
    this.extendWithFile(this._getLocalConfigPath());
  }

  ConfJS.prototype.extendWithFile = function(file) {
    var fileContents;
    if (!fs.existsSync(file)) {
      return;
    }
    fileContents = this._readFile(file);
    return this.extend(fileContents);
  };

  ConfJS.prototype.set = function(key, value) {
    return this._data[key] = value;
  };

  ConfJS.prototype.get = function(key) {
    if (key == null) {
      return this._data;
    }
    return _.getPath(this._data, key);
  };

  ConfJS.prototype.has = function(key) {
    return _.has(this._data, key);
  };

  ConfJS.prototype.extend = function() {
    var objects;
    objects = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    return _.extend.apply(_, [this._data].concat(slice.call(objects)));
  };

  ConfJS.prototype.isEmpty = function() {
    return _.isEmpty(this._data);
  };

  ConfJS.prototype.parse = function(input) {
    return this._options.parse(input);
  };

  ConfJS.prototype._getLocalConfigPath = function() {
    var localConfigFile;
    localConfigFile = this._options.localConfig;
    if (localConfigFile == null) {
      return;
    }
    return path.join(process.cwd(), localConfigFile);
  };

  ConfJS.prototype._readFile = function(file) {
    var fileContents;
    fileContents = fs.readFileSync(file, this._options.encoding);
    return this.parse(fileContents);
  };

  return ConfJS;

})();

module.exports = ConfJS;
