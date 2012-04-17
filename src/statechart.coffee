Emitter = require 'common-emitter'
_       = require 'underscore'

class Stateful extends Emitter
	
	@define: (name, config) -> Object.defineProperty @::, name, config

	@define 'statechart', get: -> @__statechart
	@define 'stateName',  get: -> @__state.name
	@define 'state',      
		get: -> @__state
		set: (obj) -> @__state = obj
	
	@Success: false
	@Failure: true
			
	@StateChart: (chart) ->
		@::__statechart = {}

		addPaths = (statesObj, parent) ->
			for name, defn of statesObj
				stateObj = 
					name       : name
					transitions: defn.transitions
					methods    : defn.methods
					paths      : {}
					parent     : parent

				parent[name] = stateObj
							
				addPaths defn.paths, stateObj.paths

		addPaths chart, @::__statechart
		
		# TODO: confirm integrity of chart, makes sure all entry / exit points are accounted for
		
	constructor: (config={}) ->
		return unless @statechart?
		
		if config.defaultState
			@setState @pathResolver config.defaultState
		else
			stateName = _.keys(@statechart)[0]
			@setState @statechart[stateName]
		
	dispose: -> @removeAllListeners()

	setState: (stateObj) ->
		# TODO validate state change

		if @state
			oldState = @state
			# only remove if oldState isnt an ancestor of the new state
			if @isDescendantState stateObj
				@removeMethods oldState.methods

		@state = stateObj
		@addMethods @state.methods
		@buildTransitions @state.transitions
		
		@onStateChange @state, oldState
		
		@emit 'statechange', @stateName, oldState?.name
		@emit "statechange:#{@stateName}", oldState?.name
	
	isDescendantState: (state) ->
		unless state.parent? then return false
		if state.parent is @state then return true
		@isDescendantState state.parent

	onStateChange: (newStateObj, oldStateObj) ->
	
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
		_.each transitions, (t) =>
			destination = @pathResolver t.destination
			chgMethod = @[t.action]
			@[t.action] = =>
				dontTransition = (chgMethod.apply @, arguments)
				
				unless dontTransition
					@setState destination

				return dontTransition
	
	pathResolver: (path) ->
		# check if path is direct descendant current state
		if @state.paths[path]? then return @state.paths[path]

		# start from top
		steps = path.split '/'
		target = paths: @statechart
		for step in steps
			target = target.paths[step]
			
		return target
	
module.exports = Stateful
