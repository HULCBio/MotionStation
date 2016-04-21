function result = eml_script_man(methodName, objectId, varargin)
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2004/04/15 00:57:26 $

result = [];

% Input object should be Stateflow eML script
if ~sf('ishandle',objectId) || ~is_eml_script(objectId)
    return;
end

try,
    switch(methodName)
        case {'create_ui', 'close_ui', 'set_title', 'save_model', ...
              'print', 'model_dirty'}
            result = feval(methodName, objectId);
        %case {'debugger_step', 'debugger_stop', 'debugger_continue','get_eml_prototype'}
        %case {'update_data','save_model_as','update_ui','update_layout_data','model_dirty','new_model'}
            % These methods need more thoughts
        %    result = feval(methodName, objectId, varargin{:});
        %case {'query_symbol'}
        %    result = feval(methodName, objectId, varargin{:});
        case {'get_bkpt_prop_str'}
            result = feval(methodName, varargin{:});
        otherwise,
            errStr = sprintf('Unknown methodName "%s" passed to eml_script_man', methodName);
            %error(errStr);
            disp(errStr);
    end
catch,
    str = sprintf('Error calling eml_script_man(%s): %s',methodName,lasterr);
    if(~strcmp(methodName,'create_ui'))
        construct_error(objectId, 'Embedded MATLAB', str, 0);
        slsfnagctlr('ViewNaglog');
    else
        str = sprintf('Error opening the Embedded MATLAB editor:\n%s\n',clean_error_msg(lasterr));
        disp(str);
        errordlg(str,'Embedded MATLAB Editor Creation Failed','replace');
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = create_ui(objectId)

result = [];
if ~eml_man('jvm_available');
    str = sprintf('%s','The Embedded MATLAB editor requires Java Swing and AWT components. One of these components in missing.');
    error(str);
end

hEditor =  eml_man('manage_emldesktop');
if(isempty(hEditor))
    str = sprintf('%s','The Embedded MATLAB editor could not be initialized.');
    error(str);
end

if hEditor.documentIsOpen(objectId)
  hEditor.documentToFront(objectId,true);
else
    [emltitle, shorttitle] = create_title_string(objectId);
    % TODO: use sf('Feature','ReferenceDegung')
    layout = [0, 0, 0, 0];
    scriptMachineId = -1;
    hEditor.machineOpen(scriptMachineId,false);
    
    success = hEditor.documentOpen(scriptMachineId,...
                                   scriptMachineId,...
                                   objectId,...
                                   emltitle,...
                                   shorttitle,...
                                   sf('get',objectId,'script.script'),...
                                   layout(1),layout(2),layout(3), ...
                                   layout(4));
    
    % Mark breakpoints
    %bkpts = sf('get', objectId, get_bkpt_prop_str);
    %hDoc.setRunBreakpoints(bkpts);
    %inferBkpts = sf('get', objectId, 'state.eml.inferBkpts');
    %hDoc.setBuildBreakpoints(inferBkpt);
    
    hEditor.setScriptEditableFeature(eml_man('scripts_are_editable'));

    eml_man('update_ui_state',-1,'idle');        
end

result = hEditor;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = set_title(objectId)
% Refresh eML editor title
result = [];

hEditor = eml_man('get_editor_for_opened_object', objectId);
if ~isempty(hEditor)
    hEditor.setEditorTitle(objectId,create_title_string(objectId));
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [titleString, shortName] = create_title_string(objectId)

filePath = sf('get', objectId, 'script.filePath');
titleString = ['Script: ' filePath];
shortName = sf('get', objectId, '.name');
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = close_ui(objectId)

result = [];

%during_close_ui(1);

hEditor = eml_man('get_editor_for_opened_object', objectId);
if ~isempty(hEditor)
    %update_data(objectId);
    %update_layout_data(objectId);
    hEditor.documentClose(objectId);
end

hEditor = [];
clear hEditor;

%during_close_ui(0);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = print(objectId)

%update_data(objectId); % Put print in eml_man later
htmlBuf = state2html(objectId);
jobName = ['(Embedded MATLAB) ' sf('get', objectId, '.name')];
result = print_html_str(htmlBuf, jobName);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = save_model(objectId)

result = [];

hEditor = eml_man('get_editor')
if ~isempty(hEditor) && hEditor.documentIsOpen(objectId)
    newScript = char(hEditor.documentGetText(objectId));
    sf('set', objectId, 'script.script', newScript);
    
    filePath = sf('get', objectId, 'script.filePath');
    fid = fopen(filePath,'w');
    fwrite(fid, newScript);
    fclose(fid);
      
    hEditor.documentSetDirty(objectId,false);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = get_bkpt_prop_str(varargin)

result = [];
inferDbgMode = [];

if nargin > 0
    inferDbgMode = varargin{1};
else
    inferDbgMode = eml_man('infer_dbg');
end

if inferDbgMode
    result = 'script.inferBkpts';
else
    result = 'script.breakpoints';
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function result = model_dirty(objectId)

result = [];

% We don't have to do anything here.


return;
