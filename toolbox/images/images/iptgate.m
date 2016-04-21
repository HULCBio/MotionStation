function varargout = iptgate(varargin)
%IPTGATE Gateway routine to call private functions.
%   IPTGATE is used to access private functions. 
%
%   [OUT1, OUT2,...] = IPTGATE(FCN, VAR1, VAR2,...) calls FCN in
%   MATLABROOT/toolbox/images/images/private with input arguments
%   VAR1, VAR2,... and returns the output, OUT1, OUT2,....
 
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/01/26 05:56:36 $

if nargin == 0
    errID = sprintf('Images:%s:invalidNumberOfInputs', mfilename);
    msg = sprintf('There must be a function name as the first input'); 
    error(errID,'%s',msg);
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end
