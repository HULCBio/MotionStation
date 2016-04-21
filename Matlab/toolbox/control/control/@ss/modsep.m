function [H,H0,T,Ti] = modsep(G,N,RegionFcn,varargin)
%MODSEP  Region-based modal decomposition.
%
%   [H,H0] = MODSEP(G,N,REGIONFCN) decomposes the LTI model G into a 
%   sum of N simpler models Hj with their poles in disjoint regions Rj
%   of the complex plane:
%
%      G(s) = H0 +  sum   Hj(s) ,     pole(Hj) inside Rj
%                  j=1:N
%
%   G can be any LTI model created with SS, TF, or ZPK, and N is the 
%   number of regions used in the decomposition.  MODSEP packs the 
%   submodels Hj into an LTI array H and returns the static gain H0 
%   separately.  Use H(:,:,j) to retrieve the submodel Hj(s).
%
%   To specify the regions of interest, use a function of the form
%      IR = REGIONFCN(P)
%   that assigns a region index IR between 1 and N to a given pole P.
%   You can specify this function as a string or a function handle, and
%   use the syntax MODSEP(G,N,REGIONFCN,PARAM1,...) to pass extra input 
%   arguments: IR = REGIONFCN(P,PARAM1,...).
%
%   Example
%     To decompose G into G(z) = H0 + H1(z) + H2(z) where H1 and H2 
%     have their poles inside and outside the unit disk respectively,
%     use 
%        [H,H0]  = modsep(G,2,@udsep)
%     where the function UDSEP is defined by
%        function r = udsep(p)
%        if abs(p)<1, r = 1;  % assign r=1 to poles inside unit disk
%        else         r = 2;  % assign r=2 to poles outside unit disk
%        end
%     To extract H1(z) and H2(z) from the LTI array H, use 
%        H1 = H(:,:,1);  H2 = H(:,:,2);
%
%   See also STABSEP.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/10 23:13:29 $
[no,ni,nsys] = size(G.d);
if nsys>1
   error('Cannot be applied to multiple models at once.')
elseif N<=0
   error('Number of regions N must be a positive integer.')
end

% Extract data
% REVISIT: descriptor case will require generalized Sylvester solver (LAPACK)
[a,b,c,d] = ssdata(G);

% Balancing of A
[a,e,s,p] = aebalance(a,[]);
b(p,:) = lrscale(b,1./s,[]);  % T\b
c(:,p) = lrscale(c,[],s);     % c*T

% Schur decomposition
[u,a] = schur(a);
e = eig(a);
nx = length(e);

% Assign region index to each eigenvalue
try
   clusters = zeros(nx,1);
   for ct=1:nx
      clusters(ct) = round(feval(RegionFcn,e(ct),varargin{:}));
   end
catch 
   error('Invalid region-selecting function REGIONFCN.')
end
if any(clusters<1 | clusters>N)
   error('REGIONFCN must return region indices between 1 and N.')
end

% Go complex if A real but different regions are assigned to conjugate pairs
if isreal(a)
   idxp = find(imag(e)>0);
   [junk,ia,ib] = intersect(e,conj(e(idxp)));
   if any(clusters(ia)~=clusters(idxp(ib)))
      [u,a] = rsf2csf(u,a);
   end
end

% Sort eigenvalues by increasing region index
try
   [u,a] = ordschur(u,a,-clusters);
   b = u'*b;
   c = c*u;
catch
   error('Decomposition failed. Some poles are too close to the region boundaries.') 
end
clusters = sort(clusters);
if isempty(clusters)
   blksize = [];
else
   blksize = diff([0;find(diff(clusters));length(clusters)]);
end

% Block diagonalize
try
   [t,a] = bdschur(a,[],blksize);
catch
   % Should not happen
   rethrow(lasterror)
end
b = t\b;
c = c*t;

% Store results
L = G.lti;
set(L,'Notes',{},'UserData',[]);
H0 = ss(d,L);
H = ss(zeros(no,ni,N),L);
is = 0;
for j=1:length(blksize)
   % Store j-th component
   bs = blksize(j);
   jsys = clusters(is+1);
   H.a{jsys} = a(is+1:is+bs,is+1:is+bs);
   H.b{jsys} = b(is+1:is+bs,:);
   H.c{jsys} = c(:,is+1:is+bs);
   H.StateName(end+1:bs,:) = {''};
   is = is+bs;
end

% Construct block diagonalization state transformation T and its inverse Ti
% RE: The system with decoupled dynamics is ss2ss(G,T)
if nargout>2
   Ti(:,p) = diag(s);
   Ti = Ti * u * t;
   T(p,:) = diag(1./s);
   T = t \ (u' * T);
end