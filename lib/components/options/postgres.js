(function() {
  var BaseOptions, PostgresOptions, _,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  _ = require('lodash');

  BaseOptions = require('./options');

  PostgresOptions = (function(superClass) {
    extend(PostgresOptions, superClass);

    function PostgresOptions() {
      this.sortOptions = bind(this.sortOptions, this);
      return PostgresOptions.__super__.constructor.apply(this, arguments);
    }

    PostgresOptions.prototype.ASC = 'ASC';

    PostgresOptions.prototype.DESC = 'DESC';

    PostgresOptions.prototype.rowOptions = function(opts) {
      var rowOpts;
      rowOpts = {};
      if (!isNaN(opts.offset)) {
        rowOpts.OFFSET = parseInt(opts.offset);
      }
      if (!isNaN(opts.limit)) {
        rowOpts.LIMIT = parseInt(opts.limit);
      }
      return rowOpts;
    };

    PostgresOptions.prototype.sortOptions = function(opts) {
      var orderings, sortOpts, sorts;
      orderings = this.formatSortOpts(opts);
      sortOpts = {};
      if ((orderings != null) && orderings.length > 0) {
        sorts = orderings.map(function(order) {
          return order[0] + ' ' + order[1];
        });
        sortOpts['ORDER BY'] = sorts.join(', ');
      }
      return sortOpts;
    };

    PostgresOptions.prototype.fieldOptions = function(opts) {
      var fieldStr, fields;
      fields = {};
      if (opts.fields != null) {
        fieldStr = opts.fields.join(', ');
        fields.SELECT = fieldStr;
      }
      return fields;
    };

    PostgresOptions.prototype.tableOptions = function(opts) {
      if (opts.table != null) {
        return {
          FROM: opts.table
        };
      } else {
        throw new Error('No table specified');
      }
    };

    return PostgresOptions;

  })(BaseOptions);

  module.exports = (new PostgresOptions).convertOptions;

}).call(this);
