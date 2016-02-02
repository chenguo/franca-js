(function() {
  var COUNT, DEFAULT_SORT, VALUE, common, parseSortBy, parseSortDir;

  common = require('../../common');

  COUNT = 'count';

  VALUE = 'value';

  DEFAULT_SORT = {
    count: -1,
    value: 1
  };

  parseSortDir = common.makeSortValueFormatter(1, -1);

  parseSortBy = (function(_this) {
    return function(sortBy) {
      sortBy = sortBy.toLowerCase();
      if (sortBy === COUNT || sortBy === VALUE) {
        return sortBy;
      } else {
        throw new Error('Facet sort field must be "count" or "value": ' + sortBy);
      }
    };
  })(this);

  module.exports = {
    COUNT: 'count',
    VALUE: 'value',
    parseSortDir: parseSortDir,
    formatSortOpts: function(sortOpts) {
      var s, sortBy, sortDir;
      switch (false) {
        case typeof sortOpts !== 'number':
          sortDir = parseSortDir(sortOpts);
          break;
        case typeof sortOpts !== 'string':
          if (common.isAscVal(sortOpts)) {
            sortDir = 1;
          } else if (common.isDescVal(sortOpts)) {
            sortDir = -1;
          } else {
            sortBy = parseSortBy(sortOpts);
          }
          break;
        case !(sortOpts instanceof Object):
          if (COUNT in sortOpts) {
            sortBy = COUNT;
            sortDir = parseSortDir(sortOpts[COUNT]);
          } else if (this.VALUE in sortOpts) {
            sortBy = VALUE;
            sortDir = parseSortDir(sortOpts[VALUE]);
          } else {
            s = JSON.stringify(sortOpts);
            throw new Error('Invalid focet sort specification: ' + s);
          }
      }
      if (sortBy == null) {
        sortBy = COUNT;
      }
      if (sortDir == null) {
        sortDir = DEFAULT_SORT[sortBy];
      }
      return {
        dir: sortDir,
        sortBy: sortBy
      };
    }
  };

}).call(this);
