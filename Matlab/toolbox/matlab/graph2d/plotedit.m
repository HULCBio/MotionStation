function varargout = plotedit(varargin)
%PLOTEDIT  Tools for editing and annotating plots
%   PLOTEDIT ON   starts plot edit mode for the current figure.  
%   PLOTEDIT OFF  ends plot edit mode for the current figure.
%   PLOTEDIT  with no arguments toggles the plot edit mode for
%      the current figure.
%   
%   PLOTEDIT(FIG)  toggles the plot edit mode for figure FIG.
%   PLOTEDIT(FIG,'STATE')  specifies the PLOTEDIT STATE for
%      the figure FIG.
%   PLOTEDIT('STATE')  specifies the PLOTEDIT STATE for
%      the current figure.
%
%      STATE can be one of the strings:
%          ON - starts plot edit mode
%          OFF - ends plot edit mode
%          SHOWTOOLSMENU - displays the Tools menu (the default)
%          HIDETOOLSMENU - removes the Tools menu from the menubar
%   
%   When PLOTEDIT is ON, use the Tools menu to add and 
%   modify objects, or select the annotation toolbar buttons
%   to add annotations such as text, line and arrows.
%   Click and drag objects to move or resize them.
%   
%   To edit object properties, right click or double click on 
%   the object.
%   
%   Shift-click to select multiple objects.
%
%   See also PROPEDIT.

%   Internal interfaces for toolbox-plotedit compatibility
%
%   plotedit(FIG,'hidetoolsmenu')
%      makes the standard figure 'Tools' menu Visible off
%   plotedit(FIG,'showtoolsmenu')
%      makes the standard figure 'Tools' menu Visible on
%   h = plotedit(FIG,'gethandles')
%      returns a list of the hidden plot editor objects which
%      should be excluded from GUIDE's object browser.
%   h = plotedit(FIG,'gettoolbuttons')
%      returns a list plot editing and annotation buttons in
%      the toolbar.  Used by UISUSPEND and UIRESTORE.
%   h = plotedit(FIG,'locktoolbarvisibility')
%      freezes the current state of the toolbar.
%   plotedit(FIG,'setsystemeditmenus')
%      restores the system Edit menu.
%   plotedit(FIG,'setploteditmenus')
%      restores the plotedit Edit menu.
%
%   these are used by UISUSPEND/UIRESTORE
%   a = plotedit(FIG,'getenabletools')
%      returns the enable state of the plot editing tools
%   plotedit(FIG,'setenabletools','off')
%      disables the plot editing tools under Tools menu
%      and disables the Tools menu callback which updates
%      the status of the tools menu, and disables the plot
%      editing tools in the Toolbar
%   plotedit(FIG,'setenabletools','on')
%      enables the Tools menu and the items underneath it
%      and enables the plot editing buttons in the Toolbar
%
%   To hide the figure toolbar, set the figure 'ToolBar'
%   property (hidden) to 'none'.
%      set(fig,'ToolBar','none');
%   
%   plotedit({'subfcn',...}) fevals the subfunction and passes
%   it the rest of the inputs.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.53.4.15 $  $Date: 2004/04/06 21:53:00 $
%   j. H. Roh  10/20/97


fSilent = 0;

switch nargin
 case 0   
  % plotedit
  fig = gcf; 
  action = 'toggle';
 case 1  
  if iscell(varargin{1}) 
    % switchyard to subfunctions or private functions
    args = varargin{1};
    if nargout > 0
      [varargout{1:nargout}] = feval(args{:});
    else
      feval(args{:});
    end
    return;
  elseif ischar(varargin{1})
    % plotedit [on | off ]
    fig = gcf; 
    action = varargin{1};
  else
    % plotedit(fig)
    if ~isempty(varargin{1}) && ishandle(varargin{1}) && strcmpi('figure',get(varargin{1},'type'))
      fig = varargin{1};
    else
      fig = gcf; 
    end
    action = 'toggle';
  end
 case 2
  if ~isempty(varargin{1}) && ishandle(varargin{1}) && strcmpi('figure',get(varargin{1},'type'))
    fig = varargin{1};
  else
    fig = gcf; 
  end
  action = varargin{2};
 case 3  
  if ~isempty(varargin{1}) && ishandle(varargin{1}) && strcmpi('figure',get(varargin{1},'type'))
    fig= varargin{1};
  else
    fig = gcf; 
  end
  action = varargin{2};
  parameter = varargin{3}; % silent: don't switch button
  switch parameter
   case 'silent'
    fSilent = 1;
  end
end

switch lower(action)
  
 case 'on'
  if ~isappdata(fig,'scribeActive')
    setappdata(fig,'scribeActive','on'); 
    if ~isappdata(fig,'ScribeFigSavedState') 
      % check to see if clearmode callback is already
      % plotedit off.  If it is then remove the appdata to
      % prevent calling plotedit off from scribeclearmode
      % during uiclearmode.
      scmc=getappdata(fig,'ScribeClearModeCallback');
      if ~isempty(scmc) && length(scmc)==3 && ...
            strcmpi(scmc{1},'plotedit') && strcmpi(scmc{3},'off')
        rmappdata(fig,'ScribeClearModeCallback');
      end
      state=uiclearmode(fig,'keepWatch','plotedit',fig,'off');
      setappdata(fig,'ScribeFigSavedState',state);        
    end
    % if there is not already a scribeaxes for this figure create
    % one
    scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay')); 
    if isempty(scribeaxes)
      scribeaxes = scribe.scribeaxes(fig); 
    end
    scribetogg = uigettoolbar(fig,'Standard.EditPlot');
    if ~isempty(scribetogg) && ~strcmpi(get(scribetogg,'beingdeleted'),'on') 
      set(scribetogg,'state','on');
    end
    set(fig,... 
        'WindowButtonMotionFcn',{graph2dhelper('scribemethod'),fig,'wbmotion'},...
        'WindowButtonUpFcn',{graph2dhelper('scribemethod'),fig,'wbup',0},...
        'WindowButtonDownFcn',{graph2dhelper('scribemethod'),fig,'wbdown',0},...
        'KeyPressFcn',{graph2dhelper('scribemethod'),fig,'kpress'});
    scribeaxes.methods('update_ccp_menuitems');
  end
 case 'off'
  scribeaxes = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  % no action is needed if scribeaxes doesn't exist or is not a valid
  % scribe axes.
  if ~isempty(scribeaxes) && isa(scribeaxes,'scribe.scribeaxes')
    scribeaxes.InteractiveCreateMode = 'off';
    % deselect everything
    scribeaxes.methods('deselectall');
    if isappdata(fig,'scribeActive')
      rmappdata(fig,'scribeActive');
    end
    scribetogg = uigettoolbar(fig,'Standard.EditPlot');            
    if ~isempty(scribetogg) && ~strcmpi(get(scribetogg,'beingdeleted'),'on')
      set(scribetogg,'state','off');
    end
    % turn off other toggles
    t = cell(1,7);
    t{1} = uigettoolbar(fig,'Annotation.InsertRectangle');
    t{2} = uigettoolbar(fig,'Annotation.InsertEllipse');
    t{3} = uigettoolbar(fig,'Annotation.InsertTextbox');
    t{4} = uigettoolbar(fig,'Annotation.InsertDoubleArrow');
    t{5} = uigettoolbar(fig,'Annotation.InsertArrow');
    t{6} = uigettoolbar(fig,'Annotation.InsertLine');
    t{7} = uigettoolbar(fig,'Annotation.Pin');
    for k=1:7
      if ~isempty(t{k})
        set(t{k},'state','off');
      end
    end
    % be sure pinning is off
    startscribepinning(fig,'off');
    % set cursor to arrow
    scribecursors(fig,0);
    % restore state if it was saved and still exists
    if isappdata(fig,'ScribeFigSavedState')
      state=getappdata(fig,'ScribeFigSavedState');
      uirestore(state);
      rmappdata(fig,'ScribeFigSavedState');
    end
  end
 case 'toggle' 
  if isappdata(fig,'scribeActive')
    plotedit(fig,'off');
  else
    plotedit(fig,'on');
  end
 case 'cut'
  if anytextediting(fig)
    uimenufcn(fig,'EditCut');
  else
    scribe_cut(fig);
  end
  update_edit_menu(fig);
 case 'copy'
  if anytextediting(fig)
    uimenufcn(fig,'EditCopy');
  else
    scribe_copy(fig);
  end
  update_edit_menu(fig);
 case 'paste'
  if anytextediting(fig)
    uimenufcn(fig,'EditPaste');
  else
    scribe_paste(fig);
  end
  update_edit_menu(fig);
 case 'clear'
  if anytextediting(fig)
    uimenufcn(fig,'EditClear');
  else
    scribe_delete(fig);        
  end
  update_edit_menu(fig);
 case 'selectall'
  if anytextediting(fig)
    uimenufcn(fig,'EditSelectAll');
  else
    scribe_selectall(fig);     
  end
  update_edit_menu(fig);
 case 'gethandles'
  varargout{1} = LGetScribeObjectList(fig);
 case 'hidetoolsmenu'
  set(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuTools'),...
      'visible','off');
 case 'showtoolsmenu'
  set(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuTools'),...
      'visible','on');
 case 'setenabletools'
  if nargin==3
    setappdata(fig,'ScribePloteditEnable',parameter);
    % disable toolbar
    toolButtons = plotedit(fig,'gettoolbuttons');
    set(toolButtons,'Enable',parameter);
    % disable Tools menu
    % happens within the Tools menu callback, by polling the
    % ScribePloteditEnable state
  end
 case 'getenabletools'
  ploteditEnable = getappdata(fig,'ScribePloteditEnable');
  if isempty(ploteditEnable)
    varargout{1} = 'on';    % default
  else
    varargout{1} = ploteditEnable;
  end        
 case 'setsystemeditmenus'
  LModifyFigMenus(fig,'off');
 case 'setploteditmenus'
  LModifyFigMenus(fig,'on');
 case 'gettoolbuttons'
  c = findobj(allchild(fig),'flat','Type','uitoolbar');
  
  % ToDo: Instead of hardcoding button names below, delegate 
  % and have this check done dynamically. 
  h = [uigettool(c,'Standard.EditPlot'),
       uigettool(c,'Exploration.ZoomIn'),
       uigettool(c,'Exploration.ZoomOut'),
       uigettool(c,'Exploration.Pan'),
       uigettool(c,'Exploration.Rotate'),  
       uigettool(c,'Exploration.DataCursor')]; 
  if nargout>0
    varargout{1} = h;
  end
 case 'locktoolbarvisibility'
  toolbarShowing = ~isempty(findall(fig,'Tag','FigureToolBar'));
  if toolbarShowing
    set(fig,'Toolbar','figure');
  else
    set(fig,'Toolbar','none');
  end
 case 'isactive'
  switch LGetState(fig)
   case 'on'
    varargout{1} = 1;      
   case 'off'
    varargout{1} = 0;
  end
 case 'promoteoverlay'
  %         promoteoverlay(fig);
  return
end

%------------------------------------------------------%
function LChangeState(fig,state,fSilent)
% oldPtr = LWaitPtr(fig);
% 
% LModifyFigMenus(fig,state);
% LSetState(fig,state,fSilent);
% LActivateWindowFcns(fig,state);
% LSetSelection(fig,state);
% LPrepareOverlay(fig,state);
% 
% set(f,'Pointer',oldPtr);

%------------------------------------------------------%
function oldPtr = LWaitPtr(fig);
% oldPtr = get(fig,'Pointer');
% set(fig,'Pointer','watch');

%------------------------------------------------------%
function LSetState(fig,state,silent)
% setappdata(fig,'scribeActive',state);
% if ~silent
%     tbSelectPlotEdit = (fig,'Tag','ScribeSelectToolBtn');
%     set(tbSelectPlotEdit,'State',state);   
% end

%------------------------------------------------------%
function state = LGetState(fig)
state = getappdata(fig,'scribeActive');
if isempty(state)
    state = 'off';
end

%------------------------------------------------------%
function LSetSelection(fig,state)
% switch state
%     case 'off'
%         try
%             fObj = getobj(fig);
%             if ~isempty(fObj)
%                 domethod(fObj,'deselectall');
%             end
%         catch
%             % when a figure is closed with a selection,
%             % we can't depend on the order of children being
%             % destroyed: fail silently and allow the window to close
%         end
%     case 'on'
% end

%------------------------------------------------------%
function LActivateWindowFcns(fig,state)
% windowFcns = {...
%         'WindowButtonDownFcn' ...
%         'WindowButtonMotionFcn' ...
%         'WindowButtonUpFcn' ...
%         'KeyPressFcn' ...
%     };
% switch state
%     case 'on'
%         saveFcns = getappdata(fig,'ScribeSaveWindowFcns');   
%         if isempty(saveFcns)
%             saveFcns = get(fig, windowFcns);
%             setappdata(fig,'ScribeSaveWindowFcns', saveFcns);
%         end
%         set(fig,windowFcns, {'scribeeventhandler' '' '' 'dokeypress(gcbf)'});
%     case 'off'
%         saveFcns = getappdata(fig,'ScribeSaveWindowFcns');
%         if ~isempty(saveFcns)
%             set(fig,windowFcns, saveFcns);
%             rmappdata(fig,'ScribeSaveWindowFcns');
%         end
% end

%------------------------------------------------------%
function LPrepareOverlay(f,state)
% saveProps = {...
%         'DoubleBuffer'};
% 
% switch state
%     case 'on'
%         axH=(f,'type','axes');
%         if ~isempty(axH)
%             overlay=double(find(handle(axH),'-class','graph2d.annotationlayer'));
%             if isempty(overlay)
%                 overlay = (axH,'Tag','ScribeOverlayAxesActive');
%             end
%         else
%             overlay=[];
%         end
%         
%         if isempty(overlay)
%             currentAxes = get(f,'CurrentAxes');
%             overlay = LAddOverlayAxes(f);
%             set(f,'CurrentAxes',currentAxes);
%             
%             % make sure new axes are created behind the overlay axes
%             % don't turn this off even if plotedit is off!
%             axesCreateFcn = get(0,'DefaultAxesCreateFcn');
%             set(f,'DefaultAxesCreateFcn', ...
%                 ['plotedit(gcbf,''promoteoverlay''); ' axesCreateFcn]);
%         end
%         
%         fh = getobj(f);
%         if isempty(fh)
%             fh = scribehandle(figobj(f));
%         end
%         
%         figSaveProps = getappdata(f,'ScribeFigSaveProps');
%         if isempty(figSaveProps)
%             figSaveProps = get(f,saveProps);
%             setappdata(f,'ScribeFigSaveProps',figSaveProps);
%         end
%         scribeVals = {...
%                 'on'};
%         
%         set(f, saveProps, scribeVals);
%     case 'off'
%         figSaveProps = getappdata(f,'ScribeFigSaveProps');   
%         if ~isempty(figSaveProps)
%             set(f,saveProps,figSaveProps);
%             rmappdata(f,'ScribeFigSaveProps');
%         end
% end

%------------------------------------------------------%
function aOverlay = LAddOverlayAxes(f)
aOverlay = [];
% aOverlay = graph2d.annotationlayer(...
%     'Parent',f,...
%     'Position',[0 0 1 1],...
%     'Box','off',...
%     'XLimMode','manual',...
%     'YLimMode','manual',...
%     'XColor',[.8 .8 .8],...
%     'YColor',[.8 .8 .8],...        
%     'XTick',[],...
%     'YTick',[],...
%     'Color','none',... %'Tag','ScribeOverlayAxesActive',...
%     'HitTest','off',...
%     'Visible','off',...
%     'CreateFcn','',...
%     'HandleVisibility','off'...
%     );

%------------------------------------------------------%
function LModifyFigMenus(fig,state)
figMenuBar = get(fig,'MenuBar');
switch state
    case 'off'
        if strcmp(figMenuBar,'none')
            return;
        end
        menuObjects = getappdata(fig,'ScribeSaveMenuHandles');
        oldMenuValues = getappdata(fig,'ScribeSaveMenuProps');
        toolObjects = getappdata(fig,'ScribeSaveToolHandles');
        oldToolValues = getappdata(fig,'ScribeSaveToolProps');
        if isempty(menuObjects) | isempty(oldMenuValues)
            return;
        end
        try
            if all(ishandle(menuObjects)) & all(ishandle(toolObjects))
                set(menuObjects,{'Callback' 'Tag' 'Enable'}, oldMenuValues);
                set(toolObjects,{'ClickedCallback' 'Tag'}, ...
                    oldToolValues);
            end % else, the menus have been reloaded...
        catch
            warning(['Failed to restore state for some menus: ' lasterr])
        end
    case 'on'
        if strcmp(figMenuBar,'none')
            return;
        end
        editMenu = findall(fig,'Type','uimenu','Tag','figMenuEdit');
        if ~isempty(editMenu)
            editPostCallback = get(editMenu,'Callback');
            if ~isempty(editPostCallback)
                eval(editPostCallback);
            end
        end
        menuObjects = LGetMenuList(fig);
        if isempty(menuObjects)
            if feature('figuretools') 
                set(fig,'MenuBar','none');
                set(fig,'MenuBar','figure');  % loads the default menus
            else
                feature('figuretools',1);
                set(fig,'MenuBar','none');
                set(fig,'MenuBar','figure');  % loads the default menus
                feature('figuretools',0);     % restore state
            end
            menuObjects = LGetMenuList(fig);
        end
        if isempty(menuObjects)
            error(['Unable to activate Plot Editor: ' lasterr]);
        end
        % save tools
        toolObjects = findall(fig,'Tag','figToolSave');
        oldValues = get(toolObjects,{'ClickedCallback' 'Tag'});
        setappdata(fig,'ScribeSaveToolProps', oldValues);
        setappdata(fig,'ScribeSaveToolHandles', toolObjects);
        set(toolObjects,...
            'ClickedCallback','domymenu(''menubar'',''save'',gcbf)',...
            'Tag','scrSaveMenu');
        % save menus
        oldValues = get(menuObjects,{'Callback' 'Tag' 'Enable'});
        setappdata(fig,'ScribeSaveMenuProps', oldValues);
        setappdata(fig,'ScribeSaveMenuHandles', menuObjects);
        callbacks = {...
                ''
            ''
            'domymenu(''updatemenu'',''edit'',gcbf);'
            'domymenu(''menubar'',''cut'',gcbf);'
            'domymenu(''menubar'',''copy'',gcbf);'
            'domymenu(''menubar'',''paste'',gcbf);'
            'domymenu(''menubar'',''clear'',gcbf);'
            'domymenu(''menubar'',''save'',gcbf);'
            'domymenu(''menubar'',''saveas'',gcbf);'
        };
        tags = {...
                ''
            ''
            'scrEditMenu'
            'scrCCCMenu'
            'scrCCCMenu'
            'scrPasteMenu'
            'scrCCCMenu'
            'scrSaveMenu'
            'scrSaveAsMenu'
        };
        enable =  {...
                'off'
            'off'
            'on'
            'on'
            'on'
            'on'
            'on'
            'on'
            'on'};
        set(menuObjects,{'Callback' 'Tag' 'Enable'}, cat(2, ...
            callbacks, tags, enable));
end

%------------------------------------------------------%
function h = LFindMenu(fig,tag)
h = findall(fig,'Type','uimenu','Tag',tag);
if length(h)>1  % ??? 
    h = h(1);
end

%------------------------------------------------------%
function V = LGetMenuList(fig)
try
    V = [...
            LFindMenu(fig,'figMenuEditSelectAll') ...
            LFindMenu(fig,'figMenuEditUndo') ...                 
            LFindMenu(fig,'figMenuEdit') ...
            LFindMenu(fig,'figMenuEditCut') ...
            LFindMenu(fig,'figMenuEditCopy') ...
            LFindMenu(fig,'figMenuEditPaste') ...
            LFindMenu(fig,'figMenuEditClear') ...
            LFindMenu(fig,'figMenuFileSave') ...
            LFindMenu(fig,'figMenuFileSaveAs') ...
        ];
catch
    V = [];
end

%------------------------------------------------------%
function h = LGetScribeObjectList(f)

fkids = allchild(f);
axH=findall(f,'type','axes');
if ~isempty(axH)
    overlay=double(find(handle(axH),'-class','graph2d.annotationlayer'));
    if isempty(overlay)
        overlay = findall(axH,'Tag','ScribeOverlayAxesActive');
    end
else
    overlay=[];
end
if ~isempty(overlay) & ishandle(overlay)
    % add everything in the overlay axis
    % this line creates the label objects if they don't already
    % exist
    labels = get(overlay,{'XLabel' 'YLabel' 'ZLabel' 'Title'});
    annotations = findall(overlay);
    % labels = [labels{:}]';
else
    labels = [];
    annotations = [];
end
% uicontext menus
cxm = findobj(fkids,'flat','Type','uicontextmenu');
myContextMenus = [...
        findobj(cxm, 'Tag', 'ScribeAxisObjContextMenu');
    findobj(cxm, 'Tag', 'ScribeAxistextObjContextMenu');
    findobj(cxm, 'Tag', 'ScribeEditlineObjContextMenu');   
];
% add children of the context menus
myContextMenus = findall(myContextMenus);
% hidden figobj storage
figStoreObj = findall(fkids,'flat','Tag','ScribeFigObjStorage');
% other vector objects
storageObj = findobj(fkids,'flat','Tag','ScribeHGBinObject');
h = [annotations; myContextMenus; figStoreObj; ...
        storageObj];


%--------------------------------------------------------------------%
%                       PlotEdit Context Menu 
%--------------------------------------------------------------------%

%--------------------------------------------------------------------%

function scribe_contextmenu(h,onoff)

h = handle(h);
fig = ancestor(h,'figure');
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
stype = get(h,'ShapeType');

if strcmpi(onoff,'on')
  % create and/or update context menus for scribe object
  switch stype
   case 'textarrow'
    uic = get(h.Tail,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'arrow_pinhead',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'arrow_unpinhead',h});
      % flip
      uimenu(uic,'HandleVisibility','off','Label','Reverse Direction','Callback',...
             {graph2dhelper('scribecallback'),'arrow_flip',h});
      % edit
      add_action_menu(uic,'on','Edit Text',{'textstringeditcb',h});
      % color
      add_colorprop_menu(uic,h,'on');
      % backgroundcolor
      add_colorprop_menu(uic,h,'off','Text Background','TextBackground');
      % font properties
      add_fontprops_menu(uic,h,'off');
      % line props
      add_lineprops_menus(uic,h,'off');
      % style
      create_enumstrprop_menu(h,'HeadStyle',uic,'Head Style','off',...
                              {'Plain','V-Back','C-Back','Diamond','Deltoid'},...
                              {'plain','vback2','cback2','diamond','deltoid'});
      % size
      create_numprop_menu(h,'HeadSize',uic,'Head Size','off',...
                          [6,8,10,12,15,20,25,30,40],'%1.0f');
      % properties, mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Tail),'uicontextmenu',uic);
      set(double(h.Heads),'uicontextmenu',uic);
      set(double(h.Srect),'uicontextmenu',uic);
      set(double(h.Text),'uicontextmenu',uic);
    end
   case {'arrow','doublearrow'}
    uic = get(h.Tail,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'arrow_pinhead',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'arrow_unpinhead',h});
      % flip
      uimenu(uic,'HandleVisibility','off','Label','Reverse Direction','Callback',...
             {graph2dhelper('scribecallback'),'arrow_flip',h});
      % color
      add_colorprop_menu(uic,h,'on');
      % line props
      add_lineprops_menus(uic,h,'off');
      % style
      create_enumstrprop_menu(h,'HeadStyle',uic,'Head Style','off',...
                              {'Plain','V-Back','C-Back','Diamond','Deltoid'},...
                              {'plain','vback2','cback2','diamond','deltoid'});
      % size
      create_numprop_menu(h,'HeadSize',uic,'Head Size','off',...
                          [6,8,10,12,15,20,25,30,40],'%1.0f');
      % properties, mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Tail),'uicontextmenu',uic);
      set(double(h.Heads),'uicontextmenu',uic);
      set(double(h.Srect),'uicontextmenu',uic);
    end        
   case 'line'
    uic = get(h.Tail,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'arrow_pinhead',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'arrow_unpinhead',h}); 
      % color
      add_colorprop_menu(uic,h,'on');
      % line props
      add_lineprops_menus(uic,h,'off');
      % properties, mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Tail),'uicontextmenu',uic);
      set(double(h.Srect),'uicontextmenu',uic);
    end
   case 'rectangle'
    % rect
    uic = get(h.Rect,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'pin_rect',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'unpin_scribepin',h});
      % facecolor
      add_colorprop_menu(uic,h,'on','Face','Face');
      % edge color
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % properties, mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Rect),'uicontextmenu',uic);
      set(double(h.FaceObject),'uicontextmenu',uic);
    end
   case 'ellipse'
    % rect
    uic = get(h.Rect,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'pin_rect',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'unpin_scribepin',h});
      % facecolor
      add_colorprop_menu(uic,h,'on','Face','Face');
      % edge color
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % properties, mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Rect),'uicontextmenu',uic);
      set(double(h.Ellipse),'uicontextmenu',uic);
    end
   case 'textbox'
    % rect
    uic = get(h.Rect,'UIContextMenu');
    if isempty(uic)
      uic = uicontextmenu('Parent',fig,'HandleVisibility','off','Callback',...
                          {@update_scribecontextmenu_cb,h});
      add_cutcopyclear_menus(uic,h,'off');
      % pin/unpin
      uimenu(uic,'HandleVisibility','off','Label','Pin to axes','Separator','on',...
             'Callback',{graph2dhelper('scribecallback'),'pin_rect',h});
      uimenu(uic,'HandleVisibility','off','Label','Unpin','Callback',...
             {graph2dhelper('scribecallback'),'unpin_scribepin',h});
      % edit
      add_action_menu(uic,'on','Edit',{'textstringeditcb',h});
      % text color
      add_colorprop_menu(uic,h,'on','Text');
      % backgroundcolor
      add_colorprop_menu(uic,h,'off','Background','Background');
      % edgecolor
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % font properties
      add_fontprops_menu(uic,h,'off');
      % interpreter
      create_enumstrprop_menu(h,'Interpreter',uic,'Interpreter','off',...
                              {'latex','tex','none'},{'latex','tex','none'});
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
      % set
      set(double(h.Rect),'uicontextmenu',uic);
      set(double(h.Text),'uicontextmenu',uic);
    end
  end
else
  % no op.
end

%-------------------------------------------------------------------%
function update_scribecontextmenu(h,onoff)

h = handle(h);
fig = ancestor(h,'figure');
stype = get(h,'ShapeType');

% update context menus for scribe object
switch stype
 case 'textarrow'
  uic = get(h.Tail,'UIContextMenu');
  if ~isempty(uic)
    % update lineprops menus
    update_lineprops_menus(uic,h);
    % check correct headstyle item
    update_enumstrprop_menu_checked(h,'HeadStyle',uic,'Head Style',...
                                    {'None','Plain','V-Back','C-Back','Diamond','Deltoid'},...
                                    {'none','plain','vback2','cback2','diamond','deltoid'});
    % check correct head size item
    update_numprop_menu_checked(h,'HeadSize',uic,'Head Size','%1.0f');            
  end
 case {'arrow','doublearrow'}
  uic = get(h.Tail,'UIContextMenu');
  if ~isempty(uic)
    % update lineprops menus
    update_lineprops_menus(uic,h);
    % check correct headstyle item
    update_enumstrprop_menu_checked(h,'HeadStyle',uic,'Head Style',...
                                    {'None','Plain','V-Back','C-Back','Diamond','Deltoid'},...
                                    {'none','plain','vback2','cback2','diamond','deltoid'});
    % check correct head size item
    update_numprop_menu_checked(h,'HeadSize',uic,'Head Size','%1.0f');
  end
 case 'line'
  uic = get(h.Tail,'UIContextMenu');
  if ~isempty(uic)
    % update lineprops menus
    update_lineprops_menus(uic,h);
  end
 case 'rectangle'
  % rect
  uic = get(h.Rect,'UIContextMenu');
  if ~isempty(uic)
    % update lineprops menus
    update_lineprops_menus(uic,h);
    % update pin/unpin
    pinmenu = findall(uic,'Type','uimenu','Label','Pin');
    if ~isempty(pinmenu)
      if isempty(h.Pin) && ...
            ~isempty(findobj(fig,'type','axes'))
        set(pinmenu,'Enable','on');
      else
        set(pinmenu,'Enable','off');
      end
    end
    unpinmenu = findall(uic,'Type','uimenu','Label','Unpin');
    if ~isempty(unpinmenu)
      if ~isempty(h.Pin)
        set(unpinmenu,'Enable','on');
      else
        set(unpinmenu,'Enable','off');
      end
    end
  end
 case 'ellipse'
  % rect
  uic = get(h.Rect,'UIContextMenu');
  if ~isempty(uic)
    % update lineprops menus
    update_lineprops_menus(uic,h)
    % update pin/unpin
    pinmenu = findall(uic,'Type','uimenu','Label','Pin');
    if ~isempty(pinmenu)
      if isempty(h.Pin) && ...
            ~isempty(findobj(fig,'type','axes'))
        set(pinmenu,'Enable','on');
      else
        set(pinmenu,'Enable','off');
      end
    end
    unpinmenu = findall(uic,'Type','uimenu','Label','Unpin');
    if ~isempty(unpinmenu)
      if ~isempty(h.Pin)
        set(unpinmenu,'Enable','on');
      else
        set(unpinmenu,'Enable','off');
      end
    end
  end
 case 'textbox'
  % rect
  uic = get(h.Rect,'UIContextMenu');
  if ~isempty(uic)
    % update borderprops menus
    update_lineprops_menus(uic,h);
    % check correct interpreter
    update_enumstrprop_menu_checked(h,'Interpreter',uic,'Interpreter',...
                                    {'latex','tex','none'},{'latex','tex','none'});
    % update pin/unpin
    pinmenu = findall(uic,'Type','uimenu','Label','Pin');
    if ~isempty(pinmenu)
      if isempty(h.Pin) && ...
            ~isempty(findobj(fig,'type','axes'))
        set(pinmenu,'Enable','on');
      else
        set(pinmenu,'Enable','off');
      end
    end
    unpinmenu = findall(uic,'Type','uimenu','Label','Unpin');
    if ~isempty(unpinmenu)
      if ~isempty(h.Pin)
        set(unpinmenu,'Enable','on');
      else
        set(unpinmenu,'Enable','off');
      end
    end
  end
end

%-------------------------------------------------------------------%
function update_scribecontextmenu_cb(hSrc,evdata,varargin)
update_scribecontextmenu(varargin{:});

%-------------------------------------------------------------------%
function nonscribe_contextmenu(h,onoff)

fig = ancestor(h,'figure');
skip = false;
if ~isempty(hggetbehavior(h,'Plotedit','-peek'))
  b = hggetbehavior(h,'Plotedit');
  skip = b.KeepContextMenu;
end
if isequal(onoff,'on') && ~skip
  htype = get(h,'Type');
  uic = get(h,'UIContextMenu');
  if isempty(uic)
    uic=uicontextmenu('Parent',fig,'HandleVisibility','off');
    % no existing context menu start with no separator
    sep = 'off';
    setappdata(uic,'WasEmptyContextmenu',true);
  else
    sep = 'on';
  end
  uch = findall(uic,'Type','uimenu');
  utag = get(uch,'Tag');
  % indices of scribe (plot edit) additions
  scribechindex = strcmpi(utag,'ScribeUIContextMenuItem');
  if ~any(scribechindex)
    % add scribe context menu items if they don't exist
    switch htype
     case 'axes'
      add_action_menu(uic,sep,'Add Data...',{'addaxesdata',h});
      add_general_action_menu(uic,'on','Cut',{@scribe_cut_cb,h});
      add_general_action_menu(uic,'off','Copy',{@scribe_copy_cb,h});
      add_general_action_menu(uic,'off','Paste',{@scribe_paste_cb,h});
      add_action_menu(uic,'off','Clear Axes',{'clearaxes',h});
      add_general_action_menu(uic,'off','Delete',{@scribe_delete_cb,h});
      add_action_menu(uic,'on','Show Legend',{'togglelegend',h});
      % color
      add_colorprop_menu(uic,h,'on');
      % grids
      add_toggleprops_menu(uic,h,'on','Grid',{'XGrid','YGrid','ZGrid'});
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     case 'line'
      add_cutcopyclear_menus(uic,h,sep);
      % color
      add_colorprop_menu(uic,h,'on');
      % line properties
      add_lineprops_menus(uic,h,'off');
      % marker properties
      add_markerprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);         
     case 'patch'
      add_cutcopyclear_menus(uic,h,sep);
      % facecolor
      add_colorprop_menu(uic,h,'on','Face','Face');
      % edge color
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % marker properties
      add_markerprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     case 'surface'
      add_cutcopyclear_menus(uic,h,sep);
      % facecolor
      add_colorprop_menu(uic,h,'on','Face','Face');
      % edge color
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % marker properties
      add_markerprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     case 'rectangle'
      add_cutcopyclear_menus(uic,h,sep);
      % facecolor
      add_colorprop_menu(uic,h,'on','Face','Face');
      % edge color
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     case 'text'
      add_cutcopyclear_menus(uic,h,sep);
      % edit
      add_action_menu(uic,'on','Edit',{'textstringeditcb',h});
      % text color
      add_colorprop_menu(uic,h,'on','Text');
      % backgroundcolor
      add_colorprop_menu(uic,h,'off','Background','Background');
      % edgecolor
      add_colorprop_menu(uic,h,'off','Edge','Edge');
      % font properties
      add_fontprops_menu(uic,h,'off');
      % interpreter
      create_enumstrprop_menu(h,'Interpreter',uic,'Interpreter','off',...
                              {'latex','tex','none'},{'latex','tex','none'});
      % edge properties
      add_lineprops_menus(uic,h,'off');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     case 'figure'
      % color
      add_colorprop_menu(uic,h,'on');
      % properties and mcode
      add_propsandmcode_menus(uic,h);
      % close
      add_action_menu(uic,'off','Close Figure',{'closefigure',h});
     case 'hggroup'
      add_cutcopyclear_menus(uic,h,sep);
      % specific hggroup types (plot objects)
      switch class(handle(h))
       case 'specgraph.areaseries'
        % facecolor
        add_colorprop_menu(uic,h,'on','Face','Face');
        % edge color
        add_colorprop_menu(uic,h,'off','Edge','Edge');
        % line properties
        add_lineprops_menus(uic,h,'off');
       case 'specgraph.barseries'
        % facecolor
        add_colorprop_menu(uic,h,'on','Face','Face');
        % edge color
        add_colorprop_menu(uic,h,'off','Edge','Edge');
        % bar width
        create_numprop_menu(h,'BarWidth',uic,'Bar Width','off',...
                            [.2,.3,.4,.5,.6,.7,.8,.9,1.0],'%1.1f');
        % layout
        create_enumstrprop_menu(h,'BarLayout',uic,'Bar Layout','off',...
                                {'Grouped','Stacked'},{'grouped','stacked'});
       case 'specgraph.contourgroup'
        % line color
        add_colorprop_menu(uic,h,'on','Line','Line');
        % line properties
        add_lineprops_menus(uic,h,'on');
        % fill
        add_toggleprops_menu(uic,h,'off','Fill',{'Fill'});
       case 'specgraph.quivergroup'
        % color
        add_colorprop_menu(uic,h,'on');
        % line properties
        add_lineprops_menus(uic,h,'off');
        % marker properties
        add_markerprops_menus(uic,h,'off');
        % auto scale factor
        create_numprop_menu(h,'AutoScaleFactor',uic,'Scale Factor','off',...
                            [.2,.3,.4,.5,.7,.9,1.0],'%1.1f');
       case 'specgraph.scattergroup'
        % marker face color
        add_colorprop_menu(uic,h,'on','Marker Face','MarkerFace');
        % marker edge color
        add_colorprop_menu(uic,h,'off','Marker Edge','MarkerEdge');
        % marker
        create_enumstrprop_menu(h,'Marker',uic,'Marker','off',...
                                {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none' },...
                                {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none' });
       case {'specgraph.stairseries','specgraph.stemseries','specgraph.errorbarseries'}
        % color
        add_colorprop_menu(uic,h,'on');
        % line properties
        add_lineprops_menus(uic,h,'off');
        % marker properties
        add_markerprops_menus(uic,h,'off');
      end                
      % properties and mcode
      add_propsandmcode_menus(uic,h);
     otherwise
      add_cutcopyclear_menus(uic,h,sep);
      % properties and mcode
      add_propsandmcode_menus(uic,h);
    end
    % set
    set(h,'UIContextMenu',uic);
  end
  % update items
  switch htype
   case 'axes'
    % find paste menu item and set enabled appropriately
    pastemenu = findall(uic,'Type','uimenu','Label','Paste');
    if ~isempty(pastemenu)
      if isempty(getappdata(0,'ScribeCopyBuffer'))
        set(pastemenu,'Enable','off');
      else
        set(pastemenu,'Enable','on');
      end
    end
    % find show/hide legend item and set label
    legendmenu = findall(uic,'Type','uimenu','Label','Show Legend');
    if isempty(legendmenu)
      legendmenu = findall(uic,'Type','uimenu','Label','Hide Legend');
    end
    if ~isempty(legendmenu)
      legh = legend(double(h));
      if isempty(legh) || strcmpi(get(legh,'Visible'),'off')
        set(legendmenu,'Label','Show Legend');
      else
        set(legendmenu,'Label','Hide Legend');
      end
    end
    % grids
    update_toggleprops_menu(uic,h,'Grid',{'XGrid','YGrid','ZGrid'});
   case {'line','patch','surface'}
    % update lineprops menus
    update_lineprops_menus(uic,h);
    % update marker menus
    update_markerprops_menus(uic,h);
   case 'rectangle'
    % update lineprops menus
    update_lineprops_menus(uic,h);
   case 'text'
    % check correct interpreter
    update_enumstrprop_menu_checked(h,'Interpreter',uic,'Interpreter',...
                                    {'latex','tex','none'},{'latex','tex','none'});
   case 'hggroup'
    % specific hggroup types (plot objects)
    switch class(handle(h))
     case 'specgraph.areaseries'
      % update lineprops menus
      update_lineprops_menus(uic,h);
     case 'specgraph.barseries'
      % check correct bar width
      update_numprop_menu_checked(h,'BarWidth',uic,'Bar Width','%1.1f');
      % check correct bar layout
      update_enumstrprop_menu_checked(h,'BarLayout',uic,'Bar Layout',...
                                      {'Grouped','Stacked'},{'grouped','stacked'});
     case 'specgraph.contourgroup'
      % update lineprops menus
      update_lineprops_menus(uic,h);
      % fill
      update_toggleprops_menu(uic,h,'Fill',{'Fill'});
     case 'specgraph.errorbarseries'
      % update lineprops menus
      update_lineprops_menus(uic,h);
      % update marker menus
      update_markerprops_menus(uic,h);
     case 'specgraph.quivergroup'
      % update lineprops menus
      update_lineprops_menus(uic,h);
      % update marker menus
      update_markerprops_menus(uic,h);
      % check correct autoscalefactor
      update_numprop_menu_checked(h,'AutoScaleFactor',uic,'Scale Factor','%1.1f');
     case 'specgraph.scattergroup'
      % check correct marker toggle
      update_enumstrprop_menu_checked(h,'Marker',uic,'Marker',...
                                      {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'},...
                                      {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'});
     case {'specgraph.stairseries','specgraph.stemseries'}
      % update lineprops menus
      update_lineprops_menus(uic,h);
      % update marker menus
      update_markerprops_menus(uic,h);
    end

   otherwise
  end
elseif ~skip
  % remove scribe additions
  uic = get(h,'UIContextMenu');
  if ~isempty(uic)
    % menu items
    uch = allchild(uic);
    utag = get(uch,'Tag');
    % indices of scribe (plot edit) additions
    scribechindex = strcmpi(utag,'ScribeUIContextMenuItem');
    if all(scribechindex) && ~isempty(getappdata(uic,'WasEmptyContextmenu'))
      % same number of items as plot edit items
      % delete context menu
      delete(uic);
      set(h,'UIContextMenu',[]);
    else
      % otherwise delete only
      delete(uch(scribechindex));
    end
  end
end

%--------------------------------------------------------------------%
% add an action that has a callback in scribecallback.m
function add_action_menu(uic,sep,label,cbargs)

uimenu(uic,'HandleVisibility','off','Label',label,'Separator', sep, ...
       'tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),cbargs{:}});

%--------------------------------------------------------------------%
% add an action with arbitrary callback
function add_general_action_menu(uic,sep,label,cb)

uimenu(uic,'HandleVisibility','off','Label',label,'Separator', sep, ...
       'tag','ScribeUIContextMenuItem',...
       'Callback',cb);

%--------------------------------------------------------------------%
function add_cutcopyclear_menus(uic,h,sep);

add_general_action_menu(uic,sep,'Cut',{@scribe_cut_cb,h});
add_general_action_menu(uic,'off','Copy',{@scribe_copy_cb,h});
add_general_action_menu(uic,'off','Delete',{@scribe_delete_cb,h});

%--------------------------------------------------------------------%
function add_fontprops_menu(uic,h,sep)

uimenu(uic,'HandleVisibility','off','Label','Font...','Separator',sep,...
       'tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),'fontpropscb',h});

%-------------------------------------------------------------------%
function add_colorprop_menu(uic,h,sep,labprefix,propprefix)

if nargin>=4
  label = [labprefix ' ' 'Color...'];
else
  label = 'Color...';
end
if nargin>=5
  propname = [propprefix 'Color'];
else
  propname = 'Color';
end  
uimenu(uic,'HandleVisibility','off','Label',label,'Separator',sep,...
       'tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),'colorpropcb',h,propname});

%-------------------------------------------------------------------%
function add_toggleprops_menu(uic,h,sep,label,propnames)

uimenu(uic,'HandleVisibility','off','Label',label,'Separator',sep,...
       'tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),'togglepropscb',h,propnames})

%-------------------------------------------------------------------%
function update_toggleprops_menu(uic,h,label,propnames)

% find and set checked on/off for xgridmenu
tmenu = findall(uic,'Type','uimenu','Label',label,'Tag','ScribeUIContextMenuItem');
if ~isempty(tmenu)
  if all(strcmpi(get(h,propnames),'on'))
    set(tmenu,'Checked','on')
  else
    set(tmenu,'Checked','off');
  end
end

%-------------------------------------------------------------------%
function add_lineprops_menus(uic,h,sep,labprefix,propprefix)

if nargin>=4
  wlabel = [labprefix ' ' 'Line Width'];
  slabel = [labprefix ' ' 'Line Style'];
else
  wlabel = 'Line Width';
  slabel = 'Line Style';
end
if nargin>=5
  wpropname = [propprefix 'LineWidth'];
  spropname = [propprefix 'LineStyle'];
else
  wpropname = 'LineWidth';
  spropname = 'LineStyle';
end
% edge line width
create_numprop_menu(h,wpropname,uic,wlabel,sep,...
                    [.5,1,2,3,4,5,6,7,8,9,10,12],'%1.1f');
% edge line style
create_enumstrprop_menu(h,spropname,uic,slabel,'off',...
                        {'solid','dash','dot','dash-dot','none'},...
                        {'-','--',':','-.','none'});

%-------------------------------------------------------------------%
function update_lineprops_menus(uic,h,labprefix,propprefix)

if nargin>=3
  wlabel = [labprefix ' ' 'Line Width'];
  slabel = [labprefix ' ' 'Line Style'];
else
  wlabel = 'Line Width';
  slabel = 'Line Style';
end
if nargin>=4
  wpropname = [propprefix 'LineWidth'];
  spropname = [propprefix 'LineStyle'];
else
  wpropname = 'LineWidth';
  spropname = 'LineStyle';
end
% check correct linewidth item
update_numprop_menu_checked(h,wpropname,uic,wlabel,'%1.1f');
% check correct edgelinestyle item
update_enumstrprop_menu_checked(h,spropname,uic,slabel,...
                                {'solid','dash','dot','dash-dot','none'},...
                                {'-','--',':','-.','none'});

%-------------------------------------------------------------------%
function add_markerprops_menus(uic,h,sep)

% marker
create_enumstrprop_menu(h,'Marker',uic,'Marker',sep,...
                        {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none' },...
                        {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none' });
% marker size
create_numprop_menu(h,'MarkerSize',uic,'Marker Size','on',...
                    [2,4,5,6,7,8,10,12,18,24,48],'%1.0f');

%-------------------------------------------------------------------%
function update_markerprops_menus(uic,h)

% check correct marker toggle
update_enumstrprop_menu_checked(h,'Marker',uic,'Marker',...
                                {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'},...
                                {'+','o','*','.','x','square','diamond','v','^','>','<','pentagram','hexagram','none'});
% check correct markersize toggle
update_numprop_menu_checked(h,'MarkerSize',uic,'Marker Size','%1.0f');

%-------------------------------------------------------------------%
function add_propsandmcode_menus(uic,h)

% properties
uimenu(uic,'HandleVisibility','off','Label','Properties...',...
       'Separator','on',...
       'Tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),'propeditcb',h});
% mcode
uimenu(uic,'HandleVisibility','off','Label','Show M-code',...
       'Separator','on',...
       'Tag','ScribeUIContextMenuItem',...
       'Callback',{graph2dhelper('scribecallback'),'makemcode',h});            

%-------------------------------------------------------------------%
function create_numprop_menu(h,propname,parent,label,sep,values,format)
% create a menu for a numeric property in a scribe context menu

m=uimenu(parent,...
         'HandleVisibility','off',...
         'Label',label,...
         'Separator',sep,...
         'Tag','ScribeUIContextMenuItem');
for k=1:length(values)
  uimenu(m,...
         'HandleVisibility','off',...
         'Label',sprintf(format,values(k)),...
         'Separator','off',...
         'Tag','ScribeUIContextMenuItem',...
         'Callback',{graph2dhelper('scribecallback'),'propvalcb',h,propname,values(k)});
end

%-------------------------------------------------------------------%
function create_enumstrprop_menu(h,propname,parent,label,sep,labels,values)
% create a menu for an enumerated string property in a scribe context menu

m=uimenu(parent,...
         'HandleVisibility','off',...
         'Label',label,...
         'Separator',sep,...
         'Tag','ScribeUIContextMenuItem');
for k=1:length(labels)
  uimenu(m,...
         'HandleVisibility','off',...
         'Label',labels{k},...
         'Separator','off',...
         'Tag','ScribeUIContextMenuItem',...
         'Callback',{@setcb,h,propname,values{k}});
end

function setcb(hSrc,evdata,h,propname,val)
set(h,propname,val);

%-------------------------------------------------------------------%
function update_numprop_menu_checked(h,propname,parent,label,format)

m = findall(parent,'Type','uimenu','Label',label,'Tag','ScribeUIContextMenuItem');
if ~isempty(m)
  mitems = allchild(m);
  if ~isempty(mitems)
    set(mitems,'Checked','off');
    mitem=findall(m,'Label',sprintf(format,get(h,propname)));
    if ~isempty(mitem)
      set(mitem,'Checked','on');
    end
  end
end

%-------------------------------------------------------------------%
function update_enumstrprop_menu_checked(h,propname,parent,label,labels,values)

m = findall(parent,'Type','uimenu','Label',label,'Tag','ScribeUIContextMenuItem');
if ~isempty(m)
  mitems = allchild(m);
  if ~isempty(mitems)
    set(mitems,'Checked','off');
    labindex=find(strcmpi(get(h,propname),values));
    if ~isempty(labindex)
      mitem=findall(m,'Label',labels{labindex});
      if ~isempty(mitem)
        set(mitem,'Checked','on');
      end
    end
  end
end

%-----------------------------------------------%
function scribe_delete(h)

if strcmp(get(double(h),'Type'),'figure')
  fig = double(h);
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
    scribeax.methods('delete_selected_objs');
  end
else
  fig = ancestor(double(h),'figure');
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
    scribeax.methods('delete_obj',h);
  else
    delete(h);
  end
end

function scribe_delete_cb(hSrc,evdata,h)
scribe_delete(h)

%-----------------------------------------------%
function scribe_copy(h)

if strcmp(get(double(h),'Type'),'figure')
  fig = double(h);
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
    scribeax.methods('copy_selected_objs',false);
  end
else
  fig = ancestor(double(h),'figure');
  scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
  if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
    scribeax.methods('copy_obj',h,false);
  elseif isempty(scribeax)
    plotedit(fig,'on');
    scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
    scribeax.methods('copy_obj',h,false);
  end
end

function scribe_copy_cb(hSrc,evdata,h)
scribe_copy(h)

%-----------------------------------------------%
function scribe_cut(h)
scribe_copy(h);
scribe_delete(h);

function scribe_cut_cb(hSrc,evdata,h)
scribe_cut(h)

%-----------------------------------------------%
function scribe_paste(h)

if strcmpi(get(double(h),'Type'),'figure')
  fig = double(h);
else
  fig = ancestor(double(h),'figure');
end
if isempty(fig)
  fig=gcf;
end
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
  methods(scribeax,'paste_copybuffer',fig);
end

function scribe_paste_cb(hSrc,evdata,h)
scribe_paste(h)

%-----------------------------------------------%
function scribe_selectall(h)
if strcmpi(get(double(h),'Type'),'figure')
  fig = double(h);
else
  fig = ancestor(double(h),'figure');
end
if isempty(fig)
  fig=gcf;
end
scribeax = handle(getappdata(fig,'Scribe_ScribeOverlay'));
if ~isempty(scribeax) && ishandle(scribeax) && ~strcmpi(get(scribeax,'BeingDeleted'),'on')
  shapes = get(scribeax,'children');
  ax = findobj(get(fig,'children'),'flat','type','axes');
  if ~isempty(ax)
    axNonData(1) = true;
    for k=length(ax):-1:1
      axNonData(k) = isappdata(ax(k),'NonDataObject');
    end
    ax(axNonData) = [];
  end
  selectobject([shapes;ax],'replace');
end

%-----------------------------------------------%
function update_edit_menu(hfig,allfigs)

if nargin == 1, allfigs = true; end

edit = findall(allchild(hfig),'flat','type','uimenu','tag','figMenuEdit');
if isempty(edit), return; end
kids = allchild(edit);
cut = findall(kids,'flat','Tag','figMenuEditCut');
copy = findall(kids,'flat','Tag','figMenuEditCopy');
paste = findall(kids,'flat','Tag','figMenuEditPaste');
clear = findall(kids,'flat','Tag','figMenuEditClear');
selectall = findall(kids,'flat','Tag','figMenuEditSelectAll');
if ~isappdata(hfig, 'scribeActive')
  if anytextediting(hfig), 
    onoff = 'on';
  else
    onoff = 'off';
  end
  set([cut copy paste clear selectall],'enable',onoff);
else
  scribeax = handle(getappdata(hfig,'Scribe_ScribeOverlay')); 

  % cut copy clear disable/enable
  selectedobjs = scribeax.SelectedObjects;
  if isempty(selectedobjs) || ...
        any(strcmp(get(selectedobjs,'Type'),'figure'))
    cccenable = 'off';
  else
    cccenable = 'on';
  end
  set([cut copy clear],'enable',cccenable);

  % paste enable/disable
  if isempty(getappdata(0,'ScribeCopyBuffer'))
    penable = 'off';
  else
    penable = 'on';
  end
  set(paste,'enable',penable);
  if allfigs
    update_all_paste_menus(penable);
  end
  set(selectall,'enable','on');
end

%-----------------------------------------------%
% update paste menu on all figs with plotedit turned on
function update_all_paste_menus(penable)
figs = allchild(0);
figs = figs(:).';
for hfig=figs
  if isappdata(hfig,'scribeActive')
    edit = findall(allchild(hfig),'flat','type','uimenu','tag','figMenuEdit');
    if isempty(edit), continue; end
    kids = allchild(edit);
    paste = findall(kids,'flat','Tag','figMenuEditPaste');
    set(paste,'enable',penable);
  end
end

%-----------------------------------------------%
function res = anytextediting(fig)
objs = findall(fig,'type','text');
res = any(strcmp(get(objs,'Editing'),'on'));
