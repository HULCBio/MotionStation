function varargout = slwsprmattrib( varargin )
% SLWSPRMATTRIB Real-Time Workshop Model Parameter Configuration settings
% dialog. It will be accessed from SIMULATION PARAMETER dialog (SIMPRM) and 
% also from the S-function Target code generation procedure.
%
% See also SIMPRM.

% Copyright 1990-2003 The MathWorks, Inc.
% $Revision: 1.34.4.4 $

% Abstract:
%   This dialog will provide an user interface to allow user to do
%   following tasks:
%   1) view all of the parameters that are existing in the current MATLAB 
%      workspace, select parameters from them and add, delete and/or 
%      modify appropriate attributes on these parameters;
%   2) inspect and modify attributes on the existing parameters in a model;
%
% Attributes list and their equivalent command interface:
%   Name:     set/get_param(model,  'TunableVars', 'var1, var2, ...');
%   DataType: >>vars = datatype(value);
%   StorageClass: 
%      set/get_param(model,  'TunableVarsStorageClass', ...
%               'Auto, ExportedGlobal, ImportedExtern, ImportedExternPointer');
%   StorageTypeQualifier:
%      set/get_param(model,  'TunableVarsTypeQualifier', ...
%                            ' '''', ''string'', ''string'', ''string'' ');
%   Value:    >>vars = (NumericValue);
%   Referenced by blocks: list of block that referenced this parameter
%
% Basic GUI architecture:
%   This dialog consists of 4 major parts:
%   1) Dialog title and description. It will on top of the dialog
%      and the contents will not be changed.
%   2) Parameter Viewer. This includes:
%      - one multi-column listbox for parameter listing, 
%      - a 'Refresh list' button that will refresh the content of the listbox, 
%      - a 'Add to table' checkbox inside listbox that will add
%        selected parameters into the editing table (attributes table), 
%      - a 'Variables list in' popup menu that switch between 'ML_WS' 
%        and the model, 
%   3) Parameter attributes table. This includes:
%      - a 'Table' that list all parameters' attributes,
%      - a 'New' button that adds a new parameter into the Table
%      - a 'Remove' button that deletes one or more parameters from the Table
%      - 'Data type', 'Storage class' & 'Storage type qualifier'
%        items for multiplue selection.
%   4) System default dialog buttons: 'OK', 'Cancel', 'Help' & 'Apply'.
%  
% Naming convention and coding format guideline for this file (a MATLAB style 
% Java enhanced code):
%   1) function name: all words start with capital letters
%   2) variable name: first letter of the first word is lower case,
%      all others' first letters are capitalized;
%   3) new container (frame, groupbox, panel, etc.) created with:
%       % xxxx -------------------------------------
%   4) new firm objects (needs to be called later eventually) created with:
%       % xxxx *************************************
%   5) function description:
%       % Function: xxxxxxx ========================
%   6) variable name prefix: e.g. xTunable is Tunable checkbox
%       a-Label,   b-Button,c-Combobox,e-Editfield,f-Frame
%       g-Groupbox,h-Handle,l-Listbox, p-Panel,    t-Table, x-Checkbox,
%
%   Jun Wu, Feb. 10, 2000
%
%mlock;					% locks this file for using function
                                        % handle correctly with pcode.
					
% This function must be called with at least two input arguments:
% 'action' flag and 'model' handle, the third one could be a callback argument
msgin = nargchk(2, 4, nargin);

% This function will return the frame figure handle by default
msgout = nargchk(0, 1, nargout);

if ~isempty([msgin msgout])
  error(sprintf([msgin '\n' msgout]));
end
  
action = varargin{1};			% action switch
hModel = varargin{2};			% get the model's handle

try
  switch lower(action)
   case 'create'

    simprmChildren = varargin{3};		% simprm's item's handle

    % create the dialog
    CreateDialog( hModel, simprmChildren);

    % output the dialog figure's handle
    appdata   = getappdata(0, get_param(hModel, 'Name'));
    dialogFig = appdata.fWPA;
    
    varargout = { dialogFig };
 
   case 'reshow'
    fWPA = varargin{4};
    
    % update the listbox & table
    % output the dialog figure's handle
    appdata   = getappdata(0, get_param(hModel, 'Name'));
    set(fWPA, 'Visible', 'on');
    doWsSelection(appdata.cVarsSelection, [], hModel);

    appdata.tAttributes.repaint;
    varargout = { fWPA };
    
   case 'changename'
    dialogFig = varargin{3};
    set(dialogFig, 'Title', GetDialogName(hModel));
    
    % change the previous appdata to new one
    prevModelName = get(dialogFig, 'UserData');
    setappdata(0, get_param(hModel, 'Name'), ...
		  getappdata(0, prevModelName) );
    
    rmappdata(0, prevModelName);
    set(dialogFig, 'UserData', get_param(hModel, 'Name'));
    
   case 'figdelete'
    
   otherwise
    error('Incorrect call to Worksapce Parameter Attributes dialog function.');
  end
catch
  if isappdata(0, get_param(hModel, 'Name') )
    appdata = getappdata(0, get_param(hModel, 'Name') );
    fWPA = appdata.fWPA;
    hd=findobj(allchild(0), 'Name', get(fWPA,'Name'));

    if ishandle(hd)
      delete(hd);
    end
  
    % clean up the appdata in ML session
    setappdata(0, get_param(hModel, 'Name'), '');
    rmappdata(0, get_param(hModel, 'Name') );
  else
    % no-op for now
  end
end

% end of main function


% Function: CreateDialog =======================================================
% Abstract:
%   Create workspace parameter attributes main dialog
%
function CreateDialog(hModel, simprmChildren)

%
% Import java package
%
import java.awt.*;			% 
import com.mathworks.mwt.*;  		% for MWT stuff
import com.mathworks.mwt.table.*;	% 
import com.mathworks.widgets.*;  	% for StyledTextLabel

%
% create the dialog frame
%
if isappdata(0, get_param(hModel, 'Name') ) && ...
      ~isempty(getappdata(0, get_param(hModel, 'Name') ) )
  appdata = getappdata(0, get_param(hModel, 'Name') );
  fWPA = appdata.fWPA;
  hd=findobj(allchild(0), 'Name', get(fWPA,'Name'));
  if ishandle(hd)
    % do the reload and turn the figure visible
    set(hd, 'Visible', 'on');
    fWPA.repaint;
    return;
  end
end

% main frame created -----------------------------------------------------------
fWPA = MWFrame( GetDialogName(hModel) );
appdata.fWPA = fWPA;
appdata.hModel = hModel;

% use BorderLayout, NORTH for description, CENTER for the main
% stuff and SOUTH for system buttons such as 'OK', 'Apply', etc.
fWPA.setLayout( BorderLayout );
set(fWPA, 'Parent', 0);

vCommonGeom = commonGeomFcn;

% panel for 'Description' groupbox ---------------------------------------------
pDescription = MWPanel( ...
    MWBorderLayout( vCommonGeom.hGap, vCommonGeom.vGap) );
pDescription.setInsets( vCommonGeom.insets );

% 'Description' groupbox created -----------------------------------------------
gDescription = MWGroupbox( sprintf('Description') );
gDescription.setLayout( BorderLayout );

% create the string of description
descriptionStr = StyledTextLabel( ...
    sprintf(['Define the global (tunable) parameters for your model.' ...
     ' These parameters affect: ', sprintf('\n'), ...
     '1. the simulation by providing the ability to tune parameters during' ...
     ' execution, and ', sprintf('\n'), ...
     '2. the generated code by enabling access to parameters by other modules.']));
appdata.descriptionStr = descriptionStr;
gDescription.add( descriptionStr, BorderLayout.CENTER );
pDescription.add( gDescription );

% add the description panel on top of the frame
fWPA.add( pDescription, BorderLayout.NORTH );

% panel for bottom of the window -----------------------------------------------
pBottom = MWPanel( BorderLayout(vCommonGeom.vGap, ...
				vCommonGeom.hGap+vCommonGeom.vGap) );

bStatus = MWLabel;
bStatus.setText(sprintf('Ready'));
appdata.bStatus = bStatus;
pBottom.add(bStatus, BorderLayout.CENTER);

% panel for system buttons ('OK','Cancel','Help' and 'Apply') ------------------
pSystemButtons = MWPanel( FlowLayout( FlowLayout.RIGHT, ...
				      vCommonGeom.vGap*2, vCommonGeom.vGap ) );

% OK button ********************************************************************
bOK = MWButton( sprintf('OK') );

bOK.setName('OKButton');

% Cancel button ****************************************************************
bCancel = MWButton( sprintf('Cancel') );

bCancel.setName('CancelButton');

% Help button ******************************************************************
bHelp = MWButton( sprintf('Help')   );

bHelp.setName('HelpButton');

% Apply button *****************************************************************
bApply = MWButton( sprintf('Apply')  );
set(bApply, 'Enabled', 'off');

bApply.setName('ApplyButton');

% add these button objects into the appdata for later use
appdata.bOK     = bOK;
appdata.bCancel = bCancel;
appdata.bHelp   = bHelp;
appdata.bApply  = bApply;

% add them on to the container pSystemButtons
pSystemButtons.add( bOK );
pSystemButtons.add( bCancel );
pSystemButtons.add( bHelp );
pSystemButtons.add( bApply );

% add the system buttons panel on the bottom of the frame
pBottom.add( pSystemButtons, BorderLayout.EAST );

fWPA.add(pBottom, BorderLayout.SOUTH);

% Main panel ----------------------------------------------------------------
% Create a panel to contain the workspace variable panel and Attributes 
% settings panel wiht a splitter panel. This panel has two parts,
% LEFT and RIGHT, and will be placed in the center of the Frame (fWPA).
%
pMain = MWPanel( ...
    MWBorderLayout( vCommonGeom.hGap,vCommonGeom.vGap) );
pMain.setInsets( vCommonGeom.insets );

pCentral = MWSplitter;
pCentral.setOrientation(0);
pCentral.setDividerLocation(1);
pCentral.setDividerDark(1);
pCentral.setDividerLocation(0.37)

% Workspace variables groupbox -------------------------------------------------
% used to contain the variables listbox and associated buttons  
% and popup menu items.
%
gWorkspaceVariables = MWGroupbox( sprintf('Source list') );
gWorkspaceVariables.setLayout( BorderLayout(vCommonGeom.vGap, ...
					    vCommonGeom.vGap+vCommonGeom.hGap));

% Workspace variables listbox created ******************************************
lVariables = MWListbox;
appdata.lVariables = lVariables;	% have it in appdata

lVariables.setName('VarsListbox');

% set listbox's property
lVariables.setHeaderVisible(1);
lVariables.setColumnCount(1);
varsListHeaderStr = {sprintf('Name')};		% set up listbox headers

lVariables.setHeaders( varsListHeaderStr );
lVariables.setPreferredTableSize(4, 1);
lVariables.getColumnOptions.setHeaderVisible(1); % 
lVariables.getRowOptions.setHeaderVisible(1); % 
lVariables.getRowOptions.setHeaderWidth(30); % 
lVariables.getTableStyle.setHGridVisible(1);% needs vertical grid
lVariables.getColumnOptions.setResizable(0); % make it not resizable
lVariables.setMultiSelection(1);
width = 50;
lVariables.setColumnWidth(0, width);	% set default column width

% add the listbox in the CENTER of the groupbox
gWorkspaceVariables.add(lVariables, BorderLayout.CENTER);

% wsSelection popup ************************************************************
wsList = {'MATLAB workspace'; 'Referenced workspace variables'};
wsSrc = wsList{1};
try
  wsSrc = get_param(hModel, 'ParamWorkspaceSource');
  if findstr(wsSrc, 'MATLAB')
    wsSrc = wsList{1};
  else
    wsSrc = wsList{2};
  end
catch
  % do nothing
end
cVarsSelection = MWCombobox(wsSrc, wsList);

cVarsSelection.setTextEditable(0);	% not editable
appdata.cVarsSelection = cVarsSelection; % add into appdata for function pointer

cVarsSelection.setName('VarsSelectionPopup');

% add the cVarsSelection on the NORTH of the groupbox
gWorkspaceVariables.add(cVarsSelection, BorderLayout.NORTH);

% panel for a workspace selection and Refresh list button ----------------------
pAddRefresh = MWPanel( BorderLayout(vCommonGeom.vGap, ...
				    vCommonGeom.vGap+vCommonGeom.hGap));

% create 'Add to table' button *************************************************
bAdd = MWButton(sprintf('Add to table >>'));
set(bAdd, 'Name', 'AddToTableButton');
appdata.bAdd = bAdd;		% add into appdata for function pointer
set(bAdd, 'Enabled', 'off');				

pAddRefresh.add(bAdd, BorderLayout.EAST);

% create 'Refresh list' button *************************************************
bRefresh = MWButton(sprintf('Refresh list'));
appdata.bRefresh = bRefresh;		% add into appdata for function pointer

bRefresh.setName('RefreshButton');

pAddRefresh.add(bRefresh, BorderLayout.WEST);

% add the pAddRefresh on the SOUTHTH of the groupbox
gWorkspaceVariables.add(pAddRefresh, BorderLayout.SOUTH);

% add the gWorkspaceVariables on the TOP of the panel
pCentral.add(gWorkspaceVariables);

% Attributes settings panel ----------------------------------------------------
% Create a panel to list and modify the parameter's attributes and associated
% buttons and other menu items. Use the groupbox as the panel container
% create attributes setting table groupbox
gAttributesSettings = MWGroupbox( sprintf('Global (tunable) parameters') );
gAttributesSettings.setLayout( BorderLayout(vCommonGeom.vGap, ...
					    vCommonGeom.vGap+vCommonGeom.hGap));

% Attributes settings table created --------------------------------------------
tAttributes = MWTable(3, 3);		% initial number
appdata.tAttributes = tAttributes;	% add into appdata

tAttributes.setName('AttributesTable');
tAttributes.setTableBackground(tAttributes.getBackground); % white background 
% multiple selection available
tAttributes.getSelectionOptions.setMode(SelectionOptions.SELECT_COMPLEX);

tAttributesHeadersStr = {...
    sprintf('Name');  sprintf('Storage class'); sprintf('Storage type qualifier')};
for i=0:length(tAttributesHeadersStr)-1
  tAttributes.setColumnHeaderData(i, tAttributesHeadersStr{i+1} );
end
tAttributes.setAutoExpandColumn(2);
tAttributes.getColumnOptions.setResizable(1);
tAttributes.getRowOptions.setHeaderVisible(1); % 
tAttributes.getRowOptions.setHeaderWidth(30); % 
tAttributes.getSelectionOptions.setSelectBy(SelectionOptions.SELECT_BY_ROW);

tStyle = tAttributes.getTableStyle;
tStyle.setEditable(1);
tAttributes.setTableStyle(tStyle);

tAttributes.setMinAutoExpandColumnWidth(30); % minimium width

nRows = 0;
tAttributes.getData.setHeight(nRows);

% add the table onto the groupbox container
gAttributesSettings.add(tAttributes, BorderLayout.CENTER);

% panel for 'New' & 'Remove' buttons -------------------------------------------
pNew = MWPanel( FlowLayout(FlowLayout.RIGHT, vCommonGeom.vGap*2, 0) );

% create 'New' button **********************************************************
bNew = MWButton( sprintf('New') );
appdata.bNew = bNew;			% put into appdata

bNew.setName('NewButton');

% create 'Remove' button *******************************************************
bRemove = MWButton( sprintf('Remove') );
set(bRemove, 'Enabled', 'off');
appdata.bRemove = bRemove;		% put into appdata

bRemove.setName('RemoveButton');

% put these two buttons on the panel
pNew.add(bNew);
pNew.add(bRemove);

% we need to use the same ui item for the columns in the table
lStyle = Style(Style.H_ALIGNMENT);
lStyle.setHAlignment(Style.H_ALIGN_CENTER); % put the checkbox in the center
tAttributes.setColumnStyle(1, lStyle);
tAttributes.setColumnStyle(2, lStyle);

for i = 0:nRows				% initialize cell style
  % 'Name' column
  tAttributes.setColumnWidth(0, 60);
  
  % 'Storage class' column
  tAttributes.setColumnWidth(1, 150);

  % type qualifier' column
  tAttributes.setColumnWidth(2, 120);
  
end

% add the bottom panel into the attributes settings groupbox
gAttributesSettings.add( pNew, BorderLayout.SOUTH );

% then post it on the central panel
pCentral.add(gAttributesSettings);

pMain.add(pCentral);

% add the entire central piece on to the frame
fWPA.add( pMain, BorderLayout.CENTER );

% save the model's name for future use like model's name changed.
set(fWPA, 'UserData', get_param(hModel, 'Name')); 

% store the userdata for function pointer and other usages
setappdata(0, get_param(hModel, 'Name'), appdata);

% set windows closing callback
set(fWPA, 'WindowClosingCallback', {@doCloseFigure, fWPA} );

% add callback for these buttons
set(bOK, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bOK, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bCancel, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bCancel, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bHelp, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bHelp, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bApply, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bApply, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bOK,    'ActionPerformedCallback', {@doOK, hModel} );
set(bCancel,'ActionPerformedCallback', {@doCancel, hModel} );
set(bHelp,  'ActionPerformedCallback', {@doHelp, fWPA} );
set(bApply, 'ActionPerformedCallback', {@doApply, hModel} );
set(bRemove, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bRemove, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bNew,    'ActionPerformedCallback', {@doNew, hModel});
set(bRemove, 'ActionPerformedCallback', {@doRemove, hModel});

set(bAdd, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bAdd, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bAdd, 'ActionPerformedCallback', {@doAdd, hModel} );

set(bRefresh, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bRefresh, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(bRefresh, 'ActionPerformedCallback', {@doRefresh, hModel} );

set(bNew, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(bNew, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );

set(lVariables, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(lVariables, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(lVariables, 'ItemStateChangedCallback', ...
		 {@ListboxItemStateChangedCallback, hModel} );

set(lVariables, 'ValueChangedCallback', {@AddSelectedVarsIntoTable, hModel});

set(cVarsSelection, 'MouseEnteredCallback', {@doMouseEnterFcn, hModel} );
set(cVarsSelection, 'MouseExitedCallback', {@doMouseExitFcn, hModel} );
set(cVarsSelection, 'ActionPerformedCallback', {@doWsSelection, hModel} );

% set action listener for the table
set(tAttributes, 'ItemStateChangedCallback', ...
		 {@TableItemStateChangedCallback, hModel} );

% set action listener for value change callback
set(tAttributes, 'ValueChangedCallback', ...
		 {@TableValueChangedCallback, hModel} );

fWPA.pack; 				% trigger the layout manager
fWPA.setSize(700, 500); 		% set the default window's size
fWPA.show;				% everything is finished, 
					% show the dialog
% end CreateDlg;


% Function: doAdd ==============================================================
% Abstract:
%   Add selected variables into the table
%
function doAdd(bAdd, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));

appdata.bStatus.setText('Adding parameters to table ...');

AddSelectedVarsIntoTable(appdata.lVariables, [], hModel);

set(bAdd, 'Enabled', 'off');				
appdata.bStatus.setText('Ready');

% end doAdd


% Function: doApply ============================================================
% Abstract:
%   Apply the changes on the dialog and leave the figure open.
%
function doApply(bApply, evd, hModel)

appdata = getappdata(0,get_param(hModel, 'Name'));

appdata.bStatus.setText('Saving parameters...');

% applying the changes you made on the dialog
invalidVars = SaveTunableVars( appdata );

% set the parameter workspace source
if findstr(get(appdata.cVarsSelection, 'Text'), 'MATLAB')
  set_param(hModel, 'ParamWorkspaceSource', 'MATLABWorkspace');
elseif findstr(get(appdata.cVarsSelection, 'Text'), 'Referenced')
  set_param(hModel, 'ParamWorkspaceSource', 'ReferencedWorkspace');
else
  errordlg('Error when set_param on workspace source.');
end

if ~isempty(invalidVars)
  errordlg('Error when set_param on tunable parameters.');
else
  set(bApply, 'Enabled', 'off');
end
appdata.bStatus.setText('Ready');

% end doApply


% Function: doCancel ===========================================================
% Abstract:
%   Cancel any unapplied change and close the figure.
%
function doCancel(bCancel, evd, hModel)

appdata = getappdata(0,get_param(hModel, 'Name'));

fWPA        = appdata.fWPA;
tAttributes = appdata.tAttributes;

% remove all unsaved changes
tableData = tAttributes.getData;
tableData.removeRows(0, tableData.getHeight);

doCloseFigure(bCancel, evd, fWPA);

% end doCancel


% Function: doCloseFigure ======================================================
% Abstract:
%   This function closes the figure without deleting the figure's handle.
%
function doCloseFigure(frame, evd, fWPA)

fWPA.setVisible(0);
fWPA.dispose;

% end doCloseFigure


% Function: doHelp =============================================================
% Abstract:
%   Launch the helpdesk.
%
function doHelp(bHelp, evd, fWPA)

helpview([docroot '/mapfiles/simulink.map'], 'model_config_optimization');

% end doHelp  


% Function: doNew ==============================================================
% Abstract:
%   Add a new entry in attributes table.
%
function doNew(bNew, evd, hModel)

% get app data
appdata = getappdata(0, get_param(hModel, 'Name'));
lVariables  = appdata.lVariables;	% get listbox's handle
tAttributes = appdata.tAttributes;	% get Table's handle

% add one row in the table
oldHeight = tAttributes.getData.getHeight;
tAttributes.getData.setHeight(1 + oldHeight);

% create popup list for column 2,3 in the table
tAttributes = AddNewItemInTable(tAttributes, 1);

% set the cursor in the Name cell of that new row
tAttributes.select(oldHeight, 0);

set(appdata.bRemove, 'Enabled', 'on');
set(appdata.bApply, 'Enabled', 'on');

% end doNew 


% Function: doOK ===============================================================
% Abstract:
%   This function apply the change and close the figure without
%   actually deleting it.
%
function doOK(bOK, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));
fWPA = appdata.fWPA;
doApply(appdata.bApply, evd, hModel);

fWPA.setVisible(0);
fWPA.dispose;

set(appdata.bApply, 'Enabled', 'off');

% end doOK


% Function: doRefresh ==========================================================
% Abstract:
%   This is the 'Refresh list' button callback function.
%
function doRefresh(bRefresh, evd, hModel)
  
appdata = getappdata(0, get_param(hModel, 'Name'));

cVarsSelection = appdata.cVarsSelection;
valSelected = get(cVarsSelection, 'Text');
choices     = get(cVarsSelection, 'Label');

try
  wsSrc = get_param(hModel, 'ParamWorkspaceSource');
  if findstr(wsSrc, 'MATLAB')
    wsSrc = 'MATLAB workspace';
  else
    wsSrc = 'Referenced workspace variables';
  end
catch
  wsSrc = 'MATLAB workspace';
end

if strcmp(wsSrc, choices{1})
  appdata = LoadWhosData(appdata);
elseif strcmp(wsSrc, choices{2})
  lVariables = LoadReferencedVars(appdata, hModel);
else
  error(['Internal data corruption happened. Close your model and' ...
	 ' re-open dialogs.']);
end

set(appdata.bApply, 'Enabled', 'on');

setappdata(0, get_param(hModel, 'Name'), appdata);

% end doRefresh 


% Function: doRemove ===========================================================
% Abstract:
%   Remove one or more attributes from the table.
%
function doRemove(bRemove, evd, hModel)
import com.mathworks.mwt.table.*;

% get app data
appdata = getappdata(0, get_param(hModel, 'Name'));
lVariables  = appdata.lVariables;	% get listbox's handle
tAttributes = appdata.tAttributes;	% get Table's handle

% get the index of selected rows (multiple selection is possible)
try  rowIndx = tAttributes.getSelectedRows; catch  rowIndx = []; end

% get the name of those selected variables
removedItems = [];
for i = 1 : length(rowIndx)
  removedItems = [removedItems, '/', ...
		  tAttributes.getCellData(rowIndx(i), 0), '/'];
end

% go 'Source list' to turn the removed parameter's font to be normal
itemsOnList  = get(lVariables,'Items');
releasedIndx = [];
lStyle = Style;
for i = 0:length(itemsOnList)-1
  item = ['/', itemsOnList{i+1}, '/'];
  if ~isempty(findstr(removedItems, item))
    lVariables.setRowStyle(i, lStyle);
  end
end
lVariables.repaint;

% remove it from the table
if ~isempty(rowIndx)
  tableData = tAttributes.getData;
  tableData.removeRows(rowIndx(1), length(rowIndx));
end

if tAttributes.getData.getHeight > 0
  set(appdata.bRemove, 'Enabled', 'on');
else
  set(appdata.bRemove, 'Enabled', 'off');
end
set(appdata.bApply, 'Enabled', 'on');

% restore appdata
appdata.tAttributes = tAttributes;
appdata.lVariables  = lVariables;
setappdata(0, get_param(hModel, 'Name'), appdata);

% end doRemove 


% Function: doMouseEnterFcn ====================================================
% Abstract:
%   This function handles all the mouse enter function callback.
%
function doMouseEnterFcn(obj, evd, hModel)

if ishandle(hModel)
  mdlName = get_param(hModel, 'Name');
  appdata = getappdata(0, mdlName);

  itemName = get(obj, 'Name');
  
  switch itemName
   case 'AddToTableButton'
    str = sprintf(['Add selected variables to Global\n', ...
		   '(tunable) parameters table']);
   case 'OKButton'
    str = sprintf('Apply changes and close the dialog');
   case 'CancelButton'
    str = sprintf('Discard changes and close the dialog');
   case 'HelpButton'
    str = sprintf('Launch Help');
   case 'ApplyButton'
    str = sprintf('Apply changes');
   case 'RefreshButton'
    str = sprintf('Refresh the Source list');
   case 'NewButton'
    str = sprintf(['Add new parameter to Global\n', ...
		   '(tunable) parameters table']);
   case 'RemoveButton'
    str = sprintf(['Remove selected parameters from\n', ...
		   'Global (tunable) parameters table']);
   case 'VarsSelectionPopup'
    str = sprintf('Display variables in selected source');
   case 'VarsListbox'
    str = sprintf(['Select variables and press ''Add to table''\n', ...
		   'to add to Global (tunable) parameters table']);
   otherwise
    str = sprintf('no status');
  end
  
  bStatus = appdata.bStatus;
  bStatus.setText(str);
end

% end doMouseEnterFcn


% Function: doMouseExitFcn =====================================================
% Abstract:
%   This function handles all the mouse exit function callback.
%
function doMouseExitFcn(obj, evd, hModel)

if ishandle(hModel)
  mdlName = get_param(hModel, 'Name');
  appdata = getappdata(0, mdlName);
  
  itemName = get(obj, 'Name');
  
  switch itemName
   case {'AddToTableButton', 'OKButton', 'CancelButton', 'HelpButton', ...
	 'ApplyButton', 'RefreshButton', 'NewButton', 'RemoveButton', ...
	 'VarsSelectionPopup', 'VarsListbox'}
    str = sprintf('Ready');
   otherwise
    % no-op
    str = '';
  end
  
  if ~isempty(str)
    bStatus = appdata.bStatus;
    bStatus.setText(str);
  end
end

% end doMouseExitFcn


% Function: doWsSelection ======================================================
% Abstract:
%   This function handles the workspace choices popup menu callback.
%
function doWsSelection(cVarsSelection, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));

valSelected = get(cVarsSelection, 'Text'); % get popup's current selection
choices     = get(cVarsSelection, 'Label'); % get popup's string

if strcmp(valSelected, choices{1})
  appdata = LoadWhosData(appdata);
elseif strcmp(valSelected, choices{2})
  lVariables = LoadReferencedVars(appdata, hModel);
else
  error(['Internal data corruption happened. Close your model and' ...
	 ' re-open dialogs.']);
end
set(appdata.bApply, 'Enabled', 'on');

setappdata(0, get_param(hModel, 'Name'), appdata);

% end doWsSelection  


% Function: AddNewItemInTable ==================================================
% Abstract:
%
function table = AddNewItemInTable(table, numNewItems)

import com.mathworks.mwt.table.*;

% 'Storage class' column
storageClassStr = {...		% default storage class
    'SimulinkGlobal (Auto)'; ...
    'ExportedGlobal'; ...
    'ImportedExtern'; ...
    'ImportedExternPointer'};

% type qualifier' column
typeQualifierStr = {''; 'const'; };

nRows = table.getData.getHeight;
if nRows == 0
  error(['M-assert: table cannot be empty when calling function:' ...
	 ' AddNewItemInTable.']);
  return;
end
for i = nRows-numNewItems : nRows-1
  storageClassCell = DynamicEnumWithState(storageClassStr);
  storageClassCell.setEditable(0);
  table.setCellData(i, 1, storageClassCell);

  typeQualifierCell = DynamicEnumWithState(typeQualifierStr);
  typeQualifierCell.setEditable(1);
  table.setCellData(i, 2, typeQualifierCell);
end

% end AddNewItemInTable


% Function: AddSelectedVarsIntoTable ===========================================
% Abstract:
%   Select variables from the variable list and add it (them) into
%   the attributes setting table.
%
function AddSelectedVarsIntoTable(lVariables, evd, hModel)

import com.mathworks.mwt.table.*;

% get appdata
appdata = getappdata(0, get_param(hModel, 'Name'));
lVariables  = appdata.lVariables;	% get listbox's handle
tAttributes = appdata.tAttributes;	% get Table's handle

% get the cell data where it's changed on the listbox
rowIndx = [];
if lVariables.getItemCount > 0
  try  rowIndx = lVariables.getSelectedRows; catch  rowIndx = []; end
end

selectedItems = [];
if ~isempty(rowIndx)
  lStyle = Style;
  lStyle.setFont(...
      java.awt.Font('', ...
		    java.awt.Font.BOLD+java.awt.Font.ITALIC, ...
		    lStyle.getFont.getSize));

  for i = 1:length(rowIndx)
    selectedItems = [selectedItems; ...
		     {lVariables.getCellData(rowIndx(i), 0)}];
    lVariables.setRowStyle(rowIndx(i), lStyle);
  end
end
lVariables.repaint;

% get the existing vars in table
prevVars = GetExistingVarsInTable(tAttributes);

if ~isempty(selectedItems)
  % add them into the Table
  nRows = tAttributes.getData.getHeight;
  
  % update the table's data
  for i = nRows : nRows+length(selectedItems)-1
    if isempty(findstr(...
	prevVars, ['/' deblankall(selectedItems{i-nRows+1}) '/']))
      % create popup list for column 2,3 on the new row
      tAttributes.getData.setHeight(tAttributes.getData.getHeight+1);
      tAttributes = AddNewItemInTable(tAttributes, 1);

      % set parameter's name
      tAttributes.setCellData(tAttributes.getData.getHeight-1, 0, ...
					    selectedItems{i-nRows+1});
      
    else
      % variable already in table
    end
  end
end

if tAttributes.getData.getHeight > 1	% sort it by names
  tAttributes = SortRowsInTable(tAttributes, hModel);
end

% refresh region of the table
tAttributes.repaint;
  
appdata.lVariables  = lVariables;	% set listbox's handle
appdata.tAttributes = tAttributes;	% set Table's handle

setappdata(0, get_param(hModel, 'Name'), appdata);

% end AddSelectedVarsIntoTable


% Function: GetDialogName ======================================================
% Abstract:
%   Get the name of this dialog for each simulink model.
%
function name = GetDialogName(hModel)

if nargin < 1
  modelName = [];
else
  modelName = get_param(hModel,'name');
end
name = ['Model Parameter Configuration: ' modelName];

% end GetDialogName


% Function: GetExistingVarsInTable =============================================
% Abstract:
%   Return the variables list of the table's first column.
%
function vars = GetExistingVarsInTable(table)

try 
  vars = [];
  if table.getData.getHeight > 0
    for i = 0 : table.getData.getHeight-1
      vars = [vars, '/', deblankall(table.getCellData(i, 0)) '/'];
    end
  end
catch
  vars = [];
end

% end GetExistingVarsInTable


% Function: ListboxItemStateChangedCallback ====================================
% Abstract:
%   This function is the variable listbox callback function. It
%   will be called whenever the listbox's item state changed.
%
function ListboxItemStateChangedCallback(listbox, evd, hModel)

% get app data
appdata = getappdata(0, get_param(hModel, 'Name'));
listbox = appdata.lVariables;	% get handle

% get the index of selected rows
rowIndx = [];
if listbox.getItemCount > 0
  try  rowIndx = listbox.getSelectedRows; catch  rowIndx = []; end
end

cVarsSelection = appdata.cVarsSelection;
valSelected = get(cVarsSelection, 'Text');
choices     = get(cVarsSelection, 'Label');
if length(rowIndx) > 0
  set(appdata.bAdd, 'Enabled', 'on');
end

% end ListboxItemStateChangedCallback


% Function: LoadReferencedVars =================================================
% Abstract:
%      Load the parameters that are referenced by the model.
%
function listbox = LoadReferencedVars( appdata, hModel )

import com.mathworks.mwt.table.*;	% for Style

appdata.bStatus.setText('Loading parameters...');

% get the list of variables that exist in the table
varsInTable = [];
if isfield(appdata, 'tAttributes')
  tAttributes = appdata.tAttributes;	% get the table handle
  varsInTable = GetExistingVarsInTable(tAttributes);
end

listbox        = appdata.lVariables;
warnMsg        = [];
referencedVars = [];
try
  referencedVars = get_param(hModel, 'ReferencedWSVars');
catch
  warnMsg = 'Unable to resolve all parameter fields';
end

listbox.removeAllItems;		% clear all first
  
% set style to be normal
lStyle = Style;

if ~isempty(referencedVars)
  nRows = length(referencedVars);
  listbox.removeAllItems;		% clear all first
  
  varsList = {};
  varsList = {referencedVars.Name}';

  if ~isempty(varsList)
    listbox.setItems(varsList);
  end
else
  % no-op for now 
end

if ~isempty( warnMsg )
  set_param(hModel, 'SimulationCommand', 'Start');
  appdata.bStatus.setText( warnMsg );
else
  appdata.bStatus.setText('Ready');
end

SyncAndUpdateTable(tAttributes, listbox, varsInTable, appdata);

setappdata(0, get_param(hModel, 'Name'), appdata);

% end LoadReferencedVars


% Function: LoadTunableVars ====================================================
% Abstract:
%      Load the model's tunable parameters and parsing them into one string and
%      return it. Gateway function. Could be removed afterward.
%
function tunableVars = LoadTunableVars( hModel )

% load tunable vars from the model
tunableVars = PrmStr2Struct( hModel );

%end LoadTunableVars


% Function: LoadWhosData =======================================================
% Abstract:
%   This function will retrieve the data from MATLAB workspace by
%   doing 'whos' command and displaying them in the listbox.
%
function appdata = LoadWhosData(appdata, listbox)

import com.mathworks.ide.workspace.*;	% for whosparser
import com.mathworks.mwt.table.*;	% for Style

ud = appdata;

ud.bStatus.setText('Loading parameters...');

% get the list of variables that exist in the table
varsInTable = [];
if isfield(ud, 'tAttributes')
  tAttributes = ud.tAttributes;	% get the table handle
  varsInTable = GetExistingVarsInTable(tAttributes);
end

if nargin == 2
  lVariables = listbox;
else
  lVariables = ud.lVariables;
end

hModel = ud.hModel;			% get the model's handle
ud = getappdata(0, get_param(hModel, 'Name'));

% Get the whos data using built-in functionality
[Names, unused1, unused2] = mexGetWSData('base', 1, 1, 0);

Names = sortrows(Names);
% insert whos data into the workspace variables listbox
if ~isempty(Names)
  lVariables.removeAllItems;		% clear all first
  
  % set style to be normal
  lStyle = Style;
  
  lVariables.setItems(Names);
else
  % no-op for now 
end

SyncAndUpdateTable(tAttributes, lVariables, varsInTable, appdata);

ud.bStatus.setText('Ready');

setappdata(0, get_param(hModel, 'Name'), ud);

% end LoadWhosData



% Unused functions between lines ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Function: MultiStorageClassChange ============================================
% Abstract:
%   Change multiple parameters' storage class at once.
%
function MultiStorageClassChange(cStorageClass, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));
tAttributes = appdata.tAttributes;	% get Table's handle

selectedText = get(cStorageClass, 'Text');

tAttributes = MultiChangeCallback(tAttributes, 2, selectedText);
set(appdata.bApply, 'Enabled', 'on');

% end MultiStorageClassChange


% Function: MultiTypeQualifierChange ===========================================
% Abstract:
%   Change multiple parameters' type qualifier at once
%
function MultiTypeQualifierChange(cTypeQualifier, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));
tAttributes = appdata.tAttributes;	% get Table's handle

selectedText = get(cTypeQualifier, 'Text');

tAttributes = MultiChangeCallback(tAttributes, 3, selectedText);
set(appdata.bApply, 'Enabled', 'on');

% end MultiTypeQualifierChange


% Function: MultiChangeCallback ================================================
% Abstract:
%   Change multiple parameters' attributes at once
%
function table = MultiChangeCallback(table, colNum, newText)

% get the index of selected rows (only for multiple selection)
try  rowIndx = table.getSelectedRows; catch  rowIndx = []; end

if ~isempty(rowIndx)
  for i=1:length(rowIndx)
    if colNum == 1			% no type qualifier for 'Auto'
      % potential error caused by java.lang.string
      storageClassText = ...
	  lower(deblankall( ...
	      table.getCellData(rowIndx(i), colNum-1).getCurrentString));
      
      if strcmp(storageClassText, 'auto')
	newText = ' ';
	warningstate = [warning; warning('query','backtrace')];
	warning off backtrace;
	warning on;
	warning(['Parameter ' table.getCellData(rowIndx(i), 0) ...
		 ' has storage class ''Auto'' and can not have storage type' ...
		 ' qualifier specified.']);
	warning(warningstate);
      end
    end
    % potential error caused by java.lang.string
    table.getCellData(rowIndx(i), colNum).setCurrentString( newText );
  end
end

% refresh the affected region on the table
table.repaintCells(rowIndx(1), colNum, length(rowIndx), 1);

% end MultiChangeCallback

% Unused functions between lines ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Function: PrmStr2Struct ======================================================
% Abstract:
%      Loading saved tunable parameters from model and convert them
%      into a structure array.
%      i.e.: TunableVars             = 'a,    b,              c';
%            TunableVarsStorageClass = 'Auto, ExportedGlobal, ImportedExtern'
%            TunableVarsTypeQualifier= '    , const,          const'
%      the input like this will have the output as:
%            a(1).name         = 'a'
%            a(1).storageclass = 'Auto'
%            a(1).typequalifier= '';
%            a(2).name         = 'b'
%            a(2).storageclass = 'ExportedGlobal'
%            a(2).typequalifier= 'const';         ... and so on.
%
function varsInStruct = PrmStr2Struct( hModel )

tunableVarsName          = get_param(hModel, 'TunableVars');
tunableVarsStorageClass  = get_param(hModel, 'TunableVarsStorageClass');
tunableVarsTypeQualifier = get_param(hModel, 'TunableVarsTypeQualifier');

varsInStruct = [];

% Locate the separate symbol's position.
sep         = ',';
sepNameIndx = findstr(tunableVarsName, sep);
sepSCIndx   = findstr(tunableVarsStorageClass, sep);
sepTQIndx   = findstr(tunableVarsTypeQualifier, sep);

% Get the number of Tunable Variables
if ~isempty(tunableVarsName)
  numberVars = length(sepNameIndx) + 1;
else
  numberVars = 0;
end

vars = [];
if numberVars
  % Error handling
  if length(sepSCIndx)+1 ~= numberVars
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	 get_param(hModel,'name'), ... 
	 '. Number of tunable parameter names doesn''t match the number ' ...
	 'of storage class settings. Loading failed.'], ...
	'Model Parameter Configuration Dialog Error', 'modal');
    return;
  elseif  length(sepTQIndx)+1 ~= numberVars
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	 get_param(hModel,'name'), ...
	 '. Number of tunable parameter names doesn''t match the number ' ...
	 'of type qualifier settings. Loading failed.'], ...
	'Model Parameter Configuration Dialog Error', 'modal');
    return;
  elseif  length(sepTQIndx) ~= length(sepSCIndx)
    errordlg(...
	['Error on tunable parameters setting in model: ', ...
	  get_param(hModel,'name'), ...
	  '. Number of tunable parameter storage class settings doesn''t ' ...
	  'match the number of type qualifier settings. Loading failed.'], ... 
	'Model Parameter Configuration Dialog Error', 'modal');
    set(Children.okButton, 'Enable', 'off');
    set(Children.applyButton, 'Enable', 'off');
    return;
  end

  % Re-locate the separate symbol's position.
  sepNameIndx = [0 sepNameIndx length(tunableVarsName)+1];
  sepSCIndx   = [0 sepSCIndx length(tunableVarsStorageClass)+1];
  sepTQIndx   = [0 sepTQIndx length(tunableVarsTypeQualifier)+1];

  for i = 1 : numberVars
    % tunable variable name
    vars(i).name = deblankall(tunableVarsName(sepNameIndx(i)+1 : ...
				   sepNameIndx(i+1)-1));
    if ~validate(vars(i).name)
      warningstate = [warning; warning('query','backtrace')];
      warning off backtrace;
      warning on;
      warning([ ...
	  'Invalid variable specified: ''' vars(i).name '''. ' ...
	  'Variable must have an valid MATLAB variable name. ' ...
	  'Please check them in model by typing the ' ...
	  'following in command window:' sprintf('\n') ...
	  'get_param(''' get_param(hModel,'Name')  ''', ''TunableVars'')']);
      warning(warningstate);
    end

    % tunable variable storage class
    vars(i).storageclass = deblankall( ...
	tunableVarsStorageClass(sepSCIndx(i)+1 : sepSCIndx(i+1)-1));
    if strcmp(lower(vars(i).storageclass), 'auto')
      vars(i).storageclass = 'SimulinkGlobal (Auto)';
    elseif strcmp(lower(vars(i).storageclass), 'exportedgloabal')
      vars(i).storageclass = 'ExportedGloabal';
    elseif strcmp(lower(vars(i).storageclass), 'importedextern')
      vars(i).storageclass = 'ImportedExtern';
    elseif strcmp(lower(vars(i).storageclass), 'importedexternpointer')
      vars(i).storageclass = 'ImportedExternPointer';
    end
  
    % tunable variable type qualifier
    if isempty(tunableVarsTypeQualifier(sepTQIndx(i)+1 : sepTQIndx(i+1)-1))
      vars(i).typequalifier = '';
    else
      vars(i).typequalifier= tunableVarsTypeQualifier(sepTQIndx(i)+1 : ...
						    sepTQIndx(i+1)-1);
    end
  end  

end

varsInStruct = vars;			% output of the function

% end PrmStr2Struct


% Function: RefreshListbox =====================================================
% Abstract:
%   Refreshing the variable listbox according to the data
%
function listbox = RefreshListbox( listbox, data )

import com.mathworks.mwt.table.*;	% for Style

listbox.removeAllItems; % clear all first

for i = 0 : length(data)-1
  listbox.addItem(' ');
  % update workspace variable listbox
  listbox.setCellData(i, 0, deblankall(data(i+1).name));
  
  varSize  = '';
  varClass = '';
  
  % set style to change the foreground color of the line
  lStyle = Style(Style.FOREGROUND);

  if evalin('base',['exist(''' data(i+1).name ''')'])
    [m,n] = size(data(i+1).name);
    varSize  = [num2str(m), 'x', num2str(n)];
    varClass = evalin('base', ['class(' data(i+1).name ')']);
  else
    lStyle.setFont( ...
	java.awt.Font('', ...
		      java.awt.Font.BOLD+java.awt.Font.ITALIC, ...
		      lStyle.getFont.getSize));
  end
  
  % set the font of the row
  listbox.setRowStyle(i, lStyle);
end
listbox.repaint;

% end RefreshListbox


% Function: RefreshTable =======================================================
% Abstract:
%   Refreshing the parameter attributes table according to the data
%
function table = RefreshTable( table, prevData, data )
 
redundent = 0;
prevTableHeight = table.getData.getHeight;
if isempty(prevData)
  % no need to detect any exisitng data
  table.getData.setHeight(length(data));
  table = AddNewItemInTable(table, length(data));
  for i = 0 : length(data)-1
    table.setCellData(i, 0, deblankall(data(i+1).name));
    table.getCellData(i, 1).setCurrentString(data(i+1).storageclass);
    table.getCellData(i, 2).setCurrentString(data(i+1).typequalifier);
  end
else
  for i = 0 : length(data)-1
    % update table
    if isempty(findstr(prevData, ['/' deblankall(data(i+1).name) '/']))
      table.getData.setHeight(prevTableHeight + i + 1 - redundent);
      table = AddNewItemInTable(table, 1);
      table.setCellData(i+prevTableHeight-redundent, 0, ...
				      deblankall(data(i+1).name));
      table.getCellData(i+prevTableHeight-redundent, 1).setCurrentString( ...
	  data(i+1).storageclass);
      table.getCellData(i+prevTableHeight-redundent, 2).setCurrentString( ...
	  data(i+1).typequalifier);
    else
      redundent = redundent + 1;
    end
  end
end
table.repaint;

% end RefreshTable


% Function: SaveTunableVars ====================================================
% Abstract:
%      Parsing tunable parameters and save them into three system
%      parameters: TunableVars, TunableVarsStorageClass &
%                  TunableVarsTypeQualifier 
%
function invalidVars = SaveTunableVars( appdata )

invalidVars = [];

hModel = appdata.hModel;
tAttributes = appdata.tAttributes;

tunableVarsName          = [];
tunableVarsStorageClass  = [];
tunableVarsTypeQualifier = [];

% parse table data into these 3 parameters.
for i = 0:tAttributes.getData.getHeight-1
  if i == 0
    sep = '';
  else
    sep = ',';
  end
  tunableVarsName = [tunableVarsName, sep, ...
		     deblankall(tAttributes.getCellData(i, 0))];
  
  scTmp = deblankall(tAttributes.getCellData(i, ...
					     1).getCurrentString);
  if ~isempty(findstr(lower(scTmp), 'auto'))
    scTmp = 'Auto';
  end
  tunableVarsStorageClass = [tunableVarsStorageClass, sep, scTmp];
  
  if ~strcmp(lower(scTmp), 'auto')
    tqTmp = char(tAttributes.getCellData(i, 2).getCurrentString);
  else
    tqTmp = '';
  end
  tunableVarsTypeQualifier = [tunableVarsTypeQualifier, sep, tqTmp]; 

end
  
if tAttributes.getData.getHeight > 0
  set_param( hModel, ...
	     'TunableVars', tunableVarsName, ...
	     'TunableVarsStorageClass', tunableVarsStorageClass, ...
	     'TunableVarsTypeQualifier', tunableVarsTypeQualifier ...
	     );
else
  % No Tunable Parameters were set up, set parameters to be empty.
  set_param( hModel, ...
	     'TunableVars', '', ...
	     'TunableVarsStorageClass', '', ...
	     'TunableVarsTypeQualifier', '' ...
	     );
end


%end SaveTunableVars


% Function: SortRowsInTable ====================================================
% Abstract:
%   Sort the parameters in the table by their name
%
function sortedTable = SortRowsInTable(table, hModel)
import com.mathworks.mwt.table.*;

appdata = getappdata(0, get_param(hModel, 'Name'));
tAttributes = appdata.tAttributes;	% get Table's handle

% first backup the table data
for i=0:tAttributes.getData.getHeight-1
  for j = 0:2
    switch j
     case 0
      tableDataAsMatrix{i+1,j+1} = tAttributes.getCellData(i,j);
     case {1,2}
      tableDataAsMatrix{i+1,j+1} = ...
	  char(tAttributes.getCellData(i,j).getCurrentString);
     otherwise
      % no-op
    end
  end
end
newTableDataAsMatrix = sortrows(tableDataAsMatrix, 1);

% set sorted table data
for i=0:tAttributes.getData.getHeight-1
  for j = 0:2
    switch j
     case 0
      tAttributes.setCellData(i,j, newTableDataAsMatrix{i+1,j+1});
     case {1,2}
      tAttributes.getCellData(i,j).setCurrentString(...
	  newTableDataAsMatrix{i+1,j+1});
     otherwise
      %no-op
    end
  end
end
sortedTable = tAttributes;

%end SortRowsInTable


% Function: SyncAndUpdateTable =================================================
% Abstract:
%   Update the table and synchronize the source list.
%
function SyncAndUpdateTable(tAttributes, lVariables, varsInTable, appdata)

import com.mathworks.mwt.table.*;	% for Style

% load the tunable parameters that are saved in the model into the
% attributes table 
tAttributes = appdata.tAttributes;
% get the tunable vars in structure format
tunableVars = LoadTunableVars( appdata.hModel );
if ~isempty(tunableVars)
  tAttributes = RefreshTable(tAttributes, varsInTable, ...
			     tunableVars);
end

% if anything is listed in the WS listbox, set it to be BOLD&ITALIC
lStyle = Style;
lStyle.setFont( ...
    java.awt.Font('', ...
		  java.awt.Font.BOLD+java.awt.Font.ITALIC, ...
		  lStyle.getFont.getSize));

varsNames = [];
for i = 0:tAttributes.getData.getHeight-1
  varsNames = [varsNames, ...
	       '/', deblankall(tAttributes.getCellData(i, 0)), '/'];
end
repaintFlag = [];
if lVariables.getItemCount > 0 && ~isempty(varsNames)
  for i = 0 : lVariables.getItemCount-1
    if ~isempty(findstr(varsNames, ...
			['/', lVariables.getCellData(i, 0), '/']))
      lVariables.setRowStyle(i, lStyle);
      repaintFlag = 1;
    end
  end
end

if ~isempty(repaintFlag)
  lVariables.repaint;
end

% end SyncAndUpdateTable



% Function: TableItemStateChangedCallback ======================================
% Abstract:
%   This function is the attributes table callback function. It
%   will be called whenever the table's item state changed.
%
function TableItemStateChangedCallback(tAttributes, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));
tAttributes = appdata.tAttributes;	% get Table's handle

% get the index of selected rows (multiple selection is possible
rowIndx = [];
if tAttributes.getData.getHeight > 0
  try  rowIndx = tAttributes.getSelectedRows; catch  rowIndx = []; end
end

if length(rowIndx) > 0
  set(appdata.bRemove, 'Enabled', 'on');
  set(appdata.bApply, 'Enabled', 'on');
end

% end TableItemStateChangedCallback 


% Function: TableValueChangedCallback ==========================================
% Abstract:
%   This function is the attributes table callback function. It
%   will be called whenever the table's item value changed.
%
function TableValueChangedCallback(tAttributes, evd, hModel)

appdata = getappdata(0, get_param(hModel, 'Name'));
tAttributes = appdata.tAttributes;
lVariables  = appdata.lVariables;
bStatus     = appdata.bStatus;

cbData  = get(tAttributes, 'ValueChangedCallbackData');
rowNum  = cbData.row;
prevStr = cbData.previousValue;
varName = tAttributes.getCellData(rowNum, cbData.column);

if cbData.column == 0				% name validating
  if ~validate(varName)
    warnStr = ['Invalid variable specified: ''' varName '''. ' ...
	       sprintf('\n'), ...
	       'It must be an valid MATLAB variable name. '];
    bStatus.setText(warnStr);
    tAttributes.setCellData(rowNum, cbData.column, prevStr);
  end
  
elseif cbData.column == 1 && ...
      ~isempty(deblankall(tAttributes.getCellData(rowNum, ...
						  2).getCurrentString))
  % no type qualifier for Auto class
  tAttributes.getCellData(rowNum, 2).setCurrentString( '' );

elseif cbData.column == 2 && ...
      ~isempty(deblankall(tAttributes.getCellData(rowNum,2).getCurrentString))
  % no type qualifier for 'Auto'
  storageClassText = ...
      lower(deblankall( ...
	  tAttributes.getCellData(rowNum, 1).getCurrentString));
  if ~isempty(findstr(storageClassText, 'auto'))
    newText = '';
    warnStr = ['''' tAttributes.getCellData(rowNum, 0) ...
	       ''' has storage class ''SimulinkGlobal (Auto)''' ...
	       sprintf('\n'), ...
	       'that can not have storage type qualifier specified.'];
    bStatus.setText(warnStr);
    tAttributes.getCellData(rowNum, 2).setCurrentString( newText );
  end
end

% get the list of variables that exist in the table
%varsInTable = [];
varsInTable = GetExistingVarsInTable(tAttributes);

set(appdata.bApply, 'Enabled', 'on');
tAttributes.deselectAll;

% end TableValueChangedCallback


% Function: commonGeomFcn ======================================================
% Abstract:
%   Set up some geom for general usage to keep every little details consistent.
%
function vCommonGeom = commonGeomFcn

import java.awt.*;
%
% common insets, e.g. the gap between groupbox's left border and
% the frame's left edge.
%
vCommonGeom.insets = Insets(5, 5, 5, 5);

% common gaps
vCommonGeom.hGap = 3;
vCommonGeom.vGap = 5;

% end commonGeomFcn


% Function: validate ===========================================================
% Abstract:
%      Detect the valid MATLAB variable.
% 
function valid = validate(var)
eval([var '=[];valid=1;'],'valid=0;')

%endfunction

%[eof]
