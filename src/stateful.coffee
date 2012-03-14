Emitter = require 'common-emitter'
_       = require 'underscore'

class Stateful extends Emitter

	Object.defineProperty @prototype, 'state',
		get: -> @__state
		set: (state) -> @changeState(state)

	@state: (stateName, config) ->
		@::__stateChart = {} unless @::__stateChart?
		
		interpretDirection = (state, config, direction) =>
			value = config[direction]
			if not value? then return []
			else if _.isArray(value) then return value
			else if _.isString(value) then return _.map(value.split(','), (token) -> token.trim())
			else throw new Error("The '#{state}' state has an invalid configuration for its #{direction} states")

		# Interpret the state configuration and update the class's statechart.
		transitions = config.transitions
		@::__stateChart[stateName] =
			enter:   interpretDirection(stateName, transitions, 'enter')
			exit:    interpretDirection(stateName, transitions, 'exit')
			initial: transitions.initial ? false
			methods: config.methods or {}

	@buildStateChart: ->
		throw new Error "Must add states inorder to build a StateChart" unless @::__stateChart?
		
		validateDirection = (state, config, direction) =>
			reverse = if direction is 'enter' then 'exit' else 'enter'
			for otherState in config[direction]
				otherConfig = @::__stateChart[otherState]
				if not otherConfig?
					throw new Error("Invalid non-existent '#{otherState}' state declared as an #{direction} state for '#{state}'")
				unless _.contains(otherConfig[reverse], state)
					throw new Error("The '#{otherState}' state is declared as an #{direction} state for '#{state}', but '#{state}' is not an #{reverse} state for '#{otherState}'")
		
		# Validate the state chart to ensure each declared state has valid entrances and exits,
		# and that only one state is defined as the default state.
		@::__initialState = null
		for state, config of @::__stateChart
			do (state, config) =>
				if config.initial is true
					if @::__initialState?
						throw new Error("Both the '#{@::__initialState}' and '#{state}' states are defined as initial states")
					@::__initialState = state
				validateDirection(state, config, 'enter')
				validateDirection(state, config, 'exit')

	constructor: (config) ->
		super(config)
		@state = @__initialState

	is: (state) ->
		unless @isValidState state then throw new Error "State: #{state} doesn't exist for #{@}."
		@state is state

	isIn: (states) -> _.any states, @is, @

	isnt: (state) -> @state isnt state

	changeState: (to) ->
		from = @__state
		return if from is to

		if from isnt undefined and not @isValidStateChange(from, to)
			throw new Error "Bad state change: can't change from the '#{@state}' state to '#{to}' state on #{@}"

		# Could introduce an extension point here that would allow child class to do a check before the state changes
		# and if the callback returns true would abort the state change.

		@__state = to

		# build something like this so we can reuse this
		# handler = "onState#{__rubicon.pascalCase to}"
		# @[handler](from) if @[handler]?

		@onStateChange(from, to)

	isValidState: (state) -> @__stateChart[state]?

	isValidStateChange: (from, to) ->
		fromConfig = @__stateChart[from]
		toConfig   = @__stateChart[to]

		if not fromConfig? then throw new Error("Bad state change: can't change from the non-existent state '#{from}'")
		if not toConfig?   then throw new Error("Bad state change: can't change to the non-existent state '#{to}'")

		return _.contains(fromConfig.exit, to) and _.contains(toConfig.enter, from)

	onStateChange: (from, to) ->
		# unapply methods in the fromState
		# apply methods in the toState
		@emit 'stateChange', from, to
		@emit "stateChange:#{to}", from

	when: (state, callback) ->
		if @is state then callback()
		else
			@once "stateChange:#{state}", callback


module.exports = Stateful