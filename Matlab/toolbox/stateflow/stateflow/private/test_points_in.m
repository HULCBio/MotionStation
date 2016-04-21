function testPoints = test_points_in(chart)

% Copyright 2003-2004 The MathWorks, Inc.

machine = sf('get', chart, '.machine');
target = acquire_target(machine, 'sfun');
codingDebug = target_code_flags('get', target, 'debug');

tp = sf('TestPointsIn', chart, codingDebug);
testPoints = [tp.data tp.state];

return;
