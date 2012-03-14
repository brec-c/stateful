module.exports = 
	doTest: (num) ->
		num = num * 7
		console.log "num is #{num}"
		console.log "common code is #{@testCommon()}"
