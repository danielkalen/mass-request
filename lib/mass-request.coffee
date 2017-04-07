Promise = require 'bluebird'
axios = require 'axios'
extend = require 'smart-extend'
defaults = 
	times: 5
	maxFailed: 100
	delay: 150
	debug: false
	url: ''

module.exports = (options={}, fromCLI)->
	options = extend.clone(defaults, options)
	return Promise.reject('Invalid/No URL provided') if not options.url or not options.url.startsWith('http')
	failedReqCount = 0
	reqCount = 0
	totalReqTime = 0
	processStartTime = process.hrtime()

	makeRequest = ()->
		reqStartTime = Date.now()
		console.log("Making request \##{++reqCount}") if fromCLI
		
		axios.get(options.url)
			.then (res)->
				reqEndTime = Date.now()
				totalReqTime += reqEndTime-reqStartTime
				console.log("#{res.status} #{res.statusText} (#{reqEndTime-reqStartTime}ms)") if options.debug and fromCLI

				if reqCount < options.times
					Promise.delay(options.delay).then(makeRequest)
			
			.catch (err)->
				if ++failedReqCount >= options.maxFailed
					Promise.reject(new Error "Too many failed requests (#{failedReqCount} failures)")
				else
					reqCount--
					Promise.delay(options.delay).then(makeRequest)


	makeRequest().then ()->
		processTime = process.hrtime(processStartTime)
		processTime = processTime[0]+processTime[1]/1e9
		processTimeNoReq = processTime - totalReqTime/1e3
		return {
			totalTime: processTime.toFixed(3)
			requestTime: totalReqTime/1e3
			processTime: processTimeNoReq.toFixed(3)
			failed: failedReqCount
		}







