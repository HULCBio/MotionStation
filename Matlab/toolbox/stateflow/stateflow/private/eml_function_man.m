function result = eml_function_man(methodName, objectId, varargin)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2004/04/15 00:57:23 $

result = [];

% Input object should be Stateflow eML function
if ~sf('ishandle',objectId) || ~is_eml_fcn(objectId)
    return;
end

try,
    switch(methodName)
        case {'close_ui', 'set_title','compile','get_eml_prototype',}
            result = feval(methodName, objectId);
        case {'update_active_instance', 'update_data', 'update_ui', 'goto_sf_explorer', 'sync_prototype', 'query_symbol'}
            set_title(objectId);
            result = feval(methodName, objectId, varargin{:});
        case {'goto_sf_editor', 'update_layout_data', 'model_dirty', 'new_model','print'}
            set_title(objectId);
            result = feval(methodName, objectId);
        case {'update_script_prototype', 'create_ui'}
            result = feval(methodName, objectId, varargin{:});
        case {'get_bkpt_prop_str'}
            result = feval(methodName, varargin{:});
        case 'save_model'
            set_title(objectId);
            machine = sf('get',sf('get',objectId,'.chart'),'.machine');
            % sfsave will do all eML, truthtable data updation from editor
            sfsave(machine,[], 1);
        case 'save_model_as'
            set_title(objectId);
            machine = sf('get',sf('get',objectId,'.chart'),'.machine');
            % sfsave will do all eML, truthtable data updation from editor
            sfsave(machine,sf('get',machine,'.name'), 1);
        case 'export_to_m'
            set_title(objectId);
            update_data(objectId);
            % NOT DONE YET
        otherwise,
            disp(sprintf('Unknown methodName %s passed to eml_function_man', methodName));
    end
catch,
    str = sprintf('Error calling eml_function_man(%s): %s',methodName,lasterr);
    if(~strcmp(methodName,'create_ui'))
        construct_error(objectId, 'Embedded MATLAB', str, 0);
        slsfnagctlr('ViewNaglog');
    else
        str = sprintf('Error opening the Embedded MATLAB editor:\n%s\n',clean_error_msg(lasterr));
        disp(str);
        errordlg(str,'Embedded MATLAB Editor Creation Failed','replace');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_eml_prototype(objectId)

script = sf('get', objectId, 'state.eml.script');
result = eml_man('find_prototype_str', script);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = print(objectId)

update_data(objectId);
htmlBuf = state2html(objectId);
jobName = ['(Embedded MATLAB) ' sf('get', objectId, '.name')];
result = print_html_str(htmlBuf, jobName);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isLibrary = machine_is_library(machineId)
modelH = sf('get',machineId,'machine.simulinkModel');

isLibrary = strcmp(lower(get_param(modelH,'BlockDiagramType')), ...
                     'library');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_active_instance(objectId)

result = [];

hEditor = eml_man('manage_emldesktop');

if isempty(hEditor) 
  return;
end

if hEditor.documentIsOpen(objectId)
  chartId = sf('get',objectId,'state.chart');
  activeMachineId = actual_machine_referred_by(chartId);
  
  % Make sure the active machine is "open" in the editor.
  if ~hEditor.machineIsOpen(activeMachineId)
    hEditor.machineOpen(activeMachineId, ...
                        machine_is_library(activeMachineId));
  end
  hEditor.documentChangeActiveInstance(objectId,activeMachineId);
end

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(objectId, inDebugging)

result = [];
if ~eml_man('jvm_available');
    str = sprintf('%s','The Embedded MATLAB editor requires Java Swing and AWT components. One of these components in missing.');
    error(str);
end

hEditor =  eml_man('manage_emldesktop');
if(isempty(hEditor))
    str = sprintf('%s','Embedded MATLAB editor could not be initialized.');
    error(str);
end

if nargin < 2
    inDebugging = 0;
end

if hEditor.documentIsOpen(objectId)
  % Already open. Bring it to front.
  % Do not grab focus if in the command-line debugger.
  % But we should grab focus if we are not at the command line
  % Not at the command line seems the most likely case to me
  requestFocus = true;
  %if inDebugging
  %  requestFocus = false;
  %else
  %  requestFocus = true;
  %end
  hEditor.documentToFront(objectId,requestFocus);
else
  % Create the a new document window for this id.
  chartId = sf('get',objectId,'state.chart');
  machineId = sf('get',chartId,'chart.machine');
  isLibrary = machine_is_library(machineId);

  activeMachineId = actual_machine_referred_by(chartId);
  hEditor.machineOpen(machineId,isLibrary);
  hEditor.machineOpen(activeMachineId,...
                      machine_is_library(activeMachineId));


  [emltitle, shorttitle] = create_title_string(objectId);
  layout = sf('get', objectId, 'state.eml.editorLayout');
  if(isempty(layout) || length(layout) ~= 4)
    layout = [10, 5, 750, 500];
  end
  
  opened = hEditor.documentOpen(activeMachineId,...
                                machineId,...
                                objectId, ...
                                emltitle,...
                                shorttitle, ...
                                sf('get',objectId,'state.eml.script'),...
                                layout(1), layout(2), layout(3), layout(4));
  
  if ~opened
    error('Failed to open a new Embedded MATLAB editor pane.');
  end
  
  % Mark breakpoints
  bkpts = sf('get', objectId, get_bkpt_prop_str);
  inferBkpts = sf('get', objectId, 'state.eml.inferBkpts');
  
  hEditor.documentSetRunBreakpoints(objectId,bkpts);
  hEditor.documentSetBuildBreakpoints(objectId,inferBkpts);
    
  if(sf('get',chartId,'chart.iced') || sf('get',chartId,'chart.locked'))
    eml_man('lock_editor',objectId,1);
  end  

  if sfdebug_paused(activeMachineId)
    [id,lineNo] = sfdebug_get_linenum(activeMachineId);
    if(id == objectId && lineNo ~= 0)
      eml_man('debugger_break',objectId,lineNo);
    end
  end

  eml_man('update_ui_state',activeMachineId);  
end

result = hEditor;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = during_close_ui(varargin)
% G157881. In editor closing time, don't try to update UI

persistent status;
result = [];

if isempty(status)
    status = 0;
end

if nargin > 0
    status = varargin{1};
end

result = status;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = close_ui(objectId)

result = [];

during_close_ui(1);

hEditor = eml_man('manage_emldesktop');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  update_data(objectId);
  update_layout_data(objectId);
  hEditor.documentClose(objectId);
end

hEditor = [];
clear hEditor;

during_close_ui(0);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_data(objectId,varargin)

result = [];

if nargin > 1
    switch varargin{1}
        case 'script'
            oldScript = sf('get',objectId,'state.eml.script');
            newScript = char(varargin{2});
            if ~isequal(oldScript, newScript)
                sf('TurnOffEMLUIUpdates',1);
                sf('set',objectId,'state.eml.script',newScript);
                sf('TurnOffEMLUIUpdates',0);
            end
        otherwise
            error('Unknown data update mode');
    end
else  
    % update data from eML editor UI
    hEditor = eml_man('get_editor');
    if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
        oldScript = sf('get',objectId,'state.eml.script');
        newScript = char(hEditor.documentGetText(objectId));
        if ~isequal(oldScript, newScript)
            sf('TurnOffEMLUIUpdates',1);
            sf('set',objectId,'state.eml.script',newScript);
            sf('TurnOffEMLUIUpdates',0);
        end        
    end      
end

% %%%% EMM - 2/22/2003 - The following code is for BAT and internal
% %%%                   testing of eML language and run-time library
% %%%                   scripts.
eml_evalin_matlab('eval',objectId);
%%%

return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = compile(objectId)

result = [];
chartId = sf('get', objectId, '.chart');
machineId = sf('get',chartId,'chart.machine');
autobuild_driver('rebuildall',machineId,'sfun','yes');
% update status bar
result = 'ready';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = new_model(objectId)

result = [];
chartId = sf('get', objectId, '.chart');
if(is_eml_chart(chartId))
    open_system(new_system);
else
    sfnew;
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_bkpt_prop_str(varargin)

result = [];
inferDbgMode = [];

if nargin > 0
    inferDbgMode = varargin{1};
else
    inferDbgMode = 0;
end

if inferDbgMode
    result = 'state.eml.inferBkpts';
else
    result = 'state.eml.breakpoints';
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_title(objectId)
% Refresh eML editor title
result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  [titleString, shortName] = create_title_string(objectId);
  hEditor.documentSetTitle(objectId,titleString);
  hEditor.documentSetShortName(objectId,shortName);  
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [titleString, shortName] = create_title_string(objectId)
% the title string must be appropriately
% constructed for eml fcns and eml blocks
chartId = sf('get',objectId,'.chart');

[fullName,shortName] = chart2name(chartId);

if(is_eml_chart(chartId))
    titleString = ['Block: ' fullName];
else
    titleString = ['Stateflow (Embedded MATLAB) ' fullName];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_ui(objectId, varargin)
result = [];
if nargin < 2
  return;
end

hEditor = eml_man('get_editor');
if ~isempty(hEditor)  
  switch varargin{1}
   case 'script'
    hEditor.documentSetText(objectId,varargin{2},false);
   otherwise
    return;
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_editor(objectId)
result = [];

chartId = sf('get', objectId, '.chart');
if(is_eml_chart(chartId))
    sf('UpView',chartId);
else
    if chartId > 0
        sf('Open', chartId);
        sf('FitToView', chartId, objectId);
    end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = goto_sf_explorer(objectId, varargin)
result = [];

sf('Explr');
if nargin > 1
    sf('Explr', 'VIEW', varargin{1});
else
    objectId = eml_fcn_source(objectId);
    sf('Explr', 'VIEW', objectId);
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = is_alphanumeric(ch)

result = false;

if (ch >= 'a' && ch <= 'z') || ...
   (ch >= 'A' && ch <= 'Z') || ...
   (ch >= '0' && ch <= '9') || ...
   (ch == '_')
   result = true;
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = extract_symbol_from_pos(textBuf, pos)

result = '';

if(pos > length(textBuf) || pos < 1)
  return;
end

% pos is often to the left by 1/2 a character so give us some 
% slack.  We should consider a smaller pos if possible.
if(pos>1 && ~is_alphanumeric(textBuf(pos)))
  pos = pos-1;
end

% Get the lower boundry
pl = pos;
while pl > 0 && is_alphanumeric(textBuf(pl))
    pl = pl - 1;
end
pl = pl + 1;

if pl > pos || (textBuf(pl) >= '0' && textBuf(pl) <= '9')
    % Either current pos is not alhpanumeric, or the word begins with 0-9
    return;
end

% Get the upper boundry
pu = pos;
bufLen = length(textBuf);
while pu <= bufLen && is_alphanumeric(textBuf(pu))
    pu = pu + 1;
end
pu = pu - 1;

result = textBuf(pl:pu);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = query_symbol(objectId, pos)
% query_symbol is used by editor UI to display data value in tooltip
result = [];

hEditor = eml_man('get_editor');
if isempty(hEditor)
  return;
end

inferDbgMode = eml_man('infer_dbg');

if inferDbgMode
  [inferInfoStr, sPos, ePos] = sf('EmlInferDbgTooltip',objectId, ...
                                  pos);
  if(sPos>0) 
    eml_man('highlight',objectId,sPos,ePos);
  end
  
  hEditor.documentDisplayTooltipSymbol(objectId,inferInfoStr);
else
  %hEditor.documentDisplayTooltipSymbol(objectId,sprintf('pos = %d',pos));
  textBuf = sf('get', objectId, 'state.eml.script');
  symbolName = extract_symbol_from_pos(textBuf, pos);
  
  if ~isempty(symbolName)
    chartId = sf('get',objectId,'state.chart');
    machineId = actual_machine_referred_by(chartId);
    dataVal = sfdebug('mex', 'watch_data', machineId, symbolName);
    if ~ischar(dataVal) || ~strcmp(dataVal, 'Unrecognized symbol.')
      if ischar(dataVal)
        dataVal = sprintf('"%s"', dataVal);
      end
      valStr = evalc('disp(dataVal)');
      valStr = [symbolName ' =' 10 valStr(1:end-1)];
      hEditor.documentDisplayTooltipSymbol(objectId,valStr);
    end
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_layout_data(objectId)

result = [];

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
  layout = double(hEditor.documentLayout(objectId));
  sf('set', objectId, 'state.eml.editorLayout', layout);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_dirty(objectId)

result = [];

chartId = sf('get',objectId,'state.chart');
machineId = sf('get',chartId,'chart.machine');
modelH = sf('get',machineId,'machine.simulinkModel');

sf('set',machineId,'machine.dirty',1);
sf('set',chartId,'chart.dirty',1);
if(strcmp(get_param(modelH,'Lock'),'off'))
  set_param(modelH,'dirty','on');
end

hEditor = eml_man('get_editor');
if ~isempty(hEditor) && hEditor.machineIsOpen(machineId)
  hEditor.machineSetDirty(machineId,true);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = sync_prototype(objectId, dirLabelToScript)

result = [];

% Turn off syncronize becase we are alreay in it
sf('TurnOffPrototypeSync',1);

if (dirLabelToScript)
    % The sync direction is from label string to eML script

    % Make sure Statflow get updated eML script from eML editor.
    update_data(objectId);

    newLabelStr = sf('get', objectId, 'state.labelString');
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str',script);

    if (st == 0)
        % Fix function prototype in script
        update_script_prototype(objectId, script, ['function ' regexprep(newLabelStr, '\(\)$', '') 10], st,en);
    elseif ~function_prototype_utils('compare', newLabelStr, pStr)
        % Update function prototype in script
        update_script_prototype(objectId, script, ['function ' regexprep(newLabelStr, '\(\)$', '')], st,en);
    end
else
    % The sync direction is from eML script to label string
    oldLabelStr = sf('get', objectId, 'state.labelString');
    script = sf('get', objectId, 'state.eml.script');
    [pStr st en] = eml_man('find_prototype_str',script);

    if (st == 0)
        % Fix function prototype in script
        update_script_prototype(objectId, script,  ['function ' regexprep(oldLabelStr, '\(\)$', '') 10], st,en);
    %elseif ~function_prototype_utils('compare', oldLabelStr, pStr)
    elseif ~strcmp(oldLabelStr, pStr)
        % Update function prototype in Stateflow

        % Attempt to set Stateflow block with new labelString
        % Read back the auto corrected label string.
        sf('set', objectId, 'state.labelString', pStr);
        corrLabelStr = sf('get', objectId, 'state.labelString');

        if ~function_prototype_utils('compare', corrLabelStr, pStr)
            % If prototype get corrected, correct it in script too
            update_script_prototype(objectId, script, ['function ' regexprep(corrLabelStr, '\(\)$', '')], st,en);
        end
    end
end

% Restore syncronize function prototype
sf('TurnOffPrototypeSync',0);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = update_script_prototype(objectId, script, newPrototypeStr, st, en)

result = [];

newScript = [script(1:st-1) newPrototypeStr script(en+1:end)];
sf('TurnOffEMLUIUpdates',1);
sf('set', objectId, 'state.eml.script', newScript);
sf('TurnOffEMLUIUpdates',0);

if ~during_close_ui
  hEditor = eml_man('get_editor');
  if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    hEditor.documentUpdateSubstring(objectId,st,en,newPrototypeStr);
  end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objectId = eml_fcn_source(objectId)

chartId = sf('get',objectId,'.chart');
if(is_eml_chart(chartId))
    objectId = chartId;
end
return;
