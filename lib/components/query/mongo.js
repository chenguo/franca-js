(function() {
  var BaseQuery, MongoQuery, _,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  BaseQuery = require('./base');

  MongoQuery = (function(superClass) {
    extend(MongoQuery, superClass);

    function MongoQuery() {
      this.buildCompoundImpl = bind(this.buildCompoundImpl, this);
      this.buildRangeMatchImpl = bind(this.buildRangeMatchImpl, this);
      return MongoQuery.__super__.constructor.apply(this, arguments);
    }

    MongoQuery.prototype.buildEmptyImpl = function() {
      return {};
    };

    MongoQuery.prototype.buildMatchImpl = function(q) {
      var fieldQ;
      fieldQ = q.negate ? {
        $ne: q.match
      } : q.match;
      return _.set({}, q.field, fieldQ);
    };

    MongoQuery.prototype.buildMatchInImpl = function(q) {
      var op;
      op = q.negate ? '$nin' : '$in';
      return _.set({}, [q.field, op], q.match);
    };

    MongoQuery.prototype.buildNullMatchImpl = function(q) {
      var cond, field;
      field = q.field;
      cond = [{}, {}];
      if (this.matchNull(q)) {
        cond[0][field] = null;
        cond[1][field] = {
          $exists: false
        };
        return {
          $or: cond
        };
      } else {
        cond[0][field] = {
          $ne: null
        };
        cond[1][field] = {
          $exists: true
        };
        return {
          $and: cond
        };
      }
    };

    MongoQuery.prototype.negateRangeQuery = function(rq) {
      if (rq.$gt != null) {
        return {
          $lte: rq.$gt
        };
      } else if (rq.$gte != null) {
        return {
          $lt: rq.$gte
        };
      } else if (rq.$lt != null) {
        return {
          $gte: rq.$lt
        };
      } else if (rq.$lte != null) {
        return {
          $gt: rq.$lte
        };
      }
      throw new Error('Invalid Mongo range query: ' + JSON.stringify(rq));
    };

    MongoQuery.prototype.generateRangeQueries = function(r) {
      var rangeQueries, rq;
      rangeQueries = [];
      if ((r.gt != null) || (r.gte != null)) {
        if (r.gt != null) {
          rq = {
            $gt: r.gt
          };
        } else {
          rq = {
            $gte: r.gte
          };
        }
        rangeQueries.push(rq);
      }
      if ((r.lt != null) || (r.lte != null)) {
        if (r.lt != null) {
          rq = {
            $lt: r.lt
          };
        } else {
          rq = {
            $lte: r.lte
          };
        }
        rangeQueries.push(rq);
      }
      return rangeQueries;
    };

    MongoQuery.prototype.buildRangeMatchImpl = function(q) {
      var queries, rangeQueries;
      rangeQueries = this.generateRangeQueries(q.range);
      queries = rangeQueries.map((function(_this) {
        return function(rq) {
          if (q.negate) {
            rq = _this.negateRangeQuery(rq);
          }
          return _.set({}, q.field, rq);
        };
      })(this));
      if (queries.length > 1) {
        if (q.negate) {
          return {
            $or: queries
          };
        } else {
          return {
            $and: queries
          };
        }
      } else {
        return queries[0];
      }
    };

    MongoQuery.prototype.buildRegexMatchImpl = function(q) {
      var e, regex, regq;
      try {
        regex = new RegExp(q.regexp, q.regFlags);
      } catch (_error) {
        e = _error;
        throw new Error('Query regex fail: ' + e);
      }
      regq = q.negate ? {
        $not: regex
      } : regex;
      return _.set({}, q.field, regq);
    };

    MongoQuery.prototype.buildRawImpl = function(q) {
      var e, raw, rawQuery;
      rawQuery = q.raw;
      if ('string' === typeof rawQuery) {
        try {
          raw = JSON.parse(rawQuery);
        } catch (_error) {
          e = _error;
          throw new Error('Failed parsing raw query string: ' + e);
        }
      } else if (rawQuery instanceof Object) {
        raw = rawQuery;
      }
      if (raw == null) {
        throw new Error('Raw Mongo query is not a JSON string or Object: ' + rawQuery);
      }
      return raw;
    };

    MongoQuery.prototype.buildCompoundImpl = function(q) {
      var condOp;
      if (q.type === this.TYPES.AND) {
        condOp = '$and';
      } else {
        condOp = '$or';
      }
      return _.set({}, condOp, q.queries.map((function(_this) {
        return function(query) {
          return _this.buildQuery(query);
        };
      })(this)));
    };

    return MongoQuery;

  })(BaseQuery);

  module.exports = (new MongoQuery).convertQuery;

}).call(this);
