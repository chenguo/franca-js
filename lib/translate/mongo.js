(function() {
  var KEYS, _, components;

  _ = require('lodash');

  components = require('../components');

  KEYS = ['query', 'options', 'pipeline', 'collection'];

  module.exports = function(q) {
    var c, translated;
    c = components.toMongo(q);
    translated = _.pick(c, KEYS);
    return translated;
  };

}).call(this);
