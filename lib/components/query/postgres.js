(function() {
  var BaseQuery, PostgresQuery, _,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  BaseQuery = require('./base');

  PostgresQuery = (function(superClass) {
    var AND, BETWEEN, EQ, IN, IS, NOT, NOT_BETWEEN, NOT_EQ, NOT_IN, NOT_IS, NOT_REG, NULL, OR, REG;

    extend(PostgresQuery, superClass);

    function PostgresQuery() {
      return PostgresQuery.__super__.constructor.apply(this, arguments);
    }

    AND = 'AND';

    OR = 'OR';

    BETWEEN = 'BETWEEN';

    EQ = '=';

    IN = 'IN';

    IS = 'IS';

    NOT_BETWEEN = 'NOT BETWEEN';

    NOT_EQ = '!=';

    NOT_IN = 'NOT IN';

    NOT_IS = 'IS NOT';

    NOT_REG = '!~';

    NOT = 'NOT';

    NULL = 'NULL';

    REG = '~';

    PostgresQuery.prototype.tokenStr = function() {
      return Array.prototype.join.call(arguments, ' ');
    };

    PostgresQuery.prototype.cond = function(field, op, val) {
      return this.tokenStr(field, op, val);
    };

    PostgresQuery.prototype.formatVal = function(val) {
      if (typeof val === 'string') {
        val = val.replace("'", "''");
        return "'" + val + "'";
      } else {
        return val;
      }
    };

    PostgresQuery.prototype.buildEmptyImpl = function() {
      return '';
    };

    PostgresQuery.prototype.buildMatchImpl = function(q) {
      var op, qstr, val;
      if (q.negate) {
        op = '!=';
      } else {
        op = '=';
      }
      val = this.formatVal(q.match);
      qstr = this.cond(q.field, op, val);
      return qstr;
    };

    PostgresQuery.prototype.buildMatchInImpl = function(q) {
      var op, qstr, vals;
      op = q.negate ? NOT_IN : IN;
      vals = q.match.map(this.formatVal).join(', ');
      qstr = this.cond(q.field, op, "(" + vals + ")");
      return qstr;
    };

    PostgresQuery.prototype.buildNullMatchImpl = function(q) {
      var op, qstr;
      op = this.matchNull(q) ? IS : NOT_IS;
      qstr = this.cond(q.field, op, NULL);
      return qstr;
    };

    PostgresQuery.prototype.buildBetween = function(q) {
      var op, qstr, r, val;
      op = q.negate ? NOT_BETWEEN : BETWEEN;
      r = q.range;
      val = this.tokenStr(this.formatVal(r.gte), AND, this.formatVal(r.lte));
      qstr = this.cond(q.field, op, val);
      return qstr;
    };

    PostgresQuery.prototype.rangeConds = function(r) {
      var conds;
      conds = [];
      if (r.gt != null) {
        conds.push(['>', r.gt]);
      } else if (r.gte != null) {
        conds.push(['>=', r.gte]);
      }
      if (r.lt != null) {
        conds.push(['<', r.lt]);
      } else if (r.lte != null) {
        conds.push(['<=', r.lte]);
      }
      return conds;
    };

    PostgresQuery.prototype.negateRangeConds = function(condPair) {
      var newOp, op, val;
      op = condPair[0];
      val = condPair[1];
      newOp = (function() {
        switch (op) {
          case '<':
            return '>=';
          case '<=':
            return '>';
          case '>':
            return '<=';
          case '>=':
            return '<';
          default:
            throw new Error('Invalid range operator: ' + op);
        }
      })();
      return [newOp, val];
    };

    PostgresQuery.prototype.rangeCondNegater = function(neg) {
      if (neg) {
        return this.negateRangeConds;
      } else {
        return function(x) {
          return x;
        };
      }
    };

    PostgresQuery.prototype.rangeStrFormatter = function(field, negate, conds) {
      var condStrs, op, qstr;
      condStrs = conds.map((function(_this) {
        return function(condPair) {
          return _this.tokenStr(field, condPair[0], condPair[1]);
        };
      })(this));
      if (condStrs.length > 1) {
        op = negate ? OR : AND;
        qstr = condStrs.join(" " + op + " ");
      } else {
        qstr = condStrs[0];
      }
      return qstr;
    };

    PostgresQuery.prototype.buildRangeMatchImpl = function(q) {
      var conds, qstr, range;
      range = q.range;
      if ((range.lte != null) && (range.gte != null)) {
        qstr = this.buildBetween(q);
      } else {
        conds = this.rangeConds(range).map(this.rangeCondNegater(q.negate));
        qstr = this.rangeStrFormatter(q.field, q.negate, conds);
      }
      return qstr;
    };

    PostgresQuery.prototype.formatRegStr = function(regStr) {
      regStr = regStr.replace(/^\/|\/$/g, '');
      regStr = "'" + regStr + "'";
      return regStr;
    };

    PostgresQuery.prototype.translateRegex = function(regStr) {
      regStr = this.formatRegStr(regStr);
      return regStr;
    };

    PostgresQuery.prototype.buildRegexMatchImpl = function(q) {
      var op, qstr, regStr;
      regStr = this.getRegexStr(q.regexp);
      op = q.negate ? NOT_REG : REG;
      if ((q.regFlags != null) && /i/.test(q.regFlags)) {
        op += '*';
      }
      qstr = this.tokenStr(q.field, op, this.translateRegex(regStr));
      return qstr;
    };

    PostgresQuery.prototype.buildCompoundImpl = function(q) {
      var condOp, conds, qstr;
      if (q.type === this.TYPES.AND) {
        condOp = AND;
      } else {
        condOp = OR;
      }
      conds = q.queries.map((function(_this) {
        return function(query) {
          return _this.buildQuery(query);
        };
      })(this));
      qstr = '(' + conds.join(" " + condOp + " ") + ')';
      return qstr;
    };

    PostgresQuery.prototype.buildRawImpl = function(q) {
      var rawQuery;
      rawQuery = q.raw;
      if ('string' === !typeof rawQuery) {
        throw new Error('Raw Solr query is not a string: ' + rawQuery);
      }
      return rawQuery;
    };

    return PostgresQuery;

  })(BaseQuery);

  module.exports = (new PostgresQuery).convertQuery;

}).call(this);
