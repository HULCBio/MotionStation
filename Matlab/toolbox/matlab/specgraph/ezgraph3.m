function hh = ezgraph3(varargin)
%EZGRAPH3 Helper function for easy surface plotters.
%   EZGRAPH3(PLOTFUN,f) plots z=f(x,y) using the plotting function PLOTFUN.
%   PLOTFUN is any function like SURF that takes (x,y,z) as inputs.
%
%   EZGRAPH3(PLOTFUN,f,[xmin xmax ymin ymax]) plots over the specified domain.
%   EZGRAPH3(PLOTFUN,...,DOMSTYLE) DOMSTYLE can be 'rect' or 'circ'.
%   EZGRAPH3(PLOTFUN,...,Npts) uses a grid of Npts-by-Npts points.
%
%   EZGRAPH3(PLOTFUN,x,y,z) plots the parametric surface x=x(s,t), y=y(s,t),
%   and z=z(s,t) over the square -2*pi < s < 2*pi and -2*pi < t < 2*pi.
%
%   EZGRAPH3(PLOTFUN,x,y,z,[smin,smax,tmin,tmax]) or EZGRAPH3(x,y,z,[a,b])
%   uses the specified domain. 
%
%   EZGRAPH3(AX,...) plots into AX instead of GCA.
%
%   H = EZGRAPH3(...) returns handles to the plotted objects in H.
%
%   See also EZPLOT, EZPLOT3, EZPOLAR, EZMESH, EZMESHC, EZSURF,
%            EZSURFC, EZCONTOUR. EZCONTOURF.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.13.4.4 $  $Date: 2004/04/06 21:53:34 $
%   P. J. Costa and Clay Thompson

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

surfstyle = args{1};
args = args(2:end);

% Set defaults
if isempty(cax)
   cax = gca;
end

[ezflag,f,domain,domstyle,Npts,flabel,fargs,fixdomain] = parse_inputs(args{:});

if ezflag % Use ezplot3s
   h = ezplot3s(cax,Npts,f{:},domain,surfstyle,flabel,fargs,'st');
elseif ~ezflag & isequal(domstyle,'rect') 
   % Plot a surface z = f(x,y) over a rectangle [x0,xf] x [y0,yf].
   [dummy,h] = surfplot(f,domain,surfstyle,cax,Npts,fixdomain,flabel,fargs);
elseif isequal(domstyle,'circ')
   % Plot a surface z = f(x,y) over a circle by letting x = r*cos(t),
   % y = r*sin(t), z = f(r*cos(t),r*sin(t)), r in [0,rm] and t in [-pi,pi].
   a = domain(1); b = domain(2); c = domain(3); d = domain(4);
   [z,fargs] = ezfixfun(f,fargs,flabel);
   Cen = [a+b,c+d]/2;
   % Change variables to (r,t)
   x = inline(['(r.*cos(t) + ' num2str(Cen(1)) ')'],'r','t');
   y = inline(['(r.*sin(t) + ' num2str(Cen(1)) ')'],'r','t');
   rm = sqrt((Cen(1) - b)^2 + (Cen(2) - d)^2);
   domain = [0,rm,-pi,pi];
   h = ezplot3s(cax,76,x,y,z,domain,surfstyle,flabel,fargs,'xy');
   title(cax,texlabel(flabel));
end 

if nargout > 0
    hh = h;
end

%-----------------------------------------
function R = dom(v)
%DOM creates a 1-by-4 class double vector whose elements
%   correspond to the endpoints of a rectangle.  If the
%   length of the input vector v is 1, then the rectangle R
%   is [-|v|,|v|,-|v|,-|v|].  If the length of the input
%   is 2, then R = [-v(1),v(2),-v(1),v(2)].  If the length
%   of v is 3, the R = [v(1),v(2),-|v(3)|,|v(3)|] and if the
%   length of of v is 4, then R = v.  Otherwise,
%   R = [-|v(1)|,|v(1)|,-|v(1)|,-|v(1)|]
switch length(v)
   case 0
      R = [-2*pi, 2*pi, -2*pi, 2*pi];
   case 1
      R = double([-abs(v),abs(v),-abs(v),abs(v)]);
   case 2
      R = double([v(1),v(2),v(1),v(2)]);
   case 3
      R = double([-v(1),v(2),-abs(v(3)),abs(v(3))]);
   case 4
      R = double(v);
   otherwise
      R = double([-abs(v(1)), abs(v(1)), -abs(v(1)), abs(v(1))]);
end

%-------------------------

function hh = ezplot3s(cax,Npts,varargin)
% EZPLOT3S  Easy to use 3-d parametric curve or surface plotter.
%   EZPLOT3S(AX,Npts,x,y,z) plots the surfaces S(t,s) = (x(t,s),y(t,s),z(t,s))
%   using a grid of Npts-by-Npts points.  The default region of surfaces is
%   the square [-2*pi,2*pi] X [-2*pi,2*pi].
%
%   EZPLOT3S(AX,Npts,x,y,z,[smin,smax],[tmin,tmax]), plots the surface
%   S(t,s) = (x(t,s),y(t,s),z(t,s)) for smin < s < smax, tmin < t < tmax.
%   In the case thatðx,y,z are not functions of s and t 
%   (rather, say u and v), then the domain endpoints [umin,umax] 
%   [vmin,vmax] are given alphabetically.
%
%   EZPLOT3S(AX,Npts,x,y,z,[a,b]) plots S(t,s) for a < s < b, a < t < b.
%
%   H = EZPLOT3S(...) returns handles to the plotted objects in H.
%
%   The last three arguments are flabel (a version of the function suitable
%   for use as a label), svars (the symbolic variables in the functions)
%   and xyorst (either 'st' to evaluate z as a function of the s and t
%   parameters, or 'xy' to evaluate it as a function of x and y).
%   
%   Examples
%     syms t s
%     ezplot3s(50,s*cos(t),s*sin(t),t)
%     ezplot3s(50,s*cos(t),s*sin(t),s)
%     ezplot3s(50,exp(-s)*cos(t),exp(-s)*sin(t),t,[0,8],[0,2*pi])
%     ezplot3s(50,cos(s)*cos(t),cos(s)*sin(t),sin(s),[0,pi/2],[0,3*pi/2])

fig = ancestor(cax,'figure');

% At the beginning of the calculation, set the pointer to an hour glass.
curPtr = get(fig,'Pointer');
set(fig,'Pointer','watch');
NA = length(varargin)-3;
[x,y,z] = deal(varargin{1:3});
flabel = varargin{end-2};
xyorst = varargin{end};

% Determine the variables in that define the parametrization
svars = varargin{end-1};
% Determine the number of variables in r = (x,y,z)
N = length(svars);
if isequal(svars,'{''}')
   svars = {};
end
if N==0 && (isa(x,'function_handle') || ...
            isa(y,'function_handle') || ...
            isa(z,'function_handle'))
  N = 2;
end
% Determine the surface style
if isa(varargin{NA},'char')
   surfstyle = varargin{NA};
   L = NA-1;
else
   surfstyle = 'surf';
   L = NA;
end

% Determine the domains in t and s:
switch L
   case 3
      T = linspace(-2*pi,2*pi,Npts);
      S = linspace(-2*pi,2*pi,Npts);
   case 4
      if ( prod(size(varargin{4})) == 4 )
         T = linspace(varargin{4}(3),varargin{4}(4),Npts);
         S = linspace(varargin{4}(1),varargin{4}(2),Npts);
      else
         T = linspace(varargin{4}(1),varargin{4}(2),Npts);
         S = T;
      end
   case 5
      T = linspace(varargin{5}(1),varargin{5}(2),Npts);
      S = linspace(varargin{4}(1),varargin{4}(2),Npts);
end

switch N
   case 0 % ezsurf('2','3','4')
      h = plot3(eval(char(x)),eval(char(y)),eval(char(z)),'b.', ...
          'MarkerSize',24,'parent',cax);
   case 1 % either bad inputs or the same as above
      error('To plot parametric curves, use EZPLOT3.');
   case 2 % Parametrized surface
      V = svars;
      if isempty(V), V{1} = 't'; V{2} = 's'; end
      [S,T] = meshgrid(S,T);
      [X,Xmin,Xmax] = ezeval(x,V,S,T);
      [Y,Ymin,Ymax] = ezeval(y,V,S,T);
      if (isequal(xyorst,'st'))
         [Z,Zmin,Zmax] = ezeval(z,V,S,T);
      else
         [Z,Zmin,Zmax] = ezeval(z,V,X,Y);
      end

      [X,xmin,xmax] = ufilt(X);
      [Y,ymin,ymax] = ufilt(Y);
      [Z,zmin,zmax] = ufilt(Z);

      % Plot the parametrically defined surface.

      oldChildren = get(cax,'children');
      feval(surfstyle,cax,X,Y,Z);
      h = setdiff(get(cax,'children'),oldChildren);

      xlabel(cax,'x'); ylabel(cax,'y'); zlabel(cax,'z');
      % Set the appropriate limits in x, y, and z.
      Xmin = 1.2*min(Xmin,xmin); Xmax = 1.2*max(Xmax,xmax);
      Ymin = 1.2*min(Ymin,ymin); Ymax = 1.2*max(Ymax,ymax);
      % Change Zmin and Zmax to get entire plot within the axis frame.
      Zmin = 1.2*min(Zmin,zmin); Zmax = 1.2*max(Zmax,zmax);
      if isequal(surfstyle,'contour') | isequal(surfstyle,'contourf')
         axis(cax,[Xmin,Xmax,Ymin,Ymax]);
      else
         axis(cax,[Xmin,Xmax,Ymin,Ymax,Zmin,Zmax]);
      end
      if (iscell(flabel))
         title(cax,[  'x = ' texlabel(flabel{1}), ...
                ', y = ' texlabel(flabel{2}), ...
                ', z = ' texlabel(flabel{3})]);
      end
   otherwise
      error('Cannot plot in 4 dimensions')
end

% At the end of the calculation, reset the pointer to an arrow.
set(fig,'Pointer',curPtr);

if nargout > 0
    hh = h;
end

%----------------------------------------

function [X,Y,u,umin,umax] = gridfilt(X,Y,u,N,fixdomain,F,V)
%GRIDFILT filters the computational grid to remove singularities and
%   imaginary (complex) numbers.
%   GRIDFILT(X,Y,Z,N,fixdomain) returns a surface grid [X,Y], u = F(X,Y)
%   whose singularities and complex number values have been set to NaNs.
%   Here X,Y, and u represent the points in a surface, N = number of points
%   in the grid, fixdomain indicates whether the domain should be fixed
%   (not changed), and F is the inline function that defines u:
%   u = F(X,Y).  V is the set of arguments that may appear in F.

t = (0:N-1)/(N-1);
% Reduce to an "interesting" domain.
if (N > 1) & ~fixdomain
   dx = X(2)-X(1);
   if (dx == 0), dx = 0.025; end
   dy = Y(2)-Y(1);
   if (dy == 0), dy = 0.025; end
   if prod(size(u)) == 1
      dudx = 0; dudy = 0;
      k = [];
   else
      [dudx,dudy] = gradient(u,dx,dy);
      absd = abs(dudx) + abs(dudy);
      k = find(absd > .01 * mean(absd(:)));
   end
   
   if isempty(k)
      xmin = min(X(:)); xmax = max(X(:));
      ymin = min(Y(:)); ymax = max(Y(:));
   else
      xmin = min(X(k)); xmax = max(X(k));
      ymin = min(Y(k)); ymax = max(Y(k));
   end
   if xmin < floor(4*xmin)/4 + dx, xmin = floor(4*xmin)/4; end
   if xmax > ceil(4*xmax)/4 - dx, xmax = ceil(4*xmax)/4; end
   X = xmin + t*(xmax-xmin);
   if ymin < floor(4*ymin)/4 + dy, ymin = floor(4*ymin)/4; end
   if ymax > ceil(4*ymax)/4 - dy, ymax = ceil(4*ymax)/4; end
   Y = ymin + t*(ymax-ymin);
   [X,Y] = meshgrid(X,Y);
   u = ezeval(F,V,X,Y);
   Umin = min(u(:)); Umax = max(u(:));
   k = find(abs(imag(u)) > 1.e-6*abs(real(u)));
   if any(k), u(k) = NaN; end
end

[u,umin,umax] = ufilt(u);

% ---------------------------
function [u,umin,umax] = ufilt(u)
%UFILT   Filter the surface only, not the X and Y values

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
du = abs(del2(u));
cutoff = 0.2 * (umax - umin);
U = u;

if (sum(du(:) > cutoff) > sqrt(N)/2)
   U(du > cutoff) = NaN;
end
unan = isnan(U) | u > umax | u < umin;

% If everything gets set to a NaN proceed via the ezplot/Moler 
% filtering . . .
if ( sum(sum(unan))/prod(size(U)) > 0.50 )
   [nr,nc] = size(u);
   % First, search along the rows . . .
   for j = 1:nr
     k = 2:nc;
     krow = find( (u(j,k) > umax/3 & u(j,k-1) < umin/3) | ...
                 (u(j,k) < umin/3 & u(j,k-1) > umax/3) );
     if any(krow), u(j,krow) = NaN; end
   end
   % . . . then search along the columns.
   for j = 1:nc
     k = 2:nr;
     kcol = find( (u(k,j) > umax/3 & u(k-1,j) < umin/3) | ...
                 (u(k,j) < umin/3.4 & u(k-1,j) > umax/3) );
     if any(kcol), u(kcol,j) = NaN; end
   end
else
   u = U;
end


% Limit data to umin and umax to "fake" clipping
if (any(any(isnan(u))))
   u(u > umax | u < umin) = NaN;
end

%--------------------------------------------------

function [ezflag,fout,domain,domstyle,Npts,flabel,V,fixdomain] = parse_inputs(varargin)
% PARSE_INPUTS Parses the inputs to EZGRAPH3.

ezflag = 0;  % EZFLAG = 0 when ezplot3s is NOT in use.
domain = [];        % means domain must be specified later
fixdomain = false;  % means domain not specified as an input arg
Npts = 60;
domstyle = 'rect';
[fout,flabel,V] = ezfcnchk(varargin{1},1);

switch length(varargin)
case 0
   error('Mathematical expression required.');
case 1
   % ezgraph3(surfstyle,f) - use the default values
case 2
   % ezgraph3(surfstyle,f,domain)
   if isa(varargin{2},'double') & (length(varargin{2}) > 1)
      domain = dom(varargin{2});

   % ezgraph3(surfstyle,f,Npts)
   elseif isa(varargin{2},'double') & length(varargin{2}) == 1
      Npts = varargin{2};

   % ezgraph3(surfstyle,f,domstyle)
   elseif isa(varargin{2},'char')
      domstyle = varargin{2};
   end
case 3
   % ezgraph3(surfstyle,f,domain(x,y),domstyle)
   if isa(varargin{2},'double') & ...
          (length(varargin{2}) > 1) & isa(varargin{3},'char')
      domain = dom(varargin{2});
      domstyle = varargin{3};

   % ezgraph3(surfstyle,f,Npts,domstyle)
   elseif isa(varargin{2},'double') & ...
          (length(varargin{2}) == 1) & isa(varargin{3},'char')
      Npts = varargin{2};
      domstyle = varargin{3};

   % ezgraph3(surfstyle,f,domain(x),domain(y))
   elseif isa(varargin{2},'double') & ...
          isa(varargin{3},'double') & ...
          (length(varargin{2}) > 1) & (length(varargin{3}) > 1)
      domain = dom([varargin{2}, varargin{3}]);

   % ezgraph3(surfstyle,f,domain(x,y),Npts)
   elseif isa(varargin{2},'double') & ...
          isa(varargin{3},'double') & ...
          (length(varargin{2}) > 1) & (length(varargin{3}) == 1)
      domain = dom(varargin{2});
      Npts = varargin{3};
   % ezgraph3(surfstyle,x,y,z)
   else
      [y,ylab,yargs,ymsg] = ezfcnchk(varargin{2},1);
      [z,zlab,zargs,zmsg] = ezfcnchk(varargin{3},1);
      if (isempty(ymsg) & isempty(zmsg))
         ezflag = 1;
         x = fout;
         Npts = 50;
      else
         error('Incorrect inputs.');
      end
   end
case 4
   % ezgraph3(surfstyle,f,domain(x),domain(y),domstyle)
   if isa(varargin{4},'char') & ...
          isa(varargin{2},'double') & (length(varargin{2}) > 1) & ...
          isa(varargin{3},'double') & (length(varargin{3}) > 1)
      domain = dom([varargin{2},varargin{3}]);
      domstyle = varargin{4};

   % ezgraph3(surfstyle,f,domain(x),domain(y),Npts)
   elseif isa(varargin{2},'double') & (length(varargin{2}) > 1) & ...
          isa(varargin{3},'double') & (length(varargin{3}) > 1) & ...
          isa(varargin{4},'double') & (length(varargin{4}) == 1)
      domain = dom([varargin{2},varargin{3}]);
      Npts = varargin{4};

   % ezgraph3(surfstyle,f,domstyle,domain(x,y),Npts)
   elseif isa(varargin{2},'char') & ...
          isa(varargin{3},'double') & (length(varargin{3}) > 1) & ...
          isa(varargin{4},'double') & (length(varargin{4}) == 1)
      domstyle = varargin{2};
      domain = dom(varargin{3});
      Npts = varargin{4};

   % ezgraph3(surfstyle,f,domain(x,y),Npts,domstyle)
   elseif isa(varargin{2},'double') & ...
          (length(varargin{2}) > 1) & isa(varargin{4},'char') & ...
          isa(varargin{3},'double') & (length(varargin{3}) == 1)
      domain = dom(varargin{2});
      Npts = varargin{3};
      domstyle = varargin{4};

   else
      % ezgraph3(surfstyle,x,y,z,domain(s,t))
      [y,ylab,yargs,ymsg] = ezfcnchk(varargin{2},1);
      [z,zlab,zargs,zmsg] = ezfcnchk(varargin{3},1);
      if (isempty(ymsg) & isempty(zmsg) & ...
          isa(varargin{4},'double') & (length(varargin{4}) > 1))
         ezflag = 1;
         x = fout;
         domain = dom(varargin{4});
         Npts = 50;

      % ezgraph3(surfstyle,x,y,z,Npts)
      elseif (isempty(ymsg) & isempty(zmsg) & ...
          isa(varargin{4},'double') & (length(varargin{4}) == 1))
         ezflag = 1;
         x = fout;
         Npts = varargin{4};

      % ezgraph3(surfstyle,x,y,z,domstyle)
      elseif (isempty(ymsg) & isempty(zmsg) & isa(varargin{4},'char'))
         ezflag = 1;
         x = fout;
         domstyle = varargin{4};
         Npts = 50;

      else
         error('Incorrect inputs.');
      end
   end
case 5
   % ezgraph3(surfstyle,x,y,z,domain(s,t),Npts)
   if (length(varargin{4}) > 1) & (length(varargin{5}) == 1)
      domain = dom(varargin{4});
      Npts = varargin{5};

   % ezgraph3(surfstyle,x,y,z,domain(s),domain(t))
   elseif (length(varargin{4}) == 2) & (length(varargin{5}) == 2)
      domain = dom([varargin{4},varargin{5}]);
      Npts = 50;
   else
      error('Incorrect inputs.');
   end
   ezflag = 1;
   x = fout;
   [y,ylab,yargs,ymsg] = ezfcnchk(varargin{2},1);
   [z,zlab,zargs,zmsg] = ezfcnchk(varargin{3},1);
case 6
   % ezgraph3(surfstyle,x,y,z,domain(s),domain(t),Npts)
   if (length(varargin{4}) == 2) & (length(varargin{5}) == 2)
      ezflag = 1;
      x = fout;
      [y,ylab,yargs,ymsg] = ezfcnchk(varargin{2},1);
      [z,zlab,zargs,zmsg] = ezfcnchk(varargin{3},1);
      domain = dom([varargin{4},varargin{5}]);
      Npts = varargin{6};
   else
      error('Incorrect inputs.');
   end
otherwise
   fout = varargin{1};
   domain = dom(varargin{2});
   domstyle = varargin{3};
   Npts = varargin{4};
end

if ezflag, % Package x,y,z into f.
  fout = {x,y,z};
  V = union(V,union(yargs,zargs));
  flabel = {flabel ylab zlab};
end

if isempty(domain)
   domain = [-2*pi, 2*pi, -2*pi, 2*pi];
else
   fixdomain = true;
end

%-------------------------

function [zlim,hh] = surfplot(F,domain,surfstyle,cax,N,fixdomain,flabel,fargs)
%SURFPLOT Plots the surface z = f associated with the symbolic expression f
%   of two symbolic variables over the DOMAIN with a surface style SURFSTYLE,
%   figure number FIG, and N-by-N grid. fixdomain is true if the domain is
%   specified and should not be changed.  flabel is the function text
%   suitable for use as a label, and fargs is a cell array of function
%   arguments.
%
%   Example:
%       % plot the surface z = x^2 + y^2, for 0 < x < 1 and 2 < y < 3 via
%       % 'surf' in axes(ax) over a 50-by-50 grid.
%       ax = axes;   
%       surfplot(x^2 + y^2,[0,1,2,3],'surf',ax,50,1) 

% At the beginning of the calculation, set the pointer to an hour glass.
fig = ancestor(cax,'figure');
curPtr = get(fig,'Pointer');
set(fig,'Pointer','watch');

[F,var] = ezfixfun(F,fargs,flabel);
    
% Sample on the initial rectangle with X = xmin + t*(xmax-xmin),
% Y = ymin + t*(ymax-ymin) and t = [0, 1/N, 2/N, ... , (N-1)/N];
t = (0:N-1)/(N-1);
xmin = min(domain(1),domain(2));
xmax = max(domain(1),domain(2));
X = xmin + t*(xmax - xmin);
ymin = min(domain(3),domain(4));
ymax = max(domain(3),domain(4));
Y = ymin + t*(ymax - ymin);
[X,Y] = meshgrid(X,Y);
u = ezeval(F,var,X,Y);
Umin = min(u(:)); Umax = max(u(:));
k = find(abs(imag(u)) > 1.e-6*abs(real(u)));
if any(k), u(k) = NaN; X(k) = NaN; Y(k) = NaN; N = length(Y); end

[X,Y,u,umin,umax] = gridfilt(X,Y,u,N,fixdomain,F,var);

% Plot the function
if (isnan(xmin) | isnan(xmax) | isnan(ymin) | isnan(ymax) )
   error([flabel ' must be real-valued only.'])
end
% If the figure is 'visible', make it active
if strcmp(get(fig,'Visible'),'on'), figure(fig); end
if prod(size(u)) == 1, u = u*ones(size(X)); end

oldChildren = get(cax,'children');
feval(surfstyle,cax,X,Y,u);
h = setdiff(get(cax,'children'),oldChildren);

% Set the appropriate limits in x, y, and z.
zlim = get(cax,'zlim');
xmin = max(xmin,min(min(X))); xmax = min(xmax,max(max(X)));
ymin = max(ymin,min(min(Y))); ymax = min(ymax,max(max(Y)));

% Change umin and umax to get entire plot within the axis frame.
if abs(Umin - umin) > 0.05*abs(Umin) | Umin == -Inf, umin = zlim(1); end
if abs(Umax - umax) > 0.05*abs(Umax) | Umax == Inf, umax = zlim(2); end
if isequal(surfstyle,'contour') | isequal(surfstyle,'contourf')
   axis(cax,[xmin xmax ymin ymax]);
   grid(cax,'off');
else
   axis(cax,[xmin xmax ymin ymax umin umax]);
   grid(cax,'on');
 end

if ~isnan(var{1}), xlabel(cax,texlabel(var{1})); end
if ~isnan(var{2}), ylabel(cax,texlabel(var{2})); end

% Change the title to TeX format.
title(cax,texlabel(flabel));

% At the end of the calculation, reset the pointer to an arrow.
set(fig,'Pointer',curPtr);

if nargout > 1
    hh = h;
end
    

% -------------------------------------------------
function [X,Xmin,Xmax] = ezeval(fx,fargs,arg1,arg2)
%EZEVAL  Evaluate expression with appropriate arguments

% We have a total of two arguments, but this function may not
% use both of them.  Figure out which are required
useargs = 3;
if (isa(fx,'inline') & nargin(fx)==1)
   myarg = argnames(fx);
   myarg = myarg{1};
   if (isequal(myarg,fargs{1}))
      useargs = 1;
   else
      useargs = 2;
   end
end

if (ischar(fx) & isempty(symvar(fx)))
   X = eval(fx);
elseif (useargs==1)
   X = ezplotfeval(fx,arg1);
elseif (useargs==2)
   X = ezplotfeval(fx,arg2);
else
   X = ezplotfeval(fx,arg1,arg2);
end

% Special processing for 1-by-1 syms/doubles.
if prod(size(X)) == 1
   if (nargout>1)
      Xmin = 0.9*X;
      Xmax = 1.1*X;
   end
   X = X*ones(size(arg1));
elseif (nargout>1)
   Xmin = min(min(X));
   Xmax = max(max(X));
end


% -------------------------------------------------
function [fout,var] = ezfixfun(fin,argsin,flabel)
%EZFIXFUN  Fix function and argument list for surface plotting

if ischar(fin) || (isa(fin,'function_handle') && isempty(argsin))
  var = {'x','y'};
else
  var = argsin;
end
fout = fin;

% Make sure we have two variables
var = var(~cellfun('isempty',var));
switch(length(var))
case 0
   var = {'x','y'};
case 1
  if isequal(var{1},'y')
    var = {'x', var{1}};
  else
    var = {var{1}, 'y'};
  end
  if (isa(fin,'inline')), fout = inline(char(fin),var{:}); end
case 2
  % done
otherwise
  error(['The expression ' flabel ' must only have 2 symbolic variables']);
end
