function varargout = cmptool(varargin)
%CMPTOOL MATLAB Builder graphical user interface.
%    CMPTOOL launch MATLAB Builder GUI.

%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.15 $   $Date: 2004/05/07 21:34:18 $

%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.border.*;

%Only allow for single instance of mxljava
f = getappdata(0,'CMPToolHandle');

if ~isempty(f)

  %Functions that rely on running mxltool functions will open mxltool initially  
  if nargin > 0
    switch varargin{1}
      case 'openproject'    
        openproject([],[],f,varargin{2});
    end
  end

  f.show
  return
end

%Check features
x = licavail;
if ~any(x)
  return
end

%Figure spacing
[dfp,mfp,bspc,bhgt,bwid] = spacingparams;
framehgt = 5*bspc+17*bhgt;
frame1wid = 5*bspc+3*bwid;
frame2wid = frame1wid;

%Create base frame
f = JFrame('MATLAB Builder');
imic = javax.swing.ImageIcon(fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif'));
im = imic.getImage;
f.setIconImage(im);
set(f,'WindowClosingCallback', {@closedialog, f})
p = get(0,'DefaultFigurePosition');
f.setBounds(p(1),p(2),p(3),p(4));

%Initialize menu bar
ui.MenuBar = JMenuBar;
set(ui.MenuBar,'Borderpainted','off')
setproperties(ui.MenuBar)

%File Menu
ui.FileMenu = JMenu(xlate('File')); 
ui.FileMenu.setMnemonic('F');
ui.NewProjectItem = addmenuitem(ui.FileMenu,xlate('New Project...'),{@newproject,f},'N');
ui.OpenProjectItem = addmenuitem(ui.FileMenu,xlate('Open Project...'),{@openproject,f},'O');
ui.SaveProjectItem = addmenuitem(ui.FileMenu,xlate('Save Project...'),{@saveproject,f},'S');
ui.SaveAsProjectItem = addmenuitem(ui.FileMenu,xlate('Save As Project...'),{@saveasproject,f},'A');
ui.CloseProjectItem = addmenuitem(ui.FileMenu,xlate('Close Project'),{@closeproject,f},'C');
ui.FileMenu.insertSeparator(5);
ui.CloseMXLItem = addmenuitem(ui.FileMenu,xlate('Close CMPTOOL'),{@closedialog,f},'L');
setproperties(ui.FileMenu)
ui.MenuBar.add(ui.FileMenu);

%Project Menu
ui.ProjectMenu = JMenu(xlate('Project'));
ui.ProjectMenu.setMnemonic('P');
ui.AddFileItem = addmenuitem(ui.ProjectMenu,xlate('Add File...'),{@addfile,f},'A');
ui.EditFileItem = addmenuitem(ui.ProjectMenu,xlate('Edit File...'),{@editfile,f},'E');
ui.RemoveFileItem = addmenuitem(ui.ProjectMenu,xlate('Remove File'),{@removefile,f},'R');
ui.ProjectMenu.insertSeparator(3);
ui.SettingsItem = addmenuitem(ui.ProjectMenu,xlate('Settings...'),{@registration,f},'S');
setproperties(ui.ProjectMenu)
ui.MenuBar.add(ui.ProjectMenu);

%Build Menu
ui.BuildMenu = JMenu(xlate('Build'));
ui.BuildMenu.setMnemonic('B');
if x(1),ui.COMComItem = addmenuitem(ui.BuildMenu,xlate('COM Object'),{@build,f,'com'},'C');end
if x(2),ui.ExcelComItem = addmenuitem(ui.BuildMenu,xlate('Excel/COM Object'),{@build,f,'excelcom'},'E');end
if x(3),ui.JavaItem = addmenuitem(ui.BuildMenu,xlate('Java Object'),{@build,f,'java'},'J');end
if x(4),ui.NetItem = addmenuitem(ui.BuildMenu,xlate('.NET Object'),{@build,f,'.net'},'N');end
if any(x),ui.BuildMenu.insertSeparator(length(find(x)));end
ui.ClearStatusItem = addmenuitem(ui.BuildMenu,xlate('Clear Status'),{@clearstatus,f},'S');
ui.BuildLogItem = addmenuitem(ui.BuildMenu,xlate('Open Build Log'),{@openbuildlog,f},'O');
setproperties(ui.BuildMenu)
ui.MenuBar.add(ui.BuildMenu);

%Component Menu
ui.ComponentMenu = JMenu(xlate('Component'));
ui.ComponentMenu.setMnemonic('C');
ui.PackageItem = addmenuitem(ui.ComponentMenu,xlate('Package Component'),{@package,f},'P');
ui.ComponentMenu.insertSeparator(1);
ui.InfoItem = addmenuitem(ui.ComponentMenu,xlate('Component Info...'),{@compinfo,f},'C');
setproperties(ui.ComponentMenu)
ui.MenuBar.add(ui.ComponentMenu);

%Help Menu
ui.HelpMenu = JMenu(xlate('Help'));
ui.HelpMenu.setMnemonic('H');
ui.ToolHelp = addmenuitem(ui.HelpMenu,xlate('CMPTOOL Help'),{@helptool},'P');
if x(1)
  ui.MainComItem = JMenu(xlate('MATLAB Builder for COM'));
  ui.HelpComItem = addmenuitem(ui.MainComItem,xlate('MATLAB Builder for COM Help'),{@helpcom},'C');
  ui.AboutComItem = addmenuitem(ui.MainComItem,xlate('About MATLAB Builder for COM'),{@aboutcom},'A');
  setproperties(ui.MainComItem)
  ui.HelpMenu.add(ui.MainComItem);
end
if x(2)
  ui.MainExcelItem = JMenu(xlate('MATLAB Builder for Excel'));
  ui.HelpExcelItem = addmenuitem(ui.MainExcelItem,xlate('MATLAB Builder for Excel Help'),{@helpxl},'E');
  ui.AboutExcelItem = addmenuitem(ui.MainExcelItem,xlate('About MATLAB Builder for Excel'),{@aboutxl},'B');
  setproperties(ui.MainExcelItem)
  ui.HelpMenu.add(ui.MainExcelItem);
end
if x(3)
  ui.MainJavaItem = JMenu(xlate('MATLAB Java Builder'));
  ui.HelpJavaItem = addmenuitem(ui.MainJavaItem,xlate('MATLAB Java Builder Help'),{@helpjava},'J');
  ui.AboutJavaItem = addmenuitem(ui.MainJavaItem,xlate('About MATLAB Java Builder'),{@aboutjava},'O');
  setproperties(ui.MainJavaItem)
  ui.HelpMenu.add(ui.MainJavaItem);
end
if x(4)
  ui.MainNetItem = JMenu(xlate('MATLAB .NET Builder'));
  ui.HelpNetItem = addmenuitem(ui.MainNetItem,xlate('MATLAB .NET Builder Help'),{@helpnet},'N');
  ui.AboutNetItem = addmenuitem(ui.MainNetItem,xlate('About MATLAB .NET Builder'),{@aboutnet},'U');
  setproperties(ui.MainNetItem)
  ui.HelpMenu.add(ui.MainNetItem);
end
setproperties(ui.HelpMenu)
ui.MenuBar.add(ui.HelpMenu);

%Add menu to figure
f.setJMenuBar(ui.MenuBar);

%Base panel
BasePanel = JPanel;
BasePanel.setLayout(GridLayout(1,2,bspc,bspc));
setproperties(BasePanel);
f.getContentPane.add(BasePanel);

%Create split pane
splitter = JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
splitter.setBorder([]);
try
  set(splitter,'DividerLocation',floor(p(3)/2));    %Place divider in middle of frame if platform allows it
end
splitter.setDividerSize(bspc);
BasePanel.add(splitter,BorderLayout.CENTER);

%Project Files Panel
ProjectPanel = JPanel;
ProjectPanel.setLayout(BorderLayout(bspc,bspc));
setproperties(ProjectPanel)
ProjectTitle = TitledBorder(LineBorder(java.awt.Color(0,0,0)),xlate('Project Files'));
ProjectTitle.setTitleFont(Font(get(0,'Defaultuicontrolfontname'),0,12))
uiColor = get(0,'Defaultuicontrolforegroundcolor');
ProjectTitle.setTitleColor(java.awt.Color(uiColor(1),uiColor(2),uiColor(3)))
ProjectPanel.setBorder(ProjectTitle)
splitter.setLeftComponent(ProjectPanel)

%Add file button panel
ProjectTopPanel = JPanel;
ProjectTopPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(ProjectTopPanel);
ProjectPanel.add(ProjectTopPanel,BorderLayout.NORTH);

%Add File button
ui.AddButton = JButton(sprintf('Add File'));
ProjectTopPanel.add(ui.AddButton);
setproperties(ui.AddButton)
set(ui.AddButton,'ActionPerformedCallback',{@addfile,f})

%2 Padding Labels
for i = 1:2
  BlankLabel = JLabel;
  setproperties(BlankLabel);
  ProjectTopPanel.add(BlankLabel);
end

%Tree Panel
TreePanel = JPanel;
TreePanel.setLayout(BorderLayout(bspc,bspc));
setproperties(TreePanel);
ProjectPanel.add(TreePanel,BorderLayout.CENTER);

%Tree viewer
top = DefaultMutableTreeNode('Project Files');
tree = DefaultTreeModel(top);
ui.ProjectTree = JTree(tree);
crend = ui.ProjectTree.getCellRenderer;
crend.setBackgroundNonSelectionColor(java.awt.Color(1,1,1));
ui.ProjectTree.setCellRenderer(crend);
set(ui.ProjectTree,'Mouseclickedcallback',{@projectfiles,f})
setproperties(ui.ProjectTree);

%Make tree scrollable
ui.TreeScrollPane = JScrollPane;
ui.TreeScrollPane.getViewport.add(ui.ProjectTree);
TreePanel.add(ui.TreeScrollPane,BorderLayout.CENTER);

%Panel for edit and remove buttons
ProjectBottomPanel = JPanel;
ProjectBottomPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(ProjectBottomPanel);
ProjectPanel.add(ProjectBottomPanel,BorderLayout.SOUTH);

%Edit File button
ui.EditButton = JButton(sprintf('Edit'));
setproperties(ui.EditButton)
set(ui.EditButton,'ActionPerformedCallback',{@editfile,f})
ProjectBottomPanel.add(ui.EditButton);

%Creating padding objects
BlankLabel = JLabel;
setproperties(BlankLabel);
ProjectBottomPanel.add(BlankLabel);

%Remove File button
ui.RemoveButton = JButton(sprintf('Remove'));
setproperties(ui.RemoveButton)
set(ui.RemoveButton,'ActionPerformedCallback',{@removefile,f})
ProjectBottomPanel.add(ui.RemoveButton);

%Build Status panel
BuildPanel = JPanel;
BuildPanel.setLayout(BorderLayout(bspc,bspc));
setproperties(BuildPanel);
BuildTitle = TitledBorder(LineBorder(java.awt.Color(0,0,0)),xlate('Build Status'));
BuildTitle.setTitleFont(Font(get(0,'Defaultuicontrolfontname'),0,12));
BuildTitle.setTitleColor(java.awt.Color(uiColor(1),uiColor(2),uiColor(3)))
BuildPanel.setBorder(BuildTitle)
splitter.setRightComponent(BuildPanel)

%Build Status text
BuildTextPanel = JPanel;
BuildTextPanel.setLayout(BorderLayout(bspc,bspc));
setproperties(BuildTextPanel);
BuildPanel.add(BuildTextPanel);

%Text area
ui.BuildText = JTextArea;
setproperties(ui.BuildText)
set(ui.BuildText,'Editable','off');

%Make text area scrollable
ui.BuildScrollPane = JScrollPane;
ui.BuildScrollPane.getViewport.add(ui.BuildText);
BuildTextPanel.add(ui.BuildScrollPane,BorderLayout.CENTER);

%Build and Clear button panel
BuildButtonsPanel = JPanel;
BuildButtonsPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(BuildButtonsPanel);
BuildPanel.add(BuildButtonsPanel,BorderLayout.SOUTH);

%Creating padding objects
for i = 1:2
  BlankLabel = JLabel;
  setproperties(BlankLabel);
  BuildButtonsPanel.add(BlankLabel);
end

%Clear File button
ui.ClearButton = JButton(sprintf('Clear'));
setproperties(ui.ClearButton)
ui.ClearButton.setBounds(7*bspc+frame1wid+2*bwid,17*bhgt,bwid,bhgt);
set(ui.ClearButton,'ActionPerformedCallback',{@clearstatus,f})
BuildButtonsPanel.add(ui.ClearButton);

%Set application data
setappdata(f,'uidata',ui)
setappdata(f,'mexfiles',[])
setappdata(f,'mfiles',[])
setappdata(f,'saveflag',0)
setappdata(f,'lastfileclick',now)
enablefiles([],[],f,'off')

%Store frame in root window
setappdata(0,'CMPToolHandle',f)
f.show;


function aboutcom(obj,evd)
%ABOUT About MATLAB Builder for COM.

aboutstring = {'MATLAB Builder for COM for use with MATLAB(r)';...
				        ' ';...
               'Version 1.1';...
					    ' ';...
				'Copyright 2001-2004 The MathWorks, Inc.'};
x = msgbox(aboutstring,'About MATLAB Builder');
set(x,'Windowstyle','modal')


function aboutjava(obj,evd)
%ABOUTJAVA About MATLAB Builder for Java Language dialog.

aboutstring = {'MATLAB Builder for Java Language for use with MATLAB(r)';...
				        ' ';...
               'Version 1.0';...
					    ' ';...
				'Copyright 2004 The MathWorks, Inc.'};
x = msgbox(aboutstring,'About MATLAB Builder');
set(x,'Windowstyle','modal')


function aboutxl(obj,evd)
%ABOUT About MATLAB Builder dialog.

aboutstring = {'MATLAB Builder for Excel for use with MATLAB(r)';...
				        ' ';...
               'Version 1.2';...
					    ' ';...
				'Copyright 2001-2004 The MathWorks, Inc.'};
x = msgbox(aboutstring,'About MATLAB Builder');
set(x,'Windowstyle','modal')


function addclass(obj,evd,frame)
%ADDCLASS New class for existing component.

%Get ui data
ui = getappdata(frame,'uidata');

%Get existing classes
classes = getappdata(ui.ClassList,'classes');

%Get class to add
classname = char(ui.ClassName.getText);
if isempty(classname),return,end
j = [findstr(classname,' ') findstr(classname,'.')];
if ~isempty(j)
  errordlg('No spaces or periods are allowed in a class name.')
  return
end

ui.ClassName.setText('');

%Append classname to classes and update Jlist model
classes = unique([classes;{classname}]);
setappdata(ui.ClassList,'classes',classes);
classVector = java.util.Vector;
for i = 1:length(classes)
  classVector.addElement(classes{i});
end
ui.ClassList.setListData(classVector)


function addfile(obj,evd,frame,varargin)
%ADDFILE Add files to project

%Class must be selected to which to add file
a = getappdata(frame); 
lastadddir = getappdata(frame,'lastadddir');
ui = getappdata(frame,'uidata');

%Get 2nd node of first selection path (classes are always in second node)
p = getSelectionPaths(ui.ProjectTree);
try
  nodes = p(1).getPath;  
  selclass = {char(nodes(2).toString)};
  if isempty(p) | isempty(find(strcmp(selclass,a.classes)))
    error('builder:cmptool:selectionError','No path selected or no class selected.')
  end
catch
  errordlg(sprintf('Please select a Class before adding a file.'))
  return
end

%If previous add directory exists, move to it
currentdir = pwd;
if ~isempty(lastadddir)
  cd(lastadddir)
end

%Choose file or use given file
if length(varargin) 
  manadd = 0;
  filename = varargin{1};
  pathname = varargin{2};
  if isempty(pathname)
    pathname = [pwd '\'];
  end
else
  manadd = 1;
  [filename, pathname] = uigetfile( ...
       {'*.m', 'M-files (*.m)'; ...
        '*.dll','MEX-files (*.dll)';...
        '*.*','Other (.mat, .fig, etc) (*.*)'},...
        xlate('Add file to project'));
end 
 
%If cancel, do nothing
if ~pathname
  cd(currentdir)   %Move back to original direcory
  return
end

%save last addfile directory (if manual add) and move back to original directory
if manadd
  setappdata(frame,'lastadddir',pathname)
end
cd(currentdir)

%Do not allow file name with same name as component name
if ~isempty(findstr(['\' a.componentname '.m'],['\' filename]))
  warndlg('Component name has the same name as one of the project''s m-files.   Please change the component name or the build step will fail.','Add File Warning')
  uiwait
end
    
%Determine type of file added
newfile = {[pathname filename]};
j = findstr(newfile{:},'.');
addfileext = lower(newfile{:}(j(1)+1:end));
switch addfileext
  case 'm'   %M-file
    if ~any(strcmp(newfile,a.mfiles(:,1)) & strcmp(selclass,a.mfiles(:,2)))
      newlist = [a.mfiles;newfile selclass];
      [y,i] = sort(upper(newlist(2:end,1)));
      setappdata(frame,'mfiles',newlist([1;i+1],:))
    end
  case {'dll','so'}   %MEX-file  (dll or so extension)
    if ~any(strcmp(newfile,a.mexfiles(:,1)) & strcmp(selclass,a.mexfiles(:,1)))
      setappdata(frame,'mexfiles',[a.mexfiles;newfile selclass])
    end
  otherwise  %Other file type (*.mat, *.fig, etc)
    if ~any(strcmp(newfile,a.mfiles(:,1)) & strcmp(selclass,a.mfiles(:,2)))
      newlist = [a.mfiles;newfile selclass];
      [y,i] = sort(upper(newlist(2:end,1)));
      setappdata(frame,'mfiles',newlist([1;i+1],:))
    end
end      
            
%Update project file list and set save flag
adjusttreelist(obj,evd,frame)
setappdata(frame,'saveflag',1)


function addpackagefile(obj,evd,frame,varargin)
%ADDPACKAGEFILE Add files to package.

ui = getappdata(frame,'uidata');
a = getappdata(frame);
f = getappdata(0,'CMPToolHandle');
lastadddir = getappdata(frame,'lastadddir');

%If previous add directory exists, move to it
currentdir = pwd;
if ~isempty(lastadddir)
  cd(lastadddir)
end

%Choose file or use given file
if length(varargin) 
  manadd = 0;
  filename = varargin{1};
  pathname = varargin{2};
  if isempty(pathname)
    pathname = [pwd '\'];
  end
else
  manadd = 1;
  [filename, pathname] = uigetfile( ...
       {'*.*', 'All files (*.*)'},...
        xlate('Add file to package'));
end 

%If cancel, do nothing
if ~pathname
  cd(currentdir)   %Move back to original direcory
  return
end

%save last addfile directory (if manual add) and move back to original directory
if manadd
  setappdata(frame,'lastadddir',pathname)
end
cd(currentdir)

%Add file to list and update tree
a.packagefiles = [a.packagefiles;{'User Files' [pathname filename]}];
[b,i] = unique(a.packagefiles(:,2));
packagefiles = a.packagefiles(i,:);
setappdata(frame,'packagefiles',packagefiles)
adjustpackagetree(obj,evd,frame)
setappdata(f,'saveflag',1)


function x = addmenuitem(menu,label,callback,keystroke)
%ADDMENUITEM(MENU,LABEL,CALLBACK)

import javax.swing.*;

x = JMenuItem(label);
setproperties(x)
set(x,'Actionperformedcallback',callback);
x.setMnemonic(keystroke)
menu.add(x);


function adjustpackagetree(obj,evd,frame)
%ADJUSTPACKAGETREE Callback for package files list

import javax.swing.tree.*;

%Get ui info
ui = getappdata(frame,'uidata');
a = getappdata(frame);
mcrloc = getappdata(frame,'MCRLocation');

%Determine expanded/collapsed state of each path
visnodes = ui.PackageTree.getRowCount;
paths = cell(visnodes,4);
for i = 1:visnodes
  paths{i,1} = ui.PackageTree.getPathForRow(i-1);
  paths{i,2} = ui.PackageTree.isExpanded(i-1);
  paths{i,3} = char(paths{i,1}.toString);
  paths{i,4} = ui.PackageTree.isRowSelected(i-1);
end

%Define top level of tree
top = DefaultMutableTreeNode('Package Files');
tree = DefaultTreeModel(top);

%Add nodes for each file type
Ucategory = DefaultMutableTreeNode('User Files');
Scategory = DefaultMutableTreeNode('System Files');

%Find user files
if ~isempty(a.packagefiles)
  j = find(strcmp('User Files',a.packagefiles(:,1)));
  for k = 1:length(a.packagefiles(j,2))
    usf = DefaultMutableTreeNode(a.packagefiles{j(k),2});
    Ucategory.add(usf);
  end
  
  %Find system files
  j = find(strcmp('System Files',a.packagefiles(:,1)));
  for k = 1:length(a.packagefiles(j,2))
    syf = DefaultMutableTreeNode(a.packagefiles{j(k),2});
    Scategory.add(syf);  
  end
end

top.add(Ucategory);
top.add(Scategory)

%Add MCR if selected
mcr = ui.CheckBoxMCR.isSelected;
if isempty(mcrloc)
  if ispc
    mcrloc = [matlabroot '\toolbox\compiler\deploy\win32\MCRInstaller.exe'];
  else
    arch = lower(computer);
    mcrloc = [matlabroot '\toolbox\compiler\deploy\' arch '\MCRInstaller.exe'];
  end
end

%Check existence of MCRInstaller.exe
if mcr && exist(mcrloc) ~= 2
  warndlg([mcrloc ' does not exist. Please see help for BUILDMCR.  MCRInstaller ',...
           'has not been added to the package list.'],'MCRInstaller not found')
  ui.CheckBoxMCR.setSelected(0)
  if ~isempty(a.packagefiles) || any(strcmp('MCR Installer',a.packagefiles(:,2)))
    j = find(strcmp('MCR Installer',a.packagefiles(:,2)));
    a.packagefiles(j,:) = [];
    setappdata(frame,'MCRLocation',[])
  end
elseif mcr
  MCRNode = DefaultMutableTreeNode(mcrloc);
  if isempty(a.packagefiles) || ~any(strcmp('MCR Installer',a.packagefiles(:,2)))
    a.packagefiles = [a.packagefiles;{mcrloc 'MCR Installer'}];
    setappdata(frame,'MCRLocation',mcrloc)
  end
  top.add(MCRNode);
else
  if ~isempty(a.packagefiles)  
    j = find(strcmp('MCR Installer',a.packagefiles(:,2)));
    if ~isempty(j)
      a.packagefiles(j,:) = [];
    end
  end
end

%Set tree model
set(ui.PackageTree,'Model',tree)
setappdata(frame,'packagefiles',a.packagefiles)

%Use to previous expansion settings for correct visual display

%Find paths that were expanded and expand them
for i = 1:size(paths,1)
  
  %Get new paths of tree
  newvisnodes = ui.PackageTree.getRowCount;
  newpaths = cell(newvisnodes,2);
  for j = 1:newvisnodes
    newpaths{j,1} = ui.PackageTree.getPathForRow(j-1);
    newpaths{j,2} = char(newpaths{j,1}.toString);
  end
  
  matches = strcmp(newpaths(:,2),paths(i,3));
  if any(matches) & paths{i,2}
    ui.PackageTree.expandRow(find(matches)-1)
  end
  
end

%Find rows that were selected and selected them
for i = 1:size(paths,1)
  matches = strcmp(newpaths(:,2),paths(i,3));
  if any(matches) & paths{i,4}
    ui.PackageTree.setSelectionRow(find(matches)-1)
    return
  end
end


function adjusttreelist(obj,evd,frame)
%PROJECTFILES Callback for project files list

import javax.swing.tree.*;

%Get uicontrol information
ui = getappdata(frame,'uidata');
a = getappdata(frame);

%Determine expanded/collapsed state of each path
visnodes = ui.ProjectTree.getRowCount;
paths = cell(visnodes,4);
for i = 1:visnodes
  paths{i,1} = ui.ProjectTree.getPathForRow(i-1);
  paths{i,2} = ui.ProjectTree.isExpanded(i-1);
  paths{i,3} = char(paths{i,1}.toString);
  paths{i,4} = ui.ProjectTree.isRowSelected(i-1);
end

%Account for Builder for Excel projects that had single class
if isempty(a.classes)
  if ~isempty(a.componentname)  %No component, adjusting to empty tree
    a.classes = {a.componentname};
    a.mfiles(:,2) = a.classes;
    a.mexfiles(:,2) = a.classes;
  end
end

%Define top level of tree
top = DefaultMutableTreeNode('Project Files');
tree = DefaultTreeModel(top);

%Add nodes for each class and it's M/MEX files
for i = 1:length(a.classes)
  
  Ccategory = DefaultMutableTreeNode(a.classes{i});
   
  %Find M-files for given class
  Mcategory = DefaultMutableTreeNode('M-files');
  j = find(strcmp(a.classes{i},a.mfiles(:,2)));
  for k = 1:length(a.mfiles(j,2))
    mmm = DefaultMutableTreeNode(a.mfiles{j(k),1});
    Mcategory.add(mmm);
  end 
  Ccategory.add(Mcategory);
  
  %Find MEX-files for given class
  MEXcategory = DefaultMutableTreeNode('MEX-files');
  j = find(strcmp(a.classes{i},a.mexfiles(:,2)));
  for k = 1:length(a.mexfiles(j,2))
    mex = DefaultMutableTreeNode(a.mexfiles{j(k),1});
    MEXcategory.add(mex);  
  end 
  Ccategory.add(MEXcategory)
  
  top.add(Ccategory)
end

%Set tree model
set(ui.ProjectTree,'Model',tree)

%Use to previous expansion settings for correct visual display

%Find paths that were expanded and expand them
for i = 1:size(paths,1)
  
    %Get new paths of tree
  newvisnodes = ui.ProjectTree.getRowCount;
  newpaths = cell(newvisnodes,2);
  for j = 1:newvisnodes
    newpaths{j,1} = ui.ProjectTree.getPathForRow(j-1);
    newpaths{j,2} = char(newpaths{j,1}.toString);
  end
  
  matches = strcmp(newpaths(:,2),paths(i,3));
  if any(matches) & paths{i,2}
    ui.ProjectTree.expandRow(find(matches)-1)
  end
  
end

%Find rows that were selected and selected them
for i = 1:size(paths,1)
  matches = strcmp(newpaths(:,2),paths(i,3));
  if any(matches) & paths{i,4}
    ui.ProjectTree.setSelectionRow(find(matches)-1)
    return
  end
end


function aok = applyregister(obj,evd,frame)
%APPLYREGISTER Apply registration information.

%Get ui information
f = getappdata(0,'CMPProjSettings');
ui = getappdata(f,'uidata');

%Verify that all information has been entered
try
  componentname = char(ui.CompName.getText);
  if isempty(componentname)
    error('builder:cmptool:missingComponent','Please enter a project component name.')
  end
  j = [findstr(componentname,' ') findstr(componentname,'.')];
  if ~isempty(j)
    error('No spaces or periods are allowed in a component name.')
  end
  ClassListModel = ui.ClassList.getModel;
  i = 1;
  while i
    try
      classes{i} = ClassListModel.getElementAt(i-1);
      if strcmp(lower(classes{i}),'no data model')
        classes = [];
        error('builder:cmptool:missingClass','Please add at least one class name.')
      end
      i = i+1;
    catch
      i = 0;
    end
  end
  if ~exist('classes') || isempty(classes)
    error('builder:cmptool:missingClass','Please add at least one class name.')
  end
  projectversion = char(ui.ProjVer.getText);
  if isempty(projectversion)
    error('builder:cmptool:missingVersion','Please enter a project version, e.g. 1.0')
  end
  projectdirectory = char(ui.ProjDir.getText);
  if isempty(projectdirectory)
    error('builder:cmptool:missingProjDir','Please enter a project directory.')
  end
catch
  errstr = lasterr;
  i = find(errstr == 10);    %Strip off first line of message
  errordlg(errstr(i(1):end))
  aok = 0;     %Failure flag
  return
end

%Store project registration information and return success flag
setappdata(frame,'componentname',componentname)
setappdata(frame,'classes',classes)
setappdata(frame,'projectversion',projectversion)
if ((projectdirectory(end) == '\') | (projectdirectory(end) == '/'))
  projectdirectory(end) = [];     %mkdir fails if trailing /
end
setappdata(frame,'projectdir',projectdirectory)

%For existing project, remove any mfiles/mexfiles associated with removed class
a = getappdata(frame);
allfiles = [a.mfiles(2:end,:);a.mexfiles(2:end,:)];   %First row is empty placeholder
oldclasses = setdiff(allfiles(:,2),classes);

%M-file removal
for i = 1:length(oldclasses)
  j = find(strcmp(oldclasses(i),a.mfiles(:,2)));
  a.mfiles(j,:) = [];
end

%MEX-file removal
for i = 1:length(oldclasses)
  j = find(strcmp(oldclasses(i),a.mexfiles(:,2)));
  a.mexfiles(j,:) = [];
end

%Save new file lists
setappdata(frame,'mfiles',a.mfiles)
setappdata(frame,'mexfiles',a.mexfiles)

%Give user option of creating directory if it doesn't exist
if (exist(projectdirectory) ~= 7)
  bname = questdlg(sprintf('%s does not exist.  Create it?', projectdirectory), xlate('Project directory'),'Yes','No','Yes');
  try
    switch bname
      case 'Yes'
        i = find((projectdirectory == '\') | (projectdirectory == '/'));
        if isempty(i)
          [s,m] = mkdir(projectdirectory);
          if ~s
            errordlg(m)
            return
          end
        else
          if (exist(projectdirectory) ~= 7)
            [s,m] = mkdir(projectdirectory);
            if ~s
              error(m)
            end
          end
        end
      case 'No'
        %Return to settings dialog
        aok = 0;
        return
    end
  catch
    errordlg(lasterr)
    aok = 0;
    return
  end
end      
setappdata(frame,'projectdir',projectdirectory)

%Create java package path (done for all flavors)

%Need to create source directory at top level
tmpcomponent = ['src.' componentname];  

%Parse periods in componentname to get directory names
j = findstr(tmpcomponent,'.');
dirnames = cell(length(j),1);

%Pad '.' indices with 0 to account for first entry
j = [0 j];
for i = 1:length(j)-1
  dirnames{i} = tmpcomponent(j(i)+1:j(i+1)-1);
end
%increment counter to get last directory name 
i = i+1;
dirnames{i} = tmpcomponent(j(i)+1:end);

%Make directories
parentdir = projectdirectory;
for k = 1:i
  [s,m,id] = mkdir([parentdir '\'],dirnames{k});
  if ~s
    errordlg(m)
    return
  end
  parentdir = [parentdir '\' dirnames{k}];
end

%Get switches
if ui.CheckBoxDebug.isSelected,debugswitch = '-g';else,debugswitch = [];end
if ui.CheckBoxVerbose.isSelected,verboseoutput = '-v';else,verboseoutput = [];end

setappdata(frame,'debugswitch',debugswitch)
setappdata(frame,'verboseoutput',verboseoutput)
setappdata(frame,'saveflag',1)

%Success
aok = 1;


function x = licavail()
%LICAVAIL Feature checker.

x = [license('test','MATLAB_COM_Builder');...
     license('test','MATLAB_Excel_Builder');...
     license('test','MATLAB_Java_Builder');...
     license('test','MATLAB_NET_Builder')];


function browseprojdir(obj,evd,frame)
%BROWSEPROJDIR Get project directory.

%Open get directory dialog
p = uigetdir;

%Return of 0 is cancel, otherwise display chosen directory
if isa(p,'double')
  return
else
  ui = getappdata(frame,'uidata');
  ui.ProjDir.setText(p)
end


function build(obj,evd,frame,btype)
%BUILD Build project.
%   BUILD(BTYPE) builds the current project.  BTYPE determines what kind of build
%   action to take.

%Get ui data, define file separator
ui = getappdata(frame,'uidata');
a = getappdata(frame);
if ispc, ds = '\'; else, ds = '/'; end 

%Get current cursor type
cursFrame = frame.getCursor;
cursBuildText = ui.BuildText.getCursor;
frame.setCursor(java.awt.Cursor(3))
ui.BuildText.setCursor(java.awt.Cursor(3))

%Clear old build status
clearstatus(obj,evd,frame)

%Move to current project's directory to generate build files.   If file hasn't been saved, move the MATLAB startup directory
%This prevents files from being saved into a toolbox directory or some other desired location
currentdir = pwd;
if ~isempty(a.projectdir)
  cd(a.projectdir)
end

%Get project settings
a = getappdata(frame);

%Component name cannot be the same as a project file (tries to create multiple .c files of same name)
for i = 1:size(a.mfiles,1)
  if ~isempty(findstr(['\' a.componentname '.m'],a.mfiles{i,1}))
    errordlg(sprintf('Component name has the same name as one of the project''s m-files.   Please enter a unique component name in the Project Settings dialog.'))
    cd(currentdir)
    frame.setCursor(cursFrame)
    ui.BuildText.setCursor(cursBuildText)
    return
  end
end

%Create output directory
if ~(exist([pwd '\src']) == 7)
  [s,m] = mkdir('src');
  if ~s
    errordlg(m)
    frame.setCursor(cursFrame)
    ui.BuildText.setCursor(cursBuildText)
    return
  end
end

%Get files from mmexfiles for -a switch
tmpfiles = [a.mfiles(1:end,:);a.mexfiles(1:end,:)];
otherfiles = [];
j = [];
for i = 1:size(tmpfiles,1)
  if ~isempty(tmpfiles{i,1})
    k = findstr(tmpfiles{i},'.');
    switch lower(tmpfiles{i}(k(1)+1:end))
        case {'m','dll','so'}
        otherwise
          otherfiles = [otherfiles ' -a ' tmpfiles{i}];
          j = [j;i]; 
    end
  end
end
tmpfiles(j,:) = [];  %Remove other files from mmexfiles list

%Build class and corresponding M/MEX files lists, first class list has different format
classstring = ' ';
for i = 1:length(a.classes)
      
  switch i
      
    %First class is default and has different command syntax
    case 1
      classname = a.classes{i};
      mmexfiles = [];
      j = find(strcmp(a.classes{i},tmpfiles(:,2)));
      for k = 1:length(j)
        mmexfiles = [mmexfiles '''' tmpfiles{j(k),1} ''' '];
      end
          
    %Remaining classes have same syntax
    otherwise
      classstring = [classstring 'class{' a.classes{i} ':'];
      j = find(strcmp(a.classes{i},tmpfiles(:,2)));
      for k = 1:length(j)
        classstring = [classstring tmpfiles{j(k),1} ','];
      end
      classstring(end) = '}';
      classstring = [classstring ' '];
          
  end
end

%Build compiler command string without M/MEX files
switch btype
    
  case 'com'
      
    %Compiler command
    compcomm = {['mcc -M -silentsetup -d ''' a.projectdir '\src'' ' a.verboseoutput ' -B ''ccom:' a.componentname ',' classname ',' a.projectversion ''' ' a.debugswitch ' -i ' mmexfiles ' ' classstring otherfiles]};    
    
    j = findstr('\',compcomm{:});
    compcomm{:}(j) = '/';
    newstr = ['Building COM object...\n' compcomm{:}];    
    compstr = 'Standalone DLL build complete.';
    
  case 'excelcom'
    
    %Compiler command
    compcomm = {['mcc -M -silentsetup -d ''' a.projectdir '\src'' ' a.verboseoutput ' -B ''cexcel:' a.componentname ',' a.classes{:} ',' a.projectversion ''' ' a.debugswitch ' -bi ']};
    
    %Add files to build command
    compfiles = tmpfiles(:,1);
    for i = 1:length(compfiles)
      if ~isempty(compfiles{i})
        compcomm = {[compcomm{:} ' ''' compfiles{i} ''' ']};
      end
    end
    compcomm = {[compcomm{:} otherfiles]};
    j = findstr('\',compcomm{:});
    compcomm{:}(j) = '/';
    newstr = ['Building COM object and generating VBA code...\n' compcomm{:}];    
    compstr = 'Standalone DLL and VBA code build complete.\n';

end

set(ui.BuildText,'Text',sprintf(newstr))
vscrollbar = ui.BuildScrollPane.getVerticalScrollBar;
vscrollbar.setValue(vscrollbar.getMaximum)

%Evaluate compiler command and show verbose compiler output in status
err = 0;
try
  verifyfiles(obj,evd,frame);
  comout = evalc(compcomm{:},'err=1;comout = lasterr;');
  ststr = get(ui.BuildText,'Text');
  if isempty(comout)
    error(sprintf('Build error.'))
  end
  j = findstr('\',comout);
  comout(j) = '/';
  ui.BuildText.append(sprintf('\n'))
  ui.BuildText.append(comout)
  vscrollbar.setValue(vscrollbar.getMaximum)
   
  %Throw error if one occurred
  if err
    error(lasterr)
  end
  
catch
  createbuildlog(obj,evd,frame)
  errordlg(lasterr)
  cd(currentdir)
  frame.setCursor(cursFrame)
  ui.BuildText.setCursor(cursBuildText)
  return
end

%Move files to be distributed to a subdirectory called distrib
ui.BuildText.append(sprintf('\n'))
ui.BuildText.append('Creating distrib directory.')
vscrollbar.setValue(vscrollbar.getMaximum);
if (exist([pwd ds 'distrib']) ~= 7)  
  mkdir('distrib')
end

%Move files to distrib
ui.BuildText.append(sprintf('\n'))
ui.BuildText.append('Moving files to distrib.')
ui.BuildText.append(sprintf('\n'))
vscrollbar.setValue(vscrollbar.getMaximum);
i = find(a.projectversion == '.');
a.projectversion(i) = '_';

%Get dllname from componentname and copy to distrib
j = findstr(a.componentname,'.');
if length(j) == 0
  dll = a.componentname;
else
  dll = a.componentname(j(end)+1:end);
end
if ispc
  dllname = [dll '_' a.projectversion '.dll'];
else
  dllname = ['lib' dll '_' a.projectversion '.so'];
end
[s,m] = copyfile(['src' ds dllname],'distrib');
if ~s
  errordlg(lasterr)
  cd(currentdir)
  frame.setCursor(cursFrame)
  ui.BuildText.setCursor(cursBuildText)
  return
end
delete(['src' ds dllname]);

%Move CTF file to distrib
[s,m] = copyfile(['src' ds dll '.ctf'],'distrib');
if ~s
  errordlg(lasterr)
  cd(currentdir)
  frame.setCursor(cursFrame)
  ui.BuildText.setCursor(cursBuildText)
  return
end
delete(['src' ds dll '.ctf']);

%Move .bas file if Excel Builder target
switch btype
  case 'excelcom'
    basfile = [a.componentname '.bas'];
    [s,m] = copyfile(['src' ds basfile],'distrib');
    if ~s
      errordlg(lasterr)
      cd(currentdir)
      frame.setCursor(cursFrame)
      ui.BuildText.setCursor(cursBuildText)
      return
    end
    delete(['src' ds basfile]);
end

%If is exists, move bin directory to distrib
if (exist([pwd '\src\bin']) == 7)
  
  %Create distrib/bin if it doesn't exist
  if (exist([pwd '\distrib\bin']) ~= 7)
    mkdir([pwd '\distrib'],'bin');
  end
  
  %Copy files
  x = dir('src\bin');
  for i = 3:length(x)
    [s,m] = copyfile(['src\bin\' x(i).name],'distrib\bin');
    if ~s
      errordlg(m)
      frame.setCursor(cursFrame)
      ui.BuildText.setCursor(cursBuildText)
      return
    end
  end
  
end
  
%Register the new location if COM or Builder for Excel
switch btype
    
  case {'com','excelcom'}
    ui.BuildText.append('Registering new location of DLL.')
    ui.BuildText.append(sprintf('\n'));
    ui.BuildText.append(['mwregsvr ' pwd '\distrib\' dllname]);
    ui.BuildText.append(sprintf('\n'));
    [s,m] = system(['mwregsvr distrib\' dllname]);
    if s
      createbuildlog(obj,evd,frame)
      errordlg(sprintf('Unable to register %s : %s',dllname,m))
      cd(currentdir)
      frame.setCursor(cursFrame)
      ui.BuildText.setCursor(cursBuildText)
      return
    end
    
    %Create list of package files
    ui.BuildText.append('Creating file list for deployment package.')
    ui.BuildText.append(sprintf('\n'));
    packagefiles = {'distrib\_install.bat';...
                      ['distrib\' a.componentname '_' a.projectversion '.dll']};
                      
    if strcmp(btype,'excelcom')
      packagefiles = [packagefiles;...
                      {['distrib\' a.componentname '.bas']};,...
                      {['' matlabroot '\toolbox\matlabxl\matlabxl\mlfunction.xla']};...
                      {['' matlabroot '\toolbox\matlabxl\matlabxl\mlfunction.chm']}];
    end
    
end

%Add any MEX files to the deployment
for i = 2:size(a.mexfiles,1)
  packagefiles = [packagefiles;a.mexfiles(i,1)];
end

%Add CTF file to package list
packagefiles = [packagefiles;{['distrib' ds dll '.ctf']}];

%Process package list
tmp = {'System Files'};
packagefiles = [tmp(ones(length(packagefiles),1),:) packagefiles];
setappdata(frame,'packagefiles',packagefiles)

%Creating installation script for deployment
ui.BuildText.append('Creating installation script for deployment.')
ui.BuildText.append(sprintf('\n'));
createscript(obj,evd,frame,btype,a.componentname,a.projectversion);

%Add completion message
ui.BuildText.append(sprintf('\n'));
ui.BuildText.append(sprintf(compstr));
vscrollbar.setValue(vscrollbar.getMaximum);
   
%Move back to the original directory location
createbuildlog(obj,evd,frame)
cd(currentdir)
frame.setCursor(cursFrame)
ui.BuildText.setCursor(cursBuildText)


function cancelregister(obj,evd,frame)
%CANCELREGISTER Close registration dialog with applying changes.

%Set project save flag
setappdata(frame,'saveflag',0)
f = getappdata(0,'CMPProjSettings');
f.dispose;
setappdata(0,'CMPProjSettings',[])

function cleanupdialog(obj,evd)
%CLEANUPDIALOG Visual enhancement of dialog.

%Set colors and alignment
e = findobj(gcf,'Style','edit');
l = findobj(gcf,'Style','listbox');
p = findobj(gcf,'Style','popupmenu');
set([e;l;p],'Backgroundcolor','white','Horizontalalignment','left')
dbc = get(0,'Defaultuicontrolbackgroundcolor');
set(gcf,'Color',dbc)

%Make text boxes proper width
textuis = findobj(gcf,'Style','text');
for i = 1:length(textuis)
  pos = get(textuis(i),'Position');
  ext = get(textuis(i),'Extent');
  set(textuis(i),'Position',[pos(1) pos(2) ext(3) pos(4)])
end
set(textuis,'Backgroundcolor',dbc)

%Normalize units
set(findobj(gcf,'Type','uicontrol'),'Units','normal')


function clearstatus(obj,evd,frame)
%CLEARSTATUS Clear build status window.

%Get ui data
ui = getappdata(frame,'uidata');
set(ui.BuildText,'Text','')


function closecompinfo(obj,evd,f)
%CLOSECOMPINFO Close component information dialog.

f.dispose
setappdata(0,'CompInfo',[])


function closedialog(obj,evd,frame)
%CLOSEDIALOG Close COMTOOL

%Save project if unsaved 
if getappdata(frame,'saveflag')
  switch unsavedproject(obj,evd,frame)
    case 1
      saveproject(obj,evd,frame) %Save project
    case -1
      return      %Cancel
    case 0
      %Continue with no save operation
  end
end

%If package window is open, close it
f = getappdata(0,'PackageDialog');
if ~isempty(f)
  f.dispose
  setappdata(0,'PackageDialog',[])
end

%If component info dialog is open, close it
infof = getappdata(0,'CompInfo');
if ~isempty(infof)
  infof.dispose
  setappdata(0,'CompInfo',[])
end

%If project settings dialog is open, close it
projset = getappdata(0,'CMPProjSettings');
if ~isempty(projset)
  projset.dispose
  setappdata(0,'CMPProjSettings',[])
end

%Close dialog
setappdata(0,'CMPToolHandle',[])
frame.dispose


function closepackagedialog(obj,evd,frame)
%CLOSEPACKAGEDIALOG 

%Store package information in base frame
f = getappdata(0,'CMPToolHandle');
ui = getappdata(frame,'uidata');
packagefiles = getappdata(frame,'packagefiles');
if ui.CheckBoxMCR.isSelected;
  mcrloc = getappdata(frame,'MCRLocation');
else
  mcrloc = [];
end
setappdata(f,'packagefiles',packagefiles)
setappdata(f,'MCRLocation',mcrloc)
setappdata(f,'saveflag',1)

%Close dialog
frame.dispose
setappdata(0,'PackageDialog',[])


function c = closeproject(obj,evd,frame)
%CLOSEPROJECT Close project.

%Check save flag to prompt for current project save if necessary
c = 0;   %Initialize close flag
if getappdata(frame,'saveflag')
  switch unsavedproject(obj,evd,frame)
    case 1
      saveproject(obj,evd,frame) %Save project
      c = 0;
    case -1
      c = 1;
      return      %Cancel
    case 0
      %Continue with no save operation
      c = 0;
  end
end

%If package window is open, close it
f = getappdata(0,'PackageDialog');
if ~isempty(f)
  f.dispose
  setappdata(0,'PackageDialog',[])
end

%If component info dialog is open, close it
infof = getappdata(0,'CompInfo');
if ~isempty(infof)
  infof.dispose
  setappdata(0,'CompInfo',[])
end

%If project settings dialog is open, close it
projset = getappdata(0,'CMPProjSettings');
if ~isempty(projset)
  projset.dispose
  setappdata(0,'CMPProjSettings',[])
end

%Clear project data
ui = getappdata(frame,'uidata');
setappdata(frame,'mfiles',cell(1,2))
setappdata(frame,'mexfiles',cell(1,2))
setappdata(frame,'projectdir',[])
setappdata(frame,'projectname',[])
setappdata(frame,'componentname',[])
setappdata(frame,'classes',[])
setappdata(frame,'projectversion',[])
setappdata(frame,'debugswitch',[])
setappdata(frame,'verboseoutput',[])
setappdata(frame,'packagefiles',[])
setappdata(frame,'MCRLocation',[])

%Update tree list for empty project
adjusttreelist(obj,evd,frame)

%Disable Project and Build menus
enablefiles(obj,evd,frame,'off')

%Clear dialog name
set(frame,'Title','MATLAB Builder')


function coderadio(obj,evd,frame)
%CODERADIO Toggle code type radio buttons.

%Get ui data from dialog
ui = getappdata(frame,'uidata');

%Turn off all radio buttons
ui.RadioButtonC.setSelected(0);
ui.RadioButtonCp.setSelected(0);

%Turn on selected radio button
set(gcbo,'Selected','on')


function compinfo(obj,evd,frame)
%COMPINFO Component information dialog

%If component info dialog is already, show it
infof = getappdata(0,'CompInfo');
if ~isempty(infof)
  infof.show
  return
end

%Get current component name
componentname = getappdata(frame,'componentname');

%Get raw component information
ci = componentinfo(componentname);
if isempty(ci)
  errordlg(sprintf('No information found for component: %s ',componentname))
  return
end

%Create revision numbers
revnums = cell(length(ci),1);
for i = 1:length(ci)
  revnums{i} = [num2str(ci(i).MajorRev) '.' num2str(ci(i).MinorRev)];
end
  
%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.border.*;

%Build dialog with component information
[dfp,mfp,bspc,bhgt,bwid] = spacingparams;

%Create base frame
infof = JFrame(['Component - ' componentname]);
imic = javax.swing.ImageIcon(fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif'));
im = imic.getImage;
infof.setIconImage(im);
set(infof,'WindowClosingCallback', {@closecompinfo, infof})
p = get(0,'DefaultFigurePosition');
top = p(4)-2*bhgt-bspc;
rgt = 8*bspc+5*bwid;
infof.setBounds(p(1),p(2),rgt,top);

%Base panel
BasePanel = JPanel;
BasePanel.setLayout(BorderLayout(bspc,bspc));
%BasePanel.setBorder(LineBorder(java.awt.Color(0,0,0)))
setproperties(BasePanel);
infof.getContentPane.add(BasePanel);

%Tree Panel
TreePanel = JPanel;
TreePanel.setLayout(BorderLayout(bspc,bspc));
setproperties(TreePanel);
BasePanel.add(TreePanel,BorderLayout.NORTH);

%Tree viewer
top = DefaultMutableTreeNode(['Name - ' upper(componentname)]);
tree = DefaultTreeModel(top);
ui.ProjectTree = JTree(tree);
setproperties(ui.ProjectTree);

%Add tree information

%Revision, etc information
Versions = DefaultMutableTreeNode('Version');
for i = 1:length(revnums)
  
  %Revision numbers
  Revnum = DefaultMutableTreeNode(revnums{i});
  
  %ID information
  TypeLibrary = DefaultMutableTreeNode(['Type Library: ' ci(i).TypeLib]);
  LibID = DefaultMutableTreeNode(['Library ID: ' ci(i).LIBID]);
  FileName = DefaultMutableTreeNode(['File Name: ' ci(i).FileName]);
  Revnum.add(TypeLibrary)
  Revnum.add(LibID)
  Revnum.add(FileName)
  
  %Class information
  Class = DefaultMutableTreeNode('Classes');
  numclasses = length(ci(i).CoClasses);
  for j = 1:numclasses
    
    ClassName = DefaultMutableTreeNode(['Name: ' ci(i).CoClasses(j).Name]);
    ClassID = DefaultMutableTreeNode(['Class ID: ' ci(i).CoClasses(j).CLSID]);
    ProgID = DefaultMutableTreeNode(['Program ID: ' ci(i).CoClasses(j).ProgID]);
    InProcServ = DefaultMutableTreeNode(['In Process Server: ' ci(i).CoClasses(j).InprocServer32]);
    ClassName.add(ClassID)
    ClassName.add(ProgID)
    ClassName.add(InProcServ)
    
    %Methods information
    Methods = DefaultMutableTreeNode('Methods');
    nummethods = length(ci(i).CoClasses(j).Methods);
    for k = 1:nummethods
      methM = DefaultMutableTreeNode(ci(i).CoClasses(j).Methods(k).M);
      Methods.add(methM);
    end
    ClassName.add(Methods)
    
    %Properties information
    Properties = DefaultMutableTreeNode('Properties');
    numprops = length(ci(i).CoClasses(j).Properties);
    for m = 1:numprops
      prop = DefaultMutableTreeNode(ci(i).CoClasses(j).Properties{m});
      Properties.add(prop);
    end
    ClassName.add(Properties)
    
    %Events information
    Events = DefaultMutableTreeNode('Events');
    numevents = length(ci(i).CoClasses(j).Events);
    for n = 1:numevents
      evnt = DefaultMutableTreeNode(ci(i).CoClasses(j).Events(n).M);
      Events.add(evnt);
    end
    ClassName.add(Events)
    
    Class.add(ClassName)
    
  end
 
  %Interface information
  Interfaces = DefaultMutableTreeNode('Interfaces');
  for j = 1:length(ci(i).Interfaces)
     IntName = DefaultMutableTreeNode(['Name: ' ci(i).Interfaces(j).Name]);
     IntID = DefaultMutableTreeNode(['Interface ID: ' ci(i).Interfaces(j).IID]);
     Interfaces.add(IntName)
     Interfaces.add(IntID)
  end
  Revnum.add(Class)
  Revnum.add(Interfaces)
  Versions.add(Revnum)
end
top.add(Versions)

%Make tree scrollable
ui.TreeScrollPane = JScrollPane;
ui.TreeScrollPane.getViewport.add(ui.ProjectTree);
TreePanel.add(ui.TreeScrollPane,BorderLayout.CENTER);

%Panel for Help and Close buttons
CompInfoBottomPanel = JPanel;
CompInfoBottomPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(CompInfoBottomPanel);
BasePanel.add(CompInfoBottomPanel,BorderLayout.SOUTH);

%Help button
ui.HelpButton = JButton(sprintf('Help'));
setproperties(ui.HelpButton)
set(ui.HelpButton,'ActionPerformedCallback',{@helpcompinfo})
CompInfoBottomPanel.add(ui.HelpButton);

%Creating padding objects
BlankLabel = JLabel;
setproperties(BlankLabel);
CompInfoBottomPanel.add(BlankLabel);

%Close button
ui.CloseButton = JButton(sprintf('Close'));
setproperties(ui.CloseButton)
set(ui.CloseButton,'ActionPerformedCallback',{@closecompinfo, infof})
CompInfoBottomPanel.add(ui.CloseButton);

infof.show
setappdata(0,'CompInfo',infof)   %Store handle in case project or parent dialog gets closed


function createbuildlog(obj,evd,frame)
%CREATEBUILDLOG Write build status to log file in project directory.

%Get build status string
ui = getappdata(frame,'uidata');
buildstr = get(ui.BuildText,'Text');

%Open build log file
fid = fopen('build.log','w');

%Write status to file
if fid > 0
  fprintf(fid,'%s',buildstr);
end

%Close log file
fclose(fid);


function createpackage(obj,evd,frame)
%CREATEPACKAGE Package component for deployment to client desktops

%Build zip command with file list

%Need componentname, projectversion to identify which DLL to package
f = getappdata(0,'PackageDialog');
a = getappdata(frame);
a.packagefiles = getappdata(f,'packagefiles');
zipfilename = a.componentname;
j = findstr(zipfilename,'.');
zipfilename(j) = [];

%Convert . to _ in version number
i = find(a.projectversion == '.');
a.projectversion(i) = '_';

%Check existence of Add-In
a.projectdir = getappdata(frame,'projectdir');

waitfig = waitbar(0,'Packaging component for distribution...');

%Move to project directory
currentdir = pwd;
cd(a.projectdir)

%Create long file list from packagefiles
filelist = [];
for i = 1:size(a.packagefiles,1)
  if strcmp(a.packagefiles(i,2),'MCR Installer')
    filelist = [filelist ' ' a.packagefiles{i,1}];
  else
    filelist = [filelist ' ' a.packagefiles{i,2}];
  end
end

waitbar(.25,waitfig,'Created zip file list and creating zip file');

if ispc
  ds = '\';
  mvcommand = 'rename';
  delcommand = 'del';
  cpcommand = 'copy /b';
else
  ds = '/';
  mvcommand = 'mv';
  delcommand = 'rm';
  cpcommand = 'cp';
end

%Execute zip command
if exist([a.projectdir ds 'distrib' ds zipfilename '.zip'])
[s,w] = system([delcommand ' distrib' ds zipfilename '.zip']);
  if s
    close(waitfig)
    errordlg(w)
    cd(currentdir)
    return
  end
end

[s,w] = system(['zip -q -j distrib' ds zipfilename ' ' filelist]);
if s
  close(waitfig)
  errordlg(w)
  cd(currentdir)
  return
end

waitbar(.50,waitfig,'Adding bin directory to zip if necessary...');

%Add bin directory to zip file if it exists
if (exist([a.projectdir ds 'distrib' ds 'bin']) == 7)
  cd('distrib')
  [s,w] = system(['zip -q ' zipfilename ' bin' ds '*']);
  if s
    close(waitfig)
    errordlg(w)
    cd(currentdir)
    return
  end
  cd('..')
end

if isunix
  %Stop after creating zip file
  close(waitfig)
  return
end

%Turn zip file into self extracting executable
if exist([a.projectdir ds 'distrib' ds zipfilename '.ZZZ'])
  [s,w] = system([delcommand ' distrib' ds zipfilename '.ZZZ']);
  if s
    close(waitfig)
    errordlg(w)
    cd(currentdir)
    return
  end
end
%Rename zip file
[s,w] = system([mvcommand ' distrib' ds zipfilename '.zip ' zipfilename '.ZZZ']);
if s
  close(waitfig)
  errordlg(w)
  cd(currentdir)
  return
end

waitbar(.75,waitfig,'Creating self-extracting executable...');

%Make binary copy of file prepending unzip utility
[s,w] = system([cpcommand ' ' matlabroot ds 'extern' ds 'lib' ds 'win32' ds 'mwunzipsfx.exe+distrib' ds zipfilename '.ZZZ distrib' ds zipfilename '.zip']);
if s
  close(waitfig)
  errordlg(w)
  cd(currentdir)
  return
end

%Delete ZZZ file
if exist([a.projectdir ds 'distrib' ds zipfilename '.ZZZ'])
  [s,w] = system([delcommand ' distrib' ds zipfilename '.ZZZ']);
  if s
    close(waitfig)
    errordlg(w)
    cd(currentdir)
    return
  end
end

%Turn zip file in executable
[s,w] = system(['zip -A distrib' ds zipfilename '.zip']);
if s
  close(waitfig)
  errordlg(w)
  cd(currentdir)
  return
end
if exist([a.projectdir ds 'distrib' ds zipfilename '.exe'])
  [s,w] = system([delcommand ' distrib' ds zipfilename '.exe']);
  if s
    close(waitfig)
    errordlg(w)
    cd(currentdir)
    return
  end
end
[s,w] = system([mvcommand ' distrib' ds zipfilename '.zip ' zipfilename '.exe']);
if s
  close(waitfig)
  errordlg(w)
  cd(currentdir)
  return
end

%Show success and close waitbar
waitbar(1,waitfig,'Done.')
close(waitfig)

%Move to original directory
cd(currentdir)


function createscript(obj,evd,frame,btype,componentname,projectversion)
%CREATESCRIPT Installation script creation.
%   CREATESCRIPT(OBJ,EVD,FRAME,BTYPE) where BTYPE is build flavor.

scriptfile = 'distrib\_install.bat';

%Create list of commands
commands = {'echo off';...
           ['echo Deploying project ' componentname ', version ' projectversion];...
            'echo Running MCRInstaller if present...';...
            'MCRInstaller.exe';...
            'echo Registering DLL''s';...
            'set path=%path%;.\MATLAB Component Runtime\v70\runtime\win32'};
           
switch btype
    
  case {'com','excelcom'}
      
    commands = [commands;{['regsvr32 ' componentname '_' projectversion '.dll']}];    %register project dll
    
end
  
commands = [commands;{'echo Installation complete.'}];
commands = [commands;{'echo Please refer to documentation for any additional setup steps.'}];

%Write commands to script file
fid = fopen(scriptfile,'wt');
if fid > 0
  for i = 1:length(commands)
    fprintf(fid,'%s\n',commands{i});
  end
  fclose(fid);
end
    

function editfile(obj,evd,frame)
%EDITMFILE Create new mfile.

%Get selected file name
ui = getappdata(frame,'uidata');
rsel = double(get(ui.ProjectTree,'SelectionRows'));
paths = get(ui.ProjectTree,'SelectionPaths');

%Edit all selected files if possible
for i = 1:length(rsel)
  file = char(toString(paths(i).getLastPathComponent));
  file = fliplr(deblank(fliplr(deblank(file))));
  
  if exist(file) == 0   
    return   %File does not exist
  end
  
  j = find(strcmp(file,{'Project Files','M-files','MEX-files'}));
  if isempty(j)
    if ~(exist(file) == 3)
      try  
        eval(['edit ''' file '''']);
      catch
        errordlg(lasterr)
      end
    else
      errordlg(sprintf('Unable to edit file %s ',file))
    end
  end
end


function enablefiles(obj,evd,frame,e)
%ENABLEFILES Enable/disable file operation buttons and menus
%   ENABLEFILES(OBJ,EVD,FRAME,E) enables/disables the file operations uicontrols.  E is 'on' or 'off'.

%Get dialog handle information
ui = getappdata(frame,'uidata');

%Set enable state of ui's
set(ui.AddFileItem,'Enable',e)
set(ui.AddButton,'Enable',e)
set(ui.EditFileItem,'Enable',e)
set(ui.EditButton,'Enable',e)
set(ui.RemoveFileItem,'Enable',e)
set(ui.RemoveButton,'Enable',e)
set(ui.SettingsItem,'Enable',e)

%Check features
x = licavail;

%Enable options based on license
switch e
  case 'off'
    if x(1),set(ui.COMComItem,'Enable',e),end
    if x(2),set(ui.ExcelComItem,'Enable',e),end
    if x(3),set(ui.JavaItem,'Enable',e),end
    if x(4),set(ui.NetItem,'Enable',e),end
  case 'on'
    if x(1),set(ui.COMComItem,'Enable',e),end
    if x(2),set(ui.ExcelComItem,'Enable',e),end
    if x(3),set(ui.JavaItem,'Enable',e),end
    if x(4),set(ui.NetItem,'Enable',e),end
end
set(ui.ClearStatusItem,'Enable',e)
set(ui.BuildLogItem,'Enable',e)
set(ui.PackageItem,'Enable',e)
set(ui.InfoItem,'Enable',e)
set(ui.ClearButton,'Enable',e)
set(ui.ProjectTree,'Enable',e)


function helpcompinfo(obj,evd)
%HELPCOMPINFO Component info help.

%Get file extension list
frame = getappdata(0,'CMPToolHandle');
fileext = fileextlist(obj,evd,frame);
switch fileext{1}
  case '*.cbl'
    mapfile = [docroot '\mapfiles\combuilder.map'];
    mapentry = 'compinfocsh';
  case '*.mxl'
    mapfile = [docroot '\mapfiles\matlabxl.map'];
    mapentry = 'compinfocsh';
  case '*.jbl'
end   
helpview(mapfile,mapentry)


function helppackagefile(obj,evd,f)
%HELPPACKAGEFILE Packager help information.

%Get file extension list
frame = getappdata(0,'CMPToolHandle');
fileext = fileextlist(obj,evd,frame);
switch fileext{1}
  case '*.cbl'
    mapfile = [docroot '\mapfiles\combuilder.map'];
    mapentry = 'packagecsh';
  case '*.mxl'
    mapfile = [docroot '\mapfiles\matlabxl.map'];
    mapentry = 'packagecsh';
  case '*.jbl'
end 
helpview(mapfile,mapentry)


function helpregister(obj,evd)
%HELPREGISTER Help registration information.

%Get file extension list
frame = getappdata(0,'CMPToolHandle');
fileext = fileextlist(obj,evd,frame);
switch fileext{1}
  case '*.cbl'
    mapfile = [docroot '\mapfiles\combuilder.map'];
    mapentry = 'settingscsh';
  case '*.mxl'
    mapfile = [docroot '\mapfiles\matlabxl.map'];
    mapentry = 'settingscsh';
  case '*.jbl'
end 
helpview(mapfile,mapentry)


function helptool(obj,evd)
%HELPTOOL Builder help.

%Get file extension list
frame = getappdata(0,'CMPToolHandle');
fileext = fileextlist(obj,evd,frame);
switch fileext{1}
  case '*.cbl'
    mapfile = [docroot '\mapfiles\combuilder.map'];
    mapentry = 'maincsh';
  case '*.mxl'
    mapfile = [docroot '\mapfiles\matlabxl.map'];
    mapentry = 'maincsh';
  case '*.jbl'
end

helpview(mapfile,mapentry)


function f = fileextlist(obj,evd,frame)
%FILEEXTLIST File extension list for project management.

f = getappdata(frame,'fileextlist');
if isempty(f)
  f = {'*.cbl','Builder for COM 1.0 (*.cbl)';...
       '*.mxl','Builder for Excel 1.0, 1.1 (*.mxl)';...
       '*.jbl','Java Builder 1.0 (*.jbl)'};
end
x = licavail;
if ~x(1),i = find(strcmp(f(:,1),'*.cbl'));f(i,:) = [];end
if ~x(2),i = find(strcmp(f(:,1),'*.mxl'));f(i,:) = [];end
if ~x(3),i = find(strcmp(f(:,1),'*.jbl'));f(i,:) = [];end
if ~x(4),i = find(strcmp(f(:,1),'*.nbl'));f(i,:) = [];end 
setappdata(frame,'fileextlist',f);


function helpcom(obj,evd)
%HELPCOM MATLAB Builder for COM help.

doc combuilder


function helpxl(obj,evd)
%HELPXL MATLAB Builder for Excel help.

doc matlabxl


function mcrbrowser(obj,evd,frame)
%MCRBROWSER Set location of MCR Installer.

%Get current MCR Installer location
mcrloc = getappdata(frame,'MCRLocation');
if isempty(mcrloc)
  mcrloc = [matlabroot '\toolbox\compiler\deploy\win32'];
end
mcrloc = uigetdir(mcrloc,'Please specify directory location of MCRInstaller.exe');
if ~isa(mcrloc,'double')
  mcrloc = [mcrloc '\MCRInstaller.exe'];
  setappdata(frame,'MCRLocation',mcrloc)
end


function newproject(obj,evd,frame)
%NEWPROJECT Initialize new project.

%Close current project
if closeproject(obj,evd,frame)
  return         %Save operation was cancelled, cancel open
end

%Ask for new project registration information
registration(obj,evd,frame)
f = getappdata(0,'CMPProjSettings');
f.setTitle(xlate('New Project Settings'))


function okregister(obj,evd,frame)
%OKREGISTER Apply registration information and close registration dialog.

%Get current cursor type and frame cursor to busy
f = getappdata(0,'CMPProjSettings');
cursFrame = f.getCursor;
f.setCursor(java.awt.Cursor(3))

%Apply changes, stop processing if problem
aok = applyregister(obj,evd,frame);
if aok    %Return value of 1 means apply succeeded, 0 means failure
  componentname = getappdata(frame,'componentname');
  projectname = getappdata(frame,'projectname');
  if isempty(projectname)
    fileext = fileextlist(obj,evd,frame);
    projectname = [componentname fileext{1}(end-3:end)];
  end
  setappdata(frame,'projectname',projectname)
  f.dispose;
  setappdata(0,'CMPProjSettings',[])
  adjusttreelist(obj,evd,frame)
  enablefiles([],[],frame,'on')
end

%Reset cursor
f.setCursor(cursFrame)


function openbuildlog(obj,evd,frame)
%OPENBUILDLOG Open project build log in MATLAB editor

%Get projectdir
projectdir = getappdata(frame,'projectdir');

%Build log filename
buildlog = [projectdir '\build.log'];
if ~exist(buildlog)
  errordlg(sprintf('No build log for this project currently exists.'))
  return
end

%Open buildlog
edit(buildlog)

function openproject(obj,evd,frame,filename)
%OPENPROJECT Open project.

%Close current project
if closeproject(obj,evd,frame)
  return         %Save operation was cancelled, cancel open
end

if nargin == 3
    
  %Get file extension list
  fileext = fileextlist(obj,evd,frame);
  
  %Get project file
  [filename,pathname] = uigetfile(fileext,xlate('Open project...'));

  %Do nothing if canceled
  if ~filename
    return
  end
  
else
  pathname = [];    %Filename already supplied
end

%File extension determines how to open file
switch filename(end-2:end)
    case 'mxl'
      openmxlproject(obj,evd,frame,[pathname filename]);
      return
    case 'cbl'
      opencblproject(obj,evd,frame,[pathname filename]);
      return 
    case 'jbl'
      openjblproject(obj,evd,frame,[pathname filename]);
      return
end


function opencblproject(obj,evd,frame,filename)
%OPENCBLPROJECT Open Builder for COM project.

%Load project file
eval(['load ''' filename ''' -mat'])

%Set current project data
setappdata(frame,'projectname',projectname);
setappdata(frame,'projectdir',projectdir);
setappdata(frame,'lastadddir',projectdir);
setappdata(frame,'mfiles',mfiles);
setappdata(frame,'mexfiles',mexfiles);
setappdata(frame,'componentname',componentname);
setappdata(frame,'classes',classes);
setappdata(frame,'projectversion',projectversion);
setappdata(frame,'debugswitch',debugswitch);
setappdata(frame,'verboseoutput',verboseoutput);
if exist('packagefiles')
  setappdata(frame,'packagefiles',packagefiles)
end
if exist('mcrloc')
  setappdata(frame,'MCRLocation',mcrloc)
end

%Enable file operations ui's
enablefiles(obj,evd,frame,'on')

%Set dialog name
set(frame,'Title',['MATLAB Builder - ' projectname])

%Expand list of source files
adjusttreelist(obj,evd,frame)


function openmxlproject(obj,evd,frame,filename)
%OPENMXLPROJECT Open Builder for Excel project.

%Load project file
eval(['load ''' filename ''' -mat'])
if exist('classname')
  classes = classname;   %Old MXL file format class storage
end

%Strip leading spaces from mfiles and mexfiles (Version 1.0 projects)
for i = 1:length(mfiles)
  mfiles{i} = fliplr(deblank(fliplr(mfiles{i})));
end
for i = 1:length(mexfiles)
  mexfiles{i} = fliplr(deblank(fliplr(mexfiles{i})));
end

%Adjust mfiles/mexfiles into multi class format
tmp = cell(length(mfiles),1);
tmp(:) = cellstr(classes);
if isempty(mfiles)
  mfiles = {[] []};
elseif (size(mfiles,2) == 1)
  mfiles = [mfiles tmp];
end
if isempty(mexfiles)
  mexfiles = {[] []};
elseif (size(mexfiles,2) == 1)
  mexfiles = [mexfiles tmp];
end

%Set current project data
setappdata(frame,'projectname',projectname);
setappdata(frame,'projectdir',projectdir);
setappdata(frame,'lastadddir',projectdir);
setappdata(frame,'mfiles',mfiles);
setappdata(frame,'mexfiles',mexfiles);
setappdata(frame,'componentname',componentname);
setappdata(frame,'classes',cellstr(classes));
setappdata(frame,'projectversion',projectversion);
setappdata(frame,'debugswitch',debugswitch);
setappdata(frame,'verboseoutput',verboseoutput);
if exist('packagefiles')
  setappdata(frame,'packagefiles',packagefiles)
end
if exist('mcrloc')
  setappdata(frame,'MCRLocation',mcrloc)
end

%Enable file operations ui's
enablefiles(obj,evd,frame,'on')

%Set dialog name
set(frame,'Title',['MATLAB Builder - ' projectname])

%Expand list of source files
adjusttreelist(obj,evd,frame)

function openjblproject(obj,evd,frame,filename)
%OPENJBLPROJECT Open Java Builder project.

%Load project file
eval(['load ''' pathname filename ''' -mat'])

%Set current project data
setappdata(frame,'projectname',projectname);
setappdata(frame,'projectdir',projectdir);
setappdata(frame,'lastadddir',projectdir);
setappdata(frame,'mfiles',mfiles);
setappdata(frame,'mexfiles',mexfiles);
setappdata(frame,'componentname',componentname);
setappdata(frame,'classes',classes);
setappdata(frame,'projectversion',projectversion);
setappdata(frame,'debugswitch',debugswitch);
setappdata(frame,'verboseoutput',verboseoutput);
if exist('packagefiles')
  setappdata(frame,'packagefiles',packagefiles)
end
if exist('mcrloc')
  setappdata(frame,'MCRLocation',mcrloc)
end

%Enable file operations ui's
enablefiles(obj,evd,frame,'on')

%Set dialog name
set(frame,'Title',['MATLAB Builder - ' projectname])

%Expand list of source files
adjusttreelist(obj,evd,frame)


function package(obj,evd,frame)
%PACKAGE Place holder for CTF file management and creation.

%Get existing package file information
packagefiles = getappdata(frame,'packagefiles');
mcrloc = getappdata(frame,'MCRLocation');

f = getappdata(0,'PackageDialog');
if ~isempty(f)
  f.show
  return
end

%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.border.*;

[dfp,mfp,bspc,bhgt,bwid] = spacingparams;

%Create base frame
f = JFrame('Package Files');
imic = ImageIcon(fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif'));
im = imic.getImage;
f.setIconImage(im);
set(f,'WindowClosingCallback', {@closepackagedialog, f})
p = get(0,'DefaultFigurePosition');
f.setBounds(p(1),p(2),p(3)/2,p(4));

%Base panel
BasePanel = JPanel;
BasePanel.setLayout(GridLayout(1,1,bspc,bspc));
setproperties(BasePanel);
f.getContentPane.add(BasePanel);

%Package Files Panel
PackagePanel = JPanel;
PackagePanel.setLayout(BorderLayout(bspc,bspc));
setproperties(PackagePanel)
PackageBorder = EmptyBorder(bspc,bspc,bspc,bspc);
PackagePanel.setBorder(PackageBorder)

%Add file button panel
PackageTopPanel = JPanel;
PackageTopPanel.setLayout(GridLayout(2,2,bspc,bspc));
setproperties(PackageTopPanel);
PackagePanel.add(PackageTopPanel,BorderLayout.NORTH);

%Add File button
ui.AddButton = JButton(sprintf('Add File'));
setproperties(ui.AddButton)
set(ui.AddButton,'ActionPerformedCallback',{@addpackagefile,f})
PackageTopPanel.add(ui.AddButton);

%Remove File button
ui.RemoveButton = JButton(sprintf('Remove File'));
setproperties(ui.RemoveButton)
set(ui.RemoveButton,'ActionPerformedCallback',{@removepackagefile,f})
PackageTopPanel.add(ui.RemoveButton);
PackagePanel.add(PackageTopPanel,BorderLayout.NORTH);

%MCR checkbox
ui.CheckBoxMCR = JCheckBox(sprintf('Include MCR'));
setproperties(ui.CheckBoxMCR)
j = find(strcmp('MCR Installer',packagefiles));
if isempty(j)
  ui.CheckBoxMCR.setSelected(0)
else
  ui.CheckBoxMCR.setSelected(1)
end
set(ui.CheckBoxMCR,'ActionPerformedCallback',{@adjustpackagetree,f})
PackageTopPanel.add(ui.CheckBoxMCR);

%MCR Installer browse pushbutton
ui.MCRBrowse = JButton(sprintf('MCR Location ...'));
setproperties(ui.MCRBrowse)
set(ui.MCRBrowse,'ActionPerformedCallback',{@mcrbrowser,f})
PackageTopPanel.add(ui.MCRBrowse);

%Tree Panel
TreePanel = JPanel;
TreePanel.setLayout(BorderLayout(bspc,bspc));
setproperties(TreePanel);
PackagePanel.add(TreePanel,BorderLayout.CENTER);

%Tree viewer
top = DefaultMutableTreeNode('Package Files');
tree = DefaultTreeModel(top);
ui.PackageTree = JTree(tree);
crend = ui.PackageTree.getCellRenderer;
crend.setBackgroundNonSelectionColor(java.awt.Color(1,1,1));
ui.PackageTree.setCellRenderer(crend);
setproperties(ui.PackageTree);

%Make tree scrollable
ui.TreeScrollPane = JScrollPane;
ui.TreeScrollPane.getViewport.add(ui.PackageTree);
TreePanel.add(ui.TreeScrollPane,BorderLayout.CENTER);

%Panel for Package, Close, and Help buttons
PackageBottomPanel = JPanel;
PackageBottomPanel.setLayout(GridLayout(1,3,bspc,bspc));
setproperties(PackageBottomPanel);
PackagePanel.add(PackageBottomPanel,BorderLayout.SOUTH);

%Package button
ui.PackageButton = JButton(sprintf('Create...'));
setproperties(ui.PackageButton)
set(ui.PackageButton,'ActionPerformedCallback',{@createpackage,frame})
PackageBottomPanel.add(ui.PackageButton);

%Close button
ui.CloseButton = JButton(sprintf('Close'));
setproperties(ui.CloseButton)
set(ui.CloseButton,'ActionPerformedCallback',{@closepackagedialog,f})
PackageBottomPanel.add(ui.CloseButton);

%Help button
ui.HelpButton = JButton(sprintf('Help'));
setproperties(ui.HelpButton)
set(ui.HelpButton,'ActionPerformedCallback',{@helppackagefile,f})
PackageBottomPanel.add(ui.HelpButton);

BasePanel.add(PackagePanel);

f.show
setappdata(0,'PackageDialog',f)
setappdata(f,'uidata',ui)
setappdata(f,'packagefiles',packagefiles)
setappdata(f,'MCRLocation',mcrloc)
adjustpackagetree(obj,evd,f)


function projectfiles(obj,evd,frame)
%PROJECTFILES Callback for project files list.

%If file double click, open file in editor
if (now - getappdata(frame,'lastfileclick')) < 5e-6
  editfile(obj,evd,frame)
else
  setappdata(frame,'lastfileclick',now)
end  


function registration(obj,evd,frame)
%REGISTRATION Project registration information.
%   REGISTRATION(OBJ,EVD,FRAME) opens the project registration dialog for component naming and
%   compiler options.  

%imports
import java.awt.*;
import java.util.Vector;
import javax.swing.*;
import javax.swing.tree.*;
import javax.swing.border.*;

%Only allow for single instance of dialog
f = getappdata(0,'CMPProjSettings');
if ~isempty(f)
  f.show
  return
end
  
%Get current project information, defaults to empty if new project
a = getappdata(frame);

%Open registration dialog
[dfp,mfp,bspc,bhgt,bwid] = spacingparams;
%Create base frame
f = JFrame('Project Settings');
imic = javax.swing.ImageIcon(fullfile(matlabroot,'toolbox/matlab/icons/matlabicon.gif'));
im = imic.getImage;
f.setIconImage(im);
set(f,'WindowClosingCallback', {@cancelregister,frame})
p = get(0,'DefaultFigurePosition');
f.setBounds(p(1),p(2)/2,6*bspc+3*bwid,12*bspc+19*bhgt);

%Base panel
BasePanel = JPanel(BorderLayout(bspc,bspc));
setproperties(BasePanel);
f.getContentPane.add(BasePanel);

%Name/Options Panel
NOPanel = JPanel;
setproperties(NOPanel);
NOPanel.setLayout(BoxLayout(NOPanel,BoxLayout.Y_AXIS));

%Project Name Panel
NamingPanel = JPanel;
setproperties(NamingPanel)
NamingPanel.setLayout(BoxLayout(NamingPanel,BoxLayout.Y_AXIS));
NamingTitle = TitledBorder(LineBorder(java.awt.Color(0,0,0)),xlate('Project naming'));
NamingTitle.setTitleFont(Font(get(0,'Defaultuicontrolfontname'),0,12))
uiColor = get(0,'Defaultuicontrolforegroundcolor');
NamingTitle.setTitleColor(java.awt.Color(uiColor(1),uiColor(2),uiColor(3)))
NamingPanel.setBorder(NamingTitle)

%Component name
CompNamePanel = JPanel(GridLayout(2,1,bspc,bspc));
setproperties(CompNamePanel)
ui.CompNameString = JLabel(sprintf('Component name'));
setproperties(ui.CompNameString);
ui.CompName = JTextField;
set(ui.CompName,'Actionperformedcallback',{@setcomponentname,f})
set(ui.CompName,'Focuslostcallback',{@setcomponentname,f})
CompNamePanel.add(ui.CompNameString,BorderLayout.NORTH);
CompNamePanel.add(ui.CompName);
NamingPanel.add(CompNamePanel);

%Classes panel
ClassesPanel = JPanel(GridLayout(1,3,bspc,bspc));
setproperties(ClassesPanel)
ClassNamePanel = JPanel(GridLayout(4,1,bspc,bspc));
ui.ClassNameString = JLabel(sprintf('Class name'));
setproperties(ui.ClassNameString)
ui.ClassName = JTextField;
setproperties(ui.ClassName)
BlankLabel = JLabel;
setproperties(BlankLabel)
ClassNamePanel.add(BlankLabel);
ClassNamePanel.add(ui.ClassNameString);
ClassNamePanel.add(ui.ClassName);
BlankLabel = JLabel;
setproperties(BlankLabel)
ClassNamePanel.add(BlankLabel);
ClassesPanel.add(ClassNamePanel);

%Add/Remove panel
AddRemovePanel = JPanel(GridLayout(4,1,0,3));
setproperties(AddRemovePanel);
for i = 1:2
  BlankLabel = JLabel;
  setproperties(BlankLabel)
  AddRemovePanel.add(BlankLabel);
end
ui.Add = JButton(sprintf('Add >>'));
setproperties(ui.Add)
set(ui.Add,'ActionPerformedCallback',{@addclass,f})
ui.Remove = JButton(sprintf('Remove'));
setproperties(ui.Remove)
set(ui.Remove,'ActionPerformedCallback',{@removeclass,f})
AddRemovePanel.add(ui.Add);
AddRemovePanel.add(ui.Remove);
ClassesPanel.add(AddRemovePanel);

%Classes list
ClassListPanel = JPanel(BorderLayout(bspc,bspc));
setproperties(ClassListPanel)
ui.ClassesString = JLabel(sprintf('Classes'));
setproperties(ui.ClassesString)
ui.ClassList = JList;
setproperties(ui.ClassList)
setappdata(ui.ClassList,'classes',a.classes)
ui.ClassScroll = JScrollPane(ui.ClassList);
ui.ClassList.setBorder([]);
ClassListPanel.add(ui.ClassesString,BorderLayout.NORTH);
ClassListPanel.add(ui.ClassScroll,BorderLayout.CENTER);
ClassesPanel.add(ClassListPanel);

NamingPanel.add(ClassesPanel);

%Project Panel
ProjectPanel = JPanel(GridLayout(5,1,bspc,bspc));
setproperties(ProjectPanel)

%Project version
ui.ProjVerString = JLabel(sprintf('Project version'));
setproperties(ui.ProjVerString)
ui.ProjVer = JTextField;
setproperties(ui.ProjVer)
ProjectPanel.add(ui.ProjVerString);
ProjectPanel.add(ui.ProjVer);

%Project directory
ui.ProjDirString = JLabel(sprintf('Project directory'));
setproperties(ui.ProjDirString)
ui.ProjDir = JTextField;
setproperties(ui.ProjDir)
ProjectPanel.add(ui.ProjDirString);
ProjectPanel.add(ui.ProjDir);

%Browse button
BrowsePanel = JPanel(GridLayout(1,3,bspc,bspc));
setproperties(BrowsePanel)
ui.Browse = JButton(sprintf('Browse...'));
setproperties(ui.Browse)
set(ui.Browse,'ActionPerformedCallback',{@browseprojdir,f})
BrowsePanel.add(ui.Browse);
%2 Padding Labels
for i = 1:2
  BlankLabel = JLabel;
  setproperties(BlankLabel);
  BrowsePanel.add(BlankLabel);
end
ProjectPanel.add(BrowsePanel);
NamingPanel.add(ProjectPanel);

NOPanel.add(NamingPanel);

%Compiler options panel
OptionsPanel = JPanel(GridLayout(2,1));
setproperties(OptionsPanel)
OptionsTitle = TitledBorder(LineBorder(java.awt.Color(0,0,0)),xlate('Compiler options'));
OptionsTitle.setTitleFont(Font(get(0,'Defaultuicontrolfontname'),0,12))
uiColor = get(0,'Defaultuicontrolforegroundcolor');
OptionsTitle.setTitleColor(java.awt.Color(uiColor(1),uiColor(2),uiColor(3)))
OptionsPanel.setBorder(OptionsTitle)
ui.CheckBoxDebug = JCheckBox(sprintf('Build debug version'));
ui.CheckBoxVerbose = JCheckBox(sprintf('Show verbose output'));
OptionsPanel.add(ui.CheckBoxDebug);
OptionsPanel.add(ui.CheckBoxVerbose);
NOPanel.add(OptionsPanel);

%Add Naming/Options panel to base panel
BasePanel.add(NOPanel,BorderLayout.CENTER);

%Buttons panel
ButtonsPanel = JPanel(GridLayout(1,3,bspc,bspc));
setproperties(ButtonsPanel)

%OK button
ui.OKButton = JButton(sprintf('OK'));
setproperties(ui.OKButton)
set(ui.OKButton,'ActionPerformedCallback',{@okregister,frame})
ButtonsPanel.add(ui.OKButton);

%Cancel button
ui.CancelButton = JButton(sprintf('Cancel'));
setproperties(ui.CancelButton)
set(ui.CancelButton,'ActionPerformedCallback',{@cancelregister,frame})
ButtonsPanel.add(ui.CancelButton);

%Help button
ui.HelpButton = JButton(sprintf('Help'));
setproperties(ui.HelpButton)
set(ui.HelpButton,'ActionPerformedCallback',{@helpregister,frame})
ButtonsPanel.add(ui.HelpButton);

%Add button panel to base panel
BasePanel.add(ButtonsPanel,BorderLayout.SOUTH);

%Display project settings
if ~isempty(a.componentname)
  ui.CompName.setText(a.componentname);
  ui.ProjVer.setText(a.projectversion);
  ui.ProjDir.setText(a.projectdir);
  listVector = Vector;
  for i = 1:length(a.classes)
    listVector.addElement(a.classes{i});
  end
  ui.ClassList.setListData(listVector);
  if ~isempty(a.debugswitch),ui.CheckBoxDebug.setSelected(1);end
  if ~isempty(a.verboseoutput),ui.CheckBoxVerbose.setSelected(1);end
end

setappdata(f,'uidata',ui)
f.show
setappdata(0,'CMPProjSettings',f)


function removeclass(obj,evd,frame)
%REMOVECLASS Remove class from class list.

%Get ui data
ui = getappdata(frame,'uidata');
h = getappdata(0,'CMPToolHandle');
d = getappdata(h);

classval = ui.ClassList.getSelectedIndices;
classes = getappdata(ui.ClassList,'classes');
if isempty(classval)
  return
end

%Give user choice of continuing if class is not empty
clsval = [];
for i = 1:length(classval)
  cls = classes(double(classval(i))+1);
  if (~isempty(find(strcmp(d.mfiles(:,2),cls))) || ~isempty(find(strcmp(d.mexfiles(:,2),cls))))
    bn=questdlg(['Class ' cls{:} ' contains M or MEX files.  Remove class and associated files?'], ...
                       'Remove class', ...
                       'Yes','No','No');
    switch bn
      case 'Yes'
        clsval = [clsval;double(classval(i))];
    end
  else
    clsval = [clsval;double(classval(i))];  
  end
end
classes(clsval+1) = [];
setappdata(ui.ClassList,'classes',classes)
classVector = java.util.Vector;
for i = 1:length(classes)
  classVector.addElement(classes{i});
end
ui.ClassList.setListData(classVector);


function removefile(obj,evd,frame)
%REMOVEFILE Remove file from project.

%Get ui data
ui = getappdata(frame,'uidata');
a = getappdata(frame);
rsel = double(get(ui.ProjectTree,'SelectionRows'));
paths = get(ui.ProjectTree,'SelectionPaths');

%Remove mfiles from list
if ~isempty(a.mfiles)
  for i = 1:length(rsel)
    currentpath = paths(i).getPath;
    currentclass = toString(currentpath(2));    %Class is always second element of path
    j = find(strcmp(a.mfiles(:,1),toString(paths(i).getLastPathComponent)) & ...
             strcmp(a.mfiles(:,2),currentclass));
    a.mfiles(j,:) = [];
  end
end

%Remove mexfiles from list
if ~isempty(a.mexfiles)
  for i = 1:length(rsel)
    currentpath = paths(i).getPath;
    currentclass = toString(currentpath(2));    %Class is always second element of path
    j = find(strcmp(a.mexfiles(:,1),toString(paths(i).getLastPathComponent)) & ...
             strcmp(a.mexfiles(:,2),currentclass));
    a.mexfiles(j,:) = [];
  end
end

%Save updated file lists
setappdata(frame,'mfiles',a.mfiles)
setappdata(frame,'mexfiles',a.mexfiles)
adjusttreelist(obj,evd,frame)
setappdata(frame,'saveflag',1)


function removepackagefile(obj,evd,frame)
%REMOVEPACKAGEFILE Delete file from package.

%Get ui data
ui = getappdata(frame,'uidata');
rsel = double(get(ui.PackageTree,'SelectionRows'));
paths = get(ui.PackageTree,'SelectionPaths');
f = getappdata(0,'CMPToolHandle');

%Get current files in package
packagefiles = getappdata(frame,'packagefiles');

%Remove packagefiles from list
if ~isempty(packagefiles)
  for i = 1:length(rsel)
    currentpath = paths(i).getPath;
    currentclass = toString(currentpath(2));    %Class is always second element of path
    j = find(strcmp(packagefiles(:,2),toString(paths(i).getLastPathComponent)) & ...
             strcmp(packagefiles(:,1),currentclass));
    packagefiles(j,:) = [];
  end
end

%Save updated file list
setappdata(frame,'packagefiles',packagefiles)
adjustpackagetree(obj,evd,frame)
setappdata(f,'saveflag',1)


function saveproject(obj,evd,frame,projectname)
%SAVEPROJECT Save project.

%Get current project name
if nargin == 3
  projectname = getappdata(frame,'projectname');
end
projectdir = getappdata(frame,'projectdir');

%If no project name, call saveasproject, otherwise projectname given so save explicitly
if nargin == 3
  if isempty(projectname) || ~exist([projectdir '\' projectname])
    saveasproject(obj,evd,frame)
    return
  end
elseif isempty(projectname)
  saveasproject(obj,evd,frame)
  return
end

%Get current files in project
mfiles = getappdata(frame,'mfiles');
mexfiles = getappdata(frame,'mexfiles');

%Get current registration information
componentname = getappdata(frame,'componentname');
classes = getappdata(frame,'classes');
projectversion = getappdata(frame,'projectversion');
debugswitch = getappdata(frame,'debugswitch');
verboseoutput = getappdata(frame,'verboseoutput');

%Get package information
packagefiles = getappdata(frame,'packagefiles');
mcrloc = getappdata(frame,'MCRLocation');

%Save data
eval(['save ''' projectdir '\' projectname ...
      ''' mfiles mexfiles projectdir projectname componentname classes projectversion debugswitch verboseoutput packagefiles mcrloc -mat'])

%Update window title
set(frame,'Title',['MATLAB Builder - ' projectname])

%Reset save flag
setappdata(frame,'saveflag',0)


function saveasproject(obj,evd,frame)
%SAVEPROJECT Save project prompting new project name.

%Get current files in project
mfiles = getappdata(frame,'mfiles');
mexfiles = getappdata(frame,'mexfiles');

%Get current registration information
componentname = getappdata(frame,'componentname');
classes = getappdata(frame,'classes');
projectversion = getappdata(frame,'projectversion');
projectdir = getappdata(frame,'projectdir');

%Move to project directory if there is one
currentdir = pwd;
if ~isempty(projectdir)
  cd(projectdir)
end
debugswitch = getappdata(frame,'debugswitch');
verboseoutput = getappdata(frame,'verboseoutput');
packagefiles = getappdata(frame,'packagefiles');
mcrloc = getappdata(frame,'MCRLocation');

%Get save path
fileext = fileextlist(obj,evd,frame);
[projectname,projectdir] = uiputfile(fileext,xlate('Save project as...'));

%Move back to original directory
cd(currentdir)

%If Cancel, do nothing
if ~projectname
  return
end

%Append .cbl extension if not given
i = findstr(projectname,'.');
if isempty(i)
  projectname = [projectname '.cbl'];
end

%Save file location
setappdata(frame,'projectdir',projectdir)
setappdata(frame,'projectname',projectname)
setappdata(frame,'lastadddir',projectdir)

%Save data
eval(['save ''' projectdir projectname ...
      ''' mfiles mexfiles projectdir projectname componentname classes projectversion debugswitch verboseoutput packagefiles mcrloc -mat'])

%Set name of dialog to current project
set(frame,'Title',['MATLAB Builder - ' projectname])

%Reset save flag
setappdata(frame,'saveflag',0)


function setcomponentname(obj,evd,frame)
%SETCOMPONENTNAME Project component name entry callback.

%Get ui data
ui = getappdata(frame,'uidata');

%Get entered component name
componentname = get(ui.CompName,'Text');
if isempty(componentname)
  return
end

%Create default class name if none given
ClassListModel = ui.ClassList.getModel;
classes = [];
i = 1;
while i
  try
    classes{i} = ClassListModel.getElementAt(i-1);
    if strcmp(lower(classes{i}),'no data model')
      classes = [];
      i = -1;
    end
    i = i+1;
  catch
    i = 0;
  end
end
if isempty(classes)
  set(ui.ClassName,'Text',[componentname 'class'])
  addclass(obj,evd,frame)
end

%Enter default project version if it is blank
projectversion = get(ui.ProjVer,'Text');
if isempty(projectversion)
  set(ui.ProjVer,'Text','1.0')
end

%Create default project directory name if none given
projectdirectory = get(ui.ProjDir,'Text');
if isempty(projectdirectory)
  set(ui.ProjDir,'Text',[pwd '\' componentname])
end


function setproperties(textobj)
%SETTEXTPROPERTIES sets the font, size, color, etc of text of the given object

%imports
import java.awt.*;
import javax.swing.*;
import javax.swing.border.*;

%Set default properties
uiFontName = get(0,'Defaultuicontrolfontname');
uiFontSize = 12;
uiFontColor = get(0,'Defaultuicontrolforegroundcolor');
uiBackGround = get(0,'Defaultuicontrolbackgroundcolor');

textobj.setFont(Font(uiFontName,0,uiFontSize))
set(textobj,'Foreground',uiFontColor)
objtype = class(textobj);

%Set background
switch objtype
  case {'javax.swing.JTextArea','javax.swing.JTree','javax.swing.JTextField','javax.swing.JList'}
    %leave background unchanged
  otherwise
    set(textobj,'Background',uiBackGround)
end

%Set border
switch objtype
  case {'javax.swing.JButton'}
    textobj.setBorder(BevelBorder(0));
  case {'javax.swing.JTextArea','javax.swing.JTree','javax.swing.JList'}
    textobj.setBorder(BevelBorder(1));
end

function [dfp,mfp,bspc,bhgt,bwid] = spacingparams()
%SPACINGPARAMS Dialog ui spacing parameters.

dfp = get(0,'DefaultFigurePosition');
mfp = [560 420];    %Reference width and height
bspc = mean([5/mfp(2)*dfp(4) 5/mfp(1)*dfp(3)]);
bhgt = 20/mfp(2) * dfp(4);
bwid = 80/mfp(1) * dfp(3);


function u = unsavedproject(obj,evd,frame)
%UNSAVEDPROJECT Prompt user to save unsaved project.

buttonname = questdlg(xlate('Current project has not been saved.   Do you wish to save it?'),xlate('Unsaved project...'));
switch buttonname
  case 'Yes'
    u = 1;
  case 'No'
    u = 0;
    setappdata(frame,'saveflag',0)
  otherwise
    u = -1;
end


function verifyfiles(obj,evd,frame)
%VERIFYFILES Verify existence of files in project

%Get M/MEX-files
a = getappdata(frame);

%Trap missing m-files
for i = 2:size(a.mfiles,1)
  if ~exist(a.mfiles{i,1})
    error('builder:cmptool:invalidMFile','%s does not exist.',a.mfiles{i})
  end
end

%Trap missing mex-files
for i = 2:size(a.mexfiles,1)
  if ~exist(a.mexfiles{i,1})
    error('builder:cmptool:invalidMEXFile','%s does not exist.',a.mexfiles{i})
  end
end
