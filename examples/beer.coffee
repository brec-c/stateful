Statechart = require '../src/statechart'

class BeerMug extends Statechart
	
	@StateChart 
		Empty: 
			transitions: [
				destination: 'Full'
				action: 'fill'
			]
			methods: 
				fill: -> 
					console.log "I'm pouring..."
					Statechart.Success
				test: ->
					console.log "this is a test"
		Full:
			transitions: [
				{destination: 'Empty',action: 'pour'}
				{destination: 'HalfFull', action: 'drink'}
				{destination: 'MostlyFull', action: 'sip'}
			]
			methods:
				pour: -> 
					console.log 'pouring this skunk out!'
					Statechart.Success

				drink: -> 
					console.log "chug, chug, chug..."
					Statechart.Success

				sip: (size = 1) ->
					console.log "taking sip of size #{size}"
					@sipCount = 0 unless @sipCount
					@sipCount += size
					console.log "sip count at #{@sipCount}"
					if @numSips > @sipCount then return Statechart.Success
					else return Statechart.Failure

			paths: 
				HalfFull:
					transitions:[]
					methods: 
						test: -> console.log "remapped!"

				MostlyFull:
					transitions:[]
					methods: {}


	numSips: 5

	onStateChange: -> console.log "I'm now in state: #{@stateName}."
		

mug = new BeerMug

mug.fill()

mug.test()

mug.sip 3

mug.test()

result = mug.sip(3)
console.log "result is #{result}, Failure is #{Statechart.Failure}"
if result is Statechart.Failure
	console.log "wtf?"
	mug.drink()

mug.test()

mug.pour()



