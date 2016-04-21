function varargout = cfgetcolor(ax, linetype, objh)
%CFGETCOLOR Get a color, marker, and linestyle suitable for a new line
%
%   [C,M,L,W] = CFGETCOLOR(AX,LINETYPE,OBJH) gets a color, marker, linestyle,
%   and width for drawing a new line of type LINETYPE in the axes
%   AX. Valid line types are 'data' and 'fit'.  OBJH is the handle
%   for the containing dataset or fit object.
%
%   [C,M,L,W,C2,M2,L2,W2] = CFGETCOLOR(AX,LINETYPE,OBJH) gets the
%   same for a residual curve.

%   Copyright 2001-2004 The MathWorks, Inc.  
%   $Revision: 1.12.2.1 $  $Date: 2004/02/01 21:39:52 $

allcolors = get(ax, 'ColorOrder');
lineproperties = {'Color' 'LineStyle' 'LineWidth' 'Marker'};

% For bad call, these will be returned
c = [0 0 0];
m = 'none';
l = 'none';
w = 1;

% Get values already stored, if any
if ~isempty(objh) & ~isempty(objh.ColorMarkerLine) ...
                  & nargout<=length(objh.ColorMarkerLine)
   [varargout{1:nargout}] = deal(objh.ColorMarkerLine{1:nargout});
   if nargout>4
      if nargout>=5 && isempty(varargout{5})
         varargout{5} = varargout{1};
      end
      if nargout>=6 && isempty(varargout{6})
         varargout{6} = '.';
      end
      if nargout>=7 && isempty(varargout{7})
         varargout{7} = 'none';
      end
      if nargout>=8 && isempty(varargout{8})
         varargout{8} = 1;
      end
   end
   return
end

switch linetype
 case 'data'
  h = findobj(ax, 'Type','line', 'Tag','cfdata');
  unplottedds = find(getdsdb,'Plot',0);

  % Start data colors from the end, to reduce collisions with fit colors
  ncolors = size(allcolors,1) + 1;
  
  % Find an unused color/marker combination, prefer marker = '.'  
  allmarkers = {'.' '+' 'o' '*' 'x' 's' 'd'};
  for j=1:length(allmarkers)
     m = allmarkers{j};
     h1 = findobj(h,'flat','Marker',m);
     a=1;
     for k=1:size(allcolors,1)
        c = allcolors(ncolors-k,:);
        a = findobj(h1,'flat','Color',c);
        if isempty(a)
           for j=1:length(unplottedds)
              cml = get(unplottedds(j),'ColorMarkerLine');
              if iscell(cml) & ~isempty(cml) & ...
                                isequal(cml{1},c) & isequal(cml{2},m)
                 a = j;
                 break
              end
           end
           if isempty(a)           
              varargout = {c m l w};
              return
           end
        end
     end
  end
  varargout = {c m l w};

 case 'fit'
  w = 2;
  h = findobj(ax, 'Type','line', 'Tag','curvefit');
  unplottedfit = find(getfitdb,'Plot',0);

  % Find an unused color/linestyle combination, prefer linestyle = '-'
  allstyles = {'-' '--' '-.'};
  a = 1;
  for j=1:length(allstyles)
     l = allstyles{j};
     h1 = findobj(h,'flat','LineStyle',l);
     for k=1:size(allcolors,1)
        c = allcolors(k,:);
        a = findobj(h1,'flat','Color',c);
        if isempty(a)
           for j=1:length(unplottedfit)
              cml = get(unplottedfit(j),'ColorMarkerLine');
              if iscell(cml) & ~isempty(cml) & ...
                                isequal(cml{1},c) & isequal(cml{3},l)
                 a = j;
                 break
              end
           end
           if isempty(a)           
              % Include info for residuals in case it was requested
              varargout = {c m l w c '.' l 1};
              return
           end
        end
     end
  end
  
  varargout = {c m l w c '.' l 1};
end
