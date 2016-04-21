function [Tf,Ts] = idtscale(varargin)
%IDTSCALE finds good time scales for time responses.
%
%   [Tf,Ts] = IDTSCALE(m1,m2,...,mn)
%   mi are IDMODELS
%   Tf is a suitable final time and Ts is a suitable sampling time for
%   plotting step and impulse responses.
%
%   The  routine builds on LTI/TRANGE from the Control System Toolbox.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/12/02 16:42:55 $


% The test below is inhibeted to save time. The test should be done before the
% call.

% if ~exist('lti')
%     error('IDTSCALE requires the Control System Toolbox.')
% end

for kv = 1:length(varargin)
    varargin{kv}=ss(varargin{kv});
end
[t,f] = trange('step',[],[],varargin{:});
Tf = f(2);
tt = t{1}{1};
Ts = tt(2)-tt(1);
