function cfdocontext(varargin)
%CFDOCONTEXT Perform context menu actions for curve fitting tool

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.7.2.4 $  $Date: 2004/03/09 16:15:42 $
import com.mathworks.toolbox.curvefit.*;

% Special action to create context menus
if isequal(varargin{1},'create')
   makecontextmenu(varargin{2});
   return
end

% Get information about what invoked this function
obj = gcbo;
action = get(obj,'Tag');
h = gco;
if isempty(h), return; end
hh = handle(h);
f = getfit(h);

% Set up variables that define some menu items
[sizes styles markers] = getmenuitems;
styles{end+1} = 'none';

switch action

 % This case is triggered when we display the menu
 case {'fitcontext' 'datacontext'}
   % Store a handle to the object that triggered this menu
   set(obj,'UserData',h);
   
   % Fix check marks on line width and line style cascading menus
   c = findall(obj,'Type','uimenu');
   set(c,'Checked','off');
   w = get(h,'LineWidth');
   u = findall(c,'flat','Tag',num2str(w));
   if ~isempty(u)
      set(u,'Checked','on');
   end
   w = get(h,'LineStyle');
   u = findall(c,'flat','Tag',w);
   if ~isempty(u)
      set(u,'Checked','on');
   end
   w = get(h,'Marker');
   u = findall(c,'flat','Tag',w);
   if ~isempty(u)
      set(u,'Checked','on');
   end
   return
   
 % Remaining cases are triggered by selecting menu items
 case 'color'
   oldcolor = get(h,'Color');
   newcolor = uisetcolor(oldcolor);
   if ~isequal(oldcolor,newcolor)
      set(h,'Color',newcolor);
      if isa(hh,'cftool.boundedline')
         set(get(hh,'BoundLines'),'Color',newcolor);

         % Change residuals as well
         ptype = cfgetset('residptype');
         if ~isequal(ptype,'none') && ~isempty(f) && ...
                                      ~isempty(f.rline) && ishandle(f.rline)
             set(f.rline,'Color',newcolor);
         end
      end
   end

 case styles
   set(h,'LineStyle',action);

   % Change residuals as well
   ptype = cfgetset('residptype');
   if isa(hh,'cftool.boundedline')
      if isequal(ptype,'line') && ~isempty(f) && ...
                                  ~isempty(f.rline) && ishandle(f.rline)
         set(f.rline,'LineStyle',action);
      end
   end

 case markers
   if isequal(action,'point')
      msize = 12;
   else
      msize = 6;
   end
   set(h,'Marker',action,'MarkerSize',msize);

 % Either delete a fit, or a hide a fit or data set
 case {'hidecurve' 'deletefit'}
   isdataset = true;
   if isequal(get(h,'Tag'),'curvefit')
      f = getfit(h);
      isdataset = false;
   elseif isequal(get(h,'Tag'),'cfdata')
      f = getds(h);
   else
      return;          % should not happen
   end
   
   if isempty(f), return; end

   if isequal(action,'hidecurve')
      f.plot = 0;
      if ~isdataset
         FitsManager.getFitsManager.fitChanged(java(f));
      end
   else
      FitsManager.getFitsManager.deleteFits(java(f));
   end
   return

 % If the menu item is a number, it is a line width
 otherwise
   j = str2num(action);
   if ~isempty(j)
      set(h,'LineWidth',j);
   end

   % Do not change residuals, wide lines will be too obtrusive
end

if isa(hh,'cftool.boundedline')
   savelineproperties(f);
else
   ds = getds(hh);
   if ~isempty(ds)
      savelineproperties(ds);
   end
end


% ---------- get handle to fit object containing this line
function f = getfit(h)
f = [];
flist = cfgetallfits;
dh = double(h);
for j=1:length(flist)
   dl = double(flist{j}.line);
   if isequal(dl,dh)
      f = flist{j};
      return
   end
end

% ---------- get handle to dataset object for this line
function ds = getds(h)
ds = [];
dslist = cfgetalldatasets;
dh = double(h);
for j=1:length(dslist)
   dl = double(dslist{j}.line);
   if isequal(dl,dh)
      ds = dslist{j};
      return
   end
end

% ---------------------- helper to make context menu
function makecontextmenu(cffig)
%MAKECONTEXTMENU Creates context menu for curve fitting figure

% First create the context menu for fit curves
c = uicontextmenu('Parent',cffig,'Tag','fitcontext','Callback',@cfdocontext);
uimenu(c,'Label','Color...','Tag','color','Callback',@cfdocontext);
uwidth = uimenu(c,'Label','Line &Width','Tag','linewidth');
ustyle = uimenu(c,'Label','Line &Style','Tag','linestyle');

% Get menu item labels and tags
[sizes styles markers slabels mlabels] = getmenuitems;

% Sub-menus for line widths
for i = 1:length(sizes)
   val = num2str(sizes(i));
   uimenu(uwidth,'Label',val,'Callback',@cfdocontext,'Tag',val);
end

% Sub-menus for line styles
for j=1:length(styles)
   uimenu(ustyle,'Label',slabels{j},'Callback',@cfdocontext,'Tag',styles{j});
end

% Create a similar context menu for data curves
cc = copyobj(c,cffig);
set(cc,'Tag','datacontext')

% Add items for fit menus only
uimenu(c,'Label','&Hide Fit','Tag','hidecurve','Callback',@cfdocontext,...
       'Separator','on');
uimenu(c,'Label','&Delete Fit','Tag','deletefit','Callback',@cfdocontext);

% Add items for data menus only
uimenu(cc,'Label','&Hide Data','Tag','hidecurve','Callback',@cfdocontext,...
       'Separator','on');
umark = uimenu(cc,'Label','Marker','Tag','marker','Position',4);
for j=1:length(markers)
   uimenu(umark,'Label',mlabels{j},'Callback',@cfdocontext,'Tag',markers{j});
end

ustyle = findall(get(cc,'Children'),'Tag','linestyle');
uimenu(ustyle,'Label','none','Callback',@cfdocontext,'Tag', 'none');


% -------------- helper to get menu item labels
function [sizes,styles,markers,slabels,mlabels] = getmenuitems
%GETMENUITEMS Get items for curve fitting context menus
sizes = [0.5 1 2 3 4 5 6 7 8 9 10];
styles = {'-' '--' ':' '-.'};
markers = {'+' 'o' '*' '.' 'x' 'square' 'diamond' ...
        'v' '^' '<' '>' 'pentagram' 'hexagram'};
slabels = {'solid' 'dash' 'dot' 'dash-dot'};
mlabels = {'plus' 'circle' 'star' 'point' 'x-mark' 'square' 'diamond' ...
           'triangle (down)' 'triangle (up)' 'triangle (left)' ...
           'triangle (right)' 'pentagram' 'hexagram'};
