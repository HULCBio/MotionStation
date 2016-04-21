function pdetool(action,flag)
%PDETOOL PDE Toolbox graphical user interface (GUI).
%   PDETOOL provides the graphical user interface for the
%   PDE Toolbox.
%
%   Call PDETOOL without arguments to start application.

%   Magnus Ringh 6-01-94, MR 10-03-95.
%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.4 $  $Date: 2003/11/24 23:24:15 $

if nargin<1
  action='initialize';
end

pde_fig=findobj(allchild(0),'flat','Tag','PDETool');

%
% case: initialize

if strcmp(action,'initialize')

  if ~isempty(pde_fig),
    set(0,'CurrentFigure',pde_fig);
    Figpos = get(pde_fig,'Position');
    set(pde_fig,...
	'Colormap',gray(20),...
	'HandleVisibility','on')
    % clf:
    delete(allchild(pde_fig))
    refresh(pde_fig)
  else
    ScreenUnits = get(0,'Units');
    set(0,'Unit','pixels');
    ScreenPos = get(0,'ScreenSize');
    set(0,'Unit',ScreenUnits);
    Figpos=[.15 .15 .8 .75].*ScreenPos+[0.1*ScreenPos(3:4) 0 0];
    pde_fig=figure(...
        'Visible','off',...
        'Color','w',...
        'Colormap',gray(20),...
        'Position',Figpos,...
        'IntegerHandle','off',...
        'Renderer','painters',...
        'Interruptible','on','CloseRequestFcn','pdetool(''exit'')');
  end

  % Set the pointer to a watch:
  set(pde_fig,'Pointer','watch')
  drawnow

  % Set up some default values:

  % flags=[save_flag mode_flag flag1 flag2 flag3 flag4 flag5]
  % save_flag: model needs to be saved.
  % mode_flag: 0=draw mode; 1=boundary mode; 2=mesh mode;
  % 3=solve mode; 4=pde mode
  % flag1=Geometry has changed, decomposition needed (flag1=-1 if decsg error)
  % flag2=Decomposed geometry has changed, mesh initialization needed
  % flag3=Mesh or boundary condition has changed, need to solve system
  % flag4=New solution computed
  % flag5=PDE equation has changed; recompute solution if necessary
  %
  % Storage: File menu's UserData
  flags=zeros(7,1);

  % PDE coefficients:
  c='1.0'; a='0.0'; f='10.0'; d='1.0'; tlist='0:10'; u0='0.0';...
  ut0='0.0'; r='[0 100]'; rtol='0.01'; atol='0.001';
  params=str2mat(c,a,f,d);
  setappdata(pde_fig,'currparam',str2mat(c,a,f,d))
  setappdata(pde_fig,'timeeigparam',str2mat(tlist,u0,ut0,r,rtol,atol))
  setappdata(pde_fig,'ncafd',ones(1,4))
  % Default solve parameters:
  % Adaptive mode: 0 (=off)
  % Max number of triangles: 1000
  % Max number of refinements: 10
  % Triangle selection method: 'pdeadworst'
  % Function parameter: 0.5
  % Local tolerance: 1E-3
  % Triangle refinement method - adaption: 'longest'
  % Nonlinear solver: 0 (=off)
  % Nonlinear tolerance: 1.0
  % Initial solution for nonlinear solver: none (optional argument)
  % Jacobian: fixed
  % Nonlinear norm: Inf
  solveparams=str2mat('0','1000','10','pdeadworst','0.5','longest',...
  '0','1E-4','','fixed','Inf');
  setappdata(pde_fig,'solveparam',solveparams)


  %
  % Initialize main PDE figure window and axes:
  set(pde_fig,...
        'Tag','PDETool',...
        'NumberTitle','off',...
        'Name','PDE Toolbox - [Untitled]',...
        'Resize','on',...
        'MenuBar','none',...
        'Visible','on',...
        'KeyPressFcn','pdetool keycall',...
        'Units','pixels')

  axwidth = 0.8*Figpos(3);
  axheight= axwidth/1.5/Figpos(4);
  axstdpos = [0.1 0.12 0.8 axheight];
  ax=axes(...
        'Parent',pde_fig,...
        'Position',axstdpos,...
        'XColor','k',...
        'Box','on',...
        'YColor','k',...
        'Color','w',...
        'DrawMode','fast',...
        'Tag','PDEAxes',...
        'XLimMode','manual',...
        'YLimMode','manual',...
        'XLim',[-1.5 1.5],...
        'YLim',[-1 1],...
        'XGrid','off',...
        'YGrid','off',...
        'ZGrid','off',...
        'XTickMode','auto',...
        'YTickMode','auto',...
        'Units','normalized',...
        'DataAspectRatio',[1 1 1]);

  % Save axes position:
  setappdata(ax,'axstdpos',axstdpos)

  % Save draw mode color map (gray) and solve mode default colormap (cool)
  set(get(ax,'XLabel'),'UserData',gray(20))
  set(get(ax,'YLabel'),'UserData',cool(64))

  % Initialize user interface menus and ui controls (buttons etc.)
  % File menu:
  [lbl,acc]=menulabel('&File');
  file_menu = uimenu(pde_fig,'Accelerator',acc,'Label',lbl,...
      'Tag','PDEFileMenu','UserData',flags);
  [lbl,acc]=menulabel('&New ^n');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,...
      'Interruptible','on','CallBack','pdetool(''new'')');
  [lbl,acc]=menulabel('&Open... ^o');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,...
      'Interruptible','on','CallBack','pdetool(''open'')');
  [lbl,acc]=menulabel('&Save ^s');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,...
      'Tag','PDESave','Enable','off','CallBack','pdetool(''save'')');
  [lbl,acc]=menulabel('Save &As...');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,...
      'CallBack','pdetool(''save_as''),');
  [lbl,acc]=menulabel('&Print...');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,'Separator','on',...
      'CallBack','pdetool(''print'')');
  [lbl,acc]=menulabel('E&xit ^w');
  uimenu(file_menu,'Accelerator',acc,'Label',lbl,...
      'Interruptible','on', 'Separator','on','CallBack','pdetool(''exit'')');

  % Edit menu:
  [lbl,acc]=menulabel('&Edit');
  edit_menu = uimenu(pde_fig,'Accelerator',acc,'Label',lbl,...
      'Tag','PDEEditMenu','UserData',[]);

  [lbl,acc]=menulabel('&Undo ^z');
  uimenu(edit_menu,'Accelerator',acc,'Label',lbl,'Enable','off',...
      'Tag','PDEUndo','CallBack','pdetool(''undo'')');
  [lbl,acc]=menulabel('Cu&t ^x');
  uimenu(edit_menu,'Accelerator',acc,'Label',lbl,'Separator','on',...
      'Tag','PDECut','CallBack','pdetool(''cut'',1)');
  [lbl,acc]=menulabel('&Copy ^c');
  uimenu(edit_menu,'Accelerator',acc,'Label',lbl,'Tag','PDECopy',...
      'CallBack','pdetool(''cut'',2)');
  [lbl,acc]=menulabel('&Paste... ^v');
  uimenu(edit_menu,'Accelerator',acc,'Label',lbl,'Enable','off',...
      'Tag','PDEPaste','CallBack','pdepsdlg');
  [lbl,acc]=menulabel('Clea&r ^r');
  uimenu(edit_menu,'Accelerator',acc,'Label',lbl,'Enable','off',...
      'Separator','on','Tag','PDEClear','CallBack','pdetool(''clear'')');
  [lbl,acc]=menulabel('Select &All ^a');
  uimenu(edit_menu,'Label',lbl,'Accelerator',acc,'Separator','on',...
      'Tag','PDESelall','CallBack','pdeselect(''select'',1)');

  % Options menu:
  [lbl,acc]=menulabel('&Options');
  opt_menu = uimenu(pde_fig,'Accelerator',acc,'Label',lbl,...
      'Tag','PDEOptMenu');
  [lbl,acc]=menulabel('&Grid');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEGrid',...
      'CallBack','pdetool gridon');
  [lbl,acc]=menulabel('Gr&id Spacing...');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDESpace',...
      'CallBack','pdetool spacing');
  [lbl,acc]=menulabel('&Snap');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDESnap',...
      'CallBack','pdetool(''snapon'')');
  [lbl,acc]=menulabel('&Axes Limits...');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEAxMenu',...
      'Separator','on','CallBack','pdetool axlim');
  [lbl,acc]=menulabel('Axes &Equal');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEAxeq',...
      'CallBack','pdetool axeq');
  [lbl,acc]=menulabel('&Turn off Toolbar Help');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEHelpoff',...
      'Separator','on','CallBack','pdetool helponoff');
  [lbl,acc]=menulabel('&Zoom');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEZoom',...
      'Separator','on','CallBack','pdetool zoom');
  [lbl,acc]=menulabel('A&pplication');
  appl_menu=uimenu(opt_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEAppMenu','Separator','on');
  uimenu(appl_menu,'Label','Generic Scalar','Checked','on',...
      'CallBack','pdetool(''appl_cb'',1)','UserData',1);
  uimenu(appl_menu,'Label','Generic System',...
      'CallBack','pdetool(''appl_cb'',2)','UserData',2);
  uimenu(appl_menu,'Label','Structural Mechanics, Plane Stress',...
      'CallBack','pdetool(''appl_cb'',3)','UserData',3);
  uimenu(appl_menu,'Label','Structural Mechanics, Plane Strain',...
      'CallBack','pdetool(''appl_cb'',4)','UserData',4);
  uimenu(appl_menu,'Label','Electrostatics',...
      'CallBack','pdetool(''appl_cb'',5)','UserData',5);
  uimenu(appl_menu,'Label','Magnetostatics',...
      'CallBack','pdetool(''appl_cb'',6)','UserData',6);
  uimenu(appl_menu,'Label','AC Power Electromagnetics',...
      'CallBack','pdetool(''appl_cb'',7)','UserData',7);
  uimenu(appl_menu,'Label','Conductive Media DC',...
      'CallBack','pdetool(''appl_cb'',8)','UserData',8);
  uimenu(appl_menu,'Label','Heat Transfer',...
      'CallBack','pdetool(''appl_cb'',9)','UserData',9);
  uimenu(appl_menu,'Label','Diffusion',...
      'CallBack','pdetool(''appl_cb'',10)','UserData',10);
  [lbl,acc]=menulabel('&Refresh');
  uimenu(opt_menu,'Label',lbl,'Accelerator',acc,'Tag','PDERefresh',...
      'Separator','on','CallBack','pdetool refresh');

  % Draw menu:
  [lbl,acc]=menulabel('D&raw');
  draw_menu = uimenu(pde_fig,'Accelerator',acc,'Label',lbl,...
      'Tag','PDEDrawMenu');

  [lbl,acc]=menulabel('&Draw Mode');
  uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEDrawMode','Interruptible','on',...
      'CallBack','pdetool(''changemode'',1)');
  [lbl,acc]=menulabel('&Rectangle/square');
  draw_hndl(1)=uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDERect','Interruptible','on',...
      'CallBack','pdetool(''drawrect'',1)');
  [lbl,acc]=menulabel('Rectangle/&square (centered)');
  draw_hndl(2)=uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDERectc','Interruptible','on',...
      'CallBack','pdetool(''drawrect'',2)');
  [lbl,acc]=menulabel('&Ellipse/circle');
  draw_hndl(3)=uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEEllip','Interruptible','on',...
      'CallBack','pdetool(''drawellipse'',1)');
  [lbl,acc]=menulabel('Ellipse/&circle (centered)');
  draw_hndl(4)=uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEEllipc','Interruptible','on',...
      'CallBack','pdetool(''drawellipse'',2)');
  [lbl,acc]=menulabel('&Polygon');
  draw_hndl(5)=uimenu(draw_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEPoly','Interruptible','on',...
      'CallBack','pdetool drawline');

  [lbl,acc]=menulabel('R&otate...');
  uimenu(draw_menu,'Label',lbl,'Accelerator',acc,'Separator','on',...
      'Tag','PDERotate','CallBack','pdertdlg');

  set(draw_menu,'UserData',draw_hndl);

  [lbl,acc]=menulabel('E&xport Geometry Description, Set Formula, Labels...');
  uimenu(draw_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEExpGD',...
      'Separator','on','CallBack','pdetool(''export'',1)','Enable','off');

  % Boundary menu:
  [lbl,acc]=menulabel('&Boundary');
  bound_menu=uimenu(pde_fig,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEBoundMenu');
  [lbl,acc]=menulabel('&Boundary Mode ^b');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEBoundMode','CallBack','pdetool(''boundmode'')');
  [lbl,acc]=menulabel('&Specify Boundary Conditions...');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEBoundSpec','CallBack',...
      ['h=get(findobj(get(gcf,''Children''),''flat'',''Tag'','...
          '''PDEBoundMenu''),''UserData''); if isempty(h),'...
          ' pdetool(''error'',''  No boundary selected.''), else,'...
          ' pdetool(''set_bounds''), end']);
  [lbl,acc]=menulabel('Show &Edge Labels');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEShowEdge','CallBack','pdetool(''edgelbl'')');
  [lbl,acc]=menulabel('Show S&ubdomain Labels');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEShowSub','CallBack','pdetool(''sublbl'')');
  [lbl,acc]=menulabel('&Remove Subdomain Border');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,'Tag','PDERemBord',...
      'Enable','off','Separator','on','CallBack','pdetool(''removeb'')');
  [lbl,acc]=menulabel('Re&move All Subdomain Borders');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,'Tag','PDERemAllBord',...
      'Enable','off','CallBack','pdetool(''removeb'',-1)');
  [lbl,acc]=menulabel('E&xport Decomposed Geometry, Boundary Cond''s...');
  uimenu(bound_menu,'Label',lbl,'Accelerator',acc,'Enable','off',...
      'Separator','on','Tag','PDEExpBound','CallBack','pdetool(''export'',2)');

  % PDE menu:
  [lbl,acc]=menulabel('P&DE');
  pde_menu=uimenu(pde_fig,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEPDEMenu','UserData',params);
  [lbl,acc]=menulabel('&PDE Mode');
  uimenu(pde_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEMode',...
      'CallBack','pdetool(''pdemode'')');
  [lbl,acc]=menulabel('&Show Subdomain Labels');
  uimenu(pde_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEShowPDESub',...
      'CallBack','pdetool(''pdesublbl'')');
  [lbl,acc]=menulabel('P&DE Specification...');
  uimenu(pde_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEParam',...
      'CallBack','pdetool(''set_param'')');
  [lbl,acc]=menulabel('E&xport PDE Coefficients...');
  uimenu(pde_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEExpParam',...
      'Separator','on','CallBack','pdetool(''export'',4)');

  % Mesh menu:
  [lbl,acc]=menulabel('&Mesh');
  mesh_menu=uimenu(pde_fig,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEMeshMenu');
  [lbl,acc]=menulabel('&Mesh Mode');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEMeshMenu',...
      'CallBack','pdetool(''meshmode'')');
  [lbl,acc]=menulabel('&Initialize Mesh ^i');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEInitMesh',...
      'CallBack','pdetool(''initmesh'')');
  [lbl,acc]=menulabel('&Refine Mesh ^m');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDERefine',...
      'CallBack','pdetool(''refine'')');
  [lbl,acc]=menulabel('&Jiggle Mesh');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEJiggle',...
      'CallBack','pdetool(''jiggle'')');
  [lbl,acc]=menulabel('&Undo Mesh Change');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEUnrefine',...
      'Enable','off','CallBack','pdetool(''unrefine'')');
  [lbl,acc]=menulabel('&Display Triangle Quality');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDETriQual',...
      'CallBack','pdetool(''triqual'')');
  [lbl,acc]=menulabel('Show &Node Labels');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEShowNode','CallBack','pdetool(''pdenodelbl'')');
  [lbl,acc]=menulabel('Show &Triangle Labels');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEShowTriangles','CallBack','pdetool(''pdetrilbl'')');
  [lbl,acc]=menulabel('&Parameters...');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEMeshParam',...
      'Separator','on','CallBack','pdemhdlg');
  [lbl,acc]=menulabel('E&xport Mesh...');
  uimenu(mesh_menu,'Label',lbl,'Accelerator',acc,'Enable','off',...
      'Separator','on','Tag','PDEExpMesh','CallBack','pdetool(''export'',3)');

  % Solve menu:
  [lbl,acc]=menulabel('&Solve');
  solve_menu=uimenu(pde_fig,'Label',lbl,'Accelerator',acc,...
      'Tag','PDESolveMenu');
  [lbl,acc]=menulabel('&Solve PDE ^e');
  uimenu(solve_menu,'Label',lbl,'Accelerator',acc,'Tag','PDESolve',...
      'CallBack','pdetool(''solve'')');
  [lbl,acc]=menulabel('&Parameters...');
  uimenu(solve_menu,'Label',lbl,'Accelerator',acc,'Separator','on',...
      'CallBack','pdetool(''solve_param'')','Tag','PDESolveParam');
  [lbl,acc]=menulabel('E&xport Solution...');
  uimenu(solve_menu,'Label',lbl,'Accelerator',acc,'Separator','on',...
      'Enable','off','CallBack','pdetool(''export'',5)','Tag','PDEExpSol');

  % Plot menu:
  [lbl,acc]=menulabel('&Plot');
  plot_menu =uimenu(pde_fig,'Label',lbl,'Accelerator',acc,...
      'Tag','PDEPlotMenu');

  [lbl,acc]=menulabel('&Plot Solution ^p');
  uimenu(plot_menu,'Label',lbl,'Accelerator',acc,'Tag','PDEPlot',...
      'CallBack',['pdeptdlg(''initialize'',2),pdeptdlg(''plot''),',...
      'pdeinfo(''PDE solution plotted.'')']);
  uimenu(plot_menu,'Label','Parameters...','Tag','PDEPlotParam',...
      'CallBack','pdeptdlg(''initialize'',0,getappdata(gcf,''plotstrings''))');

  [lbl,acc]=menulabel('E&xport Movie...');
  uimenu(plot_menu,'Label',lbl,'Accelerator',acc,'Separator','on',...
      'Tag','PDEExpMovie','Enable','off','CallBack','pdetool(''export'',6)');

  % Window menu:
  [lbl,acc]=menulabel('&Window');
  uimenu(pde_fig,'Label',lbl,'Accelerator',acc',...
                 'CallBack','winmenu; drawnow',...
                 'Tag','winmenu');

  % Help menu:
    h1 = uimenu(gcf,'Label','&Help','Tag','PDEHelpMenu','UserData',1);
    h2 = uimenu(h1,'Label','PDEtool &Help',...
                           'Callback',' doc pde/pdetool');
    h2 = uimenu(h1,'Label','&PDE Toolbox Help', ...
                           'Callback','doc pde/');
    h2 = uimenu(h1,'Label','&Demos', ...
                           'Separator','on', ...
                           'Callback','demo toolbox partial');
   h2 = uimenu(h1,'Label','&About the PDE Toolbox',...
                           'Separator','on', ...
                       'Callback','pdetool about');
  drawnow;

  %=========================================================
  %Button info and definitions

  % load button icons

  % 1st group of buttons: drawing tools
  iconFcns1 = str2mat('pdeicon(''rect'');', ...
      'pdeicon(''rectc'');', ...
      'pdeicon(''ellip'');', ...
      'pdeicon(''ellipc'');', ...
      'pdeicon(''polygon'');');

  buttonId=str2mat('rect','rectc','ellip','ellipc','poly');
  callBacks=str2mat('pdetool(''drawrect'',1)',...
                    'pdetool(''drawrect'',2)',...
                    'pdetool(''drawellipse'',1)',...
                    'pdetool(''drawellipse'',2)',...
                    'pdetool(''drawline'')');
  btn_grp1=btngroup(pde_fig,'Iconfunctions',iconFcns1,'GroupID','draw',...
      'ButtonID',buttonId,'Callbacks',callBacks,'Groupsize',[1 5],...
      'Position',[0 0.96 .20 .04]);

  % 2nd group of buttons: PDE solution tools
  iconFcns2 = str2mat('pdeicon(''DeltaOmega'');', ...
      'pdeicon(''pde'');', ...
      'pdeicon(''triangle'');', ...
      'pdeicon(''triangle2'');',...
      'pdeicon(''equal'');', ...
      'pdeicon(''plot'');');

  buttonId2=str2mat('bounds','spec','init','refine','solve','plot');
  callBacks2=str2mat('pdetool(''boundmode'')','pdetool(''set_param'')',...
      'pdetool(''initmesh'')','pdetool(''refine'')','pdetool(''solve'')',...
      ['pdeptdlg(''initialize'',0,getappdata(findobj(get(0,''Children''),',...
       '''flat'',''Tag'',''PDETool''),''plotstrings''))']);
  btn_grp2=btngroup(pde_fig,'Iconfunctions',iconFcns2,'GroupID','solve',...
      'ButtonID',buttonId2,'Callbacks',callBacks2,'Groupsize',[1 6],...
      'PressType','flash','Position',[0.20 0.96 .24 .04]);

  zoomicon = str2mat('pdeicon(''zoom'');');
  zoom_btn=btngroup(pde_fig,'Iconfunctions',zoomicon,'GroupID','zoom',...
      'ButtonID','zoom','Callbacks','pdetool(''zoom'')','Groupsize',[1 1],...
      'Position',[0.44 0.96 .04 .04]);

  % Application indicator:
  uicontrol(pde_fig,'Style','frame','Units','normalized',...
      'Position',[0.48 0.96 .28 .04]);
  uicontrol(pde_fig,'Style','popup','Units','normalized',...
      'HorizontalAlignment','left','String',...
      ['Generic Scalar|Generic System|Structural Mech., Plane Stress|',...
          'Structural Mech., Plane Strain|Electrostatics|Magnetostatics|',...
          'AC Power Electromagnetics|Conductive Media DC|',...
          'Heat Transfer|Diffusion'],...
      'Position',[0.485 0.965 .27 .03],'Tag','PDEAppl','UserData',1,...
      'Callback','pdetool(''appl_cb'',0)');

  % X and Y positions:
  uicontrol(pde_fig,'Style','frame','Units','normalized',...
      'Position',[0.76 0.96 .24 .04]);
  uicontrol(pde_fig,'Style','text',...
      'Units','normalized',...
      'Position',[.77 .965 .03 .03],...
      'ForegroundColor','k','String','X:');
  xh=uicontrol(pde_fig,'Style','text','Units','normalized',...
      'HorizontalAlignment','left','Tag','PDEXField',...
      'Position',[.8 .965 .075 .03],'String','0.0');
  uicontrol(pde_fig,'Style','text',...
      'Units','normalized',...
      'Position',[.89 .965 .03 .03],...
      'ForegroundColor','k','String','Y:');
  yh=uicontrol(pde_fig,'Style','text','Units','normalized',...
      'HorizontalAlignment','left','Tag','PDEYField',...
      'Position',[.92 .965 .075 .03],'String','0.0');

  % Set formula:
  uicontrol(pde_fig,'Style','frame','Units','normalized',...
      'Position',[0 0.9 1 .06]);
  uicontrol(pde_fig,'Style','text',...
      'Units','normalized', 'HorizontalAlignment','left',...
      'Position',[.03 .91 .12 .04],...
      'String','Set formula:');
  uicontrol(pde_fig,...
        'Style','edit',...
        'Units','normalized',...
        'Position',[.15 .91 .8 .04],...
        'HorizontalAlignment','left',...
        'BackgroundColor','w',...
        'Enable','on',...
        'Tag','PDEEval',...
        'Callback','pdetool formchk',...
        'String','',...
        'UserData','');

  % Info string display:
  uicontrol(pde_fig,'Style','frame','Units','normalized',...
      'Position',[0  0 .86 .06]);
  uicontrol(pde_fig,'Style','text',...
      'Units','normalized','HorizontalAlignment','right',...
      'Position',[.02 .01 .1  .04],...
      'String','Info:');
  uicontrol(pde_fig,'Style','text','Units','normalized',...
      'Position',[.14 .01 .7 .04],'HorizontalAlignment','left',...
      'Value',1,'Tag','PDEInfo','String','Draw 2-D geometry.',...
      'Callback','Draw 2-D geometry.',...
      'UserData','Draw 2-D geometry.');

  % Exit button
  uicontrol(pde_fig,'Style','frame','Units','normalized',...
      'Position',[0.86 0 .14 .06]);
  uicontrol(pde_fig,'Style','pushbutton',...
      'Interruptible','on','Units','normalized',...
      'Position',[.88 .01 .1 .04],...
      'Callback','pdetool(''exit'')','String','Exit');

  % Initialize property containers:
  setappdata(pde_fig,'toolhelp',1);
  setappdata(pde_fig,'stick',zeros(6,1));
  setappdata(pde_fig,'application',1);
  setappdata(pde_fig,'equation','-div(c*grad(u))+a*u=f');
  setappdata(pde_fig,'params',str2mat('c','a','f','d'));
  setappdata(pde_fig,'description',str2mat([],[],[],[]));
  setappdata(pde_fig,'bounddescr',str2mat([],[],[],[]));
  setappdata(pde_fig,'boundeq',...
      str2mat('n*c*grad(u)+qu=g','h*u=r',[]))
  setappdata(pde_fig,'objnames',[]);
  setappdata(pde_fig,'showsublbl',0);
  setappdata(pde_fig,'showpdesublbl',0);
  setappdata(pde_fig,'showedgelbl',0);
  setappdata(pde_fig,'shownodelbl',0);
  setappdata(pde_fig,'showtrilbl',0);
  setappdata(pde_fig,'trisize',[])
  setappdata(pde_fig,'Hgrad',1.3)
  setappdata(pde_fig,'refinemethod','regular')
  setappdata(pde_fig,'jiggle',str2mat('on','mean',[]))
  setappdata(pde_fig,'meshstat',[])
  setappdata(pde_fig,'bl',[])
  setappdata(pde_fig,'animparam',[6 5 0])
  setappdata(pde_fig,'colstring','')
  setappdata(pde_fig,'arrowstring','')
  setappdata(pde_fig,'deformstring','')
  setappdata(pde_fig,'heightstring','')
  setappdata(pde_fig,'plotflags',[1 1 1 1 1 1 1 1 0 0 0 1 1 0 0 0 0 1])
  % [colvar colstyle heightvar heightstyle vectorvar vectorstyle
  % colval doplot xyplot showmesh animationflag popupvalue
  % colflag contflag heightflag vectorflag deformflag deformvar]

  str1='u|abs(grad(u))|abs(c*grad(u))|user entry';
  str2=' -grad(u)| -c*grad(u)| user entry';
  strmtx=str2mat(str1,str2);
  setappdata(pde_fig,'plotstrings',strmtx)
  setappdata(ax,'snap',0);
  setappdata(ax,'subsel',[]);
  setappdata(ax,'bordsel',[]);
  setappdata(ax,'extraspacex','');
  setappdata(ax,'extraspacey','');
  setappdata(ax,'selinit',0);

  winmenu(pde_fig);

  pde_i=0;
  % PDETool figure's UserData contains the following:
  % 1-2: handles to X and Y position text objects
  % 3-4: pde_xc: circle center coordinates
  % 5: pde_i: counter: number of lines drawn when drawing a polygon.
  % 6..6+3*pde_i-2: pde_x: x data for lines (1:pde_i), y data for
  % lines (1:pde_i), handles to line objects (1:pde_i-1)
  user_data=[xh yh 0.0 0.0 pde_i 0.0 0.0];

  set(pde_fig,'WindowButtonMotionFcn','pdemtncb(0)',...
              'WindowButtonDownFcn','pdeselect select',...
              'Pointer','arrow',...
              'HandleVisibility','callback',...
              'UserData',user_data)
  set(findobj(allchild(pde_fig),'flat','Type','axes'),...
      'HandleVisibility','callback')
  drawnow;

  % End of initialization activities

%
% case: save geometry in m-file (save as...)

elseif strcmp(action,'save_as')
   [outfile,outpath]=uiputfile('*.m','Save As','Location',[100,100]);    

if outfile~=0
    n=length(outfile);
    if n>3
      if ~strcmp(lower(outfile(n-1:n)),'.m')
        outfile=[outfile '.m'];
      end
    else
      outfile=[outfile '.m'];
    end

    outfilefull=[outpath outfile];

    fid=fopen(outfilefull,'w');
    if fid>0,
      pdetool('write',fid);
      set(pde_fig,'Name',['PDE Toolbox - ' upper(outfile)]);

      h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
      flags=get(h,'UserData');
      flags(1)=0;                               % need_save=0.
      set(h,'UserData',flags)

      set(findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu'),...
        'UserData',outfilefull)
      filemenu=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
      hndl=findobj(get(filemenu,'Children'),'flat','Tag','PDESave');
      set(hndl,'Enable','on');
    else
      pdetool('error',' Can''t open file');
    end
  end

%
% case: save geometry in m-file (save to current file)

elseif strcmp(action,'save')

  curr_file=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEEditMenu'),'UserData');

  fid=fopen(curr_file,'w');
  if fid>0
    pdetool('write',fid);
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData');
    flags(1)=0;                         % need_save=0.
    set(h,'UserData',flags)
  else
    pdetool('error',' Can''t open file');
  end

%
% case: write geometry to m-file

elseif strcmp(action,'write')

  pde_circ=1; pde_poly=2; pde_rect=3; pde_ellip=4;

  fid=flag;

  fprintf(fid,'function pdemodel\n');

  fprintf(fid,'[pde_fig,ax]=pdeinit;\n');

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  % application parameters:
  appl=getappdata(pde_fig,'application');
  if (appl>1 && appl<5),
    mode=2;
  else
    mode=1;
  end
  fprintf(fid,'pdetool(''appl_cb'',%i);\n',appl);

  % scaling, grid etc. ...
  if getappdata(ax,'snap')
    fprintf(fid,'pdetool(''snapon'',''on'');\n');
  end

  xmax=get(ax,'XLim');
  ymax=get(ax,'YLim');
  dasp=get(ax,'DataAspectRatio');
  pasp=get(ax,'PlotBoxAspectRatio');
  xtck=get(ax,'XTick');
  ytck=get(ax,'YTick');
  n=length(xtck);
  tmps=char(ones(n,1)*' %.17g,...\n');
  tmps=tmps';
  tmps=reshape(tmps,1,12*n);
  tmpx=sprintf(tmps,xtck);
  n=length(ytck);
  tmps=char(ones(n,1)*' %.17g,...\n');
  tmps=tmps';
  tmps=reshape(tmps,1,12*n);
  tmpy=sprintf(tmps,ytck);

  fprintf(fid,'set(ax,''DataAspectRatio'',[%.17g %.17g %.17g]);\n',dasp);
  fprintf(fid,'set(ax,''PlotBoxAspectRatio'',[%.17g %.17g %.17g]);\n',pasp);

  if strcmp(get(ax,'XLimMode'),'auto')
    fprintf(fid,'set(ax,''XLimMode'',''auto'');\n');
  else
    fprintf(fid,'set(ax,''XLim'',[%.17g %.17g]);\n',xmax);
  end
  if strcmp(get(ax,'YLimMode'),'auto')
    fprintf(fid,'set(ax,''YLimMode'',''auto'');\n');
  else
    fprintf(fid,'set(ax,''YLim'',[%.17g %.17g]);\n',ymax);
  end

  if strcmp(get(ax,'XTickMode'),'auto')
    fprintf(fid,'set(ax,''XTickMode'',''auto'');\n');
  else
    fprintf(fid,'set(ax,''XTick'',[%s]);\n',tmpx);
  end
  if strcmp(get(ax,'YTickMode'),'auto')
    fprintf(fid,'set(ax,''YTickMode'',''auto'');\n');
  else
    fprintf(fid,'set(ax,''YTick'',[%s]);\n',tmpy);
  end

  extrax=pdequote(getappdata(ax,'extraspacex'));
  extray=pdequote(getappdata(ax,'extraspacey'));
  if ~isempty(extrax),
    fprintf(fid,'setappdata(ax,''extraspacex'',''%s'');\n',extrax);
  end
  if ~isempty(extray),
    fprintf(fid,'setappdata(ax,''extraspacey'',''%s'');\n',extray);
  end

  opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
  gridhndl=findobj(get(opthndl,'Children'),'flat','Tag','PDEGrid');
  if strcmp(get(gridhndl,'Checked'),'on')
    fprintf(fid,'pdetool(''gridon'',''on'');\n');
  end

  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
    'Tag','PDEMeshMenu'),'UserData');

  labels=pdequote(getappdata(pde_fig,'objnames'));
  fprintf(fid,'\n%% Geometry description:\n');
  for i=1:size(pdegd,2),
    if pdegd(1,i)==pde_circ
      fprintf(fid,'pdecirc(%.17g,%.17g,%.17g,''%s'');\n',...
        pdegd(2:4,i),deblank(labels(:,i)'));
    elseif pdegd(1,i)==pde_ellip
      fprintf(fid,['pdeellip(%.17g,%.17g,%.17g,%.17g,...\n',...
        '%.17g,''%s'');\n'],...
      pdegd(2:6,i),deblank(labels(:,i)'));
    elseif pdegd(1,i)==pde_rect
      tmp=[pdegd(3:4,i)', pdegd(7,i), pdegd(9,i)];
      fprintf(fid,'pderect([%.17g %.17g %.17g %.17g],''%s'');\n',...
        tmp,deblank(labels(:,i)'));
    elseif pdegd(1,i)==pde_poly
      n=pdegd(2,i);
      tmps=char(ones(n,1)*' %.17g,...\n');
      tmps=tmps';
      tmps=reshape(tmps,1,12*n);
      tmpx=sprintf(tmps,pdegd(3:2+n,i));
      tmpy=sprintf(tmps,pdegd(3+n:2*n+2,i));
      fprintf(fid,'pdepoly([%s],...\n[%s],...\n ''%s'');\n',...
        tmpx,tmpy,deblank(labels(:,i)'));
    end
  end

  evalhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
  evalstring=pdequote(get(evalhndl,'String'));
  fprintf(fid,['set(findobj(get(pde_fig,''Children''),'...
        '''Tag'',''PDEEval''),''String'',''%s'')\n'],evalstring);

  % non-empty boundary condition matrix and compatible geometry needed
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  hbound=findobj(get(menuhndl,'Children'),'flat','Tag','PDEBoundMode');
  pdebound=get(hbound,'UserData');
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');

  if ~isempty(pdebound) && ~abs(flags(3)),

    ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
    bndlines=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
    nb=length(bndlines);
    % extract column in pdebound from external boundary lines' user data
    % column no is first user data entry
    for i=1:nb,
      ud=get(bndlines(i),'UserData');
      bndcol(i)=ud(1);
    end

    fprintf(fid,'\n%% Boundary conditions:\n');
    fprintf(fid,'pdetool(''changemode'',0)\n');

    bl=getappdata(pde_fig,'bl');
    n=size(bl,1);
    for i=1:n,
      blrow=bl(i,:);
      blines=blrow(1:max(find(blrow)));
      tmps=sprintf('%i ',blines);
      tmps=['[', tmps, ']'];
      fprintf(fid,'pdetool(''removeb'',%s);\n',tmps);
    end

    outbnds=find(pdebound(1,:)~=0);
    n=length(outbnds);
    for i=1:n,
      j=bndcol(i);
      nn=pdebound(1,j);
      mm=pdebound(2,j);
      if nn==1,
        if mm==0,
          type='neu';
          ql=pdebound(3,j);
          gl=pdebound(4,j);
          qstr=sprintf('''%s''',pdequote(char(pdebound(5:4+ql,j))'));
          gstr=sprintf('''%s''',...
            pdequote(char(pdebound(5+ql:4+ql+gl,j))'));
          fprintf(fid,['pdesetbd(%i,...\n',...
            '''%s'',...\n',...
            '%i,...\n',...
            '%s,...\n',...
            '%s)\n'],...
            j,type,mode,qstr,gstr);
        elseif mm==1,
          type='dir';
          hl=pdebound(5,j);
          rl=pdebound(6,j);
          hstr=sprintf('''%s''',pdequote(char(pdebound(9:8+hl,j))'));
          rstr=sprintf('''%s''',...
            pdequote(char(pdebound(9+hl:8+hl+rl,j))'));
          fprintf(fid,['pdesetbd(%i,...\n',...
            '''%s'',...\n',...
            '%i,...\n',...
            '%s,...\n',...
            '%s)\n'],...
            j,type,mode,hstr,rstr);
        end
      elseif nn==2,
        if mm==0,
          type='neu';
          ql=pdebound(3:6,j);
          gl=pdebound(7:8,j);
          qstr=sprintf('str2mat(''%s'',''%s'',''%s'',''%s'')',...
            pdequote(char(pdebound(9:8+ql(1),j))'),...
            pdequote(char(pdebound(9+ql(1):8+sum(ql(1:2)),j))'),...
            pdequote(char(pdebound(9+sum(ql(1:2)):8+sum(ql(1:3)),j))'),...
            pdequote(char(pdebound(9+sum(ql(1:3)):8+sum(ql),j))'));
          gstr=sprintf('str2mat(''%s'',''%s'')',...
            pdequote(char(pdebound(9+sum(ql):8+sum(ql)+gl(1),j))'),...
            pdequote(char(...
              pdebound(9+sum(ql)+gl(1):8+sum(ql)+sum(gl),j))'));
          fprintf(fid,['pdesetbd(%i,...\n',...
            '''%s'',...\n',...
            '%i,...\n',...
            '%s,...\n',...
            '%s)\n'],...
            j,type,mode,qstr,gstr);
        elseif mm==1,
          type='mix';
          ql=pdebound(3:6,j);
          gl=pdebound(7:8,j);
          hl=pdebound(9:10,j);
          rl=pdebound(11,j);
          qstr=sprintf('str2mat(''%s'',''%s'',''%s'',''%s'')',...
            pdequote(char(pdebound(12:11+ql(1),j))'),...
            pdequote(char(pdebound(12+ql(1):11+sum(ql(1:2)),j))'),...
            pdequote(char(...
            pdebound(12+sum(ql(1:2)):11+sum(ql(1:3)),j))'),...
            pdequote(char(pdebound(12+sum(ql(1:3)):11+sum(ql),j))'));
          gstr=sprintf('str2mat(''%s'',''%s'')',...
            pdequote(char(pdebound(12+sum(ql):11+sum(ql)+gl(1),j))'),...
            pdequote(char(...
              pdebound(12+sum(ql)+gl(1):11+sum(ql)+sum(gl),j))'));
          hstr=sprintf('str2mat(''%s'',''%s'')',...
            pdequote(char(pdebound(12+sum(ql)+sum(gl):...
            11+sum(ql)+sum(gl)+hl(1),j))'),...
            pdequote(char(...
              pdebound(12+sum(ql)+sum(gl)+hl(1):...
              11+sum(ql)+sum(gl)+sum(hl),j))'));
          rstr=pdequote(char(pdebound(12+sum(ql)+sum(gl)+sum(hl):...
            11+sum(ql)+sum(gl)+sum(hl)+rl,j))');
          fprintf(fid,['pdesetbd(%i,...\n',...
            '''%s'',...\n',...
            '%i,...\n',...
            '%s,...\n',...
            '%s,...\n',...
            '%s,...\n',...
            '''%s'')\n'],...
            j,type,mode,qstr,gstr,hstr,rstr);
        elseif mm==2,
          type='dir';
          hl=pdebound(9:12,j);
          rl=pdebound(13:14,j);
          hstr=sprintf('str2mat(''%s'',''%s'',''%s'',''%s'')',...
            pdequote(char(pdebound(21:20+hl(1),j))'),...
            pdequote(char(pdebound(21+hl(1):20+sum(hl(1:2)),j))'),...
            pdequote(char(pdebound(21+sum(hl(1:2)):...
            20+sum(hl(1:3)),j))'),...
            pdequote(char(pdebound(21+sum(hl(1:3)):20+sum(hl),j))'));
          rstr=sprintf('str2mat(''%s'',''%s'')',...
            pdequote(char(pdebound(21+sum(hl):20+sum(hl)+rl(1),j))'),...
            pdequote(char(...
              pdebound(21+sum(hl)+rl(1):20+sum(hl)+sum(rl),j))'));
          fprintf(fid,['pdesetbd(%i,...\n',...
            '''%s'',...\n',...
            '%i,...\n',...
            '%s,...\n',...
            '%s)\n'],...
            j,type,mode,hstr,rstr);
        end
      end
    end

    meshstat=getappdata(pde_fig,'meshstat');
    n=length(meshstat);
    if n>0,
      fprintf(fid,'\n%% Mesh generation:\n');
      trisize=getappdata(pde_fig,'trisize');
      if ~isempty(trisize),
        if ischar(trisize),
          fprintf(fid,'setappdata(pde_fig,''trisize'',''%s'');\n',...
            trisize);
        else
          fprintf(fid,...
            'setappdata(pde_fig,''trisize'',%.17g);\n', trisize);
        end
      end
      Hgrad=getappdata(pde_fig,'Hgrad');
      fprintf(fid,'setappdata(pde_fig,''Hgrad'',%.17g);\n', Hgrad);
      refmet=getappdata(pde_fig,'refinemethod');
      fprintf(fid,'setappdata(pde_fig,''refinemethod'',''%s'');\n',...
          refmet);
      for i=1:n,
        if meshstat(i)==1,
          fprintf(fid,'pdetool(''initmesh'')\n');
        elseif meshstat(i)==2,
          fprintf(fid,'pdetool(''refine'')\n');
        elseif meshstat(i)==3,
          fprintf(fid,'pdetool(''jiggle'')\n');
        elseif meshstat(i)==4,
          % mesh change from adaptive solver
          break;
        end
      end
    end

  end

  fprintf(fid,'\n%% PDE coefficients:\n');
  % Unpack parameters:
  params=pdequote(get(findobj(get(pde_fig,'Children'),'flat',...
    'Tag','PDEPDEMenu'),'UserData'));
  timeeigpar=pdequote(getappdata(pde_fig,'timeeigparam'));
  ncafd=getappdata(pde_fig,'ncafd');
  nc=ncafd(1); na=ncafd(2); nf=ncafd(3); nd=ncafd(4);
  c=params(1:nc,:); a=params(nc+1:nc+na,:);
  f=params(nc+na+1:nc+na+nf,:);
  d=params(nc+na+nf+1:nc+na+nf+nd,:);
  cstr=['''', deblank(c(1,:)), ''''];
  if nc>1,
    if nc<12,
      for i=2:nc,
        cstr=[cstr, ',''' deblank(c(i,:)), ''''];
      end
      cp=sprintf('str2mat(%s)',cstr);
    else
      for i=2:11,
        cstr=[cstr, ',''' deblank(c(i,:)), ''''];
      end
      cstr2=['''', deblank(c(12,:)), ''''];
      for i=13:nc,
        cstr2=[cstr2, ',''' deblank(c(i,:)), ''''];
      end
      cp=sprintf('str2mat(str2mat(%s),%s)',cstr,cstr2);
    end
  else
    cp=cstr;
  end
  astr=['''', deblank(a(1,:)), ''''];
  if na>1,
    for i=2:na,
      astr=[astr, ',''' deblank(a(i,:)), ''''];
    end
    ap=sprintf('str2mat(%s)',astr);
  else
    ap=astr;
  end
  fstr=['''', deblank(f(1,:)), ''''];
  if nf>1,
    for i=2:nf,
      fstr=[fstr, ',''' deblank(f(i,:)), ''''];
    end
    fp=sprintf('str2mat(%s)',fstr);
  else
    fp=fstr;
  end
  dstr=['''', deblank(d(1,:)), ''''];
  if nd>1,
    for i=2:nd,
      dstr=[dstr, ',''' deblank(d(i,:)), ''''];
    end
    dp=sprintf('str2mat(%s)',dstr);
  else
    dp=dstr;
  end
  pde_type=get(findobj(get(pde_fig,'Children'),'flat',...
    'Tag','PDEHelpMenu'),'UserData');
  fprintf(fid,['pdeseteq(%i,...\n',...
    '%s,...\n',...
    '%s,...\n',...
    '%s,...\n',...
    '%s,...\n',...
    '''%s'',...\n',...
    '''%s'',...\n',...
    '''%s'',...\n',...
    '''%s'')\n'],...
    pde_type,cp,ap,fp,dp,deblank(timeeigpar(1,:)),...
    deblank(timeeigpar(2,:)),deblank(timeeigpar(3,:)),...
    deblank(timeeigpar(4,:)));

  [currparams,I]=pdequote(getappdata(pde_fig,'currparam'));
  nc=size(currparams,1);
  if ~isempty(I)
    cpstr=sprintf('[''%s'';...\n', currparams(1,1:I(1)));
    for i=2:nc-1,
      cpstr=sprintf('%s''%s'';...\n', cpstr, currparams(i,1:I(i)));
    end
    cpstr=sprintf('%s''%s'']',cpstr, currparams(nc,1:I(nc)));
    fprintf(fid,['setappdata(pde_fig,''currparam'',...\n',...
          '%s)\n'],cpstr);
  end

  fprintf(fid,'\n%% Solve parameters:\n');
  % Unpack parameters:
  solveparams=pdequote(getappdata(pde_fig,'solveparam'));
  adapt=deblank(solveparams(1,:));
  maxtri=deblank(solveparams(2,:));
  maxref=deblank(solveparams(3,:));
  tripick=deblank(solveparams(4,:));
  param=deblank(solveparams(5,:));
  refmet=deblank(solveparams(6,:));
  nonlin=deblank(solveparams(7,:));
  nonlintol=deblank(solveparams(8,:));
  nonlininit=deblank(solveparams(9,:));
  jac=deblank(solveparams(10,:));
  nonlinnorm=deblank(solveparams(11,:));
  fprintf(fid,['setappdata(pde_fig,''solveparam'',...\n',...
      'str2mat(''%s'',''%s'',''%s'',''%s'',...\n',...
      '''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s''))\n'],...
      adapt,maxtri,maxref,tripick,param,refmet,...
      nonlin,nonlintol,nonlininit,jac,nonlinnorm);

  fprintf(fid,'\n%% Plotflags and user data strings:\n');
  plotflags=getappdata(pde_fig,'plotflags');
  fprintf(fid,...
    ['setappdata(pde_fig,''plotflags'',', mat2str(plotflags), ');\n']);
  colstring=pdequote(getappdata(pde_fig,'colstring'));
  fprintf(fid,...
    ['setappdata(pde_fig,''colstring'',''', colstring, ''');\n']);
  arrowstring=pdequote(getappdata(pde_fig,'arrowstring'));
  fprintf(fid,...
    ['setappdata(pde_fig,''arrowstring'',''', arrowstring, ''');\n']);
  deformstring=pdequote(getappdata(pde_fig,'deformstring'));
  fprintf(fid,...
    ['setappdata(pde_fig,''deformstring'',''', deformstring, ''');\n']);
  heightstring=pdequote(getappdata(pde_fig,'heightstring'));
  fprintf(fid,...
    ['setappdata(pde_fig,''heightstring'',''', heightstring, ''');\n']);

  if ~abs(flags(3)) && flags(6),
    fprintf(fid,'\n%% Solve PDE:\n');
    fprintf(fid,'pdetool(''solve'')\n');
  end

  fclose(fid);

%
% case: load geometry through m-file

elseif strcmp(action,'open')

  [infile,inpath]=uigetfile('*.m','Open','Location',[100,100]);
  
  figure(pde_fig);
  set(pde_fig,'Pointer','watch')
  drawnow

  if infile~=0
    instring=[inpath infile];
    fid = fopen(instring,'r');
    n=length(infile);
    if fid==-1 || n<2
      pdetool('error','  File not found.');
    elseif ~strcmp(lower(infile(n-1:n)),'.m')
      pdetool('error','  File is not an m-file.');
      fclose(fid);
    else
      h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
      flags=get(h,'UserData');
      need_save=flags(1);

      if need_save
        curr_file=get(findobj(get(pde_fig,'Children'),'flat',...
            'Tag','PDEEditMenu'),'UserData');
        if isempty(curr_file)
          tmp=' Save changes in ''Untitled'' ?';
        else
          tmp=[' Save changes in ' pdebasnm(curr_file) '?'];
        end

        answr=questdlg(tmp,'New','Yes','No','Cancel','Yes');
      else
        answr = 'No';
      end

      if strcmp(answr,'Cancel'),
        set(pde_fig,'Pointer','arrow')
        drawnow
        return;
      end

      if strcmp(answr,'Yes')
        if isempty(curr_file)
          pdetool('save_as');
        else
          pdetool('save');
        end
      end

      flags(1)=0;
      set(h,'UserData',flags)

      currdir=pwd;
      if strcmp(computer,'PCWIN'),
      % If PC Windows, strip '\' at end (ASCII 92)
        if abs(inpath(length(inpath)))==92,
          inpath=inpath(1:length(inpath)-1);
        end
      end
      cd(inpath);
      modelerror=0;
      eval(infile(1:n-2),'modelerror=1;')
      if modelerror,
        pdetool('error',sprintf(' Error executing Model M-file %s',infile));
        set(pde_fig,'Pointer','arrow')
        drawnow
        fclose(fid);
        cd(currdir)
        return;
      end
      name=['PDE Toolbox - ', upper(infile)];
      set(findobj(get(pde_fig,'Children'),'Tag','PDESave'),...
          'Enable','on')
      set(findobj(get(pde_fig,'Children'),...
          'flat','Tag','PDEEditMenu'),'UserData',instring)
      set(pde_fig,'Name',name)

      flags=get(h,'UserData'); flags(1)=0;
      set(h,'UserData',flags)

      fclose(fid);
      cd(currdir)
    end
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: new geometry

elseif strcmp(action,'new')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');
  need_save=flags(1);

  % A flag value is sent from PDEINIT to prevent
  % question dialog when starting from the command line
  % using a model M-file.
  if need_save,
    curr_file=get(findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEEditMenu'),'UserData');
    if isempty(curr_file)
      queststr=' Save changes in ''Untitled'' ?';
    else
      queststr=[' Save changes in ' pdebasnm(curr_file) '?'];
    end

    answr=questdlg(queststr,'New','Yes','No','Cancel','Yes');

  else
    answr = 'No';
  end

  if strcmp(answr,'Cancel'), return, end

  if strcmp(answr,'Yes')
    if isempty(curr_file)
      pdetool('save_as');
    else
      pdetool('save');
    end
  end

  pdeinfo('Draw 2-D geometry.');

  % Reset PDEGD matrix
  meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  set(meshhndl,'UserData',[]);
  bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  % Reset PDEDL matrix
  set(bndhndl,'UserData',[]);
  % Reset PDEBOUND matrix:
  set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundMode'),...
      'UserData',[]);
  % Set current file name to an empty string
  set(findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu'),...
      'UserData',[]);

  % Disable export of boundary data
  set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEExpBound'),...
      'Enable','off')

  % Disable export of mesh
  set(findobj(get(meshhndl,'Children'),'flat','Tag','PDEExpMesh'),...
      'Enable','off')

  % Turn off zoom
  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'out')
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

  flagh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flagh,'UserData'); mode_flag=flags(2);
  % some extra restoration job if New is invoked when in solve mode:
  if mode_flag,
    hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
    set(hndl,'Enable','on');
    set(pde_fig,'Colormap',get(get(ax,'XLabel'),'UserData'))

    % delete colorbar and solution plot
    delete(findobj(get(pde_fig,'Children'),'flat','Tag','PDESolBar'))
    h=get(ax,'UserData');
    delete(h)
    set(ax,'UserData',[],'Position',getappdata(ax,'axstdpos'))

    % clear boundary selection vector
    bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
    set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec'),...
        'UserData',[]);

    % turn off labeling if needed
    if getappdata(pde_fig,'showsublbl'),
      pdetool sublbl
    end
    if getappdata(pde_fig,'showpdesublbl'),
      pdetool pdesublbl
    end
    if getappdata(pde_fig,'showedgelbl'),
      pdetool edgelbl
    end
    if getappdata(pde_fig,'showtrilbl'),
      pdetool pdetrilbl
    end
    if getappdata(pde_fig,'shownodelbl'),
      pdetool pdenodelbl
    end
  end

  % reset all flags
  set(flagh,'UserData',zeros(7,1));

  filehndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  hndl=findobj(get(filehndl,'Children'),'flat','Tag','PDESave');
  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  hndl=[hndl findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDECut')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDECopy')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDEClear')];
  drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
  hndl=[hndl findobj(get(drawhndl,'Children'),'flat','Tag','PDEExpGD')];
  set(hndl,'Enable','off');
  set(edithndl,'Enable','on')
  set(findobj(get(edithndl,'Children'),'flat','Tag','PDESelall'),...
      'Enable','on','CallBack','pdeselect(''select'',1)')

  set(pde_fig,'name','PDE Toolbox - [Untitled]');

  hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
  set(hndl,'String','','UserData','');

  snap=getappdata(ax,'snap');

  hndl=[findobj(get(ax,'Children'),'flat','Type','line')',...
        findobj(get(ax,'Children'),'flat','Type','text','Tag','PDELabel')',...
        findobj(get(ax,'Children'),'flat','Type','text','Tag','PDELblSel')',...
        findobj(get(ax,'Children'),'flat','Type','patch')'];
  delete(hndl)

  set(get(ax,'Title'),'String','');

  user_data=get(pde_fig,'UserData');
  user_data(5)=0;                       % pde_i
  user_data(6:7)=[0 0]; user_data=user_data(1:7);

  set(pde_fig,'UserData',user_data)

  set(get(ax,'ZLabel'),'UserData',[])

  % un-select all draw features
  for i=1:5,
    btnup(pde_fig,'draw',i);
  end
  h=findobj(get(drawhndl,'Children'),'flat','Checked','on');
  set(h,'Checked','off')

  % enable 'Rotate...':
  set(findobj(get(drawhndl,'Children'),'flat','Tag','PDERotate'),...
      'Enable','on');

  % reset property containers
  set(pde_fig,'WindowButtonDownFcn','pdeselect select');
  setappdata(pde_fig,'objnames',[]);
  setappdata(pde_fig,'nodehandles',[]);
  setappdata(pde_fig,'trihandles',[]);
  setappdata(pde_fig,'meshstat',[])
  setappdata(pde_fig,'bl',[])
  setappdata(ax,'snap',snap);
  setappdata(ax,'subsel',[]);
  setappdata(ax,'bordsel',[]);
  setappdata(ax,'selinit',0);

  % Restore max no of triangles for adaptive solver to 1000
  solveparams=getappdata(pde_fig,'solveparam');
  setappdata(pde_fig,'solveparam',...
    str2mat(solveparams(1,:),'1000',solveparams(3:11,:)))

  set(pde_fig,'CurrentAxes',ax)

  refresh(pde_fig)

%
% case: exit

elseif strcmp(action,'exit')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');
  need_save=flags(1);

  if need_save
    curr_file=get(findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEEditMenu'),'UserData');
    if isempty(curr_file)
      queststr=' Save changes in ''Untitled'' ?';
    else
      queststr=[' Save changes in ' pdebasnm(curr_file) '?'];
    end

    answr=questdlg(queststr,'Exit','Yes','No','Cancel','Yes');

  else
    answr = 'No';
  end

  if ~strcmp(answr,'Cancel')
    if strcmp(answr,'Yes')
      if isempty(curr_file)
        pdetool('save_as');
      else
        pdetool('save');
      end
    end

    % Close main PDETOOL figure and all open dialog boxes
    figs=allchild(0);
    for i=1:length(figs),
      figlbl=lower(get(figs(i),'Tag'));
      if ~isempty(findstr(figlbl,'pde'))
        delete(figs(i))
      end
    end
  end

%
% case: print pde toolbox figure

elseif strcmp(action,'print')

  kids=get(pde_fig,'Children');
  btnaxes=[findobj(kids,'flat','Type','axes','Tag','draw'),...
          findobj(kids,'flat','Type','axes','Tag','solve'),...
          findobj(kids,'flat','Type','axes','Tag','zoom')];
  uictrls = findobj(kids,'flat','Type','uicontrol');
  hideme = [btnaxes(:); uictrls];
  if strcmp(computer, 'PCWIN')
    printdlg('-crossplatform',pde_fig,[0 0.08 1 0.79],[0.05 0.05 .9 .9],hideme);
  else
    printdlg(pde_fig,[0 0.08 1 0.79],[0.05 0.05 .9 .9],hideme);
  end

%
% case: handle callback from key presses

elseif strcmp(action,'keycall')

  currchar=get(pde_fig,'CurrentCharacter');

  if ~isempty(currchar) && (abs(currchar)==127 || abs(currchar)==8),
    % case: backspace or delete
    pdetool('clear')
  end

%
% case: change axes limits

elseif strcmp(action,'axlim')

  pdeinfo('Enter axes limits.');

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  xmax=get(ax,'XLim');
  xmin=xmax(1); xmax=xmax(2);
  ymax=get(ax,'YLim');
  ymin=ymax(1); ymax=ymax(2);

  PromptString = str2mat('X-axis range:','Y-axis range:');
  OptFlags=[1, 0; 1, 0];
  DefLim = [xmin xmax; ymin ymax];
  figh=axlimdlg('Axes Limits',OptFlags,PromptString,[ax NaN ax],['x'; 'y'],...
      DefLim,'pdetool(''applyaxlim''); ');
  set(figh,'Tag','PDEAxLimDlg')

%
% case: apply new axes limits (callback via AXLIMDLG)

elseif strcmp(action,'applyaxlim')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  hndls=get(gcf,'UserData');
  hndls=hndls(:,2);                     % EditField handles is 2nd column
  xlim=get(hndls(1),'UserData');
  ylim=get(hndls(2),'UserData');

  set(ax,'XLim',xlim, 'YLim',ylim,...
      'DataAspectRatio',[1 1.5*diff(ylim)/diff(xlim) 1]);

  set(get(ax,'ZLabel'),'UserData',[]);

  opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
  h=findobj(get(opthndl,'Children'),'flat','Tag','PDEAxeq');
  set(h,'Checked','off')

  pdeinfo;

%
% case: set axes equal on/off

elseif strcmp(action,'axeq')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax);

  opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
  h=findobj(get(opthndl,'Children'),'flat','Tag','PDEAxeq');
  if umtoggle(h)
    % Axis equal
    axis equal
  else
    % Axis normal
    set(ax,...
	'DataAspectRatioMode','auto',...
	'PlotBoxAspectRatioMode','auto',...
	'CameraViewAngleMode','auto')
  end

  set(get(ax,'ZLabel'),'UserData',[]);

%
% case: spacing

elseif strcmp(action,'spacing')

  pdeinfo('Set x and y spacing. Separate entries using spaces, commas, semi-colons, or brackets.');

  pdespdlg

  pdeinfo;

%
% case: draw line (polygon)

elseif strcmp(action,'drawline')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);
  if mode_flag,
    pdetool('changemode',0)
  end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  btst=btnstate(pde_fig,'draw',1:5);
  if strcmp(get(pde_fig,'SelectionType'),'open'),
    btndown(pde_fig,'draw',5);
    sticks=zeros(6,1);
    sticks(5)=1;
    setappdata(pde_fig,'stick',sticks);
    return;
  else
    drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
    ghndls=get(drawhndl,'UserData');
    my_hndl=findobj(get(drawhndl,'Children'),'flat','Tag','PDEPoly');

    if umtoggle(my_hndl),
      ghndls=ghndls(find(ghndls~=my_hndl));
      set(ghndls,'Checked','off')
      if ~btst(5),
        btndown(pde_fig,'draw',5)
        btst(5)=1;
      end
      if btst(5),
        btst(5)=0;
        if any(btst),
          btnup(pde_fig,'draw',find(btst));
        end
      end
    else
      btnup(pde_fig,'draw',5)
      ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
      axKids=get(ax,'Children');
      lines=findobj(axKids,'flat','Tag','PDELine');
      % Erase any unfinished polygon lines
      if ~isempty(lines),
        set(lines,'Erasemode','normal'), set(lines,'Erasemode','xor')
        delete(lines)
        user_data=get(pde_fig,'UserData');
        user_data=[user_data(1:4) zeros(1,4)];
        set(pde_fig,'UserData',user_data)
      end
      set(pde_fig,'WindowButtonDownFcn','pdeselect select',...
        'WindowButtonUpFcn','')
      setappdata(pde_fig,'stick',zeros(6,1));
      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
      return;
    end
  end

  drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
  ghndls=get(drawhndl,'UserData');

  pdeinfo(['Click to create lines.'...
           ' Click at starting point to close polygon.']);
  set(pde_fig,'WindowButtonDownFcn','pdetool lineclk',...
              'WindowButtonUpFcn','');
  user_data=get(pde_fig,'UserData');
  i=user_data(5);
  if i>0,
    % If unfinished polygon on screen, enable undo:
    edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
    hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo');
    set(hndl,'Enable','on');
  end

%
% case: draw rectangle/square
%
% (flag=1 = drag from corner, flag=2 = drag from center)

elseif strcmp(action,'drawrect')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);
  if mode_flag,
    pdetool('changemode',0)
  end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  btst=btnstate(pde_fig,'draw',1:5);
  if strcmp(get(pde_fig,'SelectionType'),'open'),
    btndown(pde_fig,'draw',flag);
    sticks=zeros(6,1);
    sticks(flag)=1;
    setappdata(pde_fig,'stick',sticks);
    return;
  else
    drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
    ghndls=get(drawhndl,'UserData');
    if flag==1,
      my_hndl=findobj(get(drawhndl,'Children'),'flat','Tag','PDERect');
    elseif flag==2,
      my_hndl=findobj(get(drawhndl,'Children'),'flat','Tag','PDERectc');
    end
    if umtoggle(my_hndl),
      ghndls=ghndls(find(ghndls~=my_hndl));
      set(ghndls,'Checked','off')
      if ~btst(flag),
        btndown(pde_fig,'draw',flag)
        btst(flag)=1;
      end
      if btst(flag),
        btst(flag)=0;
        if any(btst),
          btnup(pde_fig,'draw',find(btst));
          ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
          axKids=get(ax,'Children');
          lines=findobj(axKids,'flat','Tag','PDELine');
          % Erase any unfinished polygon lines
          if ~isempty(lines),
            set(lines,'Erasemode','normal'), set(lines,'Erasemode','xor')
            delete(lines)
            user_data=get(pde_fig,'UserData');
            user_data=[user_data(1:4) zeros(1,4)];
            set(pde_fig,'UserData',user_data)
          end
        end
      end

      if flag==1,
        pdeinfo('Click at corner and drag to create rectangle/square.');
        set(pde_fig,'WindowButtonDownFcn','pdetool(''rectstart'',1)',...
          'WindowButtonUpFcn','');
      elseif flag==2,
        pdeinfo('Click at center and drag to create rectangle/square.');
        set(pde_fig,'WindowButtonDownFcn','pdetool(''rectstart'',2)',...
          'WindowButtonUpFcn','');
      end
    else
      btnup(pde_fig,'draw',flag)
      set(pde_fig,'WindowButtonDownFcn','pdeselect select')
      setappdata(pde_fig,'stick',zeros(6,1));
      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
      return;
    end
  end

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo');
  set(hndl,'Enable','off');

%
% case: draw ellipse/circle
%
% (flag=1 = drag from corner, flag=2 = drag from center)

elseif strcmp(action,'drawellipse')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);
  if mode_flag,
    pdetool('changemode',0)
  end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  btst=btnstate(pde_fig,'draw',1:5);
  if strcmp(get(pde_fig,'SelectionType'),'open'),
    btndown(pde_fig,'draw',flag+2);
    sticks=zeros(6,1);
    sticks(flag+2)=1;
    setappdata(pde_fig,'stick',sticks);
    return;
  else
    drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
    ghndls=get(drawhndl,'UserData');
    if flag==1,
      my_hndl=findobj(get(drawhndl,'Children'),'flat','Tag','PDEEllip');
    elseif flag==2,
      my_hndl=findobj(get(drawhndl,'Children'),'flat',...
          'Tag','PDEEllipc');
    end

    if umtoggle(my_hndl),
      ghndls=ghndls(find(ghndls~=my_hndl));
      set(ghndls,'Checked','off')
      if ~btst(flag+2),
        btndown(pde_fig,'draw',flag+2)
        btst(flag+2)=1;
      end
      if btst(flag+2),
        btst(flag+2)=0;
        if any(btst),
          btnup(pde_fig,'draw',find(btst));
          ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
          axKids=get(ax,'Children');
          lines=findobj(axKids,'flat','Tag','PDELine');
          % Erase any unfinished polygon lines
          if ~isempty(lines),
            set(lines,'Erasemode','normal'), set(lines,'Erasemode','xor')
            delete(lines)
            user_data=get(pde_fig,'UserData');
            user_data=[user_data(1:4) zeros(1,4)];
            set(pde_fig,'UserData',user_data)
          end
        end
      end
    else
      btnup(pde_fig,'draw',flag+2)
      set(pde_fig,'WindowButtonDownFcn','pdeselect select',...
        'WindowButtonUpFcn','');
      setappdata(pde_fig,'stick',zeros(6,1));
      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
      return;
    end
  end

  if flag==1,
    pdeinfo('Click on perimeter and drag to create ellipse/circle.');
    set(pde_fig,'WindowButtonDownFcn','pdetool(''circlecntr'',1)',...
      'WindowButtonUpFcn','');
  elseif flag==2,
    pdeinfo('Click at center and drag to create ellipse/circle.');
    set(pde_fig,'WindowButtonDownFcn','pdetool(''circlecntr'',2)',...
      'WindowButtonUpFcn','');
  end

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo');
  set(hndl,'Enable','off');

%
% case: click to draw line (lineclk)

elseif strcmp(action,'lineclk')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if ~pdeonax(ax), return, end

  user_data=get(pde_fig,'UserData');
  i=user_data(5);
  x=user_data(6:6+i-1); y=user_data(6+i:6+2*i-1);
  line_hndls=user_data(6+2*i:6+3*i-2);
  i=i+1;

  set(pde_fig,'CurrentAxes',ax)
  if strcmp(get(pde_fig,'SelectionType'),'alt') && i>1,
    x(i)=x(1); y(i)=y(1);
  else
    pv=get(ax,'CurrentPoint');
    [x(i),y(i)]=pdesnap(ax,pv,getappdata(ax,'snap'));
  end

  if i==1,
    user_data=[user_data(1:4) i x y line_hndls];
    set(pde_fig,'UserData',user_data);
    i=1+1;
    x(i)=x(i-1); y(i)=y(i-1);
  end

  hold on;
  hndl=line([x(i-1) x(i)],[y(i-1) y(i)],'color','r',...
            'linestyle','-','Erasemode','xor');
  hold off;
  set(ax,'UserData',hndl)

  set(pde_fig,'WindowButtonMotionFcn','pdemtncb(10)',...
              'WindowButtonUpFcn','pdetool linedraw')

%
% case: button up function to draw line or completed polygon

elseif strcmp(action,'linedraw')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if ~pdeonax(ax), return, end

  user_data=get(pde_fig,'UserData');
  i=user_data(5);
  x=user_data(6:6+i-1); y=user_data(6+i:6+2*i-1);
  line_hndls=user_data(6+2*i:6+3*i-2);
  i=i+1;

  if strcmp(get(pde_fig,'SelectionType'),'alt') && i>1,
    x(i)=x(1); y(i)=y(1);
  else
    pv=get(ax,'CurrentPoint');
    [x(i),y(i)]=pdesnap(ax,pv,getappdata(ax,'snap'));
  end

  set(pde_fig,'WindowButtonMotionFcn','pdemtncb(0)','CurrentAxes',ax)

  delete(get(ax,'UserData'));
  set(ax,'UserData',[]);

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  undo_hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo');
  set(undo_hndl,'Enable','on');
  xlim=get(ax,'Xlim');
  ylim=get(ax,'Ylim');
  gobj=[2, length(x), x, y]';
  % Check polygon:
  polystat=csgchk(gobj,diff(xlim),diff(ylim));
  if polystat>1,
  % Self-intersecting open or closed polygon
    pdetool('error','  Polygon lines must not overlap or intersect.');
    if i==2,
      i=0;
      x=[]; y=[];
    else
      i=i-1;
      x=x(1:i); y=y(1:i);
    end
  elseif polystat==1,
  % OK open polygon
    line_hndls(i-1)=line(x(i-1:i),...
                         y(i-1:i),...
                         'Tag','PDELine',...
                         'Color','r',...
                         'EraseMode','background');
  elseif polystat==0,
  % OK closed polygon
    set(pde_fig,'WindowButtonUpFcn','');
    sticks=getappdata(pde_fig,'stick');
    if ~any(sticks),
      set(pde_fig,'WindowButtonDownFcn','pdeselect select')
    end
    % polygon (lines):
    hndls=findobj(get(ax,'Children'),'flat',...
                  'Tag','PDELine');
    delete(hndls)
    pdepoly(x(1:i-1),y(1:i-1));

    if ~any(sticks),
      drawnow;
      btst=btnstate(pde_fig,'draw');
      if any(btst)
        btnup(pde_fig,'draw',...
          find(btst))
      end
      drawhndl=findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEDrawMenu');
      h=findobj(get(drawhndl,'Children'),'flat','Checked','on');
      set(h,'Checked','off')

      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
    end

    set(undo_hndl,'Enable','off');
    i=0; x=[]; y=[];                    % polygon done; restart.
  end

  user_data=[user_data(1:4) i x y line_hndls];
  set(pde_fig,'UserData',user_data)

%
% case: undo last line

elseif strcmp(action,'undo')

  user_data=get(pde_fig,'UserData');
  i=user_data(5);
  x=user_data(6:6+i-1); y=user_data(6+i:6+2*i-1);
  line_hndls=user_data(6+2*i:6+3*i-2);

  %lines
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if i>1,
    set(line_hndls(i-1),'Erasemode','normal')
    set(line_hndls(i-1),'Erasemode','xor','Visible','off');
    i=i-1;
  end

  if i==1
    edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
    hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo');
    set(hndl,'Enable','off');
    i=0;
  end

  user_data=[user_data(1:4) i x(1:i) y(1:i) line_hndls(1:i-1)];
  set(pde_fig,'UserData',user_data);

%
% case: cut selected object(s) out (flag=1) or copy to 'clipboard' (flag=2)

elseif strcmp(action,'cut')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  selected=findobj(get(ax,'Children'),'flat','Tag','PDELblSel','Visible','on');
  if ~isempty(selected)

    edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
    hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEPaste');
    set(hndl,'Enable','on')

    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    pdegd=get(h,'UserData');

    n=length(selected);
    for i=1:n,
      column=get(selected(i),'UserData');
      clipboard(:,i)=pdegd(:,column);
    end
    set(findobj(get(edithndl,'Children'),'flat','Tag','PDECut'),...
        'UserData',clipboard);

    if flag==1,
      % case: cut selected objects out
      pdetool('clear')
    end
  end

%
% case: click to draw circle

elseif strcmp(action,'circlecntr')

  if ~pdeonax, return, end

  user_data=get(pde_fig,'UserData');

  % flag: 1=drag from perimeter, 2=drag from center
  if flag==1,
    if strcmp(get(pde_fig,'SelectionType'),'alt'), %circle
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(-3)');
      set(pde_fig,'WindowButtonUpFcn','pdetool(''circledraw'',1)');
    else                                % ellipse
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(3)');
      set(pde_fig,'WindowButtonUpFcn','pdetool(''circledraw'',2)');
    end
  elseif flag==2,                       % circle
    if strcmp(get(pde_fig,'SelectionType'),'alt'),
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(-4)');
      set(pde_fig,'WindowButtonUpFcn','pdetool(''circledraw'',3)');
    else                                % ellipse
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(4)');
      set(pde_fig,'WindowButtonUpFcn','pdetool(''circledraw'',4)');
    end
  end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)
  pv=get(ax,'CurrentPoint');
  [xc(1),xc(2)]=pdesnap(ax,pv,getappdata(ax,'snap'));

  t=0:pi/50:2*pi;
  radius=0;
  xt=sin(t)*radius+xc(1); yt=cos(t)*radius+xc(2);
  hold on;
  hndl=line(xt,yt,'Color','r','EraseMode','xor');
  hold off;
  set(ax,'UserData',hndl)

  user_data(3:4)=xc;
  set(pde_fig,'UserData',user_data)

%
% case: mouse down to draw rectangle

elseif strcmp(action,'rectstart')

  if ~pdeonax, return, end

  set(pde_fig,'WindowButtonUpFcn','pdetool(''rectdraw'')');

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)
  pv=get(ax,'CurrentPoint');

  [tmp(1),tmp(2)]=pdesnap(ax,pv,getappdata(ax,'snap'));

  hold on;
  hndl=line([tmp(1) tmp(1) tmp(1) tmp(1) tmp(1)],...
      [tmp(2) tmp(2) tmp(2) tmp(2) tmp(2)],...
       'Color','r','EraseMode','xor');
  hold off;
  set(ax,'UserData',hndl)
  if flag==1,
    if strcmp(get(pde_fig,'SelectionType'),'alt'),
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(-1)')
    else
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(1)')
    end
  elseif flag==2,
    if strcmp(get(pde_fig,'SelectionType'),'alt'),
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(-2)')
    else
      set(pde_fig,'WindowButtonMotionFcn','pdemtncb(2)')
    end
  end

%
% case: mouse button up to draw ellipse/circle

elseif strcmp(action,'circledraw')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  hndl=get(ax,'UserData');
  if isempty(hndl) return; end

  user_data=get(pde_fig,'UserData');
  origin=user_data(3:4);

  set(pde_fig,'WindowButtonMotionFcn','pdemtncb(0)',...
        'WindowButtonUpFcn','');
  sticks=getappdata(pde_fig,'stick');

  pv=get(ax,'CurrentPoint');
  [xcurr,ycurr]=pdesnap(ax,pv,getappdata(ax,'snap'));

  delete(hndl);
  set(ax,'UserData',[]);

  if ~isempty(origin)
    if flag==1,                         % circle - perimeter
      dif=max(abs(xcurr-origin(1)),abs(ycurr-origin(2)));
      xsign=sign(pv(1,1)-origin(1));
      ysign=sign(pv(1,2)-origin(2));
      if xsign==0, xsign=1; end
      if ysign==0, ysign=1; end
      xc=0.5*(dif*xsign+2*origin(1));
      yc=0.5*(dif*ysign+2*origin(2));
      radius=0.5*dif;
      if radius==0,
        return;
      end
      if ~any(sticks),
        set(pde_fig,'WindowButtonDownFcn','pdeselect select')
      end
      pdecirc(xc,yc,radius);
    elseif flag==2,                     % ellipse - perimeter
      origin=0.5*(origin+[xcurr, ycurr]);
      radiusx=sqrt((origin(1)-xcurr)*(origin(1)-xcurr));
      radiusy=sqrt((origin(2)-ycurr)*(origin(2)-ycurr));
      if (radiusx==0 || radiusy==0), return; end
      if ~any(sticks),
        set(pde_fig,'WindowButtonDownFcn','pdeselect select')
      end
      small=100*eps*min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim')));
      if abs(radiusx-radiusy)<small,
        pdecirc(origin(1),origin(2),radiusx);
      else
        pdeellip(origin(1),origin(2),radiusx,radiusy);
      end
    elseif flag==3,                     % circle - center
      dif=max(abs(xcurr-origin(1)),abs(ycurr-origin(2)));
      radius=dif;
      if radius==0, return; end
      if ~any(sticks),
        set(pde_fig,'WindowButtonDownFcn','pdeselect select')
      end
      pdecirc(origin(1),origin(2),radius);
    elseif flag==4,                     % ellipse - center
      radiusx=sqrt((origin(1)-xcurr)*(origin(1)-xcurr));
      radiusy=sqrt((origin(2)-ycurr)*(origin(2)-ycurr));
      if (radiusx==0 || radiusy==0), return; end
      if ~any(sticks),
        set(pde_fig,'WindowButtonDownFcn','pdeselect select')
      end
      small=100*eps*min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim')));
      if abs(radiusx-radiusy)<small,
        pdecirc(origin(1),origin(2),radiusx);
      else
        pdeellip(origin(1),origin(2),radiusx,radiusy);
      end
    end

    if ~any(sticks),
      drawnow;
      btst=btnstate(pde_fig,'draw');
      if any(btst)
        btnup(pde_fig,'draw',...
          find(btst))
      end
      drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
      h=findobj(get(drawhndl,'Children'),'flat','Checked','on');
      set(h,'Checked','off')
      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
    end

  end

%
% case: mouse button up to draw rectangle

elseif strcmp(action,'rectdraw')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  hndl=get(ax,'UserData');
  if isempty(hndl), return; end

  set(pde_fig,'WindowButtonMotionFcn','pdemtncb(0)',...
        'WindowButtonUpFcn','');

  x=get(hndl,'Xdata'); y=get(hndl,'Ydata');
  delete(hndl);
  set(ax,'UserData',[]);

  if y(3)~=y(1) && x(3)~=x(1),

    sticks=getappdata(pde_fig,'stick');
    if ~any(sticks),
      set(pde_fig,'WindowButtonDownFcn','pdeselect select')
    end

    pderect([x(1:2) y([1 3])]);

    if ~any(sticks),
      drawnow;
      btst=btnstate(pde_fig,'draw');
      if any(btst)
        btnup(pde_fig,'draw',...
          find(btst))
      end
      drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
      h=findobj(get(drawhndl,'Children'),'flat','Checked','on');
      set(h,'Checked','off')

      pdeinfo('Draw and edit 2-D geometry by using the Draw and Edit menu options.');
    end

  end

%
% case: clear patch

elseif strcmp(action,'clear')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  selected=findobj(get(ax,'Children'),'flat','Tag','PDESelFrame',...
      'Visible','on');
  if isempty(selected), return; end
  n=length(selected);
  geom_cols=zeros(1,n);
  for i=1:n,
    geom_cols(i)=get(selected(i),'UserData');
  end

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  pdegd=get(h,'UserData');
  objmtx=getappdata(pde_fig,'objnames');
  m=size(pdegd,2);
  if n>1 && m>1,
    ind=find(~sum(~(ones(n,1)*(1:m)-(ones(m,1)*geom_cols)')));
  else
    ind=find(~(~(ones(n,1)*(1:m)-(ones(m,1)*geom_cols)')));
  end
  pdegd=pdegd(:,ind);
  set(h,'UserData',pdegd);
  objmtx=objmtx(:,ind);
  setappdata(pde_fig,'objnames',objmtx)

  set(pde_fig,'Pointer','watch');
  drawnow

  % First call DECSG to decompose geometry;

  [dl1,bt1,pdedl,bt,msb]=decsg(pdegd);

  pdepatch(pdedl,bt,msb);
  boundh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  set(boundh,'UserData',pdedl)
  set(get(ax,'Title'),'UserData',bt)

  setappdata(pde_fig,'dl1',dl1)
  setappdata(pde_fig,'bt1',bt1)

  set(pde_fig,'Pointer','arrow');
  drawnow

  evalhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');

  if isempty(pdegd),
    pdeinfo('Draw 2-D geometry.');
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData');
    flags(1)=0; flags(3)=0;
    set(h,'UserData',flags)
    set(evalhndl,'String','')
    drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
    hndl=findobj(get(drawhndl,'Children'),'flat','Tag','PDEExpGD');
    set(hndl,'Enable','off')
  else
    m=size(pdegd,2);
    for i=1:m,
      lbl=deblank(char(objmtx(:,i)'));
      if i==1,
        evalstr=lbl;
      else
        evalstr=[evalstr '+' lbl];
      end
    end
    % update set formula string
    set(evalhndl,'String',evalstr,'UserData',evalstr)
  end

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  hndl=findobj(get(edithndl,'Children'),'flat','Tag','PDEClear');
  set(hndl,'Enable','off');

%
% case: grid on/off

elseif strcmp(action,'gridon')

  pde_kids = allchild(pde_fig);
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax);
  opthndl=findobj(pde_kids,'flat','Tag','PDEOptMenu');
  gridhndl=findobj(get(opthndl,'Children'),'flat','Tag','PDEGrid');
  if nargin==2
    set(ax,'XGrid',flag,'YGrid',flag)
    set(gridhndl,'Checked',flag)
  else
    if umtoggle(gridhndl),
      set(ax,'XGrid','on','YGrid','on')
    else
      set(ax,'XGrid','off','YGrid','off')
      snaphndl=findobj(get(opthndl,'Children'),'flat','Tag','PDESnap');
      set(snaphndl,'Checked','off');
      setappdata(ax,'snap',0);
    end
  end

%
% case: snap to grid on/off

elseif strcmp(action,'snapon')

  pde_kids = allchild(pde_fig);
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');
  opthndl=findobj(pde_kids,'flat','Tag','PDEOptMenu');
  snaphndl=findobj(get(opthndl,'Children'),'flat','Tag','PDESnap');
  if nargin==2
    % flag contains 'on' or 'off'
    if strcmp(flag,'on')
      setappdata(ax,'snap',1)
    else
      setappdata(ax,'snap',0)
    end
    set(snaphndl,'Checked',flag)
  else
    % toggle state
    setappdata(ax,'snap',umtoggle(snaphndl));
  end

%
% case: enter boundary mode (define boundary conditions, alter subdomains)

elseif strcmp(action,'boundmode')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax,...
    'WindowButtonDownFcn','',...
    'WindowButtonUpFcn','')

  flags=get(flg_hndl,'UserData');
  if flags(2)~=1
    flags(2)=1;                         % mode_flag=1
    set(flg_hndl,'UserData',flags)

    pdetool('clearsol')

    % turn off everything else, light up boundary and subdomain lines
    kids=get(ax,'Children'); set(kids,'Erasemode','normal');
    set(kids,'Erasemode','xor','Visible','off')

    hh=[findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine')'...
            findobj(get(ax,'Children'),'flat','Tag','PDEBorderLine')'];
    if isempty(hh),
      pdetool('drawbounds')
    else
      bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
      selecth=findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec');
      selbounds=get(selecth,'UserData');
      set(selecth,'UserData',[])
      for i=1:length(selbounds),
        col=get(selbounds(i),'UserData');
        set(selbounds(i),'color',col(2:4))
      end
      set(hh,'Erasemode','background','Visible','on')
    end
  end

  pdeinfo('Click to select boundaries. Double-click to open boundary condition dialog box.');

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set(edithndl,'Enable','on')
  set(findobj(get(edithndl,'Children'),'flat','Tag','PDESelall'),...
      'Enable','on','CallBack','pdetool(''boundclk'',1)')

  % enable removal of interior subdomain boundaries
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  hbound(1)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemBord');
  hbound(2)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemAllBord');
  set(hbound,'Enable','on')

  % if requested, label subdomains and/or edges:
  if getappdata(pde_fig,'showsublbl'),
    pdetool('showsublbl',1)
  end
  if getappdata(pde_fig,'showedgelbl'),
    pdetool('showedgelbl',1)
  end

%
% case: enter PDE mode (enter PDE coefficients per subdomain)

elseif strcmp(action,'pdemode')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags(2)=4;           % mode_flag=4
  set(flg_hndl,'UserData',flags)

  pdeinfo('Click on subdomains to select. Double-click to open PDE Specification dialog box.');

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set(edithndl,'Enable','on')
  set(findobj(get(edithndl,'Children'),'flat','Tag','PDESelall'),...
      'Enable','on','CallBack','pdetool(''subclk'',1)')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax,...
    'WindowButtonDownFcn','pdetool(''subclk'')',...
    'WindowButtonUpFcn','')

  pdetool('clearsol')

  % turn off everything else
  kids=get(ax,'Children'); set(kids,'Erasemode','normal');
  set(kids,'Erasemode','xor','Visible','off')

  boundh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  dl=get(boundh,'UserData');
  bt=get(get(ax,'Title'),'UserData');
  msb=getappdata(pde_fig,'msb');

  h=findobj(get(ax,'Children'),'flat','Tag','PDESubDom');
  if isempty(h),
    pdepatch(dl,bt,msb,1)
  else
    set(h,'Erasemode','none','Visible','on');
  end

  % reset selection array and display the subdomain borders:
  setappdata(ax,'subsel',[])
  h=findobj(get(ax,'Children'),'flat','Tag','PDESelRegion');
  if ~isempty(h), delete(h); end
  dl1=getappdata(pde_fig,'dl1');
  pdebddsp(dl1)

  % if requested, label subdomains:
  if getappdata(pde_fig,'showpdesublbl'),
    pdetool('showsublbl',1)
  end

  % disable removal of interior subdomain boundaries
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  hbound(1)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemBord');
  hbound(2)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemAllBord');
  set(hbound,'Enable','off')

%
% case: manage edge labeling flags and indication

elseif strcmp(action,'edgelbl')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  edgeh=findobj(get(h,'Children'),'flat','Tag','PDEShowEdge');

  if umtoggle(edgeh),
    setappdata(pde_fig,'showedgelbl',1);
    if mode_flag==1,
      pdetool('showedgelbl',1)
    end
  else
    setappdata(pde_fig,'showedgelbl',0);
    if mode_flag==1,
      pdetool('showedgelbl',0)
    end
  end

%
% case: manage subdomain labeling flags and indication

elseif strcmp(action,'sublbl')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  subh=findobj(get(h,'Children'),'flat','Tag','PDEShowSub');

  if umtoggle(subh),
    setappdata(pde_fig,'showsublbl',1);
    if mode_flag==1,
      pdetool('showsublbl',1)
    end
  else
    setappdata(pde_fig,'showsublbl',0);
    if mode_flag==1,
      pdetool('showsublbl',0)
    end
  end

%
% case: manage pde mode subdomain labeling flags and indication

elseif strcmp(action,'pdesublbl')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEPDEMenu');
  subh=findobj(get(h,'Children'),'flat','Tag','PDEShowPDESub');

  if umtoggle(subh),
    setappdata(pde_fig,'showpdesublbl',1);
    if mode_flag==4,
      pdetool('showsublbl',1)
    end
  else
    setappdata(pde_fig,'showpdesublbl',0);
    if mode_flag==4,
      pdetool('showsublbl',0)
    end
  end

%
% case: manage mesh node labeling flags and indication

elseif strcmp(action,'pdenodelbl')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  nodeh=findobj(get(h,'Children'),'flat','Tag','PDEShowNode');

  if umtoggle(nodeh),
    setappdata(pde_fig,'shownodelbl',1);
    if mode_flag==2,
      pdetool('shownodelbl',1)
    end
  else
    setappdata(pde_fig,'shownodelbl',0);
    if mode_flag==2,
      pdetool('shownodelbl',0)
    end
  end

%
% case: manage mesh triangle labeling flags and indication

elseif strcmp(action,'pdetrilbl')

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  trih=findobj(get(h,'Children'),'flat','Tag','PDEShowTriangles');

  if umtoggle(trih)
    setappdata(pde_fig,'showtrilbl',1);
    if mode_flag==2,
      pdetool('showtrilbl',1)
    end
  else
    setappdata(pde_fig,'showtrilbl',0);
    if mode_flag==2,
      pdetool('showtrilbl',0)
    end
  end

%
% case: display subdomain labels for decomposed geometry

elseif strcmp(action,'showsublbl')

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)

  h=findobj(get(ax,'Children'),'flat','Tag','PDESubLabel');
  set(h,'Erasemode','normal'), set(h,'Erasemode','xor')
  delete(h)

  if flag,                              % flag is set: display labels

    bt1=getappdata(pde_fig,'bt1');

    p1=getappdata(pde_fig,'pinit2');
    t1=getappdata(pde_fig,'tinit2');

    A=pdetrg(p1,t1);
    small=100*eps*min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim')));

    n=size(bt1,1);
    for i=1:n,
      tri=find(t1(4,:)==i);
      Amax=find(A(tri)==max(A(tri))); Amax=Amax(1);
      xm=mean(p1(1,t1(1:3,tri(Amax))));
      ym=mean(p1(2,t1(1:3,tri(Amax))));
      text('String',int2str(i),'Units','data',...
          'Clipping','on','EraseMode','background',...
          'Tag','PDESubLabel','HorizontalAlignment','center',...
          'pos',[xm ym 1],'color','k',...
	  'Parent',ax);
    end
  end

%
% case: display edge labels for decomposed geometry

elseif strcmp(action,'showedgelbl')

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)

  h=findobj(get(ax,'Children'),'flat','Tag','PDEEdgeLabel');
  set(h,'Erasemode','normal'), set(h,'Erasemode','xor')
  delete(h)

  if flag,                              % flag is set: display labels

    dl1=getappdata(pde_fig,'dl1');

    n=size(dl1,2);
    for i=1:n,
      if dl1(1,i)==1,
        % circle
        th1=atan2(dl1(4,i)-dl1(9,i),dl1(2,i)-dl1(8,i));
        th2=atan2(dl1(5,i)-dl1(9,i),dl1(3,i)-dl1(8,i));
        if th2<th1, th2=th2+2*pi; end
        arg=(th2+th1)/2;
        xm=dl1(8,i)+cos(arg)*dl1(10,i);
        ym=dl1(9,i)+sin(arg)*dl1(10,i);
      elseif dl1(1,i)==4,
        % ellipse
        ca=cos(dl1(12,i)); sa=sin(dl1(12,i));
        xd=dl1(2,i)-dl1(8,i);
        yd=dl1(4,i)-dl1(9,i);
        x1=ca*xd+sa*yd;
        y1=-sa*xd+ca*yd;
        th1=atan2(y1./dl1(11,i),x1./dl1(10,i));
        xd=dl1(3,i)-dl1(8,i);
        yd=dl1(5,i)-dl1(9,i);
        x1=ca*xd+sa*yd;
        y1=-sa*xd+ca*yd;
        th2=atan2(y1./dl1(11,i),x1./dl1(10,i));
        if th2<th1, th2=th2+2*pi; end
        arg=(th2+th1)/2;
        x1=dl1(10,i)*cos(arg); y1=dl1(11,i)*sin(arg);
        xm=dl1(8,i)+ca*x1-sa*y1;
        ym=dl1(9,i)+sa*x1+ca*y1;
      else
        xm=0.5*(dl1(2,i)+dl1(3,i));
        ym=0.5*(dl1(4,i)+dl1(5,i));
      end
      text('String',int2str(i),'Units','data',...
          'Clipping','on','EraseMode','background',...
          'Tag','PDEEdgeLabel','HorizontalAlignment','center',...
          'pos',[xm ym 1],'color','k',...
	  'Parent',ax);
    end
  end

%
% case: display mesh node labels

elseif strcmp(action,'shownodelbl')

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)

  set(pde_fig,'Pointer','watch')
  drawnow

  h=getappdata(pde_fig,'nodehandles');
  set(h,'Erasemode','normal'), set(h,'Erasemode','xor')
  delete(h)

  if flag,                              % flag is set: display labels

    % get node data for the current mesh
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
    ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
    p=get(hp,'UserData'); t=get(ht,'UserData');

    scale=min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim')));
    ind=t(:,1)'; ind=[ind(1:3), ind(1)];
    trilength=max(mean(abs(diff(p(1,ind)))),mean(abs(diff(p(2,ind)))));
    if trilength/scale>0.06,
      fsize=10;
    elseif trilength/scale>0.04,
      fsize=8;
    elseif trilength/scale>0.02
      fsize=6;
    elseif trilength/scale>0.01
      fsize=5;
    elseif trilength/scale>0.005
      fsize=4;
    else
      fsize=3;
    end

    n=size(p,2);
    for i=1:n,
      txt(i)=text('String',int2str(i),'Units','data',...
          'Clipping','on','EraseMode','background',...
          'Tag','PDENodeLabel','HorizontalAlignment','center',...
          'FontSize',fsize,'pos',[p(1,i) p(2,i) 1],'color','k',...
	  'Parent',ax);

    end
    setappdata(pde_fig,'nodehandles',txt);
  else
    setappdata(pde_fig,'nodehandles',[]);
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: display mesh triangle labels

elseif strcmp(action,'showtrilbl')

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax)

  set(pde_fig,'Pointer','watch')
  drawnow

  h=getappdata(pde_fig,'trihandles');
  set(h,'Erasemode','normal'), set(h,'Erasemode','xor')
  delete(h)

  if flag,                              % flag is set: display labels

    % get node data for the current mesh
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
    ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
    p=get(hp,'UserData'); t=get(ht,'UserData');

    scale=min(diff(get(ax,'Xlim')),diff(get(ax,'Ylim')));
    ind=t(:,1)'; ind=[ind(1:3), ind(1)];
    trilength=max(mean(abs(diff(p(1,ind)))),mean(abs(diff(p(2,ind)))));
    if trilength/scale>0.06,
      fsize=10;
    elseif trilength/scale>0.04,
      fsize=8;
    elseif trilength/scale>0.02
      fsize=6;
    elseif trilength/scale>0.01
      fsize=5;
    elseif trilength/scale>0.005
      fsize=4;
    else
      fsize=3;
    end

    n=size(t,2);
    for i=1:n,
      xm=mean(p(1,t(1:3,i)));
      ym=mean(p(2,t(1:3,i)));
      txt(i)=text('String',int2str(i),'Units','data',...
          'Clipping','on','EraseMode','background',...
          'Tag','PDETriLabel','HorizontalAlignment','center',...
          'FontSize',fsize,'pos',[xm ym 1],'color','k',...
	  'Parent',ax);
    end
    setappdata(pde_fig,'trihandles',txt)
  else
    setappdata(pde_fig,'trihandles',[])
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: enter mesh mode (display mesh, create if non-existent)

elseif strcmp(action,'meshmode')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax,'WindowButtonDownFcn','')

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  else
    % Hide decomposition lines (=subdomain boundaries), boundary lines,
    % labels, and subdomains:
    hKids=get(ax,'Children');
    h=[findobj(hKids,'flat','Tag','PDEBoundLine')'...
            findobj(hKids,'flat','Tag','PDESubLabel')'...
            findobj(hKids,'flat','Tag','PDEEdgeLabel')'...
            findobj(hKids,'flat','Tag','PDESubDom')'...
            findobj(hKids,'flat','Tag','PDEBorderLine')'...
            findobj(hKids,'flat','Tag','PDESelRegion')'];

    set(h,'Erasemode','normal')
    set(h,'Erasemode','xor','Visible','off')

    flags=get(flg_hndl,'UserData');
    flags(2)=2;                         % mode_flag=2
    set(flg_hndl,'UserData',flags)

    pdetool('clearsol')

    drawnow

    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
    he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
    ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
    p=get(hp,'UserData'); e=get(he,'UserData'); t=get(ht,'UserData');

    % erase old mesh
    h=findobj(get(ax,'Children'),'flat','Tag','PDEMeshLine');
    set(h,'Erasemode','normal'); set(h,'Erasemode','xor'); delete(h)

    % create and plot the mesh
    h=pdeplot(p,e,t,'intool','on');
    set(h,'Erasemode','none','Tag','PDEMeshLine');

    % if requested, label nodes and/or triangles:
    if getappdata(pde_fig,'shownodelbl'),
      pdetool('shownodelbl',1)
    end
    if getappdata(pde_fig,'showtrilbl'),
      pdetool('showtrilbl',1)
    end
  end

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

  pdeinfo('Refine or jiggle mesh, label mesh nodes and triangles, display mesh quality plot.');

%
% case: initialize mesh

elseif strcmp(action,'initmesh')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flags(2)=2;                           % mode_flag=2
  set(flg_hndl,'UserData',flags)

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

  pdeinfo('Initializing mesh...',0);
  set(pde_fig,'CurrentAxes',ax,'Pointer','watch','WindowButtonDownFcn','')
  drawnow

  dl1=getappdata(pde_fig,'dl1');

  pdetool('clearsol')

  % Hide decomposition lines (=subdomain boundaries), boundary lines,
  % labels, and subdomains:
  hKids=get(ax,'Children');
  h=[findobj(hKids,'flat','Tag','PDEBoundLine')'...
          findobj(hKids,'flat','Tag','PDESubLabel')'...
          findobj(hKids,'flat','Tag','PDEEdgeLabel')'...
          findobj(hKids,'flat','Tag','PDESubDom')'...
          findobj(hKids,'flat','Tag','PDEBorderLine')'...
          findobj(hKids,'flat','Tag','PDESelRegion')'];

  set(h,'Erasemode','normal')
  set(h,'Erasemode','xor','Visible','off')

  drawnow

  trisize=getappdata(pde_fig,'trisize');
  Hgrad=getappdata(pde_fig,'Hgrad');
  jiggleparam=getappdata(pde_fig,'jiggle');
  jiggle=deblank(jiggleparam(1,:));
  if strcmp(jiggle,'on'),
    jiggle=deblank(jiggleparam(2,:));
  end
  jiggleiter=deblank(jiggleparam(3,:));
  if isempty(trisize),
    if isempty(jiggleiter),
      [p,e,t]=initmesh(dl1,'jiggle',jiggle,'Hgrad',Hgrad);
    else
      [p,e,t]=initmesh(dl1,'jiggle',jiggle,'Hgrad',Hgrad,...
          'jiggleiter',str2num(jiggleiter));
    end
  else
    if isempty(jiggleiter),
      [p,e,t]=initmesh(dl1,'hmax',trisize,'jiggle',jiggle,'Hgrad',Hgrad);
    else
      [p,e,t]=initmesh(dl1,'hmax',trisize,'jiggle',jiggle,'Hgrad','Hgrad',...
          'jiggleiter',str2num(jiggleiter));
    end
  end

  meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  h=findobj(get(meshhndl,'Children'),'flat','Tag','PDERefine');
  set(h,'Enable','on');
  h=findobj(get(meshhndl,'Children'),'flat','Tag','PDEUnrefine');
  set(h,'Enable','off');

  % erase old mesh
  h=findobj(get(ax,'Children'),'flat','Tag','PDEMeshLine');
  set(h,'Erasemode','normal'); set(h,'Erasemode','xor'); delete(h)

  % create and plot the mesh
  h=pdeplot(p,e,t,'intool','on');
  set(h,'Erasemode','none','Tag','PDEMeshLine');

  % save p, e, t
  set(findobj(get(meshhndl,'Children'),'flat','Tag','PDEInitMesh'),...
      'UserData',p)
  set(findobj(get(meshhndl,'Children'),'flat','Tag','PDERefine'),...
      'UserData',e)
  set(findobj(get(meshhndl,'Children'),'flat','Tag','PDEMeshParam'),...
      'UserData',t)

  % if requested, label nodes and/or triangles:
  if getappdata(pde_fig,'shownodelbl'),
    pdetool('shownodelbl',1)
  end
  if getappdata(pde_fig,'showtrilbl'),
    pdetool('showtrilbl',1)
  end

  % enable export
  set(findobj(get(meshhndl,'Children'),'flat','Tag','PDEExpMesh'),...
      'Enable','on')

  set(pde_fig,'Pointer','arrow')
  drawnow

  infostr=sprintf('Initialized mesh consists of %i nodes and %i triangles.',...
    size(p,2),size(t,2));
  pdeinfo(infostr);

  flags=get(flg_hndl,'UserData');
  flags(1)=1;                           % need_save=1
  flags(4)=0;                           % flag2=0
  flags(5)=1;                           % flag3=1
  flags(6)=0;                           % flag4=0
  set(flg_hndl,'UserData',flags)

  setappdata(pde_fig,'meshstat',1)

  % save this generation of the mesh for unrefine purposes
  setappdata(pde_fig,'p1',p);
  setappdata(pde_fig,'e1',e);
  setappdata(pde_fig,'t1',t);

  % Update max no of triangle default for adaptive solver
  % Double the current no, or 1000, whichever is greatest:
  solveparams=getappdata(pde_fig,'solveparam');
  tristr=int2str(max(1.5*size(t,2),1000));
  setappdata(pde_fig,'solveparam',...
    str2mat(solveparams(1,:),tristr,solveparams(3:11,:)))

  % disable removal of interior subdomain boundaries
  menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  hbound(1)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemBord');
  hbound(2)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemAllBord');
  set(hbound,'Enable','off')

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

%
% case: refine mesh

elseif strcmp(action,'refine')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  end
  flags=get(flg_hndl,'UserData');
  flags(2)=2;                           % mode_flag=2
  set(flg_hndl,'UserData',flags)

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

  pdeinfo('Refining mesh...',0);
  set(pde_fig,'CurrentAxes',ax,'Pointer','watch','WindowButtonDownFcn','')
  drawnow

  pdetool('clearsol')

  % Hide decomposition lines (=subdomain boundaries), boundary lines,
  % labels, and subdomains:
  hKids=get(ax,'Children');
  h=[findobj(hKids,'flat','Tag','PDEBoundLine')'...
          findobj(hKids,'flat','Tag','PDESubLabel')'...
          findobj(hKids,'flat','Tag','PDEEdgeLabel')'...
          findobj(hKids,'flat','Tag','PDESubDom')'...
          findobj(hKids,'flat','Tag','PDEBorderLine')'...
          findobj(hKids,'flat','Tag','PDESelRegion')'];

  set(h,'Erasemode','normal')
  set(h,'Erasemode','xor','Visible','off')

  drawnow

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
  p=get(hp,'UserData'); e=get(he,'UserData'); t=get(ht,'UserData');

  % erase old mesh
  h=findobj(get(ax,'Children'),'flat','Tag','PDEMeshLine');
  set(h,'Erasemode','normal'); set(h,'Erasemode','xor'); delete(h)

  % refine the mesh
  dl1=getappdata(pde_fig,'dl1');
  refmet=getappdata(pde_fig,'refinemethod');
  [p,e,t]=refinemesh(dl1,p,e,t,refmet);

  meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  h=findobj(get(meshhndl,'Children'),'flat','Tag','PDEUnrefine');
  set(h,'Enable','on');

  % plot the new mesh
  h=pdeplot(p,e,t,'intool','on');
  set(h,'Erasemode','none','Tag','PDEMeshLine');

  set(hp,'UserData',p), set(he,'UserData',e), set(ht,'UserData',t)

  % if requested, label nodes and/or triangles:
  if getappdata(pde_fig,'shownodelbl'),
    pdetool('shownodelbl',1)
  end


  if getappdata(pde_fig,'showtrilbl'),
    pdetool('showtrilbl',1)
  end

  flags=get(flg_hndl,'UserData');
  flags(1)=1;                           % need_save=1
  flags(5)=1;                           % flag3=1
  flags(6)=0;                           % flag4=0
  set(flg_hndl,'UserData',flags)

  meshstat=getappdata(pde_fig,'meshstat');
  meshstat=[meshstat 2];
  n=length(meshstat);
  setappdata(pde_fig,'meshstat',meshstat);

  % save this generation of the mesh for unrefine purposes
  setappdata(pde_fig,['p' int2str(n)],p);
  setappdata(pde_fig,['e' int2str(n)],e);
  setappdata(pde_fig,['t' int2str(n)],t);

  % Update max no of triangle default for adaptive solver
  % Double the current no, or 1000, whichever is greatest:
  solveparams=getappdata(pde_fig,'solveparam');
  tristr=int2str(max(1.5*size(t,2),1000));
  setappdata(pde_fig,'solveparam',...
    str2mat(solveparams(1,:),tristr,solveparams(3:11,:)))

  set(pde_fig,'Pointer','arrow')
  drawnow

  infostr=sprintf('Refined mesh consists of %i nodes and %i triangles.',...
    size(p,2),size(t,2));
  pdeinfo(infostr);

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

%
% case: jiggle mesh

elseif strcmp(action,'jiggle')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  end
  flags=get(flg_hndl,'UserData');
  flags(2)=2;                           % mode_flag=2
  set(flg_hndl,'UserData',flags)

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');

  pdeinfo('Jiggling mesh...',0);
  set(pde_fig,'CurrentAxes',ax,'Pointer','watch','WindowButtonDownFcn','')
  drawnow

  pdetool('clearsol')

  % Hide decomposition lines (=subdomain boundaries), boundary lines,
  % labels, and subdomains:
  hKids=get(ax,'Children');
  h=[findobj(hKids,'flat','Tag','PDEBoundLine')'...
          findobj(hKids,'flat','Tag','PDESubLabel')'...
          findobj(hKids,'flat','Tag','PDEEdgeLabel')'...
          findobj(hKids,'flat','Tag','PDESubDom')'...
          findobj(hKids,'flat','Tag','PDEBorderLine')'...
          findobj(hKids,'flat','Tag','PDESelRegion')'];

  set(h,'Erasemode','normal')
  set(h,'Erasemode','xor','Visible','off')

  drawnow

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
  p=get(hp,'UserData'); e=get(he,'UserData'); t=get(ht,'UserData');

  % erase old mesh plot
  h=findobj(get(ax,'Children'),'flat','Tag','PDEMeshLine');
  set(h,'Erasemode','normal'); set(h,'Erasemode','xor'); delete(h)

  % jiggle the mesh
  jiggleparam=getappdata(pde_fig,'jiggle');
  jiggleopt=deblank(jiggleparam(2,:));
  if strcmp(jiggleopt,'on'),
    jiggleopt='off';
  end
  jiggleiter=deblank(jiggleparam(3,:));
  if isempty(jiggleiter),
    p=jigglemesh(p,e,t,'opt',jiggleopt);
  else
    p=jigglemesh(p,e,t,'opt',jiggleopt,'iter',str2num(jiggleiter));
  end

  meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  h=findobj(get(meshhndl,'Children'),'flat','Tag','PDEUnrefine');
  set(h,'Enable','on');

  % plot the new mesh
  h=pdeplot(p,e,t,'intool','on');
  set(h,'Erasemode','none','Tag','PDEMeshLine');

  set(hp,'UserData',p)

  % if requested, label nodes and/or triangles:
  if getappdata(pde_fig,'shownodelbl'),
    pdetool('shownodelbl',1)
  end
  if getappdata(pde_fig,'showtrilbl'),
    pdetool('showtrilbl',1)
  end

  flags=get(flg_hndl,'UserData');
  flags(1)=1;                           % need_save=1
  flags(5)=1;                           % flag3=1
  flags(6)=0;                           % flag4=0
  set(flg_hndl,'UserData',flags)

  meshstat=getappdata(pde_fig,'meshstat');
  meshstat=[meshstat 3];
  n=length(meshstat);

  setappdata(pde_fig,'meshstat',meshstat);

  % save this generation of the mesh for unrefine purposes
  setappdata(pde_fig,['p' int2str(n)],p);
  setappdata(pde_fig,['e' int2str(n)],e);
  setappdata(pde_fig,['t' int2str(n)],t);

  set(pde_fig,'Pointer','arrow')
  drawnow

  infostr=sprintf('Jiggled mesh consists of %i nodes and %i triangles.',...
    size(p,2),size(t,2));
  pdeinfo(infostr);

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

%
% case: unrefine mesh - undo last mesh change

elseif strcmp(action,'unrefine')

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  end
  flags=get(flg_hndl,'UserData');
  flags(2)=2;                           % mode_flag=2
  set(flg_hndl,'UserData',flags)

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  pdeinfo('Unrefining the mesh...');
  set(pde_fig,'CurrentAxes',ax,'Pointer','watch','WindowButtonDownFcn','')
  drawnow

  pdetool('clearsol')

  % Hide decomposition lines (=subdomain boundaries), boundary lines,
  % labels, and subdomains:
  hKids=get(ax,'Children');
  h=[findobj(hKids,'flat','Tag','PDEBoundLine')'...
          findobj(hKids,'flat','Tag','PDESubLabel')'...
          findobj(hKids,'flat','Tag','PDEEdgeLabel')'...
          findobj(hKids,'flat','Tag','PDESubDom')'...
          findobj(hKids,'flat','Tag','PDEBorderLine')'...
          findobj(hKids,'flat','Tag','PDESelRegion')'];

  set(h,'Erasemode','normal')
  set(h,'Erasemode','xor','Visible','off')

  drawnow

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');

  % erase old mesh
  h=findobj(hKids,'flat','Tag','PDEMeshLine');
  set(h,'Erasemode','normal'); set(h,'Erasemode','xor'); delete(h)

  meshstat=getappdata(pde_fig,'meshstat');
  n=length(meshstat);

  % get previous generation of the mesh
  p=getappdata(pde_fig,['p' int2str(n-1)]);
  e=getappdata(pde_fig,['e' int2str(n-1)]);
  t=getappdata(pde_fig,['t' int2str(n-1)]);

  % plot the unrefined mesh
  h=pdeplot(p,e,t,'intool','on');
  set(h,'Erasemode','none','Tag','PDEMeshLine');

  set(hp,'UserData',p), set(he,'UserData',e), set(ht,'UserData',t)

  % if requested, label nodes and/or triangles:
  if getappdata(pde_fig,'shownodelbl'),
    pdetool('shownodelbl',1)
  end
  if getappdata(pde_fig,'showtrilbl'),
    pdetool('showtrilbl',1)
  end

  flags=get(flg_hndl,'UserData');
  flags(1)=1;                           % need_save=1
  flags(5)=1;                           % flag3=1
  flags(6)=0;                           % flag4=0
  set(flg_hndl,'UserData',flags)

  meshstat=meshstat(1:length(meshstat)-1);
  setappdata(pde_fig,'meshstat',meshstat)

  if length(meshstat)==1,               % Back to initial mesh;
    % no more undo possible
    meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    h=findobj(get(meshhndl,'Children'),'flat','Tag','PDEUnrefine');
    set(h,'Enable','off');
  end

  % Update max no of triangle default for adaptive solver
  % Double the current no, or 1000, whichever is greatest:
  solveparams=getappdata(pde_fig,'solveparam');
  tristr=int2str(max(1.5*size(t,2),1000));
  setappdata(pde_fig,'solveparam',...
    str2mat(solveparams(1,:),tristr,solveparams(3:11,:)))

  set(pde_fig,'Pointer','arrow')
  drawnow

  infostr=sprintf('Current mesh consists of %i nodes and %i triangles.',...
    size(p,2),size(t,2));
  pdeinfo(infostr);

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

%
% case: display triangle quality measure

elseif strcmp(action,'triqual')

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  end
  flags=get(flg_hndl,'UserData');
  flags(2)=2;                           % mode_flag=2
  set(flg_hndl,'UserData',flags)

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');

  set(pde_fig,'CurrentAxes',ax,'Pointer','watch','WindowButtonDownFcn','')
  drawnow

  pdeinfo('Triangle quality plot.');

  drawnow

  % Clean up axes
  h=get(ax,'UserData');
  if ~isempty(h),
    set(h,'Erasemode','xor')
    delete(h)
    set(ax,'UserData',[]);
  end
  set(get(ax,'Children'),'Visible','off')

  cmap=get(get(ax,'YLabel'),'UserData');

  hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  p=get(findobj(get(hndl,'Children'),'flat','Tag','PDEInitMesh'),...
      'UserData');
  t=get(findobj(get(hndl,'Children'),'flat','Tag','PDEMeshParam'),...
      'UserData');

  q=pdetriq(p,t);

  h=pdeplot(p,[],t,'xydata',q,'xystyle','flat','intool','on','mesh','on',...
      'colorbar','off','colormap',cmap,'title','Triangle quality');

  % Store handles to all solution plot patches in PDE Toolbox' axes' UserData.
  set(ax,'UserData',h)

  set(0,'CurrentFigure',pde_fig);

  cmin=min(min(real(q)),0.7);
  cmax=max(max(real(q)),1);
  caxis([cmin cmax]);
  h=colorbar;
  set(h,'Tag','PDESolBar')

  % if requested, label nodes and/or triangles:
  if getappdata(pde_fig,'shownodelbl'),
    pdetool('shownodelbl',1)
  end
  if getappdata(pde_fig,'showtrilbl'),
    pdetool('showtrilbl',1)
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

  pdeinfo;

  edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
  set([edithndl findobj(get(edithndl,'Children'),'flat','Tag','PDESelall')],...
      'Enable','off')

  % Enable clicking on mesh to get info about triangle and node no's:
  set(pde_fig,'WindowButtonDownFcn','pdeinfclk(1)',...
    'WindowButtonUpFcn','if pdeonax, pdeinfo; end')

%
% case: solve PDE

elseif strcmp(action,'solve')

  % if no geometry, create a default L-shape:
  pdegd=get(findobj(get(pde_fig,'Children'),'flat',...
      'Tag','PDEMeshMenu'),'UserData');
  if isempty(pdegd), pdetool('membrane'), end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');
  flag1=flags(3);
  if abs(flag1),
    pdetool('changemode',0)
  end
  flags=get(flg_hndl,'UserData');
  if flags(3)==-1,
    % error in decsg
    return;
  elseif ~flags(2),
    pdetool('cleanup')
  end
  flags=get(flg_hndl,'UserData');
  flag2=flags(4);
  if flag2,
    pdetool('initmesh')
  end
  flags=get(flg_hndl,'UserData');
  oldmode=flags(2);
  flags(2)=3;                           % mode_flag=3
  set(flg_hndl,'UserData',flags)

  pdeinfo('Solving PDE...');
  set(pde_fig,'Pointer','watch')

  drawnow

  bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  bl=get(findobj(get(bndhndl,'Children'),'flat',...
      'Tag','PDEBoundMode'),'UserData');
  dl1=getappdata(pde_fig,'dl1');

  % Unpack parameters:
  params=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEPDEMenu'),...
      'UserData');
  ns=getappdata(pde_fig,'ncafd');
  nc=ns(1); na=ns(2); nf=ns(3); nd=ns(4);
  c=params(1:nc,:);
  a=params(nc+1:nc+na,:);
  f=params(nc+na+1:nc+na+nf,:);
  d=params(nc+na+nf+1:nc+na+nf+nd,:);

  pde_type=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu'),...
      'UserData');

  if pde_type>1,
    timepar=getappdata(pde_fig,'timeeigparam');
    tlist=str2num(deblank(timepar(1,:)));
    u0=deblank(timepar(2,:));
    ut0=deblank(timepar(3,:));
    r=str2num(deblank(timepar(4,:)));
    rtol=str2num(deblank(timepar(5,:)));
    atol=str2num(deblank(timepar(6,:)));
  end

  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
  hp=findobj(get(h,'Children'),'flat','Tag','PDEInitMesh');
  p=get(hp,'UserData');
  he=findobj(get(h,'Children'),'flat','Tag','PDERefine');
  e=get(he,'UserData');
  ht=findobj(get(h,'Children'),'flat','Tag','PDEMeshParam');
  t=get(ht,'UserData');

  solveparams=getappdata(pde_fig,'solveparam');
  adaptflag=str2num(deblank(solveparams(1,:)));
  nonlinflag=str2num(deblank(solveparams(7,:)));
  nltol=str2num(deblank(solveparams(8,:)));
  nlinit=deblank(solveparams(9,:));
  jac=deblank(solveparams(10,:));
  nlinnorm=lower(deblank(solveparams(11,:)));
  if ~strcmp(nlinnorm,'energy'),
    nlinnorm=str2num(nlinnorm);
  end

  err=0;
  % Solve PDE and catch error:
  if pde_type==1,
    % solve elliptic problem:
    if adaptflag,
      maxt=str2num(deblank(solveparams(2,:)));
      ngen=str2num(deblank(solveparams(3,:)));
      tselmet=deblank(solveparams(4,:));
      par=str2num(deblank(solveparams(5,:)));
      refmet=deblank(solveparams(6,:));

      if ~nonlinflag,
        nlin='off';
      else
        nlin='on';
      end
      if isempty(nlinit),
        eval(['[u,p,e,t]=adaptmesh(dl1,bl,c,a,f,''mesh'',p,e,t,',...
          '''par'',par,''ngen'',ngen,''maxt'',maxt,''nonlin'',nlin,',...
          '''toln'',nltol,''tripick'',tselmet,''rmethod'',refmet,',...
          '''jac'',jac,''norm'',nlinnorm);'],'err=1;');
      else
        eval(['[u,p,e,t]=adaptmesh(dl1,bl,c,a,f,''mesh'',p,e,t,',...
          '''par'',par,''ngen'',ngen,''maxt'',maxt,''nonlin'',nlin,',...
          '''toln'',nltol,''init'',nlinit,''tripick'',tselmet,',...
          '''rmethod'',refmet,''jac'',jac,''norm'',nlinnorm);'],'err=1;');
      end
      if ~err,
        set(hp,'UserData',p), set(he,'UserData',e)
        set(ht,'UserData',t)
        % Update max no of triangle default for adaptive solver
        % Double the current no, or 1000, whichever is greatest:
        tristr=int2str(max(1.5*size(t,2),1000));
        setappdata(pde_fig,'solveparam',...
          str2mat(solveparams(1,:),tristr,solveparams(3:11,:)))

        meshstat=getappdata(pde_fig,'meshstat');
        meshstat=[meshstat 4];
        n=length(meshstat);
        setappdata(pde_fig,'meshstat',meshstat);

        % save this generation of the mesh for unrefine purposes
        setappdata(pde_fig,['p' int2str(n)],p);
        setappdata(pde_fig,['e' int2str(n)],e);
        setappdata(pde_fig,['t' int2str(n)],t);

        % Enable 'undo mesh change' option:
        meshhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
        h=findobj(get(meshhndl,'Children'),'flat','Tag','PDEUnrefine');
        set(h,'Enable','on');
      end
    elseif nonlinflag,
      if isempty(nlinit)
        eval(['[u,res]=pdenonlin(bl,p,e,t,c,a,f,''jacobian'',jac,',...
          '''tol'',nltol,''norm'',nlinnorm,''report'',''on'');'],'err=1;');
      else
        eval(['[u,res]=pdenonlin(bl,p,e,t,c,a,f,''jacobian'',jac,',...
          '''tol'',nltol,''U0'',nlinit,''norm'',nlinnorm,',...
          '''report'',''on'');'],'err=1;');
      end
    else
      eval('u=assempde(bl,p,e,t,c,a,f);','err=1;');
    end
    if ~err,
      if any(isnan(u)) && nonlinflag,
        % u contains NaN's if problem is nonlinear and assembled
        % using 'assempde'
        pdeinfo('Switching to nonlinear solver...',0);
        nltol=str2num(deblank(solveparams(8,:)));
        eval('[u,res]=pdenonlin(bl,p,e,t,c,a,f,nltol);','err=1;');
      end
      if any(isnan(u)),
        % if u still contains NaN's, problem is probably time dependent
        pdetool('error','Unable to solve elliptic PDE. Problem may be time dependent or nonlinear.')
        u=[]; l=[];
        set(pde_fig,'Pointer','arrow')
        drawnow
        pdeinfo;
        return;
      end
    end
    l=[];
    pdeinfo('PDE solution computed.');
  elseif pde_type==2,
    % solve parabolic problem:
    eval('u=parabolic(u0,tlist,bl,p,e,t,c,a,f,d,rtol,atol);','err=1;');
    l=[];
    pdeinfo('PDE solution computed.');
  elseif pde_type==3,
    % solve hyperbolic problem:
    eval('u=hyperbolic(u0,ut0,tlist,bl,p,e,t,c,a,f,d,rtol,atol);','err=1;');
    l=[];
    pdeinfo('PDE solution computed.');
  elseif pde_type==4,
    % solve eigenvalue problem:
    eval('[u,l]=pdeeig(bl,p,e,t,c,a,d,r);','err=1;');
    if ~err,
      if isempty(l),
        plthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEPlotMenu');
        set(plthndl,'UserData',u);
        winhndl=findobj(get(pde_fig,'Children'),'flat','Tag','winmenu');
        set(winhndl,'UserData',l);
        pdetool('error',' No eigenvalues in specified range.')
        set(pde_fig,'Pointer','arrow')
        drawnow
        pdeinfo('PDE solution computed.');
      else
        pdeinfo(sprintf('%i eigenvalues found. Use Plot Selection dialog box to select higher eigenmodes.',length(l)));
      end
    end
  end

  % Check if error:
  if err,
    errstr=lasterr;
    % Remove disturbing newlines:
    nl=find(abs(errstr)==10);
    if ~isempty(nl),
      rmnl=[];
      if nl(1)==1,
        rmnl=1;
      end
      nonl=length(nl);
      if nonl>1,
        if nl(nonl)==length(errstr) && nl(nonl-1)==length(errstr)-1,
          rmnl=[rmnl nl(nonl)];
        end
      end
      errstr(rmnl)=[];
    end
    pdetool('error',errstr);
    set(pde_fig,'Pointer','arrow')
    drawnow
    % Restore old mode
    flags=get(flg_hndl,'UserData');
    flags(2)=oldmode;
    set(flg_hndl,'UserData',flags)
    return;
  end

  % Save solution:
  plothndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEPlotMenu');
  set(plothndl,'UserData',u);
  % save eigenvalues:
  winhndl=findobj(get(pde_fig,'Children'),'flat','Tag','winmenu');
  set(winhndl,'UserData',l);

  % Enable export:
  solvehndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDESolveMenu');
  set(findobj(get(solvehndl,'Children'),'flat','Tag','PDEExpSol'),...
      'Enable','on')

  % Set flags
  flags=get(flg_hndl,'UserData');
  flags(5)=0; flags(6)=1; flags(7)=0;   % flag3=0, flag4=1, flag5=0
  set(flg_hndl,'UserData',flags)

  plotflags=getappdata(pde_fig,'plotflags');
  if pde_type==2 || pde_type==3,
    plotflags(12)=size(u,2);
  else
    plotflags(12)=1;
  end
  setappdata(pde_fig,'plotflags',plotflags)

  % Turn off replay of movie
  animparams=getappdata(pde_fig,'animparam');
  animparams(3)=0;
  setappdata(pde_fig,'animparam',animparams)

  % Update plot dialog box:
  pdeptdlg('initialize',1,getappdata(pde_fig,'plotstrings'));

  % flag is set if we're solving from PDEPTDLG. The solution plot
  % will be handled from PDEPTDLG.
  if plotflags(8) && ~isempty(u) && nargin==1,
    % do plot solution automatically:
    pdeptdlg('plot')
  elseif adaptflag && (oldmode==2) && pde_type==1,
    % We're still displaying the old mesh; update it
    pdetool meshmode
  else
    % Restore old mode since we are not plotting solution nor updating:
    flags=get(flg_hndl,'UserData');
    flags(2)=oldmode;
    set(flg_hndl,'UserData',flags)
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

  if pde_type~=4,
    pdeinfo('Select a new plot, or change mode to alter PDE, mesh, or boundaries.');
  end


%
% case: set PDE solution parameters
%       (adaption algorithm/time step/eigenvalue range)

elseif strcmp(action,'solve_param')

  pde_type=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu'),...
      'UserData');

  if pde_type==1,                       % elliptic PDE
    pdesldlg
  elseif pde_type==2,                   % parabolic PDE
    pdetrdlg('parabolic')
  elseif pde_type==3,                   % hyperbolic PDE
    pdetrdlg('hyperbolic')
  elseif pde_type==4,                   % eigenvalue PDE
    pdetrdlg('eigenvalue')
  end

%
% case: membrane (create L-shaped geometry as default if no
%       geometry created; solution in the elliptic case will
%       then resemble MATLAB's 'membrane' logo).

elseif strcmp(action,'membrane')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  mx=max(max(get(ax,'XLim')),max(get(ax,'YLim')));
  l=10^(floor(log10(mx)));
  pdepoly([-l, l, l, 0, 0, -l],...
      [-l, -l, l, l, 0, 0])

%
% case: zoom

elseif strcmp(action,'zoom')

  drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
  opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
  zoomhndl=findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom');

  if btnstate(pde_fig,'zoom',1) && strcmp(get(zoomhndl,'Checked'),'off'),
    set(zoomhndl,'Checked','on');
  elseif btnstate(pde_fig,'zoom',1) && strcmp(get(zoomhndl,'Checked'),'on'),
    set(zoomhndl,'Checked','off');
    btnup(pde_fig,'zoom',1)
  elseif ~btnstate(pde_fig,'zoom',1) && strcmp(get(zoomhndl,'Checked'),'on'),
    set(zoomhndl,'Checked','off');
  elseif ~btnstate(pde_fig,'zoom',1) && strcmp(get(zoomhndl,'Checked'),'off'),
    set(zoomhndl,'Checked','on');
    btndown(pde_fig,'zoom',1)
  end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if btnstate(pde_fig,'zoom',1),

    pdeinfo('Click (+drag) to zoom. Double-click to restore.');

    % save WindowButtonDownFcn and WindowButtonUpFcn before invoking zoom:
    setappdata(pde_fig,'WinBtnDownFcn',get(pde_fig,'WindowButtonDownFcn'))
    setappdata(pde_fig,'WinBtnUpFcn',get(pde_fig,'WindowButtonUpFcn'))
    setappdata(ax,'armodes',...
	{get(ax,'DataAspectRatioMode'), get(ax,'PlotBoxAspectRatioMode')})
    set(ax,'DataAspectRatioMode','auto',...
	'PlotBoxAspectRatioMode','auto');
    pdezoom(pde_fig,'on')

  else

    armodes = getappdata(ax,'armodes');
    set(ax,'DataAspectRatioMode',armodes{1},...
	'PlotBoxAspectRatioMode',armodes{2});
    pdezoom(pde_fig,'off')
    % restore WindowButtonDownFcn and WindowButtonUpFcn:
    set(pde_fig,'WindowButtonDownFcn',getappdata(pde_fig,'WinBtnDownFcn'),...
    'WindowButtonUpFcn',getappdata(pde_fig,'WinBtnUpFcn'))
    pdeinfo('Zoom turned off.');

  end

%
% case: change mode

elseif strcmp(action,'changemode')

  pde_kids = allchild(pde_fig);
  flg_hndl=findobj(pde_kids,'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData');

  mode_flag=flags(2);

  % case: draw mode --> draw mode. Do nothing.
  if flag==1 && mode_flag==0,
    return;
  end

  pdegd=get(findobj(pde_kids,'flat',...
      'Tag','PDEMeshMenu'),'UserData');

  % if no geometry, alert user and return:
  if isempty(pdegd), pdetool('error','  No geometry data.'), return, end

  if btnstate(pde_fig,'zoom',1),
    pdezoom(pde_fig,'off')
    btnup(pde_fig,'zoom',1)
    pde_kids=get(pde_fig,'Children');
    opthndl=findobj(pde_kids,'flat','Tag','PDEOptMenu');
    set(findobj(get(opthndl,'Children'),'flat','Tag','PDEZoom'),...
        'Checked','off')
  end

  pde_kids=get(pde_fig,'Children');
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');
  axKids=get(ax,'Children');
  set(pde_fig,'Currentaxes',ax)

  if ~mode_flag,
    % transition: draw mode -> boundary mode

    flg_hndl=findobj(pde_kids,'flat','Tag','PDEFileMenu');
    flags=get(flg_hndl,'UserData');

    mode_flag=1;
    flag1=flags(3);

    if abs(flag1),
      % delete mesh lines, decomposition lines, and subdomains:
      hndl=[findobj(axKids,'flat','Tag','PDEBorderLine')'...
              findobj(axKids,'flat','Tag','PDEBoundLine')'...
              findobj(axKids,'flat','Tag','PDEMeshLine')'...
              findobj(axKids,'flat','Tag','PDESubDom')'...
              findobj(axKids,'flat','Tag','PDESelRegion')'];
      delete(hndl)
    end

    axKids=get(ax,'Children');
    objects=[findobj(axKids,'flat',...
            'Tag','PDELabel','Visible','on')'...
            findobj(axKids,'flat','Tag','PDELblSel',...
            'Visible','on')'];
    n=length(objects);
    ns=getappdata(pde_fig,'objnames');

    pdetool formchk

    evalhndl=findobj(pde_kids,'flat','Tag','PDEEval');
    evalstring=get(evalhndl,'String');

    set(pde_fig,'Pointer','watch');
    drawnow
    % first call DECSG to decompose geometry;
    % reject if evaluation string is bad
    [dl1,bt1,dl,bt,msb]=decsg(pdegd,evalstring,ns);
    setappdata(pde_fig,'msb',msb);

    % error out here if 'eval string'-error (decsg then returns a NaN)
    if isnan(dl),
      set(pde_fig,'Pointer','arrow');
      drawnow
      pdetool('error','  Unable to evaluate set formula')
      pdetool('changemode',1)
      flags=get(flg_hndl,'UserData');
      flags(3)=-1; set(flg_hndl,'UserData',flags)
      return;
    elseif isempty(dl),
      set(pde_fig,'Pointer','arrow');
      drawnow
      pdetool('error','  Set formula results in empty geometry')
      pdetool('changemode',1)
      flags=get(flg_hndl,'UserData');
      flags(3)=-1; set(flg_hndl,'UserData',flags)
      return;
    end
    set(findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEBoundMenu'),'UserData',dl);

    setappdata(pde_fig,'dl1',dl1)
    setappdata(pde_fig,'bt1',bt1)

    % compute new coarse initmesh for labeling purposes
    [pinit2,einit2,tinit2]=initmesh(dl1,'hmax',Inf,'init','on');
    setappdata(pde_fig,'pinit2',pinit2)
    setappdata(pde_fig,'tinit2',tinit2)

    pdetool('cleanup')

    pdeinfo('Click to select boundaries. Double-click to open boundary condition dialog box.');

    pdetool('drawbounds')

    bndhndl=findobj(pde_kids,'flat','Tag','PDEBoundMenu');
    set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEExpBound'),...
        'Enable','on');

    % Reset PDE coefficients:
    currcoeff=getappdata(pde_fig,'currparam');
    newcoeff=strtok(currcoeff(1,:),'!');
    for j=2:size(currcoeff,1),
      newcoeff=str2mat(newcoeff,strtok(currcoeff(j,:),'!'));
    end
    setappdata(pde_fig,'currparam',newcoeff);
    appl=getappdata(pde_fig,'application');
    stdparam=pdetrans(newcoeff,appl);
    coeffh=findobj(pde_kids,'flat','Tag','PDEPDEMenu');
    set(coeffh,'UserData',stdparam)

    set(pde_fig,'WindowButtonDownFcn','',...
                'WindowButtonMotionFcn','pdemtncb(0)',...
                'WindowButtonUpFcn','',...
                'Pointer','arrow');
    drawnow

    % enable removal of interior subdomain boundaries
    menuhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
    hbound(1)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemBord');
    hbound(2)=findobj(get(menuhndl,'Children'),'flat','Tag','PDERemAllBord');
    set(hbound,'Enable','on')

    if abs(flag1),
      flag1=0; flag2=1; flag4=0; flag6=1;
      flags=[flags(1) mode_flag flag1 flag2 flags(5) flag4 flags(7)]';
    else
      flags=[flags(1) mode_flag flag1 flags(4:7)']';
    end
    set(flg_hndl,'UserData',flags)

  elseif mode_flag,
    % transition: 'solve modes' -> draw mode

    mode_flag=0;

    set(pde_fig,'Pointer','watch')
    drawnow
    pdeinfo('Continue drawing or edit set formula.');

    hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
    set(hndl,'Enable','on');

    % hide mesh lines, decomposition lines, subdomains, and labels:
    hndl=[findobj(axKids,'flat','Tag','PDEBorderLine')'...
            findobj(axKids,'flat','Tag','PDEBoundLine')'...
            findobj(axKids,'flat','Tag','PDEMeshLine')'...
            findobj(axKids,'flat','Tag','PDESubDom')'...
            findobj(axKids,'flat','Tag','PDESubLabel')'...
            findobj(axKids,'flat','Tag','PDEEdgeLabel')'...
            findobj(axKids,'flat','Tag','PDEENodeLabel')'...
            findobj(axKids,'flat','Tag','PDEETriLabel')'...
            findobj(axKids,'flat','Tag','PDESelRegion')'];
    set(hndl,'Erasemode','xor','Visible','off')

    set(pde_fig,'WindowButtonDownFcn','pdeselect select');

    delete(getappdata(pde_fig,'trihandles'))
    delete(getappdata(pde_fig,'nodehandles'))
    setappdata(pde_fig,'trihandles',[])
    setappdata(pde_fig,'nodehandles',[])

    delete(findobj(get(pde_fig,'Children'),'flat','Tag','PDESolBar'))

    h=get(ax,'UserData');
    if ~isempty(h),
      set(h,'Erasemode','xor')
      delete(h)
      set(ax,'UserData',[]);
    end

    set(get(ax,'Title'),'String','');

    set(ax,'Position',getappdata(ax,'axstdpos'));

    set(pde_fig,'Colormap',get(get(ax,'Xlabel'),'UserData'));

    % turn the geometry objects back on
    axKids=get(ax,'Children');
    hndl=findobj(axKids,'flat','Tag','PDEMinReg');
    set(hndl,'Erasemode','none','Visible','on')
    hndl=[findobj(axKids,'flat','Tag','PDELine')'...
            findobj(axKids,'flat','Tag','PDESelFrame')'...
            findobj(axKids,'flat','Tag','PDELabel')'...
            findobj(axKids,'flat','Tag','PDELblSel')'];
    set(hndl,'Erasemode','background','Visible','on')

    edithndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEditMenu');
    set(edithndl,'Enable','on')
    set(findobj(get(edithndl,'Children'),'flat','Tag','PDESelall'),...
        'Enable','on','CallBack','pdeselect(''select'',1)')
    bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
    set(findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec'),...
        'UserData',[]);

    % enable edit menu items:
    editkids=get(edithndl,'Children');
    hndls=[findobj(editkids,'flat','Tag','PDECut')...
            findobj(editkids,'flat','Tag','PDECopy')...
            findobj(editkids,'flat','Tag','PDEClear')];
    set(hndls,'Enable','on')

    % enable 'Rotate...':
    drawhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEDrawMenu');
    set(findobj(get(drawhndl,'Children'),'flat','Tag','PDERotate'),...
        'Enable','on')

    clipboard=get(findobj(editkids,'flat','Tag','PDECut'),'UserData');
    if ~isempty(clipboard),
      set(findobj(editkids,'flat','Tag','PDEPaste'),'Enable','on')
    end

    flags=[flags(1) mode_flag flags(3:7)']';
    set(flg_hndl,'UserData',flags)

    pdetool refresh

    set(pde_fig,'Pointer','arrow')
    drawnow

  else

    pdetool('error',' No 2-D geometry available');

  end

%
% case: clean up draw-mode features. Called from 'changemode' and
%       when entering a solve mode action through a short-cut path.

elseif strcmp(action,'cleanup')

  pde_kids = allchild(pde_fig);
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');

  % reset pushed draw button at mode change
  btst=btnstate(pde_fig,'draw');
  drawhndl=findobj(pde_kids,'flat','Tag','PDEDrawMenu');
  h=[findobj(get(drawhndl,'Children'),'flat','Tag','PDERect')...
          findobj(get(drawhndl,'Children'),'flat','Tag','PDERectc')...
          findobj(get(drawhndl,'Children'),'flat','Tag','PDEEllip')...
          findobj(get(drawhndl,'Children'),'flat','Tag','PDEEllipc')...
          findobj(get(drawhndl,'Children'),'flat','Tag','PDEPoly')];
  for i=find(btst), btnup(pde_fig,'draw',i), set(h(i),'Checked','off'), end

  axKids=get(ax,'Children');
  lines=findobj(axKids,'flat','Tag','PDELine');
  % Erase any unfinished polygon lines
  if ~isempty(lines),
    set(lines,'Erasemode','normal'), set(lines,'Erasemode','xor')
    delete(lines)
    user_data=get(pde_fig,'UserData');
    user_data=[user_data(1:4) zeros(1,4)];
    set(pde_fig,'UserData',user_data)
  end

  % disable 'Rotate...':
  set(findobj(get(drawhndl,'Children'),'flat','Tag','PDERotate'),...
      'Enable','off')

  evalhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
  set(evalhndl,'Enable','off');

  % disable edit menu items:
  edithndl=findobj(pde_kids,'flat','Tag','PDEEditMenu');
  hndls=[findobj(get(edithndl,'Children'),'flat','Tag','PDEUndo')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDECut')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDECopy')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDEPaste')...
          findobj(get(edithndl,'Children'),'flat','Tag','PDEClear')];
  set(hndls,'Enable','off')

  % turn off the drawing objects:
  axKids=get(ax,'Children');
  hndl=[findobj(axKids,'flat','Tag','PDEMinReg')'...
          findobj(axKids,'flat','Tag','PDELine')'...
          findobj(axKids,'flat','Tag','PDESelFrame')'...
          findobj(axKids,'flat','Tag','PDELabel')'...
          findobj(axKids,'flat','Tag','PDELblSel')'];
  set(hndl,'Erasemode','xor','Visible','off')

  % change colormap:
  set(pde_fig,'Colormap',get(get(ax,'Ylabel'),'UserData'))

  % turn off WindowButtonDownFcn
  set(pde_fig,'WindowButtonDownFcn','');

%
%
% case: draw the internal and external boundary segments

elseif strcmp(action,'drawbounds')

  flg_hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(flg_hndl,'UserData'); flag1=flags(3);

  pde_kids = allchild(pde_fig);
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');

  dl1=getappdata(pde_fig,'dl1');
  bounds=[find(dl1(7,:)==0) find(dl1(6,:)==0)];

  pde_circ=1;
  pde_poly=2;
  pde_ellip=4;

  % Allright, if pdebound empty or if the geometry has changed (flag1=1),
  % initialize the boundary conditions to
  % dirichlet cond, u=0.0 on all boundaries:
  bndhndl=findobj(pde_kids,'flat','Tag','PDEBoundMenu');
  h=findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundMode');
  pdebound=get(h,'UserData');

  appl=getappdata(pde_fig,'application');
  scalarflag=any(appl<2 | appl>4);

  if isempty(pdebound) || flag1,
    pdetool('initbounds',scalarflag)
    pdebound=get(h,'UserData');
  end

  % draw the decomposed boundaries:

  set(pde_fig,'CurrentAxes',ax)

  polys=find(dl1(1,:)==pde_poly);
  if ~isempty(polys),
    n1=length(polys); n2=length(bounds);
    col=0.5*ones(n1,3);
    tmp1=bounds(find(max(~(ones(n1,1)*bounds-(ones(n2,1)*polys)'))));
    n3=length(tmp1);
    if n3==0
      tmp=[];
    elseif n3==1
      tmp=find(polys==tmp1);
    else
      tmp=find(max(~(ones(n3,1)*polys-(ones(n1,1)*tmp1)')));
    end

    if scalarflag,
      dir=find(pdebound(2,polys(tmp))==1);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,polys(tmp))==0);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=[];
    else
      dir=find(pdebound(2,polys(tmp))==2);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,polys(tmp))==0);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=find(pdebound(2,polys(tmp))==1);
      m=length(mix);
      col(tmp(mix),:)=[zeros(m,1) ones(m,1) zeros(m,1)];
    end

    for i=1:n1,
      if isempty(find(bounds==polys(i))),
        line(dl1(2:3,polys(i)),...
            dl1(4:5,polys(i)),'Tag','PDEBorderLine',...
            'ButtonDownFcn','pdetool(''bordclk'')',...
            'Parent',ax,...
            'Color',col(i,:),'EraseMode','background','UserData',polys(i));
      else
        % make the boundary lines into arrows to indicate direction
        xl = get(ax,'xlim');
        yl = get(ax,'ylim');
        xd = xl(2)-xl(1);       % this sets the scale for the arrow size
        yd = yl(2)-yl(1);       % thus enabling the arrow to appear in correct
        scale = (xd + yd) / 2;  % proportion to the current axis

        start(1)=dl1(2,polys(i));
        start(2)=dl1(4,polys(i));
        stop(1)=dl1(3,polys(i));
        stop(2)=dl1(5,polys(i));

        xdif = stop(1) - start(1);
        ydif = stop(2) - start(2);

        theta = atan2(ydif,xdif);       % the angle has to point according to
        % the slope
        xx = [start(1),stop(1),...
                (stop(1)+0.02*scale*cos(theta+3*pi/4)),NaN,stop(1),...
                (stop(1)+0.02*scale*cos(theta-3*pi/4))]';
        yy = [start(2),stop(2),...
                (stop(2)+0.02*scale*sin(theta+3*pi/4)),NaN,stop(2),...
                (stop(2)+0.02*scale*sin(theta-3*pi/4))]';

        line(xx,yy,'Tag','PDEBoundLine',...
            'Parent',ax,...
            'Color',col(i,:),'EraseMode','background',...
            'ButtonDownFcn','pdetool(''boundclk'')',...
            'UserData',[polys(i) col(i,:)]);

      end
    end
  end

  % draw the decomposed geometry 2 (circles)
  circles=find(dl1(1,:)==pde_circ);
  if ~isempty(circles),
    n1=length(circles); n2=length(bounds);
    col=0.5*ones(n1,3);
    if n1==1,
      tmp1=find(bounds==circles);
    else
      tmp1=bounds(find(max(~(ones(n1,1)*bounds-(ones(n2,1)*circles)'))));
    end
    n3=length(tmp1);
    if n3==0
      tmp=[];
    elseif n3==1,
      if n1==1,
        tmp=1;
      else
        tmp=find(circles==tmp1);
      end
    else
      tmp=find(max(~(ones(n3,1)*circles-(ones(n1,1)*tmp1)')));
    end
    if scalarflag,
      dir=find(pdebound(2,circles(tmp))==1);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,circles(tmp))==0);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=[];
    else
      dir=find(pdebound(2,circles(tmp))==2);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,circles(tmp))==1);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=find(pdebound(2,circles(tmp))==0);
      m=length(mix);
      col(tmp(mix),:)=[zeros(m,1) ones(m,1) zeros(m,1)];
    end

    delta=2*pi/100;
    for i=1:n1,
      arg1=atan2(dl1(4,circles(i))-dl1(9,circles(i)),...
          dl1(2,circles(i))-dl1(8,circles(i)));
      arg2=atan2(dl1(5,circles(i))-dl1(9,circles(i)),...
          dl1(3,circles(i))-dl1(8,circles(i)));
      if arg2<0 && arg1>0, arg2=arg2+2*pi; end
      darg=abs(arg2-arg1);
      ns=max(2,ceil(darg/delta));
      arc=linspace(arg1,arg2,ns);
      x(1:ns)=(dl1(8,circles(i))+dl1(10,circles(i))*cos(arc))';
      y(1:ns)=(dl1(9,circles(i))+dl1(10,circles(i))*sin(arc))';
      if isempty(find(bounds==circles(i))),
        line(x(1:ns),y(1:ns),'Tag','PDEBorderLine',...
            'Color',col(i,:),'EraseMode','background',...
            'Parent',ax,...
            'ButtonDownFcn','pdetool(''bordclk'')',...
            'UserData',circles(i));
      else
        % make the boundary lines into arrows to indicate direction
        xl = get(ax,'xlim');
        yl = get(ax,'ylim');
        xd = xl(2)-xl(1);       % this sets the scale for the arrow size
        yd = yl(2)-yl(1);       % thus enabling the arrow to appear in correct
        scale = (xd + yd) / 2;  % proportion to the current axis

        start(1)=x(ns-1);
        start(2)=y(ns-1);
        stop(1)=x(ns);
        stop(2)=y(ns);

        xdif = stop(1) - start(1);
        ydif = stop(2) - start(2);

        theta = atan2(ydif,xdif);       % the angle has to point
        % according to the slope
        xx = [x(1:ns),(stop(1)+0.02*scale*cos(theta+3*pi/4)),NaN,...
                stop(1),(stop(1)+0.02*scale*cos(theta-3*pi/4))]';
        yy = [y(1:ns), (stop(2)+0.02*scale*sin(theta+3*pi/4)),NaN,...
                stop(2),(stop(2)+0.02*scale*sin(theta-3*pi/4))]';

        line(xx,yy,'Tag','PDEBoundLine',...
            'Color',col(i,:),'EraseMode','background',...
            'Parent',ax,...
            'ButtonDownFcn','pdetool(''boundclk'')',...
            'UserData',[circles(i) col(i,:)]);

      end
    end
  end

  % draw the decomposed geometry 3 (ellipses)
  ellipses=find(dl1(1,:)==pde_ellip);
  if ~isempty(ellipses),
    n1=length(ellipses); n2=length(bounds);
    col=0.5*ones(n1,3);
    if n1==1,
      tmp1=find(bounds==ellipses);
    else
      tmp1=bounds(find(max(~(ones(n1,1)*bounds-(ones(n2,1)*ellipses)'))));
    end
    n3=length(tmp1);
    if n3==0
      tmp=[];
    elseif n3==1
      if n1==1,
        tmp=1;
      else
        tmp=find(ellipses==tmp1);
      end
    else
      tmp=find(max(~(ones(n3,1)*ellipses-(ones(n1,1)*tmp1)')));
    end
    if scalarflag,
      dir=find(pdebound(2,ellipses(tmp))==1);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,ellipses(tmp))==0);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=[];
    else
      dir=find(pdebound(2,ellipses(tmp))==2);
      m=length(dir);
      col(tmp(dir),:)=[ones(m,1) zeros(m,2)];
      neu=find(pdebound(2,ellipses(tmp))==1);
      m=length(neu);
      col(tmp(neu),:)=[zeros(m,2) ones(m,1)];
      mix=find(pdebound(2,ellipses(tmp))==0);
      m=length(mix);
      col(tmp(mix),:)=[zeros(m,1) ones(m,1) zeros(m,1)];
    end

    delta=2*pi/100;
    for i=1:n1,
      k=ellipses(i);
      ca=cos(dl1(12,k)); sa=sin(dl1(12,k));
      yd=dl1(4,k)-dl1(9,k);
      xd=dl1(2,k)-dl1(8,k);
      x1=ca.*xd+sa.*yd;
      y1=-sa.*xd+ca.*yd;
      arg1=atan2(y1./dl1(11,k),x1./dl1(10,k));
      yd=dl1(5,k)-dl1(9,k);
      xd=dl1(3,k)-dl1(8,k);
      x1=ca.*xd+sa.*yd;
      y1=-sa.*xd+ca.*yd;
      arg2=atan2(y1./dl1(11,k),x1./dl1(10,k));
      if arg2<0 && arg1>0, arg2=arg2+2*pi; end
      darg=abs(arg2-arg1);
      ns=max(2,ceil(darg/delta));
      arc=linspace(arg1,arg2,ns);
      xd=(dl1(10,k)*cos(arc))';
      yd=(dl1(11,k)*sin(arc))';
      x1=ca*xd-sa*yd;
      y1=sa*xd+ca*yd;
      x(1:ns)=dl1(8,k)+x1;
      y(1:ns)=dl1(9,k)+y1;
      if isempty(find(bounds==k)),
        h=line(x(1:ns),y(1:ns),zeros(1,ns),'Tag','PDEBorderLine',...
            'Color',col(i,:),'EraseMode','background',...
            'Parent',ax,...
            'ButtonDownFcn','pdetool(''bordclk'')',...
            'UserData',k);
      else
        % make the boundary lines into arrows to indicate direction
        xl = get(ax,'xlim');
        yl = get(ax,'ylim');
        xd = xl(2)-xl(1);       % this sets the scale for the arrow size
        yd = yl(2)-yl(1);       % thus enabling the arrow to appear in correct
        scale = (xd + yd) / 2;  % proportion to the current axis

        start(1)=x(ns-1);
        start(2)=y(ns-1);
        stop(1)=x(ns);
        stop(2)=y(ns);

        xdif = stop(1) - start(1);
        ydif = stop(2) - start(2);

        theta = atan2(ydif,xdif);       % the angle has to point
        % according to the slope
        xx = [x(1:ns),(stop(1)+0.02*scale*cos(theta+3*pi/4)),NaN,...
                stop(1),(stop(1)+0.02*scale*cos(theta-3*pi/4))]';
        yy = [y(1:ns), (stop(2)+0.02*scale*sin(theta+3*pi/4)),NaN,...
                stop(2),(stop(2)+0.02*scale*sin(theta-3*pi/4))]';

        h=line(xx,yy,zeros(size(xx)),'Tag','PDEBoundLine',...
            'Color',col(i,:),'EraseMode','background',...
            'Parent',ax,...
            'ButtonDownFcn','pdetool(''boundclk'')',...
            'UserData',[k col(i,:)]);
      end
    end
  end


%
% case: click on boundary to select boundary and
%       open boundary condition dialog box

elseif strcmp(action,'boundclk')

  % if in Zoom-mode, let Zoom do its thing and return immediately
  if btnstate(pde_fig,'zoom',1), return, end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
  selecth=findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec');

  % case: select all (flag is set)
  if nargin>1
    hndl=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
    if ~isempty(hndl)
      set(hndl,'color','k');
      set(selecth,'UserData',hndl');
    end

    % case: double-click to open boundary condition dialog box
  elseif findstr(get(pde_fig,'SelectionType'),'open'),

    pdetool('set_bounds')

    % case: shift-click (allow selection of more than one boundary segment)
  elseif findstr(get(pde_fig,'SelectionType'),'extend'),

    curr_bound=gco;
    set(curr_bound,'color','k')

    pde_bound_sel=get(selecth,'UserData');
    if isempty(pde_bound_sel) || isempty(find(curr_bound==pde_bound_sel)),
      pde_bound_sel=[pde_bound_sel curr_bound];
    else
      % if already selected, de-select
      selcol=find(pde_bound_sel==curr_bound);
      pde_bound_sel=[pde_bound_sel(1:selcol-1) ...
              pde_bound_sel(selcol+1:length(pde_bound_sel))];
      col=get(curr_bound,'UserData');
      set(curr_bound,'color',col(2:4))
    end

    set(selecth,'UserData',pde_bound_sel)

    % case: select
  else
    % if already selected, do nothing; else, select
    curr_bound=gco;

    pde_bound_sel=get(selecth,'UserData');
    if isempty(pde_bound_sel) || isempty(find(pde_bound_sel==curr_bound))
      set(curr_bound,'color','k')
      bounds=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
      indx=find(bounds~=curr_bound)';
      for i=indx
        col=get(bounds(i),'UserData');
        set(bounds(i),'color',col(2:4))
      end
      set(selecth,'UserData',curr_bound);
    end
  end

%
% case: click on subdomain border to select border

elseif strcmp(action,'bordclk')

  % if in Zoom-mode, let Zoom do its thing and return immediately
  if btnstate(pde_fig,'zoom',1), return, end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  border_sel=getappdata(ax,'bordsel');

  % case: shift-click (allow selection of more than one border segment)
  if findstr(get(pde_fig,'SelectionType'),'extend'),

    curr_border=gco;
    set(curr_border,'color','k')

    if isempty(border_sel)
      border_sel = curr_border;
    else
      if isempty(find(curr_border==border_sel)),
        border_sel=[border_sel curr_border];
      else
        % if already selected, de-select
        selcol=find(border_sel==curr_border);
        border_sel=[border_sel(1:selcol-1) ...
              border_sel(selcol+1:length(border_sel))];
        set(curr_border,'color',0.5*ones(1,3))
      end
    end

    setappdata(ax,'bordsel',border_sel)

    % case: select
  elseif findstr(get(pde_fig,'SelectionType'),'normal'),
    % if already selected, do nothing; else, select
    curr_border=gco;

    if isempty(border_sel) || isempty(find(border_sel==curr_border))
      set(curr_border,'color','k')
      borders=findobj(get(ax,'Children'),'flat','Tag','PDEBorderLine');
      indx=find(borders~=curr_border)';
      set(borders(indx),'color',0.5*ones(1,3))
      setappdata(ax,'bordsel',curr_border)
    end
  end

%
% case: click in subdomain to select subdomain and to define PDE coefficients

elseif strcmp(action,'subclk')

  % if in Zoom-mode, let Zoom do its thing and return immediately
  if btnstate(pde_fig,'zoom',1), return, end

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  if ~pdeonax(ax) && nargin==1, return; end
  set(pde_fig,'CurrentAxes',ax)

  subsel=getappdata(ax,'subsel');
  dl1=getappdata(pde_fig,'dl1');
  hndl=findobj(get(ax,'Children'),'flat','Tag','PDESelRegion');

  p1=getappdata(pde_fig,'pinit2');
  t1=getappdata(pde_fig,'tinit2');
  pv=get(ax,'CurrentPoint');
  x=pv(1,1); y=pv(1,2);
  [uxy,tn,a2,a3]=tri2grid(p1,t1,zeros(size(p1,2)),x,y);

  % case: select all (flag is set)
  if nargin>1
    if ~isempty(hndl)
      bt1=getappdata(pde_fig,'bt1');
      set(hndl,'color','k')
      setappdata(ax,'subsel',1:size(bt1,1))
    end

    % case: double-click to open PDE Specification dialog box
  elseif findstr(get(pde_fig,'SelectionType'),'open'),

    if ~isnan(tn),
      pdetool('set_param')
    end

    % case: shift-click (allow selection of more than one subdomain)
  elseif findstr(get(pde_fig,'SelectionType'),'extend'),

    if isnan(tn),
      % clicked outside of geometry objects: deselect all
      set(hndl,'color','w')
      setappdata(ax,'subsel',[])
      return;
    else
      subreg=t1(4,tn);
    end

    s=find(dl1(6,:)==subreg | dl1(7,:)==subreg);
    h=[];
    for i=1:length(s),
      h=[h; findobj(hndl,'flat','UserData',s(i))];
    end
    if isempty(subsel) || isempty(find(subsel==subreg)),
      subsel=[subsel subreg];
      set(h,'color','k')
    else
      % if already selected, de-select
      selcol=find(subsel==subreg);
      subsel=[subsel(1:selcol-1) ...
              subsel(selcol+1:length(subsel))];
      set(h,'color','w')
    end

    setappdata(ax,'subsel',subsel)

    % case: select
  else
    % if already selected, do nothing; else, select

    if isnan(tn),
      % clicked outside of geometry objects: deselect all
      set(hndl,'color','w')
      setappdata(ax,'subsel',[])
      return;
    else
      subreg=t1(4,tn);
    end

    s=find(dl1(6,:)==subreg | dl1(7,:)==subreg);
    h=[];
    for i=1:length(s),
      h=[h; findobj(hndl,'flat','UserData',s(i))];
    end
    if isempty(subsel) || isempty(find(subsel==subreg)),
      set(hndl,'color','w')
      set(h,'color','k')
      setappdata(ax,'subsel',subreg);
    end
  end

%
% case: remove border (flag=1: remove all borders)

elseif strcmp(action,'removeb')

  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  set(pde_fig,'CurrentAxes',ax,'Pointer','watch')
  drawnow

  dl1=getappdata(pde_fig,'dl1');
  bt1=getappdata(pde_fig,'bt1');

  if nargin>1,
    if flag==-1,
      % Case: remove all borders
      bl=find([dl1(6,:)~=0 & dl1(7,:)~=0]);
      if isempty(bl),
        set(pde_fig,'Pointer','arrow')
        drawnow
        return;
      end
      [dl1,bt1]=csgdel(dl1,bt1);
    else
      % flag contains bl; used from startup-file only
      bl=flag;
      [dl1,bt1]=csgdel(dl1,bt1,bl);
    end
  else
    bdsel=getappdata(ax,'bordsel');
    if isempty(bdsel),
      set(pde_fig,'Pointer','arrow')
      drawnow
      return;
    end
    n=length(bdsel);
    bl=[];
    for i=1:n,
      bl=[bl get(bdsel(i),'UserData')];
    end
    [dl1new,bt1new]=csgdel(dl1,bt1,bl);
    if (size(dl1new,2)==size(dl1,2)),
      set(pde_fig,'Pointer','arrow')
      drawnow
      return;
    else
      dl1=dl1new; bt1=bt1new;
    end
  end

  blsaved=getappdata(pde_fig,'bl');
  if ~isempty(bl),
    i=size(blsaved,1)+1;
    blsaved(i,1:size(bl,2))=bl;
    setappdata(pde_fig,'bl',blsaved)
  end

  % save new dl1, bt1
  setappdata(pde_fig,'dl1',dl1)
  setappdata(pde_fig,'bt1',bt1)

  % compute new coarse initmesh for labeling purposes
  [pinit2,einit2,tinit2]=initmesh(dl1,'hmax',Inf,'init','on');
  setappdata(pde_fig,'pinit2',pinit2)
  setappdata(pde_fig,'tinit2',tinit2)

  % Set flag 2 to force new mesh initialization:
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData');
  flags(4)=1;
  set(h,'UserData',flags)

  setappdata(ax,'bordsel',[])

  hh=[findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine')'...
          findobj(get(ax,'Children'),'flat','Tag','PDEBorderLine')'];
  set(hh,'Erasemode','normal'), set(hh,'Erasemode','xor')
  delete(hh)

  appl=getappdata(pde_fig,'application');
  scalarflag=any(appl<2 | appl>4);
  pdetool('initbounds',scalarflag)

  pdetool('drawbounds')

  if getappdata(pde_fig,'showsublbl'),
    pdetool('showsublbl',1)
  else
    pdetool('showsublbl',0)
  end
  if getappdata(pde_fig,'showedgelbl'),
    pdetool('showedgelbl',1)
  else
    pdetool('showedgelbl',0)
  end

  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: clear solution plot from PDE axes

elseif strcmp(action,'clearsol')

  %if solution display is left on screen, remove it.
  h=findobj(get(pde_fig,'Children'),'flat','Tag','PDESolBar');
  if ~isempty(h),
    delete(h);
  end
  ax=findobj(allchild(pde_fig),'flat','Tag','PDEAxes');
  hh=get(ax,'UserData');
  if ~isempty(hh),
    set(hh,'Erasemode','xor')
    delete(hh)
  end
  set(ax,'UserData',[],'Position',getappdata(ax,'axstdpos'))
  titleh=get(ax,'Title');
  if ~isempty(get(titleh,'String')),
    set(titleh,'String','')
  end

%
% case: export variables to workspace

elseif strcmp(action,'export')

  if flag==1,
    % export geometry data:
    gd=get(findobj(get(pde_fig,'Children'),'flat',...
        'Tag','PDEMeshMenu'),'UserData');
    ns=getappdata(pde_fig,'objnames');
    evalhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
    sf=get(evalhndl,'String');
    matqueue('put',gd,sf,ns)
    pstr='Variable names for geometry data, set formula, labels:';
    estr='gd sf ns';
  elseif flag==2,
    % export decomposed list, boundary conditions:
    dl1=getappdata(pde_fig,'dl1');
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');
    bl=get(findobj(get(h,'Children'),'flat',...
        'Tag','PDEBoundMode'),'UserData');
    matqueue('put',dl1,bl)
    pstr='Variable names for decomposed geometry, boundary cond''s:';
    estr='g b';
  elseif flag==3,
    % export mesh:
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEMeshMenu');
    p=get(findobj(get(h,'Children'),'flat','Tag','PDEInitMesh'),...
        'UserData');
    e=get(findobj(get(h,'Children'),'flat','Tag','PDERefine'),...
        'UserData');
    t=get(findobj(get(h,'Children'),'flat','Tag','PDEMeshParam'),...
        'UserData');
    matqueue('put',p,e,t)
    pstr='Variable names for mesh data (points, edges, triangles):';
    estr='p e t';
  elseif flag==4,
    % export PDE coefficients:
    params=get(findobj(get(pde_fig,'Children'),'Tag','PDEPDEMenu'),...
        'UserData');
    ns=getappdata(pde_fig,'ncafd');
    nc=ns(1); na=ns(2); nf=ns(3); nd=ns(4);
    c=params(1:nc,:);
    a=params(nc+1:nc+na,:);
    f=params(nc+na+1:nc+na+nf,:);
    d=params(nc+na+nf+1:nc+na+nf+nd,:);
    matqueue('put',c,a,f,d)
    pstr='Variable names for PDE coefficients:';
    estr='c a f d';
  elseif flag==5,
    % export solution:
    u=get(findobj(get(pde_fig,'Children'),'flat','Tag','PDEPlotMenu'),...
        'UserData');
    l=get(findobj(get(pde_fig,'Children'),'flat','Tag','winmenu'),...
        'UserData');
    if isempty(l),
      pstr='Variable name for solution:';
      estr='u';
      matqueue('put',u)
    else
      pstr='Variable names for solution and eigenvalues:';
      estr='u l';
      matqueue('put',u,l)
    end
  elseif flag==6,
    % export movie:
    M=getappdata(pde_fig,'movie');
    matqueue('put',M)
    pstr='Variable name for PDE solution movie:';
    estr='M';
  end
  pdeinfo('Change the variable name(s) if desired. OK when done.',0);
  matqdlg('buffer2ws','Name','Export','PromptString',pstr,...
      'OKCallback','pdeinfo;','CancelCallback','pdeinfo;','EntryString',estr);

%
% case: check if set formula has changed:

elseif strcmp(action,'formchk')

  hndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEEval');
  newstr=deblank(get(hndl,'String'));
  oldstr=get(hndl,'UserData');
  change=~strcmp(newstr,oldstr);
  if change,
    set(hndl,'UserData',newstr)
    % set flags: need_save and flag1
    h=findobj(get(pde_fig,'Children'),'flat','Tag','PDEFileMenu');
    flags=get(h,'UserData');
    flags(1)=1; flags(3)=1;
    set(h,'UserData',flags)
    setappdata(pde_fig,'meshstat',[]);
    setappdata(pde_fig,'bl',[]);
  end

%
% case: application selection callback

elseif strcmp(action,'appl_cb')

  kids=get(pde_fig,'Children');
  h=findobj(kids,'flat','Tag','PDEAppl');
  oldval=get(h,'UserData');
  val=get(h,'Value');
  typeh=findobj(kids,'flat','Tag','PDEHelpMenu');
  paramh=findobj(kids,'flat','Tag','PDEPDEMenu');
  pde_typeh=findobj(kids,'flat','Tag','PDEHelpMenu');

  if (flag==0 && val==1) || flag==1,
    % Generic scalar
    if oldval==1, return; end
    setappdata(pde_fig,'application',1);
    set(h,'Value',1,'UserData',1)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',1),'Checked','on')
    setappdata(pde_fig,'equation','-div(c*grad(u))+a*u=f');
    setappdata(pde_fig,'params',str2mat('c','a','f','d'));
    setappdata(pde_fig,'description',str2mat([],[],[],[]));
    setappdata(pde_fig,'bounddescr',str2mat([],[],[],[]));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*c*grad(u)+q*u=g','h*u=r',[]))
    cp=str2mat('1.0','0.0','10','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,1);
    set(paramh,'UserData',stdparam)
    strmtx=str2mat('u|abs(grad(u))|abs(c*grad(u))|user entry',...
        ' -grad(u)| -c*grad(u)| user entry');
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',1)

  elseif (flag==0 && val==2) || flag==2,
    % Generic system
    if oldval==2, return; end
    setappdata(pde_fig,'application',2);
    set(h,'Value',2,'UserData',2)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',2),'Checked','on')

    setappdata(pde_fig,'equation','-div(c*grad(u))+a*u=f');
    setappdata(pde_fig,'params',str2mat('c11, c12','c21, c22',...
        'a11, a12','a21, a22','f1, f2','d11, d12','d21, d22'));
    setappdata(pde_fig,'description',str2mat([],[],[],[],[],[],[]));
    setappdata(pde_fig,'bounddescr',str2mat([],[],[],[],[],[],[],[]));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*c*grad(u)+q*u=g','h*u=r','n*c*grad(u)+q*u=g+h''*l; h*u=r'))
    cp=str2mat('1.0','0.0','0.0','0.0','1.0','1.0','0.0',...
        '0.0','1.0','0.0','0.0','1.0','0.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,2);
    set(paramh,'UserData',stdparam)
    strmtx=str2mat('u|v|abs(u,v)|user entry',...
        '(u,v)|user entry');
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',0)

  elseif (flag==0 && val==3) || flag==3,
    % Structural Mechanics, Plane Stress
    if oldval==3, return; end
    setappdata(pde_fig,'application',3);
    set(h,'Value',3,'UserData',3)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',3),'Checked','on')
    setappdata(pde_fig,'equation','Structural mechanics, plane stress');
    setappdata(pde_fig,'params',str2mat('E','nu','Kx','Ky','rho'));
    setappdata(pde_fig,'description',str2mat('Young''s modulus',...
        'Poisson ratio','Volume force, x-direction',...
        'Volume force, y-direction','Density'));
    setappdata(pde_fig,'bounddescr',str2mat('Surface tractions','  ''''',...
        'Spring constants','   ''''','Weights','   ''''',...
        'Displacements','   '''''));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*c*grad(u)+q*u=g','h*u=r','n*c*grad(u)+q*u=g+h''*l; h*u=r'))
    cp=str2mat('1E3','0.3','0.0','0.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,3);
    set(paramh,'UserData',stdparam)
    str1=['x displacement (u)|y displacement (v)|abs(u,v)|ux|uy|vx|vy|',...
      'x strain|y strain|shear strain|x stress|y stress|shear stress|',...
      '1st principal strain|2nd principal strain|1st principal stress|',...
      '2nd principal stress|von Mises stress|user entry'];

    strmtx=str2mat(str1,'(u,v)|user entry');
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',0)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==4) || flag==4,
    % Structural Mechanics, Plane Strain
    if oldval==4, return; end
    setappdata(pde_fig,'application',4);
    set(h,'Value',4,'UserData',4)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',4),'Checked','on')
    setappdata(pde_fig,'equation','Structural mechanics, plane strain');
    setappdata(pde_fig,'params',str2mat('E','nu','Kx','Ky','rho'));
    setappdata(pde_fig,'description',str2mat('Young''s modulus',...
        'Poisson ratio','Volume force, x-direction',...
        'Volume force, y-direction','Density'));
    setappdata(pde_fig,'bounddescr',str2mat('Surface tractions','  ''''',...
        'Spring constants','   ''''','Weights','   ''''',...
        'Displacements','   '''''));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*c*grad(u)+q*u=g','h*u=r','n*c*grad(u)+q*u=g+h''*l; h*u=r'))
    cp=str2mat('1E3','0.3','0.0','0.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,4);
    set(paramh,'UserData',stdparam)

    str1=['x displacement (u)|y displacement (v)|abs(u,v)|ux|uy|vx|vy|',...
      'x strain|y strain|shear strain|x stress|y stress|shear stress|',...
      '1st principal strain|2nd principal strain|1st principal stress|',...
      '2nd principal stress|von Mises stress|user entry'];

    strmtx=str2mat(str1,'(u,v)|user entry');
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',0)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==5) || flag==5,
    % Electrostatics
    if oldval==5, return; end
    setappdata(pde_fig,'application',5);
    set(h,'Value',5,'UserData',5)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',5),'Checked','on')
    setappdata(pde_fig,'equation',...
        '-div(epsilon*grad(V))=rho, E=-grad(V), V=electric potential');
    setappdata(pde_fig,'params',str2mat('epsilon','rho'));
    setappdata(pde_fig,'description',str2mat('Coeff. of dielectricity',...
        'Space charge density'));
    setappdata(pde_fig,'bounddescr',...
        str2mat('Surface charge',[],'Weight','Electric potential'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*epsilon*grad(V)+q*V=g','h*V=r',[]'))
    cp=str2mat('1.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,5);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',1)
    str1=['electric potential|electric field|electric displacement|',...
      'user entry'];
    str2='electric field|electric displacement|user entry';
    strmtx=str2mat(str1,str2);
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==6) || flag==6,
    % Magnetostatics
    if oldval==6, return; end
    setappdata(pde_fig,'application',6);
    set(h,'Value',6,'UserData',6)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',6),'Checked','on')
    setappdata(pde_fig,'equation',...
        '-div((1/mu)*grad(A))=J, B=curl(A), A=magnetic vector potential');
    setappdata(pde_fig,'params',str2mat('mu','J'));
    setappdata(pde_fig,'description',str2mat('Magnetic permeability',...
        'Current density'));
    setappdata(pde_fig,'bounddescr',...
        str2mat('Magnetic field',[],'Weight','Magnetic potential'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*(1/mu)*grad(A)+q*A=g','h*A=r',[]))
    cp=str2mat('1.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,6);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',1)
    str1='magnetic potential|magnetic flux density|magnetic field|user entry';
    str2='magnetic flux density|magnetic field|user entry';
    strmtx=str2mat(str1,str2);
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==7) || flag==7,
    % AC Power Electromagnetics
    if oldval==7, return; end
    setappdata(pde_fig,'application',7);
    set(h,'Value',7,'UserData',7)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',7),'Checked','on')
    setappdata(pde_fig,'equation',...
        ['-div((1/mu)*grad(E))+(j*omega*sigma-omega^2*epsilon)*E=0, ',...
            'E=electric field']);
    setappdata(pde_fig,'params',str2mat('omega','mu','sigma','epsilon'));
    setappdata(pde_fig,'description',str2mat('Angular frequency',...
        'Magnetic permeability','Conductivity','Coeff. of dielectricity'));
    setappdata(pde_fig,'bounddescr',...
        str2mat('',[],'Weight','Electric field'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*(1/mu)*grad(E)+q*E=g','h*E=r',[]))
    cp=str2mat('1.0','1.0','1.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,7);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',1)
    str1=['electric field|magnetic flux density|magnetic field|',...
      'current density|resistive heating rate|user entry'];
    str2='magnetic flux density|magnetic field|user entry';
    strmtx=str2mat(str1,str2);

    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==8) || flag==8
    % Conductive Media DC
    if oldval==8, return; end
    setappdata(pde_fig,'application',8);
    set(h,'Value',8,'UserData',8)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',8),'Checked','on')
    setappdata(pde_fig,'equation',...
        '-div(sigma*grad(V))=q, E=-grad(V), V=electric potential');
    setappdata(pde_fig,'params',str2mat('sigma','q'));
    setappdata(pde_fig,'description',str2mat('Conductivity',...
        'Current source'));
    setappdata(pde_fig,'bounddescr',...
        str2mat('Current source','Film conductance','Weight',...
        'Electric potential'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*sigma*grad(V)+q*V=g','h*V=r',[]))
    cp=str2mat('1.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,8);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',1)

    str1='electric potential|electric field|current density|user entry';
    str2='electric field|current density|user entry';
    strmtx=str2mat(str1,str2);
    setappdata(pde_fig,'plotstrings',strmtx)
    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==9) || flag==9,
    % Heat Transfer
    if oldval==9, return; end
    setappdata(pde_fig,'application',9);
    set(h,'Value',9,'UserData',9)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',9),'Checked','on')
    setappdata(pde_fig,'equation',...
        'rho*C*T''-div(k*grad(T))=Q+h*(Text-T), T=temperature');
    setappdata(pde_fig,'params',str2mat('rho','C','k','Q','h','Text'));
    ScreenUnits = get(0,'Units');
    set(0,'Unit','pixels');
    ScreenPos = get(0,'ScreenSize');
    set(0,'Unit',ScreenUnits);
    if ScreenPos(3)<=800,
      setappdata(pde_fig,'description',str2mat('Density','Heat capacity',...
        'Coeff. of heat conduction','Heat source',...
        'Conv. heat transfer coeff.','External temperature'));
    else
      setappdata(pde_fig,'description',str2mat('Density','Heat capacity',...
        'Coeff. of heat conduction','Heat source',...
        'Convective heat transfer coeff.','External temperature'));
    end
    setappdata(pde_fig,'bounddescr',...
        str2mat('Heat flux','Heat transfer coefficient','Weight',...
        'Temperature'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*k*grad(T)+q*T=g','h*T=r',[]))
    cp=str2mat('1.0','1.0','1.0','1.0','1.0','0.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,9);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',2)
    str1='temperature|temperature gradient|heat flux|user entry';
    str2='temperature gradient|heat flux|user entry';
    strmtx=str2mat(str1,str2);
    setappdata(pde_fig,'plotstrings',strmtx)

    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  elseif (flag==0 && val==10) || flag==10,
    % Diffusion
    if oldval==10, return; end
    setappdata(pde_fig,'application',10);
    set(h,'Value',10,'UserData',10)
    menuh=get(findobj(kids,'Tag','PDEAppMenu'),...
        'Children');
    set(menuh,'Checked','off');
    set(findobj(menuh,'UserData',10),'Checked','on')
    setappdata(pde_fig,'equation','dc/dt-div(D*grad(c))=Q, c=concentration');
    setappdata(pde_fig,'params',str2mat('D','Q'));
    setappdata(pde_fig,'description',str2mat('Diffusion coefficient',...
        'Volume source'));
    setappdata(pde_fig,'bounddescr',...
        str2mat('Flux','Transfer coefficient','Weight','Concentration'));
    setappdata(pde_fig,'boundeq',...
        str2mat('n*D*grad(c)+q*c=g','h*c=r',[]))
    cp=str2mat('1.0','1.0');
    setappdata(pde_fig,'currparam',cp);
    stdparam=pdetrans(cp,10);
    set(paramh,'UserData',stdparam)
    set(typeh,'UserData',2)

    str1='concentration|concentration gradient|flux|user entry';
    str2='concentration gradient|flux|user entry';
    strmtx=str2mat(str1,str2);
    setappdata(pde_fig,'plotstrings',strmtx)

    pdetool('initbounds',1)
    set(pde_typeh,'UserData',1)

  end

  % Restore selected plotflags:
  plotflags=getappdata(pde_fig,'plotflags');
  plotflags(1:6)=ones(1,6);
  plotflags(11:18)=[0 1 1 0 0 0 0 1];
  setappdata(pde_fig,'plotflags',plotflags)
  % [colvar colstyle heightvar heightstyle vectorvar vectorstyle
  % colval doplot xyplot showmesh animationflag popupvalue
  % colflag contflag heightflag vectorflag deformflag deformvar]

  % Restore user entries:
  setappdata(pde_fig,'colstring','')
  setappdata(pde_fig,'arrowstring','')
  setappdata(pde_fig,'deformstring','')
  setappdata(pde_fig,'heightstring','')

  % Set flags to indicate that PDE equation has changed:
  h=findobj(kids,'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); flags(6)=0; flags(7)=1;
  set(h,'UserData',flags)

  % If any affected dialog box is open, update it:
  wins=get(0,'Children');
  % Plot selection dialog
  figh=findobj(wins,'flat','Tag','PDEPlotFig');
  if ~isempty(figh),
    if strcmp(get(figh,'Visible'),'on'),
      pdeptdlg('initialize',1,getappdata(gcf,'plotstrings'));
    end
  end
  % PDE Specification dialog
  figh=findobj(wins,'flat','Tag','PDESpecFig');
  if ~isempty(figh),
    if strcmp(get(figh,'Visible'),'on'),
      close(figh)
      pdetool('set_param')
    end
  end
  % Boundary Condition dialog:
  figh=findobj(wins,'flat','Tag','PDEBoundFig');
  if ~isempty(figh),
    if strcmp(get(figh,'Visible'),'on'),
      close(figh)
      pdetool('set_bounds')
    end
  end

%
% case: initialize boundary conditions
%
% Initial boundary condition: Dirichlet condition u=0 on the boundary.

elseif strcmp(action,'initbounds')

  % flag=1 if scalar, 0 if system
  bndhndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEBoundMenu');

  dl1=getappdata(pde_fig,'dl1');
  if isempty(dl1), return; end

  h=findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundMode');

  bounds=[find(dl1(7,:)==0) find(dl1(6,:)==0)];

  m=size(dl1,2);
  if flag,
    pdebound=zeros(10,m);
    pdebound(1,bounds)=ones(1,size(bounds,2));
    pdebound(2:6,:)=ones(5,m);
    pdebound([7:8 10],:)='0'*ones(3,m);
    pdebound(9,:)='1'*ones(1,m);
  else
    pdebound=zeros(26,m);
    pdebound(1,bounds)=2*ones(1,size(bounds,2));
    pdebound(2,:)=2*ones(1,m);
    pdebound(3:14,:)=ones(12,m);
    pdebound([15:20, 22:23, 25:26],:)='0'*ones(10,m);
    pdebound([21 24],:)='1'*ones(2,m);
  end
  set(h,'UserData',pdebound)

  % set color and user data of boundaries to Dirichlet values (red)
  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  bounds=findobj(get(ax,'Children'),'flat','Tag','PDEBoundLine');
  set(bounds,'Erasemode','xor')
  for i=1:length(bounds),
    udata=get(bounds(i),'UserData');
    udata(2:4)=[1 0 0];
    set(bounds(i),'Color','r','UserData',udata)
  end
  set(bounds,'Erasemode','background')
  % deselect all selected boundaries:
  hndl=findobj(get(bndhndl,'Children'),'flat','Tag','PDEBoundSpec');
  set(hndl,'UserData',[])

%
% case: set PDE coefficient values
%

elseif strcmp(action,'set_param')

  ax=findobj(get(pde_fig,'Children'),'flat','Tag','PDEAxes');
  subreg=getappdata(ax,'subsel');

  appl=getappdata(pde_fig,'application');
  equ=getappdata(pde_fig,'equation');
  params=getappdata(pde_fig,'params');
  descr=getappdata(pde_fig,'description');
  par_val=getappdata(pde_fig,'currparam');

  if findstr(par_val(1,:),'!'),
    if ~isempty(subreg),
      k=subreg;
    else
      k=1;
    end
    for i=1:size(par_val,1),
      str=par_val(i,:);
      for j=1:k,
        [tmps,str]=strtok(str,'!');
      end
      if i==1,
        parvalues=tmps;
      else
        parvalues=str2mat(parvalues,tmps);
      end
    end
  else
    parvalues=par_val;
  end

  wbdwnfcn = get(pde_fig,'WindowButtonDownFcn');
  set(pde_fig,'WindowButtonDownFcn','',...
              'Pointer','watch')
  drawnow
  if strcmp(computer,'PCWIN'),
    pderel
  end
  typeh=findobj(get(pde_fig,'Children'),'flat','Tag','PDEHelpMenu');
  if appl==1 || appl==2,
    pde_type=get(typeh,'UserData');
    pdedlg('initialize',[],pde_type,1:4,equ,params,parvalues,descr)
  elseif appl==3 || appl==4 ,
    pde_type=get(typeh,'UserData');
    pdedlg('initialize',[],pde_type,[1,4],equ,params,parvalues,descr)
  elseif appl==5 || appl==6 || appl==7 || appl==8,
    set(typeh,'Userdata',1)
    pdedlg('initialize',[],1,1,equ,params,parvalues,descr)
  elseif appl==9 || appl==10,
    pde_type=get(typeh,'UserData');
    pdedlg('initialize',[],pde_type,1:2,equ,params,parvalues,descr)
  end
  set(pde_fig,'WindowButtonDownFcn',wbdwnfcn,...
              'Pointer','arrow')
  drawnow

%
% case: set boundary condition parameter values

elseif strcmp(action,'set_bounds')

  appl=getappdata(pde_fig,'application');
  boundequ=getappdata(pde_fig,'boundeq');
  descr=getappdata(pde_fig,'bounddescr');

  systmtx=str2mat('g1','g2','q11, q12','q21, q22','h11, h12','h21, h22',...
      'r1','r2');
  scalarmtx=str2mat('g','q','h','r');
  set(pde_fig,'Pointer','watch')
  drawnow
  if strcmp(computer,'PCWIN'),
    pderel
  end
  if appl==1
    pdebddlg('initialize',[],1,1:2,boundequ,scalarmtx,descr)
  elseif appl==2 || appl==3 || appl==4,
    pdebddlg('initialize',[],0,1:3,boundequ,systmtx,descr)
  elseif appl>4
    pdebddlg('initialize',[],1,1:2,boundequ,scalarmtx,descr)
  end
  set(pde_fig,'Pointer','arrow')
  drawnow

%
% case: turn toolbar help on/off

elseif strcmp(action,'helponoff')

  opthndl=findobj(get(pde_fig,'Children'),'flat','Tag','PDEOptMenu');
  h=findobj(get(opthndl,'Children'),'flat','Tag','PDEHelpoff');

  if getappdata(pde_fig,'toolhelp'),
    set(h,'Checked','on')
    setappdata(pde_fig,'toolhelp',0)
    pdeinfo;
  else
    set(h,'Checked','off')
    setappdata(pde_fig,'toolhelp',1)
  end

%
% case: refresh PDE toolbox figure

elseif strcmp(action,'refresh')

  pde_kids = allchild(pde_fig);
  ax=findobj(pde_kids,'flat','Tag','PDEAxes');
  h=findobj(pde_kids,'flat','Tag','PDEFileMenu');
  flags=get(h,'UserData'); mode_flag=flags(2);

  if mode_flag~=3,
    set(ax,'DrawMode','normal'),
    refresh(pde_fig);
    set(ax,'DrawMode','fast')
  end

%
% case: 'About PDE Toolbox' display
elseif strcmp(action,'about')

  s = sprintf([' Partial Differential Equation Toolbox 1.0.4 \n',...
               ' Copyright 1994-2001 The Mathworks, Inc.']);
  msgbox(s,'About PDE Toolbox','modal')

%
% case: error (error message passed in flag)

elseif strcmp(action,'error')

  errordlg(flag,'PDE Toolbox Error','modal');

end

% end pdetool
