function rsys = modred(sys,elim,method)
%MODRED  Model state reduction.
%
%   RSYS = MODRED(SYS,ELIM) reduces the order of the state-space model 
%   SYS by eliminating the states specified in vector ELIM.  The full 
%   state vector X is partitioned as X = [X1;X2] where X2 is to be 
%   discarded, and the reduced state is set to Xr = X1+T*X2 where T is 
%   chosen to enforce matching DC gains (steady-state response) between 
%   SYS and RSYS.
%
%   ELIM can be a vector of indices or a logical vector commensurate
%   with X where TRUE values mark states to be discarded.  Use BALREAL to 
%   first isolate states with negligible contribution to the I/O response.
%   If SYS has been balanced with BALREAL and the vector G of Hankel
%   singular values has M small entries, you can use MODRED to eliminate 
%   the corresponding M states.
%   Example:
%      [sys,g] = balreal(sys)   % compute balanced realization
%      elim = (g<1e-8)          % small entries of g -> negligible states
%      rsys = modred(sys,elim)  % remove negligible states
%
%   RSYS = MODRED(SYS,ELIM,METHOD) also specifies the state elimination
%   method.  Available choices for METHOD include
%      'MatchDC' :  Enforce matching DC gains (default)
%      'Truncate':  Simply delete X2 and sets Xr = X1.
%   The 'Truncate' option tends to produces a better approximation in the
%   frequency domain, but the DC gains are not guaranteed to match.
%
%   See also BALREAL, SS.

%   J.N. Little 9-4-86
%   Revised: P. Gahinet 10-30-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14.4.2 $  $Date: 2003/01/07 19:32:41 $

ni = nargin;
if ni<2
   error('Incorrect number of inputs.')
elseif ni==3 && ischar(method) && any(method(1)=='mdt')
   % Make sure to trap old keywords 'mdc' and 'del'
   if method(1)=='m'
      method = 'MatchDC';
   else
      method = 'Truncate';
   end
else
   method = 'MatchDC';  % default
end
rsys = sys;

% Unpack data
if ndims(sys)>2,
   error('MODRED is not applicable to arrays of state-space models.')
end
[a,b,c,d,Ts] = ssdata(sys);
ns = size(a,1);
if ns==0,
   return
end

% ELIM
if isa(elim,'logical')
   elim = find(elim);
end
elim = elim(:);

% Form KEEP vector:
if any(diff(sort(elim))==0) || any(elim<0) || any(elim>ns)
   error('Some index in ELIM is out of range or appears multiple times.')
end
keep = 1:ns;
keep(elim) = [];

% Handle two cases
switch method
   case 'MatchDC'
      % Matched DC gains: partition into x1, to be kept, and x2, to be eliminated:
      a11 = a(keep,keep);
      a12 = a(keep,elim);
      a21 = a(elim,keep);
      a22 = a(elim,elim);
      b1  = b(keep,:);
      b2  = b(elim,:);
      c1  = c(:,keep);
      c2  = c(:,elim);
      n2 = length(elim);
      
      % Form reduced matrices
      tolsing = eps^0.75;
      if Ts~=0,
         % Discrete-time system
         a22 = a22 - eye(n2);
      end
      [l,u,p] = lu(a22);
      norm11 = norm(a11,1);
      if norm(a22,1)>tolsing*norm11 && rcond(u)>tolsing,
         % Proceed
         A21 = (u\(l\(p*a21)));
         B2 = (u\(l\(p*b2)));
         ar = a11 - a12 * A21;
         br = b1 - a12 * B2;
         cr = c1 - c2 * A21;
         dr = d - c2 * B2;
      else
         % Use pseudo-inverse pinv(a22)
         [u,s,v] = svd(a22);
         s = diag(s(1:n2,1:n2));
         nnz = sum(s > tolsing * max([s;norm11]));
         u = u(:,1:nnz);
         v = v(:,1:nnz);
         s = s(1:nnz);
         A21 = diag(1./s) * u' * a21;
         B2 = diag(1./s) * u' * b2;
         A12 = a12 * v;
         C2 = c2 * v;
         ar = a11 - A12 * A21;
         br = b1 - A12 * B2;
         cr = c1 - C2 * A21;
         dr = d - C2 * B2;
      end
      
   case 'Truncate'
      % Simply delete specified states
      ar = a(keep,keep);
      br = b(keep,:);
      cr = c(:,keep);
      dr = d;    
end

% Build output
rsys.a = {ar};
rsys.b = {br};
rsys.c = {cr};
rsys.d = dr;
rsys.StateName = sys.StateName(keep);

