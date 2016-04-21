function sltbledit( varargin )
% SLTBLEDIT Simulink Lookup table editor dialog. This function will
% be called from any Simulink model under 'Tools' menu.
%
% To use this dialog, MATLAB must have Java Swing supported. 
% See general MATLAB Release Notes for details.
%

%  Jun Wu, Mar. 2001
%  Copyright 1990-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.11 $

% Abstract:
%   This dialog will provide an user interface that user can do following task:
%   1) view all opening Simulink models;
%   2) for each model, list all lookup table blocks in a tree viewer;
%   3) list the table data in a table, for n-D (n>2) table, the table will
%      be displayed in a 2-D slice format;
%   4) view table data in two format: plot and mesh surface;
%   5) adjust the table data on numerical table.
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Main entrance of this file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

err = javachk('Swing', createFigureTitle([]));
if ~isempty(err)
  error(err);
end

% This function will return the frame figure handle by default
msg = nargchk(0, 1, nargout);
if ~isempty(msg)
  error('SIMULINK:LUTEDITOR', msg);
end

action = varargin{1};			% action switch
srcBlk = varargin{2};

try
  switch lower(action)
   case 'create'
    % check the second input argument to be a model handle
    try
      if ~ishandle(get_param(srcBlk, 'Handle'))
        error('SIMULINK:LUTEDITOR', ...
              'To create Lookup Table Editor, the second argument must be a model handle');
      end
    catch
      error('SIMULINK:LUTEDITOR', ...
            'Internal error while opening Lookup Table Editor.');
    end
    % If the dialog has been opened and set to invisible, turn it to be visible;
    % otherwise, create it from the scratch.
    if isappdata(0, 'SLLookupTableEditor') && ...
	  ~isempty(getappdata(0, 'SLLookupTableEditor'))
      appdata  = getappdata(0, 'SLLookupTableEditor');
      FigFrame = appdata.SwingWidgets.FigFrame;
      
      if ishandle(FigFrame) && ...
	    ~isempty(findstr(FigFrame.getTitle, 'Lookup Table Editor') == 1)
        % here we activate Lookup Table Editor through simulink model, then we
        % need to update the cache info for SelectedMdl.
        updateCurrentSelectedMdl(appdata, srcBlk);
        return;
      end
    else
      if ~isempty(bdroot(srcBlk))
	% create the brand new dialog
	createDialog(srcBlk);
      else
	disp('There is no Simulink model currently open. Lookup Table Editor loading is stopped.');
	return;
      end
    end
    
   case 'close'
    doClose([], []);
   
   case 'commandapi'
    cmdStr = varargin{2};
    appdata  = getappdata(0, 'SLLookupTableEditor');
    if ~isempty(appdata)
      if nargin > 2
        executeAPICommand(cmdStr, appdata, varargin{3});
      else
        executeAPICommand(cmdStr, appdata);
      end
    end
    
   case 'java_event'
    cmdStr = varargin{2};
    eval([cmdStr, '([], []);']);
    
   case 'updatefromdesigner'
    brkData = {varargin{2}, []};
    tblData = varargin{3};
    nDims   = varargin{4};
    
    % update the table data
    appdata     = getappdata(0, 'SLLookupTableEditor');
    DataTable   = appdata.SwingWidgets.DataTable;		% data table handle
    DimSelTable = appdata.SwingWidgets.DimSelTable;
    
    if nDims > 1
      appdata.SwingWidgets.FigFrame.updateToolbarStates(1);
      tblSize = size(tblData);
    else
      appdata.SwingWidgets.FigFrame.updateToolbarStates(0);
      tblSize = length(tblData);
    end
    
    dimSelTblMdl = com.mathworks.toolbox.simulink.lookuptable.LUTDimensionSelectorTableModel(2, nDims+1);
    dimSelTblMdl.initializeModel(tblSize);
    DimSelTable.setLUTTableModel(dimSelTblMdl);
    drawnow;
    
    % create column data and headers
    [data, header, tableMode] = ...
        constructDataAndHeader(appdata.SelectedBlk, brkData, 0, tblData, false);
  
    tableModel = com.mathworks.toolbox.simulink.lookuptable.LUTDefaultTableModel(data, header);
    tableModel.setModelMode(1);
    tableModel.setBreakPointEditable(1,1);

    % set table model
    DataTable.setTableMode(tableMode);
    DataTable.setLUTTableModel(tableModel);
    appdata.SwingWidgets.FigFrame.getMenuUpdate.setEnabled(1);
    drawnow;

   otherwise
    warning('SIMULINK:LUTEDITOR', ...
            ['Incorrect call to %s dialog function.', createFigureTitle([])]);
  end
catch
  if isappdata(0, 'SLLookupTableEditor' )
    appdata = getappdata(0, 'SLLookupTableEditor' );
    FigFrame = appdata.SwingWidgets.FigFrame;
    
    % undo the hilite
    if ~isempty(appdata.SelectedBlk) && ...
          ishandle(get_param(appdata.SelectedBlk, 'Handle'))
      set_param(appdata.SelectedBlk, 'HiliteAncestors', 'off');
    end
    
    if ishandle(FigFrame) && ...
          strcmp(class(FigFrame), ...
                 'com.mathworks.toolbox.simulink.lookuptable.LUT')
      FigFrame.dispose;
    end
    
    % clean up the appdata in ML session
    setappdata(0, 'SLLookupTableEditor', '');
    rmappdata(0, 'SLLookupTableEditor');
  else
    % no-op for now
  end
  
end

% callback dispatcher
function out = lutCallbackHandler(obj, evd)
  feval(char(evd.type), evd.event);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Main Dialog functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Function: checkBpTblDimensionMatch ===========================================
% Abstract:
%   Report dimension mis-match between a block's break-points and table data.
%
function errmsg = checkBpTblDimensionMatch(blk, nDims, brkPts, tblData)
  
errmsg = '';

% check if the table data has the same dimension, error out if not.
if nDims ~= ndims(tblData) && nDims ~= 1
  errmsg = sprintf(['Error reported by block ''%s'': \n' ...
                    'The number of dimensions in the table data is %s ', ...
                    'while the number of dimensions specified in the block is %s. '...
                    'They must match.'], ...
                   blk, num2str(ndims(tblData)), num2str(nDims));
  return;
end

% now we need to check for each dimension to see if they match with the
% correspondent table data
i    = nDims;
j    = 1;
indx = 0;
tblSize = size(tblData);

while i > 1 && ~isempty(brkPts)
  indxStr = '';
  brkPtData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts(nDims-i+1, :)));
  
  if iscell(brkPtData)
    brkPtCellData = brkPtData{j};
    % compare the size of table and its corresponding breakpoint
    if length(brkPtCellData) ~= tblSize(nDims-i+j)
      indx = nDims-i+j;
    end
    if j == length(brkPtData)
      i = 1;
    else
      j = j+1;
    end
  else
    % compare the size of table and its corresponding breakpoint
    if length(brkPtData) ~= tblSize(nDims-i+1)
      indx = nDims-i+1;
    end
    i = i-1;
  end
  
  if indx ~= 0
    if indx == 1
      indxStr = 'first';
    elseif indx == 2
      indxStr = 'second';
    elseif indx == 3
      indxStr = 'third';
    else
      indxStr = [num2str(indx) 'th'];
    end
  end
  if ~isempty(indxStr)
    errmsg = sprintf(['Error reported by block ''%s'': \n', ...
                      'The size of the %s dimension in the table data ' ...
                      'must equal to the size of the %s breakpoint data.'], ...
                     blk, indxStr, indxStr);
    return;
  end
end

% end checkBpTblDimensionMatch


% Function: createDialog =======================================================
% Abstract:
%   This functions creates the main Lookup Table Editor figure and all its
%   graphical components. They are all Java Swing objects so your system and
%   MATLAB must have Java Swing feature supported.
%
function createDialog(srcBlk)

% create main dialog
figFrame = com.mathworks.toolbox.simulink.lookuptable.LUT;

SwingWidgets.FigFrame       = figFrame;
SwingWidgets.ModelsPopup    = figFrame.getModelsPopup;
SwingWidgets.BlocksTree     = figFrame.getBlksListTree;
SwingWidgets.DataTable      = figFrame.getDataTable;
SwingWidgets.DimSelTable    = figFrame.getDimSelTable;
SwingWidgets.TransposeChx   = figFrame.getTransposeChx;
SwingWidgets.UpdateMenu     = figFrame.getMenuUpdate;
SwingWidgets.ReloadMenu     = figFrame.getMenuReload;
SwingWidgets.LinearPlotMenu = figFrame.getMenuLinearPlot;
SwingWidgets.MeshPlotMenu   = figFrame.getMenuMeshPlot;
SwingWidgets.MainSplitPane  = figFrame.getMainSplitPane;
SwingWidgets.DataTablePanel = figFrame.getDataTablePanel;
SwingWidgets.DimSelPanel    = figFrame.getDimSelPanel;

% wire callbacks
set(figFrame, 'lutCallback', @lutCallbackHandler);

% set SwingWidgets to be a field of appdata
appdata.SwingWidgets  = SwingWidgets;
appdata.Plot.PlotFig  = [];		% all HG objects go here
appdata.Plot.PlotType = [];		% either linear plot(=1) or mesh plot(=2)
appdata.ModelList     = {};		% all opening models' handle
appdata.SelectedMdl   = {};		% current selection
appdata.BlksInMdl     = {};		% table blocks list in selected model
appdata.SelectedBlk   = {};		% table that its data is displayed
appdata.Flags.dirtyFlag   = 0;		% several internal flags
appdata.Flags.updateTable = 1;
SwingWidgets.MainSplitPane.setDividerLocation(.25);

% create a list that contains all opened Simulink models
appdata.ModelList = findOpenedModels;
appdata.SwingWidgets.ModelsPopup.setLUTComboBoxModel(appdata.ModelList);

% load the opened models and select the current active one.
if strcmp(get_param(bdroot(srcBlk),'BlockDiagramType'), 'model')
  SwingWidgets.ModelsPopup.setSelectedItem(bdroot(srcBlk));
  SwingWidgets.FigFrame.setCurrentBlockHandle(get_param(srcBlk,'Handle'));
end

% initialize the "lookup table blocks list" cache information.
% load lookup table blocks list from static functions if there is no pref
% info already
%
% set the default lut blocks list
list = defaultlutblklist;
SwingWidgets.FigFrame.setBlksListPrefData(createBlkListTableData(list), 1);

% need to check if user has a preference already
if ispref('sltbledit','blockconfiglist') == 1
  list = getpref('sltbledit','blockconfiglist');
  SwingWidgets.FigFrame.setUseDefaultBlksListPref(0);
  SwingWidgets.FigFrame.setBlksListPrefData(createBlkListTableData(list));
else
  SwingWidgets.FigFrame.setUseDefaultBlksListPref(1);
  SwingWidgets.FigFrame.setBlksListPrefData(...
      SwingWidgets.FigFrame.getDefaultBlksListPrefData);
end
appdata.SupportedTblBlks = list;
SwingWidgets.FigFrame.setTitle([]);
SwingWidgets.FigFrame.setVisible(1);
drawnow;

% set dialog objects to appdata
setappdata(0, 'SLLookupTableEditor', appdata);

% end createDialog


% Function: createDimSel =======================================================
% Abstract:
%   This function will create the Dimension Selector according to the table's
%   actual size. The layout is like the following:
%   (1) Dimension size: read-only, display the data size for each dimension;
%   (2) Select index of slice: a ":" means this dimension is currently 
%                         displayed, others will show the index number with 
%                         up/down arrows to allow user to change;
%  
function createDimSel(DimSelTable, blk)
appdata = getappdata(0, 'SLLookupTableEditor');

if isempty(appdata)
  return;
end

% get the break-point and table name for the selected block
[nDims, hashValue] = getBlockInfo(blk);
tblName = char(hashValue(end));

tblData = getNumericalDataFromBlock(blk, sl('deblankall', tblName));
if nDims > 1
  appdata.SwingWidgets.FigFrame.updateToolbarStates(1);
  tblSize = size(tblData);
else
  appdata.SwingWidgets.FigFrame.updateToolbarStates(0);
  tblSize = length(tblData);
end

dimSelTblMdl = com.mathworks.toolbox.simulink.lookuptable.LUTDimensionSelectorTableModel(2, nDims+1);
dimSelTblMdl.initializeModel(tblSize);
DimSelTable.setLUTTableModel(dimSelTblMdl);
drawnow;

% end createDimSel


% Function: constructDataAndHeader =============================================
% Abstract:
%   Create table data and header array for DefaultTableModel usage. This
%   function will put row/column index and table data itself into the
%   following format:
%   [ []  <---- column index name ---> ]
%   [ ^      <---- column index --->   ]
%   [ |     ^                          ]
%   [row    |                          ]
%   [index row    (table data)         ]
%   [name  data                        ]
%   [ |     |                          ]
%   [ V     V                          ]
%
% Syntax:
%  [data, header, tableMode] = ...
%      constructDataAndHeader(blk, brkPtsData2D, cellIndx, ...
%                             tblData, transposeFlag)
%  Output: data -- the cell array in M x N+1
%
%
function [data, header, tableMode] = ...
      constructDataAndHeader(blk, brkPtsData2D, cellIndx, tblData, transposeFlag)

data   = {};
header = {};
tableMode = 0;
emptyCell = '[ ]';

rowData = brkPtsData2D{1};
colData = brkPtsData2D{2};

% get table size
[nr, nc] = size(tblData);
if isempty(tblData)
  nr = length(rowData);
  nc = length(colData);
else
  if nr < length(rowData)
    nr = length(rowData);
  end
  if nc < length(colData)
    nc = length(colData);
  end
end

tableMode = 1;
header = cell(1, 2+nc);
header(1:2) = {'Breakpoints', 'Column'};
for i = 2:nc+1
  header{1,i+1} = ['(' num2str(i-1), ')'];
end

% first row, which is for column (y_index) value
data = cell(nr+1, nc+2);
data(1,1:2) = {'Row',''};
for j = 3 : nc+2
  if ~isempty(colData)
    if j > length(colData)+2
      data{1, j} = emptyCell;
    else
      data{1, j} = sprintf('%0.5g', colData(j-2));
    end
  else
    data{1, j} = '--';
  end
end
  
% rest of the table, including row header (x_index value)
for j = 2 : nc+2
  for i = 2 : nr+1
    data{i,1} = ['(' sprintf('%d',i-1), ')'];
    if j == 2
      if ~isempty(rowData)
        if j > length(rowData)+1
          data{1, j} = emptyCell;
        else
          data{i,j} = sprintf('%0.5g', rowData(i-1));
        end
      else
        data{i,j} = '--';
      end
    else
      if i>size(tblData, 1)+1 || j>size(tblData,2)+2
        data{i,j} = emptyCell;
      else
        data{i,j} = sprintf('%0.5g', tblData(i-1,j-2));
      end
    end
  end
end

% end constructDataAndHeader


% Function: get2DFromND ========================================================
% Abstract:
%   Given the specified two dimensions index and the table selection index in
%   string format, return a 2-D table with its break-points' name string.
%
function [brkPtsData2D, cellIndx, tblData2D, prelookup] = ...
      get2DFromND(blk, indxStr, default2D, transposeFlag)

% get the selected block's information
[nDims, hashValue] = getBlockInfo(blk);

% get table data from the block
tblName = char(hashValue(end));
tblData = getNumericalDataFromBlock(blk, sl('deblankall', tblName));

% get break points parameters string
brkPts             = char(hashValue(1));
[nBrkPtsPrm, nStr] = size(brkPts);
expNumDimsStr      = char(hashValue(3));

% from the block's BlockType and MaskType information, we are able to get the
% number of dimensions and its explicit number of dimensions, if specified.
[lastmsg, lastid] = lasterr;
try
  blkMaskType = get_param(blk, 'MaskType');
  expNumDims  = sscanf( get_param(blk, expNumDimsStr), '%d' );
catch
  lasterr(lastmsg, lastid);
  blkMaskType = '';
  expNumDims  = 2;  % TODO: default should be OK
end
blkKey    = [get_param(blk, 'BlockType'), '///', blkMaskType];

% This variable is for indicating the coresponding dimension that are selected 
% to be displayed for explicit breakpoint variables.
cellIndx = [];
brkPts2D = [];
prelookup = [1 1];

if isempty(tblData)
  % breakpoints data only
  brkPts2D = brkPts;
else
  if ~isempty(brkPts)
    for i=1:nBrkPtsPrm
      idx = find(default2D == i);
      if ~isempty(idx)
        if i >= nBrkPtsPrm
          brkPts2D = [brkPts2D; brkPts(end, :)];
          if isempty(expNumDimsStr)
            cellIndx = [cellIndx, 0];
          else
            cellIndx = [cellIndx, i-nBrkPtsPrm+1];
          end
        else
          brkPts2D = [brkPts2D; brkPts(i, :)];
          cellIndx = [cellIndx, 0];
        end
      end
    end
  end
end

% --- Get the 2-D data slice (possibly 1-D)

tblData2D = eval(['tblData' indxStr]);
if nDims > 2 || (nDims < 2 && ndims(tblData2D) >= 2)
  tblData2D = squeeze(tblData2D);
end

if transposeFlag
  if ~isempty(brkPts2D) && size(brkPts2D, 1) > 1
    brkPts2D = [brkPts2D(2, :); brkPts2D(1, :)];
  end
  tblData2D = tblData2D';
  if ~isempty(cellIndx)
    cellIndx = fliplr(cellIndx);
  end
end

[numTRows, numTCols] = size(tblData2D);

% --- Get or create the breakpoint data corresponding to the data slice

rowData = [];
colData = [];
if isempty(cellIndx)
  if ~isempty(brkPts2D)
    % for blocks that have explicit break points data
    rowData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(1, :)));
    if size(brkPts2D, 1) > 1
      colData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(2, :)));
    elseif transposeFlag
      colData = rowData;
      rowData = [];
    end
  else
    %  
    % No breakpoint data is in the block, look for an attached pre-lookup.
    %
    % For the 1 or 2 visible dimensions, search for a pre-lookup block 
    % and get the breakpoint info if it exists.  If the breakpoint
    % information cannot be found or if it doesn't exist, use 0-based
    % indexing.
    
    % --- First dimension in slice (TODO: do not hard code port 1 for presrc)
    
    try
      brkPtsBlk = sl('tblpresrc', blk, 1);
      if ishandle(get_param(brkPtsBlk, 'Handle'))
        prelookup(1) = 0;
        [nPreSrc, preSrcHashValue] = getBlockInfo(brkPtsBlk);
        brkPts = char(preSrcHashValue(1));
        rowData = getNumericalDataFromBlock(brkPtsBlk, sl('deblankall', brkPts(1, :)));
      else
        if transposeFlag,
          colData = 0:(numTRows-1);
        else
          rowData = (0:(numTRows-1))';
        end
      end
    catch
      if transposeFlag,
        colData = (0:(numTRows-1));
      else
        rowData = (0:(numTRows-1))';
      end
    end
    
    % --- Second dimension in slice (TODO: do not hard code port 2 for presrc)
    
    try
      brkPtsBlk = sl('tblpresrc', blk, 2);
      if ishandle(get_param(brkPtsBlk, 'Handle'))
        prelookup(2) = 0;
        [nPreSrc, preSrcHashValue] = getBlockInfo(brkPtsBlk);
        brkPts = char(preSrcHashValue(1));
        
        if transposeFlag
          colData = rowData;
          rowData = getNumericalDataFromBlock(brkPtsBlk, sl('deblankall', brkPts(1, :)));
        else
          colData = getNumericalDataFromBlock(brkPtsBlk, sl('deblankall', brkPts(1, :)));
        end
      else
        rowData = (0:(numTRows-1));
      end
    catch
      if transposeFlag,
        colData = rowData;
        rowData = (0:(numTCols-1))';
      else
        colData = (0:(numTCols-1));
      end
    end
  end
else
  %
  % --- Get data for blocks that have explicit breakpoints
  %
  if cellIndx(1) == 0
    rowData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(1, :)));
  else
    cellData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(1, :)));
    rowData = cellData{cellIndx(1)};
  end
  
  if size(brkPts2D, 1) > 1
    if cellIndx(2) == 0
      colData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(2, :)));
    else
      cellData = getNumericalDataFromBlock(blk, sl('deblankall', brkPts2D(2, :)));
      colData = cellData{cellIndx(2)};
    end
  elseif transposeFlag
    colData = rowData;
    rowData = [];
  end
end

% --- Handle 1-D table cases by clearing out the singleton dimension

if expNumDims == 1
  if length(rowData) == 1 || isempty(rowData),
    rowData = [];
  elseif length(colData) == 1 || isempty(colData),
    colData = [];
  else
    warning('Table editor internal error cleaning up breakpoints for 1-D table');
  end
  if transposeFlag
    brkPtsData2D = {colData, rowData};
    return;
  end
end

% --- Pack up results in expected format

brkPtsData2D = {rowData, colData};
    
% end get2DFromND


% Function: createBlkListTableData =============================================
% Abstract:
%   Create lookup table block list table model from a Java Hashtable object.
%
function data = createBlkListTableData(list)

data = {};
keys = list.keys;

% sort the key so that it will list the block in a sorted way.
key = {keys.nextElement};
while keys.hasMoreElements
  key = [key; {keys.nextElement}];
end
key = sort(key);

for i=1:length(key)
  % arbitrary index, no actual meaning, can be removed
  data{i, 1} = num2str(i);
  
  % get the BlockType and MaskType string
  [blkType, maskType] = strtok(key{i}, '///');
  maskType = strtok(maskType, '///');
  
  data{i, 2} = blkType;
  data{i, 3} = maskType;
  
  hashValue = list.get(key{i});
  
  % Break-points name
  data{i, 4} = javaObj2Char(hashValue(1));
  
  % table name
  data{i, 5} = javaObj2Char(hashValue(end));

  % number of dimesnions
  data{i, 6} = char(hashValue(2));
  
  % explicit number of dimesnions
  data{i, 7} = char(hashValue(3));
end

% end createBlkListTableData


% Function: createFigureTitle ==================================================
% Abstract:
%   Create this dialog's figure title. The default is 'Lookup Table Editor'. 
%   If a lookup table block is selected, put its name with full path
%   on the title.
%
function titleStr = createFigureTitle( blkStr )

if ~isempty(blkStr)
  blkStr = regexprep(blkStr, '//', '/');
end
titleStr = 'Lookup Table Editor: ';
titleStr = [titleStr blkStr];

% end createFigureTitle


% Function: doAddPref ==========================================================
% Abstract:
%   Command line interface that allows user to add a single entry from
%   LUT Blocks Type Configuration list.
%
function doAddPref(appdata, args)

if ispref('sltbledit','blockconfiglist') == 1
  pref = getpref('sltbledit','blockconfiglist');
  if ~isempty(args)
    key   = args{1};
    value = args{2};
    
    [lastmsg, lastid] = lasterr;
    try
      pref.put(key, value);
      setpref('sltbledit','blockconfiglist', pref);
      disp('Lookup Table Blocks Type Configuration has been updated.'); 
      disp('Please exit current MATLAB session to make change effective.');
    catch
      disp(['Error occurred when adding preference on Lookup Table ' ...
            'Blocks Type Configuration.']);
      disp('Please check the entry format.');
      lasterr(lastmsg, lastid);
    end
    appdata.SupportedTblBlks = pref;
    setappdata(0, 'SLLookupTableEditor', appdata);
  end
else
  disp(['You don''t have Lookup Table Blocks Type Configuration '...
        'preference set up.']);
  disp(['To have it initialized, please open Lookup Table Editor ', ...
        'to do it. Adding preference ignored.']);
end

% end doAddPref
  

% Function: doClose ============================================================
% Abstract:
%   Action responding to Close button clicked, it will "turn" dialog invisible.
%
function doClose(closeSrcObj, evd)

appdata  = getappdata(0, 'SLLookupTableEditor');
FigFrame = appdata.SwingWidgets.FigFrame;

goto = appdata.SwingWidgets.FigFrame.close;

if appdata.Flags.dirtyFlag == 1
  if appdata.SwingWidgets.FigFrame.isTestMode
    goto = 1;
  else
    goto = com.mathworks.mwswing.MJOptionPane.showConfirmDialog(...
        FigFrame, sprintf(['Table data and/or breakpoint data have changed. \n' ...
                        'Do you want to update the block data?']), ...
        sprintf('Lookup Table Editor Warning'),...
        com.mathworks.mwswing.MJOptionPane.YES_NO_CANCEL_OPTION, ...
        com.mathworks.mwswing.MJOptionPane.QUESTION_MESSAGE)+1;
  end
end

if goto == 3
  % no-op
else
  [lastmsg, lastid] = lasterr;
  try
    if ~isempty(appdata.SelectedBlk) && ...
          ishandle(get_param(appdata.SelectedBlk, 'Handle'))
      if goto == 1    % save all data
        doSendData(appdata.SwingWidgets.UpdateMenu, []);
      end
  
      % turn off the hilited block
      set_param(appdata.SelectedBlk, 'HiliteAncestors', 'off');
    end
  catch
    lasterr(lastmsg, lastid);
  end
  appdata.SelectedBlk = {};
  
  if ishandle(FigFrame)
    FigFrame.setVisible(0);
    drawnow;
    if FigFrame.isLUTDesignerDialogShown
      FigFrame.getDesignerDialog.dispose;
    end
  end
  
  if ~isempty(appdata.Plot.PlotFig) && ishandle(appdata.Plot.PlotFig)
    delete(appdata.Plot.PlotFig);
  end
  
  % clean up the appdata in ML session
  setappdata(0, 'SLLookupTableEditor', '');
  rmappdata(0, 'SLLookupTableEditor');
end

% end doClose


% Function: doDemos ============================================================
% Abstract:
%   Open MATLAB DEMOS.
%
function doDemos(menuDemo, evd)

demo('simulink');

% end doDemos


% Function: doFileOpenMouseClicked =============================================
% Abstract:
%   Open user selected Simulink model, or other files.
% 
function doFileOpenMouseClicked(FileOpenButton, evd)

[filename, pathname] = uigetfile('*.mdl', 'Select a model to open');

if ~isequal(filename, 0) && ~isequal(pathname, 0)
  eval(['open_system(''' pathname filename ''')']);
end

appdata = getappdata(0, 'SLLookupTableEditor');
updateCurrentSelectedMdl(appdata, gcs);

% end doFileOpenMouseClicked


% Function: doGotoBlock =============================================
% Abstract:
%   Open user selected Simulink model, or other files.
% 
function doGotoBlock(menuItem, evd)

appdata = getappdata(0, 'SLLookupTableEditor');

if ~isempty(appdata.SelectedBlk)
  open_system(appdata.SelectedBlk);
end

% end doGotoBlock


% Function: doLUTHelp ==========================================================
% Abstract:
%   Open helpdesk on lookup table editor page.
%
function doLUTHelp(LUTHelpMenu, evd)

[lastmsg, lastid] = lasterr;
try
  helpview([docroot, '/mapfiles/simulink.map'], ...
           'lookuptableeditor');
catch
  disp(sprintf('Error loading help for Lookup Table Editor.'));
  lasterr(lastmsg, lastid);
end

% end doLUTHelp


% Function: doLoadData =========================================================
% Abstract:
%   Reload block parameter data into current displaying field.
%
function doLoadData(ReloadMenu, evd)

appdata = getappdata(0, 'SLLookupTableEditor');

if isempty(appdata)
  return;
end
if ishandle(get_param(appdata.SelectedBlk, 'Handle'))
  doUpdateTableData(appdata.SelectedBlk);
end

% end doLoadData


% Function: doPrint ============================================================
% Abstract:
%   Print selected lookup table parameter data
%
function doPrint(PrintMenu, evd)

appdata = getappdata(0, 'SLLookupTableEditor');

if isempty(appdata)
  return;
end

blkHdl = get_param(appdata.SelectedBlk, 'Handle');
if ishandle(blkHdl)
  oldGCS = get_param(0, 'CurrentSystem');
  oldGCB = get_param(gcs, 'CurrentBlock');
  
  try
    blkFullName = getfullname(blkHdl);
    idx = findstr(blkFullName, get_param(blkHdl, 'Name'));
    sys = blkFullName(1:idx(length(idx))-2);
    
    set_param(0, 'CurrentSystem', sys);
    set_param(gcs, 'CurrentBlock', get_param(blkHdl,'Name'));
    rptgen.report([matlabroot filesep 'toolbox' filesep 'simulink' ...
                   filesep 'blocks' filesep 'private' filesep 'lookuptable.tmp']);
  catch
    
  end
  set_param(0, 'CurrentSystem', oldGCS);
  set_param(gcs, 'CurrentBlock', oldGCB);
end

% end doPrint


% Function: doMdlListActionPerformed ===========================================
% Abstract:
%   This function will be called when there is an action on "Model:" list
%   combobox performed. For example, switching from one model to another, some
%   models are added on or closed in simulink. They will all trigger this
%   function callback. This function will be responsible for refreshing the
%   tree viewer. 
%
function appdata = doMdlListActionPerformed(varargin)

if nargin > 2
  appdata = varargin{3};
else
  appdata = getappdata(0, 'SLLookupTableEditor');
end
if isempty(appdata)
  return;
end

% set mouse cursor and status label to indicate the dialog is loading table
% blocks tree viewer 
defaultCursor = java.awt.Cursor.getDefaultCursor;
appdata.SwingWidgets.FigFrame.setCursor(java.awt.Cursor.WAIT_CURSOR);

BlocksTree = appdata.SwingWidgets.BlocksTree;

% find the lookup table blocks in this model
mdlName = appdata.SwingWidgets.ModelsPopup.getSelectedItem;
blks    = findLookupBlocks(mdlName);

% when models list or blocks list in the selected model has changed, update
% blocks tree viewer immediately
if ~ishandle(appdata.SelectedMdl)
  appdata.SelectedMdl = {};
  updateTree = 1;
else 
  if ~isequal(get_param(appdata.SelectedMdl, 'Name'), mdlName) || ...
	~isequal(appdata.BlksInMdl, blks)
    updateTree = 1;
  else
    updateTree = 0;
  end
end

if updateTree
  % create the tree structure for MJTree to use
  mdlRoot = setjavaxtreenode(mdlName, blks);
  
  BlocksTree.setLUTTreeModel(mdlRoot);

  % make the first available block to be the default selection
  if BlocksTree.getRowCount > 0 
    if isempty(appdata.SelectedBlk)
      BlocksTree.setSelectionRow(0);
      drawnow;
      rowStr = strrep(char(BlocksTree.getPathForRow(0).toString), '/', '//');
      rowStr = strrep(rowStr, ', ', '/');
      appdata.SelectedBlk = rowStr(2:end-1);
    else
      for i=0:BlocksTree.getRowCount-1
        rowStr = strrep(char(BlocksTree.getPathForRow(i).toString), '/', '//');
        rowStr = strrep(rowStr, ', ', '/');
        if strcmp(rowStr(2:end-1), appdata.SelectedBlk)
          BlocksTree.setSelectionRow(i);
          break;
        end
      end
    end
  end
  appdata.BlksInMdl = blks;
end

try
  appdata.SelectedMdl = get_param(mdlName, 'Handle');
catch
  appdata.SelectedMdl = {};
end
appdata.SwingWidgets.FigFrame.setCursor(defaultCursor);

if nargout > 0
  return;
else
  setappdata(0, 'SLLookupTableEditor', appdata);
end

% end doMdlListActionPerformed


% Function: doMesh =============================================================
% Abstract:
%   Mesh plot for table data.
%
function doMesh(LinearPlotMenu, evd)

doPlot('mesh', []);

% end doMesh


% Function: doPlot =============================================================
% Abstract:
%   Linear data plot on 2-D figure.
%
function doPlot(LinearPlotMenu, evd)

doMeshFlag = 0;
if ischar(LinearPlotMenu)
  if isempty(evd) && strcmp(LinearPlotMenu, 'mesh')
    doMeshFlag = 1;
  end
end
appdata = getappdata(0, 'SLLookupTableEditor');

if isempty(appdata)
  return;
end

selectedBlk = appdata.SelectedBlk;
DataTable   = appdata.SwingWidgets.DataTable;
fig         = [];

try
  %get data directly from the DataTable widget
  data = getTableDataFromDataTable(DataTable, 0);
  data = ['reshape(', data, ',', num2str(DataTable.getRowCount-1), ',', ...
          num2str(DataTable.getColumnCount-2),')'];
  data = eval(data);
  
  % process break-points data
  brkPtsData = getBreakPointsDataFromDataTable(DataTable);
  xAxisData = str2num(brkPtsData{1,:});
  yAxisData = str2num(brkPtsData{2,:});
  labelData = {};
  for i = 2:DataTable.getColumnCount-1
    labelData = [labelData, ...
                 {['\leftarrow' DataTable.getModel.getValueAt(0, i)]}];
  end

  if ~isempty(appdata.Plot.PlotFig) && ishandle(appdata.Plot.PlotFig)
    fig = appdata.Plot.PlotFig;
    set(fig, 'HandleVisibility', 'on', ...
             'Name', sprintf(['Data for block: ' selectedBlk]));
    delete(get(fig,'Child'));
  else
    fig = figure('Visible',      'off', ...
                 'NextPlot',     'ReplaceChildren', ...
                 'NumberTitle',  'off', ...
                 'DoubleBuffer', 'on', ...
                 'Name',         ...
                 sprintf(['Data for block: ' selectedBlk]));
  end
  hold on; 
  
  if isempty(data)
    disp(sprintf('Lookup Table Editor: No table data for this block.\n'));
    return;
  end
  
  if doMeshFlag
    appdata.Plot.PlotType = 2;
  else
    appdata.Plot.PlotType = 1;
  end
  if length(selectedBlk) > 50
    selectedBlk = [selectedBlk(1:floor(length(selectedBlk)/2)) '\n' ...
                   selectedBlk(floor(length(selectedBlk)/2)+1:end)];
  end
  if ~isempty(xAxisData)
    if ~isempty(yAxisData) && doMeshFlag
      appdata.Plot.PlotType = 2;
      view(3);
      plotAxes = mesh(xAxisData, yAxisData, data', 'Tag','LUTData');
      ylabel('Column breakpoints');
      zlabel('Table data');
      text(repmat(xAxisData(end), 1,DataTable.getColumnCount-2), ...
           yAxisData, data(end, :), labelData, 'Tag', 'LUTLabel');
      xtick = get(get(fig, 'Child'), 'XTick');
      ytick = get(get(fig, 'Child'), 'YTick');
      ztick = get(get(fig, 'Child'), 'ZTick');
      text(xtick(end)+abs((xtick(end)-xtick(1))/10), ...
           ytick(1)-abs((ytick(end)-ytick(1))/10), ztick(1), ...
           'Annotations denote column breakpoints', 'Rotation', 90);
    else
      
      plotAxes = plot(xAxisData, data, 'Tag','LUTData');
      ylabel('Table data');
            xtick = get(get(fig, 'Child'), 'XTick');
      ytick = get(get(fig, 'Child'), 'YTick');

      text(xtick(end)+abs((xtick(end)-xtick(1))/10), ...
          ytick(1)+abs(ytick(end)-ytick(1))/4, ...
          'Annotations denote column breakpoints','Rotation', 90);
      text(repmat(xAxisData(end),1,DataTable.getColumnCount-2), ...
           data(end, :), labelData, 'Tag', 'LUTLabel');
    end
    xlabel('Row breakpoints');

    title(sprintf(['Table and breakpoints data for block:\n' selectedBlk]), ...
          'Interpreter', 'None');
  else
    % table data only, simple plot
    plotAxes = plot(data, 'Tag','LUTData');
    xlabel('Row index');
    ylabel('Column index');
    title(sprintf(['Table data for block:\n' selectedBlk]), ...
          'Interpreter', 'None');
  end

  % turn the grid on
  set(get(plotAxes(end), 'Parent'), 'XGrid', 'on', 'YGrid', 'on');
  
  if ~doMeshFlag
    set(fig, ...
        'WindowButtonDown', ...
        {@EditingDataFromPlotButtonDown, DataTable, []}, ...
        'WindowButtonUp',   {@EditingDataFromPlotButtonUp, DataTable});
    %set(get(plotAxes(end), 'Parent'), 'ZGrid', 'on');
    
    % Create datatip
    hDataTip = graphics.datatip(plotAxes(end), 'StringFcn', @localStringFcn);
    set(hDataTip, 'OrientationMode', 'Auto');
    for i=1:length(plotAxes)
      set(plotAxes(i), 'ButtonDownFcn', {@localUpdateDatatip, hDataTip});
    end
  end

  hold off;
  set(fig, 'HandleVisibility', 'off');
  if strcmp(get(fig, 'Visible'), 'off')
    set(fig, 'Visible', 'on');
  end
  
  DataTable.setUpdatePlot(1);
  appdata.Plot.PlotFig = fig;

  setappdata(0, 'SLLookupTableEditor', appdata);
  set(appdata.Plot.PlotFig, 'DeleteFcn', {@doPlotClose});
  
catch
  if ~isempty(fig) && ishandle(fig)
    delete(get(fig, 'Children'));
  end
  
  if appdata.SwingWidgets.FigFrame.isTestMode
    disp(lasterr);
  else
    com.mathworks.mwswing.MJOptionPane.showMessageDialog(...
        appdata.SwingWidgets.FigFrame, lasterr, ...
        sprintf('Lookup Table Editor Plot Error'),...
        com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
  end
end

% end doPlot


% Function: doPlotUpdate =======================================================
% Abstract:
%   Update plot data if the plot figure is ON.
%
function doPlotUpdate(varargin)

appdata = getappdata(0, 'SLLookupTableEditor');
DataTable = appdata.SwingWidgets.DataTable;

if ~isempty(appdata.Plot.PlotFig) && ishandle(appdata.Plot.PlotFig)
  %get data directly from the DataTable widget
  data = getTableDataFromDataTable(DataTable, 0);
  data = ['reshape(', data, ',', num2str(DataTable.getRowCount-1), ',', ...
          num2str(DataTable.getColumnCount-2),')'];
  data = eval(data);
  
  % process break-points data
  brkPtsData = getBreakPointsDataFromDataTable(DataTable);
  xAxisData = str2num(brkPtsData{1,:});
  yAxisData = str2num(brkPtsData{2,:});
  
  ax = get(appdata.Plot.PlotFig, 'Child');
  lbls = flipud(findobj(ax, 'Type', 'Text', 'Tag', 'LUTLabel'));
  
  % get all plot data from the axes
  lns = findobj(ax, 'Type', 'Line', 'Tag','LUTData');

  row = DataTable.getSelectedRow;
  col = DataTable.getSelectedColumn;
    
  if isempty(lns)   % mesh surface data
    meshHdl = findobj(ax, 'Type', 'Surface', 'Tag', 'LUTData');
    set(ax, 'XLimMode', 'Auto','YLimMode', 'Auto','ZLimMode', 'Auto');
    if col == 1
      % row breakpoint data changed
      set(meshHdl, 'XData', xAxisData);
    else
      if row == 0
        % column breakpoint data changed, update label
        set(meshHdl, 'YData', yAxisData);
      else
        % table data changed
        set(meshHdl, 'ZData', data');
      end

      % update label string
      set(lbls(col-1), ...
          'String',   ['\leftarrow' ...
                       DataTable.getValueAt(0, col)], ...
          'Position', [xAxisData(end), yAxisData(col-1), ...
                       data(DataTable.getRowCount-1, col-1)]);
    end
  else
    if row == 0
      % column breakpoint data changed, update label
      set(lbls(col-1),'String', ...
          ['\leftarrow' DataTable.getValueAt(row, col)]);
    elseif col == 1
      % row breakpoint data changed
      set(lns, 'xdata', xAxisData);
    else
      % table data changed
      set(lns(col-1), 'YData', data(:, col-1)', 'Marker', 'diamond');
      
      % label position need to be updated as well
      lbPos = get(lbls(col-1), 'Pos');
      lbPos(2) = data(end, col-1);
      set(lbls(col-1),'Pos', lbPos);
      
      % update datatip for the changing point
      bdf = get(lns(col-1), 'ButtonDownFcn');
      hDataTip = bdf{2};
      
      dataTipPos = get(hDataTip, 'Position');
      dataTipPos(1) = xAxisData(row);
      dataTipPos(2) = data(row, col-1);
      hDataTip.Host = lns(col-1);
      set(hDataTip, 'visible', 'on');
      set(hDataTip, 'position', dataTipPos);
      update(hDataTip);
    end
  end
end

% end doPlotUpdate


% Function: EditingDataFromPlotButtonUp ========================================
% Abstract:
%   This function is for resetting plot figure's windowbuttonmotion to be null.
%
function EditingDataFromPlotButtonUp(obj, evd, dt)

set(obj, 'WindowButtonMotion', '');
dt.setUpdatePlot(1);

% end EditingDataFromPlotButtonUp


% Function: EditingDataFromPlotButtonDown ======================================
% Abstract:
%   This function is for editing data from the plot figure.
%
function EditingDataFromPlotButtonDown(obj, evd, dt, selectedData)

% get the current axes
ax = get(obj, 'Child');

% get the current mouse pointer's location
z = get(ax,'currentpoint');
z = z(1,:);

lim = ones(3,length(get(ax, 'XLim')));
lim(1,:) = get(ax, 'XLim');
lim(2,:) = get(ax, 'YLim');
lim(3,:) = get(ax, 'ZLim');

if isempty(selectedData)
  if any(z(:)<lim(:,1)) || any(z(:)>lim(:,2))
    % the clicking point is out of the axes, no-op
    return;
  end
  
  % get all label data
  lbls = flipud(findobj(ax, 'Type', 'Text', 'Tag', 'LUTLabel'));
  
  % get all plot data from the axes
  lns = flipud(findobj(ax, 'Type', 'Line', 'Tag','LUTData'));
  
  % because all row axis (row breakpoints) are the same, we can just pick one
  xData = get(lns(1),'xdata');
  
  % get the closest for row index
  e = abs(xData - z(1));
  rowIdx = min(find(e == min(e)));
  
  % find out where the user is editing at, closest Y-data
  tDatas = get(lns,'ydata');
  if iscell(tDatas)
    yDiff = [];
    for j=1:length(tDatas)
      yDiff = [yDiff, abs(z(2)-tDatas{j}(rowIdx))];
    end
    colIdx = max(find(yDiff==min(yDiff)));
  else
    colIdx = 1;
  end
  ln = lns(colIdx);
  lb = lbls(colIdx);
  
  selectedData.ln = ln;
  selectedData.lb = lb;
  selectedData.rowIdx = rowIdx;
  selectedData.colIdx = colIdx;
else
  ln = selectedData.ln;
  lb = selectedData.lb;
  colIdx = selectedData.colIdx;
  rowIdx = selectedData.rowIdx;
end

tData = get(ln, 'ydata');

% update yData
tData(rowIdx) = z(2);
set(ln, 'ydata', tData, 'Marker', 'diamond');
% update label position
labelPos = get(lb, 'Position');
labelPos(2) = tData(end);
set(lb, 'Position', labelPos);

dt.setUpdatePlot(0);
if ~isempty(dt.getCellEditor)
  dt.getCellEditor.stopCellEditing;
  drawnow;
end
dt.changeSelectionFromMATLAB(rowIdx, colIdx+1, 0, 0);
dt.setValueAtFromMATLAB(num2str(tData(rowIdx)), rowIdx, colIdx+1);
set(obj, 'WindowButtonMotion', ...
         {@EditingDataFromPlotButtonDown, dt, selectedData});

% end EditingDataFromPlotButtonDown


%----------------------------------
function localUpdateDatatip(plotAxes, evd, hDatatip)

% Update position of the datatip
set(hDatatip,'Visible','on');
hDatatip.Host = plotAxes;
update(hDatatip);

% end localUpdateDatatip


%----------------------------------
function [str] = localStringFcn(hHost, hDataCursor)
% Format the datatip string to our liking

pos = hDataCursor.Position;
ind = hDataCursor.DataIndex;
xdata = get(hHost,'xdata');
ydata = get(hHost,'ydata');
if length(pos) == 2 || (length(pos) == 3 && pos(3) == 0)
  % 2-D plot
  pos(1) = xdata(ind);
  pos(2) = ydata(ind);
  
  str = {'', '', ''};
  str{1} = sprintf('Selecting table data at:');
  str{2} = sprintf('Row breakpoint: %s',num2str(pos(1)));
  str{3} = sprintf('Table data: %s',num2str(pos(2)));
else
  zdata = get(hHost,'zdata');
  [m n] = ind2sub(size(zdata),ind);

  pos = [xdata(n),ydata(m),zdata(m,n)];
  
  str{1} = sprintf('Selecting table data at:');
  str{2} = sprintf('Row breakpoint: %s',num2str(pos(1)));
  str{3} = sprintf('Column breakpoint: %s',num2str(pos(2)));
  str{4} = sprintf('Table data: %s',num2str(pos(3)));
end

% end localStringFcn


% Function: doPlotClose ========================================================
% Abstract:
%   Close plot figure.
%
function doPlotClose(fig, evd)

if ishandle(fig)
  delete(fig);
end
appdata = getappdata(0, 'SLLookupTableEditor');
if ~isempty(appdata)
  appdata.SwingWidgets.DataTable.setUpdatePlot(0);
  appdata.Plot.PlotFig  = [];
  appdata.Plot.PlotType = [];
  setappdata(0, 'SLLookupTableEditor', appdata);
end

% end doPlotClose


% Function: doRemovePref =======================================================
% Abstract:
%   Command line interface that allows user to remove any single entry from
%   LUT Blocks Type Configuration list.
%
function doRemovePref(appdata, args)

if ispref('sltbledit','blockconfiglist') == 1
  pref = getpref('sltbledit','blockconfiglist');
  if ~isempty(args)
    key   = args{1};
    [lastmsg, lastid] = lasterr;
    try
      pref.remove(key);
      setpref('sltbledit','blockconfiglist', pref);
      disp('Lookup Table Blocks Type Configuration has been updated.');
      disp('Please exit current MATLAB session to make change effective.');
    catch
      lasterr(lastmsg, lastid);
      disp(['Error occurred when removing preference from Lookup ' ...
           'Table Blocks Type Configuration.']);
      disp('Please check the entry format.');
    end
    appdata.SupportedTblBlks = pref;
    setappdata(0, 'SLLookupTableEditor', appdata);
  end
else
  disp(['You don''t have Lookup Table Blocks Type Configuration ' ...
        'preference set up.']);
  disp(['To have it initialized, please open Lookup Table Editor to do it. '...
        'Removing preference ignored.']);
end

% end doRemovePref


% Function: doSLHelp ===========================================================
% Abstract:
%   Open helpdesk on Simulink page.
%
function doSLHelp(menuSLHelp, evd);

slhelp;

% end doSLHelp


% Function: doSendData ========================================================
% Abstract:
%   Send all edited break-point data and table data into block's parameter
%   field. 
%
function doSendData(UpdateMenu, evd)

% update the table data
appdata     = getappdata(0, 'SLLookupTableEditor');
selectedBlk = appdata.SelectedBlk;
DataTable   = appdata.SwingWidgets.DataTable;		% data table handle
DimSelTable = appdata.SwingWidgets.DimSelTable;

transposeFlag = appdata.SwingWidgets.TransposeChx.isSelected;
saveStatus = 0;

try
  % get the break-point and table name for the selected block
  [nDims, hashValue] = getBlockInfo(selectedBlk);
  tblName = char(hashValue(end));
  brkPts  = char(hashValue(1));

  saveStatus = ...
      updateBlockParamData(appdata.SwingWidgets.FigFrame, ...
                           selectedBlk, DataTable, DimSelTable, ...
                           brkPts, tblName, nDims, transposeFlag);
catch
end

if saveStatus == 1
  appdata.Flags.dirtyFlag = 0;
  appdata.SwingWidgets.UpdateMenu.setEnabled(0);
end

setappdata(0, 'SLLookupTableEditor', appdata);

% end doSendData


% Function: doTablePropertyChange ==============================================
% Abstract:
%   Synchronize the table data and graphical plotting figure.
%
function doTablePropertyChange(DataTable, evd)

appdata = getappdata(0, 'SLLookupTableEditor');

appdata.Flags.dirtyFlag = 1;

setappdata(0, 'SLLookupTableEditor', appdata);

% end doTablePropertyChange


% Function: doDataCastTable ====================================================
% Abstract:
%   Casting the table data based on the data type selection
%
function appdata = doDataCastTable(varargin)

if nargin > 2
  appdata = varargin{3};
else
  appdata = getappdata(0, 'SLLookupTableEditor');
end
if isempty(appdata)
  return;
end

dataTable = appdata.SwingWidgets.DataTable;
dtPopup = appdata.SwingWidgets.FigFrame.getTableDTPopup;
dt = dtPopup.getSelectedItem;

rowStart = 1;
rowEnd = dataTable.getRowCount;
colStart = 2;
colEnd = dataTable.getColumnCount;

if dataTable.getColumnCount > 2 &&  dataTable.getRowCount > 1
  % table data is non-empty
  castData(dataTable, rowStart, rowEnd, colStart, colEnd, dt);
end

% end doDataCastTable


function castData(dataTable, rowStart, rowEnd, colStart, colEnd, dt)
  
if ~isempty(dataTable.getCellEditor)
  dataTable.getCellEditor.stopCellEditing;
  drawnow;
end

tableDataStr = '';
for i=colStart:colEnd-1
  for j=rowStart:rowEnd-1
    tableDataStr = [tableDataStr ' ' dataTable.getValueAt(j, i)];
  end
end

[lastmsg, lastid] = lasterr;
try
  tableData = eval([dt, '([' tableDataStr '])']);
catch
  lasterr(lastmsg, lastid);
  tableData = [];
end

idx = 1;
if ~isempty(tableData)
  for i = colStart:colEnd-1
    for j = rowStart:rowEnd-1
      dataTable.setValueAtFromMATLAB(tableData(idx), j, i);
      idx = idx+1;
    end
  end
end

% end castData


% Function: doDataCastRowBP ====================================================
% Abstract:
%   Casting the row breakpoint data based on the data type selection
%
function appdata = doDataCastRowBP(varargin)

if nargin > 2
  appdata = varargin{3};
else
  appdata = getappdata(0, 'SLLookupTableEditor');
end
if isempty(appdata)
  return;
end

dataTable = appdata.SwingWidgets.DataTable;
dtPopup = appdata.SwingWidgets.FigFrame.getRowBPDTPopup;
dt = dtPopup.getSelectedItem;

rowStart = 1;
rowEnd = dataTable.getRowCount;
colStart = 1;
colEnd = 2;

if dataTable.getColumnCount > 1 &&  dataTable.getRowCount > 1
  % table data is non-empty
  castData(dataTable, rowStart, rowEnd, colStart, colEnd, dt);
end

% end doDataCastRowBP


% Function: doDataCastColumnBP =================================================
% Abstract:
%   Casting the column breakpoint data based on the data type selection
%
function appdata = doDataCastColumnBP(varargin)

if nargin > 2
  appdata = varargin{3};
else
  appdata = getappdata(0, 'SLLookupTableEditor');
end
if isempty(appdata)
  return;
end

dataTable = appdata.SwingWidgets.DataTable;
dtPopup = appdata.SwingWidgets.FigFrame.getColBPDTPopup;
dt = dtPopup.getSelectedItem;

rowStart = 0;
rowEnd = 1;
colStart = 2;
colEnd = dataTable.getColumnCount;

if dataTable.getColumnCount > 2 &&  dataTable.getRowCount > 0
  % table data is non-empty
  castData(dataTable, rowStart, rowEnd, colStart, colEnd, dt);
end

% end doDataCastColumnBP


% Function: doTreeValueChanged =================================================
% Abstract:
%   Load and display the data from the selected table in tree viewer.
%   This function will be called when there is any change in table blocks tree
%   viewer (under the title "Table blocks:", including (but not limited to)
%   the change of selection, nodes, number of the nodes, etc. This function
%   will also call the function which will update the main data table.
%   
function doTreeValueChanged(varargin)

appdata   = getappdata(0, 'SLLookupTableEditor');
if isempty(appdata)
  return;
end

FigFrame      = appdata.SwingWidgets.FigFrame;
BlocksTree    = appdata.SwingWidgets.BlocksTree;

appdata.Flags.updateTable = 1;

% identify the selected item
selectedItem = BlocksTree.getSelectionPath;

if ~isempty(selectedItem)
  selectedPath = selectedItem.getPath;
  
  node = [];
  if length(selectedPath) > 0
    node = selectedPath( length(selectedPath) );
  end  
  
  blkStr = [];
  if ~isempty( node )
    if node.isLeaf
      blkStr = strrep(char(node.toString), '/', '//');
      % go through all the parents of the current leaf and create a
      % string to represent its path
      parent = node;
      for i = 1 : node.getLevel
	parent = parent.getParent;
	blkStr = [strrep(char(parent.toString), '/', '//') '/' blkStr];
      end
    end
  end
  
  % update the figure title to show the selected block's name with path
  FigFrame.setTitle(blkStr);
  
  % hilite_system on the current selection
  try
    DataTable    = appdata.SwingWidgets.DataTable;
    dtCellEditor = DataTable.getCellEditor;
    if ~isempty(dtCellEditor)
      if str2num(dtCellEditor.getComponent.getText) ...
	    ~= str2num(DataTable.getValueAt(DataTable.getSelectedRow, ...
					    DataTable.getSelectedColumn))
	appdata.Flags.dirtyFlag = 1;
      end
      FigFrame.stopTableCellEditing;
    end

    if appdata.Flags.dirtyFlag == 1
      if appdata.SwingWidgets.FigFrame.isTestMode
        goto = 1;
      else
        goto = com.mathworks.mwswing.MJOptionPane.showConfirmDialog(...
            FigFrame, sprintf(['Table data and/or breakpoint data have changed. \n' ...
                            'Do you want to update the block data?']), ...
            sprintf('Lookup Table Editor Warning'),...
            com.mathworks.mwswing.MJOptionPane.YES_NO_OPTION, ...
            com.mathworks.mwswing.MJOptionPane.QUESTION_MESSAGE)+1;
      end
    else
      goto = 0;
    end
    
    if goto == 1
      % save all data
      doSendData(appdata.SwingWidgets.UpdateMenu, []);
    elseif goto == 2
      %do nothing
    end
    
    if ~isempty(appdata.SelectedBlk)
      set_param(appdata.SelectedBlk, 'HiliteAncestors', 'off');
    end
    
    appdata.Flags.dirtyFlag = 0;
    appdata.SwingWidgets.UpdateMenu.setEnabled(0);
  catch
  end
  
  appdata.SelectedBlk = blkStr;
  if isempty(blkStr)
    appdata.SwingWidgets.FigFrame.setCurrentBlockHandle(-1);
  else
    appdata.SwingWidgets.FigFrame.setCurrentBlockHandle(get_param(blkStr, 'Handle'));
  end
  set_param(appdata.SelectedBlk, 'HiliteAncestors', 'find');
  
  appdata.SwingWidgets.DimSelTable.setLUTTableModel(com.mathworks.toolbox.simulink.lookuptable.LUTTableModel);
  appdata.SwingWidgets.DataTable.setLUTTableModel(com.mathworks.toolbox.simulink.lookuptable.LUTTableModel);
  setappdata(0, 'SLLookupTableEditor', appdata);
  appdata.SwingWidgets.TransposeChx.setSelected(0);
  
  % update the table content
  doUpdateTableData(appdata.SelectedBlk);

else
  % in this case, there is no block is selected.
  doUpdateTableData( selectedItem );
end

if isempty(appdata.SwingWidgets.ModelsPopup.getModel.getSelectedItem)
  % nothing left, close the dialog.
  doClose([], []);
else
  FigFrame.setVisible(1);
  drawnow;
end

setappdata(0, 'SLLookupTableEditor', appdata);

% end doTreeValueChanged


% Function: doUpdateTableData ==================================================
% Abstract:
%   Update the data in the table with the selected lookup table block.
% 
%   The way we do this is that we create a new DefaultTableModel for each new
%   or updated table block, the we set this tableModel to the JTable's Model
%   attribute.
%   Note: Some people said there might be some memory leak in Swing with
%   updating Table Model by doing JTable.setModel(newTableModel), not
%   confirmed yet.
%
function doUpdateTableData( selectedBlk )

appdata = getappdata(0, 'SLLookupTableEditor');
if isempty(appdata)
  return;
end

%selectedBlk = appdata.SelectedBlk;
if ~appdata.Flags.updateTable
  return;
end

FigFrame = appdata.SwingWidgets.FigFrame;
FigFrame.setCursor(java.awt.Cursor.WAIT_CURSOR);

DataTable   = appdata.SwingWidgets.DataTable;		% data table handle
DimSelTable = appdata.SwingWidgets.DimSelTable;

if isempty( selectedBlk )
  appdata.SwingWidgets.FigFrame.selectBlock([]);

  % update plot figure. in this case, close the figure
  if ~isempty(appdata.Plot.PlotFig) && ishandle(appdata.Plot.PlotFig)
    if strcmp(get(appdata.Plot.PlotFig, 'Visible'), 'on')
      set(appdata.Plot.PlotFig, 'Name', 'Plot window for Lookup Table Editor');
      delete(get(appdata.Plot.PlotFig, 'Children'));
    end
  end
  appdata.SelectedBlk = selectedBlk;
else
  try   
    % create dimension selector
    createDimSel(DimSelTable, selectedBlk);
    % update table
    doUpdateTableFromNDSelector([], [], selectedBlk);
  catch
    % exception happens, clean up the dialog
    DimSelTable.setLUTTableModel(com.mathworks.toolbox.simulink.lookuptable.LUTTableModel);
    DataTable.setLUTTableModel(com.mathworks.toolbox.simulink.lookuptable.LUTTableModel);
    appdata.SwingWidgets.DataTablePanel.setBorder('');
    drawnow;

    localException(lasterr);
  end
end

% newly loaded data, reset dirty flag
appdata.Flags.dirtyFlag = 0;
appdata.SwingWidgets.UpdateMenu.setEnabled(0);

% only enabled the plot/mesh menu while there is data in the table
appdata.SwingWidgets.FigFrame.updateToolbarStates(1);
drawnow;

% save appdata
setappdata(0, 'SLLookupTableEditor', appdata);

FigFrame.setCursor(java.awt.Cursor.DEFAULT_CURSOR);

% end doUpdateTableData


% Function: doUpdateTableFromNDSelector ========================================
% Abstract:
%   Set up the dimension index to display from n-D table data.
%   If n>2, 2 selected dimensions will be displayed in the data table.
%
function doUpdateTableFromNDSelector(varargin)
 
appdata = getappdata(0, 'SLLookupTableEditor');
if isempty(appdata)
  return;
end
localAssert(~isempty(appdata));

DimSelTable = varargin{1};
if nargin == 2
  % evd is not used in this function yet
  evd = varargin{2};
end
if nargin == 3
  selectedBlk = varargin{3};
else
  selectedBlk = appdata.SelectedBlk;
end

FigFrame    = appdata.SwingWidgets.FigFrame;
DataTable   = appdata.SwingWidgets.DataTable;
DimSelTable = appdata.SwingWidgets.DimSelTable;
dimSelModel = DimSelTable.getModel;
transSymbol = '';
indxStr = '';

if ~isempty(selectedBlk) && dimSelModel.getRowCount > 0
  % from the DimSel table, get the display format
  [indxStr, default2D, transSymbol] = ...
      viewingIndex(DimSelTable, appdata.SwingWidgets.TransposeChx.isSelected);

  modelType = 1;
  prelookup = [1 1];

  % create dimension selector's TableModel
  [brkPtsData2D, cellIndx, tblData2D, prelookup] = ...
      get2DFromND(selectedBlk, indxStr, default2D, ~isempty(transSymbol));
  
  dataType = class(brkPtsData2D{1});
  brkPtsData2D{1} = double(brkPtsData2D{1});
  if ~strcmp(dataType, FigFrame.getRowBPDTPopup.getSelectedItem)
    FigFrame.getRowBPDTPopup.setSelectedItem(dataType);
  end
  
  dataType = class(brkPtsData2D{2});
  brkPtsData2D{2} = double(brkPtsData2D{2});
  if ~strcmp(dataType, FigFrame.getColBPDTPopup.getSelectedItem)
    FigFrame.getColBPDTPopup.setSelectedItem(dataType);
  end
  
  dataType = class(tblData2D);
  tblData2D = double(tblData2D);
  if ~strcmp(dataType, FigFrame.getTableDTPopup.getSelectedItem)
    FigFrame.getTableDTPopup.setSelectedItem(dataType);
  end
  
  % create column data and headers
  [data, header, tableMode] = ...
      constructDataAndHeader(selectedBlk, brkPtsData2D, ...
                             cellIndx, tblData2D, ...
                             ~isempty(transSymbol));
  
  if isempty(data) && isempty(header)
    % no (table/brkpts) data in the block
    tableModel = com.mathworks.toolbox.simulink.lookuptable.LUTTableModel;
    tableMode = 0;
  else
    tableModel = com.mathworks.toolbox.simulink.lookuptable.LUTDefaultTableModel(data, header);
    tableModel.setModelMode(modelType);
    tableModel.setBreakPointEditable(prelookup(1), prelookup(2));
  end

  % set table model
  DataTable.setTableMode(tableMode);
  DataTable.setLUTTableModel(tableModel);
  DataTable.setBreakPointRenderer(prelookup(1), prelookup(2));
  drawnow;

end

setappdata(0, 'SLLookupTableEditor', appdata);

if ~isempty(transSymbol)
  indxStr = [indxStr transSymbol];
end
maskTypeStr = get_param(selectedBlk, 'MaskType');
if isempty(maskTypeStr)
  blkType = get_param(selectedBlk, 'BlockType');
  tableTitleStr = get_param(['built-in/' blkType], 'Name');
else
  tableTitleStr = [maskTypeStr ' (mask)'];
end
appdata.SwingWidgets.DataTablePanel.setBorder( ...
    sprintf([' Viewing "' tableTitleStr, ...
             '" block data [T' indxStr ']:']));

% this can be optional if user really wants
if ~isempty(appdata.Plot.PlotFig) && ishandle(appdata.Plot.PlotFig) ...
      && strcmp(get(appdata.Plot.PlotFig, 'Visible'), 'on')
  if appdata.Plot.PlotType == 2
    doPlot('mesh', []);
  else
    doPlot(appdata.SwingWidgets.LinearPlotMenu, []);
  end
end

setappdata(0, 'SLLookupTableEditor', appdata);

% end doUpdateTableFromNDSelector


% Function: doUpdateTranspose ==================================================
% Abstract:
%   Act when transpose checkbox is clicked
%
function doUpdateTranspose(obj, evd)
appdata = getappdata(0, 'SLLookupTableEditor');

doUpdateTableFromNDSelector([], [], appdata.SelectedBlk);

% end doUpdateTranspose


% Function: doUpdateBlksListPrefAppdata ========================================
% Abstract:
%   Set LUT Block Type Configurations list in pref data as well as appdata.
% 
function doUpdateBlksListPrefAppdata(obj, evd)

appdata = getappdata(0, 'SLLookupTableEditor');
FigFrame = appdata.SwingWidgets.FigFrame;

if FigFrame.isDefaultBlksListPrefUsed == 1
  if ispref('sltbledit','blockconfiglist') == 1
    rmpref('sltbledit','blockconfiglist');
  end
  appdata.SupportedTblBlks = defaultlutblklist;
else
  prefData = FigFrame.getBlksListPrefData;
  list = appdata.SupportedTblBlks;
  
  list.clear;
  for i=1:length(prefData)
    key = [char(prefData(i,2)), '///', char(prefData(i, 3))];
    val = {char2Cell(char(prefData(i,4))), ...
           {prefData(i,6)}, {prefData(i,7)}, {prefData(i,5)}};
    list.put(key,val);
  end
  
  % save all supported lookup table block into matlab pref MAT file
  [lastmsg, lastid] = lasterr;
  try
    appdata.SupportedTblBlks = list;
    setpref('sltbledit','blockconfiglist',list);
  catch
    lasterr(lastmsg, lastid);
    disp(lasterr);
  end
end
setappdata(0, 'SLLookupTableEditor', appdata);

% end doUpdateBlksListPrefAppdata


% Function: doWindowActivatedCallback ==========================================
% Abstract:
%   Refresh the model list combo box.
%
function doWindowActivatedCallback(FigFrame, evd)

appdata = getappdata(0, 'SLLookupTableEditor');
if isempty(appdata)
  return;
end

ModelList = appdata.ModelList;

if ishandle(appdata.SelectedMdl)
  SelectedMdl = get_param(appdata.SelectedMdl, 'Name');
else
  % handle destroyed
  SelectedMdl = {};
end

ModelsPopup = appdata.SwingWidgets.ModelsPopup;

% this popup menu has a selection in it, if the dialog is activated through a
% simulink model, we need to set that model as the newest selection.
prevItem = ModelsPopup.getSelectedItem;
if ~strcmp(prevItem, SelectedMdl)
  prevItem = SelectedMdl;
end

% load the list of opening system and compare it with cache info ModelList; if
% there is anything changed, update the combobox content.
currentOpenModels = findOpenedModels;
if ~isequal(ModelList, currentOpenModels) && ~isempty(currentOpenModels)
  % exclude closed models and remove them from the combobox
  [xorList, closedMdlIndx, newOpenedMdlIndx] = ...
	  setxor(ModelList, currentOpenModels);
  
  % remove closed models from the popup list
  remainMdls = intersect(ModelList, currentOpenModels);
  for i=1:length(closedMdlIndx)
    ModelsPopup.removeItem(ModelList{closedMdlIndx(i)});
  end

  % find newly opened models and add them into combobox
  [newOpenedMdl, indx] = setdiff(currentOpenModels, remainMdls);
  for i=1:length(indx)
    ModelsPopup.insertItemAt(newOpenedMdl{i}, indx(i)-1);
  end
  
  if isempty(prevItem)
    prevItem = char(newOpenedMdl(1));
  end
  
  % set the desired selection, keep the previous selection if the model is still
  % existing; otherwise, Java will set selection to be the first item.
  ModelsPopup.getModel.setSelectedItem(prevItem);
else
  if isempty(currentOpenModels)
    % nothing left, close the dialog.
    doClose([], []);
    return;
  else
    % set the desired selection, keep the previous selection if the model is still
    % existing; otherwise, Java will set selection to be the first item.
    ModelsPopup.getModel.setSelectedItem(prevItem);

    % the selection is still the same, check if the block is still there. 
    % If the SelectedBlk is still there, update the table data if needed; 
    % otherwise, select the first available block
    appdata = doMdlListActionPerformed([], [], appdata);
  end
end

appdata.ModelList = currentOpenModels;
appdata.SwingWidgets.ModelsPopup = ModelsPopup;

setappdata(0, 'SLLookupTableEditor', appdata);

% end doWindowActivatedCallback


% Function: doWindowIconifiedCallback ==========================================
% Abstract: 
%  After the window is "Iconified", call this function to turn off the hilited
%  block.
%
function doWindowIconifiedCallback(arg1, arg2)

appdata = getappdata(0, 'SLLookupTableEditor');

if isempty(appdata) || isempty(appdata.SelectedBlk)
  return;
end

[lastmsg, lastid] = lasterr;
try					% turn off the hilited block
  set_param(appdata.SelectedBlk, 'HiliteAncestors', 'off');
catch
  lasterr(lastmsg, lastid);
end

% end doWindowIconifiedCallback


% Function: executeAPICommand ==================================================
% Abstract:
%   The API for taking command line call. Mainly for testing purpose.
% 
function executeAPICommand(cmdStr, appdata, args)

switch cmdStr
 case 'update'
  doSendData(appdata.SwingWidgets.UpdateMenu, []);
 case 'reload'
  doLoadData(appdata.SwingWidgets.ReloadMenu, []);
 case 'close'
  doClose([], []);
 case 'plot'
  doPlot(appdata.SwingWidgets.LinearPlotMenu, []);
 case 'mesh'
  doPlot('mesh',[]);
 case 'addblklistpref'
  doAddPref(appdata, args);
 case 'removeblklistpref'
  doRemovePref(appdata, args);
 otherwise
  disp(sprintf('Command you entered ''%s'' is not supported.', cmdStr));
end

% end executeAPICommand


% Function: findLookupBlocks ===================================================
% Abstract:
%   Find all the lookup table blocks in the opened systems.
%
function tableBlocks = findLookupBlocks(model)

appdata = getappdata(0, 'SLLookupTableEditor');

% get supported blocks list hash table
list = appdata.SupportedTblBlks;

tableBlocks = [];
keys = list.keys;
while keys.hasMoreElements
  % browse each key of the hashtable
  key = keys.nextElement;
  
  % get the BlockType and MaskType string
  [blkType, maskType] = strtok(key, '///');
  maskType = strtok(maskType, '///');
  
  % find the matching blocks
  [lastmsg, lastid] = lasterr;
  try
    blks = find_system(model, ...
		       'FollowLinks',    'on', ...
		       'LookUnderMasks', 'all', ...
		       'BlockType',      blkType, ...
		       'MaskType',       maskType);
  catch
    lasterr(lastmsg, lastid);
    break;
  end
  
  % skip some lookup table blocks that under the masked subsystem
  if ~isempty(blks)
    for i = 1:length(blks)
      skipIt = 0;
      
      if strcmp(lower(get_param(get_param(blks(i), 'Parent'), 'Type')), 'block')
        parentMask = get_param(get_param(blks(i), 'Parent'), 'MaskType');
      else
        parentMask = {''};
      end
      
      switch lower(parentMask{:})
       case 'repeating table'
        % skip 1-D lookup table in repeating sequence block
        if strcmp(lower(get_param(blks(i), 'BlockType')), 'lookup')
          skipIt = 1;
        end
       otherwise
        % do nothing
      end

      if strcmp(lower(get_param(get_param(blks(i), 'Parent'), 'Type')), 'block')
        parentBlock = get_param(get_param(blks(i), 'Parent'), 'BlockType');
      else
        parentBlock = '';
      end
      % if its parent is one of the "defined" Lookup Table Block, skip it.
      anotherKeys = list.keys;
      while anotherKeys.hasMoreElements
        % browse each key of the hashtable
        anotherKey = anotherKeys.nextElement;
        
        % get the BlockType and MaskType string
        [anotherBlkType, anotherMaskType] = strtok(anotherKey, '///');
        anotherMaskType = strtok(anotherMaskType, '///');
        if strcmp(parentMask, ...
                  anotherMaskType) && strcmp(parentBlock, anotherBlkType)
          skipIt = 1;
          break;
        end
      end
      
      % add the satisfied search result into the output
      if skipIt == 0
        tableBlocks = [tableBlocks; blks(i)];
      end
    end
  end
end

tableBlocks = unique(tableBlocks);

% end findLookupBlocks


% Function: findOpenedModels ===================================================
% Abstract:
%   Find all opened Simulink models.
%
function model = findOpenedModels

model = sort( find_system('type',             'block_diagram', ...
			  'BlockDiagramType', 'model') );

% end findOpenedModels


% Function: getBlockInfo =======================================================
% Abstract:
%   Get the selected block's information including number of dimensions of the
%   table, hash value for the block tpye information.
%
function [nDims, hashValue] = getBlockInfo(selectedBlk)

appdata = getappdata(0, 'SLLookupTableEditor');
list    = appdata.SupportedTblBlks;

% get the selected block's blocktype and masktype to see if it matches
blkType = get_param(selectedBlk, 'BlockType');
mskType = get_param(selectedBlk, 'MaskType');

% get the break-point and table name for the selected block
blkKey    = [blkType, '///', mskType];
hashValue = list.get(blkKey);
numBrkPts = length(hashValue(1));
tblName   = char(hashValue(end));

if ~strcmp(blkKey, ['S-Function', '///', 'S-function: table3'])
  numDimPrmName = char(hashValue(2));
  expNumDimName = char(hashValue(3));  
  if ~isempty(numDimPrmName) && ~isempty(expNumDimName)
    if ~ischar(str2num(get_param(selectedBlk, numDimPrmName))) && ...
	  ~isempty(str2num(get_param(selectedBlk, numDimPrmName)))
      nDims = str2num(get_param(selectedBlk, numDimPrmName));
    else
      nDims = str2num(get_param(selectedBlk, expNumDimName));
    end
  else
    if ~isempty(tblName)
      tblData = getNumericalDataFromBlock(selectedBlk, sl('deblankall', tblName));

      nDims = ndims(tblData);
      if nDims == 2
	% the dimension of the block is depending upon the number of
        % break-point.
	nDims = numBrkPts;
      end
    else
      nDims = 0;
    end
  end
else
  nDims = 3;
end

% end getBlockInfo


% Function: getNumericalDataFromBlock ==========================================
% Abstract:
%   This function will get asked numerical data from a given block.
%
function data = getNumericalDataFromBlock(blk, dataName)

if isempty(dataName)
  data = [];
  return;
end
[lastmsg, lastid] = lasterr;
try
  try
    data = evalin('base', get_param(blk, sl('deblankall', dataName)));
  catch
    data = slResolve(get_param(blk, sl('deblankall', dataName)), blk);
  end
catch
  lasterr(lastmsg, lastid);
  data = {};
  infoTxt = ...
      sprintf(...
          ['\nWarning: Lookup Table Editor can not resolve parameter ' ...
           '''%s'' in block ''%s/%s''.\n', ...
           'To have them displayed correctly, use Update diagram from ' ...
           'Simulink Edit menu.\n'], ...
          get_param(blk, sl('deblankall', dataName)), ...
          get_param(blk, 'Parent'), ...
          get_param(blk, 'Name'));
  disp(infoTxt);
end
if isa(data, 'Simulink.Parameter')
  data = data.Value;
end
nonNumericalAssertion(data);
  
% end getNumericalDataFromBlock
  

% Function: getBreakPointsDataFromDataTable ========================================================
% Abstract:
%   Get the breakpoints data from 2-D table.
%
function brkPtsData = getBreakPointsDataFromDataTable(DataTable)

brkPtsData = {};
rowBrkPts  = [];
colBrkPts  = [];
try 
  if ~isempty(DataTable.getColumn('Breakpoints'))
    for i = 1:DataTable.getRowCount-1
      rowBrkPts = [rowBrkPts, ',', DataTable.getModel.getValueAt(i, 1)];
    end
    rowBrkPts = ['[' rowBrkPts(2:end) ']'];
    for i = 2:DataTable.getColumnCount-1
      colBrkPts = [colBrkPts, ',', DataTable.getModel.getValueAt(0, i)];
    end
    colBrkPts = ['[' colBrkPts(2:end) ']'];
    brkPtsData = {rowBrkPts; colBrkPts};
  end
catch
  return;
end

% end getBreakPointsDataFromDataTable


% Function: getTableDataFromDataTable(DataTable) ==========================================
% Abstract:
%   Get the table data from 2-D table.
%
function data = getTableDataFromDataTable(DataTable, transpose)

data = [];
try
  if ~isempty(DataTable.getColumn('Breakpoints'))
    if transpose == 1
      for j = 1:DataTable.getRowCount-1
        for i = 2:DataTable.getColumnCount-1
          data = [data, ',', DataTable.getModel.getValueAt(j, i)];
        end
      end
    else
      for i = 2:DataTable.getColumnCount-1
        for j = 1:DataTable.getRowCount-1
          data = [data, ',', DataTable.getModel.getValueAt(j, i)];
        end
      end
    end
    data = ['[', data(2:end), ']'];
  end
  return;
catch
  for i = 0:DataTable.getColumnCount-1
    for j = 0:DataTable.getRowCount-1
      data = [data, ',', DataTable.getModel.getValueAt(j, i)];
    end
  end
  data = ['[', data(2:end), ']'];
  return;
end

% end getTableDataFromDataTable


% Function: javaObj2Char =======================================================
% Abstract:
%   Convert a java vector to a single line matlab char array, elements are
%   separated by comma(,).
%
function charArray = javaObj2Char( obj )

charArray = [];
if ~isempty(obj)
  for i = 1:length(obj)
    if ~isempty(charArray)
      charArray = [charArray ',' char(obj(i))];
    else
      charArray = char(obj(i));
    end
  end
end

% end javaObj2Char


% Function: localAssert ========================================================
% Abstract:
%   Enforce that an assertion is true, throw an error if it is not.
%
function localAssert(assertion)
  
if ~assertion,
  error('Simulink:LUTEditor', ...
        'assertion failed in sltbledit.');
end
    
% end localAssert


% Function: localException =====================================================
% Abstract:
%   An unexpected error happened and the 'lasterr' is displayed on status view.
%
function localException(errMsg)

if ~isempty(errMsg)
  disp(errMsg);
  disp(sprintf(['Error occurs while retrieving data, check the selected ' ...
		'block''s parameter setting.']));
end
    
% end localException


% Function: nonNumericalAssertion ==============================================
% Abstract:
%   The input data is not numerical number nor could it be evaluated in
%   numerical format.
%
function nonNumericalAssertion(data)

assertion = 1;
if iscell(data)
  for i=1:length(data)
    if ~isnumeric(data{i})
      assertion = 0;
      break;
    end
  end
else
  if ~isnumeric(data)
    assertion = 0;
  end
end
if ~assertion
  error('LookupTableEditor:Error', ...
        'Assertion failed: data is not numeric array.');
end
return;
    
% end nonNumericalAssertion


% Function: saveVars ==========================================================
% Abstract:
%   Save data (breakpoints or table data) into block. If the previous block
%   parameter is a complex expression, use the numeric data to replace it.
%
function saveStatus = saveVars(blk, varStr, data, FigFrame, datatype)

saveStatus = 0;                         % updating failed
if isempty(str2num(get_param(blk, varStr))) && ...
      evalin('base',['exist(''' get_param(blk, varStr)  ''');']) == 1
  % parameter is a variable
  [lastmsg, lastid] = lasterr;
  try
    saveStatus = saveVarsInWs(blk, varStr, data, FigFrame, datatype);
  catch
    disp(lasterr);
    lasterr(lastmsg, lastid);
  end
else
  if isempty(str2num(get_param(blk, varStr)))
    if FigFrame.isTestMode
      saveStatus = 1;
    else
      saveStatus = com.mathworks.mwswing.MJOptionPane.showConfirmDialog(...
          FigFrame, ...
          sprintf(['Block parameter "%s" is an expression. ' ...
                   'Do you want it to be replaced by numeric data?'], ...
                  get_param(blk, varStr)), ...
          sprintf('Lookup Table Editor'),...
          com.mathworks.mwswing.MJOptionPane.YES_NO_OPTION, ...
          com.mathworks.mwswing.MJOptionPane.QUESTION_MESSAGE)+1;
    end
    
    if saveStatus == 2
      saveStatus = 0;
    end
  else
    % is numerical number
    saveStatus = 1;
  end
  
  if saveStatus > 0
    [lastmsg, lastid] = lasterr;
    % set its value while doing set_param for 
    try
      if ~strcmp(datatype, 'double')
        data = [datatype, '(', data, ');'];
      end
      
      if getfield(whos('data'), 'bytes') >= 64000
        com.mathworks.mwswing.MJOptionPane.showMessageDialog(...
            FigFrame, ...
            sprintf(['The size of the data you are trying to set in ' ...
                     'the block is larger than 64K bytes. This will ' ...
                     'result in the corruption of the model when you save ', ...
                     'it.\n', ...
                     'You may use variables for desired block parameters ', ...
                     'and save the variables in MAT file.']), ...
            sprintf('Lookup Table Editor Error'),...
            com.mathworks.mwswing.MJOptionPane.ERROR_MESSAGE);
        saveStatus = 0;
        return;
      else
        set_param(blk, varStr, data);
      end
      
    catch
      lasterr(lastmsg, lastid);
    end
  end
end
  
% end saveVars


% Function: saveVarsInWs ======================================================
% Abstract:
%   Overwrite workspace variable data. If the variable is Simulink data
%   object, i.e., Simulink.Parameter, save it in its Value field. Before
%   actually overwrite it, prompt user with a question dialog.
%
function saveStatus = saveVarsInWs(blk, varStr, data, FigFrame, datatype)

if evalin('base', ['isa(', get_param(blk, varStr), ...
		   ',''Simulink.Parameter'');'])
  assignStr = '.Value =';
else
  assignStr = '=';
end

if FigFrame.isTestMode
  saveStatus = 1;
else
  saveStatus = com.mathworks.mwswing.MJOptionPane.showConfirmDialog(...
      FigFrame, ...
      sprintf(['Workspace variable "%s" is not empty and could be used by multiple places.\n'...
               'Do you want to overwrite it?'], ...
              get_param(blk, varStr)), ...
      sprintf('Lookup Table Editor'),...
      com.mathworks.mwswing.MJOptionPane.YES_NO_OPTION, ...
      com.mathworks.mwswing.MJOptionPane.QUESTION_MESSAGE)+1;
end

switch saveStatus
 case 1
  % set its value
  if ~strcmp(datatype, 'double')
    data = [datatype, '(', data, ');'];
  end
  evalin('base', [get_param(blk, varStr), assignStr, data, ';']);
  saveStatus = 1;
 case 2
  saveStatus = 0;
end % switch

% end saveVarsInWs


% Function: updateCurrentSelectedMdl ===========================================
% Abstract:
%   Update the selected model to the current active one.
%
function updateCurrentSelectedMdl(appdata, srcBlk)

% refresh the current selected model list
if strcmp(get_param(bdroot(srcBlk),'BlockDiagramType'), 'model')
  appdata.SelectedMdl = get_param(bdroot(srcBlk), 'Handle');
  setappdata(0, 'SLLookupTableEditor', appdata);
end
FigFrame = appdata.SwingWidgets.FigFrame;
doWindowActivatedCallback(FigFrame, []);

% turn the figure visible
FigFrame.setVisible(1);
drawnow;

% end updateCurrentSelectedMdl


% Function: updateBlockParamData ===============================================
% Abstract:
%   This function will update selected block's breakpoint and table data.
%
function saveStatus = updateBlockParamData(FigFrame, selectedBlk, DataTable, ...
                                           DimSelTable, brkPts, ...
                                           tblName, nDims, transpose)

brkPtsData = getBreakPointsDataFromDataTable(DataTable);
tableData  = getTableDataFromDataTable(DataTable, transpose);  

viewIndx      = [];
transposeFlag = [];

brkPtsStr = [];
if nDims < 2
  brkPtsStr = brkPts;
  if transpose == 1
    brkPtsData = flipud(brkPtsData);
  end
elseif nDims == 2
  if ~isempty(brkPts)
    % check if the transpose flag is ON or OFF
    if transpose == 1
      brkPts = flipud(brkPts);
    end
    
    [lasterrmsg, lasterrid] = lasterr;
    try
      brkPtsStr = sl('deblankall', brkPts(1:2, :));
    catch
      lasterr(lasterrmsg, lasterrid);
    end
  end
else
  [viewIndx, default2D, transposeFlag] = viewingIndex(DimSelTable, transpose);
  dimStr = [];
  for i = 1:DimSelTable.getColumnCount-1
    dimStr = [dimStr, ',', DimSelTable.getValueAt(0, i)];
  end
  dimStr = dimStr(2:end);
  
  % check if the transpose flag is ON or OFF

  if ~isempty(transposeFlag)
    brkPtsData = flipud(brkPtsData);
  end
  
  % determine which two break-points variable should be updated
  try
    dims = [];
    for i=1:DimSelTable.getColumnCount-1
      if strcmp(DimSelTable.getModel.getValueAt(1, i), 'All')
	dims = [dims, i];
      end
    end
    
    [nBrkPtsPrm, nStr] = size(brkPts);
    brkPtsStr = [];
    numBrkPts = 0;
    for i = 1:nBrkPtsPrm
      brkPtData = evalin('base', ...
			 get_param(selectedBlk, sl('deblankall', brkPts(i, :))));
      if iscell(brkPtData)
	brkPtsSets = '{';
	for j = 1:length(brkPtData)
	  if ~isempty(find(dims==i+j-1))
	    % this dimension is edited
	    numBrkPts = numBrkPts + 1;
	    cellArr = brkPtsData{numBrkPts};
	  else
	    % use the existing break points data from the block
	    cellArr = ['[', num2str(brkPtData{j}, ' %0.5g'), ']'];
	  end
	  brkPtsSets = [brkPtsSets, cellArr];
	  if j ~= length(brkPtData)
	    brkPtsSets = [brkPtsSets, ','];
	  else
	    brkPtsSets = [brkPtsSets, '}'];
	  end
	end
	
	set_param(selectedBlk, sl('deblankall', brkPts(i, :)), brkPtsSets);
	
      else
	if ~isempty(find(dims==i))
	  brkPtsStr = [brkPtsStr; sl('deblankall', brkPts(i, :))];
	  numBrkPts = numBrkPts + 1;
	end
      end
      if numBrkPts == 2
	break;
      end
    end
    
  catch
    brkPtsStr = [];
  end
end
  
% update breakpoints data if the block has any
if ~isempty(brkPtsStr)
  if nDims == 0
    saveStatus = saveVars(selectedBlk, deblank(brkPtsStr), ...
                          deblank(brkPtsData{1}), FigFrame, 0);
  else
    [numBrkPts, l] = size(brkPtsStr);
    numBrkPts = min(nDims, numBrkPts);
    dataTypes = {FigFrame.getRowBPDTPopup.getSelectedItem; ...
                 FigFrame.getColBPDTPopup.getSelectedItem};
    for i=1:numBrkPts			% for both row & col breakpoints
      saveStatus = saveVars(selectedBlk, deblank(brkPtsStr(i, :)), ...
                            deblank(brkPtsData{i}), FigFrame, dataTypes{i, :});
    end
  end
end

if ~isempty(tblName)		% has table data
  tblData  = getNumericalDataFromBlock(selectedBlk, sl('deblankall', tblName));
  dataType = FigFrame.getTableDTPopup.getSelectedItem;

  if transpose == 0
    nr = DataTable.getRowCount-1;
    nc = DataTable.getColumnCount-2;
  else
    nc = DataTable.getRowCount-1;
    nr = DataTable.getColumnCount-2;
  end
  if nDims > 1
    tableData = ['reshape(',tableData, ',', ...
                 sprintf('%d', nr),',', sprintf('%d', nc),')'];
  end

  if ~isempty(viewIndx) % for N-D (N>2) blocks
    % convert 2-D table data from string format to to numerical format
    tableData = eval(tableData);
    
    % update the selected 2-D part of the n-D table data 
    eval(['tblData' viewIndx '= tableData;']);

    % now we have to store the n-D numerical data back to string format 
    % so that we can use it as the param value in set_param
    tableData = [];
    for i=1:length(tblData(:))
      tableData = [tableData, ',', sprintf('%0.5g', tblData(i))];
    end
    tableData = ['reshape([', tableData(2:end), '],', dimStr, ')'];
  end
  
  saveStatus = saveVars(selectedBlk, tblName, tableData, FigFrame, dataType);
end

% end updateBlockParamData
  

% Function: viewingIndex =======================================================
% Abstract:
%   Calculate the viewing index for n-D table data.
%
function [indxStr, default2D, transSymbol] = viewingIndex(DimSel, transpose)
    
if transpose == 1
  transSymbol = '''';
else
  transSymbol = '';
end

counter = 0;
default2D = [];
indxStr   = '';
if DimSel.getColumnCount > 1
  indxStr = [indxStr '('];
  for i=1:DimSel.getColumnCount-1
    if strcmp(char(DimSel.getValueAt(1, i)), 'All')
      counter = counter + 1;
      if counter > 2
        indxStr = [indxStr '1'];
      else
        default2D = [default2D, i];
        indxStr = [indxStr ':'];
      end
    else
      indxStr = [indxStr num2str(DimSel.getValueAt(1, i))];
    end
    if i ~= DimSel.getColumnCount-1
      indxStr = [indxStr ','];
    end
  end
  indxStr = [indxStr ')'];
end
if counter > 2
  warndlg(['Lookup Table Editor can only display two dimensional data ', ...
           'in its numerical data table. Please select at most two ' ...
           '"All"s from the dimension selector. Otherwise, only the ' ...
           'first two will be displayed.']);
end

% end viewingIndex


% Function: char2Cell ==========================================================
% Abstract:
%   Convert a char array to a cell array, excluding commas(,).
%
function cellArray = char2Cell( charArray )

cellArray = {};
if ~isempty(charArray)
  [e, charArray] = strtok(charArray, ',');
  while ~isempty(e)
    cellArray = [cellArray, {sl('deblankall', e)}];
    [e, charArray] = strtok(charArray, ',');
  end
end

% end char2Cell


% [EOF]
