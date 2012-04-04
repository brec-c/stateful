(function() {
  var Emitter, Stateful, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Emitter = require('common-emitter');

  _ = require('underscore');

  Stateful = (function(_super) {

    __extends(Stateful, _super);

    Stateful.define = function(name, config) {
      return Object.defineProperty(this.prototype, name, config);
    };

    Stateful.define('state', {
      get: function() {
        return this.__state;
      },
      set: function(state) {
        return this.changeState(state);
      }
    });

    Stateful.define('numStates', {
      get: function() {
        return _.size(this.__stateChart);
      }
    });

    Stateful.define('listStates', {
      get: function() {
        return _.keys(this.__stateChart).join(', ');
      }
    });

    Stateful.addState = function(stateName, config) {
      var interpretDirection, transitions, _ref,
        _this = this;
      if (this.prototype.__stateChart == null) this.prototype.__stateChart = {};
      interpretDirection = function(state, config, direction) {
        var value;
        value = config[direction];
        if (!(value != null)) {
          return [];
        } else if (_.isArray(value)) {
          return value;
        } else if (_.isString(value)) {
          return _.map(value.split(','), function(token) {
            return token.trim();
          });
        } else {
          throw new Error("The '" + state + "' state has an invalid configuration for its " + direction + " states");
        }
      };
      transitions = config.transitions;
      return this.prototype.__stateChart[stateName] = {
        enter: interpretDirection(stateName, transitions, 'enter'),
        exit: interpretDirection(stateName, transitions, 'exit'),
        initial: (_ref = transitions.initial) != null ? _ref : false,
        methods: config.methods || {}
      };
    };

    Stateful.buildStateChart = function() {
      var config, state, validateDirection, _ref, _results,
        _this = this;
      if (this.prototype.__stateChart == null) {
        throw new Error("Must add states inorder to build a StateChart");
      }
      validateDirection = function(state, config, direction) {
        var otherConfig, otherState, reverse, _i, _len, _ref, _results;
        reverse = direction === 'enter' ? 'exit' : 'enter';
        _ref = config[direction];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          otherState = _ref[_i];
          otherConfig = _this.prototype.__stateChart[otherState];
          if (!(otherConfig != null)) {
            throw new Error("Invalid non-existent '" + otherState + "' state declared as an " + direction + " state for '" + state + "'");
          }
          if (!_.contains(otherConfig[reverse], state)) {
            throw new Error("The '" + otherState + "' state is declared as an " + direction + " state for '" + state + "', but '" + state + "' is not an " + reverse + " state for '" + otherState + "'");
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
      this.prototype.__initialState = null;
      _ref = this.prototype.__stateChart;
      _results = [];
      for (state in _ref) {
        config = _ref[state];
        _results.push((function(state, config) {
          if (config.initial === true) {
            if (_this.prototype.__initialState != null) {
              throw new Error("Both the '" + _this.prototype.__initialState + "' and '" + state + "' states are defined as initial states");
            }
            _this.prototype.__initialState = state;
          }
          validateDirection(state, config, 'enter');
          return validateDirection(state, config, 'exit');
        })(state, config));
      }
      return _results;
    };

    function Stateful() {
      this.state = this.__initialState;
    }

    Stateful.prototype.dispose = function() {
      return this.removeAllListeners();
    };

    Stateful.prototype.is = function(state) {
      if (!this.isValidState(state)) {
        throw new Error("State: " + state + " doesn't exist for " + this + ".");
      }
      return this.state === state;
    };

    Stateful.prototype.isIn = function(states) {
      return _.any(states, this.is, this);
    };

    Stateful.prototype.isnt = function(state) {
      return this.state !== state;
    };

    Stateful.prototype.changeState = function(to) {
      var from;
      from = this.__state;
      if (from === to) return;
      if (from !== void 0 && !this.isValidStateChange(from, to)) {
        throw new Error("Bad state change: can't change from the '" + this.state + "' state to '" + to + "' state on " + this.constructor.name);
      }
      this.__state = to;
      return this.onStateChange(from, to);
    };

    Stateful.prototype.pascalCase = function(str) {
      return str[0].toUpperCase() + str.substr(1);
    };

    Stateful.prototype.isValidState = function(state) {
      return this.__stateChart[state] != null;
    };

    Stateful.prototype.isValidStateChange = function(from, to) {
      var fromConfig, toConfig;
      fromConfig = this.__stateChart[from];
      toConfig = this.__stateChart[to];
      if (!(fromConfig != null)) {
        throw new Error("Bad state change: can't change from the non-existent state '" + from + "'");
      }
      if (!(toConfig != null)) {
        throw new Error("Bad state change: can't change to the non-existent state '" + to + "'");
      }
      return _.contains(fromConfig.exit, to) && _.contains(toConfig.enter, from);
    };

    Stateful.prototype.onStateChange = function(from, to) {
      var fromMethods, impl, method, toMethods, _ref, _ref2;
      fromMethods = (_ref = this.__stateChart[from]) != null ? _ref.methods : void 0;
      for (method in fromMethods) {
        this.unapplyMethod(method);
      }
      toMethods = (_ref2 = this.__stateChart[to]) != null ? _ref2.methods : void 0;
      for (method in toMethods) {
        impl = toMethods[method];
        this.applyMethod(method, impl);
      }
      this.emit('stateChange', from, to);
      return this.emit("stateChange:" + to, from);
    };

    Stateful.prototype.unapplyMethod = function(method) {
      if (this[method] != null) delete this[method];
      if (this["_" + method] != null) return this[method] = this["_" + method];
    };

    Stateful.prototype.applyMethod = function(method, impl) {
      if (this[method] != null) this["_" + method] = this[method];
      return this[method] = impl;
    };

    Stateful.prototype.when = function(state, callback) {
      if (this.is(state)) {
        return callback();
      } else {
        return this.once("stateChange:" + state, callback);
      }
    };

    return Stateful;

  })(Emitter);

  module.exports = Stateful;

}).call(this);
