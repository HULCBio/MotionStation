function [cout,hand,CF] = contourf(varargin)
%CONTOURF Filled contour plot.
%   CONTOURF(...) is the same as CONTOUR(...) except that the contours
%   are filled.  Areas of the data at or above a given level are filled.
%   Areas below a level are either left blank or are filled by a lower
%   level.  NaN's in the data leave holes in the filled contour plot.
%
%   C = CONTOURF(...) returns contour matrix C as described in CONTOURC
%   and used by CLABEL.
%
%   [C,H] = CONTOURF(...) also returns a handle H to a CONTOUR object.
%
%   Backwards compatibility
%   CONTOURF('v6',...) creates patch objects instead of a contourgroup
%   object for compatibility with MATLAB 6.5 and earlier.
%  
%   Example:
%      z=peaks; 
%      [c,h] = contourf(z); clabel(c,h), colorbar
%
%   See also CONTOUR, CONTOUR3, CLABEL, COLORBAR.

%   Author: R. Pawlowicz (IOS)  rich@ios.bc.ca   12/14/94
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.31.4.6 $  $Date: 2004/02/01 22:05:38 $

[v6,args] = usev6plotapi(varargin{:});
if v6 || (nargout == 3)
  [c,h,cs] = Lcontourfv6(args{:});
else
  % Parse possible Axes input
  error(nargchk(1,6,nargin));
  [cax,args,nargs] = axescheck(args{:});
  [pvpairs,args,msg] = parseargs(args);
  if ~isempty(msg), error(msg); end
  
  cax = newplot(cax);
  h = specgraph.contourgroup('parent',cax,'fill','on',...
                             'linecolor',[0 0 0],pvpairs{:});
  set(h,'refreshmode','auto');
  c = get(h,'contourmatrix');
  cs = 0;
  
  if ~ishold(cax)
    view(cax,2);
    set(cax,'Box','on','Layer','top');
    grid(cax,'off')
  end
  plotdoneevent(cax,h);
  h = double(h);
end

if nargout > 0
    cout = c;
    hand = h;
    cf = cs;
end

function [c,h,CS] = Lcontourfv6(varargin)  
% Parse possible Axes input
error(nargchk(1,6,nargin));
[cax,args,nargs] = axescheck(varargin{:});

% Create the plot
cax = newplot(cax);

% Check for empty arguments.
for i = 1:nargs
  if isempty(args{i})
    error ('Invalid Argument - Input matrix is empty');
  end
end

% Trim off the last arg if it's a string (line_spec).
nin = nargs;
if isstr(args{end})
  [lin,col,mark,msg] = colstyle(args{end});
  if ~isempty(msg), error(msg); end
  nin = nin - 1;
else
  lin = '';
  col = '';
end

if (nin == 4),
   [x,y,z,nv] = deal(args{1:4});
   if (size(y,1)==1), y=y'; end;
   if (size(x,2)==1), x=x'; end;
   [mz,nz] = size(z);
elseif (nin == 3),
  [x,y,z] = deal(args{1:3});
  nv = [];
  if (size(y,1)==1), y=y'; end;
  if (size(x,2)==1), x=x'; end;
  [mz,nz] = size(z);
elseif (nin == 2),
  [z,nv] = deal(args{1:2});
  [mz,nz] = size(z);
  x = 1:nz;
  y = (1:mz)';
elseif (nin == 1),
  z = args{1};
  [mz,nz] = size(z);
  x = 1:nz;
  y = (1:mz)';
  nv = [];
end

if nin <= 2,
    [mc,nc] = size(args{1});
    lims = [1 nc 1 mc];
else
    lims = [min(args{1}(:)),max(args{1}(:)), ...
            min(args{2}(:)),max(args{2}(:))];
end

i = find(isfinite(z));
minz = min(z(i));
maxz = max(z(i));

% Generate default contour levels if they aren't specified 
if length(nv) <= 1
  if isempty(nv)
    CS=contourc([minz maxz ; minz maxz]);
  else
    CS=contourc([minz maxz ; minz maxz],nv);
  end

  % Find the levels
  ii = 1;
  nv = minz; % Include minz so that the contours are totally filled 
  while (ii < size(CS,2)),
    nv=[nv CS(1,ii)];
    ii = ii + CS(2,ii) + 1;
  end
end

% Don't fill contours below the lowest level specified in nv.
% To fill all contours, specify a value of nv lower than the
% minimum of the surface. 
draw_min=0;
if any(nv <= minz),
  draw_min=1;
end

% Get the unique levels
nv = sort([minz nv(:)']);
zi = [1, find(diff(nv))+1];
nv = nv(zi);

% Surround the matrix by a very low region to get closed contours, and
% replace any NaN with low numbers as well.

zz=[ repmat(NaN,1,nz+2) ; repmat(NaN,mz,1) z repmat(NaN,mz,1) ; repmat(NaN,1,nz+2)];
kk=find(isnan(zz(:)));
zz(kk)=minz-1e4*(maxz-minz)+zeros(size(kk));

xx = [2*x(:,1)-x(:,2), x, 2*x(:,nz)-x(:,nz-1)];
yy = [2*y(1,:)-y(2,:); y; 2*y(mz,:)-y(mz-1,:)];
if (min(size(yy))==1),
  [CS,msg]=contours(xx,yy,zz,nv);
else
  [CS,msg]=contours(xx([ 1 1:mz mz],:),yy(:,[1 1:nz nz]),zz,nv);
end;
if ~isempty(msg), error(msg); end

% Find the indices of the curves in the c matrix, and get the
% area of closed curves in order to draw patches correctly. 
ii = 1;
ncurves = 0;
I = [];
Area=[];
while (ii < size(CS,2)),
  nl=CS(2,ii);
  ncurves = ncurves + 1;
  I(ncurves) = ii;
  xp=CS(1,ii+(1:nl));  % First patch
  yp=CS(2,ii+(1:nl));
  Area(ncurves)=sum( diff(xp).*(yp(1:nl-1)+yp(2:nl))/2 );
  ii = ii + nl + 1;
end

if ~ishold(cax),
  view(cax,2);
  set(cax,'box','on');
  set(cax,'xlim',lims(1:2),'ylim',lims(3:4))
end

% Plot patches in order of decreasing size. This makes sure that
% all the levels get drawn, not matter if we are going up a hill or
% down into a hole. When going down we shift levels though, you can
% tell whether we are going up or down by checking the sign of the
% area (since curves are oriented so that the high side is always
% the same side). Lowest curve is largest and encloses higher data
% always.

fig = ancestor(cax,'figure');
H=[];
[FA,IA]=sort(-abs(Area));
if ~isstr(get(cax,'color')),
  bg = get(cax,'color');
else
  bg = get(fig,'color');
end
if isempty(col)
  edgec = get(fig,'defaultsurfaceedgecolor');
else
  edgec = col;
end
if isempty(lin)
  edgestyle = get(fig,'defaultpatchlinestyle');
else
  edgestyle = lin;
end

% Tolerance for edge comparison
xtol = 0.1*(lims(2)-lims(1))/size(z,2);
ytol = 0.1*(lims(4)-lims(3))/size(z,1);

if nargout>0
  cout = [];
end
for jj=IA,
  nl=CS(2,I(jj));
  lev=CS(1,I(jj));
  if (lev ~= minz | draw_min ),
    xp=CS(1,I(jj)+(1:nl));  
    yp=CS(2,I(jj)+(1:nl));
    clev = lev;           % color for filled region above this level
    if (sign(Area(jj)) ~=sign(Area(IA(1))) ),
      kk=find(nv==lev);
      kk0 = 1 + sum(nv<=minz) * (~draw_min);
      if (kk > kk0)
        clev=nv(kk-1);    % in valley, use color for lower level
      elseif (kk == kk0)
        clev=NaN;
      else 
        clev=NaN;         % missing data section
        lev=NaN;
      end
    end

    if (isfinite(clev)),
      H=[H;patch(xp,yp,clev,'facecolor','flat','edgecolor',edgec, ...
              'linestyle',edgestyle,'userdata',lev,'parent',cax)];
    else
      H=[H;patch(xp,yp,clev,'facecolor',bg,'edgecolor',edgec, ...
              'linestyle',edgestyle,'userdata',CS(1,I(jj)),'parent',cax)];
    end
    
    if nargout>0
      % Ignore contours that lie along a boundary
      
      % Get +1 along lower boundary, -1 along upper, 0 in middle
      tx = (abs(xp - lims(1)) < xtol ) - (abs(xp - lims(2)) < xtol);
      ty = (abs(yp - lims(3)) < ytol ) - (abs(yp - lims(4)) < ytol);

      % Locate points with a boundary contour segment leading up to them
      bcf = find((tx & [0 ~diff(tx)]) | (ty & [0 ~diff(ty)]));

      if (~isempty(bcf))
         % Get a logical vector that has 0 inserted before each such location
         wuns = true(1,length(xp) + length(bcf));
         wuns(bcf + (0:(length(bcf)-1))) = 0;

         % Create new arrays so that NaN breaks each boundary contour segment
         xp1 = NaN * wuns;
         yp1 = xp1;
         xp1(wuns) = xp;
         yp1(wuns) = yp;

         % Remove unnecessary elements
         if (length(xp1) > 2)
            % Blank out segments consisting of a single point
            tx = ([1 isnan(xp1(1:end-1))] & [isnan(xp1(2:end)) 1]);
            xp1(tx) = NaN;
            
            % Remove consecutive NaNs or NaNs on either end
            tx = isnan(xp1) & [isnan(xp1(2:end)) 1];
            xp1(tx) = [];
            yp1(tx) = [];
            if (length(xp1)>2 & isnan(xp1(1)))
               xp1 = xp1(2:end);
               yp1 = yp1(2:end);
            end
            
            % No empty contours allowed
            if (length(xp1) == 0)
               xp1 = NaN;
               yp1 = NaN;
            end
         end

         % Update the contour segments and their length
         xp = xp1;
         yp = yp1;
         nl = length(xp);
      end

      cout = [cout,[lev xp;nl yp]];
    end
  end
end

numPatches = length(H);
if numPatches>1
  for i=1:numPatches
    set(H(i), 'faceoffsetfactor', 0, 'faceoffsetbias', (1e-3)+(numPatches-i)/(numPatches-1)/30); 
  end
end

c = cout;
h = H;

function [pvpairs,args,msg] = parseargs(args)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);

% check for special string argumentss trailing data arguments
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
    pvpairs = {'color',c,pvpairs{:}};
  end
  if ~isempty(l)
    pvpairs = {'linestyle',l,pvpairs{:}};
  end
  nargs = nargs - 1;
end
if (nargs == 2) || (nargs == 4)
  if (nargs == 2)
    pvpairs = {'zdata',args{1},pvpairs{:}};
    z = args{1};
  else
    pvpairs = {'xdata',args{1},'ydata',args{2},'zdata',args{3},pvpairs{:}};
    z = args{3};
  end
  if length(args{nargs}) == 1
    % N
    zmin = min(real(z(:)));
    zmax = max(real(z(:)));
    pvpairs = {'levellist',linspace(zmin,zmax,args{nargs}),pvpairs{:}};
  else
    % levels
    pvpairs = {'levellist',unique(args{nargs}),pvpairs{:}};
  end
elseif (nargs == 1)
  pvpairs = {'zdata',args{1},pvpairs{:}};
elseif (nargs == 3)
  pvpairs = {'xdata',args{1},'ydata',args{2},'zdata',args{3},pvpairs{:}};
end

args = [];
