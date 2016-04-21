function [poles]=smpcpole(mod)

%SMPCPOLE Calculate poles for plant model in the MPC format.
% 	[poles]=smpcpole(mod)
%
% Input:
%  mod     :  is a plant model in the MPC mod format.
%
% Output:
%  poles   :  is the vector of complex values - poles
%
% See also SMPCGAIN.

%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin == 0,
   disp('Usage: poles=smpcpole(mod)');
   return
end
[a,b,c,d]=mod2ss(mod);
poles=eig(a);

% end of function SMPCPOLE.M