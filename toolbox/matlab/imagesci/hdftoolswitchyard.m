function varargout = hdftoolswitchyard(action,varargin)
%HDFTOOLSWITCHYARD for HDFTOOL

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:24 $

% Calls from Java prefer the if/else version.
% [varargout{1:max(nargout,1)}]=feval(action,varargin{:});
if nargout==0
	feval(action,varargin{:});
else    
	[varargout{1:nargout}]=feval(action,varargin{:});
end
