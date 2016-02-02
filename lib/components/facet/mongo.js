(function() {
  var BaseFacet, MongoFacet, _,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  BaseFacet = require('./base');

  MongoFacet = (function(superClass) {
    extend(MongoFacet, superClass);

    function MongoFacet() {
      this.applyFacetImpl = bind(this.applyFacetImpl, this);
      return MongoFacet.__super__.constructor.apply(this, arguments);
    }

    MongoFacet.prototype.ASC = 1;

    MongoFacet.prototype.DESC = -1;

    MongoFacet.prototype.applyFacetQuery = function(pipeline, queryComponents) {
      if (!_.isEmpty(queryComponents.query)) {
        return pipeline.push({
          $match: queryComponents.query
        });
      }
    };

    MongoFacet.prototype.applyFacetField = function(pipeline, facetOpts) {
      return pipeline.push({
        $group: {
          _id: '$' + facetOpts.field,
          count: {
            $sum: 1
          }
        }
      });
    };

    MongoFacet.prototype.applyFacetSort = function(pipeline, facetOpts) {
      var $sort, orderBy;
      $sort = {};
      orderBy = facetOpts.sortBy === this.VALUE ? '_id' : 'count';
      $sort[orderBy] = facetOpts.dir;
      return pipeline.push({
        $sort: $sort
      });
    };

    MongoFacet.prototype.applyFacetLimit = function(pipeline, queryComponents) {
      if ((queryComponents.options != null) && (queryComponents.options.limit != null)) {
        return pipeline.push({
          $limit: queryComponents.options.limit
        });
      }
    };

    MongoFacet.prototype.applyFacetImpl = function(queryComponents, facetOpts) {
      var pipeline;
      pipeline = [];
      this.applyFacetQuery(pipeline, queryComponents);
      this.applyFacetField(pipeline, facetOpts);
      this.applyFacetSort(pipeline, facetOpts);
      this.applyFacetLimit(pipeline, queryComponents);
      return pipeline;
    };

    return MongoFacet;

  })(BaseFacet);

  module.exports = (new MongoFacet).applyFacet;

}).call(this);
