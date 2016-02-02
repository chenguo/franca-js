(function() {
  var BaseQuery, SolrQuery,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseQuery = require('./base');

  SolrQuery = (function(superClass) {
    extend(SolrQuery, superClass);

    function SolrQuery() {
      this.translateRegex = bind(this.translateRegex, this);
      this.buildRangeMatchImpl = bind(this.buildRangeMatchImpl, this);
      this.buildNullMatch = bind(this.buildNullMatch, this);
      this.buildMatchInImpl = bind(this.buildMatchInImpl, this);
      this.buildMatchImpl = bind(this.buildMatchImpl, this);
      this.toNative = bind(this.toNative, this);
      return SolrQuery.__super__.constructor.apply(this, arguments);
    }

    SolrQuery.prototype.toNative = function(query) {
      var solrQuery;
      query = this.objectify(query);
      solrQuery = this.buildQuery(query);
      return solrQuery;
    };

    SolrQuery.prototype.negateQuery = function(qstr) {
      qstr = '(*:* NOT ' + qstr + ')';
      return qstr;
    };

    SolrQuery.prototype.buildEmptyImpl = function() {
      return '*:*';
    };

    SolrQuery.prototype.buildMatchImpl = function(q) {
      var qstr;
      qstr = q.field + ':"' + q.match + '"';
      if (q.negate) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.buildMatchInImpl = function(q) {
      var qstr, vals;
      vals = q.match.map(function(v) {
        return '"' + v + '"';
      });
      qstr = q.field + ':(' + vals.join(' OR ') + ')';
      if (q.negate) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.buildNullMatch = function(q) {
      var qstr;
      qstr = q.field + ':[* TO *]';
      if (this.matchNull(q)) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.buildRangeMatchImpl = function(q) {
      var conds, gte, lte, qstr, rangeStr;
      lte = q.range.lte || q.range.lt || '*';
      gte = q.range.gte || q.range.gt || '*';
      rangeStr = "[" + gte + " TO " + lte + "]";
      if ((q.range.lt != null) || (q.range.gt != null)) {
        conds = [rangeStr];
        if (q.range.gt != null) {
          conds.push('NOT ' + q.range.gt);
        }
        if (q.range.lt != null) {
          conds.push('NOT ' + q.range.lt);
        }
        rangeStr = '(' + conds.join(' ') + ')';
      }
      qstr = q.field + ":" + rangeStr;
      if (q.negate) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.translateAnchors = function(regStr) {
      var noEndWildcard, noStartWildcard;
      if (/^\/\^/.test(regStr)) {
        noStartWildcard = true;
        regStr = regStr.replace(/^\/\^/, '/');
      }
      if (/\$\/$/.test(regStr)) {
        noEndWildcard = true;
        regStr = regStr.replace(/\$\/$/, '/');
      }
      if (!(noStartWildcard || /^\/\.\*/.test(regStr))) {
        regStr = regStr.replace(/^\//, "/.*");
      }
      if (!(noEndWildcard || /\.\*\$/.test(regStr))) {
        regStr = regStr.replace(/\/$/, ".*/");
      }
      return regStr;
    };

    SolrQuery.prototype.translateCharacterClasses = function(regStr) {
      regStr = regStr.replace(/\\d/, '[0-9]');
      regStr = regStr.replace(/\\D/, '[^0-9]');
      regStr = regStr.replace(/\\w/, '[A-Za-z0-9_]');
      regStr = regStr.replace(/\\W/, '[^A-Za-z0-9_]');
      return regStr;
    };

    SolrQuery.prototype.translateRegex = function(regStr) {
      regStr = this.translateAnchors(regStr);
      regStr = this.translateCharacterClasses(regStr);
      return regStr;
    };

    SolrQuery.prototype.buildRegexMatchImpl = function(q) {
      var qstr, regStr;
      regStr = this.getRegexStr(q.regexp);
      qstr = q.field + ':' + this.translateRegex(regStr);
      if (q.negate) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.buildCompoundImpl = function(q) {
      var condOp, conds, qstr;
      if (q.type === this.TYPES.AND) {
        condOp = 'AND';
      } else {
        condOp = 'OR';
      }
      conds = q.queries.map((function(_this) {
        return function(query) {
          return _this.buildQuery(query);
        };
      })(this));
      qstr = '(' + conds.join(" " + condOp + " ") + ')';
      if (q.negate) {
        qstr = this.negateQuery(qstr);
      }
      return qstr;
    };

    SolrQuery.prototype.buildRawImpl = function(q) {
      var rawQuery;
      rawQuery = q.raw;
      if ('string' === !typeof rawQuery) {
        throw new Error('Raw Solr query is not a string: ' + rawQuery);
      }
      return rawQuery;
    };

    return SolrQuery;

  })(BaseQuery);

  module.exports = (new SolrQuery).convertQuery;

}).call(this);
