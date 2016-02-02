(function() {
  var BaseOptions, MongoOptions, _,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  BaseOptions = require('./options');

  MongoOptions = (function(superClass) {
    extend(MongoOptions, superClass);

    function MongoOptions() {
      this.sortOptions = bind(this.sortOptions, this);
      return MongoOptions.__super__.constructor.apply(this, arguments);
    }

    MongoOptions.prototype.ASC = 1;

    MongoOptions.prototype.DESC = -1;

    MongoOptions.prototype.rowOptions = function(opts) {
      var rowOpts;
      rowOpts = {};
      if (!isNaN(opts.offset)) {
        rowOpts.skip = parseInt(opts.offset);
      }
      if (!isNaN(opts.limit)) {
        rowOpts.limit = parseInt(opts.limit);
      }
      return rowOpts;
    };

    MongoOptions.prototype.sortOptions = function(opts) {
      var orderings;
      orderings = this.formatSortOpts(opts);
      if ((orderings != null) && orderings.length > 0) {
        return {
          sort: orderings
        };
      } else {
        return {};
      }
    };

    MongoOptions.prototype.tableOptions = function(opts) {
      if (opts.table != null) {
        return {
          collection: opts.table
        };
      }
    };

    MongoOptions.prototype.fieldOptions = function(opts) {
      var fieldOpts;
      if ((opts.fields != null) && opts.fields instanceof Array) {
        fieldOpts = _.reduce(opts.fields, function(fields, f) {
          fields[f] = 1;
          return fields;
        }, {});
        return {
          fields: fieldOpts
        };
      }
    };

    return MongoOptions;

  })(BaseOptions);

  module.exports = (new MongoOptions).convertOptions;

}).call(this);
