function newmap = brighten(map,beta)
%BRIGHTEN Brighten or darken color map.
%   BRIGHTEN(BETA) replaces the current color map with a brighter
%   or darker map involving essentially the same colors.  The map is
%   brighter if 0 < BETA <= 1 and darker if -1 <= BETA < 0.
%
%   BRIGHTEN(BETA), followed by BRIGHTEN(-BETA) restores the
%   original map.
%   
%   MAP = BRIGHTEN(BETA) returns a brighter or darker version of the
%   color map currently being used without changing the display.
%
%   NEWMAP = BRIGHTEN(MAP,BETA) returns a brighter or darker version
%   of the specified color map without changing the display.
%
%   BRIGHTEN(FIG,BETA) brightens all the objects in the figure FIG.

%   CBM, 9-13-91, 2-6-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.9 $  $Date: 2002/04/15 04:28:29 $

if nargin < 2, beta = map; map = colormap; end
if nargin==2 & length(map)==1, % brighten(fig,beta)
  fig = map;
  if floor(fig)~=fig | isempty(find(fig==get(0,'Children'))), return, end
  set(fig,'Colormap',brighten(get(fig,'Colormap'),beta),...
          'Color',brighten(get(fig,'color'),beta))
  for h=get(fig,'Children')',
    if strcmp(get(h,'type'),'axes'),
      set(h,'color',brighten(get(h,'color'),beta),...
            'xcolor',brighten(get(h,'xcolor'),beta),...
            'ycolor',brighten(get(h,'ycolor'),beta),...
            'zcolor',brighten(get(h,'zcolor'),beta),...
            'colororder',brighten(get(h,'colororder'),beta))
      for hh=[get(h,'title') get(h,'xlabel') get(h,'ylabel') get(h,'zlabel')],
        set(hh,'color',brighten(get(hh,'color'),beta))
      end
      for hh = get(h,'Children')',
        if strcmp(get(hh,'type'),'text'),
          set(hh,'color',brighten(get(hh,'color'),beta))
        elseif strcmp(get(hh,'type'),'line'),
          set(hh,'color',brighten(get(hh,'color'),beta))
          ec = get(hh,'MarkerEdgeColor');
          fc = get(hh,'MarkerFaceColor');
          if ~isstr(ec), set(hh,'MarkerEdgeColor',brighten(ec,beta)), end
          if ~isstr(fc), set(hh,'MarkerFaceColor',brighten(fc,beta)), end
        elseif strcmp(get(hh,'type'),'patch'),
          ec = get(hh,'EdgeColor');
          fc = get(hh,'FaceColor');
          if ~isstr(ec), set(hh,'EdgeColor',brighten(ec,beta)), end
          if ~isstr(fc), set(hh,'FaceColor',brighten(fc,beta)), end
        end
      end
    end
  end
  return
end
          
           
if max(max(map)) > 1
    map = map/255;
end

if (beta > 1) | (beta < -1)
   error('Beta must be between -1 and 1.')
end

tol = sqrt(eps);
if beta > 0
   gamma = 1 - min(1-tol,beta);
else
   gamma = 1/(1 + max(-1+tol,beta));
end

map = map.^gamma;

if nargout == 0
   colormap(map)
else
   newmap = map;
end

