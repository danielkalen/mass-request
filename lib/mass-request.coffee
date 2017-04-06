Promise = require 'bluebird'
axios = require 'axios'
extend = require 'smart-extend'
defaults = 
	times: 5
	delay: 150
	debug: false
	url: ''

module.exports = (options={}, fromCLI)->
	options = extend.clone(defaults, options)
	return Promise.reject('Invalid/No URL provided') if not options.url or not options.url.startsWith('http')
	reqCount = 0
	totalReqTime = 0
	processStartTime = process.hrtime()

	makeRequest = ()->
		reqStartTime = Date.now()
		console.log("Making request \##{++reqCount}") if fromCLI
		
		axios.get(options.url).then (res)->
			reqEndTime = Date.now()
			totalReqTime += reqEndTime-reqStartTime
			console.log("#{res.status} #{res.statusText} (#{reqEndTime-reqStartTime}ms)") if options.debug and fromCLI

			if reqCount < options.times
				Promise.delay(options.delay).then(makeRequest)


	makeRequest().then ()->
		processTime = process.hrtime(processStartTime)
		processTime = processTime[0]+processTime[1]/1e9
		processTimeNoReq = processTime - totalReqTime/1e3
		
		return "DONE! took #{processTime.toFixed(3)}s total, #{processTimeNoReq.toFixed(3)}s without request time"








