Statechart = require '../src/statechart'

class BeerMug extends Statechart
	
	@StateChart 
		Empty: 
			transitions: [
				destination: 'Empty/Full'
				action: 'pour'
			]
			methods: 
				pour: -> 
					console.log "I'm pouring..."
					Statechart.Success
			paths: 
				Full:
					transitions: [
						destination: 'Empty'
						action: 'drink'
					]
					methods:
						drink: -> 
							console.log "chug, chug, chug..."
							Statechart.Success

	onStateChange: ->
		console.log "I'm now in state: #{@stateName}."
		

mug = new BeerMug

mug.pour()

mug.drink()
