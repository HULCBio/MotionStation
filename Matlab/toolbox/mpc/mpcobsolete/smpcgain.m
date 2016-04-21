function g=smpcgain(mod)

%SMPCGAIN Calculate the steady state gain matrix for "mod"
%  	g=smpcgain(mod)
%
% Input:
%  mod    : plant model in the MPC mod format;
%           must be open-loop stable
%
% Output:
%  g      : matrix in which the rows correspond to the outputs
%            and the columns to the inputs
%
% See also SMPCPOLE.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: g=smpcgain(mod)');
   return
end
[a,b,c,d]=mod2ss(mod);
if any(abs(eig(a)) >= 1)
    error('Model is open-loop unstable')
else
   g=c*inv(eye(size(a))-a)*b+d;
end

% end of function SMPCGAIN.M