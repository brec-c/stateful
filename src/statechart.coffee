Emitter = require 'common-emitter'
_       = require 'underscore'

class Stateful extends Emitter
	
	@define: (name, config) -> Object.defineProperty @::, name, config

	@define 'state', get: -> @__state.name
			
	@StateChart (chart) ->
		@::__statechart = {} unless @::__statechart?

		addPaths = (statesObj, parent) ->
			for name,defn of statesObj
				@::__statechart[name] =
					name       : name
					transitions: defn.transitions
					methods    : defn.methods
					parent     : parent
			
				# TODO: validate contents for state
			
				addPaths defn.paths

		addPaths paths
		
		# TODO: confirm integrity of chart, makes sure all entry / exit points are accounted for
		
	constructor: (config) ->
		return unless @__statechart?
		
		if config.defaultState or @defaultState
			state = @__statechart[config.defaultState or @defaultState]
		else
			state = _.keys(@__statechart)[0]
			
		@setState tate
		
	dispose: -> @removeAllListeners()

	setState: (stateObj) ->
		# validate state change
		
		oldState = @__state
		@__state = stateObj
		
		@removeMethods oldState.methods
		@addMethods @__state.methods
		@buildTransitions @__state.transitions
	
	removeMethods: (methods) ->
		return unless methods?
		for method of methods
			delete @[method] if @[method]?
			@[method] = @["_#{method}"] if @["_#{method}"]?
	
	addMethods: (methods) ->
		return unless methods?
		for method, impl of methods
			@["_#{method}"] = @[method] if @[method]?
			@[method] = impl
	
	buildTransitions: (transitions) ->
		for t in transitions
			destination = @pathResolver t.destination
			chgMethod = @[t.method]
			@[t.method] = =>
				result = chgMethod.apply @, arguments
				@setState = destination unless result is true
	
	pathResolver: (path) ->
		steps = path.split '/'
		isRelative = path.indexOf '..' is 0
		
		for step in steps
			
	
module.exports = Stateful