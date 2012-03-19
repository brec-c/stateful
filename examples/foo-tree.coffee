# DOES NOT WORK YET.  BASED ON STATECHART IMPLEMENTATION THAT IS NOT DONE

StateChartTree = require '../src/stateForest'

class BeerStein extends StateChartTree
	
	@addStateTree 'EMPTY':
		actions: 'filling'
		methods:
			onStartFilling: -> console.log "i'm filling up"
			onStopFilling: -> console.log "i'm halfway up"
				
	@addStateTree 'HALFWAY':
		actions: 'filling'
		methods:
			onStartFilling: -> console.log "filling up continued"
			onStopFilling: -> console.log "i'm full"
				
	@addStateTree 'FULL':
		actions: 'drinking,pouring'
		methods: ->
			onStartDrinking: -> console.log "i'm getting drunk (get it :))"
			onStopDrinking: -> console.log "boo!"
			onStartPouring: -> console.log "better be for your homies."
			onStopPouring: -> console.log ""
	
	
	constructor: ->
		console.log "new foo object constructed."
		console.log "default state is #{@state}"
	

mug = new BeerStein

mug.start 'filling'
mug.stop 'filling'

mug.state = "FULL"
try
	mug.start 'filling'
catch e
	console.log "ERROR: #{e}"
	
mug.start 'drinking'

try
	mug.state = "HALFWAY"
catch e
	console.log "ERROR: #{e}"
	
mug.stop 'drinking'

mug.state = "HALFWAY"
mug.start 'filling'