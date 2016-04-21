function varargout = callSwitchyard(h,methodId,varargin)
% CALLSWITCHYARD Calls the prev_ccsmexswitchyard mex function.

% Copyright 2004 The MathWorks, Inc.

if nargout==0
    prev_ccsmexswitchyard(methodId,varargin{:});
else
    varargout{1} = prev_ccsmexswitchyard(methodId,varargin{:});
end

% [EOF] callSwitchyard.m