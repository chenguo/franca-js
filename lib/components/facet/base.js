(function() {
  var BaseFacet, _, common, facetCommon,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  _ = require('lodash');

  common = require('../../common');

  facetCommon = require('./common');

  BaseFacet = (function() {
    function BaseFacet() {
      this.applyFacet = bind(this.applyFacet, this);
      this.formatOpts = bind(this.formatOpts, this);
    }

    BaseFacet.prototype.COUNT = facetCommon.COUNT;

    BaseFacet.prototype.VALUE = facetCommon.VALUE;

    BaseFacet.prototype.formatOpts = function(opts) {
      var facetSort, sortOpts;
      if (opts.field == null) {
        throw new Error('No field provided for facet options: ' + JSON.stringify(opts));
      }
      sortOpts = facetCommon.formatSortOpts(opts.sort);
      facetSort = _.merge({
        field: opts.field
      }, sortOpts);
      return facetSort;
    };

    BaseFacet.prototype.applyFacet = function(queryComponents, facetOpts) {
      facetOpts = this.formatOpts(facetOpts);
      return this.applyFacetImpl(queryComponents, facetOpts);
    };

    return BaseFacet;

  })();

  module.exports = BaseFacet;

}).call(this);
