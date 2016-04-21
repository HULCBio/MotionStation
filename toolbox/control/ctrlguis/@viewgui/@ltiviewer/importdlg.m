function importdlg(this)
%IMPORTDLG  Opens dialog for importing LTI system into LTI Viewer.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2002 The MathWorks, Inc.

% Update status bar and open GUI
this.EventManager.newstatus('Select the systems to import...');
[ListStr,AllNames] = LocalSystemList;

% Dialog database
ud = struct('Parent',this.Figure,...
    'Figure',[],...
    'Filter',@LocalBrowseFilter,...
    'ListData',struct('Names',[],'Models',[]),...
    'Handles',[]);
 
% Create dialog
ud = LocalOpenDlg(ud,ListStr,AllNames);

% Set apply callback
set(ud.Handles.OKButton,'Callback',{@LocalApply this ud.Figure})

% Make figure visible and store database
set(ud.Figure,'UserData',ud);
viewimportfcn('workspace',ud.Figure);
set(ud.Figure,'Visible','on');

%--------------------------Local Functions------------------------
%%%%%%%%%%%%%%%%%%
%%% LocalApply %%%
%%%%%%%%%%%%%%%%%%
function LocalApply(hSrc,event,this,ImportFig)
% Commit import operation 
ImportUd = get(ImportFig,'UserData');
AllNames   = ImportUd.ListData.Names;
AllSys     = ImportUd.ListData.Models;
ImportSource = ImportUd.ListData.Eval; 
% Get values of specified models
Vals = get(ImportUd.Handles.ModelList,'Value');
if isempty(AllNames) | isempty(Vals) | isempty(AllNames)
   errordlg('No system selected for importing.','LTI Viewer Import','modal');
   return
end
set(ImportUd.Handles.ModelList,'Value',[]);
if ischar(AllNames)
   AllNames = cellstr(AllNames);
end
% Read values of imported systems
ImportSysNames = AllNames(Vals);
switch ImportSource
case 'file'
   ImportSysValues = AllSys(Vals);
case 'workspace'
   ImportSysValues = cell(size(ImportSysNames));
   for ct=1:length(ImportSysNames)
      ImportSysValues{ct} = evalin('base',ImportSysNames{ct});
   end
end

% Check for overwritten systems
[RefreshSysNames,ia,ib] = intersect(get(this.Systems,{'Name'}),ImportSysNames);
if ~isempty(RefreshSysNames)
   overwrite = questdlg(...
      'Some imported systems already exist in the Viewer. Do you want to overwrite them?',...
      'Overwrite Systems');
   switch overwrite
   case 'Cancel'
      return
   case 'No'
      ImportSysNames(ib) = [];
      ImportSysValues(ib) = [];
   end
end
    
% Complete import
importsys(this,ImportSysNames,ImportSysValues)
plural = 's';
Status = sprintf('Import completed: %d system%s imported.',length(ImportSysNames)...
    ,plural(:,(length(ImportSysNames)~=1)));
this.EventManager.newstatus(Status);
    
% Close import figure
close(ImportFig)

%--------------------------Rendering Functions------------------------
%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%%
%%%%%%%%%%%%%%%%%%%%
function ud = LocalOpenDlg(ud,ListStr,AllNames)

% Dimensioning Params (in char. units)
FigW = 200;
FigH = 22.5; 
Params = struct(...
    'hBorder',1.5,...
    'vBorder',0.3,...
    'ButtonH',1.5,...
    'EditH',1.5,...
    'TextH',1.1,...
    'Toffset',3,...
    'StdUnit','character',...
    'StdColor',get(0,'DefaultUIControlBackground'));

%---Open the Import LTI Design Model Figure
ImportFig = figure(...
    'Units',Params.StdUnit, ...
    'Color',Params.StdColor, ...
    'MenuBar','none', ...
    'Visible','off',...
    'IntegerHandle','off',...
    'Name',xlate('Import System Data'), ...
    'NumberTitle','off', ...
    'Position',[3 7 0.5*FigW+Params.hBorder FigH], ...
    'Resize','off',...
    'WindowStyle','modal');
ud.Figure = ImportFig;

% Center wrt LTIVIEWER main window
centerfig(ImportFig,ud.Parent);

% Import source frame
Y0 = Params.ButtonH+2*Params.vBorder;
SrcFramePosition = [Params.hBorder,Y0,0.5*(FigW-2*Params.hBorder),19.5];
ud = LocalCreateSourceFrame(ud,SrcFramePosition,Params,ListStr,AllNames);

% Window button fame
X0 = SrcFramePosition(1);
ButtonGroupPos = [X0,Params.vBorder,SrcFramePosition(3),Params.ButtonH+2*Params.vBorder];
ud = LocalCreateButtons(ud,ButtonGroupPos,Params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateSourceFrame %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = LocalCreateSourceFrame(ud,Position,Params,ListStr,AllNames)

ImportFig = ud.Figure;
TextH = Params.TextH;
EditH = Params.EditH;
hBorder = Params.hBorder;
FW = Position(3);
FH = Position(4);

% Main frame
uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',Position, ...
    'Style','frame');
uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[Position(1)+Params.Toffset Position(2)+FH-TextH/2 15 TextH], ...
    'String','Import from', ...
    'Style','text');

% Source selector
X0 = Position(1)+1.5*hBorder;
Y0 = Position(2)+FH-3*TextH;
RBW = 15;
ud.Handles.Wbutton = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Callback','viewimportfcn(''radiocallback'',gcbf);viewimportfcn(''workspace'',gcbf);',...
    'Position',[X0 Y0 RBW TextH], ...
    'String','Workspace', ...
    'Style','radiobutton', ...
    'Value',1);
Y0 = Y0 - 1.5*TextH;
ud.Handles.Mbutton = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Callback','viewimportfcn(''radiocallback'',gcbf);viewimportfcn(''matfile'',gcbf);',...
    'Position',[X0 Y0 RBW TextH], ...
    'String','MAT-file', ...
    'Style','radiobutton');
set(ud.Handles.Wbutton,'UserData',ud.Handles.Mbutton);
set(ud.Handles.Mbutton,'UserData',ud.Handles.Wbutton);

Y0 = Position(2)+1.25*Params.vBorder;
EBW = 0.3*FW;
ud.Handles.BrowseButton= uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'Callback','viewimportfcn(''browsemat'',gcbf);',...
    'Enable','off', ...
    'Position',[X0 Y0 EBW Params.ButtonH], ...
    'String','Browse');
Y0 = Y0 + 1.05*Params.ButtonH;
ud.Handles.FileNameEdit = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'Enable','off', ...
    'Horiz','left',...
    'BackgroundColor',[1 1 1], ...
    'Callback','viewimportfcn(''clearpath'',gcbf)',...
    'Position',[X0 Y0 EBW EditH], ...
    'Style','edit', ...
    'UserData',struct('FileName',[],'PathName',[]));
Y0 = Y0 + 1.2*EditH;
ud.Handles.FileNameText = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Enable','off', ...
    'Position',[X0 Y0 EBW TextH], ...
    'String','MAT-File Name:', ...
    'Style','text');

% Contents list box
LBW = 0.6*FW;   X0 = Position(1)+FW-LBW-hBorder;  Y0 = Position(2);
ud.Handles.ModelList = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',[1 1 1], ...
    'FontName','courier',...
    'Max',2,...
    'Position',[X0 Y0+Params.vBorder LBW FH-2.2], ...
    'String',ListStr, ...
    'Style','listbox', ...
    'Tag','SystemList', ...
    'UserData',AllNames, ...
    'Value',[]);
ud.Handles.ModelText = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'BackgroundColor',Params.StdColor, ...
    'Position',[X0 Y0+FH-1.7 LBW TextH], ...
    'HorizontalAlignment','center',...
    'String','Systems in Workspace', ...
    'Style','text');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCreateButtons %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function ud = LocalCreateButtons(ud,Position,Params)

ImportFig = ud.Figure;
BW = 12; % button width
ButtonH = Params.ButtonH;
Gap = (Position(3)-6*BW)/2;
Y0 = Position(2);

% Add window buttons
X0 = Position(3)/2 - Position(1) - 0.83*BW; 
ud.Handles.OKButton = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'Position',[X0 Y0 BW ButtonH], ...
    'String','OK');
X0 = X0 + BW + Gap;
ud.Handles.CancelButton = uicontrol('Parent',ImportFig, ...
    'Callback','close(gcbf)',...
    'Unit',Params.StdUnit,...
    'Position',[X0 Y0 BW ButtonH], ...
    'String','Cancel');
X0 = X0 + BW + Gap;
ud.Handles.HelpButton = uicontrol('Parent',ImportFig, ...
    'Unit',Params.StdUnit,...
    'Callback','ctrlguihelp(''viewer_import'');',...
    'Position',[X0 Y0 BW ButtonH], ...
    'String','Help');

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalBrowseFilter %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = LocalBrowseFilter(var)
% Checks if given variable should be included in the import browser
% VAR is the structure produced by WHOS
if any(strcmp(var.class,{'tf','ss','zpk','frd'}))
    tf = 1;
elseif any(strcmp(var.class,{'idpoly','idss','idarx','idfrd'}))
    tf = 1;
else 
    tf = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSystemList %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [ListStr,AllNames] = LocalSystemList

WorkspaceVars = evalin('base','whos');
ltivars = zeros(size(WorkspaceVars));
size_str = cell(size(WorkspaceVars));

for ct=1:size(WorkspaceVars,1)
    VarClass=WorkspaceVars(ct).class;
    if any(strcmpi(VarClass,{'ss';'tf';'zpk';'frd'}))
        ltivars(ct)=ct;
        if isequal(length(WorkspaceVars(ct).size),2)
            s = mat2str(WorkspaceVars(ct).size);
            s = strrep(s,' ','x');
            size_str{ct} = s(2:end-1);
        else
            size_str{ct} = [num2str(length(WorkspaceVars(ct).size)),'-D'];
        end
    elseif any(strcmpi(VarClass,{'idpoly';'idss';'idarx';'idfrd'}))
        ltivars(ct)=ct;
        if isequal(length(WorkspaceVars(ct).size),3)
            s = mat2str(WorkspaceVars(ct).size([1 2]));
            s = strrep(s,' ','x');
            size_str{ct} = s(2:end-1);
        else
            size_str{ct} = '4-D';
        end
    end   
end

WorkspaceVars = WorkspaceVars(find(ltivars));

AllNames = strvcat(WorkspaceVars.name);
MaxName = size(AllNames,2);
NameBlanks = repmat(max(0,blanks(15-MaxName)),size(AllNames,1),1);

AllSize = strvcat(size_str{:});
MaxSize = size(AllSize,2);
SizeBlanks = repmat(max(0,blanks(13-MaxSize )),size(AllSize,1),1);

AllClass = strvcat(WorkspaceVars.class);
ListStr = [AllNames,char(NameBlanks),AllSize,char(SizeBlanks),AllClass];
