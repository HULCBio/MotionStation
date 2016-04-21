function lims=objbounds(h)
%OBJBOUNDS 3D object limits.
%   LIMS=OBJBOUNDS(H)  limits of the objects in vector H.
%   LIMS=OBJBOUNDS(AX) limits of the objects in which are children 
%                      of axes AX.
%   LIMS=OBJBOUNDS     limits of the objects in which are children.
%                      of the current axes.
%
%   OBJBOUNDS calculates the 3D limits of the objects specified. The
%   limits are returned in the form [xmin xmax ymin ymax zmin zmax].
%   This is a utility function used by CAMLOOKAT.
%
%   See also CAMLOOKAT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.5 $  $Date: 2004/04/10 23:26:49 $

%
%  This might be called on the HG objects of a user object when its
%  bounds are requested.
%

if nargin==0
  h = gca;
end

xmin = nan;
xmax = nan;
ymin = nan;
ymax = nan;
zmin = nan;
zmax = nan;

if length(h)==1 & ishandle(h) & strcmp(get(h, 'type'), 'axes')
  ch = get(h,'children');
  if isempty(ch)
    xl = xlim(h);
    yl = ylim(h);
    zl = zlim(h);
    xmin = xl(1);  xmax = xl(2); 
    ymin = yl(1);  ymax = yl(2); 
    zmin = zl(1);  zmax = zl(2); 
  else
    h = ch;
  end
end

for i=1:length(h)
  type = get(h(i),'type');
  validtype = false;
  switch type
    case {'surface','line', 'image'}
      xd = get(h(i), 'xdata');
      yd = get(h(i), 'ydata');
      validtype = ~isempty(xd) && ~isempty(yd) && ...
          any(isfinite(xd(:))) && any(isfinite(yd(:)));
      if strcmp(type, 'image') && validtype
        zd = 0;
        siz = size(get(h(i),'cdata'));

        if isequal(siz(2),1)
          % single x value, set range +/- half that value
          xd = xd + [-1 1]/2;
        else
          % offset x,y limits by half a data-pixel
          dx = (xd(end) - xd(1))/(siz(2)-1);
          xd = [xd(1) - dx/2, xd(end)+dx/2];
        end
        if isequal(siz(1),1)
          % single y value, set range +/- half that value
          yd = yd + [-1 1]/2;
        else
          % offset x,y limits by half a data-pixel
          dy = (yd(end) - yd(1))/(siz(1)-1);
          yd = [yd(1) - dy/2, yd(end)+dy/2];
        end
      else
        zd = get(h(i), 'zdata');
        if isempty(zd)
          if strcmp(type,'line')
            zd = 0; % a line can have empty zdata
          else
            validtype = false;
          end
        end
      end
      
    case {'patch'}
      v = get(h(i), 'vertices');
      validtype = ~isempty(v) && any(isfinite(v(:)));
      if validtype
        f = get(h(i), 'faces');
        v = v(f(isfinite(f)),:);
        xd = v(:,1);
        yd = v(:,2);
        if size(v,2)==2
          zd = 0;
        else
          zd = v(:,3);
        end
      end
  end
  
  if validtype
    if strcmp(get(h(i),'XLimInclude'),'on')
      xmin = min(xmin,min(xd(:)));
      xmax = max(xmax,max(xd(:)));
    end
    if strcmp(get(h(i),'YLimInclude'),'on')
      ymin = min(ymin,min(yd(:)));
      ymax = max(ymax,max(yd(:)));
    end
    if strcmp(get(h(i),'ZLimInclude'),'on')
      zmin = min(zmin,min(zd(:)));
      zmax = max(zmax,max(zd(:)));
    end
  end
end

lims = [xmin xmax ymin ymax zmin zmax];
if any(isnan(lims))
  lims = [];
end
