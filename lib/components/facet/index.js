(function() {
  module.exports = {
    toMongo: require('./mongo'),
    toPg: require('./postgres'),
    toSolr: require('./solr')
  };

}).call(this);
