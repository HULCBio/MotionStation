function theAxis = xpsubplt(nrows, ncols, thisPlot)
%XPSUBPLT Create axes in tiled positions.
%   XPSUBPLT(m,n,p) is the version of SUBPLOT for use with 
%   some demo files.
%
%   XPSUBPLT provides for compatibility with some old demos, 
%   such as MATMANIP.  We do not recommend that you use this
%   function.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:26:00 $

create_axis = 1;

% if we haven't recovered position yet, generate it from mnp info:
if (thisPlot < 1)
   error('Illegal plot number.')
elseif (thisPlot > ncols*nrows)
   error('Index exceeds number of subplots.')
else
   % This is the percent offset from the subplot grid of the plotbox.
   PERC_OFFSET_L = 0.09;
   PERC_OFFSET_R = 0.045;
   PERC_OFFSET_B = PERC_OFFSET_L;
   PERC_OFFSET_T = PERC_OFFSET_R;
   if nrows > 2
      PERC_OFFSET_T = 0.9*PERC_OFFSET_T;
      PERC_OFFSET_B = 0.9*PERC_OFFSET_B;
   end
   if ncols > 2
      PERC_OFFSET_L = 0.9*PERC_OFFSET_L;
      PERC_OFFSET_R = 0.9*PERC_OFFSET_R;
   end
   
   row = (nrows-1) -fix((thisPlot-1)/ncols);
   col = rem (thisPlot-1, ncols);
   
   % For this to work the default axes position must be in normalized coordinates
   def_pos = get(gcf,'DefaultAxesPosition');
   totalwidth = def_pos(3);
   totalheight = def_pos(4);
   width = (totalwidth - (ncols-1)*(PERC_OFFSET_L+PERC_OFFSET_R))/ncols;
   height = (totalheight - (nrows-1)*(PERC_OFFSET_T+PERC_OFFSET_B))/nrows;
   position = [def_pos(1)+col*(width+PERC_OFFSET_L+PERC_OFFSET_R) ...
         def_pos(2)+row*(height+PERC_OFFSET_T+PERC_OFFSET_B) ...
         width height];
   if width <= 0.5*totalwidth/ncols
      position(1) = def_pos(1)+col*(totalwidth/ncols);
      position(3) = 0.7*(totalwidth/ncols);
   end
   if height <= 0.5*totalheight/nrows
      position(2) = def_pos(1)+row*(totalheight/nrows);
      position(4) = 0.7*(totalheight/nrows);
   end
end

nextplot = get(gcf,'nextplot');
if strncmp(nextplot,'replace',7), nextplot = 'add'; end

sibs = findobj(gcf,'Type','axes');
for i = 1:length(sibs)
   units = get(sibs(i),'Units');
   set(sibs(i),'Units','normalized');
   sibpos = get(sibs(i),'Position');
   set(sibs(i),'Units',units);
   
   % check for overlapping siblings
   if ~( (position(1) >= sibpos(1)   + sibpos(3))   || ...
               (sibpos(1)   >= position(1) + position(3)) || ...
               (position(2) >= sibpos(2)   + sibpos(4))   || ...
               (sibpos(2)   >= position(2) + position(4)))
      if any(sibpos ~= position)
         delete(sibs(i));
      else
         set(gcf,'CurrentAxes',sibs(i));
         if (strcmp(nextplot,'new')) 
            create_axis = 1;
         else
            create_axis = 0;
         end
      end
   end
end
set(gcf,'NextPlot',nextplot);

% create the axis:
if create_axis
   if (strcmp(nextplot,'new')) 
      figure,
   end
   ax = axes('units','normal','Position', position);
   set(ax,'units',get(gcf,'defaultaxesunits'))
else 
   ax = gca; 
end
