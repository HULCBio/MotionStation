function [hContextMenu] = createDefaultContextMenu(hThis,hDatatip)
% This should be a private method

% Copyright 2002 The MathWorks, Inc.

if nargin == 1
  hDatatip = [];
end
  
% Create context menu
hFig = hThis.Figure;
props_context.Parent = hFig;
props_context.Tag = 'DatatipContextMenu';
hContextMenu = uicontextmenu(props_context);

% Generic attributes for all datatip uimenus
props.Callback = {@localContextMenuCallback,hThis,hDatatip};
props.Parent = hContextMenu;

% Define each uimenu
umain = [];
if isempty(hDatatip)
  props.Enable = 'off';
end
props.Label = 'Selection Method'; % for all datatips
props.Tag = 'Interpolate';
umain(end+1) = uimenu(props);

props.Label = 'Snap To Nearest Data Point';
props.Tag = 'InterpolateNearest';
uimenu(props,'Parent',umain(end),'Checked','on');

props.Label = 'Interpolate Between Data Points';
props.Tag = 'InterpolateLinear';
uimenu(props,'Parent',umain(end));

props.Enable = 'on';
props.Label = 'Create New Datatip';
props.Tag = 'CreateDatatip';
umain(end+1) = uimenu(props,'Separator','on');

if isempty(hDatatip)
  props.Enable = 'off';
end
props.Label = 'Delete Datatip'; 
props.Tag = 'DeleteDatatip';
umain(end+1) = uimenu(props);

props.Enable = 'on';
props.Label = 'Delete All Datatips';
props.Tag = 'DeleteAllDatatips';
umain(end+1) = uimenu(props);

%-------------------------------------------------%
function localContextMenuCallback(hUimenu,evd,hDatatipManager,hDatatip)

hFig = gcbf;
switch get(hUimenu,'Tag')
    
  case 'InterpolateNearest'
      hDatatip.Interpolate = 'off';
      hMenuLinear = findall(hFig,'tag','InterpolateLinear','Type','Uimenu');
      hMenuNearest = hUimenu;
      set(hMenuLinear,'checked','off');
      set(hMenuNearest,'checked','on');
      
  case 'InterpolateLinear'    
      hDatatip.Interpolate = 'on';
      hMenuNearest = findall(hFig,'tag','InterpolateNearest','Type','Uimenu');
      hMenuLinear = hUimenu;
      set(hMenuLinear,'checked','on');
      set(hMenuNearest,'checked','off'); 
    
  case 'CreateDatatip'
      % Create an invisible datatip. It will become visible 
      % the next time the user clicks on a graphics object 
      % (in datatip mode) which supports datatips. 
      hCurrDatatip = hDatatipManager.CurrentDatatip;
      if ~isempty(hCurrDatatip) & strcmpi(hCurrDatatip.Visible,'on')
         hAxes = ancestor(hittest(hFig),'hg.axes');
         if ~isempty(hAxes)
            hDatatipManager.createDatatip(hAxes);
         end
      end 
  case 'DeleteDatatip'
      hDatatipManager.removeDatatip(hDatatip);
 
  case 'DeleteAllDatatips'
      hDatatipManager.removeAllDatatips;
      
end






