SPEC_PFX = /^\/base\/tests\/spec/

amdify = (.replace SPEC_PFX, 'tests' .replace '.js', '')

TESTS = [amdify f for f of window.__karma__.files when /test_.*\.js$/.test f]

require.config do
  base-url: 'base/tests/vendor'
  paths:
    backbone: 'exoskeleton'
    ribcage: '../../lib'
    tests: '../spec'
  deps: TESTS
  callback: __karma__.start
