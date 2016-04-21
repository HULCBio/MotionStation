function [x0,y0] = fplot(varargin)
%FPLOT  Plot function specified by string.
%   FPLOT(FUN,LIMS) plots the function FUN between the x-axis limits
%   specified by LIMS = [XMIN XMAX].  Using LIMS = [XMIN XMAX YMIN
%   YMAX] also controls the y-axis limits.  The function FUN(x) must
%   return a row vector for each element of vector x.  For example, if
%   FUN returns [f1(x),f2(x),f3(x)] then for input [x1;x2] the
%   function should return the matrix
%
%       f1(x1) f2(x1) f3(x1)
%       f1(x2) f2(x2) f3(x2)
%   
%   FPLOT(FUN,LIMS,TOL) with TOL < 1 specifies the relative error
%   tolerance. The default TOL is 2e-3, i.e. 0.2 percent accuracy.
%   FPLOT(FUN,LIMS,N) with N >= 1 plots the function with a minimum of
%   N+1 points.  The default N is 1.  The maximum step size is
%   restricted to be (1/N)*(XMAX-XMIN).
%   FPLOT(FUN,LIMS,'LineSpec') plots with the given line specification.
%   FPLOT(FUN,LIMS,...) accepts combinations of the optional arguments
%   TOL, N, and 'LineSpec', in any order.
%   
%   [X,Y] = FPLOT(FUN,LIMS,...) returns X and Y such that Y = FUN(X).
%   No plot is drawn on the screen.
%
%   [...] = FPLOT(FUN,LIMS,TOL,N,'LineSpec',P1,P2,...) allows 
%   parameters P1,P2, etc. to be passed directly to function FUN:
%       Y = FUN(X,P1,P2,...).
%   To use default values for TOL,N,or,'LineSpec', you may pass in the empty
%   matrix ([]).
%
%   FPLOT(AX,...) plots into AX instead of GCA.
%
%   Examples:
%     FUN can be specified using @, an inline object, or an expression:
%       subplot(2,2,1), fplot(@humps,[0 1])
%
%       f = @(x)abs(exp(-j*x*(0:9))*ones(10,1));
%       subplot(2,2,2), fplot(f,[0 2*pi])
%
%       subplot(2,2,3), fplot('[tan(x),sin(x),cos(x)]',2*pi*[-1 1 -1 1])
%       subplot(2,2,4), fplot('sin(1 ./ x)', [0.01 0.1],1e-3)

%   The FPLOT function begins with a minimum step of size (XMAX-XMIN)*TOL.
%   The step size is subsequently doubled whenever the relative error
%   between the linearly predicted value and the actual function value is
%   less than TOL.  The maximum number of x steps is (1/TOL)+1.

%   Mark W. Reichelt 6-2-93
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.22.4.3 $  $Date: 2004/04/10 23:31:48 $

%fun,lims,

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

error(nargchk(2,nargs,nargs));

fun  = args{1};
lims = args{2};
args = args(3:end);

if (isvarname(fun))
   fun = ezfcnchk(fun);
else
   fun = fcnchk(fun);
end

marker = '-';
tol = 2e-3;
N = 1;
if nargs >= 3 & ~isempty(args{1})
  if isstr(args{1})
    marker = args{1};
  elseif args{1} < 1
    tol = args{1};
  else
    N = args{1};
  end
end
if nargs >= 4 & ~isempty(args{2})
  if isstr(args{2})
    marker = args{2};
  elseif args{2} < 1
    tol = args{2};
  else 
    N = args{2};
  end
end
if nargin >= 5 & ~isempty(args{3})
  if isstr(args{3})
    marker = args{3};
  elseif args{3} < 1
    tol = args{3};
  else
    N = args{3};
  end
end

% compute the x duration and minimum and maximum x step
xmin = min(lims(1:2)); xmax = max(lims(1:2));
maxstep = (xmax - xmin) / N;
minstep = min(maxstep,(xmax - xmin) * tol);
tryVal = minstep;

% compute the first two points
x = xmin; y = feval(fun,x,args{4:end});

xx = x;
x = xmin+minstep; y(2,:) = feval(fun,x,args{4:end});
xx(2) = x;

% compute a constant ytol if y limits are given
if length(lims) == 4
  ymin = min(lims(3:4)); ymax = max(lims(3:4));
  ylims = 1;
else
  J = find(isfinite(y));
  if isempty(J)
    ymin = 0; ymax = 0;
  else
    ymin = min(y(J)); ymax = max(y(J));
  end
  ylims = 0;
end
ytol = (ymax - ymin) * tol;

I = 2;
while xx(I) < xmax
  I = I+1;

  tryVal = min(maxstep,min(2*tryVal, xmax-xx(I-1)));
  x = xx(I-1) + tryVal;
  y(I,:) = feval(fun,x,args{4:end});

  ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));

  while any(abs(y(I,:) - ylin) > ytol) & (tryVal > minstep)
    tryVal = max(minstep,0.5*tryVal);
    x = xx(I-1) + tryVal;
    y(I,:) = feval(fun,x,args{4:end});
    ylin = y(I-1,:) + (x-xx(I-1)) * (y(I-1,:)-y(I-2,:)) / (xx(I-1)-xx(I-2));
  end

  if ~ylims
    J = find(isfinite(y(I,:)));
    if ~isempty(J)
      ymin = min(ymin,min(y(I,J))); ymax = max(ymax,max(y(I,J)));
      ytol = (ymax - ymin) * tol;
    end
  end

  xx(I) = x;
end

if nargout == 0
  cax = newplot(cax);
  plot(xx,y,marker,'parent',cax)
  set(cax,'XLim',[xmin xmax]);
  if ylims
    set(cax,'YLim',[ymin ymax]);
  end
else
  x0 = xx.'; y0 = y;
end
