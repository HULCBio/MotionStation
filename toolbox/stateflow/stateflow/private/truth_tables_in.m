function ttFcns = truth_tables_in(objectId)
ttFcns = [];
charts = unencrypted_charts_in(objectId);
for i=1:length(charts)
  ttFcns = [ttFcns,truth_tables_in_chart(charts(i))];
end

function ttFcns = truth_tables_in_chart(chart)
    allStates = sf('get',chart,'chart.states');
    ttFcns = sf('find',allStates,'state.type','FUNC_STATE','state.truthTable.isTruthTable',1);

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 01:01:17 $
