function debugdlg(varargin),
%DEBUGDLG  Creates and manages the debugger dialog box

%   Vijay Raghavan
%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.10.2.1 $  $Date: 2004/04/15 00:56:41 $

if(nargin ==4)

	command = varargin{1};
	machineId = varargin{2};
	method = varargin{3};
	objectId = varargin{4};

	sfdebug('sf',method,machineId,objectId);
end



