// Generated by LiveScript 1.2.0
var SPEC_PFX, amdify, TESTS, res$, f;
SPEC_PFX = /^\/base\/tests\/spec/;
amdify = function(it){
  return it.replace(SPEC_PFX, 'tests').replace('.js', '');
};
res$ = [];
for (f in window.__karma__.files) {
  if (/test_.*\.js$/.test(f)) {
    res$.push(amdify(f));
  }
}
TESTS = res$;
console.log(TESTS);
require.config({
  baseUrl: 'base/tests/vendor',
  paths: {
    backbone: 'exoskeleton',
    ribcage: '../../lib',
    tests: '../spec'
  },
  deps: TESTS,
  callback: __karma__.start
});