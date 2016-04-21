function varargout = viewimportfcn(action,ImportFig)
% VIEWIMPORTFCN contains functions standard to all CODA Import windows
%
%   DATA = VIEWIMPORTFCN(ACTION,ImportFig) performs the action specified by 
%   the string ACTION on the Import figure with handle ImportFig. The  
%   output returned in DATA depends on which action is entered.  

%   Possible ACTIONS:
%   1) broswemat:     Opens a standard MATLAB browser for locating a MAT-file
%   2) radiocallback: Performs the actions for the radio buttons
%   3) matfile:       Performs the actions for the MAT-file radio button
%   4) workspace:     Performs the actions for the Workspace radio button

%   Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/09 20:03:08 $

action = lower(action);
if ~ishandle(ImportFig), 
   error('The second input argument must be a valid figure handle.'); 
end 
ImportDB = get(ImportFig,'UserData');  % Database for Import dialog 

switch action
   
case 'browsemat'
    filterspec = '*.mat';
    udFileEdit = get(ImportDB.Handles.FileNameEdit,'UserData');
    LastPath = udFileEdit.PathName;
    CurrentPath=pwd;
    if ~isempty(LastPath),
        cd(LastPath);
    end
    [filename,pathname] = uigetfile(filterspec,'Import file:');
    if ~isempty(LastPath),
        cd(CurrentPath);
    end
    
    if filename,
        if ~strcmpi(pathname(1:end-1),CurrentPath)
            ImportStr = [pathname,filename(1:end-4)];
        else
            ImportStr = filename(1:end-4);
        end
        set(ImportDB.Handles.FileNameEdit,'String',ImportStr);
        viewimportfcn('matfile',ImportFig);
    end
    
case 'clearpath',
    %---Callback for the FileNameEdit box
    %    Whenever a new name is entered, update the Userdata
    NewName = get(gcbo,'String');
    indDot = findstr(NewName,'.');
    if ~isempty(indDot),
        NewName=NewName(1:indDot(end)-1);
        set(ImportDB.Handles.FileNameEdit,'String',NewName)   
    end
    
case 'matfile',
    set(ImportDB.Handles.ModelText,'string','Systems in File');
    set([ImportDB.Handles.FileNameText,...
            ImportDB.Handles.FileNameEdit,...
            ImportDB.Handles.BrowseButton],'enable','on');
    set(ImportDB.Handles.FileNameText,'String','MAT-file name:');
    set(ImportDB.Handles.BrowseButton,'Callback','viewimportfcn(''browsemat'',gcbf);');
    set(ImportDB.Handles.FileNameEdit,...
        'Callback','viewimportfcn(''clearpath'',gcbf);viewimportfcn(''matfile'',gcbf);');
    
    FileName = get(ImportDB.Handles.FileNameEdit,'String');   
    if isempty(FileName),
        Data=struct('Names','','Models',[],'Eval','file'); ListStr = '';
    else
        try
            load(FileName);
            WorkspaceVars=whos;
            [AllNames,ListStr] = LocalSystemList(WorkspaceVars);
            sysvar=cell(size(WorkspaceVars));
            s=0;
            for ct=1:size(WorkspaceVars,1),
                VarClass=WorkspaceVars(ct).class;
                if any(strcmpi(VarClass,{'tf','ss','zpk','frd','idpoly','idss','idarx','idfrd'}))
                    % Only look for (TF, SS, ZPK, FRD, IDPOLY, IDSS, IDARX) LTI Models
                    s=s+1;
                    sysvar(s)={WorkspaceVars(ct).name};
                end % if isa
            end % for ct
            sysvar=sysvar(1:s);
            
            DataModels = cell(s,1);
            for ctud=1:s,
                DataModels{ctud} = eval(sysvar{ctud});
            end % for
            Data = struct('Names',{sysvar},'Models',{DataModels},'Eval','file');
            set(ImportDB.Handles.ModelList,'String',ListStr)
            %---Update the Import Figure Userdata
            ImportDB.ListData=Data;
            set(ImportFig,'UserData',ImportDB);
            
        catch
            warndlg(lasterr,'Import Warning'); 
            set(ImportDB.Handles.FileNameEdit,'String','');
            FileName='';
            Data=struct('Names','','Models',[]); ListStr = '';
        end % try/catch
    end % if/else check on FileName
    
    LocalFinishLoad(ImportFig,ImportDB,FileName,Data,ListStr)
    
case 'radiocallback',
    
    CBObj = gcbo;
    val = get(CBObj,'Value');
    sibs = get(CBObj,'UserData');
    
    if ~val,
        set(CBObj,'Value',1);
    elseif val==1,
        set(sibs,'Value',0);
        set(ImportDB.Handles.FileNameEdit,'String','', ...
            'UserData',struct('FileName',[],'PathName',[]));
    end % if/else val
    
case 'workspace',

    set(ImportDB.Handles.ModelText,'string','Systems in Workspace');
    set([ImportDB.Handles.FileNameText,...
            ImportDB.Handles.FileNameEdit,...
            ImportDB.Handles.BrowseButton],'enable','off');
    
    %----Look for all workspace variables that are system models
    WorkspaceVars = evalin('base','whos');
    [AllNames,ListStr] = LocalSystemList(WorkspaceVars);
    %
    Data = struct('Names',{AllNames},'Models',{WorkspaceVars},'Eval','workspace');
    set(ImportDB.Handles.ModelList,'String',ListStr)
    
    %---Update the Import Figure Userdata
    ImportDB.ListData=Data;
    set(ImportFig,'UserData',ImportDB);
    
case 'help'
    % Callback for Help button
    set(ImportFig,'WindowStyle','normal');
    
end

%-----------------------------Internal Functions--------------------------

%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalFinishLoad %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalFinishLoad(ImportFig,ImportDB,FileName,Data,ListStr)
%---Update the FileNameEdit Userdata

[P,F]=fileparts(FileName);
udNames = get(ImportDB.Handles.FileNameEdit,'UserData');
udNames.PathName=P; 
udNames.FileName=F;
set(ImportDB.Handles.FileNameEdit,'UserData',udNames)

%---Update the Import Figure Userdata
set(ImportDB.Handles.ModelList,'value',1);
set(ImportDB.Handles.ModelList,'String',ListStr)
ImportDB.ListData=Data;
set(ImportFig,'UserData',ImportDB);

function [AllNames,ListStr] = LocalSystemList(WorkspaceVars)

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
