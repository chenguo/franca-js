(function() {
  var _, applyOptions, applySortOptions, common, facets, filterData, makeCmpFn, makePredicate, optsCommon, singleCmp;

  _ = require('lodash');

  common = require('../common');

  optsCommon = require('../components/options/common');

  makePredicate = require('./make-predicate');

  facets = require('./facets');

  singleCmp = function(ordering, a, b) {
    var dir, f1, f2, field, sortDir;
    field = ordering[0];
    sortDir = ordering[1];
    f1 = _.get(a, field);
    f2 = _.get(b, field);
    if (f1 < f2) {
      dir = -1;
    } else if (f2 < f1) {
      dir = 1;
    } else {
      dir = 0;
    }
    return dir * sortDir;
  };

  makeCmpFn = function(orderings) {
    return function(a, b) {
      var order;
      order = 0;
      orderings.some(function(o) {
        var dir;
        dir = singleCmp(o, a, b);
        if (dir !== 0) {
          order = dir;
          return true;
        }
      });
      return order;
    };
  };

  applySortOptions = function(rows, options) {
    var formatter, orderings;
    formatter = optsCommon.makeSortValueFormatter(1, -1);
    orderings = optsCommon.getSorts(options, formatter);
    if (orderings != null) {
      rows.sort(makeCmpFn(orderings));
    }
    return rows;
  };

  applyOptions = function(rows, options) {
    var offset;
    rows = applySortOptions(rows, options);
    offset = options.offset || 0;
    if (options.limit) {
      rows = rows.slice(offset, offset + options.limit);
    } else {
      rows = rows.slice(offset);
    }
    return rows;
  };

  filterData = function(rows, query) {
    var filterFn;
    filterFn = makePredicate(query.query);
    return rows.filter(filterFn);
  };

  module.exports = {
    makePredicate: makePredicate,
    query: function(data, query) {
      var filteredData, rows;
      data = _.cloneDeep(data);
      query = common.preprocess(query);
      filteredData = filterData(data, query);
      rows = applyOptions(filteredData, query.options);
      return rows;
    },
    facets: function(data, query) {
      var dataFacets, filteredData;
      query = common.preprocess(query);
      filteredData = filterData(data, query);
      dataFacets = facets.generateFacets(filteredData, query.facet);
      return dataFacets;
    }
  };

}).call(this);
