Stateful = require '../src/stateful'

class PintGlass extends Stateful
	
	@addState "EMPTY",
		transitions:
			initial: true 
			enter: "HALFWAY"
			exit: "FULL"
		methods:
			doTest: (num) ->
				num = num * 10
				console.log "num is #{num}"
				console.log "common code is #{@testCommon()}"
				
	@addState "HALFWAY",
		transitions:
			enter: "FULL"
			exit: "EMPTY"
		methods: require './halfway'

	@addState "FULL",
		transitions:
			enter: "EMPTY"
			exit: "HALFWAY"
		methods:
			doTest: (num) ->
				num = num * 3
				console.log "num is #{num}"
				console.log "common code is #{@testCommon()}"
				
	@buildStateChart()
				
	doTest: -> console.log "should not get called.  maybe if super is called?"
	testCommon: -> return "class Foo has #{@numStates} states: #{@listStates}.  we're currently in #{@state}"

foo = new PintGlass

foo.on "stateChange", (from, to) -> console.log "state was #{from}, state is #{to}"

console.log "foo.state is #{foo.state}"

val = 5
console.log "running foo.doTest with value: #{val}"
foo.doTest val

foo.state = "FULL"
foo.doTest val

foo.state = "HALFWAY"
foo.doTest val

try 
	foo.state = "FULL"
catch e
	console.log "Caught: #{e}"

console.log "all done"
