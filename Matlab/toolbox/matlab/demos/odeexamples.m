function odeexamples(section)
%ODEEXAMPLES  Browse ODE/DAE/IDE/BVP/PDE examples.
%   ODEEXAMPLES with no input arguments starts the browser and displays 
%   the list of examples of solving ordinary differential equations, ODEs.
%   ODEEXAMPLES(SECTION) with SECTION = 'ode', 'dae', 'ide', 'dde', 'bvp', 
%   or 'pde', starts the browser and displays the list of examples for 
%   the particular class of problems.  

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2003/05/08 21:45:52 $

if (nargin < 1) || (~ischar(section))
  section = 'ode';   % default to 'ode'
end	

switch lower(section)
 case 'ode'
  startSection = 1;
 case 'dae'
  startSection = 2;
 case 'ide'          % fully implicit Differential Equations
  startSection = 3;
 case 'dde'
  startSection = 4;
 case 'bvp'
  startSection = 5;		
 case 'pde'
  startSection = 6;
 otherwise
  startSection = 1;  % default to 'ode'
end

category_names = {
    'Ordinary Differential Equations'    
    'Differential-Algebraic Equations'
    'Implicit Differential Equations'
    'Delay Differential Equations'
    'Boundary Value Problems'
    'Partial Differential Equations'};

odeitems = {
    'ballode    - Simple event location (trajectory of a bouncing ball)'
    'batonode   - ODE with time- and state-dependent mass matrix '
    'brussode   - Stiff large problem (diffusion in a chemical reaction)'
    'burgersode - ODE with strongly state-dependent mass matrix'    
    'fem1ode    - Stiff problem with a time-dependent mass matrix'
    'fem2ode    - Stiff problem with a constant mass matrix'
    'hb1ode     - Stiff problem solved on a very long interval'
    'orbitode   - Advanced event location (restricted three body problem)'
    'rigidode   - Nonstiff problem (Euler equations of motion)'
    'vdpode     - Stiff problem (van der Pol equation)' };
odedemos = odeitems;
for i = 1:length(odedemos)
  odedemos{i} = strtok(odedemos{i});
end

daeitems = {    
    'amp1dae - Stiff DAE - electrical circuit'
    'hb1dae  - Stiff DAE from a conservation law'};
daedemos = daeitems;
for i = 1:length(daeitems)
  daedemos{i} = strtok(daeitems{i});
end

ideitems = {    
    'iburgersode - Burgers'' equation solved as implicit ODE system'
    'ihb1dae  - Stiff implicit DAE from a conservation law'};
idedemos = daeitems;
for i = 1:length(ideitems)
  idedemos{i} = strtok(ideitems{i});
end

ddeitems = {    
    'ddex1 - DDEs with constant history'
    'ddex2 - DDEs with discontinuities'};
ddedemos = daeitems;
for i = 1:length(ddeitems)
  ddedemos{i} = strtok(ddeitems{i});
end

bvpitems = {
    'emdenbvp - Emden''s equation - BVP with a singular term'
    'fsbvp    - Falkner-Skan BVP on an infinite interval'
    'mat4bvp  - Fourth eigenfunction of Mathieu''s equation'
    'shockbvp - Solution has a shock layer near x = 0'
    'threebvp - Three-point boundary value problem'
    'twobvp   - Problem that has exactly two solutions'};
bvpdemos = bvpitems;
for i = 1:length(bvpitems)
  bvpdemos{i} = strtok(bvpitems{i});
end

pdeitems = {
    'pdex1 - One PDE--introductory example'
    'pdex2 - One PDE--example with discontinuities'
    'pdex3 - One PDE--approximate u(x,t) and Du(x,t)/Dx'
    'pdex4 - Two PDEs--introductory example'
    'pdex5 - Two PDEs--example of long-time behavior'};
pdedemos = pdeitems;
for i = 1:length(pdeitems)
  pdedemos{i} = strtok(pdeitems{i});
end

category_items = {odeitems,daeitems,ideitems,ddeitems,bvpitems,pdeitems};
category_demos = {odedemos,daedemos,idedemos,ddedemos,bvpdemos,pdedemos};

selectdemo(category_names,category_items,category_demos,startSection);

% --------------------------------------------------------------------------

function selectdemo(category_names,category_items,category_demos,startSection) 

figname = 'Differential Equations Examples';
examplestring = 'Examples of';
viewstring = 'View Code';
runstring = 'Run Example';
closestring = 'Close';

fontname = 'FixedWidth';
fontsize = 11;

dp = get(0,'DefaultFigurePosition');
fW = 1.1*dp(3);   % width
fH = 0.75*dp(4);  % height

fp = [dp(1) dp(2)+dp(4)-fH fW fH];   % fix upper left corner

fig = figure('Name',figname, ...
             'Position',fp, ...
             'Resize','on', ...
             'Menubar','none', ...
             'CloseRequestFcn',@doClose, ...        
             'NumberTitle','off', ...
             'Visible','on', ...
             'NextPlot','add',...
             'IntegerHandle','off',...
             'HandleVisibility','on');

exampletitle = uicontrol('Style','text',...
                         'Units','normal',...
                         'Position',[0.02 0.825 0.15 0.1],...
                         'BackgroundColor',get(fig,'Color'),...
                         'FontName',fontname,...
                         'FontSize',fontsize,...
                         'HorizontalAlignment','left',...	
                         'String',examplestring);	  
set(exampletitle,'Units','pixels');					 

listbox = uicontrol('Style','listbox',...
                    'Max',1,...
                    'Units','normal',...
                    'Position',[0.02 0.33 0.97 0.5],...
                    'BackgroundColor','w',...
                    'FontName',fontname,...
                    'FontSize',fontsize,...
                    'String',cellstr(category_items{startSection}));		
set(listbox,'Units','pixels');					 				

popupmenu = uicontrol('Style','popupmenu',...
                      'Max', 1,...					
                      'Units','normal',...
                      'Position',[0.18 0.86 0.49 0.076],...
                      'BackgroundColor','w',...
                      'FontName',fontname,...
                      'FontSize',fontsize,...
                      'HorizontalAlignment','left',...	
                      'String',cellstr(category_names),...
                      'Value',startSection,...
                      'Callback',{@changeCategory,listbox,category_items});	  
set(popupmenu,'Units','pixels');	

view_btn = uicontrol('Style','pushbutton',...
                     'String',viewstring,...
                     'Units','normal',...
                     'Position',[0.21 0.2 0.26 0.1],...
                     'Callback',{@doView,popupmenu,listbox,category_demos}); 
set(view_btn,'Units','pixels');		

run_btn = uicontrol('Style','pushbutton',...
                    'String',runstring,...
                    'Units','normal',...
                    'Position',[0.53 0.2 0.26 0.1],...  
                    'Callback',{@doRun,popupmenu,listbox,category_demos});
set(run_btn,'Units','pixels'); ...

separator =  uicontrol('Style','frame',...
                       'Units','normal',...
                       'Position',[0.02 0.15 0.96 0.005]);
set(separator,'Units','pixels'); ...
    
close_btn = uicontrol('Style','pushbutton',...
                      'String',closestring,...
                      'Units','normal',...
                      'Position',[0.79 0.02 0.19 0.1],...
                      'Callback',@doClose);
set(close_btn,'Units','pixels');	

set(fig,'HandleVisibility','off',...
        'ResizeFcn',{@doResize,fp,...
                    exampletitle,get(exampletitle,'Position'),...
                    popupmenu,get(popupmenu,'Position'),...
                    listbox,get(listbox,'Position'),...
                    view_btn,get(view_btn,'Position'),...
                    run_btn,get(run_btn,'Position'),...
                    separator,get(separator,'Position'),...
                    close_btn,get(close_btn,'Position')} );

% --------------------------------------------------------------------------

function doView(view_btn, evd, category, example, demos)
name = demos{get(category,'value')}{get(example,'value')};
pointer = get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
try   
  eval(['edit ',name]);
catch 
end
set(gcbf,'Pointer',pointer);

% --------------------------------------------------------------------------

function doRun(run_btn, evd, category, example, demos)
name = demos{get(category,'value')}{get(example,'value')};
pointer = get(gcbf,'Pointer');
set(gcbf,'Pointer','watch');
try   
  eval(name);
catch 
end
set(gcbf,'Pointer',pointer);

% --------------------------------------------------------------------------

function doClose(close_btn, evd)
delete(gcbf);

% --------------------------------------------------------------------------

function changeCategory(popup, evd, listbox, category_items)
categoryIdx = get(popup,'value');
items = category_items{categoryIdx};
set(listbox,'String',cellstr(items));
set(listbox,'Value',1);

% --------------------------------------------------------------------------

function doResize(fig,evd,fp,exampletitle,example_pos,popup,popup_pos,...
                  list,list_pos,view_btn,view_pos,run_btn,run_pos,...
                  sep,sep_pos,close_btn,close_pos);

np = get(fig,'Position');
dh = np(3) - fp(3);
dv = np(4) - fp(4);

list_pos(3) = list_pos(3) + dh;
list_pos(4) = list_pos(4) + dv;
example_pos(2) = example_pos(2) + dv;
popup_pos(2) = popup_pos(2) + dv;
popup_pos(3) = min(popup_pos(3),np(3)-popup_pos(1));		
view_pos(1) = view_pos(1) + dh/2;
run_pos(1) = run_pos(1) + dh/2;
sep_pos(3) = sep_pos(3) + dh;
close_pos(1) = close_pos(1) + dh;

try	
  set(list,'Position',list_pos);
  set(exampletitle,'Position',example_pos);	
  set(popup,'Position',popup_pos);
  set(sep,'Position',sep_pos);
  set(close_btn,'Position',close_pos);
  set(view_btn,'Position',view_pos);
  set(run_btn,'Position',run_pos);
catch
end
