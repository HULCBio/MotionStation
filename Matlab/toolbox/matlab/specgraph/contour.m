function [cout, hand] = contour(varargin)
%CONTOUR Contour plot.
%   CONTOUR(Z) is a contour plot of matrix Z treating the values in Z
%   as heights above a plane.  A contour plot are the level curves
%   of Z for some values V.  The values V are chosen automatically.
%   CONTOUR(X,Y,Z) X and Y specify the (x,y) coordinates of the
%   surface as for SURF.
%   CONTOUR(Z,N) and CONTOUR(X,Y,Z,N) draw N contour lines, 
%   overriding the automatic value.
%   CONTOUR(Z,V) and CONTOUR(X,Y,Z,V) draw LENGTH(V) contour lines 
%   at the values specified in vector V.  Use CONTOUR(Z,[v v]) or
%   CONTOUR(X,Y,Z,[v v]) to compute a single contour at the level v. 
%   CONTOUR(AX,...) plots into AX instead of GCA.
%   [C,H] = CONTOUR(...) returns contour matrix C as described in
%   CONTOURC and a handle H to a contourgroup object.  This handle can
%   be used as input to CLABEL.
%
%   Backwards compatibility
%   CONTOUR('v6',...) creates patch objects instead of a contourgroup
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   The contours are normally colored based on the current colormap
%   and are drawn as PATCH objects. You can override this behavior
%   with the syntax CONTOUR(...,LINESPEC) to draw the contours
%   with the color and linetype specified. See the help for PLOT
%   for more information about LINESPEC values.
%
%   The above inputs to CONTOUR can be followed by property/value
%   pairs to specify additional properties of the contour object.
%
%   Uses code by R. Pawlowicz to handle parametric surfaces and
%   inline contour labels.
%
%   Example:
%      [c,h] = contour(peaks); clabel(c,h), colorbar
%
%   See also CONTOUR3, CONTOURF, CLABEL, COLORBAR.

%   Additional details:
%
%   CONTOUR uses CONTOUR3 to do most of the contouring.  Unless
%   a linestyle is specified, CONTOUR will draw PATCH objects
%   with edge color taken from the current colormap.  When a linestyle
%   is specified, LINE objects are drawn. To produce the same results
%   as MATLAB 4.2c, use CONTOUR('v6',...,'-').
%
%   Thanks to R. Pawlowicz (IOS) rich@ios.bc.ca for 'contours.m' and 
%   'clabel.m/inline_labels' so that contour now works with parametric
%   surfaces and inline contour labels.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.18.4.9 $  $Date: 2004/03/02 21:48:46 $

[v6,args] = usev6plotapi(varargin{:});
if v6
  [c,h] = Lcontourv6(args{:});
else
  % Parse possible Axes input
  error(nargchk(1,inf,nargin));
  [cax,args,nargs] = axescheck(args{:});
  [pvpairs,args,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
  
  cax = newplot(cax);
  h = specgraph.contourgroup('parent',cax,pvpairs{:});
  set(h,'refreshmode','auto');
  c = get(h,'contourmatrix');
  
  if ~ishold(cax)
    view(cax,2);
    set(cax,'box','on','layer','top');
    grid(cax,'off')
  end
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout > 0
    cout = c;
    hand = h;
end

function [c,h] = Lcontourv6(varargin)  
% Parse possible Axes input
error(nargchk(1,6,nargin));
[cax,args,nargs] = axescheck(varargin{:});

cax = newplot(cax);

[c,h,msg] = contour3(cax,args{:});
if ~isempty(msg), error(msg); end

set(h,'ZData',[]);

if ~ishold(cax)
  view(cax,2);
  set(cax,'Box','on');
  grid(cax,'off')
end

function [pvpairs,args,msg] = parseargs(args)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);

% check for special string arguments trailing data arguments
if ~isempty(pvpairs)
  [l,c,m,tmsg]=colstyle(pvpairs{1});
  if isempty(tmsg)
    args = {args{:},pvpairs{1}};
    pvpairs = pvpairs(2:end);
  end
  msg = checkpvpairs(pvpairs);
end

nargs = length(args);

if ischar(args{end}) 
  [l,c,m,tmsg] = colstyle(args{end});
  if ~isempty(tmsg), 
    msg = sprintf('Unknown option "%s".',args{end});
  end
  if ~isempty(c)
    pvpairs = {'linecolor',c,pvpairs{:}};
  end
  if ~isempty(l)
    pvpairs = {'linestyle',l,pvpairs{:}};
  end
  nargs = nargs - 1;
end
if (nargs == 2) || (nargs == 4)
  if (nargs == 2)
    pvpairs = {'zdata',double(args{1}),pvpairs{:}};
    z = args{1};
  else
    pvpairs = {'xdata',double(args{1}),'ydata',double(args{2}),...
               'zdata',double(args{3}),pvpairs{:}};
    z = args{3};
  end
  if (length(args{nargs}) == 1) && (fix(args{nargs}) == args{nargs})
    % N
    zmin = min(real(double(z(:))));
    zmax = max(real(double(z(:))));
    if args{nargs} == 1
      pvpairs = {'levellist',(zmin+zmax)/2, pvpairs{:}};
    else
      pvpairs = {'levellist',linspace(zmin,zmax,args{nargs}), ...
                 pvpairs{:}};
    end
  else
    % levels
    pvpairs = {'levellist',unique(args{nargs}),pvpairs{:}};
  end
elseif (nargs == 1)
  pvpairs = {'zdata',double(args{1}),pvpairs{:}};
elseif (nargs == 3)
  pvpairs = {'xdata',double(args{1}),'ydata',double(args{2}),...
             'zdata',double(args{3}),pvpairs{:}};
end

args = [];
