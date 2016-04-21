function varargout = daqguisgate(varargin)
%DAQGUISGATE Gateway routine to call softscope private functions.
%
%   [OUT1, OUT2,...] = DAQGUISGATE(FCN, VAR1, VAR2,...) calls FCN in 
%   the Data Acquisition Toolbox daqguis private directory with input 
%   arguments VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:44:35 $

if nargin == 0
   error('daqguis:daqguisgate:invalidSyntax', sprintf(['DAQGUISGATE is a gateway routine to the softscope',...
         '\nprivate functions and should not be directly called by users.']));
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end