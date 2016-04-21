function varargout = callSwitchyard(h,methodId,varargin)
% CALLSWITCHYARD Calls the curr_ccsmexswitchyard mex function.

% Copyright 2004 The MathWorks, Inc.

if nargout==0
    curr_ccsmexswitchyard(methodId,varargin{:});
else
    varargout{1} = curr_ccsmexswitchyard(methodId,varargin{:});
end

% [EOF] callSwitchyard.m