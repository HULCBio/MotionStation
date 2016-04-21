function [newx]=mpc_chkx0u1(x,nx,xdefault,name)

%MPC_CHKX0U1 Check if x0 or u1 is ok.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2003/12/04 01:37:19 $   

if ~isa(x,'double'),
   error('mpc:mpc_chkx0u1:real',[name ' must a real valued vector.']);
end
if isempty(x),
   newx=xdefault;
   return
end

x=x(:);
l=length(x);
if l~=nx,
   error('mpc:mpc_chkx0u1:size',sprintf('%s must be a vector of length %d.',name,nx));
end
newx=x;

%end mpc_chkx0u1
