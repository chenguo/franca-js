(function() {
  var BaseQuery, common,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  common = require('../../common');

  BaseQuery = (function() {
    function BaseQuery() {
      this.convertQuery = bind(this.convertQuery, this);
    }

    BaseQuery.prototype.TYPES = common.TYPES;

    BaseQuery.prototype.convertQuery = function(query) {
      var converted;
      query = this.objectify(query);
      converted = this.buildQuery(query);
      return converted;
    };

    BaseQuery.prototype.objectify = function(input) {
      var e, q;
      if ('string' === typeof input) {
        try {
          q = JSON.parse(input);
        } catch (_error) {
          e = _error;
          throw new Error('Failed to parse string query: ' + e);
        }
      } else if (input instanceof Object) {
        q = input;
      } else {
        throw new Error('Malformed input query: ' + input);
      }
      return q;
    };

    BaseQuery.prototype.buildQuery = function(q) {
      var query;
      switch (q.type) {
        case this.TYPES.RAW:
          query = this.buildRaw(q);
          break;
        case this.TYPES.AND:
        case this.TYPES.OR:
          query = this.buildCompound(q);
          break;
        default:
          query = this.buildSingle(q);
      }
      return query;
    };

    BaseQuery.prototype.buildSingle = function(q) {
      var query;
      if (q.field != null) {
        if (q.match != null) {
          query = this.buildMatch(q);
        } else if (q["null"] != null) {
          query = this.buildNullMatch(q);
        } else if (q.range != null) {
          query = this.buildRangeMatch(q);
        } else if (q.regexp != null) {
          query = this.buildRegexMatch(q);
        }
      } else if (q.text != null) {
        query = this.buildFullTextSearch(q);
      } else {
        query = this.buildEmpty(q);
      }
      if (query != null) {
        return query;
      } else {
        return {};
      }
    };

    BaseQuery.prototype.notImplemented = function() {
      throw new Error('not implemented');
    };

    BaseQuery.prototype.buildRaw = function(q) {
      if (q.raw == null) {
        throw new Error("No query given for raw query passthrough: " + q);
      }
      return this.buildRawImpl(q);
    };

    BaseQuery.prototype.buildMatch = function(q) {
      if (q.match instanceof Array && q.match.length === 1) {
        q.match = q.match[0];
      }
      if (q.match instanceof Array) {
        return this.buildMatchInImpl(q);
      } else {
        return this.buildMatchImpl(q);
      }
    };

    BaseQuery.prototype.buildNullMatch = function(q) {
      return this.buildNullMatchImpl(q);
    };

    BaseQuery.prototype.matchNull = function(q) {
      return !q["null"] !== !q.negate;
    };

    BaseQuery.prototype.buildRangeMatch = function(q) {
      if ((!(q.range instanceof Object)) || !((q.range.lt != null) || (q.range.lte != null) || (q.range.gt != null) || (q.range.gte != null))) {
        throw new Error("Range query must contain min or max: " + q);
      }
      return this.buildRangeMatchImpl(q);
    };

    BaseQuery.prototype.buildRegexMatch = function(q) {
      if (!(q.regexp instanceof RegExp || typeof q.regexp === 'string')) {
        throw new Error('Invalid regular expression query: ' + q.regexp);
      }
      return this.buildRegexMatchImpl(q);
    };

    BaseQuery.prototype.getRegexStr = function(reg) {
      if (reg instanceof RegExp) {
        reg = reg.toString();
      } else {
        if (reg[0] !== '/') {
          reg = '/' + reg;
        }
        if (reg[reg.length - 1] !== '/') {
          reg = reg + '/';
        }
      }
      return reg;
    };

    BaseQuery.prototype.buildFullTextSearch = BaseQuery.prototype.notImplemented;

    BaseQuery.prototype.buildCompound = function(q) {
      if (!(q.queries instanceof Array)) {
        throw new Error('Compound query not specified as an array');
      }
      if (q.negate) {
        q.type = q.type === this.TYPES.AND ? this.TYPES.OR : this.TYPES.AND;
        q.queries = q.queries.map(function(subq) {
          subq.negate = !subq.negate;
          return subq;
        });
        q.negate = false;
      }
      return this.buildCompoundImpl(q);
    };

    BaseQuery.prototype.buildEmpty = function(q) {
      if (q.negate) {
        throw new Error('Cannot negate empty query');
      }
      return this.buildEmptyImpl(q);
    };

    return BaseQuery;

  })();

  module.exports = BaseQuery;

}).call(this);
