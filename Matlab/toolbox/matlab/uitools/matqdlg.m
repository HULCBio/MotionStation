function y = matqdlg(P0,P1,V1,P2,V2,P3,V3,P4,V4,P5,V5,P6,V6,P7,V7,P8,V8,P9,V9)
%MATQDLG Obsolete function.
%   MATQDLG function is obsolete and may be removed from future versions.
%
%   See also SAVE, LOAD, PERSISTENT

warning('UITools:ObsoleteFunction:matqdlg', 'MATQDLG function is obsolete.');

%MATQDLG Workspace transfer dialog box.
%   MATQDLG('ws2buffer', {prop/value pairs})
%   Put up a dialog box that invites the user to enter a comma-separated
%   list of expressions.  When user clicks OK,  eval the expressions 
%   one at a time, putting the results into the buffer.  Allowable
%   properties include 'PromptString', which may be a string matrix,
%   'OKCallback', which will be eval'ed when the user finishes
%   with the dialog box by typing <Return> in the entry field or 
%   clicking OK, 'CancelCallback', which will be eval'ed when the user 
%   clicks Cancel, and 'EntryString', the default user entry.  
%   Figure properties are also allowed in this list, such as 'Name'.
%
%   MATQDLG('buffer2ws', {prop/value pairs})
%   Put up a dialog box that invites the user to enter N comma-separated
%   variable names, where N is the number of items in the buffer.  Get
%   items out of the buffer one at a time, storing the results in
%   indicated workspace variables.  Allowable properties include 
%   'PromptString', 'OKCallback', 'CancelCallback', and 'EntryString'.
%   These work the same way as in the 'ws2buffer' action.
%
%   Y = MATQDLG('get_entry');
%   Return the user-entered string in the entry field of the workspace
%   transfer dialog box.
%
%   H = MATQDLG('find')
%   Return the handle of the dialog box figure.
%
%   H = MATQDLG('create')
%   Create the dialog box figure, returning its handle.
%
%   This function is OBSOLETE and may be removed in future versions.

%   Steven L. Eddins 1-14-94
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.16.4.1 $  $Date: 2002/10/24 02:13:34 $

% M-files required:  matqparse.m, ws2matq.m, matq2ws.m.

buffer_tag = 'Workspace Transfer';
buffer_name = '';

if (nargin < 1)
  action = 'create';
else
  action = lower(P0);
end

if (strcmp(action, 'create'))
  
  %==================================================================
  % Create a new queue.
  %
  % matqdlg('create');
  %==================================================================

  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  buffer_fig = matqdlg('find');
  if (buffer_fig ~= 0) 
    % Queue already exists; do nothing
    return;
  end
  
  screenSize = get(0,'ScreenSize');
  width = 415;
  height = 136;
  left = (screenSize(3) - width) / 2;
  bottom = (screenSize(4) - height) / 2;

  buffer_fig = figure('Name', buffer_name, 'Visible', 'off',...
      'HandleVisibility', 'callback', ...
      'IntegerHandle', 'off', ...
      'Units', 'pixels', ...
      'Position', [left bottom width height], ...
      'Colormap', [], ...
      'MenuBar', 'none', ...
      'Color', get(0, 'DefaultUIControlBackgroundColor'), ...
      'DefaultUIControlInterruptible','on', ...
      'Tag', buffer_tag, ...
      'NumberTitle', 'off');
  
  axes('Visible', 'off', 'Parent', buffer_fig);
  
  cancel = uicontrol(buffer_fig, ...
      'Style', 'push', ...
      'Units', 'normalized', ...
      'Position', [.05 .06 .15 .24], ...
      'Tag', 'Cancel', ...
      'String', 'Cancel');
  
  ok = uicontrol(buffer_fig, ...
      'Style', 'push', ...
      'Units', 'normalized', ...
      'Position', [.80 .06 .15 .24], ...
      'Tag', 'OK', ...
      'String', 'OK');
  
  prompt = uicontrol(buffer_fig, ...
      'Style', 'edit', ...
      'Units', 'normalized', ...
      'Position', [.05 .76 .90 .15], ...
      'String', '', ...
      'Min', 1, ...
      'Max', 3, ...
      'Tag', 'Prompt', ...
      'Horizontal', 'left');

  entry = uicontrol(buffer_fig, ...
      'Style', 'edit', ...
      'Units', 'normalized', ...
      'Position', [.05 .46 .90 .31], ...
      'BackgroundColor', 'w', ...
      'ForegroundColor', 'k', ...
      'Tag', 'Entry', ...
      'Horizontal', 'left');
  
  y = buffer_fig;

  return;
  
elseif (strcmp(action, 'find'))
  
  %==================================================================
  % Find the queue figure.  If no queue figure exists, return 0.
  %
  % matqdlg('find');
  %==================================================================
  
  error(nargchk(1,1,nargin));
  error(nargchk(0,1,nargout));
  
  % Search the root's children for a figure with the right tag
  buffer_number = findobj(allchild(0), 'flat', 'Type', 'figure', ...
      'Tag', buffer_tag);
  if (isempty(buffer_number))
    y = 0;
  else
    y = buffer_number(1);
  end
  
  return;
  
elseif (strcmp(action, 'ws2buffer'))
  
  %==================================================================
  % Invoke the dialog box in workspace-to-buffer mode.
  %
  % matqdlg('ws2buffer')
  %==================================================================
  
  error(nargchk(1,19,nargin));
  if (rem(nargin,2) ~= 1)
    error('Invalid number of input arguments for ws2buffer action.');
  end

  % Remember the current visible figure.
  figHandles = findobj(allchild(0), 'flat', 'Visible', 'on');
  
  % Set up default properties.
  ok_string = '';
  cancel_string = '';
  entry_string = '';
  prompt_string = 'Enter workspace variable names or expressions:';
  
  buffer_fig = matqdlg('find');
  if (buffer_fig == 0)
    buffer_fig = matqdlg('create');
  end
  if (~isempty(figHandles))
    set(buffer_fig, 'UserData', figHandles(1));
  end
  
  % Process param/value pairs.
  num_properties = (nargin - 1)/2;
  for k = 1:num_properties
    prop_arg_name = ['P' num2str(k)];
    val_arg_name = ['V' num2str(k)];
    prop_arg = lower(eval(prop_arg_name));
    val_arg = eval(val_arg_name);
    if (strcmp(prop_arg, 'promptstring'))
      prompt_string = val_arg;
    elseif (strcmp(prop_arg, 'okcallback'))
      ok_string = val_arg;
    elseif (strcmp(prop_arg, 'cancelcallback'))
      cancel_string = val_arg;
    elseif (strcmp(prop_arg, 'entrystring'))
      entry_string = val_arg;
    else
      set(buffer_fig, prop_arg, val_arg);
    end
  end
  
  cancel_callback=[ ...
    'matqueue(''clear'');' ...
    'eval(get(findobj(gcf,''Tag'',''Cancel''),''UserData''));' ...
    'close(matqdlg(''find''));'];
  
  promptButton = findobj(buffer_fig, 'Tag', 'Prompt');
  entry = findobj(buffer_fig, 'Tag', 'Entry');
  okButton = findobj(buffer_fig, 'Tag', 'OK');
  cancelButton = findobj(buffer_fig, 'Tag', 'Cancel');
  set(okButton, 'UserData', ok_string, 'Callback', 'ws2matq');
  set(cancelButton, 'UserData', cancel_string, 'Callback', cancel_callback);
  set(promptButton, 'String', prompt_string);
  set(entry, 'String', entry_string);
  
  % Adjust height of figure and prompt box.
  prompt_lines = size(prompt_string,1);
  if (prompt_lines > 1)
    set([promptButton entry okButton cancelButton], 'Units', 'pixels');
    prompt_position = get(promptButton, 'Position');
    prompt_height = prompt_position(4);
    increase = (prompt_lines-1) * prompt_height;
    fig_position = get(buffer_fig, 'Position');
    set(promptButton, 'Position', prompt_position + [0 0 0 increase]);
    set(buffer_fig, 'Position', fig_position + [0 0 0 increase]);
    set([promptButton entry okButton cancelButton], 'Units', 'normalized');
  end

  drawnow;
  figure(buffer_fig);
  
  return

elseif (strcmp(action, 'buffer2ws'))
  
  %==================================================================
  % Invoke the dialog box in workspace-to-buffer mode.
  %
  % matqdlg('ws2buffer')
  %==================================================================
  
  error(nargchk(1,19,nargin));
  if (rem(nargin,2) ~= 1)
    error('Invalid number of input arguments for ws2buffer action.');
  end
  
  % Remember the current visible figure.
  figHandles = findobj(allchild(0), 'flat', 'Visible', 'on');
  
  num_items = matqueue('length');
  if (num_items == 0)
    % If the queue is empty, there's nothing to do!
    error('The queue is empty.');
  end
  
  buffer_fig = matqdlg('find');
  if (buffer_fig == 0)
    buffer_fig = matqdlg('create');
  end
  if (~isempty(figHandles))
    set(buffer_fig, 'UserData', figHandles(1));
  end
  
  % Set up default properties.
  ok_string = '';
  entry_string = '';
  cancel_string = '';
  if (num_items == 1)
    prompt_string = 'Enter a variable name:';
  else
    prompt_string = sprintf('Enter %d variable names:', num_items);
  end
  
  % Process param/value pairs.
  num_properties = (nargin - 1)/2;
  for k = 1:num_properties
    prop_arg_name = ['P' num2str(k)];
    val_arg_name = ['V' num2str(k)];
    prop_arg = lower(eval(prop_arg_name));
    val_arg = eval(val_arg_name);
    if (strcmp(prop_arg, 'promptstring'))
      prompt_string = val_arg;
    elseif (strcmp(prop_arg, 'okcallback'))
      ok_string = val_arg;
    elseif (strcmp(prop_arg, 'cancelcallback'))
      cancel_string = val_arg;
    elseif (strcmp(prop_arg, 'entrystring'))
      entry_string = val_arg;
    else
      set(buffer_fig, prop_arg, val_arg);
    end
  end
  
  cancel_callback=[ ...
    'matqueue(''clear'');' ...
    'eval(get(findobj(gcf,''Tag'',''Cancel''),''UserData''));' ...
    'close(matqdlg(''find''));'];

  promptButton = findobj(buffer_fig, 'Tag', 'Prompt');
  set(findobj(buffer_fig, 'Tag', 'OK'), 'UserData', ok_string, ...
      'Callback', 'matq2ws;');
  set(findobj(buffer_fig, 'Tag', 'Cancel'), 'UserData', cancel_string, ...
      'Callback', cancel_callback);
  set(promptButton, 'String', prompt_string);
  set(findobj(buffer_fig, 'Tag', 'Entry'), 'String', entry_string);

  % Adjust height of figure and prompt box.
  prompt_lines = size(prompt_string,1);
  if (prompt_lines > 1)
    set([promptButton entry okButton cancelButton], 'Units', 'pixels');
    prompt_position = get(promptButton, 'Position');
    prompt_height = prompt_position(4);
    increase = (prompt_lines-1) * prompt_height;
    fig_position = get(buffer_fig, 'Position');
    set(promptButton, 'Position', prompt_position + [0 0 0 increase]);
    set(buffer_fig, 'Position', fig_position + [0 0 0 increase]);
    set([promptButton entry okButton cancelButton], 'Units', 'normalized');
  end

  drawnow;
  figure(buffer_fig);
  
  return;
  

elseif (strcmp(action, 'get_entry'))
  
  %==================================================================
  % Get the user-entered string in the entry field.
  %
  % string = matqdlg('get_entry');
  %==================================================================
  
  buffer_fig = matqdlg('find');
  if (buffer_fig < 1)
    y = [];
    return;
  end
  
  y = get(findobj(buffer_fig, 'Tag', 'Entry'), 'String');

  return;

else
  
  error('Invalid action.');
  
end
