function result = sf_debugger_trap(method,machineId)

% Copyright 2003 The MathWorks, Inc.

persistent sDebuggerTrapStatus

if(isempty(sDebuggerTrapStatus))
    sDebuggerTrapStatus.inWhileLoop = 0;
    sDebuggerTrapStatus.atCommandPrompt = 0;
    sDebuggerTrapStatus.getOutOfLoop = 0;
end

result = 0;

if(nargin==0)
    method = 'status';
end

switch(method)
    case 'status'
        result = sDebuggerTrapStatus;
        return;
    case 'enter'
        sDebuggerTrapStatus.getOutOfLoop = 0;
        % fall thru
    case 'exit'
        sDebuggerTrapStatus.getOutOfLoop = 1;
        return;
end

               
prompStr = 'sfdb> ';

try,
    while(1)
        sDebuggerTrapStatus.inWhileLoop = 1;
        
        % Break out of while loop
        if(sDebuggerTrapStatus.getOutOfLoop) 
            break;
        end
        
        sDebuggerTrapStatus.atCommandPrompt = 1;
        inpStr = input(prompStr, 's');
        sDebuggerTrapStatus.atCommandPrompt = 0;

        disp(' '); 
        tokens = tokens_in_string(inpStr);            
        if isempty(tokens)
            continue;
        end
        
        cmd = tokens{1};
        
        switch cmd
            case {'break_out_of_while_loop'}
                sDebuggerTrapStatus.getOutOfLoop = 1;
                %break;
            case {'s', 'n', 'step','next','dbstep'}
                sfdebug('gui','step_over',machineId);
                %break;
            case {'si'}
                sfdebug('gui','step',machineId);
                %break;
            case {'so'}
                sfdebug('gui','step_out',machineId);
                %break;
            case {'c', 'cont','continue', 'go','dbcont'}
                sfdebug('gui','go',machineId);
                %break;
            case {'q', 'stop', 'exit', 'quit','dbquit'}
                sfdebug('gui','stop_debugging',machineId);
                %break;
            case {'clear','dbclear'}
                sfdebug('gui','disable_all_breakpoints',machineId);
            case 'break_chart_entry'
                sfdebug('gui','chart_entry',machineId);
            case {'b', 'breakpoint'}
                emlId = str2num(tokens{2});
                breakpoint = str2num(tokens{3});
                chartId = sf('get', emlId, '.chart');
                sfdebug('sf', 'eml_breakpoint', machineId, chartId, emlId, breakpoint, 1);
            case {'rb', 'remove'}
                emlId = str2num(tokens{2});
                breakpoint = str2num(tokens{3});
                chartId = sf('get', emlId, '.chart');
                sfdebug('sf', 'eml_breakpoint', machineId, chartId, emlId, breakpoint, 0);
            case {'p', 'print'}
                if length(tokens) > 1
                    dataVal = sfdebug('mex', 'watch_data', machineId, tokens{2});
                    disp(dataVal);
                end
            case 'sfdbui'
                hDebugger = sf('get',machineId,'machine.debug.dialog');
                if ishandle(hDebugger)
                    if strcmp(get(hDebugger, 'Visible'), 'on') 
                        set(hDebugger, 'Visible', 'off');
                    else
                        set(hDebugger, 'Visible', 'on');
                    end
                end
            otherwise
                if ~isempty(regexp(inpStr, '^\s*sf\s*\(\s*'''))
                    eval_in_base(inpStr);
                    continue;
                end
                
                if ~isempty(regexp(inpStr, '^\s*[a-zA-Z]\w*\s*$')) || ...
                        ~isempty(regexp(inpStr, '^\s*[a-zA-Z]\w*\s*\([\w\s:,]+\)\s*$'))
                    [s e] = regexp(inpStr, '[a-zA-Z]\w*');
                    dataName = inpStr(s(1):e(1));
                    dataVal = sfdebug('mex', 'watch_data', machineId, dataName);
                    if ~ischar(dataVal) || ~strcmp(dataVal, 'Unrecognized symbol.')
                        eval_watch_data(inpStr, dataName, dataVal);
                        continue;
                    end
                end
                
                eval_in_base(inpStr);
        end
    end
catch,
    disp(lasterr);
end

sDebuggerTrapStatus.atCommandPrompt = 0;
sDebuggerTrapStatus.getOutOfLoop = 0;
sDebuggerTrapStatus.inWhileLoop = 0;
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tokens = tokens_in_string(str)

r = str;
tokens = {};

while ~isempty(r)
    [t, r] = strtok(r);
    
    if ~isempty(t)
        tokens{end+1} = t;
    end
end

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eval_in_base(evalStr)

try,
    evalin('base', evalStr);
catch,
    disp(lasterr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function eval_watch_data(evalStr, dataName, dataVal)

evalc([dataName ' = dataVal']);
try,
    eval(evalStr);
catch,
    disp(lasterr);
end
