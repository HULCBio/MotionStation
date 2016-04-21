function hh = barh(varargin)
%BARH Horizontal bar graph.
%   BARH(X,Y) draws the columns of the M-by-N matrix Y as M groups of
%   N horizontal bars.  The vector X must be monotonically increasing
%   or decreasing.
%
%   BARH(Y) uses the default value of X=1:M.  For vector inputs,
%   BARH(X,Y) or BARH(Y) draws LENGTH(Y) bars.  The colors are set by
%   the colormap.
%
%   BARH(X,Y,WIDTH) or BARH(Y,WIDTH) specifies the width of the
%   bars. Values of WIDTH > 1, produce overlapped bars.  The
%   default value is WIDTH=0.8.
%
%   BARH(...,'grouped') produces the default vertical grouped bar chart.
%   BARH(...,'stacked') produces a vertical stacked bar chart.
%   BARH(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BARH(AX,...) plots into AX instead of GCA.
%
%   BARH(AX,...) plots into AX instead of GCA.
%  
%   H = BARH(...) returns a vector of barseries handles in H.
%
%   Backwards compatibility
%   BARH('v6',...) creates patch objects instead of barseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   Use SHADING FACETED to put edges on the bars.  Use SHADING FLAT to
%   turn them off.
%
%   Examples: subplot(3,1,1), barh(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), barh(0:.25:1,rand(5),1)
%             subplot(3,1,3), barh(rand(2,3),.75,'grouped')
%
%   See also PLOT, BAR, BAR3, BAR3H.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.16.6.10 $  $Date: 2004/04/01 16:12:44 $

[v6,args] = usev6plotapi(varargin{:});
if v6 || ((length(args) > 1) && ...
          isa(args{end},'char') && ...
          (length(args{end}) > 3) && ...
          (strcmp(args{end}(1:4),'hist')))
  h = Lbarhv6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs,'struct'));
  [args,pvpairs,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
  nargs = length(args);

  [msg,x,y] = xychk(args{1:nargs},'plot');
  if ~isempty(msg), error(msg); end
  hasXData = nargs ~= 1;
  if min(size(x))==1, x = x(:); end
  if min(size(y))==1, y = y(:); end
  [m,n] = size(y);
  numBars = m;

  % handle vectorized data sources and display names
  extrapairs = cell(n,0);
  if ~isempty(pvpairs) && (n > 1)
    [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
                                            {'XDataSource','YDataSource','DisplayName'});
  end

  % Create plot
  cax = newplot(cax);

  h = []; 
  xdata = {};
  for k=1:n
    % extract data from vectorizing over columns
    if hasXData
      xdata = {'XData', x(:,k)};
    end
    h = [h specgraph.barseries('YData',y(:,k), xdata{:}, pvpairs{:},...
                               'horizontal','on',...
			      extrapairs{k,:}, 'Parent', cax)];
  end
  set(h,'BarPeers',h);
  set(h,'RefreshMode','auto');
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout>0, hh = h; end

function h = Lbarhv6(varargin);
error(nargchk(1,inf,nargin));
[cax,args,nargs] = axescheck(varargin{:});

[msg,x,y,xx,yy,linetype,plottype,barwidth,equal] = makebars(args{:});
if ~isempty(msg), 
    error(msg); 
end

% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);
edgec = get(fig,'defaultaxesxcolor');
facec = 'flat';
h = []; 
cc = ones(size(xx,1),1);
if ~isempty(linetype), 
    facec = linetype; 
end
for i=1:size(xx,2)
  numBars = (size(xx,1)-1)/5;
  for j=1:numBars,
     f(j,:) = (2:5) + 5*(j-1);
  end
  v = [yy(:,i) xx(:,i)];
  h=[h patch('faces', f, 'vertices', v, 'cdata', i*cc, ...
        'FaceColor',facec,'EdgeColor',edgec,'parent',cax)];
end
if length(h)==1, 
    set(cax,'clim',[1 2]), 
end
if ~equal, 
  hold(cax,'on'),
  plot(zeros(size(x,1),1),x(:,1),'*','parent',cax)
end
if ~hold_state, 
  % Set ticks if less than 16 integers
  if all(all(floor(x)==x)) & (size(x,1)<16),  
    set(cax,'ytick',x(:,1))
  end
  hold(cax,'off'), view(cax,2), set(cax,'NextPlot',next);
  set(cax,'Layer','Bottom','box','on')
  % Switch to SHADING FLAT when the edges start to overwhelm the colors
  if size(xx,2)*numBars > 150, 
      shading flat, 
  end
end

function [args,pvpairs,msg] = parseargs(args)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
% check for LINESPEC or bar layout
done = false;
while ~isempty(pvpairs) && ~done
  arg = pvpairs{1};
  [l,c,m,tmsg]=colstyle(arg,'plot');
  if isempty(tmsg)
    pvpairs = pvpairs(2:end);
    if ~isempty(l) 
      pvpairs = {pvpairs{:},'LineStyle',l};
    end
    if ~isempty(c)
      pvpairs = {pvpairs{:},'FaceColor',c}; % note FaceColor, not Color
    end
    if ~isempty(m)
      pvpairs = {pvpairs{:},'Marker',m};
    end
  elseif any(strcmpi(arg(1:min(4,length(arg))),{'grou','stac'}))
    pvpairs = {pvpairs{2:end},'BarLayout',arg};
  else
    done = true; % stop looping
  end
end
% check for bar width
if length(args) > 1 && length(args{end}) == 1 && ...
      ~((length(args) == 2) && (length(args{1}) == 1) && (length(args{2}) == 1))
    pvpairs = {'BarWidth',args{end},pvpairs{:}};
    args(end) = [];
end
msg = checkpvpairs(pvpairs,false);
