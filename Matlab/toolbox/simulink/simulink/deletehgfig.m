function deletehgfig(varargin)
% This is function used by SIMULINK to delete any Handle Graphics figure
% which was created by SIMULINK.
  
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2002/04/10 18:26:30 $
  
if nargin ~= 1 | nargout > 0
  error('Invalid call to function DELETEHGFIG.');
end

figHdl = varargin{1};

if ishandle(figHdl)
  delete(figHdl);
end

% end deletehgfig

% [EOF]