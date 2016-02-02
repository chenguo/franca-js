(function() {
  var _, common, facet, options, query;

  _ = require('lodash');

  common = require('../common');

  facet = require('./facet');

  query = require('./query');

  options = require('./options');

  module.exports = function(q) {
    var components, whereStr;
    q = common.preprocess(q);
    components = {};
    whereStr = query.toPg(q.query);
    if ((whereStr != null) && whereStr !== '') {
      components.WHERE = whereStr;
    }
    components = _.merge(components, options.toPg(q.options));
    if (q.facet != null) {
      components = facet.toPg(components, q.facet);
    }
    return components;
  };

}).call(this);
