function labelpos(h)
%LABELPOS  Adjust position of background axes labels.
           
%   Authors: A. DiVergilio, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:49 $
if isvisible(h)
   % Visible row and columns
   [VisAxes,indrow,indcol] = findvisible(h);
   if isempty(VisAxes)
      return
   end
   
   % Parameters
   Geometry = h.Axes.Geometry;
   scale = Geometry.PrintScale;
   tshave = Geometry.TopMargin*scale;  % Gap btw tops of background axes and data axes
   yshave = Geometry.LeftMargin*scale; % Gap btw left edges of background axes and data axes
   cushion = 2*scale;  % Extra cushion between labels and plots
   tcushion = 6*scale; % Extra cushion for title
   
   % Pixel width/height of background axes
   backax = h.BackgroundAxes;
   [FigW,FigH] = figsize(h.Axes,'pixel');
   bw = backax.Position(3) * FigW;
   bh = backax.Position(4) * FigH;
   LabelUnit = get(backax.Title,'Units');

   % Warnings off in case label position goes negative on log plots
   WarnState = warning('off');
   
   % Adjust YLabel position
   ylabin = get(VisAxes(:,1),{'YLabel'});
   ylabin = cat(1,ylabin{:});
   % Get max extent of inner labels
   op = get(ylabin,{'Position'});  % save position in data units
   set(ylabin,'Units','pixels');
   ex = get(ylabin,{'Extent'});
   ex = cat(1,ex{:});
   set(ylabin,'Units','data',{'Position'},op);    % restore original units/position
   x_offset = min(ex(:,1));  % offset in pixels
   YLabelPos = [yshave+x_offset (bh-tshave)/2 0];
   
   % Adjust XLabel position
   xlabin = get(VisAxes(end,:),{'XLabel'});
   xlabin = cat(1,xlabin{:});
   op = get(xlabin,{'Position'});  % save position in data units
   set(xlabin,'Units','pixels');
   ex = get(xlabin,{'Extent'});
   ex = cat(1,ex{:});
   set(xlabin,'Units','data',{'Position'},op);    % restore original units/position
   y_offset = min(ex(:,2)) - cushion;  % offset in pixels
   XLabelPos = [(bw+yshave)/2 y_offset 0];
   
   % Adjust Title position
   tlabin = get(VisAxes(1,:),{'Title'});
   tlabin = cat(1,tlabin{:});
   op = get(tlabin,{'Position'});  % save position in data units
   set(tlabin,'Units','pixels');
   ex = get(tlabin,{'Extent'});
   ex = cat(1,ex{:});
   set(tlabin,'Units','data',{'Position'},op);    % restore original units/position
   y_offset = max(ex(:,4)) + cushion + tcushion;
   TitlePos = [(bw+yshave)/2 bh-tshave+y_offset 0];
   
   % Optimized position update (AbortSet=off on Units!)
   if strcmp(LabelUnit,'pixels')
      set(backax.Title,'Position',TitlePos);
      set(backax.Xlabel,'Position',XLabelPos);
      set(backax.YLabel,'Position',YLabelPos);
   else
      set(backax.Title,'Units','pixels','Position',TitlePos,'Units',LabelUnit);
      set(backax.Xlabel,'Units','pixels','Position',XLabelPos,'Units',LabelUnit);
      set(backax.YLabel,'Units','pixels','Position',YLabelPos,'Units',LabelUnit);
   end
   
   warning(WarnState)
end