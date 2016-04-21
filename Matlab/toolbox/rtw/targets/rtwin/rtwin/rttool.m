function [varargout] = rttool(varargin)
%RTTOOL Call Real-Time Windows Target kernel directly.
%
%   RTTOOL('action',...) with possible other input and output parameters,
%   calls the Real-Time Windows Target kernel directly. This is normally not
%   needed, except for troubleshooting purposes.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $  $Date: 2004/04/15 00:29:59 $  $Author: batserve $

if exist('rtwinext')
  if nargout==0
    rtwinext(varargin{:});
  else
    [varargout{1:nargout}] = rtwinext(varargin{:});
  end
else
  error('RTWIN:unsupportedplatform','Real-Time Windows Target not available for this platform.');
end

