colorizer = require('colorizer')
fs = require('fs')
utils = require('utils')
f = utils.format
includes = []
tests = []

formatBacktrace = (trace) ->
  formatted = []

  for e in trace 
    line = (!e.file ? "(casperjs)" : e.file) + ":" + e.line
    line = "#{line} in #{e.function}" if e.function

  formatted

casper = require('casper').create({
  exitOnError: false
})

# parse some options from cli
casper.options.verbose = casper.cli.get('direct') || false
casper.options.logLevel = casper.cli.get('log-level') || "error"

cls = 'Dummy'
casper.options.colorizerType = cls
casper.colorizer = colorizer.create(cls)

# test paths are passed as args
if (casper.cli.args.length)
  tests = casper.cli.args.filter (path) ->
    fs.isFile(path) || fs.isDirectory(path)
else
  console.log('No test files!')
  casper.exit(1)

# Redfine the runTest method to emit an event we can list to
casper.test.runTest = (testFile) ->
  @emit("test.started", testFile)
  @running = true; # this.running is set back to false with done()
  @exec(testFile)


# register listeners needed to capture events
# to generate results to pass back to Iridium
currentTest = {}
startTime = null

# Patch the test.done method to emit the done event
# so we can print test results in real time.
# This functionality should make it into the 1.0 release.
#
# It was added in this commit: 
# https://github.com/n1k0/casperjs/commit/4eee81406c1e672eec58ca8c80e336ab2863e988
casper.test.done = ->
  @emit('test.done')
  @running = false

casper.test.on 'test.started', (testFile) -> 
  startTime = (new Date()).getTime()
  currentTest = {}
  currentTest.assertions = 0
  currentTest.name = testFile

casper.test.on 'success', ->
  currentTest.assertions++

# remove the stock functionality so we can replace with ours
casper.removeAllListeners(['error'])

casper.on 'error', (error, trace) ->
  currentTest.error = true
  currentTest.backtrace = formatBacktrace(trace)
  currentTest.message = error
  @test.done()

casper.test.on 'fail', (failure) -> 
  if failure.type == 'uncaughtError'
    currentTest.error = true
    currentTest.message = failure.message
    currentTest.backtrace = ["#{failure.file}:#{failure.line}"]
  else
    currentTest.assertions++
    currentTest.failed = true
    currentTest.message = failure.type + ": " + (failure.message || failure.standard || "(no message was entered)")
    currentTest.backtrace = [failure.file]
    @done()

casper.test.on 'test.done', ->
  currentTest.time = (new Date().getTime()) - startTime
  console.log("<iridium>" + JSON.stringify(currentTest) + "</iridium>")

casper.test.on 'tests.complete', ->
  console.log("Tests complete!")
  casper.exit()

@casper = casper

# run all the suites
casper.test.runSuites.apply(casper.test, tests)
