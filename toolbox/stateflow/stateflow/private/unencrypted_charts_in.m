function charts = unencrypted_charts_in(objectId,allFlag)

% Copyright 2003 The MathWorks, Inc.

if(nargin<2)
   allFlag = '';
end

if(~isempty(sf('get',objectId,'chart.id')))
   charts = objectId;
elseif(~isempty(sf('get',objectId,'machine.id')))
   charts = sf('get',objectId,'machine.charts');
end
if(isempty(allFlag))
   charts = sf('find',charts,'chart.encryption.enabled',0);
end