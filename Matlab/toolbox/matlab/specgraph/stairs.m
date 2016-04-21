function [xo,yo] = stairs(varargin)
%STAIRS Stairstep plot.
%   STAIRS(Y) draws a stairstep graph of the elements of vector Y.
%
%   STAIRS(X,Y) draws a stairstep graph of the elements in vector Y at
%   the locations specified in X.  The X-values must be in
%   ascending order and evenly spaced.
%
%   STAIRS(...,STYLE) uses the plot linestyle specified by the
%   string STYLE.
%
%   STAIRS(AX,...) plots into AX instead of GCA.
%
%   H = STAIRS(X,Y) returns a vector of stairseries handles.
%
%   Backwards compatibility
%   STAIRS('v6',...) creates line objects instead of stairseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   [XX,YY] = STAIRS(X,Y) does not draw a graph, but returns vectors
%   X and Y such that PLOT(XX,YY) is the stairstep graph.
%
%   The above inputs to STAIRS can be followed by property/value
%   pairs to specify additional properties of the stairseries object.
%
%   Stairstep plots are useful for drawing time history plots of
%   zero-order-hold digital sampled-data systems.
%
%   See also BAR, HIST, STEM.

%   L. Shure, 12-22-88.
%   Revised A.Grace and C.Thompson 8-22-90.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.8 $  $Date: 2004/02/01 22:05:46 $

[v6,args] = usev6plotapi(varargin{:});
if v6 || (nargout == 2)
  if (nargout == 2)
    [xo,yo] = Lstairsv6(args{:});
  else
    h = Lstairsv6(args{:});
  end
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs));
  [pvpairs,args,nargs,msg] = parseargs(args, nargs);
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
  autoColor = ~any(strcmpi('color',pvpairs(1:2:end)));
  autoStyle = ~any(strcmpi('linestyle',pvpairs(1:2:end)));
  xdata = {};
  for k=1:n
    % extract data from vectorizing over columns
    if hasXData
      xdata = {'XData', x(:,k)};
    end
    [l,c,m] = nextstyle(cax,autoColor,autoStyle,k==1);
    h = [h specgraph.stairseries('YData',y(:,k),xdata{:},...
                                 'Color',c,'LineStyle',l,'Marker',m,...
                                 pvpairs{:},extrapairs{k,:},'parent',cax)];
  end
  if autoColor
    set(h,'CodeGenColorMode','auto');
  end
  set(h,'RefreshMode','auto');
  if ~hold_state, set(cax,'NextPlot',next); set(cax,'Box','on'); end
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout==1, xo = h(:); end

function [xo,yo] = Lstairsv6(varargin)
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs));

sym = [];

% Parse the inputs
if isstr(args{nargs}), % stairs(y,'style') or stairs(x,y,'style')
  sym = args{nargs};
  [msg,x,y] = xychk(args{1:nargs-1},'plot');
  if ~isempty(msg), error(msg); end
else % stairs(y), or stairs(x,y)
  [msg,x,y] = xychk(args{1:nargs},'plot');
  if ~isempty(msg), error(msg); end
end

if min(size(x))==1, x = x(:); end
if min(size(y))==1, y = y(:); end

[n,nc] = size(y); 
ndx = [1:n;1:n];
y2 = y(ndx(1:2*n-1),:);
if size(x,2)==1,
  x2 = x(ndx(2:2*n),ones(1,nc));
else
  x2 = x(ndx(2:2*n),:);
end

if (nargout < 2)
    % Create the plot
    cax = newplot(cax);
  if isempty(sym),
    h = plot(x2,y2,'parent',cax);
  else
    h = plot(x2,y2,sym,'parent',cax);
  end
  if nargout==1, xo = h; end
else
    xo = x2; 
    yo = y2;
end

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
      pvpairs = {'Linestyle',l,pvpairs{:}};
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
