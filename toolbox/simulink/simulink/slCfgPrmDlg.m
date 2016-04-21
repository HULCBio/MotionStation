function ret = slCfgPrmDlg(varargin)
% SLCFGPRMDLG -- API to interact with Simulink Configuration Parameters
% dialog.
% Input:
%    arg{1} -- model name
%    arg{2} -- action: {'Open', 'Close', 'TurnToPage', 'GetCurrentPage', 
%                       'Param2UI', 'UI2Param'}
%    arg{3} -- when action == 'TurnToPage', page name;
%
%              when action == 'Param2UI', parameter name
%
%              when action == 'UI2Param', UI specification; UI spcification 
%              can be a string of the UI prompt; it may also be a mxArray with
%              Prompt, Type, and Path information.  The more details you provide
%              the more likely we can find the right match.
% Output:
%    ret    -- when action == 'GetCurrentPage', current page name.
%
%              when action == 'Param2UI', MATLAB structure pointing to the UI item.
%              Fields in the structure: Prompt, Type, Path.
%
%              When action == 'UI2Param', return the parameter names that match 
%              UI items.
%
% Note:
%   The third argument used with 'TurnToPage' above should be the page name. If there
% are slash characters ('/') in the name, they need to be escaped with another slash. 
% For example, 'Data Import/Export' should be passed in as 'Data Import//Export'.
%  

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $
  
  ret = [];
  errmsg = '';
  
  if nargin < 2
    error('Missing input arguments');
  end

  % Validate the first input
  model = varargin{1};
  if ishandle(model)
    sysFound = ~isempty(find_system('type', 'block_diagram', 'handle', model));
  elseif ischar(model)
    sysFound = ~isempty(find_system('type', 'block_diagram', 'name', model));
  else
    sysFound = false;
  end
  if ~sysFound
    if ishandle(model)
      error(['There is no model with handle ' num2str(model)]);
    elseif ischar(model)
      error(['Model "' model '" is not found']);
    else
      error('First input argument must be a valid model name or handle');
    end
  end
  
  % Validate the second input
  action = varargin{2};
  if isempty(action) || ~ischar(action)
    error('Second input argument must be a valid action string');
  end
  
  switch action
   case 'Open'
    set_param(model, 'SimulationCommand', 'SimParamDialog');
    
   case 'Close'
    hDlg = get_param(model, 'SimPrmDialog');
    if ~isempty(hDlg) && isa(hDlg, 'DAStudio.Dialog')
      delete(hDlg);
    end
    
   case 'TurnToPage'
    if nargin < 3
      error('"TurnToPage" action requires a third input argument specifying page name');
    end

    hDlg = get_param(model, 'SimPrmDialog');
    if isempty(hDlg) || ~isa(hDlg, 'DAStudio.Dialog')
      hCS = getActiveConfigSet(model);
    else
      hCS = hDlg.getDialogSource;
    end

    % Validate page name
    page = varargin{3};
    if isempty(page) || ~ischar(page)
      error('Page name must be a string');
    end
    
    s = hCS.getDialogSchema('simprm');
    found = loc_findPage(s.Items{2}.TreeItems, '', ['/' page]);
    if found
      hCS.CurrentDlgPage = page;
    else
      [found, path] = loc_findSimilarPage(s.Items{2}.TreeItems, page);
      if found
        hCS.CurrentDlgPage = path;
      else
        error(['Page "' page '" is not a valid page.']);
      end
    end

   case 'GetCurrentPage'
    hDlg = get_param(model, 'SimPrmDialog');
    if isempty(hDlg) || ~isa(hDlg, 'DAStudio.Dialog')
      hCS = getActiveConfigSet(model);
    else
      hCS = hDlg.getDialogSource;
    end
    ret = hCS.CurrentDlgPage;
    
   case 'Param2UI'
    if nargin < 3
      error('"Param2UI" action requires a third input argument specifying interested parameter');
    end
    
    % Dialog must be open
    hDlg = get_param(model, 'SimPrmDialog');
    if isempty(hDlg) || ~isa(hDlg, 'DAStudio.Dialog')
      hDlg = [];
      hCache = getActiveConfigSet(model);
    else
      hCache = hDlg.getDialogSource;
    end
    
    % Validate parameter name
    paramName = varargin{3};
    if isempty(paramName) || ~ischar(paramName)
      error('Parameter name must be a string');
    end    
    if ~hCache.hasProp(paramName)
      error(['Invalid parameter name "' paramName '"']);
    end
    
    uiItem = slprivate('slCSProp2UI', hCache, hDlg, paramName);
    ret.Prompt = uiItem.Prompt;
    ret.Type  = uiItem.Type;
    if ~isempty(uiItem.Path)
      ret.Path  = uiItem.Path(2:end);
    end
    ret.Visible = uiItem.Visible;
    
   case 'UI2Param'
    if nargin < 3
      error('"UI2Param" action requires a third input argument specifying the UI item');
    end
    
    % Dialog must be open
    hDlg = get_param(model, 'SimPrmDialog');
    if isempty(hDlg) || ~isa(hDlg, 'DAStudio.Dialog')
      hDlg = [];
      hCache = getActiveConfigSet(model);
    else
      hCache = hDlg.getDialogSource;
    end
    
    % Validate UI specification
    arg3 = varargin{3};
    if (~ischar(arg3) && ~isstruct(arg3)) || ...
          (isstruct(arg3) && (~isfield(arg3, 'Prompt') || ...
                              ~isfield(arg3, 'Type')   || ...
                              ~isfield(arg3, 'Path')))
      error('Incorrect UI description');
    end
    
    if ischar(arg3)
      uiItem.Prompt = arg3;
      uiItem.Path = '';
      uiItem.Type = 'any';
    else
      uiItem = arg3;
    end
    
    ret = slprivate('slCSUI2Prop', hCache, uiItem);
    ret = ret';
    
   otherwise
    error('Unsupported action');
  end
  
function [found] = loc_findPage(books, path, page)
  found = false;
  
  for i = 1:length(books)
    if ischar(books{i})
      item = loc_escapeSlashInTreeItem(books{i});
      if strcmp([path '/' item], page)
        found = true;
        return;
      end
    elseif iscell(books{i})
      prevItem = loc_escapeSlashInTreeItem(books{i-1});
      found = loc_findPage(books{i}, [path '/' prevItem], page);
      if found
        return;
      end
    end
  end
  
function [found, path] = loc_findSimilarPage(books, page)
  
  path = '';
  found = false;
  
  for i = 1:length(books)
    
    if ischar(books{i})
      item = loc_escapeSlashInTreeItem(books{i});
      if strcmp(item, page)
        found = true;
        path = page;
        return;
      end
    elseif iscell(books{i})
      [found, subPath] = loc_findSimilarPage(books{i}, page);
      if found
        prevItem = loc_escapeSlashInTreeItem(books{i-1});
        path = [prevItem '/' subPath];
        return;
      end
    end
  end
  
  
% Escape '/' in the item if needed
function escapedItem = loc_escapeSlashInTreeItem(item)
  
  escapedItem = item;
  
  if ~ischar(item)
    error('item must be a character string in loc_escapeSlashInTreeItem.');
  end
  
  if (any(strfind(item, '/')))
    escapedItem = strrep(item, '/', '//');
  end
  