function y = updownsample(x,N,str,varargin)
%UPDOWNSAMPLE Up- or down-sample input signal.
%   UPDOWNSAMPLE(X,N,STR) changes the sample rate of X by a factor
%   of N, as specifiedd by STR ('up' or 'down').
%
%   UPDOWNSAMPLE(X,N,STR,PHASE) specifies an optional sample offset.
%   PHASE must be an integer in the range [0, N-1].

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/15 01:09:03 $

error(nargchk(3,4,nargin));

% Shift dimension if necessary
[x,nshift] = shiftdim(x);

[phase, msg] = parseUpDnSample(str,N,varargin{:});
error(msg);

switch lower(str),
case 'down',
	% Perform the downsample
	y = x(phase:N:end, :);
case 'up',
	% Perform the upsample
	y = zeros(N*size(x,1),size(x,2));
	y(phase:N:end, :) = x;
end

y = shiftdim(y,-nshift);

% --------------------------------------------------------
function [phase, msg] = parseUpDnSample(str,N,varargin)
% parseUpDnSample Parse input arguments and perform error checking.

% Initialize output args.
phase = 0;
msg = '';

isTransposed=[];

if ( ~isnumeric(N) | (length(N) ~=1) | (fix(N) ~= N) | (N < 1) ),
   msg = [str,'sample factor must be a postive integer.'];
   return
end

if ~isempty(varargin),
   phase = varargin{1};
end

if ( (~isnumeric(phase)) | (fix(phase) ~= phase) | (phase > N-1) | (phase < 0)),
   msg = 'Offset must be from 0 to N-1.';
   return
end

phase = phase + 1; % Increase phase for 1-based indexing



% [EOF]
