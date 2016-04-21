function domymenu(method, parameter, object)
%DOMYMENU  handle menus for Plot editor

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.66.4.7 $  $Date: 2004/04/10 23:26:10 $

if strcmp(method,'menubar')
   LDoMenubar(gcbf, parameter);
   return
end

if nargin==3
   CurrentHGObj = object;
else
   CurrentHGObj = gcoall(gcbf);
end

ud = getscribeobjectdata(CurrentHGObj);
if isempty(ud)
   primaryObj = getappdata(CurrentHGObj,'ScribeButtonDownHGObj');
   if ~isempty(primaryObj) & ishandle(primaryObj)
      ud = getscribeobjectdata(primaryObj);
   end
end

try
   if ~isempty(ud)
      A = ud.ObjectStore;
   else
      A = [];
   end
   % can't do this:
   % if isstruct(ud) & isfield(ud,'ObjectStore')
   % because we've overloaded subsref for fighandle objects
   % which is what we have in the figure ScribeObjectData
catch
   if strcmp(method,'menubar')
      A = [];
      % we don't need to have plotedit on...
      LDoMenubar(CurrentHGObj, parameter);
      return
   else
      return
   end
end

try
   switch method
   case 'menubar'
      LDoMenubar(CurrentHGObj, parameter);

   case 'update'
      A = doselect(A);
      A = updatemenu(A);
      UIC = gcbo;
      
      [copyBufferFig, copyBufferAx] = getcopybuffer('noforce');
      if ~isempty(copyBufferFig) ...
                 & ~isempty(LGetSelection(copyBufferFig))
         set(findall(UIC,'Label','&Paste'),...
                 'Enable','on');
      else
         set(findall(UIC,'Label','&Paste'),...
                 'Enable','off');
      end

      callingObject = getappdata(UIC, 'ScribeOneShotContextMenuFlag');
      if ~isempty(callingObject)
         try
            set(callingObject,{'UIContextMenu' 'ButtonDownFcn'}, ...
                    getappdata(UIC,'ScribeSaveFcns'));
            rmappdata(UIC,'ScribeSaveFcns');
         catch
            warning('Object properties may be corrupted.');
         end
      end
   case 'updatemenu'
      myFig = get(A,'Figure');      
      switch parameter
      case 'edit'
         CCCMenu = findall(myFig,'Tag','scrCCCMenu');
         selection = LGetSelection(myFig);
         if isempty(selection)
            set(CCCMenu,'Enable','off');
         else
            set(CCCMenu,'Enable','on'); 
         end
         
         [copyBufferFig, copyBufferAx] = getcopybuffer('noforce');
         if ~isempty(copyBufferFig) ...
            & ~isempty(LGetSelection(copyBufferFig))
            set(findall(myFig,'Tag','scrPasteMenu'),...
                    'Enable','on');
         else
            set(findall(myFig,'Tag','scrPasteMenu'),...
                    'Enable','off');
         end
         
         switch plotedit(myFig,'getenabletools')
         case 'off'
            PasteMenu = findall(myFig,'Tag','scrPasteMenu');
            set([PasteMenu; CCCMenu],'Enable','off');
         % otherwise % 'on'
         end
      end
      
      if ~usejava('mwt')
          %There are no r11 property editors for figure and most axes children,
          %so disable the figure and current object edit options on the figure menu
          set(findall(myFig,'tag','figMenuEditGCF'),'visible','off');
          set(findall(myFig,'tag','figMenuEditGCA'),'separator','on');
          set(findall(myFig,'tag','figMenuEditGCO'),'visible','off');
      end
      
   case 'style'
      %jpropeditutils('jundo','start',myFig);
      A = editstyle(A,parameter);
      myFig = get(A,'Figure');      
      myClass = class(A);
      selection = LGetSelection(myFig);
      for aObj = selection
         switch myClass
         case {'arrowline' 'editline'}
            if isa(aObj,'arrowline') | isa(aObj,'editline')
               domethod(aObj, 'editstyle', parameter);
            end
         otherwise
            if isa(aObj,myClass)
               domethod(aObj, 'editstyle', parameter);
            end
         end
      end
      %jpropeditutils('jundo','stop',myFig);
      LUpdateLegend(selection);
      
   case 'size'
      %jpropeditutils('jundo','start',myFig);
      A = editsize(A,parameter);
      myFig = get(A,'Figure');
      myClass = class(A);
      selection = LGetSelection(myFig);
      for aObj = selection
         switch myClass
         case {'arrowline' 'editline'}
            if isa(aObj,'arrowline') | isa(aObj,'editline')
               domethod(aObj, 'editsize', parameter);
            end
         otherwise
            if isa(aObj,myClass)
               domethod(aObj, 'editsize', parameter);
            end
         end
      end
      %jpropeditutils('jundo','stop',myFig);
      LUpdateLegend(selection);
      
   case 'color'
      myColor = get(A,'Color');
      myFig = get(A,'Figure');
      selection = LGetSelection(myFig);
      if length(selection)==1
         c = uisetcolor(myColor);
      else % multiple objects: we really need to see if there
           % was a cancel
         c = uisetcolor;
      end
      if length(c)==1 & c==0
         % cancel
         return
      end
      
      %Register this action with undo
      %jpropeditutils('jundo','start',myFig);
      for aObj = selection
         if ~strcmp(class(aObj),'axisobj')  % don't change
                                            % axes color
            set(aObj,'Color',c);
         end
      end
      %jpropeditutils('jundo','stop',myFig);
      LUpdateLegend(selection);
      
   case 'string'
      A = editopen(A);
   case 'moveresize'
      % A = editmoveresize(A);
      newstate = ~get(A,'Draggable');
      % write back current changes
      LWriteBack(A,ud,CurrentHGObj);
      for a = LGetSelection(get(A,'Figure'))
         if strcmp(class(a),'axisobj')
            set(a,'Draggable',newstate);
         end
      end
      return  % avoid second writeback

   case 'showlegend'
      %Register this action with undo
      %jpropeditutils('jundo','start');

      if islegendon(get(A,'MyHGHandle'))
         newstate = 'off';
      else
         newstate = 'on';
      end
      % write back current changes
      LWriteBack(A,ud,CurrentHGObj);
      for a = LGetSelection(get(A,'Figure'))
         if strcmp(class(a),'axisobj')
            domethod(a,'showlegend',newstate);
         end
      end
      %jpropeditutils('jundo','stop');
      return  % avoid second writeback
      
   case 'more'
      A = editopen(A);
   case 'font'
      A = editfont(A);
   case {'cut' 'copy' 'paste' 'clear'}
      myFig = get(A,'Figure');
      cutcopypaste(myFig, method);
      return
   end

   LWriteBack(A,ud,CurrentHGObj);

catch
   warning(['Error executing plot editor menu: ' lasterr]);
end


function LWriteBack(A,ud,HG)
if ~isempty(A)
   ud.ObjectStore = A;
   if ishandle(HG) % we may have deleted the object
      setscribeobjectdata(HG,ud);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LDoMenubar(myFig, method)

switch method
case {'cut' 'copy' 'paste' 'clear'}
   cutcopypaste(myFig, method);
case {'save' 'saveas'}
   selection = LGetSelection(myFig);
   plotedit(myFig,'off','silent');
   % clear before saving
   scribeclearmode(myFig,'');
   switch method
   case 'save'
      filemenufcn(myFig,'FileSave');
   case 'saveas'
      filemenufcn(myFig,'FileSaveAs');
   end
   plotedit(myFig,'on');
   % restore selection
   for a = selection
      set(a,'IsSelected',1);
   end
case 'toggletoolbar'
    %jpropeditutils('jundo','start',myFig);
    
    hTB = findall(myFig,'Tag','FigureToolBar');
    if isempty(hTB)
        oldFeature=feature('figuretools');
        feature('figuretools',1);
        set(myFig,'ToolBar','figure');
        feature('figuretools',oldFeature);
        
        hTB = findall(myFig,'Tag','FigureToolBar');
        
        %initialize the toolbar appropriately
        offon = {'off' 'on'};
        set(findall(hTB,'Tag','ScribeSelectToolBtn'),...
            'state',offon{plotedit(myFig,'isactive')+1});
        
        zoomInActive=0;
        zoomOutActive=0;
        switch zoom(myFig,'getmode')
        case {'in','on'}
            zoomInActive=1;
        case 'out'
            zoomOutActive=1;
        end
        set(uigettoolbar(hTB,'Exploration.ZoomOut'),...
            'state',offon{zoomOutActive+1});
        set(uigettoolbar(hTB,'Exploration.ZoomIn'),...
            'state',offon{zoomInActive+1});

        isRotate3dActive=~isempty(findall(myFig,'type','axes','Tag','MATLAB_Rotate3D_Axes'));
        set(uigettoolbar(hTB,'Exploration.Rotate'),...
            'state',offon{isRotate3dActive+1});
        
        %BUG: To my knowledge, there is no way to query SCRIBE
        %to see if it is in linedraw, text-insert, or arrow-draw mode
        %so we can not initialize the toolbar to these states
    elseif strcmp(get(hTB,'visible'),'on')
        set(hTB,'visible','off');
    else
        set(hTB,'visible','on');
    end
    
    %jpropeditutils('jundo','stop',myFig);
    drawnow
    
case 'lockaxes'
    selection = LGetSelection(myFig);
   axesObjects = [];
   axLock = [];
   for a = selection
      if strcmp(class(a),'axisobj')
         axesObjects = [axesObjects a];
         axLock(end+1) = get(a,'Draggable');
      end
   end
   if ~isempty(axLock)
      if length(find(axLock)) > length(axLock)/2
         setDrag = 0;  % lock
      else
         setDrag = 1;  % unlock
      end
      for a = axesObjects
         set(a,'Draggable',setDrag);
      end
   end
case 'figureprop'
   LEditByType(myFig,myFig); 
case 'axesprop'
    h=LocSelectionHandles(myFig);

    hAxesIndices=find(strcmp(get(h,'Type'),'axes'));
    if ~isempty(hAxesIndices)
        h=h(hAxesIndices);
    else
        h=gca(myFig);
    end
    
    plotedit(myFig,'on');
    propedit(h);
    
    
case 'currentprop'
    currObj=LocSelectionHandles(myFig);
    
    if isempty(currObj)
        currObj=get(myFig,'currentobject');
    end

    if isempty(currObj)
        axChild=get(get(myFig,'CurrentAxes'),'Children');
        if ~isempty(axChild)
            currObj=axChild(1);
        else
            currObj=myFig;
        end
    end
    
    plotedit(myFig,'on');
    propedit(currObj);
    
case 'lineprop'
   LEditByType(myFig,'line');
case 'textprop'
   LEditByType(myFig,'text');
   
case 'legend'
    % turns the legend on - if it is off
    % setup the axObjects array then calling domethod() with the axes
    % scribehandle, 'showlegend' function and 'on' parameter
    % most of the work is in getting the scribehandle for the axes
    
    
    axObjects = [];
    
    ploteditOn = plotedit(myFig,'isactive');
    
    if ploteditOn
        % look for any and all selected axes as follows
        % first get a vector containing the Items of the DragObjects structure
        % of the scribe object of the Figure (all selected objects).
        selection = LGetSelection(myFig);
        % loop through the vector of selected objects
        for a = selection
            if strcmp(class(a),'axisobj')
                % if it's an axisobject
                % add it to the axObjects Array
                axObjects = [axObjects a];
            end
        end
    end
   
    % if there's no selected axes
    if isempty(axObjects)
       % get current axes of figure
        ax = get(myFig,'CurrentAxes');
        if ~isempty(ax)
            % get scribe object of axes
            axObjects = getobj(ax);
            
           % if there isn't a scribe object for axes, make it one
            if isempty(axObjects)
                axObjects = scribehandle(axisobj(ax));
            end
            
        end
    end

    % no axes in figure means nothing else to do
    if isempty(axObjects)
        return;
    end
    
    if ~ploteditOn 
        % if plot edit wasn't on, turn it on silently
        plotedit(myFig,'on','silent')
    end
    
    % do the showlegend method on a with param 'on'
    for a = axObjects
        domethod(a, 'showlegend', 'on');
    end
      
    % if plotedit wasn't on before, silently turn it off.
    if ~ploteditOn
        plotedit(myFig,'off','silent');
    end
case 'addaxes'
   putdowntext('axesstart');
case 'addtext'
   toolButton = findall(myFig,'ToolTip', 'Insert Text');
   putdowntext('textstart',toolButton);
case 'addarrow'
   toolButton = findall(myFig,'ToolTip', 'Insert Arrow');
   putdowntext('arrowstart',toolButton);
case 'addline'
   toolButton = findall(myFig,'ToolTip', 'Insert Line');
   putdowntext('linestart',toolButton);
case 'addxlabel'
    LEditAxesText(myFig,'Xlabel');
case 'addylabel'
    LEditAxesText(myFig,'Ylabel');
case 'addzlabel'
    LEditAxesText(myFig,'Zlabel');
case 'addtitle'
    LEditAxesText(myFig,'Title');
case 'addlight'
    %jpropeditutils('jundo','start',myFig);
    
    if plotedit(myFig,'isactive')
        axH=LocSelectionHandles(myFig);
    else
        axH=[];
    end
    
    if isempty(axH)
        axH=get(myFig, 'currentaxes');
    end
    
    %Note that jaddlight can deal with non-axes handles as well
    lightH=jpropeditutils('jaddlight',axH);
    
    if plotedit(myFig,'isactive')
        %we may not have added any lights if there were no axes or axes children selected
        if isempty(lightH)
            lightH = jpropeditutils('jaddlight',get(myFig, 'currentaxes'));
        end
    else
        plotedit(myFig,'on');
    end
    
	if ~isempty(lightH)
%         jpe=com.mathworks.page.propertyeditor.PropertyEditor.getPropertyEditor
%         jpe.edit(lightH);    
        propedit(lightH,'-noselect');
    end
    
    %jpropeditutils('jundo','stop',myFig);
    
case 'addyaxis'
    axH = gca;
    parent = get(axH,'parent');

    %jpropeditutils('jundo','start',axFigure);

    yAx = copyobj(axH,parent);
    
    %Put the y-axis ruler on the other side        
    if strcmp(get(axH,'YAxisLocation'),'right')
        yAxLoc='left';
    else
        yAxLoc='right';
    end
    
    %Shift the ColorOrder by the number of line children the principal axes has
    %Shift the LineStyleOrder by the number of line children the principal axes has
    nChild=length(findobj(axH,'type','line'));
    cOrder=get(axH,'ColorOrder');
    cIndex=min(nChild,length(cOrder));
    cOrder=[cOrder(cIndex+1:end,:);cOrder(1:cIndex,:)];
    lsOrder=get(axH,'LineStyleOrder');
    lsIndex=min(nChild,length(lsOrder));
    lsOrder=[lsOrder(lsIndex+1:end,:);lsOrder(1:lsIndex,:)];
    
    set(yAx,...
        'ALimMode','manual',...
        'CameraPositionMode','auto',...
        'CameraTargetMode','auto',...
        'CameraUpVectorMode','auto',...
        'CameraViewAngleMode','auto',...
        'CLimMode','manual',...
        'Color','none',...
        'ColorOrder',cOrder,...
        'LineStyleOrder',lsOrder,...
        'DataAspectRatioMode','auto',...
        'PlotBoxAspectRatioMode','auto',...
        'Selected','off',...
        'Tag','Y Axis 2',...
        'UIContextMenu',[],...
        'UserData',[],...
        'XGrid','off',...
        'XLimMode','manual',...
        'XTick',[],...
        'ZGrid','off',...
        'ZLimMode','manual',...
        'ZTick',[],...
        'YAxisLocation',yAxLoc,...
        'YLimMode','auto',...
        'YTickMode','auto',...
        'YTickLabelMode','auto',...
        'ButtonDownFcn','',...
        'CreateFcn','',...
        'Selected','off');
    
    %clear out application data
    allAppData=getappdata(yAx);
    if isstruct(allAppData) & ~isempty(allAppData)
    	fNames=fieldnames(allAppData);
        for i=1:length(fNames)
 			rmappdata(yAx,fNames{i});           
        end
    end
  
    delete(allchild(yAx));
    set(get(yAx,'YLabel'),'String','Y Axis 2');
    set(gcf,'currentaxes',yAx);
    
    %jpropeditutils('jundo','stop',parent);

case 'addcolorbar'    
    ax = get(myFig,'currentaxes');
    hColorbar = colorbar('peer',ax);    
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
case 'zoomin'
    fixtoolbar(myFig);   
    switch zoom(myFig,'getmode')
    case {'off' 'out'}
        zoom(myFig,'inmode');
    case {'in' 'on'}
        zoom(myFig,'off');
    end
case 'zoomout'
    fixtoolbar(myFig);   
   switch zoom(myFig,'getmode')
      case {'on' 'off' 'in'}
         zoom(myFig,'outmode');
      case 'out'
         zoom(myFig,'off');
   end
case 'rotate3d'
   fixtoolbar(myFig);
   rotate3d(myFig);
case 'inittoolsmenu'
    LUpdateToolsMenu(myFig);
case 'initviewmenu'
    LUpdateViewMenu(myFig);
case 'initinsertmenu'
    LUpdateInsertMenu(myFig);
case 'initcameramotionmode'
    modeParent=findall(myFig,'type','uimenu','tag','figMenuCameraMotionMode');
    modeItems=allchild(modeParent);
    set(modeItems,'checked','off');
    currMode=cameratoolbar('getmode');
    activeItem=findall(modeItems,'tag',['figMenuMode_' currMode]);
    set(activeItem,'Checked','on');
case 'initcameraprincipalaxis'
    paxParent=findall(myFig,'type','uimenu','tag','figMenuCameraPAx');
    paxItems=allchild(paxParent);
    offon={'off','on'};
    isActive=ismember(cameratoolbar('getmode'), {'orbit' 'pan' 'walk'});
    set(paxItems,'checked','off','enable',offon{isActive+1});

    if isActive
		currPAx=cameratoolbar('getcoordsys');
        activeItem=findall(paxItems,'tag',['figMenuAxis_' currPAx]);
        set(activeItem,'Checked','on');
    end
case 'initoptimizeaxesmode'
    bashParent = findall(myFig,'type','uimenu','tag','figMenuOA3DMode');
    bashItems=findall(bashParent,'type','uimenu');
    set(bashItems,'checked','off');
    bashMode=cameratoolbar('getoptimizeaxesmode');
    activeItem=findall(bashItems,'tag',['figMenuOA3D_' bashMode]);
    set(activeItem,'checked','on');
case 'togglecamera'
    camModes={'orbit','nomode'};
    isActive=~isempty(cameratoolbar('getmode'));
    cameratoolbar('setmode',camModes{isActive+1});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LEditAxesText(MyFig,textType)
%Triggered in response to "add xlabel" etc

axisH=get(MyFig,'currentaxes');
textH = get(axisH,textType);

% Add undo/redo support here
% % Create a command object
% cmd.Name = 'Add Text';
% cmd.Target = handle(textH);
% cmd.TargetProperties = {'String'};
% cmd.Container = MyFig;
% Record new text string
% record_start(cmd);

set(textH,'Editing','on');
waitfor(textH,'Editing','off');

% record_stop(cmd);

% % Add command object to command manager
% cmd_manager = getCommandManager(MyFig);
% cmd_manager.add(cmd);

% Update property editor
if ishandle(textH) & ~strcmp(get(textH,'BeingDeleted'),'on')
    %Note that the user can turn editing off by closing the
    %figure or deleting the object
    propedit(textH,'-noopen');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectVector = LGetSelection(aFig)
objectVector = [];
% get the scribe object, if there is one
aFigObjH = getobj(aFig);
if ~isempty(aFigObjH)
   % if there is one
   % it has "DragObjects"
   dragBinH = aFigObjH.DragObjects;
   % and the "DragObjects" has "Items"
   objectVector = dragBinH.Items;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LUpdateLegend(objects)
parents = [];
for a = objects
   parents(end+1) = get(a,'Parent');
end
parents = findobj(unique(parents),'flat','Type','axes');
%filter out r11-style annotation layers
parents(find(strcmp(get(parents,'Tag'),'ScribeOverlayAxesActive'))) = [];

if ~isempty(parents)
   for ax = parents'
       if ~isa(handle(ax),'graph2d.annotationlayer')
           %filter out r12-style annotation layers
           legend(ax);
       end
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LSetFont(co,dlgtitle)

fontprops = {'FontName'...
           'FontUnits'...
           'FontSize'...
           'FontWeight'...
           'FontAngle'};
fontvals = get(co,fontprops);
c = reshape(cat(1,fontprops,fontvals),5,2);
s = struct(c{:});
s = uisetfont(s,dlgtitle);
if isstruct(s)
   set(co,s);
   if strcmp('axes',get(co,'Type'))
      legend(co);
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LEditByType(myFig,aObj)
% aFig a handle to the figure from which the call was made
% aObj can be a string (object type) or a handle

if ischar(aObj)
    %this could be more sophisticated - could use the SCRIBE definition of selected objects,
    %which would allow us to find things like titles and labels
    editH = get(myFig,'currentobject');
    currObjType = get(editH,'type');
    if ~isempty(currObjType) & ...
        ischar(currObjType) & ...
        strcmp(currObjType,aObj)
        %the current object is the one we want
    else
	    editH=findobj(myFig,'type',aObj);
    end
 	errMsg = sprintf('Error - no "%s" objects in current figure',aObj);
elseif isnumeric(aObj)
	editH=aObj(find(ishandle(aObj)));
    errMsg = sprintf('Error - no valid handle');
else
    editH=[];
    errMsg = sprintf('Error - can only edit based on handles or object type');
end

if isempty(editH)
	errordlg(errMsg,'Property Editor Error','modal');
    return;
else
    editH=editH(1);
end

if ~plotedit(myFig,'isactive')
	plotedit(myFig,'on');
end

propedit(editH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LUpdateToolsMenu(myFig)

toolsMenuItems = allchild(findobj(allchild(myFig),'flat','Type','uimenu','Tag','figMenuTools'));

offon = {'off' 'on'};

%Mutually exclusive groups - set checked -------------------
ploteditActive = plotedit(myFig,'isactive');
set(findall(toolsMenuItems,'Tag','figMenuToolsPlotedit'),'Checked',offon{ploteditActive+1});

zoomInActive=0;
zoomOutActive=0;
switch zoom(myFig,'getmode')
case {'in','on'}
    zoomInActive=1;
case 'out'
    zoomOutActive=1;
end
set(findall(toolsMenuItems,'Tag','figMenuZoomIn'), 'Checked',offon{zoomInActive+1} );
set(findall(toolsMenuItems,'Tag','figMenuZoomOut'),'Checked',offon{zoomOutActive+1});

isRotate3dActive=~isempty(findall(myFig,'type','axes','Tag','rotaObj'));
set(findall(toolsMenuItems,'Tag','figMenuRotate3D'), 'Checked',offon{isRotate3dActive+1} );

isCameraActive = ~isempty(cameratoolbar('getmode'));
set(findall(toolsMenuItems,'Tag','figMenuMoveCamera'), 'Checked',offon{isCameraActive+1} );

% determine whether or not to enable Basic Fitting and Data Statistics
% enable them as long as there is a least one line without any zdata
% and the HandleVisibility for the Figure is 'on' (not 'off' or 'callback').

handlevis = isequal(get(myFig,'HandleVisibility'),'on');

is2d = 0;

% The separate residual plot should never have BasicFitting and DataStats enabled
if isempty(findprop(handle(myFig),'Basic_Fit_Resid_Figure'))
	axesList = findobj(myFig, 'type', 'axes');
	if ~isempty(axesList)
		
		taglines = get(axesList,'tag');
		notlegendind = ~(strcmp('legend',taglines));

		% use findobj instead of findall (we don't want plottool lines)
		lines = findobj(axesList(notlegendind),'type','line');

		for i = 1:length(lines)
			if isempty(get(lines(i), 'zdata'))
			   	is2d = 1;
			   	break;
			end
		end
	end
end

set(findall(toolsMenuItems,'Tag','figMenuToolsBFDS'), 'Enable', offon{( is2d & handlevis ) +1} );

if ~usejava('MWT')   % hide java dependent items if java is not supported 
	set(findall(toolsMenuItems,'Tag','figMenuToolsBFDS'), 'Visible', 'off' );
end
	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LUpdateViewMenu(myFig)

offon = {'off','on'};

viewMenuItems = allchild(findobj(allchild(myFig),'flat',...
    'Type','uimenu','Tag','figMenuView'));

tagList={
    'FigureToolBar',    'figMenuFigureToolbar'
    'CameraToolBar',    'figMenuCameraToolbar'
};

toolbarHandles=findall(myFig,'type','uitoolbar');

for i=1:size(tagList,1)
    toolbarShowing = ~isempty(findall(toolbarHandles,...
        'tag',tagList{i,1},...
        'Visible','on'));
    menuHandle = findall(viewMenuItems,...
        'Type','uimenu',...
        'Tag',tagList{i,2});
    if ~isempty(menuHandle)
        set(menuHandle,...
            'Checked',offon{toolbarShowing+1});
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%
function LUpdateInsertMenu(myFig);

insertMenuItems = allchild(findobj(allchild(myFig),'flat','Type','uimenu','Tag','figMenuInsert'));

zLabelEnable='off';
if isempty(findobj(myFig,'type','axes'));
    menuEnable='off';
else
    menuEnable='on';
    if ~isequal(get(get(myFig,'currentaxes'),'View'),[0 90])
        zLabelEnable='on';
    end
end

eMenus=[findobj(insertMenuItems,'tag','figMenuInsertYLabel')
    findobj(insertMenuItems,'tag','figMenuInsertXLabel')
    findobj(insertMenuItems,'tag','figMenuInsertTitle')
    findobj(insertMenuItems,'tag','figMenuInsertLegend')
    findobj(insertMenuItems,'tag','figMenuInsertColorbar')
    findobj(insertMenuItems,'tag','figMenuInsertYAxis')
    findobj(insertMenuItems,'tag','figMenuInsertLight')];

set(eMenus,'Enable',menuEnable);


set(findobj(insertMenuItems,'tag','figMenuInsertZLabel'),...
    'Enable',zLabelEnable);


%%%%%%%%%%%%%%%%%%%%%%%
function ObsoleteUpdateLegendCode

selection = LGetSelection(myFig);

% pull out axis objects in the selection
axisObjects = [];
if ~isempty(selection)
    for a = selection
        if strcmp(class(a),'axisobj')
            axisObjects = [axisObjects a];
        end
    end
end

% Show Legend
mShowLegend = findall(gcbo,'Tag','figMenuToolsShowLegend');
ax = get(myFig,'CurrentAxes');
if ploteditActive
    axLegendOn = [];
    for a = axisObjects
        % find the axes and see if they're locked.
        axLegendOn(end+1) = islegendon(get(a,'MyHGHandle'));
    end
    
    if isempty(axLegendOn) & isempty(ax)
        % disable only if the selection includes no axes AND
        % there is no current axis
        mShowLegendEnable = 'off';
    else
        mShowLegendEnable = 'on';
    end
    
    if isempty(axisObjects)
        % no axes are part of the selection
        % look at the current axis.
        if isempty(ax)
            axLegendOn = 0;  % force a "Show Legend"
        else
            axLegendOn = islegendon(ax);
        end
    end
    
    % axes are selected
    if length(find(axLegendOn)) > length(axLegendOn)/2
        % over half are showing legends
        mShowLegendLabel = 'Hide Le&gend';
    else
        mShowLegendLabel = 'Show Le&gend';
    end
    
else
    if ~isempty(mShowLegend)
        if ~isempty(ax)
            if islegendon(ax)
                mShowLegendLabel = 'Hide Le&gend';
            else
                mShowLegendLabel = 'Show Le&gend';
            end
            mShowLegendEnable = 'on';            
            % set(mShowLegend,'Checked',check{islegendon(ax)+1});
        else
            mShowLegendLabel = 'Show Le&gend';
            mShowLegendEnable = 'off';
            % set(mShowLegend,'Checked',check{0+1})
        end
    end
end
set(mShowLegend, ...
    'Enable', mShowLegendEnable,...
    'Label', mShowLegendLabel)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ObsoleteUnlockAxesCode

% Lock Axes Position/Unlock Axes Position
mLockAxes = findall(gcbo,'Tag','figMenuToolsLockAxes');
if ploteditActive
    axLock = [];
    for a = axisObjects
        % find the axes and see if they're locked.
        axLock(end+1) = get(a,'Draggable');
    end
    if isempty(axLock)
        mLockAxesEnable = 'off';
        mLockAxesLabel = 'Unloc&k Axes Position';
    else
        mLockAxesEnable = 'on';
        if length(find(axLock)) > length(axLock)/2
            % over half are draggable
            mLockAxesLabel = 'Loc&k Axes Position';
        else
            mLockAxesLabel = 'Unloc&k Axes Position';
        end
    end
else
    mLockAxesEnable = 'off';
    mLockAxesLabel = 'Unloc&k Axes Position';
end
set(mLockAxes,...
    'Label',mLockAxesLabel,...
    'Enable',mLockAxesEnable);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h=LocSelectionHandles(myFig)
%Returns the current SCRIBE selection as HG handles

h=[];
if plotedit(myFig,'isactive')
    selection=get(getobj(myFig),'Selection');
    if ~isempty(selection)
        h=[selection(:).HGHandle];
        if iscell(h)
            h=[h{:}];
        end
    end
end