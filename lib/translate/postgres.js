(function() {
  var CLAUSES, combineComponents, components;

  components = require('../components');

  CLAUSES = ['SELECT', 'FROM', 'WHERE', 'GROUP BY', 'ORDER BY', 'LIMIT', 'OFFSET'];

  combineComponents = function(components) {
    var pgQuery;
    if (components.SELECT == null) {
      components.SELECT = '*';
    }
    pgQuery = CLAUSES.reduce(function(str, c) {
      var val;
      val = components[c];
      if ((val != null) && val !== '') {
        if (str !== '') {
          str += ' ';
        }
        str += c + " " + val;
      }
      return str;
    }, '');
    return pgQuery;
  };

  module.exports = function(q) {
    var translated;
    translated = combineComponents(components.toPg(q));
    return translated;
  };

}).call(this);
