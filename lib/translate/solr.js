(function() {
  var Qs, _, combineComponents, components;

  _ = require('lodash');

  Qs = require('qs');

  components = require('../components');

  combineComponents = function(components, encode) {
    var qStr;
    qStr = Qs.stringify(components, {
      encode: encode
    });
    return qStr;
  };

  module.exports = function(q, encode) {
    var c, translated;
    if (encode == null) {
      encode = false;
    }
    c = components.toSolr(q);
    translated = combineComponents(c, encode);
    return translated;
  };

}).call(this);
