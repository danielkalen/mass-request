Promise = require 'bluebird'
minimist = require 'minimist'
args = minimist(process.argv.slice(2))
options = 
	times: args.times or args.t
	delay: args.delay or args.d
	debug: args.debug
	url: args._[0]


require('./mass-request')(options, true)
	.on 'request', (count)->
		console.log("Making request ##{count}")
	
	.on 'response', (stats)->
		console.log(stats) if options.debug
	
	.on 'failure', (failureCount, count)->
		console.log("Request ##{count} failed (failure ##{failureCount})")

	.then (res)->
		console.log "DONE! took #{res.totalTime}s total, #{res.processTime}s without request time"
	
	.catch (err)->
		console.error(err?.message or err)
		process.exit(1)