function toolsmenufcn(hfig, cmd)
%TOOLSMENUFCN Implements part of the figure tools menu.
%  TOOLSMENUFCN(CMD) invokes tools menu command CMD on figure GCBF.
%  TOOLSMENUFCN(H, CMD) invokes tools menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    PlotEdit
%    ZoomIn
%    ZoomOut
%    Rotate
%    ToggleCamera
%    CameraModeOrbit
%    CameraModeOrbitSceneLight
%    CameraModePan
%    CameraModeDollyHV
%    CameraModeDollyFB
%    CameraModeZoom
%    CameraModeRoll
%    CameraModeWalk
%    CameraCoordX
%    CameraCoordY
%    CameraCoordZ
%    CameraCoordNone
%    CameraResetCameraAndSceneLight
%    CameraResetTarget
%    CameraResetSceneLight
%    AlignLeft
%    AlignCenter
%    AlignRight
%    AlignTop
%    AlignMiddle
%    AlignBottom
%    DistributeVAdj
%    DistributeVTop
%    DistributeVMid
%    DistributeVBot
%    DistributeHAdj
%    DistributeHLeft
%    DistributeHCent
%    DistributeHRight
%    AlignDistributeSmart
%    AlignDistributeTool
%    BasicFitting
%    DataStatistics

%  CMD Values For Internal Use Only:
%    ToolsPost
%    InitCameraMotionMode
%    InitCameraPrincipalAxis
%    InitAlignDistribute

%  Copyright 1984-2002 The MathWorks, Inc. 

error(nargchk(1,2,nargin))

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

% DELETE THESE OLD MENU ENTRIES FROM FIGTOOLS.M ONCE TESTED
%  '&Tools',              'figMenuTools',           'domymenu menubar inittoolsmenu',
%   '>&Edit Plot',         'figMenuToolsPlotedit',   'plotedit(gcbf)',
%   '>&Zoom In',           'figMenuZoomIn',          'domymenu menubar zoomin',
%   '>Zoom &Out',          'figMenuZoomOut',         'domymenu menubar zoomout',
%   '>&Rotate 3D',         'figMenuRotate3D',        'domymenu menubar rotate3d',
%   '>Move &Camera',       'figMenuMoveCamera',      'domymenu menubar togglecamera',
%   '>Camera &Motion',     'figMenuCameraMotionMode','domymenu menubar initcameramotionmode',
%   '>>&Orbit Camera',     'figMenuMode_orbit',      'cameratoolbar setmodegui orbit',
%   '>>Orbit Scene &Light','figMenuMode_orbitscenelight', 'cameratoolbar setmodegui orbitscenelight',
%   '>>&Pan - Turn/Tilt',  'figMenuMode_pan',        'cameratoolbar setmodegui pan',
%   '>>Move - &Horizontally/Vertically', 'figMenuMode_dollyhv',   'cameratoolbar setmodegui dollyhv',
%   '>>Move - &Forward/Back', 'figMenuMode_dollyfb',   'cameratoolbar setmodegui dollyfb',
%   '>>&Zoom',              'figMenuMode_zoom',      'cameratoolbar setmodegui zoom',
%   '>>&Roll',              'figMenuMode_roll',      'cameratoolbar setmodegui roll',
%   '>>&Walk',              'figMenuMode_walk',      'cameratoolbar setmodegui walk',
%   '>Camera A&xis',        'figMenuCameraPAx',      'domymenu menubar initcameraprincipalaxis',
%   '>>&X Principal Axis',  'figMenuAxis_x',         'cameratoolbar setcoordsys x',
%   '>>&Y Principal Axis',  'figMenuAxis_y',         'cameratoolbar setcoordsys y',
%   '>>&Z Principal Axis',  'figMenuAxis_z',         'cameratoolbar setcoordsys z',
%   '>>&No Principal Axis', 'figMenuAxis_none',      'cameratoolbar setcoordsys none',
%   '>>Reset &Camera && Scene Light',  '',      'cameratoolbar(''resetcameraandscenelight'');',
%   '>>Reset &Target Point','',                      'cameratoolbar(''resettarget'')',
%   '>>Reset &Scene Light', '',                      'cameratoolbar(''resetscenelight'');',
%   '>Ali&gn/Distribute',   'figMenuToolsAlign',     '',
%   '>>Align Left Edges',   '',                      'scribealign(gcbf,''Left'')',
%   '>>Align Centers (X)',  '',                      'scribealign(gcbf,''Center'')',
%   '>>Align Right Edges',  '',                      'scribealign(gcbf,''Right'')',
%   '>>Align Top Edges',    '',                      'scribealign(gcbf,''Top'')',
%   '>>Align Middles (Y)',  '',                      'scribealign(gcbf,''Middle'')',
%   '>>Align Bottom Edges', '',                      'scribealign(gcbf,''Bottom'')',
%   '>>Distribute Vertical Adjacent Edges', '',      'scribealign(gcbf,''VDistAdj'')',
%   '>>Distribute Vertical Top Edges', '',           'scribealign(gcbf,''VDistTop'')',
%   '>>Distribute Vertical Middles',  '',            'scribealign(gcbf,''VDistMid'')',
%   '>>Distribute Vertical Bottom Edges',  '',       'scribealign(gcbf,''VDistBot'')',
%   '>>Distribute Horizontal Adjacent Edges',  '',   'scribealign(gcbf,''HDistAdj'')',
%   '>>Distribute Horizontal Left Edges',    '',     'scribealign(gcbf,''HDistLeft'')',
%   '>>Distribute Horizontal Centers',   '',         'scribealign(gcbf,''HDistCent'')',
%   '>>Distribute Horizontal Right Edges',   '',     'scribealign(gcbf,''HDistRight'')',
%   '>>Smart Align and Distribute',   '',            'scribealign(gcbf,''Smart'')',
%   '>&Basic Fitting',      'figMenuToolsBFDS',      'basicfitdatastat(''bfit'', gcbf, ''bf'');',
%   '>&Data Statistics',    'figMenuToolsBFDS',      'basicfitdatastat(''bfit'', gcbf, ''ds'');',

switch cmd
case 'ToolsPost'
    LUpdateToolsMenu(hfig);
case 'PlotEdit'
    plotedit(hfig)
case 'ZoomIn'
    if strcmp(zoom(hfig,'getmode'),'in') % strcmp(get(gcbo,'checked'),'on')
        zoom(hfig,'off');
    else
        zoom(hfig,'inmode');
    end
case 'ZoomOut'    
    if strcmp(zoom(hfig,'getmode'),'out') % strcmp(get(gcbo,'checked'),'on')
        zoom(hfig,'off');
    else
        zoom(hfig,'outmode');        
    end
case 'Pan'
    pan(hfig); % toggle
case 'Rotate'
    rotate3d(hfig); % toggle
case 'Datatip'
    datacursormode(hfig); % toggle
case 'Options'
    localUpdateOptions(hfig);
case 'ZoomX'
    localUpdateOptions(hfig,'ZoomX');
case 'ZoomY'
    localUpdateOptions(hfig,'ZoomY');
case 'ZoomXY'
    localUpdateOptions(hfig,'ZoomXY');
case 'PanX'
    localUpdateOptions(hfig,'PanX');
case 'PanY'
    localUpdateOptions(hfig,'PanY');
case 'PanXY'
    localUpdateOptions(hfig,'PanXY');
case 'RotateCont'
    localUpdateOptions(hfig,'RotateCont');
case 'RotateBox'
    localUpdateOptions(hfig,'RotateBox');
case 'DatatipStyle'
    localUpdateOptions(hfig,'DatatipStyle');
case 'DataBarStyle'
    localUpdateOptions(hfig,'DataBarStyle');
case 'ResetView'
    localResetView(hfig);    
case 'EditPinning'
    startscribepinning(hfig,'on')
% case 'ToggleCamera'
%     domymenu menubar togglecamera
% case 'InitCameraMotionMode'
%     modeParent=findall(hfig,'type','uimenu','tag','figMenuCameraMotionMode');
%     modeItems=allchild(modeParent);
%     set(modeItems,'checked','off');
%     currMode=cameratoolbar('getmode');
%     activeItem=findall(modeItems,'tag',['figMenuMode_' currMode]);
%     set(activeItem,'Checked','on');
% case 'CameraModeOrbit'
%     cameratoolbar setmodegui orbit
% case 'CameraModeOrbitSceneLight'
%     cameratoolbar setmodegui orbitscenelight
% case 'CameraModePan'
%     cameratoolbar setmodegui pan
% case 'CameraModeDollyHV'
%     cameratoolbar setmodegui dollyhv
% case 'CameraModeDollyFB'
%     cameratoolbar setmodegui dollyfb
% case 'CameraModeZoom'
%     cameratoolbar setmodegui zoom
% case 'CameraModeRoll'
%     cameratoolbar setmodegui roll
% case 'CameraModeWalk'
%     cameratoolbar setmodegui walk
% case 'InitCameraPrincipalAxis'
%     paxParent=findall(hfig,'type','uimenu','tag','figMenuCameraPAx');
%     paxItems=allchild(paxParent);
%     offon={'off','on'};
%     isActive=ismember(cameratoolbar('getmode'), {'orbit' 'pan' 'walk'});
%     set(paxItems,'checked','off','enable',offon{isActive+1});
%     if isActive
% 		currPAx=cameratoolbar('getcoordsys');
%         activeItem=findall(paxItems,'tag',['figMenuAxis_' currPAx]);
%         set(activeItem,'Checked','on');
%     end
% case 'CameraCoordX'
%     cameratoolbar setcoordsys x
% case 'CameraCoordY'
%     cameratoolbar setcoordsys y
% case 'CameraCoordZ'
%     cameratoolbar setcoordsys z
% case 'CameraCoordNone'
%     cameratoolbar setcoordsys none
% case 'CameraResetCameraAndSceneLight'
%     cameratoolbar resetcameraandscenelight
% case 'CameraResetTarget'
%     cameratoolbar resettarget
% case 'CameraResetSceneLight'
%     cameratoolbar resetscenelight
case 'InitAlignDistribute' 
    % scribealign(hfig,'Init');
case 'AlignLeft'
    scribealign(hfig,'Left');
case 'AlignCenter'
    scribealign(hfig,'Center');
case 'AlignRight'
    scribealign(hfig,'Right');
case 'AlignTop'
    scribealign(hfig,'Top');
case 'AlignMiddle'
    scribealign(hfig,'Middle');
case 'AlignBottom'
    scribealign(hfig,'Bottom');
case 'DistributeVAdj'
    scribealign(hfig,'VDistAdj');
case 'DistributeVTop'
    scribealign(hfig,'VDistTop');
case 'DistributeVMid'
    scribealign(hfig,'VDistMid');
case 'DistributeVBot'
    scribealign(hfig,'VDistBot');
case 'DistributeHAdj'
    scribealign(hfig,'HDistAdj');
case 'DistributeHLeft'
    scribealign(hfig,'HDistLeft');
case 'DistributeHCent'
    scribealign(hfig,'HDistCent');
case 'DistributeHRight'
    scribealign(hfig,'HDistRight');
case 'AlignDistributeSmart'
    scribealign(hfig,'Smart');
case 'AlignDistributeTool'
    scribealign(hfig);
case 'BasicFitting'
    basicfitdatastat('bfit', hfig, 'bf');
case 'DataStatistics'
    basicfitdatastat('bfit', hfig, 'ds');
case 'ToggleSnapToGrid'
    snaptogrid(gcbf,'togglesnap');
case 'ToggleViewGrid'
    snaptogrid(gcbf,'toggleview');
end

%-----------------------------------------------------------------------%
function LUpdateToolsMenu(fig)

toolsMenuItems = allchild(findobj(allchild(fig),'flat','Type','uimenu','Tag','figMenuTools'));

offon = {'off' 'on'};

%Mutually exclusive groups - set checked -------------------
ploteditActive = plotedit(fig,'isactive');
set(findall(toolsMenuItems,'Tag','figMenuToolsPlotedit'),'Checked',offon{ploteditActive+1});

zoomInActive=0;
zoomOutActive=0;
switch zoom(fig,'getmode')
case {'in','on'}
    zoomInActive=1;
case 'out'
    zoomOutActive=1;
end
set(findall(toolsMenuItems,'Tag','figMenuZoomIn'), 'Checked',offon{zoomInActive+1} );
set(findall(toolsMenuItems,'Tag','figMenuZoomOut'),'Checked',offon{zoomOutActive+1});

isRotate3dActive=~isempty(findall(fig,'type','axes','Tag','MATLAB_Rotate3D_Axes'));
set(findall(toolsMenuItems,'Tag','figMenuRotate3D'), 'Checked',offon{isRotate3dActive+1} );

isCameraActive = ~isempty(cameratoolbar('getmode'));
set(findall(toolsMenuItems,'Tag','figMenuMoveCamera'), 'Checked',offon{isCameraActive+1} );

% determine whether or not to enable Basic Fitting and Data Statistics
% enable them as long as there is a least one line without any zdata
% and the HandleVisibility for the Figure is 'on' (not 'off' or 'callback').

handlevis = isequal(get(fig,'HandleVisibility'),'on');

is2d = 0;

% The separate residual plot should never have BasicFitting and DataStats enabled
if isempty(findprop(handle(fig),'Basic_Fit_Resid_Figure'))
	axesList = findobj(fig, 'type', 'axes');
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

%----------------------------------------------%
function localUpdateOptions(hfig,option)

if nargin==1
   pan_style = pan(hfig,'getstyle');
   localUpdatePanMenu(hfig,pan_style);

   zoom_style = zoom(hfig,'Constraint');
   localUpdateZoomMenu(hfig,zoom_style);

   hTool = datacursormode(hfig);
   datacursor_style = get(hTool,'DisplayStyle');
   localUpdateDataCursorMenu(hfig,datacursor_style);
   
else
   switch(option)
         case 'ZoomX'
             localUpdateZoomMenu(hfig,'Horizontal');
         case 'ZoomY'
             localUpdateZoomMenu(hfig,'Vertical');
         case 'ZoomXY'
             localUpdateZoomMenu(hfig,'None');
         case 'PanX'
             localUpdatePanMenu(hfig,'x');
         case 'PanY'
             localUpdatePanMenu(hfig,'y');
         case 'PanXY'
             localUpdatePanMenu(hfig,'xy');
         case 'DatatipStyle'
             localUpdateDataCursorMenu(hfig,'datatip');
         case 'DataBarStyle'
             localUpdateDataCursorMenu(hfig,'window');
   end % switch  
end 

%----------------------------------------------%
function localUpdateDataCursorMenu(hfig,option)

datatip_menu = findall(hfig,'Tag','figMenuOptionsDatatip');
databar_menu = findall(hfig,'Tag','figMenuOptionsDataBar');

% Update tool
hTool = datacursormode(hfig);
set(hTool,'DisplayStyle',option);

% Update menu
switch(option)
   case 'datatip'
       set(datatip_menu,'Checked','On');
       set(databar_menu,'Checked','Off');
   case 'window'
       set(datatip_menu,'Checked','Off');
       set(databar_menu,'Checked','On');
end

%----------------------------------------------%
function localUpdatePanMenu(hfig,option)

xpan_menu = findall(hfig,'Tag','figMenuOptionsXPan');
ypan_menu = findall(hfig,'Tag','figMenuOptionsYPan');
xypan_menu = findall(hfig,'Tag','figMenuOptionsXYPan');

% Update pan
pan(hfig,option);

% Update menu
switch(option)
   case 'x'
      set(xpan_menu,'Checked','on');
      set(ypan_menu,'Checked','off');
      set(xypan_menu,'Checked','off');
   case 'y'
      set(xpan_menu,'Checked','off');
      set(ypan_menu,'Checked','on');
      set(xypan_menu,'Checked','off');
   case 'xy'
      set(xpan_menu,'Checked','off');
      set(ypan_menu,'Checked','off');
      set(xypan_menu,'Checked','on');
end

%----------------------------------------------%
function localUpdateZoomMenu(hfig,constraint)

% Get menu handles
xzoom_menu = findall(hfig,'Tag','figMenuOptionsXZoom');
yzoom_menu = findall(hfig,'Tag','figMenuOptionsYZoom');
xyzoom_menu = findall(hfig,'Tag','figMenuOptionsXYZoom');

% Update zoom
zoom(hfig,'Constraint',constraint);

% Update menus
switch(constraint)
   case 'horizontal'
      set(xzoom_menu,'Checked','on');
      set(yzoom_menu,'Checked','off');
      set(xyzoom_menu,'Checked','off');
   case 'vertical'
      set(xzoom_menu,'Checked','off');
      set(yzoom_menu,'Checked','on');
      set(xyzoom_menu,'Checked','off');
   case 'none'
      set(xzoom_menu,'Checked','off');
      set(yzoom_menu,'Checked','off');
      set(xyzoom_menu,'Checked','on');
end

%----------------------------------------------%
function localResetView(hfig)

hax = get(hfig,'CurrentAxes');
resetplotview(hax,'ApplyStoredView');

