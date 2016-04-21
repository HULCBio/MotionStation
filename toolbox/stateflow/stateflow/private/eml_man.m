function [result, varargout] = eml_man(methodName, varargin)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $  $Date: 2004/04/26 23:54:38 $

result = [];

try,
  switch (methodName)
   case {'help_stateflow',...
         'help_eml',...
         'help_desk',...
         'help_editor',...
         'about_stateflow',...
         'open_model',...
         'get_editor',...
         'jvm_available'}
    result = feval(methodName);
   case {'manage_emldesktop',...
         'update_debuggable_status',...
         'sfhelp_topic',...
         'eml_functions_help',...
         'ml_function_exists',...
         'lock_editor',...
         'highlight',...
         'mark_clean',...
         'debugger_step',...
         'debugger_stop',...
         'debugger_continue',...
         'debugger_step_in',...
         'debugger_step_out',...
         'debugger_break',...
         'browse_symbol',...
         'update_diagram',...
         'infer_dbg',...
         'refresh_breakpoints_display',...
         'get_sim_status',...
         'update_ui_state',...
         'register_breakpoint',...
         'clear_all_infer_and_runtime_breakpoints',...
         'clear_all_breakpoints',...
        'scripts_are_editable',...
        'sim_command'}
    result = feval(methodName, varargin{:});
   case {'get_editor_for_opened_object'}
    if nargout > 1
      [result varargout{1}] = feval(methodName, varargin{:});
    else
      result = feval(methodName, varargin{:});
    end
   case 'find_prototype_str'
    [result, varargout{1}, varargout{2}] = feval(methodName, varargin{:});
   case 'create_ui'
    init_html_renderer;
    result = dispatch_task(methodName, varargin{:});
   otherwise
    result = dispatch_task(methodName, varargin{:});
  end
catch,
  str = sprintf('Error calling eml_man(%s): %s',methodName,lasterr);
  construct_error([], 'Embedded MATLAB', str, 0);
  slsfnagctlr('ViewNaglog');
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = dispatch_task(methodName, objectId, varargin)

result = [];

if ~sf('ishandle', objectId)
    return;
end

if is_eml_fcn(objectId)
    result = eml_function_man(methodName, objectId, varargin{:});
elseif is_eml_chart(objectId)
    result = eml_chart_man(methodName, objectId, varargin{:});
elseif is_eml_script(objectId)
    result = eml_script_man(methodName, objectId, varargin{:});
else
    disp(sprintf('Non-Embedded MATLAB object with id #%d passed to eml_man', objectId));
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = jvm_available

persistent sRlt;

if isempty(sRlt)
    sRlt = usejava('jvm') & usejava('awt') & usejava('swing');
end

result = sRlt;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function editor = get_editor

persistent sJavaErrorMessage;

editor = [];

if ~jvm_available
  return;
end

if isempty(sJavaErrorMessage)
  [prevErrMsg, prevErrId] = lasterr;
  try 
    editor = com.mathworks.toolbox.eml.EMLEditorApi.editorHandle();
  catch
    editor = [];
    sJavaErrorMessage = sprintf(['Embedded MATLAB Editor failed to open:'...
                        '%s'],lasterr);
    warning(sJavaErrorMessage);
    
    lasterr(prevErrMsg,prevErrId);
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = manage_emldesktop(varargin)

persistent sJavaErrorOccurred;
result = [];
if ~jvm_available
  return;
end

H = com.mathworks.toolbox.eml.EMLEditorApi.editorHandle();
result = H;

if(isempty(sJavaErrorOccurred))
    [prevErrMsg, prevErrId] = lasterr;
    try,
       if nargin > 0
            Action = varargin{1};
            switch (Action)
                case 'status'
                    if ~isempty(H)
                        result = 1;
                    else
                        result = 0;
                    end
                case 'close'
                    if ~isempty(H)
                        H.editorTerminate();
                        H = [];
                        clear H;
                    end
            end
        end
    catch,
        sJavaErrorOccurred = sprintf('Error occurred managing Embedded MATLAB Java editor: %s',lasterr);
        warning(sJavaErrorOccurred);
        lasterr(prevErrMsg, prevErrId);
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = open_model

result = [];
sfopen;
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = eml_help_helper(isEmlChart)

result = [];
try
  if isEmlChart
    % eml_functions_simulink
    helpview([docroot '/mapfiles/simulink.map'],  'em_block_ref');
  else
    % eml_functions_stateflow
    helpview([docroot '/mapfiles/stateflow.map'],  'eml_functions_stateflow');
  end
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result =  eml_functions_help(objectId)

result = [];
try
  if nargin == 0
    eml_help_helper(true);
  else
    chartId = sf('get', objectId, '.chart');
    eml_help_helper(is_eml_chart(chartId));
  end
end
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sfhelp_topic(topic)

result = [];
sfhelp(topic);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_stateflow

result = [];
sfhelp('stateflow');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_desk

result = [];
sfhelp('helpdesk');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_eml

result = [];
sfhelp('eML_functions_chapter');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = help_editor

result = [];

try  
  helpview([docroot '/mapfiles/simulink.map'],'eml_editor'); 
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = about_stateflow

resutl = [];
sfabout;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = ml_function_exists(fcnName)

result = [];
existType = exist(fcnName);
switch (existType),
case {2, 3, 5, 6},
    result = true;
otherwise,
    result = false;
end,
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [result, objectId] = get_editor_for_opened_object(objectId)
% This function returns the editor handle which has object opened
% If no editor available, or object is not open in editor, return empty.

result = [];

if nargout > 1
    if is_eml_chart(objectId)
        ids = eml_fcns_in(objectId);
        if ~isempty(ids)
            objectId = ids(1);
        end
    end
end

hEditor = manage_emldesktop;
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  result = hEditor;
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sim_command(machineId, cmd)

result = [];

modelH = sf('get',machineId,'machine.simulinkModel');

switch(cmd)
    case 'start'
        if strcmp(get_param(modelH,'SimulationStatus'),'paused') & strcmp(cmd,'start')
            set_param(modelH,'SimulationCommand', 'continue');
        else
          start_simulation(machineId);
        end
    case 'stop'
        stop_simulation(machineId);
    otherwise,
        set_param(modelH,'SimulationCommand', cmd);
end

eml_man('update_ui_state',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_debuggable_status(machineId)

hEditor = get_editor();
if ~isempty(hEditor)
  if ~sf('ishandle',machineId)
    % True for scripts which have a bogus "machineId"
    isOn = false;
  else
    target = sf('get',machineId,'.firstTarget');
    isOn = target_code_flags('get',target,'debug');
  end
  
  if isOn
    isOn = true;
  else 
    isOne = false;
  end

  hEditor.machineSetDebuggable(machineId, isOn);

end
  
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_sim_status(machineId)
result = '-1';

modelH = sf('get',machineId,'machine.simulinkModel');

result =  get_param(modelH, 'simulationstatus');

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_ui_state(machineId,state)
result = [];

hEditor = get_editor();
if isempty(hEditor) || ~hEditor.machineIsOpen(machineId)
  return;
end

if(nargin == 1)    
  if sf('ishandle',machineId)
    simStatus = get_sim_status(machineId);
    
    switch(lower(simStatus))
     case 'stopped',
      if sfdebug_paused(machineId)
        state = 'debug_pause';
      else
        state = 'idle';
      end
     case 'updating',
      if infer_dbg %sfdebug_paused(machineId)
        state = 'build_pause';
      else
        state = 'build';
      end
     case 'initializing',
      state = 'build';
     case 'running',
      if sfdebug_paused(machineId)
        state = 'debug_pause';
      else
        state = 'run';
      end
     case 'paused',
      if sfdebug_paused(machineId)
        state = 'debug_pause';
      else 
        state = 'run_pause';
      end
     case 'terminating',
      state = 'idle';
     case 'external',
      state = 'run';
     case 'library';
      hMachine.setLibrary(true);
     otherwise,
      state = 'error';
    end
  else
    state = 'idle';
  end  
end

hEditor.machineSetUIState(machineId,state);

update_debuggable_status(machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = lock_editor(objectId, mode)
% mode: lock/unlock = true/false
result = [];

hEditor = get_editor();
if ~isempty(hEditor)
  if mode % Ensure mode is a logical.
    mode = true;
  else 
    mode = false;
  end
  % FIXME: Document or Machine??
  hEditor.documentSetLock(objectId,mode);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = highlight(objectId, sPos, ePos)

result = [];

hEditor = get_editor();
if ~isempty(hEditor)
  if is_eml_chart(objectId)
    fcnId = eml_fcns_in(objectId);
    if ~isempty(fcnId)
      objectId = fcnId(1);
    end
  end
  hEditor.documentHighlightError(objectId,sPos,ePos);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step(machineId)
result = [];

inferDbgMode = eml_man('infer_dbg');

if inferDbgMode
    sf_debug_exit_trap;
else
    sfdebug('gui','step_over',machineId);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step_in(machineId)
result = [];

sfdebug('gui','step',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_step_out(machineId)
result = [];

sfdebug('gui','step_out',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_continue(machineId)
result = [];

inferDbgMode = eml_man('infer_dbg');

if inferDbgMode
    sf('EmlInferDbgGo');
    sf_debug_exit_trap;
else
sfdebug('gui','go',machineId);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_stop(machineId)
result = [];

sfdebug('gui','stop_debugging',machineId);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = debugger_break(objectId, lineNo)

result = [];

hEditor = get_editor();
if ~isempty(hEditor)
  hEditor.documentDebuggerStopAt(objectId,lineNo);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = mark_clean(objectId)
result = [];

chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');

hEditor = get_editor();
if ~isempty(hEditor)
  hEditor.machineSetDirty(machineId,false);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [str, st, en] = find_prototype_str(text)
% Searching for prototype string in text
% function y = foo(x),   returns  "y = foo(x)",
% st: the start position of "function y = foo(x)"
% en: the end position of "function y = foo(x)"

[s e t] = regexp([text 10], '^(?:\s*(%[^\n]*)?\n)*\s*(function)\s*(\.\.\.[^\n]*\n|.)*?(?:\s*[%\n])', 'once');

if isempty(s)
    % Doesn't match any prototype pattern
    st = 0; en = 0; str = '';
    return;
end

pSt = t{1}(2,1);
pEn = t{1}(2,2);
st = t{1}(1,1);
if pSt > pEn
    % Empty second token
    en = t{1}(1,2);
else
    en = t{1}(2,2);
end

str = text(pSt:pEn);

if text(en) == 10
    % We want to preserve the ending newline, so that it won't be eaten
    % out by replacing with updated prototype.
    en = en - 1;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_diagram(objectId)
result = [];
chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
modelH = sf('get',machineId,'machine.simulinkModel');
set_param(modelH, 'SimulationCommand','Update')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = browse_symbol(objectId, symbolName)
result = [];

resolvedId = sf('EmlResolveSymbol', objectId, symbolName);

if (resolvedId ~= 0)
  sf('Open', resolvedId);
else
  hEditor = get_editor();
  if ~isempty(hEditor)
    hEditor.documentGotoSymbolFirstExistence(symbolName);
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = infer_dbg(varargin)

persistent status;

if isempty(status)
    status = 0;
end

switch nargin
    case 1
        status = varargin{1};

        sf('EmlInferDbgSetEnable', status);

        if manage_emldesktop('status')
            hEmlEditor = manage_emldesktop;
            uiObjList = double(hEmlEditor.cachedObjectIds());
            for i = 1:length(uiObjList)
                refresh_breakpoints_display(uiObjList(i));
            end
        end
    case 2
        status = varargin{1};
        refreshBreakPointStatus =  varargin{2};
        sf('EmlInferDbgSetEnable', status);
        if(refreshBreakPointStatus)
        end
    otherwise
        % do nothing
end

result = status;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = refresh_breakpoints_display(objectId, varargin)
% objectId, <breakpoints>

result = [];

bkpts = [];
inferBreakPoints = [];
if nargin > 1
    bkpts = varargin{1};
else
    bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, infer_dbg);
    bkpts = sf('get', objectId, bkptPropStr);
    inferBreakPoints = sf('get', objectId,'state.eml.inferBkpts')
end

hEditor = get_editor();
if ~isempty(hEditor)
  if(infer_dbg)
    hEditor.documentSetBuildBreakpoints(objectId,inferBreakPoints);
  end
  hEditor.documentSetRunBreakpoints(objectId,bkpts);  
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = register_breakpoint(objectId, lineNo, regValue, debugMode)
result = [];
% if debugMode == 0 register  RunTime breakpoints
% if debugMode == 1 register  Inference breakpoints

if nargin < 4
  debugMode = 0;
end

bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, debugMode);
brkpts = sf('get', objectId, bkptPropStr);
if regValue
    if isempty(find(brkpts == lineNo))
        brkpts = [brkpts, lineNo];
    end
else
    brkpts(brkpts == lineNo) = [];
end
sf('set', objectId, bkptPropStr, brkpts);

result = brkpts;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = clear_all_breakpoints(objectId)

result = [];

bkptPropStr = dispatch_task('get_bkpt_prop_str', objectId, infer_dbg);
sf('set', objectId, bkptPropStr, []);
return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = clear_all_infer_and_runtime_breakpoints(objectId)
result = [];
sf('set', objectId,'state.eml.breakpoints',[])
sf('set', objectId,'state.eml.inferBkpts',[])

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = scripts_are_editable()

result = logical(sf('Feature','Developer'));

return;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
