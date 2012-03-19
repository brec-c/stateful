# WORK IN PROGRESS


# --------------------------------------------------------------------------------------------------------------------

# think of it this way, States are Adjectives and action are Verbs
# A class becomes a state but it starts/stops an action

###
@addStateTree 'UNSAVED': # I am an Unsaved Model
	actions: 'Editing,Saving' # As an Unsaved Model, my actions are Editing and Saving
	methods: 
		foo: -> console.log bar
	

@addStateTree 'SAVED': # I am a Saved Model
	'UNLOADED': # I am a Saved Model but am UNLOADED
		actions: 'Loading' # As a Saved, Unloaded model my actions are Loading
		methods: require './model-states/unloaded'
		
	'LOADED': # etc...
		actions: 'Updating,Editing' # do actions need designated exit states?
		'DIRTY':
			actions: 'Syncing'
			'CONFLICTED':
				actions: 'Editing'
	
###
# how do we change between major tree branches?  
# Is it legal to jump from SAVED->LOADED->DIRTY to UNSAVED?  What prevents this?
	
# Legal Statechanges:
#
# Can only change between siblings of the same parent or to a direct descendant or to any ancestor
# 
# IE: 
# UNLOADED can change to LOADED but not DIRTY.
# LOADED can become DIRTY but not CONFLICTED
# CONFLICTED can become DIRTY or LOADED

# what role do actions play?
# Actions are handled like delegated events but only when in the right state.  what causes the event? -> code, programmatic
# model.start('editing') ... model.stop('editing') -> good
# model.start('editing') ... model.start('saving') -> error
# model.start('editing') ... model.become('DIRTY') -> error
# model.state = "LOADED" ... model.start('syncing') -> error

# how do we incorporate state specific methods or method implementations as part of the configuration?
# methods hash that can either be filled in directly or use a require to load a separate file.


class Tree extends Emitter

	@addStateTree: (tree) ->
		@::__stateForest = {} unless @::__stateForest?
		
		# TODO: validate Tree
		
		@::__stateForest = _.extend @::__stateForest, tree
		
	Object.defineProperty @prototype, 'states',
		get: -> @__states or @__states = _.keys @__stateForest
	Object.defineProperty @prototype, 'tree',
		get: -> @__tree
	Object.defineProperty @prototype, 'state',
		get: -> @__state
		set: (state) -> @changeState state
				
	constructor: (config) ->
		unless config.state then @state = @states[0]
		
	changeState: (to) ->
		from = @state
		return if from is to

		# if from isnt undefined and not @isValidStateChange(from, to)
		# 	throw new Error "Bad state change: can't change from the '#{@state}' state to '#{to}' state on #{@constructor.name}"

		# Could introduce an extension point here that would allow child class to do a check before the state changes
		# and if the callback returns true would abort the state change.

		@state = to

		@onStateChange(from, to) if @onStateChange?
		
		# remove methods for actions in the fromState
		@removeActionMethods from
		
		# add methods for actions in the toState
		@addActionMethods to
		
		# unapply methods in the fromState
		fromMethods = @__stateChart[from]?.methods
		@unapplyMethod method for method of fromMethods
		
		# apply methods in the toState
		toMethods = @__stateChart[to]?.methods
		@applyMethod method, impl for method, impl of toMethods
		
		@emit 'stateChange', from, to
		@emit "stateChange:#{to}", from
		

	# isValidState: (state) -> @__stateChart[state]?
	# isValidStateChange: (from, to) ->
	# 	fromConfig = @__stateChart[from]
	# 	toConfig   = @__stateChart[to]
	# 
	# 	if not fromConfig? then throw new Error("Bad state change: can't change from the non-existent state '#{from}'")
	# 	if not toConfig?   then throw new Error("Bad state change: can't change to the non-existent state '#{to}'")
	# 
	# 	return _.contains(fromConfig.exit, to) and _.contains(toConfig.enter, from)
		
	unapplyMethod: (method) -> 
		console.log "unapply #{method}"
		if @[method]?
			delete @[method]
			@[method] = null
		
	applyMethod: (method, impl) -> 
		console.log "apply #{method} -> #{impl}"
		@[method] = impl	
	
exports.StateChartTree = Tree
