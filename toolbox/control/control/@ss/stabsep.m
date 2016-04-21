function [G1,G2,T,Ti] = stabsep(G,condt,mode,tol)
%STABSEP  Stable/unstable decomposition of LTI models.
%
%   [GS,GNS] = STABSEP(G,CONDMAX) decomposes the LTI model G 
%   into its stable and unstable parts
%      G = GS + GNS
%   where GS contains all stable modes that can be separated 
%   from the unstable modes in a numerically stable way, and
%   GNS contains the remaining modes.  GNS is always strictly 
%   proper.
%   
%   Use the optional input CONDMAX to control the condition 
%   number of the decoupling state transformation.  Increasing  
%   CONDMAX helps separate closeby stable and unstable modes 
%   at the expense of accuracy (see BDSCHUR for more details). 
%   By default CONDMAX=1e8.
%
%   [G1,G2] = STABSEP(G,CONDMAX,MODE,TOL) performs more general 
%   stable/unstable decompositions such that G1 includes all  
%   separable eigenvalues lying in one the following regions:
%
%       Mode         Continuous Time          Discrete Time
%        1       Re(s)<-TOL*max(1,|Im(s)|)     |z| < 1-TOL
%        2       Re(s)> TOL*max(1,|Im(s)|)     |z| > 1+TOL
%
%   The default values are MODE=1 and TOL=0.
%
%   See also MODSEP.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2003/01/07 19:32:43 $
ni = nargin;
no = nargout;
if no>3 && ~isa(G,'ss')
   error('Too many output arguments.')
end
isDiscrete = (isdt(G));
L = G.lti;
set(L,'Notes',{},'UserData',[]);

% Default values for parameters
if ndims(G)>2
   error('Not supported for arrays of models.')
elseif ni<2 || isempty(condt)
   condt = 1e8;
elseif condt<1
   error('Condition number of state transformation must be greater than one.')
end
if ni<3 || isempty(mode)
   mode = 1;
elseif ~any(mode==[1 2])
   error('Invalid mode value.')
end
if ni<4 || isempty(tol)
   tol = 0;
end

% Extract data
% REVISIT: descriptor case will require generalized Sylvester solver (LAPACK)
[a,b,c,d] = ssdata(G);
n = size(a,1);

% Balancing of A
[a,e,s,perm] = aebalance(a,[]);
b(perm,:) = lrscale(b,1./s,[]);  % T\b
c(:,perm) = lrscale(c,[],s);     % c*T

% Schur decomposition
[u,a] = schur(a);
b = u'*b;
c = c*u;

% Select poles to be assigned to G2
p = eig(a);
sgn = sign(1.5-mode);
if isDiscrete
   select = (sgn*(abs(p)-1)+tol>=0);
else
   select = (sgn*real(p)+tol*max(1,abs(imag(p)))>=0);
end
   
% Split unstable part from stable part
[t,a,blks] = esplit(a,condt,select);
b = t\b;
c = c*t;

% Build GS and GNS
indns = 1:blks(1);
inds = blks(1)+1:blks(1)+blks(2);
G1 = ss(a(inds,inds),b(inds,:),c(:,inds),d,L);
G2 = ss(a(indns,indns),b(indns,:),c(:,indns),zeros(size(d)),L);

% Construct block diagonalization state transformation T and its inverse Ti
if no>3
   Ti(:,perm) = diag(s);
   Ti = Ti * u * t;
   T(perm,:) = diag(1./s);
   T = t \ (u' * T);
end