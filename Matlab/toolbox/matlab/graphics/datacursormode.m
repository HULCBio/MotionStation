function retval = datacursormode(varargin)
%DATACURSORMODE Interactively create data cursors on plot
%   DATACURSORMODE ON turns on cursor mode.
%   DATACURSORMODE OFF turns off cursor mode
%   DATACURSORMODE by itself toggles the state.
%   DATACURSORMODE(FIG,...) works on specified figure handle.
%
%   H = DATACURSORMODE(FIG)
%        Returns the figure's data cursor mode object for 
%        customization. The following properties can be 
%        modified using set/get:
%
%        Figure <handle>
%        Specifies associated figure handle. This property
%        supports GET only.
%
%        Enable  'on'|'off'
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%  
%        SnapToDataVertex 'on'|'off'
%        Specified whether data cursors snap to nearest data
%        value or appear at mouse position.
%
%        DisplayStyle 'datatip' | 'window'
%        'datatip' displays cursor information as a text box 
%        and marker and 'window' displays cursor information 
%        in a floating window within the figure.
%
%        UpdateFcn <function_handle>
%        Set this callback to customize the text that appears 
%        in the data cursor. The input function handle should
%        reference a function with two implicit arguments (similar
%        to handle callbacks):
%        
%             function [output_txt] = myfunction(obj,event_obj)
%             % OBJ        handle to object generating the 
%             %            callback (empty in this release).
%             % EVENT_OBJ  handle to event object
%             % OUTPUT_TXT data cursor text string (string or
%             %            cell array of strings).
%         
%             The event object has the following read only 
%             properties:
%             Target    The handle of the object the data cursor
%                       is referencing.
%             Position  An array specifying x,y,(z) location of 
%                       cursor.
%
%   INFO = getCursorInfo(H)
%       Calling the function GETCURSORINFO on the data cursor
%       mode object, H, will return a vector structures (one for 
%       each data cursor). Each structure contains the fields:
%             Target    The handle of the object the data cursor
%                       is referencing (i.e. the obejct that was
%                       clicked on).
%             Position  An array specifying x,y,(z) location of
%                       cursor.
%
%   EXAMPLE 1:
%
%   surf(peaks);
%   datacursormode on
%   % mouse click on plot
%
%
%   EXAMPLE 2:
%
%   surf(peaks);
%   h = datacursormode;
%   set(h,'ViewStyle','datatip','SnapToData','off');
%   % mouse click on plot
%   s = getCursorInfo(h);
%
%   EXAMPLE 3 (place in an m-file)
%       
%   function demo
%   % Customize datatip string to display 'Amplitude' and
%   % 'Time'. 
%   fig = figure;
%   plot(rand(1,10));
%   h = datacursormode(fig);
%   set(h,'UpdateFcn',@myupdatefcn,'SnapToDataVertex','on');
%   datacursormode on
%   % mouse click on plot
%
%   function [txt] = myupdatefcn(obj,event_obj)
%   % Display 'Time' and 'Amplitude'
%   pos = get(event_obj,'Position');
%   txt = {['Time: ',num2str(pos(1))],['Amplitude: ',num2str(pos(2))]};
%
%   See also GINPUT.

%   Copyright 1984-2004 The MathWorks, Inc. 

% UNDOCUMENTED FUNCTIONALITY
% The following features may change in a future release. 
%
% DATACURSORMODE(fig,'enableandcreate')
%    Turns on mode and fires button down function as if user clicked
%    at current mouse location. 
%
%
% The following object events are thrown by the data cursor 
% mode object:
%   'MouseMotion' Fires when mode is enabled and mouse is moving.
%   'ButtonDown'  Fires when mode is enabled and mouse is pressed.

action = []; % 'toggle' | 'on' | 'off'

fig = [];
if nargin==0
  fig = gcf;
  action = 'toggle';

elseif nargin==1
  arg1 = varargin{1};
  if isstr(arg1)
     action = arg1;
     fig = gcf;
  elseif isa(handle(arg1),'hg.figure')
     fig = arg1;
     if nargout==1
         action = 'retval';
     else
         action = 'toggle';
     end
  end
 
elseif nargin==2
  fig = varargin{1};
  action = varargin{2};
end

% First time through is slow due to class loading / pcoding
% Give user feedback with figure pointer
%persistent doInit;
%if isempty(doInit) & strcmpi(action,'on') 
%      setptr(fig,'watch');
%      doInit = false;
%end

fig = handle(fig);

if isempty(fig) || ~ishandle(fig) || ~isa(fig,'hg.figure')
  error('Invalid figure handle')
end


% Get the data cursor tool object
hTool = localGetObj(fig);

% Take appropriate action
switch(action)
    case 'on'
        set(hTool,'Enable','on');
    case 'off'
        set(hTool,'Enable','off');
    case 'toggle'
        curr = get(hTool,'Enable');
        if strcmp(curr,'on')
            set(hTool,'Enable','off');
        else
            set(hTool,'Enable','on');
        end
        retval = hTool;
        
    % Undocumented syntax    
    case 'enableandcreate'
        set(hTool,'Enable','on');
        localWindowButtonDownFcn([],[],hTool);
        
    case 'ison'
        retval = get(hTool,'Enable');
        
    case 'retval'
        retval = hTool;
        
    case 'none'
       ; % do nothing
end

%-----------------------------------------------%
function [hTool] = localGetObj(fig)

key = 'appdata_graphics_datacursortool';
fig = handle(fig);

hTool = [];

% Store datacursormanager object in a figure instance property.
% We can't store the object in appdata since we don't want to 
% it to serialize.
if isprop(fig,key)
    hTool = get(fig,key);
else
    p = schema.prop(handle(fig),key,'handle');
    p.AccessFlags.Serialize = 'off';
end
    
% Create tool object
if isempty(hTool) || ~ishandle(hTool)

    hTool = graphics.datacursormanager(fig);
    
    % add listeners
    l(1) = handle.listener(hTool,...
                           findprop(hTool,'Enable'),...
                           'PropertyPostSet',...
                           {@localSetEnable,hTool});
    l(end+1) = handle.listener(hTool,...
                               findprop(hTool,'DisplayStyle'),...
                               'PropertyPostSet',...
                               {@localSetDisplayStyle,hTool});
%    l(end+1) = handle.listener(hTool,...
%                               'ObjectBeingDestroyed',...
%                               {@localDestroy,hTool});
    addlistener(hTool,l);
    
    set(handle(fig),key,hTool);
end

%-----------------------------------------------%
function localSetDisplayStyle(obj,evd,hTool)
  
dispstyle = get(hTool,'DisplayStyle');

if get(hTool,'Debug')
  disp(dispstyle)
end

switch(dispstyle)
   case 'window'
      % Remove all data cursors except for the 
      % one that has focus.
      hList = get(hTool,'DataCursors');
      hDatatip = get(hTool,'CurrentDataCursor');           
      if ~isempty(hList)  
         for n = 1:length(hList)
            if ~isequal(hList(n),hDatatip)  
               removeDataCursor(hTool,hList(n)); 
            end
         end 
 
         %  Remove datatip's text box
         htmp = get(hDatatip,'TextBoxHandle');
         set(htmp,'Visible','off');
      
         % Listen to datatip string and feed to panel
         % ToDo: Listen to Update event instead
         h = handle.listener(hDatatip,...
                       'UpdateCursor',...
                       {@localUpdatePanel,hTool});
         hDatatip.addlistener(h);
      end
      
      % If mode is on, turn on window 
      if strcmpi(get(hTool,'Enable'),'on')
            localPanelUIOn(hTool);

            % Hide text box on datatip with focus
            if ~isempty(hDatatip) 
               h = get(hDatatip,'TextBoxHandle');
               set(h,'Visible','off');
            end
         
            % Update string in panel
            localUpdatePanel([],[],hTool);
      end
          
   case 'datatip'  
       % Remove window
       localPanelUIOff(hTool);
       
       % Restore datatip's text box
       hDataCursor = get(hTool,'DataCursors');
       h = get(hDataCursor,'TextBoxHandle');
       set(h,'Visible','on');
end
    

%-----------------------------------------------%
function localSetEnable(obj,evd,hTool)
% Turn on/off UI 

if get(hTool,'Debug')
  disp('localSetEnable')
end

fig = get(hTool,'Figure');
onoff = get(hTool,'Enable');
uistate = get(hTool,'UIState');

if strcmpi(onoff,'on')

    % turn off all other interactive modes
    if isempty(uistate) 
        
        % Specify uninstaller callback: DATACURSORMODE(fig,'off') 
        uistate = uiclearmode(double(fig),...
                              'docontext',...
                              'datacursormode',fig,'off');         
        
        % restore button down functions for uicontrol children of the figure
        uirestore(uistate,'uicontrols');
        
        set(hTool,'UIState',uistate);
        
        
        % Create context menu
        c = get(hTool,'UIContextMenu');
        if isempty(c) | ~ishandle(c) 
           c = localCreateUIContextMenu(hTool);
           set(hTool,'UIContextMenu',c);        
        end
        
        % Add context menu to the figure, axes, and axes children
        % but NOT to uicontrols or other widgets at the figure level.
        if ishandle(c)
            set(fig,'UIContextMenu',c);
            ax_child = findobj(fig,'type','axes');
            for n = 1:length(ax_child)
                kids = findobj(ax_child(n));
                set(kids,'UIContextMenu',c);
                set(ax_child(n),'UIContextMenu',c);                  
            end
        end
        
        % Avoids failure in tdatacursormode (UICLEARMODE related) 
        set(hTool,'Enable','on');
        
        % Work around for figure flashing during renderer change
        % Maintain renderer state during mode to avoid flashing.
        %origRenderer = get(fig,'Renderer');
        %if ~strcmpi(origRenderer,'None')
        %   set(hTool,'OriginalRenderer',get(fig,'Renderer'));
        %   set(hTool,'OriginalRendererMode',get(fig,'RendererMode'));
        %   set(fig,'RendererMode','manual');
        %end
        
    end
            
    % Enable mode
    set(fig,'WindowButtonMotionFcn',{@localWindowMotionFcn,hTool});
    set(fig,'WindowButtonDownFcn',{@localWindowButtonDownFcn,hTool});
    set(fig,'KeyPressFcn',{@localKeyPressFcn,hTool});     
    setptr(fig,'modifiedfleur');
        
    % Turn on UI (i.e. toolbar buttons, menus)
    % This must be called AFTER uiclear to avoid uiclear state munging
    localSetUIOn(hTool);

    scribefiglisten(fig,'on');
        
else % off

    if ~isempty(uistate)
        % Restore figure and children callbacks 
        uirestore(uistate,'nouicontrols');
    
        % Turn off UI (i.e. toolbar buttons, menus)
        localSetUIOff(hTool);        
                
        scribefiglisten(fig,'off');
    end
    
    % Reset figure renderer
    %origRenderer = get(hTool,'OriginalRenderer');
    %origRendererMode = get(hTool,'OriginalRendererMode');
    %if ~isempty(origRenderer) & ~isempty(origRendererMode)
    %    set(fig,'Renderer',origRenderer);
    %    set(fig,'RendererMode',origRendererMode);
    %end
    
    % Reset appdata
    set(hTool,'UIState',[]);
    
    % Avoids failure in tdatacursormode (UICLEARMODE related) 
    set(hTool,'Enable','off');

end

%-----------------------------------------------%
function [hContextMenu] = localCreateUIContextMenu(hTool)
% Create context menu for mode

% MAIN MENU
props.Parent = get(hTool,'Figure');
s.main = handle(uicontextmenu(props));
h(1) = s.main;
hContextMenu = h(1);

% InterpMethod
props.Parent = hContextMenu;
props.Label = 'Selection Style';
props.Separator = 'off';
s.cursor_style = handle(uimenu(props,'Checked','off'));
h(end+1) = s.cursor_style;

props = [];
props.Parent = s.cursor_style;
props.Label = 'Mouse Position';
props.Separator = 'off';
s.interp_linear = handle(uimenu(props));
h(end+1) = s.interp_linear;

props = [];
props.Parent = s.cursor_style;
props.Label = 'Snap to Nearest Data Vertex';
props.Separator = 'off';
s.interp_nearest = handle(uimenu(props));
h(end+1) = s.interp_nearest;

% ViewStyle
props = [];
props.Parent = s.main;
props.Label = 'Display Style';
props.Separator = 'off';
s.disp_style = handle(uimenu(props,'Checked','off'));
h(end+1) = s.disp_style;

props = [];
props.Parent = s.disp_style;
props.Label = 'Window Inside Figure';
props.Separator = 'off';
s.disp_style_panel = handle(uimenu(props));
h(end+1) = s.disp_style_panel;

props = [];
props.Parent = s.disp_style;
props.Label = 'Datatip';
props.Separator = 'off';
s.disp_style_datatip = handle(uimenu(props));
h(end+1) = s.disp_style_datatip;

% Datatip creation/deletion
props = [];
props.Parent = hContextMenu;
props.Label = 'Create New Datatip             Alt-Click'; 
props.Separator = 'on';
s.create_datatip = handle(uimenu(props));
h(end+1) = s.create_datatip;

props.Parent = hContextMenu;
props.Label = 'Delete Current Datatip            Delete'; 
props.Separator = 'off';
s.delete_datatip = handle(uimenu(props));
h(end+1) = s.delete_datatip;

props.Parent = hContextMenu;
props.Label = 'Delete All Datatips'; 
props.Separator = 'off';
s.delete_all_datatips = handle(uimenu(props));
h(end+1) = s.delete_all_datatips;

% export
props.Parent = hContextMenu;
props.Label = 'Export Cursor Data to Workspace...';
props.Separator = 'on';
s.export = handle(uimenu(props));
h(end+1) = s.export;

% Assign callback to all handles
set(h,'Callback',{@localUpdateUIContextMenu,hTool,s});

%-----------------------------------------------%
function localUpdateUIContextMenu(obj,evd,hTool,s)

hFig = get(hTool,'Figure');
obj = handle(obj);
disp_style = get(hTool,'DisplayStyle');

% Update all child menu "checked" property
if isequal(obj,s.main)
     if strcmpi(disp_style,'window')
           set(s.disp_style_panel,'Checked','On');
           set(s.disp_style_datatip,'Checked','Off');
           set(s.create_datatip,'Enable','off');
           set(s.delete_datatip,'Enable','off');
           set(s.delete_all_datatips,'Enable','off');
     else
           set(s.disp_style_panel,'Checked','Off');
           set(s.disp_style_datatip,'Checked','On');
           set(s.create_datatip,'Enable','on');
           set(s.delete_datatip,'Enable','on');
           set(s.delete_all_datatips,'Enable','on');
     end
       
     snapon = get(hTool,'SnapToDataVertex');
     if strcmpi(snapon,'on')
          set(s.interp_linear,'Checked','off');
          set(s.interp_nearest,'Checked','on');
     else
          set(s.interp_linear,'Checked','on');
          set(s.interp_nearest,'Checked','off');         
     end
     
     h = get(hTool,'DataCursors');
     if isempty(h)
        set(s.export,'Enable','off');
     else
        set(s.export,'Enable','on');
     end
       
elseif isequal(obj,s.interp_nearest)
     set(hTool,'SnapToDataVertex','on');

elseif isequal(obj,s.interp_linear)
     set(hTool,'SnapToDataVertex','off');

elseif isequal(obj,s.disp_style_datatip)
     set(hTool,'DisplayStyle','datatip','Enable','on');
     
elseif isequal(obj,s.disp_style_panel)
     set(hTool,'DisplayStyle','window');
     set(hTool,'Enable','on');
       
elseif isequal(obj,s.delete_datatip)
     hCurrDatatip = get(hTool,'CurrentDataCursor');
     if ~isempty(hCurrDatatip)
        removeDataCursor(hTool,hCurrDatatip);
     end
elseif isequal(obj,s.delete_all_datatips)
     removeAllDataCursors(hTool);

elseif isequal(obj,s.create_datatip)
      set(hTool,'NewDataCursor',true);
       
% Export cursor to workspace     
elseif isequal(obj,s.export)
  
   prompt={'Enter the variable name'};
   name='Output Data Cursor Information';
   numlines=1;
   defaultanswer={get(hTool,'DefaultExportVarName')};
   answer=inputdlg(prompt,name,numlines,defaultanswer);
   if ~isempty(answer) && isstr(answer{1})
      set(hTool,'DefaultExportVarName',answer{1});
      datainfo = getCursorInfo(hTool);
      assignin('base',answer{1},datainfo);
   end
end

%-----------------------------------------------%
function [key] = locGetHashKey
% always returns a string unique to this mfile

key = 'DATACURSORTOOLFigureState';


%-----------------------------------------------%
function localSetUIOn(hTool)

fig = get(hTool,'Figure');

% Turn on UI state 
set(uigettoolbar(fig,'Exploration.DataCursor'),'State','on');   
set(findall(fig,'Tag','figMenuDatatip'),'Checked','on');

if strcmpi(get(hTool,'DisplayStyle'),'window')
   localPanelUIOn(hTool);
end

%-----------------------------------------------%
function localSetUIOff(hTool)
% Turn off UI state

fig = get(hTool,'Figure');
set(uigettoolbar(fig,'Exploration.DataCursor'),'State','off');   
set(findall(fig,'Tag','figMenuDatatip'),'Checked','off');

localPanelUIOff(hTool);

% Remove all data cursors if in window mode
if(strcmpi(get(hTool,'DisplayStyle'),'window'))
  removeAllDataCursors(hTool);
end

%-----------------------------------------------%
function [h] = localPanelUIOn(hTool)

if get(hTool,'Debug')
  disp('localPanelUIOn')
end

fig = get(hTool,'Figure');

DEFAULT_STR = 'Mouse Click on Plotted Data...';
TITLE = ' '; % eventually make the title show plot name property

hFrame = get(hTool,'PanelHandle');

% Create new panel if necessary
if isempty(hFrame) || ~ishandle(hFrame)

   % Make sure the toolbar does not go away
   origToolbarMode = get(fig,'Toolbar');
   set(fig,'Toolbar','figure');

   % Create data panel
   % ToDo: Make figpanel a subclass of uipanel
   hFrame = figpanel('parent',fig,'title',TITLE);
   set(hFrame,'Visible','off');
   pos = get(hTool,'DefaultPanelPosition');
   if ~isempty(pos)
      fp = get(hFrame,'Position');
      set(hFrame,'Position',[pos(1), pos(2), fp(3), fp(4)]);   
   end 
   figpanel(hFrame,'String',DEFAULT_STR);
   figpanel(hFrame,'CloseFcn',{@localFrameCloseFcn,fig,hTool,origToolbarMode});
   figpanel(hFrame,'UIContextMenu',get(hTool,'UIContextMenu'));
   set(hFrame,'Visible','on');
   set(hTool,'PanelHandle',hFrame);
   
end

% Permit dragging for any prior data cursors
set(get(hTool,'DataCursors'),'Draggable','on');

%-----------------------------------------------%
function localFrameCloseFcn(obj,evd,fig,hTool,origToolbarMode)

% Store panel position to get sticky behavior
hFrame = get(hTool,'PanelHandle');
pos = get(hFrame,'Position');
set(hTool,'DefaultPanelPosition',pos);

% Panel was deleted, so exit mode
set(hTool,'Enable','off');
set(fig,'Toolbar',origToolbarMode);

%-----------------------------------------------%
function localPanelUIOff(hTool)

% Remove data panel 
hFrame = get(hTool,'PanelHandle');
if ~isempty(hFrame) & ishandle(hFrame)
  % Store panel position
  pos = get(hFrame,'Position');
  set(hTool,'DefaultPanelPosition',pos);
  delete(hFrame);
end

%-----------------------------------------------%
function localKeyPressFcn(fig,evd,hTool)

if isempty(hTool) || ~ishandle(hTool)
    return;
end

fig = get(hTool,'Figure');

% Get key pressed
if ~isstruct(evd) || ~isfield(evd,'Key')
  return;
end

keypressed = evd.Key;
if isempty(keypressed), return; end

hDataCursor = get(hTool,'CurrentDataCursor');

% Return early if no current datatip
if isempty(hDataCursor) | ~ishandle(hDataCursor)
   return;
end

switch keypressed
  case 'leftarrow'
     move(hDataCursor,'left');
  case 'rightarrow'
     move(hDataCursor,'right');
  case 'uparrow' 
     move(hDataCursor,'up');
  case 'downarrow'
     move(hDataCursor,'down');
  case 'delete'
     removeDataCursor(hTool,hDataCursor);
  otherwise
     return;   
end

%-----------------------------------------------%
function localWindowButtonDownFcn(fig,evd,hTool)

if isempty(hTool) || ~ishandle(hTool)
    return;
end

fig = get(hTool,'Figure');

% Right click is for reserved context menu.
sel_type = get(fig,'SelectionType');
if ~strcmp(sel_type,'normal')
  return;
end

% Determine the object that we clicked on.
% We can't use get(fig,'CurrentObject') since that returns
% empty if the user has the handle visibility set to off.
hTarget = hittest(fig);

% Cast to handle type
hTarget = handle(hTarget);
hTargetParent = handle(get(hTarget,'Parent'));

doignore = false;

% Ignore if not a subclass of hg.GObject
if isempty(hTarget) || ~ishandle(hTarget) || ~isa(hTarget,'hg.GObject')
  doignore = true;
end

% Ignore if object is a data cursor (parent group object)
if ~doignore & isa(hTargetParent,'graphics.datatip')
  %ToDo: Listen to datatip clicked event instead
  set(hTool,'CurrentDataCursor',hTargetParent);
  doignore = true;  
end

% Ignore if not a child of an axes
hAxes = handle(ancestor(hTarget,'hg.axes'));
if ~doignore & (isempty(hAxes) | isequal(hAxes,hTarget)) 
  doignore = true;
end

% Ignore children of scribe objects
if ~doignore & isappdata(hTarget,'ScribeGroup')
    doignore = true;
end

% Ignore legend and colorbar
htag = lower(get(hTarget,'tag'));
if ~doignore & ... 
      (~isempty(findstr(htag,'legend')) || ...
        ~isempty(findstr(htag,'colorbar')))
    doignore = true;
end

% Ignore children of legend and colorbar
parent = get(hTarget,'parent');
if ~isempty(parent)
    ptag = lower(get(parent,'tag'));
    if ~doignore & (~isempty(findstr(ptag,'legend')) || ...
            ~isempty(findstr(ptag,'colorbar')))
        doignore = true;
    end
end

% Ignore scribe objects
if ~doignore & isprop(hTarget,'shapeType')
    doignore = true;
end

% Get behavior object 
% ToDo: Hide behavior object details within datatip class
hBehavior = hggetbehavior(hTarget,'DataCursor','-peek');
has_behavior_obj = false;
if ~doignore && ~isempty(hBehavior) && ishandle(hBehavior)
    has_behavior_obj = true;
    if ~get(hBehavior,'Enable')
         doignore = true;
    end
end

% Ignore text objects, rectangles, and uicontrols that don't have 
% behavior objects.
% ToDo: A better way is to delegate to the datatip via some method 
% to see if this object is supported
if (isa(hTarget,'rectangle') || ...
    isa(hTarget,'text') || ...
    isa(hTarget,'uicontrol')) ...
        && ~has_behavior_obj
    doignore = true;
end

% Create new datatip if user clicks on 'alt' key
doNewDatatip = false;
if strcmp(get(fig,'CurrentModifier'),'alt')
    doNewDatatip = true;
end

if ~doignore 
  % HG needs double-handles to avoid seg-v
  set(fig,'CurrentObject',double(hTarget)); 
  disp_style = get(hTool,'DisplayStyle');
  if strcmp(disp_style,'datatip')
     localWindowButtonDownFcnDatatip(fig,hTool,hTarget,doNewDatatip);
  else
     localWindowButtonDownFcnPanel(fig,hTool,hTarget);
  end
end

% send event
sendMouseEvent(hTool,'ButtonDown',hTarget);

%-----------------------------------------------%
function localWindowButtonDownFcnPanel(fig,hTool,hTarget)
% Create a datatip without the text box and place the 
% string into a small panel within the figure

% Get necessary handles
hFig = get(hTool,'Figure');
hDatatip = get(hTool,'CurrentDataCursor');
hPanel = get(hTool,'PanelHandle');

% Create a new datatip if necessary
if isempty(hDatatip) || ~ishandle(hDatatip)
   
   % Wipe out any stale data cursors
   removeAllDataCursors(hTool);
   
   % Create a new datatip
   hDatatip = createDatatip(hTool,hTarget);
   
   % Turn off datatip text box in panel mode
   hText =  get(hDatatip,'TextBoxHandle');
   set(hText,'Visible','off');
      
   % Listen to datatip string and feed to panel
   % ToDo: Listen to Update event instead
   h = handle.listener(hDatatip,...
                       'UpdateCursor',...
                       {@localUpdatePanel,hTool});
   addlistener(hDatatip,h);
end

% Update datatip state, position, and string
if ishandle(hDatatip) & ishandle(hTarget)
   set(hDatatip,'Host',hTarget);
   set(hDatatip,'ViewStyle','marker');
      
   % Update datatip
   update(hDatatip);
   
   % Update panel
   localUpdatePanel([],[],hTool);
   
   % start dragging
   startDrag(hDatatip,fig);
end
%-----------------------------------------------%
function localUpdatePanel(obj,evd,hTool)
% Update panel string


hDatatip = get(hTool,'CurrentDataCursor');
hPanel = get(hTool,'PanelHandle');

if (~isempty(hDatatip)  & ...
     ishandle(hDatatip) & ...
    ~isempty(hPanel)    & ...
     ishandle(hPanel))
        str = get(hDatatip,'String');
        
        figpanel(hPanel,'String',str);
        
        % Update panel's title bar based on target
        hTarget = get(hDatatip,'Host');
        
        if isempty(hTarget) | ~ishandle(hTarget)
          return;
        end
        
        title_name = [];
        
        % Use specified Display Name
        if ~isempty(findprop(hTarget,'DisplayName'))
            title_name = get(hTarget,'DisplayName');
        end
        % Use class name
        if isempty(title_name)
           title_name = get(classhandle(handle(hTarget)),'Name'); 
        end
         
        % Set panel's title string
        figpanel(hPanel,'Title',upper(title_name));
end

%-----------------------------------------------%
function localWindowButtonDownFcnDatatip(fig,hTool,hTarget,docreate)
% Create datatip UI

hTargetBehavior = hggetbehavior(hTarget,'DataCursor','-peek');

hDatatip = get(hTool,'CurrentDataCursor');

% Query target's behavior object to see if we should create
% a new datatip
if ~docreate ...
   && ~isempty(hTargetBehavior) ...
   && ishandle(hTargetBehavior)
       docreate = get(hTargetBehavior,'CreateNewDatatip');
end

% Create a new datatip if the current datatip has draggable set to
% off. This scenario occurs with response plots.
if ~isempty(hDatatip) && ishandle(hDatatip)
   if strcmp(get(hDatatip,'Draggable'),'off')   
       docreate = true;
   end
end

% Create a new datatip when appropriate
if isempty(hDatatip) ...
   || ~ishandle(hDatatip) ...
   || get(hTool,'NewDataCursorOnClick') ...
   || docreate
       hDatatip = hTool.createDatatip(hTarget);
   set(hDatatip,'HandleVisibility','off');
end
  
% Update position
if ishandle(hDatatip) && ishandle(hTarget) 
  
   % Toggle OrientationMode to auto so datatip appears with best
   % orientation.
   
   origInvalidState = get(hDatatip,'Invalid');
   set(hDatatip,'Invalid',true);
   set(hDatatip,'OrientationMode','auto');
   set(hDatatip,'Invalid',origInvalidState);
  
   set(hDatatip,'Host',hTarget);
   set(hDatatip,'ViewStyle','datatip');
   update(hDatatip);
   set(hDatatip,'OrientationMode','manual');
 
   % start dragging
   startDrag(hDatatip,fig);
end

%-----------------------------------------------%
function localWindowMotionFcn(fig,evd,hTool)
% Update pointer

if isempty(hTool) || ~ishandle(hTool)
    return;
end

fig = get(hTool,'Figure');
obj = handle(hittest(fig));

% ToDo: Clean up API for testing if obj is data cursor
if strcmpi(get(obj,'tag'),'DataTipMarker')
   set(fig,'Pointer','fleur')

% If mouse is over an axes
elseif ~isempty(ancestor(obj,'hg.axes'))
  setptr(fig,'modifiedfleur');

else
  setptr(fig,'arrow');
end

% send event
sendMouseEvent(hTool,'MouseMotion',obj);
