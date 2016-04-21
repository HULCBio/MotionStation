function emlFcns = eml_fcns_in(objectId,allFlag)
if(nargin<2)
   allFlag = '';
end
emlFcns= [];
charts = unencrypted_charts_in(objectId,allFlag);
for i=1:length(charts)
  emlFcns = [emlFcns,eml_fcns_in_chart(charts(i))];
end

function emlFcns = eml_fcns_in_chart(chart)
    allStates = sf('get',chart,'chart.states');
    emlFcns = sf('find',allStates,'state.type','FUNC_STATE','state.eml.isEML',1);

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:57:22 $
