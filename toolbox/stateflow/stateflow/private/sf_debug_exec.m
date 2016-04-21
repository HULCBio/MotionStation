function breakLoop = sf_debug_exec(cmdStr, machineId, populateWS)
% cmdStr:     The input command string.
%             NOTE: It MUST contain no heading and tailing white space.
% machineId:  The id of current debugging machine 
% populateWS: Populate workspace for this command

% Copyright 2003-2004 The MathWorks, Inc.

breakLoop = 0;

if isempty(cmdStr)
    return;
end

% This rely on the instant entry and exit of infer debug mode
% User should have no control of change this mode. And should
% guard against any error in infer dbg to turn this mode back off.
isEmlInferDbgMode = eml_man('infer_dbg');

try,
    tokens = strread(cmdStr, '%s');
    cmd = regexprep(tokens{1}, '^(.*?)[,;]*$', '$1');
    
    switch cmd
        case 'dbstep'
            if ~isEmlInferDbgMode
                if(length(tokens)==1)
                    sfdebug('gui','step_over',machineId);
                else
                    cmdModifier = tokens{2};
                    switch(cmdModifier)
                        case 'in'
                            sfdebug('gui','step',machineId);
                        case 'out'
                            sfdebug('gui','step_out',machineId);
                    end
                end
            end
            breakLoop = 1;
        case 'dbcont'
            if isEmlInferDbgMode
                sf('EmlInferDbgGo');
            else
                sfdebug('gui','go',machineId);
            end
            breakLoop = 1;
        case {'dbquit', 'exit', 'quit'}
            if isEmlInferDbgMode
                sf('EmlInferDbgGo'); % For now, until eml infer dbg stop is implemented
            else
                sfdebug('gui','stop_debugging',machineId);
            end
            lastCmdStr = ''; % Clear last keyboard command
            breakLoop = 1;
        case 'print'
            if length(tokens) > 1
                if ~isEmlInferDbgMode
                    dataVal = sfdebug('mex', 'watch_data', machineId, tokens{2});
                    disp(dataVal);
                end
            end
        case 'clear'
            % Disallow "clear" command
            disp('Warning: ''clear'' command is disabled at Stateflow/Embedded MATLAB debugger prompt.');
        case {'whos'}
            if ~isEmlInferDbgMode
                if length(tokens) > 1
                    % For non singleton "whos" command, handle with TMW interpeter
                    sf_debug_eval(cmdStr, machineId, populateWS);
                else
                    % Make up SF's own "whos" text for better performance 
                    dataInfo = sfdebug('mex', 'whos', machineId);
                    whosStr = print_whos_string(dataInfo, machineId);
                    disp(whosStr);
                end
            end
        case 'help'
            disp(get_help_str);
        case 'sfdbui'
            if ~isEmlInferDbgMode
                hDebugger = sf('get',machineId,'machine.debug.dialog');
                if ishandle(hDebugger)
                    if strcmp(get(hDebugger, 'Visible'), 'on')
                        set(hDebugger, 'Visible', 'off');
                    else
                        set(hDebugger, 'Visible', 'on');
                    end
                end
            end
        otherwise
            sf_debug_eval(cmdStr, machineId, populateWS);
    end
catch,
    disp(lasterr);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sf_debug_eval(cmdStr, machineId, populateWS)

sfDbgEvalWsData = {};

if populateWS > 1
    % Populate all available SF data in current scope
    sfDbgEvalWsData = sfdebug('mex', 'whos', machineId, 1);
elseif populateWS == 1
    % Populate only necessary
    possibleSfData = unique(regexp(cmdStr, '[a-zA-Z]\w*', 'match'));

    for i = 1:length(possibleSfData)
        dataName = possibleSfData{i};
        dataVal = sfdebug('mex', 'watch_data', machineId, dataName);

        if ~ischar(dataVal) || ~strcmp(dataVal, 'Unrecognized symbol.')
            sfDbgEvalWsData{end+1}.name = dataName;
            sfDbgEvalWsData{end}.value = dataVal;
        end
    end
end

sf_debug_eval_kernel(cmdStr, sfDbgEvalWsData);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sf_debug_eval_kernel(m_sfDebugEvalStr_, m_sfDebugEvalWorkspaceData_)

try,
    % Populate workspace data for eval
    for m_sfDebugEvalLoopIdx_ = 1:length(m_sfDebugEvalWorkspaceData_)
        m_sfDebugEvalCapture = ...
            evalc([m_sfDebugEvalWorkspaceData_{m_sfDebugEvalLoopIdx_}.name ...
                   ' = m_sfDebugEvalWorkspaceData_{m_sfDebugEvalLoopIdx_}.value;']);
    end
    
    m_sfDebugEvalStr_ = ['clear m_sfDebugEvalLoopIdx_ m_sfDebugEvalStr_ ' ...
                         'm_sfDebugEvalWorkspaceData_ m_sfDebugEvalCapture; ' ...
                         m_sfDebugEvalStr_];
    eval(m_sfDebugEvalStr_);
catch,
    disp(lasterr);
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dataInfo = get_ml_data_info(dataInfo, machineId)
% Get data class name and bytes

dataVal = sfdebug('mex', 'watch_data', machineId, dataInfo.name);
info = whos('dataVal');

nDim = length(info.size);
if nDim > 3
    dataInfo.size = sprintf('%d-D', nDim);
else
    dataInfo.size = sprintf('%dx', info.size);
    dataInfo.size(end) = '';
end
dataInfo.class = [info.class ' (ml)'];
dataInfo.bytes = sprintf('%d', info.bytes);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function whosStr = print_whos_string(dataInfo, machineId)

whosStr = '';
if isempty(dataInfo)
    return;
end

if ~iscell(dataInfo)
    dataInfo = {dataInfo};
end

nameField{1} = 'Name';    nameField{2} = '';
sizeField{1} = 'Size';    sizeField{2} = '';
bytesField{1} = 'Bytes';  bytesField{1} = fliplr(bytesField{1}); bytesField{2} = '';
classField{1} = 'Class';  classField{2} = '';

numData = length(dataInfo);

for i = 1:numData
    thisDataInfo = dataInfo{i};
    
    if strcmp(thisDataInfo.class, 'ml')
        thisDataInfo = get_ml_data_info(thisDataInfo, machineId);
    end
    
    nameField{2+i} = thisDataInfo.name;
    sizeField{2+i} = thisDataInfo.size;
    bytesField{2+i} = fliplr(thisDataInfo.bytes); % fliplr for right alignment
    classField{2+i} = thisDataInfo.class;
end

nameFieldStr = char(nameField);
sizeFieldStr = char(sizeField);
bytesFieldStr = fliplr(char(bytesField));
classFieldStr = char(classField);

numRows = length(nameField);
for i = 1:numRows
    whosStr = sprintf('%s  %s      %s               %s  %s\n', ...
                      whosStr, ...
                      nameFieldStr(i,:), ...
                      sizeFieldStr(i,:), ...
                      bytesFieldStr(i,:), ...
                      classFieldStr(i,:));
end

whosStr = sprintf('%s\nGrand total is %d data in scope\n', whosStr, numData);

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = get_help_str(helpCmd)
  
helpFile = 'sf_debug_help.txt';

fd = fopen(helpFile, 'r');
F = fread(fd);
fclose(fd);

str = char(F');
