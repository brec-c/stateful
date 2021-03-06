(function() {
  var EventEmitter2, Stateful, _,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  EventEmitter2 = require('eventemitter2').EventEmitter2;

  _ = require('underscore');

  Stateful = (function(_super) {

    __extends(Stateful, _super);

    Stateful.define = function(name, config) {
      return Object.defineProperty(this.prototype, name, config);
    };

    Stateful.define('statechart', {
      get: function() {
        return this.__statechart;
      }
    });

    Stateful.define('stateName', {
      get: function() {
        return this.__state.name;
      }
    });

    Stateful.define('state', {
      get: function() {
        return this.__state;
      },
      set: function(obj) {
        return this.setState(obj);
      }
    });

    Stateful.Success = false;

    Stateful.Failure = true;

    Stateful.StateChart = function(chart) {
      var addPaths;
      this.prototype.__statechart = {};
      addPaths = function(statesObj, parent) {
        var defn, name, stateObj, _results;
        _results = [];
        for (name in statesObj) {
          defn = statesObj[name];
          stateObj = {
            name: name,
            transitions: defn.transitions,
            methods: defn.methods,
            paths: {},
            parent: parent
          };
          parent[name] = stateObj;
          _results.push(addPaths(defn.paths, stateObj.paths));
        }
        return _results;
      };
      return addPaths(chart, this.prototype.__statechart);
    };

    function Stateful(config) {
      var stateName;
      if (config == null) config = {};
      Stateful.__super__.constructor.call(this, _.extend({
        wildcard: true
      }, config));
      if (this.statechart == null) return;
      if (config.defaultState) {
        this.setState(this.pathResolver(config.defaultState));
      } else {
        stateName = _.keys(this.statechart)[0];
        this.setState(this.statechart[stateName]);
      }
    }

    Stateful.prototype.dispose = function() {
      return this.removeAllListeners();
    };

    Stateful.prototype.setState = function(nameOrObj) {
      var oldState, stateObj;
      stateObj = typeof nameOrObj === 'string' ? this.pathResolver(nameOrObj) : nameOrObj;
      if (this.state) {
        oldState = this.state;
        if (this.isDescendantState(stateObj)) this.removeMethods(oldState.methods);
      }
      this.__state = stateObj;
      this.addMethods(this.state.methods);
      this.buildTransitions(this.state.transitions);
      this.onStateChange(this.state, oldState);
      this.emit('statechange', this.stateName, oldState != null ? oldState.name : void 0);
      return this.emit("statechange:" + this.stateName, oldState != null ? oldState.name : void 0);
    };

    Stateful.prototype.isDescendantState = function(state) {
      if (state.parent == null) return false;
      if (state.parent === this.state) return true;
      return this.isDescendantState(state.parent);
    };

    Stateful.prototype.onStateChange = function(newStateObj, oldStateObj) {};

    Stateful.prototype.removeMethods = function(methods) {
      var method, _results;
      if (methods == null) return;
      _results = [];
      for (method in methods) {
        if (this[method] != null) delete this[method];
        if (this["super_" + method] != null) {
          _results.push(this[method] = this["super_" + method]);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Stateful.prototype.addMethods = function(methods) {
      var impl, method, _results;
      if (methods == null) return;
      _results = [];
      for (method in methods) {
        impl = methods[method];
        if (this[method] != null) this["super_" + method] = this[method];
        _results.push(this[method] = impl);
      }
      return _results;
    };

    Stateful.prototype.buildTransitions = function(transitions) {
      var _this = this;
      return _.each(transitions, function(t) {
        var chgMethod, destination;
        destination = _this.pathResolver(t.destination);
        chgMethod = _this[t.action];
        return _this[t.action] = function() {
          var dontTransition;
          dontTransition = chgMethod.apply(_this, arguments);
          if (!dontTransition) _this.setState(destination);
          return dontTransition;
        };
      });
    };

    Stateful.prototype.pathResolver = function(path) {
      var step, steps, target, _i, _len;
      if (this.state.paths[path] != null) return this.state.paths[path];
      steps = path.split('/');
      target = {
        paths: this.statechart
      };
      for (_i = 0, _len = steps.length; _i < _len; _i++) {
        step = steps[_i];
        target = target.paths[step];
      }
      return target;
    };

    return Stateful;

  })(EventEmitter2);

  module.exports = Stateful;

}).call(this);
