function result = grandfather( command, varargin )
% RESULT = GRANDFATHER( COMMAND, ... )

%	E. Mehran Mestchian
%  Copyright 1990-2002 The MathWorks, Inc.
%  $Revision: 1.7 $  $Date: 2002/03/23 02:59:03 $

result = [];
switch command
case 'isproperty' % propName
	% Add the list of all grandfathered properties to the switchyard below.
	propName = varargin{1};
	result = 1;
	switch propName
    case 'chart.decomposition'
	otherwise % property is not grandfathered
		result = 0;
		return;
	end
case 'get' % objId, propName
	objId = varargin{1};
	propName = varargin{2};
case 'set' % objId, propName, propValue
	objId = varargin{1};
	propName = varargin{2};
	propValue = varargin{3};
case 'preload' % fileName
	fileName = varargin{1};
case 'load' % objId, propValuePairs
	objId = varargin{1};
	propValuePairs = varargin{2};
case 'postload' % fileName, objects
	fileName = varargin{1};
	ids = varargin{2};		% ids of everything in machine are passed in
otherwise
	disp(sprintf('stateflow/private/grandfather: unknown command %s.',command));
end

