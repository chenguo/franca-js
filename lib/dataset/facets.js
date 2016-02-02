(function() {
  var Set, arrayifyFacets, facetCommon, getFacetValues, sortFacetValues;

  Set = require('es6-set');

  facetCommon = require('../components/facet/common');

  getFacetValues = function(data, field) {
    var facets;
    facets = [];
    data.forEach(function(row) {
      var found, val;
      val = row[field];
      found = facets.some(function(f) {
        if (f.value === val) {
          f.count += 1;
          return true;
        }
      });
      if (!found) {
        return facets.push({
          value: val,
          count: 1
        });
      }
    });
    return facets;
  };

  arrayifyFacets = function(facets) {
    return Object.keys(facets).map(function(val) {
      return {
        value: val,
        count: facets[val]
      };
    });
  };

  sortFacetValues = function(facets, sortOpts) {
    var valFn;
    if (sortOpts.sortBy === facetCommon.VALUE) {
      valFn = function(facet) {
        return facet.value;
      };
    } else {
      valFn = function(facet) {
        return facet.count;
      };
    }
    facets = facets.sort(function(a, b) {
      var cmpVal, valA, valB;
      valA = valFn(a);
      valB = valFn(b);
      cmpVal = (function() {
        switch (false) {
          case !(valA < valB):
            return -1;
          case !(valB < valA):
            return 1;
          default:
            return 0;
        }
      })();
      return cmpVal * sortOpts.dir;
    });
    return facets;
  };

  module.exports = {
    generateFacets: function(data, facetOpts) {
      var facetValues, facets, sortOpts;
      if (facetOpts == null) {
        facetOpts = {};
      }
      facetValues = getFacetValues(data, facetOpts.field);
      sortOpts = facetCommon.formatSortOpts(facetOpts.sort);
      facets = sortFacetValues(facetValues, sortOpts);
      return facets;
    }
  };

}).call(this);
