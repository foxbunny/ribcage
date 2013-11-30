#!/usr/bin/env livescript
require! 'shelljs/make'
require! path
require! fs
require! child_process.spawn

console.log

const node-path = 'node_modules/.bin'

target.compile = ->
  node 'livescript -cbo lib src'

target.watch = ->
  node 'livescript -cbwo lib src'
  node 'livescript -cbwo tests/spec tests'
  node 'karma start tests/karma.conf.js'

## Utility functions

function run cmd
  [cmd, ...args] = cmd.split ' '
  r = spawn cmd, args, stdio: \inherit
  r.on \error, ->
    process.stderr.write "ERR: Could not run command '#{cmd}'\n"

function node cmd
  [cmd, ...r] = cmd.split ' '
  cmd = path.join node-path, cmd
  if process.platform is \win32
    cmd = cmd + '.cmd'
  r.unshift cmd
  run r.join ' '

