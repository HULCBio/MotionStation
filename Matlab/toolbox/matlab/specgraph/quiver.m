function hh = quiver(varargin)
%QUIVER Quiver plot.
%   QUIVER(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVER(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVER(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the 
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER(...,'filled') fills any markers specified.
%
%   QUIVER(AX,...) plots into AX instead of GCA.
%
%   H = QUIVER(...) returns a quivergroup handle.
%
%   Backwards compatibility
%   QUIVER('v6',...) creates line objects instead of a quivergroup
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.21.6.9 $  $Date: 2004/02/01 22:05:42 $

[v6,args] = usev6plotapi(varargin{:});
if v6
  h = Lquiverv6(args{:});
else
  error(nargchk(1,inf,nargin));
  % Parse possible Axes input
  [cax,args,nargs] = axescheck(args{:});
  [pvpairs,args,nargs] = parseargs(args,nargs);
  
  cax = newplot(cax);
  [ls,c,m] = nextstyle(cax);

  h = specgraph.quivergroup('Color',c,'LineStyle',ls,...
                            'parent',cax,pvpairs{:});

  if ~any(strcmpi('color',pvpairs(1:2:end)))
    set(h,'CodeGenColorMode','auto');
  end
  set(h,'refreshmode','auto');
  if ~ishold(cax), box(cax,'on'); end
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout>0, hh = h; end

function h = Lquiverv6(varargin)
[cax,args,nargs] = axescheck(varargin{:});

% Arrow head parameters
alpha = 0.33; % Size of arrow head relative to the length of the vector
beta = 0.33;  % Width of the base of the arrow head relative to the length
autoscale = 1; % Autoscale if ~= 0 then scale by this.
plotarrows = 1; % Plot arrows
sym = '';

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

error(nargchk(2,5,nin));

% Check numeric input arguments
if nin<4, % quiver(u,v) or quiver(u,v,s)
  [msg,x,y,u,v] = xyzchk(args{1:2});  % "xyzchk(Z,C)"
else
  [msg,x,y,u,v] = xyzchk(args{1:4});  % "xyzchk(X,Y,Z,C)"
end
if ~isempty(msg), 
  if isstruct(msg)
    % make the xyzchk message match quiver's help string:
    msg.message = strrep(msg.message, 'Z', 'U');
    msg.message = strrep(msg.message, 'C', 'V');
    msg.identifier = strrep(msg.identifier, 'Z', 'U');
    msg.identifier = strrep(msg.identifier, 'C', 'V');
  else
    msg = strrep(msg, 'Z', 'U');
    msg = strrep(msg, 'C', 'V');
  end        
  error(msg); 
end

if nin==3 | nin==5, % quiver(u,v,s) or quiver(x,y,u,v,s)
  autoscale = args{nin};
end

% Scalar expand u,v
if prod(size(u))==1, u = u(ones(size(x))); end
if prod(size(v))==1, v = v(ones(size(u))); end

if autoscale,
  % Base autoscale value on average spacing in the x and y
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if x and y are vectors.
  if min(size(x))==1, n=sqrt(prod(size(x))); m=n; else [m,n]=size(x); end
  delx = diff([min(x(:)) max(x(:))])/n;
  dely = diff([min(y(:)) max(y(:))])/m;
  del = delx.^2 + dely.^2;
  if del>0
    len = sqrt((u.^2 + v.^2)/del);
    maxlen = max(len(:));
  else
    maxlen = 0;
  end
  
  if maxlen>0
    autoscale = autoscale*0.9 / maxlen;
  else
    autoscale = autoscale*0.9;
  end
  u = u*autoscale; v = v*autoscale;
end

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% Make velocity vectors
x = x(:).'; y = y(:).';
u = u(:).'; v = v(:).';
uu = [x;x+u;repmat(NaN,size(u))];
vv = [y;y+v;repmat(NaN,size(u))];

h1 = plot('v6',uu(:),vv(:),[col ls],'parent',cax);

if plotarrows,
  % Make arrow heads and plot them
  hu = [x+u-alpha*(u+beta*(v+eps));x+u; ...
        x+u-alpha*(u-beta*(v+eps));repmat(NaN,size(u))];
  hv = [y+v-alpha*(v-beta*(u+eps));y+v; ...
        y+v-alpha*(v+beta*(u+eps));repmat(NaN,size(v))];
  hold(cax,'on')
  h2 = plot('v6',hu(:),hv(:),[col ls],'parent',cax);
else
  h2 = [];
end

if ~isempty(ms), % Plot marker on base
  hu = x; hv = y;
  hold(cax,'on')
  h3 = plot('v6',hu(:),hv(:),[col ms],'parent',cax);
  if filled, set(h3,'markerfacecolor',get(h1,'color')); end
else
  h3 = [];
end

if ~hold_state, hold(cax,'off'), view(cax,2); set(cax,'NextPlot',next); end

h = [h1;h2;h3];

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
if (nargs == 2)
  pvpairs = {pvpairs{:},'udata',args{1},'vdata',args{2}};
elseif (nargs == 4)
  pvpairs = {pvpairs{:},'xdata',args{1},'ydata',args{2},...
	     'udata',args{3},'vdata',args{4}};
end
