function varargout = gadsswitchyard(action,varargin)
% GADSSWITCHYARD switchyard for Genetic Algorithm and Direct Search.
% Helper function for the Genetic Algorithm and Direct Search tool

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2004/01/16 16:51:46 $

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
