function parse_this(parseObjectId,targetName,showNags)
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $  $Date: 2004/04/15 00:58:59 $
if(nargin<2)
    targetName = 'sfun';
end
if(nargin<3)
    showNags = 'yes';
end
if(~isempty(sf('get',parseObjectId,'machine.id')))
    machineId = parseObjectId;
    chartId = [];
elseif(~isempty(sf('get',parseObjectId,'chart.id')))
    machineId = sf('get',parseObjectId,'chart.machine');
    chartId = parseObjectId;
end
autobuild(machineId,targetName,'parse','yes',showNags,chartId);


