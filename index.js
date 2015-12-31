require('coffee-script');
r = require('app-root-path').require;
common = r('lib/common');
translate = r('/lib/translate');


module.exports = {
  components: r('/lib/components'),
  TYPES: common.TYPES,
  translate: translate,
  toMongo: translate.toMongo,
  toPg: translate.toPg,
  toSolr: translate.toSolr
};
