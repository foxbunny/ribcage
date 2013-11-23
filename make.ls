#!/usr/bin/env livescript

require! 'shelljs/make'
require! child_process.spawn

target.compile = ->
  run 'livescript -cbo lib src'

target.watch = ->
  run 'livescript -cbwo lib src'
  run 'livescript -cbwo tests/spec tests'

function run cmd
  cmd = cmd.split ' '
  spawn cmd.0, cmd[1 til], stdio: 'inherit'

