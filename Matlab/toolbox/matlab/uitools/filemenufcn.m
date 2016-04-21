function filemenufcn(hfig, cmd)
%FILEMENUFCN Implements part of the figure file menu.
%  FILEMENUFCN(CMD) invokes file menu command CMD on figure GCBF.
%  FILEMENUFCN(H, CMD) invokes file menu command CMD on figure H.
%
%  CMD can be one of the following:
%
%    FileClose
%    FileExportSetup
%    FileNew
%    FileOpen
%    FilePageSetup
%    FilePreferences
%    FilePrintPreview
%    FilePrintSetup
%    FileSave
%    FileSaveAs

%    FileExport - merged into FileSaveAs
%    FilePost - internal use only

%  Copyright 1984-2004 The MathWorks, Inc.
%  $Revision: 1.17.4.11 $  $Date: 2004/04/10 23:33:39 $

error(nargchk(1,2,nargin));

if ischar(hfig)
    cmd = hfig;
    hfig = gcbf;
end

switch cmd
    case 'FilePost'
        localPost(hfig)
    case 'UpdateFileNew'
        localUpdateNewMenu(hfig)
    case 'FileNew'
        localNewFigure(hfig)       
    case 'NewGUI'
        guide
    case 'NewVariable'
        localNewVariable(hfig);
    case 'NewModel'
        % Availability of simulink is verified in 'UpdateFileNew'
        open_system(new_system);
    case 'NewMFile'
        com.mathworks.mlservices.MLEditorServices.newDocument;
    case 'FileOpen'
        uiopen figure
    case 'FileClose'
        close(hfig)
    case 'FileSave'
        localSave(hfig)
    case 'FileSaveAs'
        localSaveExport(hfig)
    case 'MFileSaveAs'
        makemcode(hfig,'Output','-editor');
    case 'FileImportData'
        uiimport('-file')
    case 'FileSaveWS'
        localFileSaveWS(hfig);
    case 'FileExport'
        localSaveExport(hfig)
    case 'FileExportSetup'
        exportsetupdlg(hfig)
    case 'FilePreferences'
        preferences
    case 'FilePageSetup'
        pagesetupdlg(hfig)
    case 'FilePrintSetup'
        printdlg -setup
    case 'FilePrintPreview'
        printpreview(hfig)
    case 'FileExitMatlab'
        exit
end

% --------------------------------------------------------------------
function  [jframe] = localGetJavaFrame(hfig)
% Get java frame for figure window

jframe = [];
jpeer = get(hfig,'JavaFrame');
if ~isempty(jpeer)
   jcanvas = jpeer.getAxisComponent; 
   jframe = javax.swing.SwingUtilities.getWindowAncestor(jcanvas);
end

% --------------------------------------------------------------------
function  localFileSaveWS(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getSaveWorkspaceAction;
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localNewVariable(hfig)

jframe = localGetJavaFrame(hfig);
if ~isempty(jframe)
   jActionEvent = java.awt.event.ActionEvent(jframe,1,[]);

   % Call generic desktop component callback
   jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
   jAction = jDesktop.getNewVariableAction;    
   awtinvoke(jAction,'actionPerformed(Ljava.awt.event.ActionEvent;)',jActionEvent);
end

% --------------------------------------------------------------------
function  localUpdateNewMenu(hfig)

% If no simulink, hide 'New Model' menu
res = which(fullfile(matlabroot,'toolbox/simulink/simulink/open_system'));
h = findall(hfig,'type','uimenu','Tag','figMenuFileNewModel');
if isempty(res)
    set(h,'Visible','off')
else
    set(h,'Visible','on');
end

% --------------------------------------------------------------------
function localPost(hfig)
   
filemenuchildren = findall(allchild(hfig),'type','uimenu','Tag','figMenuFile');
    
% hide java dependent items if java is not supported 
if ~usejava('MWT')
    % Hide File -> Preferences
    set(findall(filemenuchildren,'label','figMenuFilePreferences'),'visible','off'); 
end

% Hide callbacks that require a java frame
if isempty(get(hfig,'JavaFrame'))
    set(findall(filemenuchildren,'tag','figMenuFileSaveWorkspaceAs'),'visible','off');
    set(findall(filemenuchildren,'tag','figMenuFileNewVariable'),'visible','off');      
end

% If figure is not docked, hide 'Exit MATLAB' menu
h = findall(filemenuchildren,'type','uimenu','Tag','figMenuFileExitMatlab');
if strcmp(get(hfig,'WindowStyle'),'docked')
    set(h,'Visible','on');
else
    set(h,'Visible','off');
end


% --------------------------------------------------------------------
function localNewFigure(hfig)

% Create a new figure replicating the WindowStyle from source figure.
figure('WindowStyle', get(hfig, 'WindowStyle'));

% --------------------------------------------------------------------
function localSave(hfig)
filename=get(hfig,'filename');
if isempty(filename)
  filemenufcn(hfig,'FileSaveAs');
else
  [types,filter,default_ext] = localGetTypes;
  type_id = localGetDefaultType(types);
  localSaveExportHelper(hfig, filename, types, type_id);
end       

% --------------------------------------------------------------------
function success = localSaveExportHelper(hfig, filename, types, typevalue)

success = false;
try
  if strcmp(types{typevalue,4},'fig')
    saveas(hfig,filename);
  else
    style = localGetStyle(hfig);
    hgexport(hfig,filename,style,'Format',types{typevalue,4});
  end
  set(hfig,'filename',filename);
  setappdata(0,LASTEXPORTEDASTYPE,typevalue);
  success = true;
catch
  uiwait(errordlg(lasterr,'Error Saving Figure','modal'));
end

% --------------------------------------------------------------------
function str = LASTEXPORTEDASTYPE
str = 'FileMenuFcnLastExportedAsType';

% --------------------------------------------------------------------
function [types,filter,default_ext] = localGetTypes;

types = localExportTypes;
type_id = localGetDefaultType(types);

% since the file selection dialog does not allow us to pre-select which
% filter to use, we will always put the default one at the top of the
% list. 
types_to_show = [types(type_id,:); types];
filter = types_to_show(:,1:2);
default_ext = types{type_id,3}; 

% --------------------------------------------------------------------
function filename = localGetFilename(hfig,default_ext)

filename=get(hfig,'filename');

[PATH,FILENAME,EXT] = fileparts(filename);

if isempty(FILENAME)
    FILENAME = 'untitled';
end
if isempty(EXT)
    EXT = default_ext;
end

filename=[FILENAME EXT];

if ~isempty(PATH)
    filename = fullfile(PATH, filename);
end

% --------------------------------------------------------------------
function localSaveExport(hfig)

[types,filter,default_ext] = localGetTypes;
filename = localGetFilename(hfig,default_ext);

% uiputfile on unix will allow saving an empty file name, make sure we get
% a real one.
newfile='';
while isempty(newfile)
    [newfile, newpath, typevalue] = uiputfile(filter, 'Save As',filename);
end

if newfile == 0
    % user pressed cancel
    return;
end

% make sure a reasonable extension is used
[p,f,ext] = fileparts(newfile);
if isempty(ext)
  ext = types{typevalue,3};
  newfile = [newfile ext];
end

filename=fullfile(newpath,newfile);

if typevalue == 1    % means user didn't change from pre-selected
  typevalue = localGetDefaultType(types);
else
  typevalue = typevalue - 1;
end

localSaveExportHelper(hfig, filename, types, typevalue);

% --------------------------------------------------------------------
function list=localExportTypes;

% build the list dynamically from printtables.m
[a,opt,ext,d,e,output,name]=printtables;

% only use those marked as export types (rather than print types)
% and also have a descriptive name
valid=strcmp(output,'X') & ~strcmp(name,'');
name = name(valid);
ext  = ext(valid);
opt  = opt(valid);

% remove eps formats except for the first one
iseps = strncmp(name,'EPS',3);
inds = find(iseps);
name(inds(2:end),:) = [];
ext(inds(2:end),:) = [];
opt(inds(2:end),:) = [];

for i=1:length(ext)
    ext{i} = ['.' ext{i}];
end
star_ext = ext;
for i=1:length(ext)
    star_ext{i} = ['*' ext{i}];
end
description = name;
for i=1:length(name)
    description{i} = [name{i} ' (*' ext{i} ')'];
end

% add fig file support to front of list
star_ext = {'*.fig',star_ext{:}};
description = {'MATLAB Figure (*.fig)',description{:}};
ext = {'.fig',ext{:}};
opt = {'fig',opt{:}};

[description,sortind] = sort(description);
star_ext = star_ext(sortind);
ext = ext(sortind);
opt = opt(sortind);

list = [star_ext(:), description(:), ext(:), opt(:)];

% --------------------------------------------------------------------
function style = localGetStyle(hfig)
style = getappdata(hfig,'Exportsetup');
if isempty(style)
  try
    style = hgexport('readstyle','Default');
  catch
    style = hgexport('factorystyle');
  end
end

function type_id = localGetDefaultType(types)
type_id = getappdata(0,LASTEXPORTEDASTYPE);
if isempty(type_id)
  typeformats = types(:,4);
  type_id = find(strcmp(typeformats,'fig'));
end;
