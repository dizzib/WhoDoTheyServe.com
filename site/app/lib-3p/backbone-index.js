;(function(_, Backbone) {
'use strict';

/**
 * Add where/query to Collection
 */

Backbone.Index = function(Collection, options) {
  if (!options) options = {};

  Collection.prototype.where = function(args, first) {
    // use query for array arguments
    if (_.filter(_.values(args), _.isArray).length) return this.query(args);

    var keys = _.keys(args).sort();
    var res  =  getIndex(this, args, keys, options)[getValue(args, keys)] || [];
    return first ? _.first(res) : res;
  };

  // It just calls `where` for every pairs of keys and
  // concat result
  Collection.prototype.query = function(args) {
    var keys   = getKeys(_.pairs(args));
    var result = [];

    for (var i = 0, len = keys.length; i < len; i++)
      result = result.concat(this.where(keys[i]));

    return result;
  };
};

/**
 * Work with indexes
 */

function getIndex(coll, args, keys, options) {
  var name = keys.join('');

  if (!coll._index) setupCollection(coll, options);
  if (!coll._index[name]) generateIndex(coll, name, keys);

  return coll._index[name];
}

function generateIndex(coll, name, keys) {
  coll._indexKeys.push(keys);
  coll._index[name] = coll.groupBy(function(item) {
    return getValue(item.attributes, keys);
  });
}

function getValue(args, keys) {
  var res = '';
  for (var i = 0, len = keys.length; i < len; i++) res += args[keys[i]];
  return res;
}

// Recursive function that transform object with arrays of keys
// to array of simple objects
// FIXME: main bottleneck for query vs where
function getKeys(pairs) {
  var i, j, len, len2, value;
  var res  = [];
  var pair = _.first(pairs), key = pair[0], val = pair[1];

  if (!_.isArray(val)) val = [val];
  for (i = 0, len = val.length; i < len; i++) {
    value = val[i];
    if (value && value.id) value = value.id;
    res.push(_.object([key], [value]));
  }

  if (pairs.length > 1) {
    var children = getKeys(_.rest(pairs));
    var merged   = [];
    for (i = 0, len = res.length; i < len; i++)
      for (j = 0, len2 = children.length; j < len2; j++)
        merged[len2*i + j] = _.extend({}, res[i], children[j]);
    return merged;
  } else {
    return res;
  }
}

/**
 * Manage events
 */

function setupCollection(coll, options) {
  coll._index     = {};
  coll._indexKeys = [];

  coll.on('add', forEachKeys(addItem));
  coll.on('remove', forEachKeys(removeItem));
  if (!options.ignoreChange) coll.on('change', onchange);
}

function addItem(index, value, item) {
  if (_.has(index, value)) index[value].push(item);
  else index[value] = [item];
}

function removeItem(index, value, item) {
  if (_.has(index, value))
    index[value] = _.without(index[value], item);
}

// In general change is most complex event.
// It tries to skip useless events with `changedAttributes` methods.
//
// When it needs to update index after change:
// 1. find previous index value
// 2. remove it
// 3. add new value
function onchange(item) {
  var changedKeys = _.keys(item.changedAttributes());
  var isChanged   = _.bind(_.include, null, changedKeys);
  var prevAttrs   = item.previousAttributes();

  forEachKeys(function(index, value, item, keys) {
    if (!_.some(keys, isChanged)) return;
    var prevValue = getValue(prevAttrs, keys);

    removeItem(index, prevValue, item);
    addItem(index, value, item);
  })(item);
}

// Helper to iterate `_indexKeys` on every event
function forEachKeys(cb) {
  return function(item) {
    var coll = item.collection;

    _.forEach(coll._indexKeys, function(keys) {
      var name  = keys.join('');
      var index = coll._index[name];
      var value = getValue(item.attributes, keys);
      cb(index, value, item, keys);
    });
  };
}

}).call(this, _, Backbone);
