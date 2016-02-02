(function() {
  var common, facet, options, query;

  common = require('../common');

  facet = require('./facet');

  query = require('./query');

  options = require('./options');

  module.exports = function(q) {
    var collection, components, opts;
    q = common.preprocess(q);
    opts = options.toMongo(q.options);
    if (opts.collection != null) {
      collection = opts.collection;
      delete opts.collection;
    }
    components = {
      query: query.toMongo(q.query),
      options: opts
    };
    if (q.facet != null) {
      components = {
        pipeline: facet.toMongo(components, q.facet)
      };
    }
    if (collection != null) {
      components.collection = collection;
    }
    return components;
  };

}).call(this);
