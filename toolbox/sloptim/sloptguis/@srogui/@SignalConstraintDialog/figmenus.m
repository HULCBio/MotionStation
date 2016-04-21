function h = figmenus(this)
% Creates menu for Signal Constraint block dialog.
%
%   Author(s): Kamesh Subbarao
%   Copyright 1990-2004 The MathWorks, Inc.

Figure = this.Figure;
Editor = this.Editor;

% File menu
filemenu = uimenu(Figure,'Label',xlate('&File'),'HandleVisibility','off');
uimenu(filemenu,'Label',xlate('&Load...'),'CallBack',{@LocalLoadFrom this});
uimenu(filemenu,'Label',xlate('&Save'),'CallBack',{@LocalSave this});
uimenu(filemenu,'Label',xlate('&Save As...'),'CallBack',{@LocalSaveAs this});
uimenu(filemenu,'Label',xlate('&Print...'),'Separator','on','CallBack',{@LocalPrint this});
uimenu(filemenu,'Label',xlate('&Close'),'Separator','on','CallBack',{@LocalHide this});

% Edit Menu
editmenu = uimenu(Figure,'Label',xlate('&Edit'),'HandleVisibility','off');
% Undo/redo
Undo = uimenu(editmenu,'Label',xlate('&Undo'),'Enable','off','CallBack',{@LocalUndo this});
Redo = uimenu(editmenu,'Label',xlate('&Redo'),'Enable','off','CallBack',{@LocalRedo this});
% Install listener for enable state
Recorder = Editor.Recorder;
set(Undo,'UserData',...
   handle.listener(Recorder,findprop(Recorder,'Undo'),...
   'PropertyPostSet',{@LocalDoMenu Undo this}));
set(Redo,'UserData',...
   handle.listener(Recorder,findprop(Recorder,'Redo'),...
   'PropertyPostSet',{@LocalDoMenu Redo this}));
% Constraint editing
uimenu(editmenu,'Label',xlate('&Scale Constraint...'),'Separator','on',...
   'CallBack',@(x,y) scaledlg(Editor));
uimenu(editmenu,'Label',xlate('Re&set Constraint'),...
   'CallBack',{@LocalReset this});
% Axes props
uimenu(editmenu,'Label',xlate('&Axes Properties...'),'Separator','on',...
   'CallBack',@(x,y) PropEditor(Editor));

% View menu
viewmenu = uimenu(Figure,'Label',xlate('&Plots'),'HandleVisibility','off');
uimenu(viewmenu,'Label',xlate('&Plot Current Response'),...
   'CallBack',{@LocalSimCurrent this});
m = uimenu(viewmenu,'Label',xlate('Show')); 
addShowMenus(Editor,m)
uimenu(viewmenu,'Label',xlate('&Clear Plots'), 'CallBack',@(x,y) clearplot(Editor))

% Goals menu (contribution to optimization problem formulation)
goalmenu = uimenu(Figure,'Label',xlate('&Goals'),'HandleVisibility','off');
g1 = uimenu(goalmenu,'Label',xlate('&Enforce Signal Bounds'));
g2 = uimenu(goalmenu,'Label',xlate('&Track Reference Signal'));
% Wire up listeners
addGoalSelectors(Editor,g1,g2)
uimenu(goalmenu,'Label',xlate('&Desired Response...'),'Separator','on',...
   'CallBack',{@LocalSpecDlg this});

% Optimization menu
optimmenu = uimenu(Figure,'Label',xlate('&Optimization'),'HandleVisibility','off');
Start = uimenu(optimmenu,'Label',xlate('&Start'),'CallBack',{@LocalStart this});
Stop = uimenu(optimmenu,'Label',xlate('Sto&p'),...
   'Enable','off','CallBack',{@LocalStop this});
m1 = uimenu(optimmenu,'Label',xlate('&Tuned Parameters...'),'Separator','on', ...
   'CallBack',{@LocalTunedParam this});
m2 = uimenu(optimmenu,'Label',xlate('&Uncertain Parameters...'),'CallBack',...
   {@LocalSetUncertain this});
m3 = uimenu(optimmenu,'Label',xlate('&Simulation Options...'),'Separator','on', ...
   'CallBack',{@LocalSetOptions this 1});
m4 = uimenu(optimmenu,'Label',xlate('&Optimization Options...'), ...
   'CallBack',{@LocalSetOptions this 2});

% Windows Menu
% windowmenu = uimenu(Figure,'Tag','winmenu','Label',xlate('&Window'),...
%    'Callback',winmenu('callback'),'HandleVisibility','off');
%
%%%%%%%%%%% Help Menu
%
helpmenu = uimenu(Figure,'Label',xlate('&Help'),'HandleVisibility','off');
uimenu(helpmenu,'Label',xlate('&Simulink Response Optimization Help'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim_product_page.html''])');
uimenu(helpmenu,'Label',xlate('Specifying the Desired &Response'),'Separator','on',...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''desired_response'')');
uimenu(helpmenu,'Label',xlate('Specifying the &Tuned Parameters'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''tuning'')');
uimenu(helpmenu,'Label',xlate('Running the &Optimization'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''optim'')');
uimenu(helpmenu,'Label',xlate('Accounting for &Uncertainty'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''uncertain'')');
uimenu(helpmenu,'Label',xlate('Setting Opt&ions'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''options_opt'')');
uimenu(helpmenu,'Label',xlate('Saving &Projects'),...
   'CallBack','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''saving'')');
uimenu(helpmenu,'Label',xlate('&Demos'),'Separator','on',...
   'CallBack','demo(''simulink'',''Simulink Response Optimization'')');
uimenu(helpmenu,'Label',xlate('&About Simulink Response Optimization'),'Separator','on',...
   'CallBack',@LocalShowVer);


% uimenu(helpmenu,'Label',xlate('&Hot-key help ...'),...
%    'CallBack','ncdhelp(''hotkey.hlp'',''NCD Blockset Accelerator/Keypress Help'');');
% uimenu(helpmenu,'Label',xlate('&Readme.m ...'), ...
%    'CallBack','ncdhelp(''readncd.hlp'',''NCD Blockset Readme.m file'');');

% Listeners
OtherMenus = [filemenu;editmenu;viewmenu;goalmenu;helpmenu;Start;m1;m2;m3;m4];
h = struct('Stop',Stop','Other',OtherMenus);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Pass these callbacks to class methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LocalDoMenu(hProp,event,hMenu,this)
% Update menu state and label
Stack = event.NewValue;
if isempty(Stack)
   % Empty stack
   set(hMenu,'Enable','off','Label',sprintf('&%s',get(hProp,'Name')))
else
   % Get last transaction's name
   ActionName = Stack(end).Name;
   Label = sprintf('&%s %s',get(hProp,'Name'),ActionName);
   set(hMenu,'Enable','on','Label',Label)
end
% Set dirty flag
this.Project.Dirty = true;


function LocalUndo(hMenu,event,this)
% Undo callback
undo(this.Editor)


function LocalRedo(hMenu,event,this)
% Redo callback
redo(this.Editor)


function LocalHide(eventsrc,eventdata,this)
this.Figure.Visible = 'off';


function LocalSpecDlg(eventsrc,eventdata,this)
% Desired... response
specdlg(this.Editor)


function LocalReset(eventsrc,eventdata,this)
% Reinitializes constraint
C = this.Constraint;
Editor = this.Editor;
% X range
try
   Editor.XFocus = getSimInterval(this.Project);
catch
   errordlg('Could not evaluate model stop time.','Reset Error','modal')
   return
end
% Y range
Ylim = get(getaxes(Editor),'Ylim');
% Update constraint
Transaction = ctrluis.transaction(C,'Name','Reset Constraint',...
   'OperationStore','on','InverseOperationStore','on');
% Split consraint
C.init(Editor.XFocus,Ylim*[.9 .1;.1 .9])
% Commit and stack transaction
commit(Transaction)
Editor.Recorder.pushundo(Transaction)
% Update plot
update(Editor)


function LocalLoadFrom(eventsrc,eventdata,this)
% Load... menu: open load dialog
loadfrom(this)


function LocalSave(eventsrc,eventdata,this)
% Save menu/button
save(this)


function LocalSaveAs(eventsrc,eventdata,this)
% Save As... menu: open save dialog
saveas(this)


function LocalSimCurrent(eventsrc,eventdata,this)
% Simulate and notify all editors to update
feval(this.Editor.RespFcn{:})


function LocalTunedParam(eventsrc,eventdata,this)
% Opens dialog for specifying tuned parameters
pardlg(this)


function LocalSetUncertain(eventsrc,eventdata,this)
% Opens dialog for specifying tuned parameters
uncdlg(this)


function LocalSetOptions(eventsrc,eventdata,this,Tab)
% Opens dialog for setting options
optdlg(this,Tab)


function LocalStart(eventsrc,eventdata,this)
% Start button
optimize(this)


function LocalStop(eventsrc,eventdata,this)
% Stop button
if strcmp(this.RunTimeProject.OptimStatus,'run')
   this.RunTimeProject.OptimStatus = 'stop';
else
   % CTRL-C interrupt (second click)
   this.RunTimeProject.OptimStatus = 'idle';
end


function LocalPrint(eventsrc,eventdata,this)
% Redo callback
printdlg(double(this.Figure))


function LocalShowVer(varargin)
verstruct = ver('sloptim');
verstring = sprintf('   %s    \n\n       Version %s %s',...
   verstruct.Name,verstruct.Version,verstruct.Release); 
msgbox(verstring,'About This Product')

