function hh = bar(varargin)
%BAR Bar graph.
%   BAR(X,Y) draws the columns of the M-by-N matrix Y as M groups of N
%   vertical bars.  The vector X must be monotonically increasing or
%   decreasing.
%
%   BAR(Y) uses the default value of X=1:M.  For vector inputs, BAR(X,Y)
%   or BAR(Y) draws LENGTH(Y) bars.  The colors are set by the colormap.
%
%   BAR(X,Y,WIDTH) or BAR(Y,WIDTH) specifies the width of the bars. Values
%   of WIDTH > 1, produce overlapped bars.  The default value is WIDTH=0.8
%
%   BAR(...,'grouped') produces the default vertical grouped bar chart.
%   BAR(...,'stacked') produces a vertical stacked bar chart.
%   BAR(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BAR(AX,...) plots into AX instead of GCA.
%  
%   H = BAR(...) returns a vector of barseries handles in H.
%
%   Backwards compatibility
%   BAR('v6',...) creates patch objects instead of barseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   Use SHADING FACETED to put edges on the bars.  Use SHADING FLAT to
%   turn them off.
%
%   Examples: subplot(3,1,1), bar(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), bar(0:.25:1,rand(5),1)
%             subplot(3,1,3), bar(rand(2,3),.75,'grouped')
%
%   See also HIST, PLOT, BARH, BAR3, BAR3H.

%   C.B Moler 2-06-86
%   Modified 24-Dec-88, 2-Jan-92 LS.
%   Modified 8-5-91, 9-22-94 by cmt; 8-9-95 WSun.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.34.6.10 $  $Date: 2004/04/01 16:12:43 $

[v6,args] = usev6plotapi(varargin{:});
if v6 || ((length(args) > 1) && ...
          isa(args{end},'char') && ...
          (length(args{end}) > 3) && ...
          (strcmp(args{end}(1:4),'hist')))
  h = Lbarv6(args{:});
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
			      extrapairs{k,:}, 'Parent', cax)];
  end
  set(h,'BarPeers',h);
  set(h,'RefreshMode','auto');
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout>0, hh = h; end

function h = Lbarv6(varargin);
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
  f = 1:(numBars*5);
  f(1:5:(numBars*5)) = [];
  f = reshape(f, 4, numBars);
  f = f';

  v = [xx(:,i) yy(:,i)];

  h=[h patch('faces', f, 'vertices', v, 'cdata', i*cc, ...
             'FaceColor',facec,'EdgeColor',edgec,'parent',cax)];
end
if length(h)==1, 
    set(cax,'clim',[1 2]), 
end
if ~equal, 
  hold(cax,'on'),
  plot(x(:,1),zeros(size(x,1),1),'*','parent',cax)
end
if ~hold_state, 
  % Set ticks if less than 16 integers
  if all(all(floor(x)==x)) & (size(x,1)<16),  
    set(cax,'xtick',x(:,1))
  end
  hold(cax,'off'), view(cax,2), set(cax,'NextPlot',next);
  set(cax,'Layer','Bottom','box','on')
  % Turn off edges when they start to overwhelm the colors
  if size(xx,2)*numBars > 150, 
    set(h,{'edgecolor'},get(h,{'facecolor'}));
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
