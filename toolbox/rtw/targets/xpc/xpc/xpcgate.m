function varargout = xpcgate(varargin)

% XPCGATE - Gateway function to call xPC Target private functions.
%
%    [OUT1, OUT2,...] = XPCGATE(FCN, VAR1, VAR2,...) calls FCN in 
%    the xPC Target private directory with input arguments
%    VAR1, VAR2,... and returns the output, OUT1, OUT2,....

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.5 $ $Date: 2002/03/25 04:22:52 $

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end

