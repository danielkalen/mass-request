util = require 'util'
Promise = require 'bluebird'
axios = require 'axios'
extend = require 'smart-extend'
defaults = 
	times: 5
	maxFailed: 100
	milestone: 100
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
	task = new Task()

	makeRequest = ()->
		reqStartTime = Date.now()
		task.emit('request', ++reqCount)
		task.emit('milestone', reqCount) if reqCount % options.milestone is 0
		
		axios.get(options.url)
			.then (res)->
				reqEndTime = Date.now()
				totalReqTime += reqEndTime-reqStartTime
				task.emit('response', "#{res.status} #{res.statusText} (#{reqEndTime-reqStartTime}ms)")

				if reqCount < options.times
					Promise.delay(options.delay).then(makeRequest)
			
			.catch (err)->
				if ++failedReqCount >= options.maxFailed
					Promise.reject(new Error "Too many failed requests (#{failedReqCount} failures)")
				else
					task.emit('failure', failedReqCount, reqCount)
					reqCount--
					Promise.delay(options.delay).then(makeRequest)


	task.init makeRequest().then ()->
		processTime = process.hrtime(processStartTime)
		processTime = processTime[0]+processTime[1]/1e9
		processTimeNoReq = processTime - totalReqTime/1e3
		return {
			totalTime: processTime.toFixed(3)
			requestTime: totalReqTime/1e3
			processTime: processTimeNoReq.toFixed(3)
			failed: failedReqCount
		}



class Task extends require('events')
	init: (@task)->
		@taskPromise = Promise.resolve(@task)
		return @
	
	then: ()-> @taskPromise.then(arguments...)
	catch: ()-> @taskPromise.catch(arguments...)


