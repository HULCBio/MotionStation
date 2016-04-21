function hh = stem(varargin)
%STEM   Discrete sequence or "stem" plot.
%   STEM(Y) plots the data sequence Y as stems from the x axis
%   terminated with circles for the data value. If Y is a matrix then
%   each column is plotted as a separate series.
%
%   STEM(X,Y) plots the data sequence Y at the values specified
%   in X.
%
%   STEM(...,'filled') produces a stem plot with filled markers.
%
%   STEM(...,'LINESPEC') uses the linetype specified for the stems and
%   markers.  See PLOT for possibilities.
%
%   STEM(AX,...) plots into axes with handle AX. Use GCA to get the 
%   handle to the current axes or to create one if none exist.
% 
%   H = STEM(...) returns a vector of stemseries handles in H, one handle
%   per column of data in Y.
%
%   Backwards compatibility
%   STEM('v6',...) creates line objects instead of stemseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   See also PLOT, BAR, STAIRS.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.19.4.8 $  $Date: 2004/02/01 22:05:47 $

[v6,args] = usev6plotapi(varargin{:});
if v6
  h = Lstemv6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs));
  [pvpairs,args,nargs,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
  error(nargchk(1,2,nargs));

  [msg,x,y] = xychk(args{1:nargs},'plot');
  if ~isempty(msg), error(msg); end
  hasXData = nargs ~= 1;
  if min(size(x))==1, x = x(:); end
  if min(size(y))==1, y = y(:); end
  [m,n] = size(y);

  % handle vectorized data sources and display names
  extrapairs = cell(n,0);
  if ~isempty(pvpairs) && (n > 1)
    [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
                                            {'XDataSource','YDataSource','DisplayName'});
  end

  cax = newplot(cax);
  next = lower(get(cax,'NextPlot'));
  hold_state = ishold(cax);
  
  h = []; 
  autoColor = ~any(strcmpi('Color',pvpairs(1:2:end)));
  autoStyle = ~any(strcmpi('LineStyle',pvpairs(1:2:end)));
  origpvpairs = pvpairs;
  xdata = {};
  for k=1:n
    % extract data from vectorizing over columns
    if hasXData
      xdata = {'XData', x(:,k)};
    end
    [l,c,m] = nextstyle(cax,autoColor,autoStyle,k==1);
    if ~isempty(m) && ~strcmp(m,'none')
      pvpairs = {'Marker',m,origpvpairs{:}};
    end
    h = [h specgraph.stemseries('YData',y(:,k), xdata{:},...
                                'Color',c,'LineStyle',l,...
			      pvpairs{:},extrapairs{k,:}, 'Parent', cax)];
  end

  if autoColor
    set(h,'CodeGenColorMode','auto');
  end
  if autoStyle
    set(h,'CodeGenLineStyleMode','auto');
  end
  if ~any(strcmpi('marker',pvpairs(1:2:end)))
    set(h,'CodeGenMarkerMode','auto');
  end
  if ~hold_state, set(cax,'NextPlot',next); end
  set(h,'RefreshMode','auto');
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout>0, hh = h; end

function h = Lstemv6(varargin)
[cax,args,nargs] = axescheck(varargin{:});
nin = nargs;

fill = 0;
ls = '-';
ms = 'o';
col = '';

% Parse the string inputs
while isstr(args{nin}),
  v = args{nin};
  if ~isempty(v) & strcmp(lower(v(1)),'f')
    fill = 1;
    nin = nin-1;
  else
    [l,c,m,msg] = colstyle(v);
    if ~isempty(msg), 
      error(sprintf('Unknown option "%s".',v));
    end
    if ~isempty(l), ls = l; end
    if ~isempty(c), col = c; end
    if ~isempty(m), ms = m; end
    nin = nin-1;
  end
end

error(nargchk(1,2,nin));

[msg,x,y] = xychk(args{1:nin},'plot');
if ~isempty(msg), error(msg); end

if min(size(x))==1, x = x(:); end
if min(size(y))==1, y = y(:); end

% Set up data using fancing indexing
[m,n] = size(x);
xx = zeros(3*m,n);
xx(1:3:3*m,:) = x;
xx(2:3:3*m,:) = x;
xx(3:3:3*m,:) = NaN;

[m,n] = size(y);
yy = zeros(3*m,n);
yy(2:3:3*m,:) = y;
yy(3:3:3*m,:) = NaN;

cax = newplot(cax);
next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

h1 = plot('v6',x,y,[col,ms],'parent',cax); hold(cax,'on'),
h2 = plot('v6',xx,yy,[col,ls],'parent',cax);
for i=1:length(h1), % Make the color of the 'o's the same as the lines.
  c = get(h2(i),'Color');
  set(h1(i),'Color',c)
  if fill, set(h1(i),'MarkerFaceColor',c), end
end

h3 = graph2d.constantline(0,'parent',cax); % draw horizontal line through 0
set(h3,'XLimInclude','off','YLimInclude','off','ZLimInclude', ...
       'off');

h = [h1;h2;double(h3)];
if ~hold_state, set(cax,'NextPlot',next); end

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
        extrapv = {'LineStyle',l,extrapv{:}};
      end
      if ~isempty(c)
        extrapv = {'Color',c,extrapv{:}};
      end
      if ~isempty(m)
        extrapv = {'Marker',m,extrapv{:}};
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);