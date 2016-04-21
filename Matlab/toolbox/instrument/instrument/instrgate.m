function varargout = instrgate(varargin)
%INSTRGATE Gateway routine to call Instrument Control Toolbox private functions.
%
%   [OUT1, OUT2,...] = INSTRGATE(FCN, VAR1, VAR2,...) calls FCN in 
%   the Instrument Control Toolbox private directory with input 
%   arguments VAR1, VAR2,... and returns the output, OUT1, OUT2,....
%

%   MP 7-13-99
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.8.2.3 $  $Date: 2004/01/16 20:01:35 $

if nargin == 0
   error('instrument:instrgate:invalidSyntax', sprintf(['INSTRGATE is a gateway routine to the Instrument Control',...
         ' Toolbox \nprivate functions and should not be directly called by users.']));
end

nout = nargout;
if nout==0,
   feval(varargin{:});
else
   [varargout{1:nout}] = feval(varargin{:});
end
