#Stateful Designed Classes

When designing certain kinds of classes it can be very useful to have a map or chart of all the potential States that might exist for the class.  Not only all the states but also how they are allowed to transition between them.  Quite often just the exercise of thinking up the States and their transitions will help you design the class more thoughtfully.  __Stateful__ gives you mechanic and then reinforces by preventing any invalid state changes.  In addition, __Stateful__ also allows you to have specific implementations by state (ie the doThat (™) method might behave different if your class is "loaded" and not "processing").

# Install

npm install stateful

#Usage

Look at this example:

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
