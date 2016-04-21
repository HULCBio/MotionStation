function varargout = sldebugui(varargin)
% SLDEBUGUI creates and manages the graphical Simulink debugger

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8.2.3 $
%   Sanjai Singh 01-26-00
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define PERSISTENT variables that track the state of the Debugger %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  persistent DEBUGGER_HANDLE;
  persistent MODEL_HANDLE;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% Lock the file to prevent tampering %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  mlock
  
  %%%%%%%%%%%%%%%%%%%%%%%%%
  %% Determine arguments %%
  %%%%%%%%%%%%%%%%%%%%%%%%%
  error(nargchk(1, 2, nargin));
  Action = varargin{1};
  
  %%%%%%%%%%%%%%%%%%%%
  %% Process Action %%
  %%%%%%%%%%%%%%%%%%%%
  switch (Action)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Create Debugger if needed or make it visible %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'Create'
    
    % Test for existence of java
    if ~usejava('MWT')
      error('The Simulink debugger requires Java support');
    end
    
    model = varargin{2};
    if (isempty(DEBUGGER_HANDLE))
      DEBUGGER_HANDLE = com.mathworks.toolbox.simulink.debugger.SimDebugger.CreateSimulinkDebugger(model);
      MODEL_HANDLE    = get_param(model, 'Handle');
    else
      frame = DEBUGGER_HANDLE.getParent;
      frame.show;
      name = get_param(MODEL_HANDLE, 'Name');
      if ~strcmp(model, name)
          errordlg(sprintf(['The Simulink Debugger is being used for : ''%s''.\n', ...
                  'To debug ''%s'', exit current debugger.'], name, model));
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%
    %% Start Debugger %%
    %%%%%%%%%%%%%%%%%%%%
   case 'Start'
    frame = DEBUGGER_HANDLE.getParent;
    name  = get_param(MODEL_HANDLE, 'Name');
    
    DEBUGGER_HANDLE.updateWindowTitle(frame, name);
    sldebug(name)
    
    %%%%%%%%%%%%%%%%%%%%
    %% Close Debugger %%
    %%%%%%%%%%%%%%%%%%%%
   case 'Close'
    frame = DEBUGGER_HANDLE.getParent;
    DEBUGGER_HANDLE = [];
    MODEL_HANDLE    = -1;
    frame.dispose;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get Debugger Handle %%
    %%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetHandle'
    varargout{1} = DEBUGGER_HANDLE;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get current block if not virtual %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetCurrentBlock'
    oldGCB = gcb;
    if isempty(oldGCB)
      errordlg(['There is no block selected in the model']);
      newGCB = '';
    elseif strcmp(get_param(oldGCB, 'Virtual'), 'off')
      newGCB = strrep(oldGCB, sprintf('\n'), ' ');
    else
      errordlg(['The selected block is virtual and meant for graphical' ...
                ' purposes only. You must select a block that is part of' ...
                ' the simulation i.e a block that generates a signal']);
      newGCB = '';
    end
    varargout{1} = newGCB;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get simulation state of the model %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetModelState'
    state = get_param(MODEL_HANDLE, 'SimulationStatus');
    varargout{1} = state;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get top level stack data %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetTopLevelStackData'
    topstack = slfeature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'stack');
    varargout{1} = i_ConvertStackToObject(topstack, 0);
    
    %%%%%%%%%%%%%%%%%%%%
    %% Get stack data %%
    %%%%%%%%%%%%%%%%%%%%
   case 'GetStackData'
    indices = varargin{2};
    indices = double([indices{:}]);
    
    stack = slfeature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'stack', indices);
    varargout{1} = i_ConvertStackToObject(stack, indices);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Refresh entire stack %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'RefreshStack'
    if ~isempty(DEBUGGER_HANDLE)
      DEBUGGER_HANDLE.refreshStack; 
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Get break points set via "break gcb" %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   case 'GetBlockBreakPoints' 
    fullnames = {};
    bPoints   = slfeature('sldebug', get_param(MODEL_HANDLE, 'Name'), 'breakpoints');
    if ~isempty(bPoints) & isstruct(bPoints)
      blockPoints = bPoints(find([bPoints.nodeIndex] == -1));
      if ~isempty(blockPoints)
        fullnames = getfullname([blockPoints.handle]);
      end
    end
    varargout{1} = fullnames;
    
   case 'IsPauseRequested' 
    varargout{1} = DEBUGGER_HANDLE.querySimulationPause;
   case 'GetAnimationDelay' 
    varargout{1} = DEBUGGER_HANDLE.queryAnimationDelay;
  end
  
%%
% Local function to convert the stack data structure to an object to send
% to java
%%
function object = i_ConvertStackToObject(stack, indices)
  
  object = {};
  for i = 1:length(stack)
    isBlock = double(strcmp(get_param(stack(i).handle, 'Type'), 'block'));              
    object{i} = com.mathworks.toolbox.simulink.debugger.StackObject(...
        stack(i).name, stack(i).handle, stack(i).status, ...
        stack(i).breakOnEntry, indices(i), stack(i).childNodeIndices, isBlock);
  end
  
