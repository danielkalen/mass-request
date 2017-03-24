global.Promise = require 'bluebird'
axios = require 'axios'
minimist = require 'minimist'
args = minimist(process.argv.slice(2))
options = 
	# times: args.times or args.t or 500
	times: args.times or args.t or 5
	delay: args.delay or args.d or 150
	debug: args.debug
	url: args._[0]

if not options.url or not options.url.startsWith('http')
	console.log 'Invalid/No URL provided'
	process.exit(1)


reqCount = 0
totalReqTime = 0
processStartTime = process.hrtime()

makeRequest = ()->
	reqStartTime = Date.now()
	console.log("Making request \##{++reqCount}")
	
	axios.get(options.url).then (res)->
		reqEndTime = Date.now()
		totalReqTime += reqEndTime-reqStartTime
		console.log("#{res.status} #{res.statusText} (#{reqEndTime-reqStartTime}ms)") if options.debug

		if reqCount < options.times
			Promise.delay(options.delay).then(makeRequest)


makeRequest().then ()->
	processTime = process.hrtime(processStartTime)
	processTime = processTime[0]+processTime[1]/1e9
	processTimeNoReq = processTime - totalReqTime/1e3
	
	console.log "DONE! took #{processTime.toFixed(3)}s total, #{processTimeNoReq.toFixed(3)}s without request time"








