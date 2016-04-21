function hh = ezplot(varargin)
%EZPLOT Easy to use function plotter.
%   EZPLOT(f) plots the expression f = f(x) over the default
%   domain -2*pi < x < 2*pi.
%
%   EZPLOT(f, [a,b]) plots f = f(x) over a < x < b
%
%   For implicitly defined functions, f = f(x,y)
%   EZPLOT(f) plots f(x,y) = 0 over the default domain
%   -2*pi < x < 2*pi and -2*pi < y < 2*pi
%   EZPLOT(f, [xmin,xmax,ymin,ymax]) plots f(x,y) = 0 over
%   xmin < x < xmax and  ymin < y < ymax.
%   EZPLOT(f, [a,b]) plots f(x,y) = 0 over a < x < b and a < y < b.
%   If f is a function of the variables u and v (rather than x and y), then
%   the domain endpoints a, b, c, and d are sorted alphabetically. Thus,
%   EZPLOT('u^2 - v^2 - 1',[-3,2,-2,3]) plots u^2 - v^2 - 1 = 0 over
%   -3 < u < 2, -2 < v < 3.
%
%   EZPLOT(x,y) plots the parametrically defined planar curve x = x(t)
%   and y = y(t) over the default domain 0 < t < 2*pi.
%   EZPLOT(x,y, [tmin,tmax]) plots x = x(t) and y = y(t) over
%   tmin < t < tmax.
%
%   EZPLOT(f, [a,b], FIG), EZPLOT(f, [xmin,xmax,ymin,ymax], FIG), or
%   EZPLOT(x,y, [tmin,tmax], FIG) plots the given function over the
%   specified domain in the figure window FIG.
%
%   EZPLOT(AX,...) plots into AX instead of GCA or FIG.
%
%   H = EZPLOT(...) returns handles to the plotted objects in H.
%
%   Examples
%    f is typically an expression, but it can also be specified
%    using @ or an inline function:
%     ezplot('cos(x)')
%     ezplot('cos(x)', [0, pi])
%     ezplot('1/y-log(y)+log(-1+y)+x - 1')
%     ezplot('x^2 - y^2 - 1')
%     ezplot('x^2 + y^2 - 1',[-1.25,1.25]); axis equal
%     ezplot('x^3 + y^3 - 5*x*y + 1/5',[-3,3])
%     ezplot('x^3 + 2*x^2 - 3*x + 5 - y^2')
%     ezplot('sin(t)','cos(t)')
%     ezplot('sin(3*t)*cos(t)','sin(3*t)*sin(t)',[0,pi])
%     ezplot('t*cos(t)','t*sin(t)',[0,4*pi])
%
%     f = @(x)cos(x)+2*sin(x);
%     ezplot(f)
%     ezplot(@humps)
%
%   See also EZCONTOUR, EZCONTOURF, EZMESH, EZMESHC, EZPLOT3,
%            EZPOLAR, EZSURF, EZSURFC, PLOT.

%   Copyright 1984-2002 The MathWorks, Inc.  
%   $Revision: 1.43.4.7 $  $Date: 2004/04/06 21:53:35 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

f = args{1};
args = args(2:end);

if ~ischar(f) & ~isa(f,'inline') & ~isa(f,'function_handle')
   if all(size(f)==1) 
      f = num2str(f); 
   else
      error('Input must be a string expression, function name, or INLINE object.');
   end
end
twofuns = 0;
if (nargs > 1)
   twofuns = (ischar(args{1}) | isa(args{1},'inline') ...
                                  | isa(args{1}, 'function_handle'));
   if (length(args)>1 & length(args{2})<=1)
       twofuns = 0;
   end
end

% Place f into "function" form (inline).
if (twofuns)
   [f,fx0,varx] = ezfcnchk(f,0,'t');
else
   [f,fx0,varx] = ezfcnchk(f);
end

vars = varx;
nvars = length(vars);
if isa(f,'function_handle') && nvars==0
    nvars = nargin(f);  % can determine #args without knowing their names
end
labels = {fx0};
if ~iscell(f), f = {f}; end

if (twofuns)
   % Determine whether the two input functions have the same
   % independent variable.  That is, in the case of ezplot(x,y),
   % check that x = x(t) and y = y(t).  If not (x = x(p) and
   % y = y(q)), reject the plot.
   [fy,fy0,vary] = ezfcnchk(args{1},0,'t');
   nvars = max(nvars, length(vary));
   if isa(fy,'function_handle') && isempty(vary)
      nvars = max(nvars,nargin(fy));
   end
   f{2} = fy;
   labels{2} = fy0;

   % This is the case of ezplot('2','f(q)') or ezplot('f(p)','3').
   if isempty(varx) | isempty(vary)
      vars = union(varx,vary);
   end
end

vars = vars(~cellfun('isempty',vars));
if isempty(vars)
   if (twofuns)
      vars = {'t'};
   else
      if (nvars == 2)
         vars = {'x' 'y'};
      else
         vars = {'x'};
      end
   end
end
nvars = max(nvars, length(vars));
ninputs = length(args);

if (ninputs==1 & ~twofuns)
   if length(args{1}) == 4 & nvars == 2
      V = args;
      args{1} = [V{1}(1),V{1}(2)];
      args{2} = [V{1}(3),V{1}(4)];
   end
   % ezplot(f,[xmin,ymin]) covered in the default setting.
end

if ~twofuns
   switch nvars
      case 1
         % Account for variables of [char] length > 1
         [hp,cax] = ezplot1(cax,f{1},vars,labels,args{:});
         title(cax,texlabel(labels),'interpreter','tex');
         if ninputs>0 & isa(args{1},'double') & length(args{1}) == 4
            axis(cax,args{1});
         elseif ninputs > 1 & isa(args{2},'double') & ...
                length(args{2}) == 4
            axis(cax,args{2});
         end
      case 2
         [hp,cax] = ezimplicit(cax,f{1},vars,labels,args{:});
      otherwise
         if (isa(f,'function_handle'))
            fmsg = func2str(f);
         else
            fmsg = char(f);
         end
         error([fmsg ' cannot be plotted in the xy-plane.']);
      end
else
   [hp,cax] = ezparam(cax,f{1},f{2},vars,labels,args{2:end});
end

if nargout > 0
    hh = hp;
end

%------------------------

function [hp,newcax] = ezimplicit(cax,f,vars,labels,varargin)
% EZIMPLICIT Plot of an implicit function in 2-D.
%    EZIMPLICIT(cax,f,vars) plots in cax the string expression f 
%    that defines an implicit function f(x,y) = 0 for x0 < x < x1
%    and y0 < y < y1, whose default values are x0 = -2*pi = y0
%    and x1 = 2*pi = y1.  The arguments of f are listed in vars and
%    a non-vector version of the function expression is in labels.
%
%   EZIMPLICIT(cax,f,vars,labels,[x0,x1]) plots the implicit function
%   f(x,y) = 0 for x0 < x < x1, x0 < y < x1.
%
%   EZIMPLICIT(cax,f,vars,labels,[x0,x1],[y0,y1]) plots the implicit
%   function f(x,y) = 0 for x0 < x < x1, y0 < y < y1.
%   In the case that f is not a function of x and y 
%   (rather, say u and v), then the domain endpoints [u0,u1] 
%   [v0,v1] are given alphabetically.
%
%   [HP,NEWCAX] = EZIMPLICIT(...) returns the handles to the plotted
%   objects in HP, and the axes used to plot the function in NEWCAX.

% If f is created from a string equation f(x,y) = g(x,y), change
% the equal sign '=' to a minus sign '-'
if (isa(f,'inline') & findstr(char(f), '='))
   symvars = argnames(f);
   f = char(f);
   f = strrep(f,'=','-');
   f = inline(f, symvars{:});
end

% Choose the number of points in the plot
npts = 250;

fig = [];
switch length(vars)
case 0
   x = 'x'; y = 'y';
case 1
   x = vars{1}; y = 'y';
case 2
   x = vars{1}; y = vars{2};
otherwise
   % If there are more than 2 variables, send an error message
   W = {vars{1},vars{2}};
   error(['ezplot requires numeric values for ' setdiff(vars,W)]);
end
% Define the computational space
switch (nargin-3)
case 1
   X = linspace(-2*pi,2*pi,npts);
   Y = X;
case 2
   if length(varargin{1}) == 1
      fig = varargin{1};
      X = linspace(-2*pi,2*pi,npts); Y = X;
   else 
      X = linspace(varargin{1}(1),varargin{1}(2),npts);
      Y = X;
   end
case 3
   if length(varargin{1}) == 1
      fig = varargin{1};
      X = linspace(varargin{2}(1),varargin{2}(2),npts);
      Y = X;
   elseif length(varargin{2}) == 1 & length(varargin{1}) == 2
      fig = varargin{2};
      X = linspace(varargin{1}(1),varargin{1}(2),npts);
      Y = X;
   elseif length(varargin{2}) == 1 & length(varargin{1}) == 4
      fig = varargin{2};
      X = linspace(varargin{1}(1),varargin{1}(2),npts);
      Y = linspace(varargin{1}(3),varargin{1}(4),npts);
   else
      X = linspace(varargin{1}(1),varargin{1}(2),npts);
      Y = linspace(varargin{2}(1),varargin{2}(2),npts);
   end
end

[X,Y] = meshgrid(X,Y);
u = ezplotfeval(f,X,Y);

% Determine u scale so that "most" of the u values
% are in range, but singularities are off scale.

u = real(u);
uu = sort(u(isfinite(u)));
N = length(uu);
if N > 16
   del = uu(fix(15*N/16)) - uu(fix(N/16));
   umin = max(uu(1)-del/16,uu(fix(N/16))-del);
   umax = min(uu(N)+del/16,uu(fix(15*N/16))+del);
elseif N > 0
   umin = uu(1);
   umax = uu(N);
else
   umin = 0;
   umax = 0;
end
if umin == umax, umin = umin-1; umax = umax+1; end

% Eliminate vertical lines at discontinuities.

ud = (0.5)*(umax - umin); umean = (umax + umin)/2;
[nr,nc] = size(u);
% First, search along the rows . . .
for j = 1:nr
   k = 2:nc;
   kc = find( abs(u(j,k) - u(j,k-1)) > ud );
   ki = find( max( abs(u(j,k(kc)) - umean), abs(u(j,k(kc)-1) - umean) ) );
   if any(ki), u(j,k(kc(ki))) = NaN; end
end
% . . . then search along the columns.
for j = 1:nc
   k = 2:nr;
   kr = find( abs(u(k,j) - u(k-1,j)) > ud );
   kj = find( max( abs(u(k(kr),j) - umean), abs(u(k(kr)-1,j) - umean) ) );
   if any(kj), u(k(kr(kj)),j) = NaN; end
end

% First check if cax was specified (strongest specification for plot axes)
if isempty(cax)
    % Now allow the fig input to be honored
    cax = determineAxes(fig);
end

[cmatrix,hp] = contour(cax,X(1,:),Y(:,1),u,[0,0],'-');
if (isa(x,'function_handle'))
   xmsg = func2str(x);
else
   xmsg = char(x);
end
if (isa(y,'function_handle'))
   ymsg = func2str(y);
else
   ymsg = char(y);
end
xlabel(cax,texlabel(xmsg)); ylabel(cax,texlabel(ymsg));
title(cax,texlabel([labels{1},' = 0']));

newcax = cax;

%----------------------------------

function [hp,newcax] = ezparam(cax,x,y,vars,labels,varargin)
% EZPARAM Easy to use 2-d parametric curve plotter.
%   EZPARAM(cax,x,y,vars,labels) plots the planar curves r(t) = (x(t),y(t))
%   in cax.  The default domain in t [0,2*pi].  vars contains the common
%   argument of x and y, and labels contains non-vector versions of the
%   x and y expressions.
%
%   EZPARAM(cax,x,y,vars,labels,[tmin,tmax]) plots r(t) = (x(t),y(t)) for
%   tmin < t < tmax.
%
%   [HP,NEWCAX] = EZPARAM(...) returns the handles to the plotted
%   objects in HP, and the axes used to plot the function in NEWCAX.

fig = [];
N = length(vars);

Npts = 300;

% Determine the domains in t:
switch (nargin-3)
case 2
   T = linspace(0,2*pi,Npts);
case 3
   if length(varargin{1}) == 1
      fig = varargin{1};
      T = linspace(0,2*pi,Npts);
   else
      T = linspace(varargin{1}(1),varargin{1}(2),Npts);
   end
case 4
   if length(varargin{2}) == 1
      fig = varargin{2};
      T = linspace(varargin{1}(1),varargin{1}(2),Npts);
   elseif length(varargin{1}) == 1
      fig = varargin{1};
      T = linspace(varargin{2}(1),varargin{2}(2),Npts);
   else
      T = linspace(varargin{1},varargin{2},Npts);
   end
end

% First check if cax was specified (strongest specification for plot axes)
if isempty(cax)
    % Now allow the fig input to be honored
    cax = determineAxes(fig);
end

% Create plot
cax = newplot(cax);

switch N
   case 1 % planar curve
      X = ezplotfeval(x,T);
      Y = ezplotfeval(y,T);
      hp = plot(X,Y,'parent',cax);
      xlabel(cax,'x'); ylabel(cax,'y');
      axis(cax,'equal');
      title(cax,['x = ' texlabel(labels{1}), ', y = ' texlabel(labels{2})]);
   otherwise
      error('Cannot plot parametrized surfaces.  Try ezsurf.')
end

newcax = cax;

%-------------------------

function [hp,newcax] = ezplot1(cax,f,vars,labels,xrange,fig)
%EZPLOT1 Easy to use function plotter.
%   EZPLOT1(cax,f,vars,labels) plots a graph of f(x) into cax  
%   where f is a string or a symbolic expression representing a 
%   mathematical expression involving a single symbolic variable, 
%   say 'x'.
%   vars is the name of the variable and labels is a non-vector
%   version of the function expression.
%   The range of the x-axis is approximately  [-2*pi, 2*pi]
%
%   EZPLOT1(cax,f,vars,labels,xmin,xmax) or EZPLOT(f,[xmin,xmax]) 
%   uses the specified x-range instead of the default [-2*pi, 2*pi].
%
%   EZPLOT1(cax,f,vars,labels,[xmin xmax],fig) uses the specified
%   figure number, fig, instead of cax.
%
%   [HP,NEWCAX] = EZPLOT1(...) returns the handles to the plotted
%   objects in HP, and the axes used to plot the function in NEWCAX.

% Set defaults
if nargin < 4, error('Not enough input arguments.'); end
if nargin < 5, xrange = [-2*pi 2*pi]; end
if isstr(xrange), xrange = eval(xrange); end
if nargin < 6, fig = ancestor(cax,'figure'); end
if nargin == 6
   if length(xrange) == 1
      xrange = [xrange fig];
   elseif isstr(fig)
      xrange = [xrange eval(fig)];
   elseif ~isempty(cax)
     fig = ancestor(cax,'figure');
   end
end

% First check if cax was specified (strongest specification for plot axes)
if isempty(cax)
    % Now allow the fig input to be honored
    cax = determineAxes(fig);
end

% Create plot
cax = newplot(cax);

warns = warning('off');

% Sample on initial interval.

units = get(cax,'units');
set(cax,'units','pixels');
% npts = # of pixels in the axis width.
npts = get(cax,'position')*[0;0;1;0];
set(cax,'units',units);
t = (0:npts-1)/(npts-1);
xmin = min(xrange);
xmax = max(xrange);
x = xmin + t*(xmax-xmin);

% Get y values, and possibly also change f to be vectorized
[y,f,loopflag] = ezplotfeval(f,x);

k = find(abs(imag(y)) > 1.e-6*abs(real(y)));
if any(k), x(k) = []; y(k) = []; end
npts = length(y);
if isempty(y) & npts == 0
   warning(warns);
   warning('MATLAB:ezplot:NoRealValues', ...
           'Cannot plot %s:  This function has no real values.', ...
           labels{1});
   return
elseif loopflag
   % Warnings are off, so turn them on temporarily and issue a warning
   % message similar to what would have come from ezplotfeval.
   warning(warns);
   warning('MATLAB:ezplot:NotVectorized', ...
['Function failed to evaluate on array inputs; vectorizing the function may\n'...
'speed up its evaluation and avoid the need to loop over array elements.']);
   warning('off');
end
% Reduce to an "interesting" x interval.

if (npts > 1) & (nargin < 5)
   dx = x(2)-x(1);
   dy = diff(y)/dx;
   dy(npts) = dy(npts-1);
   k = find(abs(dy) > .01);
   if isempty(k), k = 1:npts; end
   xmin = x(min(k));
   xmax = x(max(k));
   if xmin < floor(4*xmin)/4 + dx, xmin = floor(4*xmin)/4; end
   if xmax > ceil(4*xmax)/4 - dx, xmax = ceil(4*xmax)/4; end
   x = xmin + t*(xmax-xmin);
   y = ezplotfeval(f,x);
   k = find(abs(imag(y)) > 1.e-6*abs(real(y)));
   if any(k), y(k) = NaN; end
end

% Determine y scale so that "most" of the y values
% are in range, but singularities are off scale.

y = real(y);
u = sort(y(isfinite(y)));
npts = length(u);
if isempty(u)
   u = repmat(NaN,size(x));
   npts = prod(size(x));
end
ymin = u(1);
ymax = u(npts);
if npts > 4
   del = u(fix(7*npts/8)) - u(fix(npts/8));
   ymin = max(u(1)-del/8,u(fix(npts/8))-del);
   ymax = min(u(npts)+del/8,u(fix(7*npts/8))+del);
end
 
% Eliminate vertical lines at discontinuities.
 
k = 2:length(y);
k = find( ((y(k) > ymax/2) & (y(k-1) < ymin/2)) | ...
          ((y(k) < ymin/2) & (y(k-1) > ymax/2)) );
if any(k), y(k) = NaN; end

% Plot the function

hp = plot(x,y,'parent',cax);
if ymax > ymin
   axis(cax,[xmin xmax ymin ymax])
else
   axis(cax,[xmin xmax get(cax,'ylim')])
end

xlabel(cax,texlabel(vars{1}));
title(cax,texlabel(labels{1}),'Interpreter','none')
warning(warns)

newcax = cax;

%-------------------------

function cax = determineAxes(fig)
% Helper function that takes the specified figure handle.  If the handle is
% not empty, find its current axes.  If it is empty, use the current axes.
if ~isempty(fig)
    % In case a figure handle was specified, but the figure does not exist,
    % create one.
    figure(fig);
    cax = gca(fig);
else
    % Neither cax nor fig was specified, so use gca
    cax = gca;
end
