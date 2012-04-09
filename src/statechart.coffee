Emitter = require 'common-emitter'
_       = require 'underscore'

class Stateful extends Emitter
	
	@define: (name, config) -> Object.defineProperty @::, name, config

	@define 'state', get: -> @__state.name
			
	@StateChart (chart) ->
		@::__statechart = {} unless @::__statechart?

		addStackedStates = (statesObj) ->
			for name,defn of statesObj
				@::__statechart[name] =
					name   : name
					actions: defn.actions
					methods: defn.methods
			
				# TODO: validate contents for state
			
				addStackedStates defn.states

		addStackedStates chart
		
	constructor: (config) ->
		return unless @__statechart?
		
		if config.defaultState or @defaultState
			state = @__statechart[config.defaultState or @defaultState]
		else
			state = _.keys(@__statechart)[0]
			
		@setState tate
		
	dispose: -> @removeAllListeners()


	setState: (stateObj) ->
		oldState = @__state
		@__state = stateObj
		
		@removeMethods oldState.methods
		@addMethods @__state.methods
		@buildActions @__state.actions
	
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
	
	buildActions: (actions) ->
		for action in actions
			destination = @pathResolver action.destination
			chgMethod = @[action.method]
			@[action.method] = =>
				result = chgMethod.apply @, arguments
				@setState = destination unless result is true
	
	changeState: (statePath) ->
		# TODO: suppport absolute and relative pathing
		# does path exist from the current state? 
		# is this the first path?
		unless @__state?

		# change old methods out
		# put new methods in
		
		# wrap actions in decision functions