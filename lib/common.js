(function() {
  var canonicalizeOpts, canonicalizeQuery, ensureNumericValue, isAscVal, isDescVal;

  ensureNumericValue = function(obj, field) {
    var val;
    if (obj[field] != null) {
      val = parseInt(obj[field]);
      if (isNaN(val)) {
        delete obj[field];
      } else {
        obj[field] = val;
      }
    }
    return obj;
  };

  canonicalizeOpts = function(q) {
    var opts;
    opts = q.options || {};
    if (q.table != null) {
      opts.table = q.table;
    }
    if (opts.columns != null) {
      opts.fields = opts.columns;
      delete opts.columns;
    }
    opts = ensureNumericValue(opts, 'limit');
    opts = ensureNumericValue(opts, 'offset');
    return opts;
  };

  canonicalizeQuery = function(q) {
    var query;
    return query = (function() {
      switch (false) {
        case q.query == null:
          return q.query;
        case q.filter == null:
          return q.filter;
        case !(q.facet == null):
          return q;
        default:
          return {};
      }
    })();
  };

  isAscVal = function(v) {
    switch (v) {
      case 1:
      case '1':
      case 'asc':
      case 'ascending':
        return true;
      default:
        return false;
    }
  };

  isDescVal = function(v) {
    switch (v) {
      case -1:
      case '-1':
      case 'desc':
      case 'descending':
        return true;
      default:
        return false;
    }
  };

  module.exports = {
    TYPES: {
      Q: 'Q',
      AND: 'AND',
      OR: 'OR',
      RAW: 'RAW'
    },
    preprocess: function(q) {
      var processed;
      processed = {
        query: canonicalizeQuery(q),
        options: canonicalizeOpts(q),
        facet: q.facet
      };
      return processed;
    },
    isAscVal: isAscVal,
    isDescVal: isDescVal,
    makeSortValueFormatter: function(ascVal, descVal) {
      return function(v) {
        if (typeof v === 'string') {
          v = v.toLowerCase();
        }
        v = (function() {
          switch (false) {
            case !isAscVal(v):
              return ascVal;
            case !isDescVal(v):
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
