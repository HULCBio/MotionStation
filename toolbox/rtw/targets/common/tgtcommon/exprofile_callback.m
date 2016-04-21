function varargout = exprofile_callback(action, varargin)
%EXPROFILE_CALLBACK Execution profiling callback for system target files.
%
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $

  s.action = action;
  s.hSrc = varargin{1};
  s.hDlg = varargin{2};

  switch action
    
   case 'callback',
        
    s.currentVar = varargin{3};
    s.currentVal = getVal(s, s.currentVar);
    feval([s.currentVar '_callback'], s);
    
   case 'opencallback',
    % Execute all dynamic-dialog callbacks
    callbacks = {'ExecutionProfilingEnabled'};
    for k = 1:length(callbacks),
      s.currentVar = callbacks{k};
      s.currentVal = getVal(s, s.currentVar); % gets DEFAULT value
      feval([s.currentVar '_callback'], s);
    end
  end
    
function ExecutionProfilingEnabled_callback(s)
  
  switch s.currentVal
   case {'on'}
    setEnable(s, 'ExecutionProfilingNumSamples', 1);
   otherwise
    setEnable(s, 'ExecutionProfilingNumSamples', 0);
  end

% --------------------------------------------------------------------
function setEnable(s, propName, state)

% Allow either number or string representation
if strcmp(state,'on'),
    state = 1;
elseif strcmp(state,'off'),
    state = 0;
end

slConfigUISetEnabled(s.hDlg,s.hSrc,propName,state);

% --------------------------------------------------------------------
function val = getVal(s, propName)

val = slConfigUIGetVal(s.hDlg, s.hSrc, propName);
