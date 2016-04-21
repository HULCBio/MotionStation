function hh = errorbar(varargin)
%ERRORBAR Error bar plot.
%   ERRORBAR(X,Y,L,U) plots the graph of vector X vs. vector Y with
%   error bars specified by the vectors L and U.  L and U contain the
%   lower and upper error ranges for each point in Y.  Each error bar
%   is L(i) + U(i) long and is drawn a distance of U(i) above and L(i)
%   below the points in (X,Y).  The vectors X,Y,L and U must all be
%   the same length.  If X,Y,L and U are matrices then each column
%   produces a separate line.
%
%   ERRORBAR(X,Y,E) or ERRORBAR(Y,E) plots Y with error bars [Y-E Y+E].
%   ERRORBAR(...,'LineSpec') uses the color and linestyle specified by
%   the string 'LineSpec'.  See PLOT for possibilities.
%
%   ERRORBAR(AX,...) plots into AX instead of GCA.
%
%   H = ERRORBAR(...) returns a vector of errorbarseries handles in H.
%
%   Backwards compatibility
%   ERRORBAR('v6',...) creates line objects instead of errorbarseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   For example,
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)
%   draws symmetric error bars of unit standard deviation.

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.19.4.8 $  $Date: 2004/02/01 22:05:39 $


[v6,args] = usev6plotapi(varargin{:});
if v6
  h = Lerrorbarv6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs));
  [pvpairs,args,nargs,msg] = parseargs(args, nargs);
  if ~isempty(msg), error(msg); end
  error(nargchk(2,4,nargs));

  hasXData = nargs ~= 2;
  switch nargs
   case 2
    [y,u] = deal(args{1:nargs});
    u = abs(u);
    l = u;
   case 3
    [x,y,u] = deal(args{1:nargs});
    if min(size(x))==1, x = x(:); end
    u = abs(u);
    l = u;
   case 4
    [x,y,l,u] = deal(args{1:nargs});
    if min(size(x))==1, x = x(:); end
  end
  if min(size(u))==1, u = u(:); end
  if min(size(l))==1, l = l(:); end
  if min(size(y))==1, y = y(:); end
  [m,n] = size(y);

  % handle vectorized data sources and display names
  extrapairs = cell(n,0);
  if ~isempty(pvpairs) && (n > 1)
    [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
                                            {'XDataSource','YDataSource',...
                        'UDataSource','LDataSource',...
                        'DisplayName'});
  end

  cax = newplot(cax);
  next = lower(get(cax,'NextPlot'));
  hold_state = ishold(cax);

  h = []; 
  autoColor = ~any(strcmpi('color',pvpairs(1:2:end)));
  autoStyle = ~any(strcmpi('linestyle',pvpairs(1:2:end)));
  xdata = {};
  for k=1:n
    % extract data from vectorizing over columns
    if hasXData
      xdata = {'XData', x(:,k)};
    end
    [ls,c,m] = nextstyle(cax,autoColor,autoStyle,k==1);
    h = [h specgraph.errorbarseries('YData',y(:,k),'UData',u(:,k),...
                                    'LData',l(:,k),xdata{:},...
                                    'Color',c,'LineStyle',ls,'Marker',m,...
                                    pvpairs{:},extrapairs{k,:},'parent',cax)];
  end
  if autoColor
    set(h,'CodeGenColorMode','auto');
  end
  set(h,'RefreshMode','auto');
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout>0, hh = h; end

function h = Lerrorbarv6(varargin)
% Parse possible Axes input
error(nargchk(2,6,nargin));
[cax,args,nargs] = axescheck(varargin{:});

x = args{1};
y = args{2};
if nargs > 2, l = args{3}; end
if nargs > 3, u = args{4}; end
if nargs > 4, symbol = args{5}; end

if min(size(x))==1,
  npt = length(x);
  x = x(:);
  y = y(:);
    if nargs > 2,
        if ~isstr(l),  
            l = l(:);
        end
        if nargs > 3
            if ~isstr(u)
                u = u(:);
            end
        end
    end
else
  [npt,n] = size(x);
end

if nargs == 3
    if ~isstr(l)  
        u = l;
        symbol = '-';
    else
        symbol = l;
        l = y;
        u = y;
        y = x;
        [m,n] = size(y);
        x(:) = (1:npt)'*ones(1,n);;
    end
end

if nargs == 4
    if isstr(u),    
        symbol = u;
        u = l;
    else
        symbol = '-';
    end
end


if nargs == 2
    l = y;
    u = y;
    y = x;
    [m,n] = size(y);
    x(:) = (1:npt)'*ones(1,n);;
    symbol = '-';
end

u = abs(u);
l = abs(l);
    
if isstr(x) | isstr(y) | isstr(u) | isstr(l)
    error('Arguments must be numeric.')
end

if ~isequal(size(x),size(y)) | ~isequal(size(x),size(l)) | ~isequal(size(x),size(u)),
  error('The sizes of X, Y, L and U must be the same.');
end

tee = (max(x(:))-min(x(:)))/100;  % make tee .02 x-distance for error bars
xl = x - tee;
xr = x + tee;
ytop = y + u;
ybot = y - l;
n = size(y,2);

% Plot graph and bars
cax = newplot(cax);
hold_state = ishold(cax);
next = lower(get(cax,'NextPlot'));

% build up nan-separated vector for bars
xb = zeros(npt*9,n);
xb(1:9:end,:) = x;
xb(2:9:end,:) = x;
xb(3:9:end,:) = NaN;
xb(4:9:end,:) = xl;
xb(5:9:end,:) = xr;
xb(6:9:end,:) = NaN;
xb(7:9:end,:) = xl;
xb(8:9:end,:) = xr;
xb(9:9:end,:) = NaN;

yb = zeros(npt*9,n);
yb(1:9:end,:) = ytop;
yb(2:9:end,:) = ybot;
yb(3:9:end,:) = NaN;
yb(4:9:end,:) = ytop;
yb(5:9:end,:) = ytop;
yb(6:9:end,:) = NaN;
yb(7:9:end,:) = ybot;
yb(8:9:end,:) = ybot;
yb(9:9:end,:) = NaN;

[ls,col,mark,msg] = colstyle(symbol); if ~isempty(msg), error(msg); end
symbol = [ls mark col]; % Use marker only on data part
esymbol = ['-' col]; % Make sure bars are solid

h = plot('v6',xb,yb,esymbol,'parent',cax); hold(cax,'on')
h = [h;plot('v6',x,y,symbol,'parent',cax)]; 

if ~hold_state, hold(cax,'off'); end

function [pvpairs,args,nargs,msg] = parseargs(args,nargs)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
% check for LINESPEC
if ~isempty(pvpairs)
  [l,c,m,tmsg]=colstyle(pvpairs{1},'plot');
  if isempty(tmsg)
    pvpairs = pvpairs(2:end);
    if ~isempty(l) 
      pvpairs = {'LineStyle',l,pvpairs{:}};
    end
    if ~isempty(c)
      pvpairs = {'Color',c,pvpairs{:}};
    end
    if ~isempty(m)
      pvpairs = {'Marker',m,pvpairs{:}};
    end
  end
end
msg = checkpvpairs(pvpairs);
nargs = length(args);
