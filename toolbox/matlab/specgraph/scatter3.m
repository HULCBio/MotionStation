function hh = scatter3(varargin)
%SCATTER3 3-D Scatter plot.
%   SCATTER3(X,Y,Z,S,C) displays colored circles at the locations
%   specified by the vectors X,Y,Z (which must all be the same size).  The
%   area of each marker is determined by the values in the vector S (in
%   points^2) and the colors of each marker are based on the values in C.  S
%   can be a scalar, in which case all the markers are drawn the same
%   size, or a vector the same length as X,Y, and Z.
%   
%   When C is a vector the same length as X,Y, and Z, the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a LENGTH(X)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   SCATTER3(X,Y,Z) draws the markers with the default size and color.
%   SCATTER3(X,Y,Z,S) draws the markers with a single color.
%   SCATTER3(...,M) uses the marker M instead of 'o'.
%   SCATTER3(...,'filled') fills the markers.
%
%   SCATTER3(AX,...) plots into AX instead of GCA.
%
%   H = SCATTER3(...) returns handles to scatter objects created.
%
%   Backwards compatibility
%   SCATTER3('v6',...) creates patch objects instead of a scattergroup
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   Use PLOT3 for single color, single marker size 3-D scatter plots.
%
%   Example
%      [x,y,z] = sphere(16);
%      X = [x(:)*.5 x(:)*.75 x(:)];
%      Y = [y(:)*.5 y(:)*.75 y(:)];
%      Z = [z(:)*.5 z(:)*.75 z(:)];
%      S = repmat([1 .75 .5]*10,prod(size(x)),1);
%      C = repmat([1 2 3],prod(size(x)),1);
%      scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
%
%   See also SCATTER, PLOT3.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.5 $ $Date: 2004/02/01 22:05:45 $

[v6,args] = usev6plotapi(varargin{:});

if v6
  h = Lscatterv6(args{:});
else
  [cax,args,nargs] = axescheck(args{:});
  error(nargchk(1,inf,nargs));
  [pvpairs,args,nargs,msg] = parseargs(args, nargs);
  if ~isempty(msg), error(msg); end
 
  error(nargchk(3,7,nargs));

  cax = newplot(cax);

  switch (nargs)
   case 3
      [x,y,z] = deal(args{1:nargs});
      [ls,c,m] = nextstyle(cax);
      s = get(cax,'defaultlinemarkersize')^2;
   case 4
      [x,y,z,s] = deal(args{1:nargs});
      [ls,c,m] = nextstyle(cax);
   case 5
      [x,y,z,s,c] = deal(args{1:nargs});
   otherwise
      error('MATLAB:scatter3:invalidInput',...
            'Wrong number of input arguments.');
  end

  % Verify {X,Y,Z}data is correct size
  if any([length(x) length(y) length(z) ...
            prod(size(x)) prod(size(y)) prod(size(y))] ~= length(x))
     error('MATLAB:scatter3:invalidData',...
           'X,Y, and Z must be vectors of the same length.');
  end
  
  % Verify CData is correct size
  if isstr(c) | isequal(size(c),[1 3]); 
     % string color or scalar rgb 
  elseif length(c)==prod(size(c)), 
     % C is a vector
  elseif isequal(size(c),[length(x) 3]), 
     % vector of rgb's
  else
     error('MATLAB:scatter3:invalidCData',...
           ['C must be a single color, a vector the same length as X, ',...
            'or an M-by-3 matrix.'])
  end

  if isempty(s), s = 36; end

  % Verify correct S vector
  if length(s)~=1 && ...
    (length(s)~=prod(size(s)) || length(s)~=length(x))
    error('MATALB:scatter3:invalidSData',...
          'S must be a scalar or a vector the same length as X.')
  end

  cax = newplot(cax);

  h = specgraph.scattergroup('parent',cax,'xdata',x,'ydata',y,'zdata',z,...
                             'sizedata',s,'cdata',c,pvpairs{:});
  set(h,'refreshmode','auto');
  if ~ishold(cax), view(cax,3), grid(cax,'on'), end
  h = double(h);
end

if nargout>0, hh = h; end

%--------------------------------------------------
function [hh] = Lscatterv6(varargin)

[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(3,7,nargs))

cax = newplot(cax);
filled = 0;
scaled = 0;
marker = 'o';
c = '';

% Parse optional trailing arguments (in any order)
nin = nargs;
while nin > 0 & isstr(args{nin})
    if strcmp(args{nin},'filled'),
        filled = 1;
    else
        [l,ctmp,m,msg] = colstyle(args{nin});
        error(msg)
        if ~isempty(m), marker = m; end
        if ~isempty(ctmp), c = ctmp; end
    end
    nin = nin-1;
end
if isempty(marker), marker = 'o'; end
co = get(cax,'colororder');

switch nin
case 3  % scatter3(x,y,z)
    [x,y,z] = deal(args{1:3});
    if isempty(c),
        c = co(1,:);
    end
    s = get(cax,'defaultlinemarkersize')^2;
case 4 % scatter3(x,y,z,s)
    [x,y,z,s] = deal(args{1:4});
    if isempty(c),
        c = co(1,:);
    end
case 5  % scatter3(x,y,z,s,c)
    [x,y,z,s,c] = deal(args{1:5});
otherwise
    error('Wrong number of input arguments.');
end

if any([length(x) length(y) length(z) ...
            prod(size(x)) prod(size(y)) prod(size(y))] ~= length(x))
    error('X,Y, and Z must be vectors of the same length.');
end

% Map colors into colormap colors if necessary.
if isstr(c) | isequal(size(c),[1 3]); % string color or scalar rgb
    color = repmat(c,length(x),1);
elseif length(c)==prod(size(c)), % is C a vector?
    scaled = 1;
elseif isequal(size(c),[length(x) 3]), % vector of rgb's
    color = c;
else
    error(['C must be a single color, a vector the same length as X, ',...
            'or an M-by-3 matrix.'])
end

% Scalar expand the marker size if necessary
if length(s)==1, 
    s = repmat(s,length(x),1); 
elseif length(s)~=prod(size(s)) | length(s)~=length(x)
    error('S must be a scalar or a vector the same length as X.')
end

% Now draw the plot, one patch per point.
h = [];
% keeping track of scatter groups for legend
if isappdata(cax,'scattergroup');
    scattergroup=getappdata(cax,'scattergroup') + 1;
else
    scattergroup = 1;
end
setappdata(cax,'scattergroup',scattergroup);

for i=1:length(x),
    h = [h;patch('xdata',x(i),'ydata',y(i),'zdata',z(i),...
            'linestyle','none','facecolor','none',...
            'markersize',sqrt(s(i)), ...
            'marker',marker, ...
            'parent',cax)];
    % set scatter group for patch
    setappdata(h(end),'scattergroup',scattergroup); 
    if scaled,
        set(h(end),'cdata',c(i),'edgecolor','flat','markerfacecolor','flat');
    else
        set(h(end),'edgecolor',color(i,:),'markerfacecolor',color(i,:));
    end
    if ~filled,
        set(h(end),'markerfacecolor','none');
    end
    
end
if ~ishold(cax), view(cax,3), grid(cax,'on'), end

if nargout>0, hh = h; end


function [pvpairs,args,nargs,msg] = parseargs(args,nargs)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
n = 1;
extrapv = {};
% check for 'filled' or LINESPEC or ColorSpec
while length(pvpairs) >= 1 && n < 5 && isstr(pvpairs{1})
  arg = lower(pvpairs{1});
  if arg(1) == 'f'
    pvpairs(1) = [];
    extrapv = {'MarkerFaceColor','flat','MarkerEdgeColor','none', ...
               extrapv{:}};
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = {'LineStyle',l,extrapv{:}};
      end
      if ~isempty(c)
        extrapv = {'CData',ColorSpecToRGB(c),extrapv{:}};
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

function [color,msg] = ColorSpecToRGB(s)
color=[];
msg = [];
switch s
 case 'y'
  color = [1 1 0];
 case 'm'
  color = [1 0 1];
 case 'c'
  color = [0 1 1];
 case 'r'
  color = [1 0 0];
 case 'g'
  color = [0 1 0];
 case 'b'
  color = [0 0 1];
 case 'w'
  color = [1 1 1];
 case 'k'
  color = [0 0 0];
 otherwise
  msg = 'unrecognized color string';
end
