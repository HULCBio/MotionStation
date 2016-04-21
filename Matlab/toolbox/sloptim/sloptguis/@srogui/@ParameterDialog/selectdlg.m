function selectdlg(this)
% Dialog for selecting tuned variables

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:44:09 $
%   Copyright 1990-2003 The MathWorks, Inc. 
Dlg = this.SelectDialog;
if isempty(Dlg) || ~ishandle(Dlg)
   Dlg = LocalCreateDlg(this);
   this.SelectDialog = Dlg;
end
ud = get(Dlg,'UserData');
% Get tunable variables
try
   TunablePars = getTunableParams(this.Project,'Reference');
catch
   [junk,errmsg]=strtok(lasterr,sprintf('\n'));
   errordlg(errmsg,'Parameter Selection Error','modal')
   return
end
% Get list of tuned variables in Parameter Dialog (not Project)
if isempty(this.ParamSpecs)
   TunedVars = cell(0,1);
else
   % Get current list of model parameters and references
   TunedVars = strtok(get(this.ParamSpecs,{'Name'}),'.({');
end
% Get list of uncertain vars
UVars = getUncertainParams(this.Project);
% Populate list box (show only tunable variables with double value
TunableDoubles = TunablePars(strcmp({TunablePars.Type},'double'));
NewPars = setdiff({TunableDoubles.Name},[TunedVars;UVars]);
set(ud.List,'String',NewPars,'Value',[])
% Clear expression edit box
set(ud.Expression,'String','')
% Store reference data
ud.TunablePars = TunablePars;
% Make dialog visible
set(Dlg,'Visible','on','UserData',ud)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCALCREATEDLG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Dlg = LocalCreateDlg(this)
%
DlgH = 20;
DlgW = 50;
UIColor = get(0,'DefaultUIControlBackgroundColor');
Dlg = figure('Name','Add Parameters', ...
    'Visible','off', ...
    'MenuBar','none', ...
    'Units','character',...
    'Position',[0 0 DlgW DlgH], ...
    'Color', UIColor, ...
    'IntegerHandle','off', ...
    'HandleVisibility','off',...
    'WindowStyle','modal',...
    'NumberTitle','off');
centerfig(Dlg,this.Figure);
set(Dlg,'CloseRequestFcn',{@localHide Dlg})

% Button group
xgap = 2;
BW = 10;  BH = 1.5; Bgap = 1;
X0 = DlgW - xgap - 3*BW - 2*Bgap;
Y0 = 0.5;
uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Position',[X0 Y0 BW BH], ...
   'Callback',{@localOK Dlg this},...
   'String','OK');
X0 = X0+BW+Bgap;
uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Callback','', ...
   'Position',[X0 Y0 BW BH], ...
   'Callback',{@localHide Dlg},...
   'String','Cancel');
X0 = X0+BW+Bgap;
uicontrol('Parent',Dlg, ...
   'Units','character', ...
   'Callback','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''adding_tuned'')', ...
   'Position',[X0 Y0 BW BH], ...
   'String','Help');

% Expression edit 
Y0 = Y0 + BH + 0.7;
ud.Expression = uicontrol('Parent',Dlg, ...
         'BackgroundColor',[1 1 1],...
         'Style','edit', ...
         'HorizontalAlignment','left', ...
         'Units','character',...
         'TooltipString','Specify composite parameter such as structure field, matrix entry,...',...
         'Position',[xgap Y0 DlgW-2*xgap 1.4]);
Y0 = Y0 + 1.5;
uicontrol('Parent',Dlg, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','Specify expression (e.g., s.x or a(3)):', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[xgap Y0 DlgW-xgap 1.2]);


yL = DlgH-2;
uicontrol('Parent',Dlg, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','Select workspace variables:', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[xgap yL DlgW-xgap 1.2]);

Y0 = Y0 + 1.8;
LH = yL-Y0-0.3;
ud.List = uicontrol('Parent',Dlg, ...
   'Style','listbox', ...
   'Units','character',...
   'BackgroundColor',[1 1 1],...
   'Position',[xgap Y0 DlgW-2*xgap LH],...
   'Max',2,...
   'Value',[]);

% Listener to parent deletion
ud.Listener = handle.listener(this,'ObjectBeingDestroyed',{@localDelete Dlg});
% REVISIT: (src,data) delete(Dlg));

set(Dlg,'UserData',ud)



%------------------

function localDelete(eventsrc,eventdata,Dlg)
% Deletes dialog when parent axes go away
delete(Dlg)


function localHide(eventsrc,eventdata,Dlg)
% Cancel or close 
set(Dlg,'Visible','off')


function localOK(eventsrc,eventdata,Dlg,this)
% OK
ud = get(Dlg,'UserData');
TunablePars = ud.TunablePars;
TunableParNames = {TunablePars.Name};
ParSpecs = this.ParamSpecs;
Model = this.Project.Model;
% Selected workspace vars
Selection = get(ud.List,'Value');
if all(Selection>0)
   VarList = get(ud.List,'String');
   VarList = VarList(Selection);
   % Evaluate new parameters
   pv = utEvalParams(Model,VarList);
   % Add parameters
   [junk,idxLoc] = ismember(VarList,TunableParNames);
   for ct=1:length(VarList)
      ps = srogui.ParameterForm(VarList{ct},TunablePars(idxLoc(ct)).ReferencedBy);
      ps.Value = mat2str(pv(ct).Value,4);
      ParSpecs = [ParSpecs ; ps];
   end
end
% Expression
Expr = strtrim(get(ud.Expression,'String'));
if ~isempty(Expr)
   ExpVar = strtok(Expr,'.{(');
   idxTP = find(strcmp(ExpVar,TunableParNames));
   if isempty(idxTP)
      errordlg(sprintf('Undefined variable %s.',strtok(Expr,'.{(')),'Add Parameter Error','modal')
      return
   end
   % Try evaluating
   try
      pv = utEvalParams(Model,{Expr});
   catch
      errordlg(sprintf('Expression "%s" could not be evaluated.',Expr),'Add Parameter Error','modal')
      return
   end
   % Check value is double
   if ~isa(pv.Value,'double')
      errordlg(sprintf('Expression "%s" must evaluate to a double array.',Expr),'Add Parameter Error','modal')
      return
   end
   % Check for valid assignable expression by reassigning the value
   try
      utAssignParams(Model, pv)
   catch
      errordlg(sprintf('Expression "%s" is not tunable.',Expr),'Add Parameter Error','modal')
      return
   end
   % Add parameter
   if ~any(strcmp( Expr, get(ParSpecs, {'Name'})))
      ps = srogui.ParameterForm(Expr,TunablePars(idxTP).ReferencedBy);
      ps.Value = mat2str(pv.Value,4);
      ParSpecs = [ParSpecs ; ps];
   end
end
% Update parameter list
% RE: Listener attached
this.ParamSpecs = ParSpecs;
% Hide dialog and show warning
set(Dlg,'Visible','off')

