function newmod=mod2mod(oldmod,T)

% MOD2MOD Change sampling period of model in MPC toolbox MOD format
%  	newmod=mod2mod(oldmod,delt2)
%
% Inputs:
%  oldmod  is existing model in MPC toolbox MOD format
%  delt2   is desired new sampling period
%
% Output:
%  newmod  is model obtained by converting "oldmod" to
%          sampling period "delt2".  It will also be in the
%          MOD format.
%
% See also SS2MOD.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin ~= 2
   disp('USAGE:  newmod=mod2mod(oldmod,delt2)')
   return
end

[a,b,c,d,minfo]=mod2ss(oldmod);

% Convert back to continuous time, then return to discrete
% using new sampling period.

[a,b]=d2cmp(a,b,minfo(1));
[a,b]=c2dmp(a,b,T);
minfo(1)=T;
newmod=ss2mod(a,b,c,d,minfo);