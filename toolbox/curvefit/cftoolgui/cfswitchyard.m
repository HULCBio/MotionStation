function varargout = cfswitchyard(action,varargin)
% CFSWITCHYARD switchyard for Curve Fitting.
% Helper function for the Curve Fitting tool

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $ $Date: 2004/02/01 21:38:56 $

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
