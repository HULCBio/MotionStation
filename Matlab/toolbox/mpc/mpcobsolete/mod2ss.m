function [a,b,c,d,minfo,x0,u0,y0,f0]=mod2ss(mod)

%MOD2SS	Extract state-space matrices from "mod" form
% 	[phi,gam,c,d] = mod2ss(mod)
% 	[phi,gam,c,d,minfo] = mod2ss(mod)
% 	[phi,gam,c,d,minfo,x0,u0,y0,f0] = mod2ss(mod)
%
% Input:
%  mod: a plant model in the MPC mod format.
%
% Outputs:
%  phi,gam,c,d :  state-space model matrices.
%  minfo       :  ROW vector containing the following information:
%        minfo(1) = T, the sampling period.
%             (2) = n, the system order (dimension of A).
%             (3) = nu, the number of manipulated inputs.
%             (4) = nd, the number of measured disturbances.
%             (5) = nw, the number of unmeasured disturbances.
%             (6) = nym, the number of measured outputs.
%             (7) = nyu, the number of unmeasured outputs.
%
%  x0,u0,y0,f0 :  linearization data.
%
% See also ss2mod.

%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if nargin ~= 1
   disp('USAGE:  [phi,gam,c,d,minfo] = mod2ss(mod)')
   return
elseif ~isnan(mod(2,1))
   error('MOD does not appear to be in MPC MOD format')
end

minfo=mod(1,1:7);
n=minfo(2);             % system order
m=sum(minfo(3:5));      % total number of inputs
ny=sum(minfo(6:7));     % total number of outputs

ju=[n+2:n+m+1];         % points to columns related to inputs
iy=[n+2:n+ny+1];        % points to rows related to outputs

x0=zeros(n,1);          % initialize to default
f0=zeros(n,1);

% See whether MOD is in old or new format.  Depends on number
% of rows.

[nrow,ncol]=size(mod);
if nrow == n+ny+1
   newform=0;
elseif nrow == n+ny+2
   newform=1;
else
   mpcinfo(mod)
   error('Number of rows in MOD inconsistent with ns+ny in MINFO')
end

if newform
   u0=mod(n+ny+2,ju)';
   y0=mod(iy,n+m+2);
else
   u0=zeros(m,1);
   y0=zeros(ny,1);
end

if n > 0
   ix=[2:n+1];
   a=mod(ix,ix);
   b=mod(ix,ju);
   c=mod(iy,ix);
   if newform
      x0=mod(n+ny+2,ix)';
      f0=mod(ix,n+m+2);
   end
else
   a=zeros(n,n);
   b=zeros(n,m);
   c=zeros(ny,n);
end
d=mod(n+2:n+ny+1,n+2:n+m+1);