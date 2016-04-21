function varargout = workspaceddg_cb(hDialog, action, hWS, newValue)
% WORKSPACEDDG_CB DataSource combobox callback from workspace dialog

% Copyright 2003-2004 The MathWorks, Inc.

  varargout = {};
  
  switch (action)
   case 'mapDataSourceToValue'
    if (nargin ~= 4), error('Invalid number of input arguments'); end;
    if (nargout~= 1), error('Invalid number of output arguments'); end;
    if (~isempty(hDialog)), error('hDialog should be empty'); end;
    varargout{1} = mapDataSourceToValue_l(hWS, newValue);
    
   case 'dataSource'
    if (nargin ~= 4), error('Invalid number of input arguments'); end;
    dataSource_l(hDialog, action, hWS, newValue);
    
   case 'import'
    if (nargin ~= 3), error('Invalid number of input arguments'); end;
    import_l(hDialog, hWS);
   
   case 'reload'
    if (nargin ~= 3), error('Invalid number of input arguments'); end;
    reload_l(hDialog, hWS);
    
   case 'export'
    if (nargin ~= 3), error('Invalid number of input arguments'); end;
    export_l(hDialog, hWS);
    
   case 'clear'
    if (nargin ~= 3), error('Invalid number of input arguments'); end;
    clear_l(hDialog, hWS);
    
   otherwise
    error(['Unexpected action: ', action]);
  end

%------------------------------------------------------------------------------
% SUBFUNCTIONS
%------------------------------------------------------------------------------
function value = mapDataSourceToValue_l(hWS, dataSource)
% MAPDATASOURCETOVALUE  Maps workspace data source to combobox value
  
  switch (dataSource)
   case 'MDL-File'
    value = 0;
   case 'MAT-File'
    value = 1;
   case 'M-Code'
    value = 2;
   otherwise
    error(['Unexpected data source: ', dataSource]);
  end
    
%------------------------------------------------------------------------------
function dataSource_l(hDialog, tag, hWS, newValue)
%DATASOURCE_L DataSource combobox callback from workspace dialog
  
  % If we are changing out of 'MDL-File' data source,
  % prompt the user to inform them that we are clearing the workspace.
  if ((strcmp(hWS.DataSource, 'MDL-File')) && (~isempty(hWS.whos)))
    question = sprintf(['The workspace is about to be cleared.\n', ...
                        'Do you want to continue?']);
    response = questdlg(question, 'Warning', 'Yes', 'No', 'Yes');
    
    switch response
     case 'No'
      % Reset dialog widget to old value (0 == MDL-File)
      hDialog.setWidgetValue(tag, mapDataSourceToValue_l(hWS, 'MDL-File'));
      return;
     case 'Yes'
      % No special action, just continue.
     otherwise
      error(['Unexpected response: ', response]);
    end
  end
  
  % Apply all changes before switching data source
  hDialog.apply;
  
  % Set the data source to the new value
  hWS.DataSource = newValue;
  
  % Must send a "readonly" change event to ensure Explorer is updated
  es = DAStudio.EventDispatcher;
  es.broadcastEvent('ReadonlyChangedEvent', hWS)
  
%------------------------------------------------------------------------------
function import_l(hDialog, hWS)
% IMPORT_L Import button callback from workspace dialog
  
  % Get the full path to the destination file
  [fileName, dirPath] = uigetfile('*.mat', 'Import From');
  
  if (fileName == 0) % Cancel
    return;
  end
  
  % Error out if the selected file is not a MAT-file
  if ~strcmp(fileName(end-3:end), '.mat')
    error(['The selected file is not a MAT-file: ', dirPath, fileName]);
  end
  
  % Apply changes in dialog
  hDialog.apply;
  
  % Save workspace
  hWS.evalin(['load ', dirPath, fileName]);
  
%------------------------------------------------------------------------------
function reload_l(hDialog, hWS)
% RELOAD_L Reload button callback from workspace dialog
  
  % Apply changes in dialog
  hDialog.apply;
  
  % Reload workspace data
  hWS.reload;

%------------------------------------------------------------------------------
function export_l(hDialog, hWS)
% EXPORT_L Export button callback from workspace dialog
  
  % Get the full path to the destination file
  [fileName, dirPath] = uiputfile('*.mat', 'Export To');
  
  if (fileName == 0) % Cancel
    return;
  end
  
  % Append '.mat' if not already done
  if ~strcmp(fileName(end-3:end), '.mat')
    fileName = [fileName, '.mat'];
  end
  
  % Apply changes in dialog
  hDialog.apply;
  
  % Save workspace
  hWS.save([dirPath, fileName]);

%------------------------------------------------------------------------------
function clear_l(hDialog, hWS)
% CLEAR_L Clear button callback from workspace dialog

  % Apply changes in dialog
  hDialog.apply;

  % Clear workspace data
  hWS.clear

%------------------------------------------------------------------------------
