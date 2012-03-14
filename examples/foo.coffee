Stateful = require '../src/stateful'

class Foo extends Stateful
	
	@state "EMPTY",
		transitions:
			initial: true 
			enter: "HALFWAY"
			exit: "FULL"
		methods:
			doTest: (num) ->
				num = num * 10
				console.log "num is #{num}"
				console.log "common code is #{@testCommon()}"
				
	@state "HALFWAY",
		transitions:
			enter: "FULL"
			exit: "EMPTY"
		methods: require './halfway'

	@state "FULL",
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
	testCommon: -> return "class Foo has two states: 'EMPTY' and 'FULL'	 we're currently in #{@state}"

foo = new Foo

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
