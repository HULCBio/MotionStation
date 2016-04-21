function varargout = daqgate(varargin)
%DAQGATE Gateway routine to call Data Acquisition Toolbox private functions.
%
%    [OUT1, OUT2,...] = DAQGATE(FCN, VAR1, VAR2,...) calls FCN in 
%    the Data Acquisition Toolbox private directory with input arguments
%    VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%

%    MP 6-01-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:40:45 $

if nargin == 0
   error('daq:daqgate:argcheck', 'DAQGATE is a gateway routine to the Data Acquistion Toolbox\nprivate functions and should not be directly called by users.');
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end

