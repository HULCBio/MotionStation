function [dFdy,fac,g,nfevals,nfcalls] = ...
    numjac(F,t,y,Fty,thresh,fac,vectorized,S,g,varargin)
%NUMJAC Numerically compute the Jacobian dF/dY of function F(T,Y).
%   [DFDY,FAC] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED) numerically
%   computes the Jacobian of function F(T,Y), returning it as full matrix
%   DFDY.  T is the independent variable and column vector Y contains the
%   dependent variables. Function F must return a column vector. Vector FTY
%   is F evaluated at (T,Y). Column vector THRESH provides a threshold of
%   significance for Y, i.e. the exact value of a component Y(i) with
%   abs(Y(i)) < THRESH(i) is not important. All components of THRESH must
%   be positive. Column FAC is working storage. On the first call, set 
%   FAC to []. Do not alter the returned value between calls. VECTORIZED
%   tells NUMJAC whether multiple values of F can be obtained with a single
%   function evaluation. In particular, VECTORIZED=1 indicates that  
%   F(t,[y1 y2 ...]) returns [F(t,y1) F(t,y2) ...], and VECTORIZED=2 that
%   F([x1 x2 ...],[y1 y2 ...]) returns [F(x1,y1) F(x2,y2) ...]. When solving
%   ODEs, use ODESET to set the ODE solver 'Vectorized' property to 'on' if
%   the ODE function has been coded so that F(t,[y1 y2 ...]) returns 
%   [F(t,y1) F(t,y2) ...]. When solving BVPs, use BVPSET to set the BVP
%   solver 'Vectorized' property to 'on' if the ODE function has been coded
%   so that F([x1 x2 ...],[y1 y2 ...]) returns [F(x1,y1) F(x2,y2) ...].  
%   Vectorizing the function F may speed up the computation of DFDY.
%   
%   [DFDY,FAC,G] = NUMJAC(F,T,Y,FTY,THRESH,FAC,VECTORIZED,S,G) numerically
%   computes a sparse Jacobian matrix DFDY.  S is a non-empty sparse matrix
%   of 0's and 1's.  A value of 0 for S(i,j) means that component i of the
%   function F(T,Y) does not depend on component j of vector Y (hence
%   DFDY(i,j) = 0).  Column vector G is working storage.  On the first call,
%   set G to [].  Do not alter the returned value between calls.
%   
%   [DFDY,FAC,G,NFEVALS,NFCALLS] = NUMJAC(...) returns the number of values
%   F(T,Y) computed while forming dFdy (NFEVALS) and the number of calls 
%   to the function F (NFCALLS). If F is not vectorized, NFCALLS equals 
%   NFEVALS. 
%
%   Although NUMJAC was developed specifically for the approximation of
%   partial derivatives when integrating a system of ODE's, it can be used
%   for other applications.  In particular, when the length of the vector
%   returned by F(T,Y) is different from the length of Y, DFDY is
%   rectangular.
%   
%   See also COLGROUP, ODE15S, ODE23S, ODE23T, ODE23TB, ODESET.

%   NUMJAC is an implementation of an exceptionally robust scheme due to
%   Salane for the approximation of partial derivatives when integrating 
%   a system of ODEs, Y' = F(T,Y). It is called when the ODE code has an
%   approximation Y at time T and is about to step to T+H.  The ODE code
%   controls the error in Y to be less than the absolute error tolerance
%   ATOL = THRESH.  Experience computing partial derivatives at previous
%   steps is recorded in FAC.  A sparse Jacobian is computed efficiently 
%   by using COLGROUP(S) to find groups of columns of DFDY that can be
%   approximated with a single call to function F.  COLGROUP tries two
%   schemes (first-fit and first-fit after reverse COLAMD ordering) and
%   returns the better grouping.
%   
%   D.E. Salane, "Adaptive Routines for Forming Jacobians Numerically",
%   SAND86-1319, Sandia National Laboratories, 1986.
%   
%   T.F. Coleman, B.S. Garbow, and J.J. More, Software for estimating
%   sparse Jacobian matrices, ACM Trans. Math. Software, 11(1984)
%   329-345.
%   
%   L.F. Shampine and M.W. Reichelt, The MATLAB ODE Suite, SIAM Journal on
%   Scientific Computing, 18-1, 1997.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-28-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.35.4.4 $  $Date: 2004/04/16 22:05:27 $

% Deal with missing arguments.
if nargin < 10
  args = {};                          % F accepts only (t,y)
  
  if nargin == 7
    S = [];
  elseif nargin == 6
    S = [];
    vectorized = 0;
  elseif nargin == 5
    S = [];
    vectorized = 0;
    fac = [];
  end
else
  args = varargin;
end

% Initialize.
br = eps ^ (0.875);
bl = eps ^ (0.75);
bu = eps ^ (0.25);
facmin = eps ^ (0.78);
facmax = 0.1;
ny = length(y);
nF = length(Fty);
if isempty(fac)
  fac = sqrt(eps) + zeros(ny,1);
end

% Select an increment del for a difference approximation to
% column j of dFdy.  The vector fac accounts for experience
% gained in previous calls to numjac.
yscale = max(abs(y),thresh);
del = (y + fac .* yscale) - y;
for j = find(del == 0)'
  while 1
    if fac(j) < facmax
      fac(j) = min(100*fac(j),facmax);
      del(j) = (y(j) + fac(j)*yscale(j)) - y(j);
      if del(j)
        break
      end
    else
      del(j) = thresh(j);
      break;
    end
  end
end
if nF == ny
  s = (sign(Fty) >= 0);
  del = (s - (~s)) .* abs(del);         % keep del pointing into region
end

% Form a difference approximation to all columns of dFdy.
if isempty(S)                           % generate full matrix dFdy
  g = [];
  ydel = y(:,ones(1,ny)) + diag(del);
  switch vectorized
   case 1
    Fdel = feval(F,t,ydel,args{:});
    nfcalls = 1;                        % stats
   case 2
    Fdel = feval(F,t(ones(1,ny)),ydel,args{:});
    nfcalls = 1;                        % stats 
   otherwise % not vectorized
    Fdel = zeros(nF,ny);
    for j = 1:ny
      Fdel(:,j) = feval(F,t,ydel(:,j),args{:});
    end
    nfcalls = ny;                       % stats     
  end
  nfevals = ny;                         % stats (at least one per loop)
  Fdiff = Fdel - Fty(:,ones(1,ny));
  dFdy = Fdiff * diag(1 ./ del);
  [Difmax,Rowmax] = max(abs(Fdiff),[],1);
  % If Fdel is a column vector, then index is a scalar, so indexing is okay.
  absFdelRm = abs(Fdel((0:ny-1)*nF + Rowmax));
else                                    % sparse dFdy with structure S
  if isempty(g)
    g = colgroup(S);                    % Determine the column grouping.
  end
  ng = max(g);
  one2ny = (1:ny)';
  ydel = y(:,ones(1,ng));
  i = (g-1)*ny + one2ny;
  ydel(i) = ydel(i) + del;  
  switch vectorized
   case 1
    Fdel = feval(F,t,ydel,args{:});
    nfcalls = 1;                        % stats 
   case 2
    Fdel = feval(F,t(ones(1,ng)),ydel,args{:});
    nfcalls = 1;                        % stats 
   otherwise % not vectorized
    Fdel = zeros(nF,ng);
    for j = 1:ng
      Fdel(:,j) = feval(F,t,ydel(:,j),args{:});
    end
    nfcalls = ng;                       % stats
  end
  nfevals = ng;                         % stats (at least one per column)
  Fdiff = Fdel - Fty(:,ones(1,ng));
  [i j] = find(S);
  Fdiff = sparse(i,j,Fdiff((g(j)-1)*nF + i),nF,ny);
  dFdy = Fdiff * sparse(one2ny,one2ny,1 ./ del,ny,ny);
  [Difmax,Rowmax] = max(abs(Fdiff),[],1);
  Difmax = full(Difmax);
  % If ng==1, then Fdel is a column vector although index may be a row vector.
  absFdelRm = abs(Fdel((g-1)*nF + Rowmax').');
end  

% Adjust fac for next call to numjac.
absFty = abs(Fty);
absFtyRm = absFty(Rowmax);              % not a col vec if absFty scalar
absFtyRm = absFtyRm(:)';                % ensure that absFtyRm is a row vector
j = ((absFdelRm ~= 0) & (absFtyRm ~= 0)) | (Difmax == 0);
if any(j)
  ydel = y;
  Fscale = max(absFdelRm,absFtyRm);

  % If the difference in f values is so small that the column might be just
  % roundoff error, try a bigger increment. 
  k1 = (Difmax <= br*Fscale);           % Difmax and Fscale might be zero
  for k = find(j & k1)
    tmpfac = min(sqrt(fac(k)),facmax);
    del = (y(k) + tmpfac*yscale(k)) - y(k);
    if (tmpfac ~= fac(k)) && (del ~= 0)
      if nF == ny
        if Fty(k) >= 0                  % keep del pointing into region
          del = abs(del);
        else
          del = -abs(del);
        end
      end
        
      ydel(k) = y(k) + del;
      fdel = feval(F,t,ydel,args{:});
      nfevals = nfevals + 1;            % stats
      nfcalls = nfcalls + 1;            % stats
      ydel(k) = y(k);
      fdiff = fdel - Fty;
      tmp = fdiff ./ del;
      
      [difmax,rowmax] = max(abs(fdiff));
      if tmpfac * norm(tmp,inf) >= norm(dFdy(:,k),inf);
        % The new difference is more significant, so
        % use the column computed with this increment.
        if isempty(S)
          dFdy(:,k) = tmp;
        else
          i = find(S(:,k));
          if ~isempty(i)
            dFdy(i,k) = tmp(i);
          end
        end
  
        % Adjust fac for the next call to numjac.
        fscale = max(abs(fdel(rowmax)),absFty(rowmax));
          
        if difmax <= bl*fscale
          % The difference is small, so increase the increment.
          fac(k) = min(10*tmpfac, facmax);
          
        elseif difmax > bu*fscale
          % The difference is large, so reduce the increment.
          fac(k) = max(0.1*tmpfac, facmin);

        else
          fac(k) = tmpfac;
            
        end
      end
    end
  end
  
  % If the difference is small, increase the increment.
  k = find(j & ~k1 & (Difmax <= bl*Fscale));
  if ~isempty(k)
    fac(k) = min(10*fac(k), facmax);
  end

  % If the difference is large, reduce the increment.
  k = find(j & (Difmax > bu*Fscale));
  if ~isempty(k)
    fac(k) = max(0.1*fac(k), facmin);
  end
end
