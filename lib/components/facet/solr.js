(function() {
  var BaseFacet, SolrFacet,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseFacet = require('./base');

  SolrFacet = (function(superClass) {
    extend(SolrFacet, superClass);

    function SolrFacet() {
      this.applyFacetImpl = bind(this.applyFacetImpl, this);
      this.applyFacetSort = bind(this.applyFacetSort, this);
      return SolrFacet.__super__.constructor.apply(this, arguments);
    }

    SolrFacet.prototype.applyFacetField = function(queryComponents, facetOpts) {
      return queryComponents['facet.field'] = facetOpts.field;
    };

    SolrFacet.prototype.indexSortError = function() {
      throw new Error('Solr does not support descending sort on facet values');
    };

    SolrFacet.prototype.countSortError = function() {
      throw new Error('Solr does not support ascending sort on facet counts');
    };

    SolrFacet.prototype.applyFacetSort = function(queryComponents, facetOpts) {
      var sortBy;
      if (facetOpts.sortBy === this.VALUE) {
        sortBy = 'index';
        if (facetOpts.dir === -1) {
          this.indexSortError();
        }
      } else {
        sortBy = 'count';
        if (facetOpts.dir === 1) {
          this.countSortError();
        }
      }
      return queryComponents['facet.sort'] = sortBy;
    };

    SolrFacet.prototype.applyFacetLimit = function(queryComponents) {
      if (queryComponents.rows != null) {
        queryComponents['facet.limit'] = queryComponents.rows;
        return delete queryComponents.rows;
      }
    };

    SolrFacet.prototype.applyFacetImpl = function(queryComponents, facetOpts) {
      this.applyFacetField(queryComponents, facetOpts);
      this.applyFacetSort(queryComponents, facetOpts);
      this.applyFacetLimit(queryComponents);
      return queryComponents;
    };

    return SolrFacet;

  })(BaseFacet);

  module.exports = (new SolrFacet).applyFacet;

}).call(this);
