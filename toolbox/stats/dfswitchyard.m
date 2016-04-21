function varargout = dfswitchyard(action,varargin)
% DFSWITCHYARD switchyard for Distribution Fitting.
% Helper function for the Distribution Fitting tool

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/01/24 09:33:21 $

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
