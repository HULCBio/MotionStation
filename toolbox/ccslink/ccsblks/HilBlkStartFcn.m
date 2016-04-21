function HilBlkStartFcn
% StartFcn callback for HIL Block.
% 
% Adds the following information to persistent m-variable:
%           PDATA.inports(k).obj 
%           PDATA.inports(k).addr     (only if pointer)
%           PDATA.outports(k).obj 
%           PDATA.outports(k).addr     (only if pointer)
% in addition to what is already there, i.e.,
%           PDATA.ccsObj 
%           PDATA.tgtFcnObj 

% Copyright 2003-2004 The MathWorks, Inc.

blk = gcb;

PDATA = HilBlkPersistentData(blk,'get');
UDATA = get_param(blk,'UserData');
if isempty(UDATA.funcName),
    error('No function specified')
end

% FOR EACH PORT, 
% Add input variable object, and address (if ptr),
% to PDATA
for k = 1:PDATA.numInports, 
    % corresponding function argument:
    arg = UDATA.args(PDATA.inports(k).argIdx);
    % Create object for inputvar
    try
        PDATA.inports(k).obj = eval( ...
            ['PDATA.tgtFcnObj.inputvars.' arg.name]);
    catch
        msg = ['Error accessing function ' ...
                'input ''' arg.name '''.'];
        disp(msg);
        error(msg);
    end
    if arg.isPtr,
        PDATA.inports(k).addr = getAddressForPointer( ...
            PDATA.ccsObj,PDATA.inports(k),arg);
    end
end

for k = 1:PDATA.numOutports,
    if k==1 && UDATA.hasReturnValue,  
        % --- return value ----
        try
            PDATA.outports(k).obj = PDATA.tgtFcnObj.outputvar;
        catch
            msg = ['Error accessing function''s ' ...
                    'return value.'];
            disp(msg);
            error(msg);
        end
    else
        % --- input arg that is actually output port ---
        % corresponding function argument:
        arg = UDATA.args(PDATA.outports(k).argIdx);
        % Create object for input arg
        try
            PDATA.outports(k).obj = eval( ...
                ['PDATA.tgtFcnObj.inputvars.' arg.name]);
        catch
            msg = ['Error accessing function '...
                    'input argument ''' arg.name '''.'];
            disp(msg);
            error(msg);
        end
        if arg.isPtr,
            PDATA.outports(k).addr = getAddressForPointer( ...
                PDATA.ccsObj,PDATA.outports(k),arg);
        end
    end
end

HilBlkPersistentData(blk,'set',PDATA);


% ------------------------------------------------------
function addr = getAddressForPointer(ccsObj,port,arg)

switch arg.storageOption,
    case 'Automatic',
        error('Automatic storage not supported yet.')
        % port.addr = ?
    case 'Global variable',
        if isempty(port.globVarName), 
            error(['You have not specified a global variable name for ' ...
                'storage for argument "' port.name '".']);
        end
        msg = ['Error obtaining address for ' ...
                'global variable ''' port.globVarName '''.'];
        try
            addr = address(ccsObj,port.globVarName);
        catch
            disp(msg);
            error(msg);
        end
        if isempty(addr),
            disp(msg);
            error(msg);
        end
        %addr = addr(1);  % Ignore page
        if addr==0
            msg = ['Encountered null address for ' ...
                    'global variable ''' port.globVarName '''.'];
            disp(msg);
            error(msg);
        end
    case 'Specify address',
        addr = arg.address;
end
