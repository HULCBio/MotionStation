%
% Example of HG dialog and setting of various callbacks.  Also
% shows how gcbh returns the handle the block whose callback
% is currently executing.  Companion to sfcndemo_hg_gui.mdl.
%
% Example dialog sets the tag and displays the new tag in the
% command line.
%


%   Copyright 2000-2002 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2004/04/15 00:39:22 $
function sfcndemo_hg_gui_m(varargin),

action = varargin{1};

switch action

  case 'open',
    %
    % Open the dialog or brings existing dialog to foreground
    %
    % Called when double clicking on the block or via open_system
    %     set_param(gcb,'OpenFcn','sfcndemo_hg_gui_m(''open'',gcbh)');
    %
    b = varargin{2};
    i_show(b);

  case {'destroy','delete','close','parentclose'},
    %
    % Destroy the dialog.
    %
    % destroy:
    %   Called when block finally gets destroyed (e.g., model closed).
    %     set_param(gcb,'DestroyFcn','sfcndemo_hg_gui_m(''destroy'',gcbh)');
    %
    % delete
    %   Called when the block gets deleted (e.g., click on it & hit del).
    %   he block does not necessarily get destroyed when this happens (it
    %   moves to the undo area).
    %     set_param(gcb,'DeleteFcn','sfcndemo_hg_gui_m(''delete'',gcbh)');
    %
    % close
    %   Called when the close_system command is invoked on the block.
    %     set_param(gcb,'CloseFcn','sfcndemo_hg_gui_m(''close'',gcbh)');
    %
    % parentclose
    %   Called when the block is insided a subsystem and the subsytem is
    %   closed.
    %     set_param(gcb,'ParentCloseFcn','sfcndemo_hg_gui_m(''parentclose'',gcbh)');
    %
    b    = varargin{2};
    hFig = i_findfig(b);
	
    if ~isempty(hFig),
      delete(hFig);	
    end
	
  case 'namechange',
    %
    % Update the name on the dialog.
    %
    % Called when:
    %   o the model is saved under a new name
    %   o the block name is changed
    %   o an ancestor subsystem of the block has its name changed (i.e., 
    %     the full block path of the name has changed).
    %     
    %     set_param(gcb,'NameChangeFcn','sfcndemo_hg_gui_m(''namechange'',gcbh)');
    %
    b    = varargin{2};
    hFig = i_findfig(b);
	
    set(hFig,'name',getfullname(b));

  case 'settag',
    %
    % This is the callback for the edit box in the GUI.  This is where we
    % actually set new block properties as directed by the GUI.
    %
    hFig = varargin{2};
    i_settag(hFig);

  otherwise,
    error('unhandled action');
end

% Function: i_show =============================================================
% Abstrct:
%   Build a new dialog or bring an existing one to the foreground.  The dialogs
%   tag will be the blocks handle.
function i_show(b),

hStr = num2str(b);
hFig = i_findfig(b);

if ~isempty(hFig),
  %
  % bring it to the foreground
  %
  figure(hFig);
else,
  %
  % create the figure
  %
  hFig = figure( ...
    'IntegerHandle',    'off', ...
    'Name',             getfullname(b), ...
    'Menubar',          'none', ...
    'NumberTitle',      'off', ...
    'HandleVisibility', 'on', ...
    'Position',         [956 843 300 75], ...
    'Tag',              hStr, ...
    'UserData',         b);

  uicontrol( ...
    'Style',           'edit', ...
    'String',          get_param(b,'param'), ...
    'Callback',        'sfcndemo_hg_gui_m(''settag'',gcbf)', ...
    'BackgroundColor', 'w', ...
    'HorizontalAlign', 'left', ...
    'Position',        [5 25 290 24]);

  uicontrol( ...
    'Style',            'text', ...
    'String',           'Enter gain:', ...
    'HorizontalAlign',  'left', ...
    'BackgroundColor',  get(hFig, 'color'), ...
    'Position',         [5 50 75 20]);

end


% Function: i_settag ===========================================================
% Abstract:
%   Set the tag on the block and echo the new tag to the command line.
function i_settag(hFig),

b   = get(hFig,'UserData');
str = get(gcbo,'String');

set_param(b,'param', str);
display(['New parameter set to: ' str]);

% Function: i_findfig ===========================================================
% Abstract:
%   Get the handle figure, if it exists.
function h = i_findfig(b),

hStr = num2str(b);
h    = findobj(allchild(0),'type','figure','tag',hStr);
