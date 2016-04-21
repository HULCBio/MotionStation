function hh = quiver3(varargin)
%QUIVER3 3-D quiver plot.
%   QUIVER3(X,Y,Z,U,V,W) plots velocity vectors as arrows with components
%   (u,v,w) at the points (x,y,z).  The matrices X,Y,Z,U,V,W must all be
%   the same size and contain the corresponding position and velocity
%   components.  QUIVER3 automatically scales the arrows to fit.
%
%   QUIVER3(Z,U,V,W) plots velocity vectors at the equally spaced
%   surface points specified by the matrix Z.
%
%   QUIVER3(Z,U,V,W,S) or QUIVER3(X,Y,Z,U,V,W,S) automatically
%   scales the arrows to fit and then stretches them by S.
%   Use S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER3(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER3(...,'filled') fills any markers specified.
%
%   QUIVER3(AX,...) plots into AX instead of GCA.
%
%   H = QUIVER3(...) returns a quiver object.
%
%   Backwards compatibility
%   QUIVER3('v6',...) creates line objects instead of a quivergroup
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   Example:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
%   See also QUIVER, PLOT, PLOT3, SCATTER.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.23.4.4 $  $Date: 2004/02/01 22:05:43 $

[v6,args] = usev6plotapi(varargin{:});

% old implementation
if v6
  h = Lquiver3v6(args{:});
  
% create quiver object  
else
  error(nargchk(1,inf,nargin));
  % Parse possible Axes input
  [cax,args,nargs] = axescheck(args{:});
  [pvpairs,args,nargs] = parseargs(args,nargs);
  
  cax = newplot(cax);
  [ls,c,m] = nextstyle(cax);

  h = specgraph.quivergroup('Color',c,'LineStyle',ls,...
                            'parent',cax,pvpairs{:});
  
  if ~ishold(cax), view(cax,3); grid(cax,'on'); end
  
  if ~any(strcmpi('color',pvpairs(1:2:end)))
    set(h,'CodeGenColorMode','auto');
  end
  set(h,'refreshmode','auto');
  h = double(h);
  
end

if nargout>0, hh = h; end

%----------------------------------------------%
function [pvpairs,args,nargs,msg] = parseargs(args,nargs)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
n = 1;
extrapv = {};
% check for 'filled' or LINESPEC
while length(pvpairs) >= 1 && n < 3 && isstr(pvpairs{1})
  arg = lower(pvpairs{1});
  if arg(1) == 'f'
    pvpairs(1) = [];
    extrapv = {'MarkerFaceColor','auto',extrapv{:}};
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = {'linestyle',l,extrapv{:}};
      end
      if ~isempty(c)
        extrapv = {'color',c,extrapv{:}};
      end
      if ~isempty(m)
        extrapv = {'ShowArrowHead','off',extrapv{:}};
        if ~isequal(m,'.')
          extrapv = {'marker',m,extrapv{:}};
        end
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);
if isa(args{nargs},'double') && (length(args{nargs}) == 1)
  if args{nargs} > 0
    pvpairs = {pvpairs{:},'autoscale','on',...
	       'autoscalefactor',args{nargs}};
  else
    pvpairs = {pvpairs{:},'autoscale','off'};
  end
  nargs = nargs - 1;
end
if (nargs == 4)
  pvpairs = {pvpairs{:},'zdata',args{1},'udata',args{2},'vdata',args{3},'wdata',args{4}};
elseif (nargs == 6)
  pvpairs = {pvpairs{:},'xdata',args{1},'ydata',args{2}, 'zdata',args{3}...
	     'udata',args{4},'vdata',args{5},'wdata',args{6}};
end


%----------------------------------------------%
function hh = Lquiver3v6(varargin)
[cax,args,nargs] = axescheck(varargin{:});

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1;

filled = 0;
ls = '-';
ms = '';
col = '';

nin = nargs;
% Parse the string inputs
while isstr(args{nin}),
  vv = args{nin};
  if ~isempty(vv) & strcmp(lower(vv(1)),'f')
    filled = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(vv);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',vv));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; plotarrows = 0; end
    if isequal(m,'.'), ms = ''; end % Don't plot '.'
    nin = nin-1;
  end
end

error(nargchk(4,7,nin));

% Check numeric input arguments
if nin<6, % quiver3(z,u,v,w) or quiver3(z,u,v,w,s)
  [msg,x,y,z] = xyzchk(args{1});
  u = args{2};
  v = args{3};
  w = args{4};
else % quiver3(x,y,z,u,v,w) or quiver3(x,y,z,u,v,w,s)
  [msg,x,y,z] = xyzchk(args{1:3});
  u = args{4};
  v = args{5};
  w = args{6};
end
if ~isempty(msg), error(msg); end

% Scalar expand u,v,w.
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end
if prod(size(w))==1, w = w(ones(size(v))); end

% Check sizes
if ~isequal(size(x),size(y),size(z),size(u),size(v),size(w))
  error('The sizes of X,Y,Z,U,V, and W must all be the same.');
end

% Get autoscale value if present
if nin==5 | nin==7, % quiver3(z,u,v,w,s) or quiver3(x,y,z,u,v,w,s)
  autoscale = args{nin};
end

if length(autoscale)>1,
  error('S must be a scalar.');
end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n; 
  dely = diff([min(y(:)) max(y(:))])/m;
  delz = diff([min(z(:)) max(y(:))])/max(m,n);
  del = sqrt(delx.^2 + dely.^2 + delz.^2);
  if del>0
    len = sqrt((u/del).^2 + (v/del).^2 + (w/del).^2);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale; w = w*autoscale;
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% Make velocity vectors
x = x(:).'; y = y(:).'; z = z(:).';
u = u(:).'; v = v(:).'; w = w(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];
ww = [z;z+w;repmat(NaN,size(u))];

h1 = plot3('v6',uu(:),vv(:),ww(:),[col ls],'parent',cax);

if plotarrows,
  beta = beta * sqrt(u.*u + v.*v + w.*w) ./ (sqrt(u.*u + v.*v) + eps);

  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta.*(v+eps));x+u; ...
        x+u-alpha*(u-beta.*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta.*(u+eps));y+v; ...
        y+v-alpha*(v+beta.*(u+eps));repmat(NaN,size(v))];
  hw = [z+w-alpha*w;z+w;z+w-alpha*w;repmat(NaN,size(w))];

  hold(cax,'on')
  h2 = plot3(hu(:),hv(:),hw(:),[col ls],'parent',cax);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y; hw = z;
  hold(cax,'on')
  h3 = plot3(hu(:),hv(:),hw(:),[col ms],'parent',cax);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

if ~hold_state, hold(cax,'off'), view(cax,3); grid(cax,'on'), set(cax,'NextPlot',next); end

if nargout>0, hh = [h1;h2;h3]; end
