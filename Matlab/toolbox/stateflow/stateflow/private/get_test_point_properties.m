function tpProps = get_test_point_properties(sfBlkH)

% Copyright 2004 The MathWorks, Inc.

chart = block2chart(sfBlkH);
if isempty(chart) || ~sf('ishandle', chart)
  tpProps = {};
  return;
end

chartPath = sf('FullNameOf', chart, '/');

tps = test_points_in(chart);
numTps = length(tps);
tpProps = cell(numTps, 1);

entry = [];
for i = 1:numTps
  entry.id      = tps(i);
  entry.name    = sf('FullNameOf', entry.id, chart, '.');
  entry.logName = entry.name;
  entry.path    = sprintf('StateflowChart/%s', entry.logName);
  %entry.path    = sprintf('%s@Stateflow/%s', chartPath, entry.logName);
  entry.type    = '';

  tpProps{i} = entry;
end

return;
