(function() {
  var BaseFacet, PostgresFacet,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  BaseFacet = require('./base');

  PostgresFacet = (function(superClass) {
    extend(PostgresFacet, superClass);

    function PostgresFacet() {
      this.applyFacetImpl = bind(this.applyFacetImpl, this);
      this.applyFacetSort = bind(this.applyFacetSort, this);
      return PostgresFacet.__super__.constructor.apply(this, arguments);
    }

    PostgresFacet.prototype.ASC = 'ASC';

    PostgresFacet.prototype.DESC = 'DESC';

    PostgresFacet.prototype.applyFacetField = function(queryComponents, facetOpts) {
      var selectFields;
      selectFields = facetOpts.field + ', ' + facetOpts.countField;
      queryComponents.SELECT = selectFields;
      return queryComponents['GROUP BY'] = facetOpts.field;
    };

    PostgresFacet.prototype.applyFacetSort = function(queryComponents, facetOpts) {
      var dir, orderBy;
      if (facetOpts.sortBy === this.VALUE) {
        orderBy = facetOpts.field;
      } else {
        orderBy = facetOpts.countField;
      }
      dir = facetOpts.dir === 1 ? this.ASC : this.DESC;
      orderBy += ' ' + dir;
      return queryComponents['ORDER BY'] = orderBy;
    };

    PostgresFacet.prototype.applyFacetImpl = function(queryComponents, facetOpts) {
      facetOpts.countField = "COUNT(" + facetOpts.field + ")";
      this.applyFacetField(queryComponents, facetOpts);
      this.applyFacetSort(queryComponents, facetOpts);
      return queryComponents;
    };

    return PostgresFacet;

  })(BaseFacet);

  module.exports = (new PostgresFacet).applyFacet;

}).call(this);
