function selectdlg(this)
% Dialog for selecting uncertain variables

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:45:19 $
%   Copyright 1990-2003 The MathWorks, Inc. 
Dlg = this.SelectDialog;
if isempty(Dlg) || ~ishandle(Dlg)
   Dlg = LocalCreateDlg(this);
   this.SelectDialog = Dlg;
end
ud = get(Dlg,'UserData');
% Get tunable variables
try
   TunablePars = getTunableParams(this.Project);
catch
   errordlg(utGetLastError,'Parameter Selection Error','modal')
   return
end
% Get list of all already used parameters
TPars = getTunedVarNames(this.Project);
uspec = this.Uncertainty(this.ActiveSpec);
if isempty(uspec.Parameters)
   UPars = cell(0,1);
else
   UPars = strtok({uspec.Parameters.Name},'.{(');
end
% Populate list box
TunableDoubles = TunablePars(strcmp({TunablePars.Type},'double'));
NewPars = setdiff({TunableDoubles.Name},[TPars(:);UPars(:)]);
set(ud.List,'String',NewPars,'Value',[])
% Clear expression edit box
% set(ud.Expression,'String','')
% Make dialog visible
set(Dlg,'Visible','on')


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
   'Callback','helpview([docroot ''/toolbox/sloptim/sloptim.map''],''adding_uncertain'')', ...
   'Position',[X0 Y0 BW BH], ...
   'String','Help');

% Expression edit 
Y0 = Y0 + BH + 0.7;
% ud.Expression = uicontrol('Parent',Dlg, ...
%          'BackgroundColor',[1 1 1],...
%          'Style','edit', ...
%          'HorizontalAlignment','left', ...
%          'Units','character',...
%          'TooltipString','Specify composite parameter such as structure field, matrix entry,...',...
%          'Position',[xgap Y0 DlgW-2*xgap 1.4]);
% Y0 = Y0 + 1.5;
% uicontrol('Parent',Dlg, ...
%    'BackgroundColor',UIColor,...
%    'Style','text', ...
%    'String','Specify expression (e.g., s.x or a(3)):', ...
%    'HorizontalAlignment','left', ...
%    'Units','character',...
%    'Position',[xgap Y0 DlgW-xgap 1.2]);

% List box
yL = DlgH-2;
uicontrol('Parent',Dlg, ...
   'BackgroundColor',UIColor,...
   'Style','text', ...
   'String','Select workspace variables:', ...
   'HorizontalAlignment','left', ...
   'Units','character',...
   'Position',[xgap yL DlgW-xgap 1.2]);

% Y0 = Y0 + 1.8;
LH = yL-Y0-0.5;
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
% Callback for OK
ud = get(Dlg,'UserData');
Model = this.Project.Model;
% Selected workspace vars
Selection = get(ud.List,'Value');
if all(Selection>0)
   ParList = get(ud.List,'String');
   s = utEvalParams(Model,ParList(Selection));
   % Add parameters to spec
   for ctu=1:length(this.Uncertainty)
      for ct=1:length(s)
         this.Uncertainty(ctu).addpar(s(ct).Name,s(ct).Value);
      end
   end
end
% % Expression
% Expr = strtrim(get(ud.Expression,'String'));
% if ~isempty(Expr)
%    % Try evaluating
%    try
%       s = utEvalParams(Model,{Expr});
%    catch
%       errordlg(sprintf('Expression "%s" could not be evaluated.',Expr),'Add Parameter Error','modal')
%       return
%    end
%    % Check value is double
%    if ~isa(s.Value,'double')
%       errordlg(sprintf('Expression "%s" must evaluate to a double array.',Expr),'Add Parameter Error','modal')
%       return
%    end
%    % Check for valid assignable expression by reassigning the value
%    try
%       utAssignParams(Model, s)
%    catch
%       errordlg(sprintf('Expression "%s" is not tunable.',Expr),'Add Parameter Error','modal')
%       return
%    end
%    % Add parameter
%    for ctu=1:length(this.Uncertainty)
%       uf = this.Uncertainty(ctu);
%       if isempty(uf.Parameters) || ...
%             ~any(strcmp( Expr, {uf.Parameters.Name}))
%          uf.addpar(s.Name,s.Value);
%       end
%    end
% end
% Update table
updateTable(this)
% Hide dialog
set(Dlg,'Visible','off')

   


