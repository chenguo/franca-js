(function() {
  var _, getSorts;

  _ = require('lodash');

  getSorts = function(opts, formatter) {
    var msg, orderings;
    if (opts == null) {
      opts = {};
    }
    if (opts.sort != null) {
      if (opts.sort instanceof Array) {
        orderings = opts.sort.map(function(s) {
          return [s[0], formatter(s[1])];
        });
      } else if (opts.sort instanceof Object) {
        orderings = _.map(opts.sort, function(v, k) {
          return [k, formatter(v)];
        });
      } else {
        if (typeof opts.sort !== 'string') {
          msg = JSON.stringify(opts.sort);
        } else {
          msg = opts.sort;
        }
        throw new Error('Invalid sort option format: ' + msg);
      }
      return orderings;
    }
  };

  module.exports = {
    getSorts: getSorts,
    makeSortValueFormatter: function(ascVal, descVal) {
      return function(v) {
        if (typeof v === 'string') {
          v = v.toLowerCase();
        }
        v = (function() {
          switch (v) {
            case 1:
            case '1':
            case 'asc':
            case 'ascending':
              return ascVal;
            case -1:
            case '-1':
            case 'desc':
            case 'descending':
              return descVal;
            default:
              throw new Error('Invalid field sort direction: ' + v);
          }
        })();
        return v;
      };
    }
  };

}).call(this);
