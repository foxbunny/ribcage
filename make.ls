#!/usr/bin/env livescript

require! 'shelljs/make'
require! child_process.spawn

run = (cmd) -> spawn cmd[0], cmd[1..]

target.compile ->
  run 'livescript -cbwo . src'
