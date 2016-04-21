% Called by GOPTRIC
%
% Removes plant singularities due to rank-deficiency of D12 or D21.
% Written for X, applies to Y by duality.
%
% No meant to be called by the user.
%
% See also   HINFRIC.

% Authors: P. Gahinet and A.J. Laub  10/93
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $



function [aX,b1X,c1X,b2X,d12X,Z12,sing12,u1]=...
                             rankreg(a,b1,c1,b2,d12,tolsing,toleig)


%  TOLSING determines the singular part of D12 by the constraint:
%                || B2 D12^+ || < 1/tolsing


% initialization
aX=a; b1X=b1; c1X=c1; b2X=b2; d12X=d12;
Z12=1; Z12p=[];
sing12=0;
na=size(a,1); m2X=size(d12,2); naX=na;


% find the SV of d12 greater than tolsing*b2*v column-wise and tolsing*|d12|
% (regular part of d12)
[u,s,v]=svd(d12X);
abstol=max(toleig*norm(b2X,1),tolsing*s(1,1));
ratio=max([s;zeros(1,size(s,2))])./...
      max([tolsing*abs(b2X*v);abstol*ones(1,size(b2X,2))]);
v1=v(:,find(ratio >= 1)); v2=v(:,find(ratio < 1)); r12=size(v1,2);
u1=u(:,find(ratio >= 1));



while r12 < m2X,          % regularization loop

   sing12=1;
   [w2,s,s,s,w1]=svdparts(b2X*v2,toleig*norm(b2X,1),tolsing);

   tmp=w1'*aX;   aX=tmp*w1;
   d12X=[c1X*w2,d12X*v1];    b2X=[tmp*w2,w1'*b2X*v1];
   c1X=c1X*w1;               b1X=w1'*b1X;

   % keep track of order reduction in first iteration
%   if naX==na, red12=na-size(aX,1); end

   naX=size(aX,1);           m2X=size(d12X,2);

   % ABORT if either w1 or w2 is void
   if naX==0 | isempty(w2), break; end

   Z12p=[Z12*w2,Z12p];   Z12=Z12*w1;

   [u,s,v]=svd(d12X);
   abstol=max(toleig*norm(b2X,1),tolsing*s(1,1));
   ratio=max([s;zeros(1,size(s,2))])./...
         max([tolsing*abs(b2X*v);abstol*ones(1,size(b2X,2))]);
   v1=v(:,find(ratio >= 1)); v2=v(:,find(ratio < 1));
   r12=size(v1,2);
end


Z12=[Z12,Z12p];  % orthogonal change of coordinates on X
