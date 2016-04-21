function [t,b,blks] = esplit(a,condt,select)
%ESPLIT  Splits A into blkdiag(A1,A2) where A1 contains all 
%        selected eigenvalues, plus non-selected eigenvalues
%        that cannot be safely broken of the A1 cluster.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:14:54 $

n = size(a,1);
if ~any(select)
   b = a;
   t = eye(n);
   blks = [0 ; n];
   return
end
   
% Number of eigenvalues assigned to A11 (initially)
cs = sum(select);
tmax = sqrt(condt);

% If needed, reorder to push selected eigs into upper left corner
if any(diff(select)>0)
   [u,a] = ordschur([],a,select);
else 
   u = eye(n);
end
cmf = [true(cs,1) ; false(n-cs,1)];
e = eig(a);

% Try splitting
sw = warning('off'); lw = lastwarn;
try
   [t,b] = bdschur(a,[],[cs n-cs]);
catch
   % Should never happen
   t = Inf;
end
while max(abs(t(:)))>tmax
   % Grow cluster by absorbing eigs closest to current cluster
   cmf = LocalNearestNeighborExpand(e,cs);
   cs = sum(cmf);
   if cs==n
      break;
   end
   if any(diff(cmf)>0)
      [u,a] = ordschur(u,a,cmf);
      e = [e(cmf) ; e(~cmf)];
   end
   % Try separating
   try
      [t,b] = bdschur(a,[],[cs n-cs]);
   catch
      t = Inf;
   end
end
lastwarn(lw); warning(sw);

if cs==n
   t = u;
   b = a;
   blks = [n ; 0];
else
   t = u * t;
   blks = [cs ; n-cs];
end


%--------------- Local Function ------------------

function cmf = LocalNearestNeighborExpand(e,cs)
e1 = e(1:cs);
e2 = e(cs+1:end);
% Find eigenvalues closest to current cluster
[e1opt,e2opt] = LocalMinDistPairing(e1,e2);
rho = abs(e1opt-e2opt);
% New cluster membership function
% REVISIT: real data only!
cmf = [true(cs,1) ; (abs(e1opt-e2)<=rho | abs(conj(e1opt)-e2)<=rho)];

function [e1,e2] = LocalMinDistPairing(e1,e2)
% Min distance pairing
e2 = e2.';
d = abs(e1(:,ones(1,length(e2)))-e2(ones(1,length(e1)),:));
[dmin,I] = min(d,[],1);
[junk,J] = min(dmin);
e1 = e1(I(J));
e2 = e2(J);
