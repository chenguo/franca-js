(function() {
  var TYPES, _, checkNegate, common, evaluateAndQuery, evaluateBasicQuery, evaluateMatchQuery, evaluateNullQuery, evaluateOrQuery, evaluateQuery, evaluateRangeQuery, evaluateRegexpQuery, evaluteFullTextQuery;

  _ = require('lodash');

  common = require('../common');

  TYPES = common.TYPES;

  checkNegate = function(match, query) {
    if (query.negate) {
      match = !match;
    }
    return match;
  };

  evaluateQuery = function(row, query) {
    var match;
    match = (function() {
      switch (query.type) {
        case TYPES.AND:
          return evaluateAndQuery(row, query);
        case TYPES.OR:
          return evaluateOrQuery(row, query);
        default:
          return evaluateBasicQuery(row, query);
      }
    })();
    return match;
  };

  evaluateAndQuery = function(row, query) {
    var match, queries;
    queries = query.queries || [];
    match = queries.every(function(q) {
      return evaluateQuery(row, q);
    });
    match = checkNegate(match, query);
    return match;
  };

  evaluateOrQuery = function(row, query) {
    var match, queries;
    queries = query.queries || [];
    match = queries.some(function(q) {
      return evaluateQuery(row, q);
    });
    match = checkNegate(match, query);
    return match;
  };

  evaluateBasicQuery = function(row, query) {
    var match;
    if (query.field != null) {
      if (query.range != null) {
        return evaluateRangeQuery(row, query);
      } else {
        if (query.match != null) {
          match = evaluateMatchQuery(row, query);
        } else if (query["null"] != null) {
          match = evaluateNullQuery(row, query);
        } else if (query.regexp != null) {
          match = evaluateRegexpQuery(row, query);
        }
        match = checkNegate(match, query);
        return match;
      }
    } else if (query.text != null) {
      return evaluateFullTextQuery(row, query);
    }
    return true;
  };

  evaluateMatchQuery = function(row, query) {
    var value;
    value = row[query.field];
    if (query.match instanceof Array) {
      return query.match.some(function(match) {
        return value === match;
      });
    } else {
      return value === query.match;
    }
  };

  evaluateNullQuery = function(row, query) {
    var isNull;
    isNull = row[query.field] == null;
    if (query["null"]) {
      return isNull;
    } else {
      return !isNull;
    }
  };

  evaluateRangeQuery = function(row, query) {
    var failRangeCheck, match, range, value;
    range = query.range || {};
    value = row[query.field];
    if (value == null) {
      return false;
    }
    failRangeCheck = ((range.lt != null) && value >= range.lt) || ((range.lte != null) && value > range.lte) || ((range.gt != null) && value <= range.gt) || ((range.gte != null) && value < range.gte);
    match = checkNegate(!failRangeCheck, query);
    return match;
  };

  evaluateRegexpQuery = function(row, query) {
    var pattern, value;
    pattern = new RegExp(query.regexp, query.regFlags);
    value = row[query.field];
    return pattern.test(value);
  };

  evaluteFullTextQuery = function(row, query) {
    throw new Error('Fulltext query not yet supported');
  };

  module.exports = function(query) {
    return function(row) {
      if (query.query != null) {
        query = query.query;
      }
      return evaluateQuery(row, query);
    };
  };

}).call(this);
