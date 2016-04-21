function hh = bar3h(varargin)
%BAR3H  Horizontal 3-D bar graph.
%   BAR3H(Y,Z) draws the columns of the M-by-N matrix Z as horizontal
%   3-D bars.  The vector Y must be monotonically increasing or
%   decreasing.
%
%   BAR3H(Z) uses the default value of Y=1:M.  For vector inputs,
%   BAR3H(Y,Z) or BAR3H(Z) draws LENGTH(Z) bars. The colors are set by
%   the colormap. 
%
%   BAR3H(Y,Z,WIDTH) or BAR3(Z,WIDTH) specifies the width of the
%   bars. Values of WIDTH > 1, produce overlapped bars.  The default
%   value is WIDTH=0.8
%
%   BAR3H(...,'detached') produces the default detached bar chart.
%   BAR3H(...,'grouped') produces a grouped bar chart.
%   BAR3H(...,'stacked') produces a stacked bar chart.
%   BAR3H(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BAR3H(AX,...) plots into AX instead of GCA.
%
%   H = BAR3H(...) returns a vector of surface handles in H.
%   
%   Example:
%       subplot(1,2,1), bar3h(peaks(5))
%       subplot(1,2,2), bar3h(rand(5),'stacked')
%
%   See also BAR, BARH, BAR3.

%   Mark W. Reichelt 8-24-93
%   Revised by CMT 10-19-94, WSun 8-9-95
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.20.6.4 $  $Date: 2004/04/10 23:31:36 $

error(nargchk(1,4,nargin));
[cax,args,nargs] = axescheck(varargin{:});

[msg,x,y,xx,yy,linetype,plottype,barwidth,zz] = makebars(args{:},'3');
if ~isempty(msg), 
    error(msg); 
end

[n,m] = size(y);
% Create plot
cax = newplot(cax);
fig = ancestor(cax,'figure');

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);
edgec = get(fig,'defaultaxesxcolor');
facec = 'flat';
h = []; 
cc = ones(size(yy,1),4);
if ~isempty(linetype), facec = linetype; end
    for i=1:size(yy,2)/4
        h = [h,surface('xdata',xx+x(i),'zdata',yy(:,(i-1)*4+(1:4)), ...
               'ydata',zz(:,(i-1)*4+(1:4)),'cdata',i*cc, ...
               'FaceColor',facec,'EdgeColor',edgec,'parent',cax)];
    end
if length(h)==1, 
    set(cax,'clim',[1 2]), 
end

if ~hold_state, 
  % Set ticks if less than 16 integers
  if all(all(floor(y)==y)) & (size(y,1)<16),  
      set(cax,'ztick',y(:,1))
  end
  hold(cax,'off'), view(cax,3), grid(cax,'on')
  set(cax,'NextPlot',next,'ydir','reverse');
  if plottype==0,
    set(cax,'xtick',[],'xlim',[1-barwidth/m/2 max(x)+barwidth/m/2])
  else
    set(cax,'xtick',[],'xlim',[1-barwidth/2 max(x)+barwidth/2])
  end

  dx = diff(get(cax,'xlim'));
  dz = size(y,1)+1;
  if plottype==2,
    set(cax,'PlotBoxAspectRatio',[dx (sqrt(5)-1)/2*dz dz])
  else
    set(cax,'PlotBoxAspectRatio',[dx (sqrt(5)-1)/2*dz dz])
  end
end

if nargout>0, 
    hh = h; 
end
