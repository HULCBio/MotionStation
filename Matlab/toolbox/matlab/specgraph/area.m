function hh = area(varargin)
%AREA  Filled area plot.
%   AREA(X,Y) produces a stacked area plot suitable for showing the
%   contributions of various components to a whole.  
%
%   For vector X and Y, AREA(X,Y) is the same as PLOT(X,Y) except that
%   the area between 0 and Y is filled.  When Y is a matrix, AREA(X,Y)
%   plots the columns of Y as filled areas.  For each X, the net
%   result is the sum of corresponding values from the columns of Y.
%   X must be monotonic. 
%
%   AREA(Y) uses the default value of X=1:SIZE(Y,1).
%
%   AREA(X,Y,LEVEL) or AREA(Y,LEVEL) specifies the base level
%   for the area plot to be at the value y=LEVEL.  The default
%   value is LEVEL=0.
%
%   AREA(...,'Prop1',VALUE1,'Prop2',VALUE2,...) sets the specified
%   properties of the underlying areaseries objects.
%
%   AREA(AX,...) plots into axes with handle AX. Use GCA to get the 
%   handle to the current axes or to create one if none exist.
%
%   H = AREA(...) returns a vector of handles to areaseries objects.
%
%   Backwards compatibility
%   AREA('v6',...) creates patch objects instead of areaseries
%   objects for compatibility with MATLAB 6.5 and earlier.
%  
%   See also PLOT, BAR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.6 $  $Date: 2004/02/01 22:05:33 $

[v6,args] = usev6plotapi(varargin{:});
if v6
  h = Lareav6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  [args,pvpairs,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
  nargs = length(args);

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
  
  % Create plot
  cax = newplot(cax);

  next = lower(get(cax,'NextPlot'));
  hold_state = ishold(cax);
  h = []; 
  xdata = {};
  for k=1:n
    % extract data from vectorizing over columns
    if hasXData
      xdata = {'XData', x(:,k)};
    end
    h = [h specgraph.areaseries('YData',y(:,k), xdata{:}, pvpairs{:},...
			      extrapairs{k,:}, 'Parent', cax)];
  end
  set(h,'AreaPeers',h);
  set(h,'RefreshMode','auto');

  if ~hold_state, 
    view(cax,2); set(cax,'NextPlot',next); set(cax,'Box','on')
    set(cax,'XLim',[min(x(:)) max(x(:))],'CLim',[1 max(n,2)])
  end
  plotdoneevent(cax,h);
  h = double(h);
end
if nargout>0, hh = h; end

function h = Lareav6(varargin)
[cax,args,nargs] = axescheck(varargin{:});
ax = newplot(cax);
next = lower(get(ax,'NextPlot'));
hold_state = ishold;

% Search for the beginning of the prop,value pairs.
for i=1:length(args),
  if isstr(args{i}), nargs = i-1; break, end
end

if nargs<3, level = 0; end

% Make sure x and y are the same size
if nargs<1, 
  error('Not enough input arguments.');
elseif nargs==1, % area(y)
  [msg,x,y] = xychk(args{1},'plot');
elseif nargs==2 % area(x,y) or area(y,level)
  % area(y,level)
  if ~isequal(size(args{1}),size(args{2})) & ...
      length(args{2})==1, 
    [msg,x,y] = xychk(args{1},'plot');
    level = args{2};
  else
    [msg,x,y] = xychk(args{1:2},'plot');
  end
else % area(x,y,level)
  [msg,x,y] = xychk(args{1:2},'plot');
  level = args{3};
end
if ~isempty(msg), error(msg); end
if all(size(level))~=1, error('LEVEL must be a scalar.'); end

if min(size(y))==1, y = y(:); x = x(:); end
[m,n] = size(y);

if n>1,
  % Check for the same x spacing
  if all(all(abs(diff(x')')<eps)), 
    y = cumsum(y')'; % Use fast calculation
  else
    xi = sort(x(:));
    yi = zeros(length(xi),size(y,2));
    for i=1:n,
      yi(:,i) = interp1(x(:,i),y(:,i),xi);
    end
    d = find(isnan(yi(:,1))); 
    if ~isempty(d), yi(d,1) = level(ones(size(d))); end
    d = find(isnan(yi)); 
    if ~isempty(d), yi(d) = zeros(size(d)); end
    x = xi(:,ones(1,n));
    y = cumsum(yi')';
    [m,n] = size(y);
  end
  xx = [x(1,:);x;flipud(x)];
  yy = [level(ones(m,1)) y];
  yy = [yy(1,1:end-1);yy(:,2:end);flipud(yy(:,1:end-1))];
else
  xx = [x(1,:);x;flipud(x)];
  yy = [level;y;level(ones(m,1))];
end

h = []; cc = ones(size(xx,1),1);
for i=1:size(y,2),
  h = [h,patch('xdata',xx(:,i),'ydata',yy(:,i),'cdata',i*cc, ...
      'faceColor','flat','edgecolor',get(ax,'xcolor'), ...
      args{nargs+1:end})];
end

if ~hold_state, 
   view(2); set(ax,'NextPlot',next); set(ax,'box','on')
   set(ax,'xlim',[min(xx(:)) max(xx(:))],'clim',[1 max(n,2)])
end

function [args,pvpairs,msg] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
% check for base value
if length(args) > 1 && length(args{end}) == 1 && ...
      ~((length(args) == 2) && (length(args{1}) == 1) && (length(args{2}) == 1))
    pvpairs = {'BaseValue',args{end},pvpairs{:}};
    args(end) = [];
end
msg = checkpvpairs(pvpairs,false);
