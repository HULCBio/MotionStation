function rtclear(varargin)
%RTCLEAR Clear Real-Time Windows Target kernel process.
%
%   RTCLEAR stops all kernel processes and frees memory associated with them.
%   RTCLEAR ALL does the same.
%   These commands can be used as an emergency stop function from the MATLAB
%   command line.
%
%   RTCLEAR(T) clears single process T.
%   RTCLEAR(T1,T2,T3,...) clears multiple processes at a time.
%   These commands are useful for troubleshooting purposes only.

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 18:53:23 $  $Author: batserve $

if nargin==0
  rttool('Clear');
elseif strcmp(varargin{1},'all')
  rttool('Clear');
else
  for i=1:nargin;
    rttool('Clear',varargin{i});
  end;
end;


