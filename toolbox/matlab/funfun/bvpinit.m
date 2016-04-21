function solinit = bvpinit(x,v,parameters,varargin)
%BVPINIT  Form the initial guess for BVP4C.
%   SOLINIT = BVPINIT(X,YINIT) forms the initial guess for BVP4C in common
%   circumstances. The boundary value problem (BVP) is to be solved on [a,b]. 
%   The vector X specifies a and b as X(1) = a and X(end) = b. It is also 
%   a guess for an appropriate mesh. BVP4C will adapt this mesh to the solution, 
%   so often a guess like X = linspace(a,b,10) will suffice, but in difficult 
%   cases, mesh points should be placed where the solution changes rapidly. 
%
%   The entries of X must be ordered. For two-point BVPs, the entries of X 
%   must be distinct, so if a < b, then X(1) < X(2) < ... < X(end), and 
%   similarly for a > b. For multipoint BVPs there are boundary conditions
%   at points in [a,b]. Generally, these points represent interfaces and 
%   provide a natural division of [a,b] into regions. BVPINIT enumerates 
%   the regions from left to right (from a to b), with indices starting 
%   from 1. You can specify interfaces by double entries in the initial 
%   mesh X. BVPINIT interprets oneentry as the right end point of region k 
%   and the other as the left end point of region k+1. THREEBVP exemplifies 
%   this for a three-point BVP.
%
%   YINIT provides a guess for the solution. It must be possible to evaluate 
%   the differential equations and boundary conditions for this guess. 
%   YINIT can be either a vector or a function:
%
%   vector:  YINIT(i) is a constant guess for the i-th component Y(i,:) of 
%            the solution at all the mesh points in X.
%
%   function:  YINIT is a function of a scalar x. For example, use 
%              solinit = bvpinit(x,@yfun) if for any x in [a,b], yfun(x) 
%              returns a guess for the solution y(x). For multipoint BVPs, 
%              BVPINIT calls Y = YINIT(X,K) to get an initial guess for the 
%              solution at x in region k. 
%                       
%   SOLINIT = BVPINIT(X,YINIT,PARAMETERS) indicates that the BVP involves 
%   unknown parameters. A guess must be provided for all parameters in the 
%   vector PARAMETERS. 
%
%   SOLINIT = BVPINIT(X,YINIT,PARAMETERS,P1,P2...) passes the additional
%   known parameters P1,P2,... to the guess function as YINIT(X,P1,P2...) or 
%   YINIT(X,K,P1,P2) for multipoint BVPs. Known parameters P1,P2,... can be
%   used only when YINIT is a function. When there are no unknown parameters,
%   use SOLINIT = BVPINIT(X,YINIT,[],P1,P2...). 
%
%   SOLINIT = BVPINIT(SOL,[ANEW BNEW]) forms an initial guess on the interval  
%   [ANEW,BNEW] from a solution SOL on an interval [a,b]. The new interval
%   must be bigger, so either ANEW <= a < b <= BNEW or ANEW >= a > b >= BNEW.
%   The solution SOL is extrapolated to the new interval. If present, the 
%   PARAMETERS from SOL are used in SOLINIT. To supply a different guess for 
%   unknown parameters use SOLINIT = BVPINIT(SOL,[ANEW BNEW],PARAMETERS).
%
%   See also BVPGET, BVPSET, BVP4C, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $  $Date: 2003/05/19 11:15:02 $

% Extend existing solution?
if isstruct(x)
  if nargin < 2 || length(v) < 2
    error('MATLAB:bvpinit:NoSolInterval',...
          'Did not specify [ANEW BNEW] in BVPINIT(SOL,[ANEW BNEW]).')
  elseif nargin < 3
    parameters = [];
  end   
  solinit = bvpxtrp(x,v,parameters);
  return;
end

% Create a guess structure.
N = length(x);
if x(1) == x(N)
  error('MATLAB:bvpinit:XSameEndPts',...
        'The entries of x must satisfy a = x(1) ~= x(end) = b.')    
elseif x(1) < x(N)
  if any(diff(x) < 0)
    error('MATLAB:bvpinit:IncreasingXNotMonotonic',...
          'The entries of x must satisfy a = x(1) < x(2) < ... < x(end) = b.')
  end
else  % x(1) > x(N)
  if any(diff(x) > 0)
    error('MATLAB:bvpinit:DecreasingXNotMonotonic',...
          'The entries of x must satisfy a = x(1) > x(2) > ... > x(end) = b.')
  end
end

if nargin>2
  params = parameters;
else
  params = [];
end

extraArgs = varargin;

mbcidx = find(diff(x) == 0);  % locate internal interfaces
ismbvp = ~isempty(mbcidx);  
if ismbvp
  Lidx = [1, mbcidx+1]; 
  Ridx = [mbcidx, length(x)];
end

if isnumeric(v) 
  w = v;
else
  if ismbvp
    w = feval(v,x(1),1,extraArgs{:});   % check region 1, only.
  else
    w = feval(v,x(1),extraArgs{:});
  end
end
[m,n] = size(w);
if m == 1
  L = n;
elseif n == 1
  L = m;
else
  error('MATLAB:bvpinit:SolGuessNotVector',...
        'The guess for the solution must return a vector.')
end

yinit = zeros(L,N);
if isnumeric(v)
  yinit = repmat(v(:),1,N);
else 
  if ismbvp
    for region = 1:nregions
      for i = Lidx(region):Ridx(region)
        w = feval(v,x(i),region,extraArgs{:});
        yinit(:,i) = w(:);
      end  
    end        
  else  
    yinit(:,1) = w(:);
    for i = 2:N
      w = feval(v,x(i),extraArgs{:});
      yinit(:,i) = w(:);
    end
  end  
end

solinit.x = x(:)';  % row vector
solinit.y = yinit;
if ~isempty(params)  
  solinit.parameters = params;
end

%---------------------------------------------------------------------------

function solxtrp = bvpxtrp(sol,v,parameters)
% Extend a solution SOL on [sol.x(1),sol.x(end)]
% to a guess for [v(1),v(end)] by extrapolation.

a = sol.x(1);
b = sol.x(end);
  
anew = v(1);
bnew = v(end);

if (a < b && (anew > a || bnew < b)) || ...
   (a > b && (anew < a || bnew > b))
    
  msg = sprintf(['The call BVPINIT(SOL,[ANEW BNEW]) must have\n',...
                'ANEW <= SOL.x(1) < SOL.x(end) <= BNEW  or \n',...
                'ANEW >= SOL.x(1) > SOL.x(end) >= BNEW. \n']);
  error('MATLAB:bvpinit:bvpxtrp:SolInterval', msg);            
   
end   
   
solxtrp.x = sol.x;
solxtrp.y = sol.y;
if abs(anew - a) <= 100*eps*max(abs(anew),abs(a))
    solxtrp.x(1) = anew;
else
    S = Hermite(sol.x(1),sol.y(:,1),sol.yp(:,1),...
                sol.x(2),sol.y(:,2),sol.yp(:,2),anew);
    solxtrp.x = [anew solxtrp.x];
    solxtrp.y = [S solxtrp.y];
end
if abs(bnew - b) <= 100*eps*max(abs(bnew),abs(b))
    solxtrp.x(end) = bnew;
else  
    S = Hermite(sol.x(end-1),sol.y(:,end-1),sol.yp(:,end-1),...
                sol.x(end),sol.y(:,end),sol.yp(:,end),bnew);
    solxtrp.x = [solxtrp.x bnew];
    solxtrp.y = [solxtrp.y S];
end

if ~isempty(parameters)
  solxtrp.parameters = parameters;
elseif isfield(sol,'parameters')
  solxtrp.parameters = sol.parameters;
end

%---------------------------------------------------------------------------

function S = Hermite(x1,y1,yp1,x2,y2,yp2,xi)
% Evaluate cubic Hermite interpolant at xi.
h = x2 - x1;
s = (xi - x1)/h;
A1 = (s - 1)^2 * (1 + 2*s);
A2 = (3 - 2*s)*s^2;
B1 = h*s*(s - 1)^2;
B2 = h*s^2 *(s - 1);
S = A1*y1 + A2*y2 + B1*yp1 + B2*yp2;


