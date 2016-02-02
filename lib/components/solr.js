(function() {
  var _, common, facet, options, query;

  _ = require('lodash');

  common = require('../common');

  facet = require('./facet');

  query = require('./query');

  options = require('./options');

  module.exports = function(q) {
    var components;
    q = common.preprocess(q);
    components = {
      q: query.toSolr(q.query)
    };
    components = _.merge(components, options.toSolr(q.options));
    if (q.facet != null) {
      components = facet.toSolr(components, q.facet);
    }
    return components;
  };

}).call(this);
