nopt = require 'nopt'
path = require 'path'
{log, deepExtend} = require './utils'

exports.VERSION = VERSION = require('../package.json').version

exports.DEFAULT_OPTIONS = DEFAULT_OPTIONS =
  verbose: false
  debug: false
  force: false
  cache: true
  check: false
  colors: true
  delay: 500
  threads: 5
  retries: 3
  startAt: 0
  limit: 0  # Unlimited
  'retry-factor': 2
  'refresh-db': false
  'refresh-photos': false

longOptions =
  version: Boolean
  help: Boolean
  verbose: Boolean
  debug: Boolean
  colors: Boolean
  cache: Boolean
  check: Boolean
  force: Boolean
  delay: Number
  retries: Number
  threads: Number
  startAt: Number
  limit: Number
  'retry-factor': Number
  'refresh-db': Boolean
  'refresh-photos': Boolean

shortOptions =
  v: [ '--version' ]
  h: [ '--help' ]
  d: [ '--delay' ]
  D: [ '--debug' ]
  c: [ '--cache' ]
  C: [ '--check' ]
  f: [ '--force' ]
  l: [ '--limit' ]
  r: [ '--retries' ]
  s: [ '--startAt' ]
  t: [ '--threads' ]
  nc: [ '--no-colors' ]
  rf: [ '--retry-factor' ]
  rd: [ '--refresh-db' ]
  rp: [ '--refresh-photos' ]

showVersion = ->
  log "tumblrip version #{VERSION}\n"
  0

showHelp = ->
  log HELP+'\n'
  0

HELP = """
tumblrip #{VERSION}
usage: tumblrip [options] blogname [destination]

http://<blogname>.tumblr.com/ will have photos retrieved to destination.
If a `destination` is supplied and the path does not exist, it will be created.
If no destination set, current directory is assumed.

options:
  --version [-v]            : display version/build
  --help [-h]               : this help
  --delay [-d]              : add a delay (in ms) between requests
                            : (default: #{DEFAULT_OPTIONS['delay']}, empty: random)
  --debug [-D]              : enable more debug output (default: #{DEFAULT_OPTIONS['debug']})
  --cache [-c]              : enable/disable cache (default: #{DEFAULT_OPTIONS['cache']})
  --check [-C]              : enforce additional consistency checks (slower) (default: #{DEFAULT_OPTIONS['check']})
  --force [-f]              : force overwrite if file exists (default: #{DEFAULT_OPTIONS['force']})
  --limit [-l]              : download that many pictures (default: unlimited)
  --retries [-r]            : number of retries before giving up (default: #{DEFAULT_OPTIONS['retries']})
  --threads [-t]            : maximum simultaneous connections to tumblr.com
                            : (default: #{DEFAULT_OPTIONS['threads']})
  --retry-factor [-rf]      : if throttling, multiply delay by this factor
                            : (default: #{DEFAULT_OPTIONS['retry-factor']})
  --refresh-db [-rd]        : update database (default: #{DEFAULT_OPTIONS['refresh-db']})
  --refresh-photos [-rp]    : update photos (default: #{DEFAULT_OPTIONS['refresh-photos']})
  --startAt [-s]            : start at a specific index in the posts database
                            : (default: #{DEFAULT_OPTIONS['startAt']})
"""

# Parse command line arguments and define global options.
exports.parse = ->
  # Take default options and update them with command line arguments
  options = deepExtend {}, DEFAULT_OPTIONS, nopt longOptions, shortOptions

  # We directly expose options to other modules
  deepExtend exports, options

  # We need to do this to avoid circular reference between this module and the
  # log module. Chicken and egg problem.
  log.verbose = options.verbose
  log.DEBUG = options.debug
  log.colors = options.colors

  return showHelp() if options.help
  return showVersion() if options.version

  {remain} = options.argv

  switch remain.length
    when 1
      exports.blogname = remain[0]
      exports.dest = '.'
    when 2
      exports.blogname = remain[0]
      exports.dest = remain[1]
    else
      return showHelp()

  options
