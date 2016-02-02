(function() {
  var _, common, componentMaker, facet, options, query;

  _ = require('lodash');

  common = require('../common');

  facet = require('./facet');

  query = require('./query');

  options = require('./options');

  componentMaker = function(protocol) {
    return function(q) {
      var components, optsComp, qComp;
      q = common.preprocess(q);
      qComp = query[protocol](q.query);
      optsComp = options[protocol](q.options);
      components = _.merge(qComp, optsComp);
      if (q.facet != null) {
        components = facet[protocol](components, q.facet);
      }
      return components;
    };
  };

  module.exports = {
    toMongo: require('./mongo'),
    toPg: require('./postgres'),
    toSolr: require('./solr')
  };

}).call(this);
