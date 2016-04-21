function varargout = HilBlkOutputFcn(varargin)
% Output function for HIL Block.
% This function is called from the s-function
% (via mexCallMATLAB).
% ins and outs are cell arrays whose elements 
% are numeric arrays corresponding to port signals.

% Copyright 2003-2004 The MathWorks, Inc.

ins = varargin;

blk = gcb;
PDATA = HilBlkPersistentData(blk,'get');
UDATA = get_param(blk,'UserData');

% --- Write inputs --- 

if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle), 
    handles = guidata(UDATA.guiHandle);
    set(handles.statusTextTag,'string', ...
        ['Writing input port data to target ' ...
            'for function "' UDATA.funcName '"']);
else
    handles = [];  % Indicates that gui is not open
end

for k = 1:PDATA.numInports,
    inputVarObj = PDATA.inports(k).obj;
    arg = UDATA.args(PDATA.inports(k).argIdx);
    if arg.isPtr,
        % Place address in register
        addr = PDATA.inports(k).addr;
        write(inputVarObj,addr(1)); 
        % Write data 
        timeoutVal = max(10,30*prod(double(size(ins{k})))/1000);
        write(PDATA.ccsObj,addr,ins{k},timeoutVal);
    else % pass by value:
        % Write data directly to register/stack
        % (using data object method because 
        % the object may or may not be a pointer.)
        write(inputVarObj,ins{k});
    end
end

% Set up pointers in registers for any output arrays
%  (Input-and-output args have been done already)
%  (Skip "return value," because its address 
%    *is* the return value.)
for k = 1:PDATA.numOutports,
    if ~(k==1 && UDATA.hasReturnValue),
        arg = UDATA.args(PDATA.outports(k).argIdx);
        if arg.isPtr && strcmp(arg.portAssign,'Output port'),
            % Place address in register
            outputVarObj = PDATA.outports(k).obj;
            addr = PDATA.outports(k).addr;  
            write(outputVarObj,addr(1)); 
        end
    end
end

if ~isempty(handles),
    set(handles.statusTextTag,'string', ...
        ['Executing function "' UDATA.funcName '" on target']);
end

% --- Execute function --- 
dummyStr = 'dummyStringIndicatingRunFailure';
retVal = dummyStr;
lastwarn('');
try
    retVal = run(PDATA.tgtFcnObj);
catch
    disp(lasterr);
    if isempty(findstr(lasterr, ...
            'One or more output arguments not assigned' )),
        error('Error running function on target.  See MATLAB command window for details.')
    end  % Else, continue
end
if ( ~exist('retVal','var') || isequal(retVal,dummyStr) || isempty(retVal)) && ...
    ~isempty(findstr(lastwarn,'A breakpoint within the function')),
    % User must have set a breakpoint within the function.
    msg = ['The CPU halted, but the PC is not at the return address.  \n' ...
           'It is assumed that you are debugging in Code Composer ' ...
           'Studio IDE.  \n' ...
            'When you are finished debugging, hit "OK" to resume ' ...
            'CPU execution.  \n\n' ...
            '(You must use this button to resume; an error will ' ...
            'result if you resume execution in Code Composer Studio.)'];
    uiwait(errordlg(sprintf(msg), ...
        'HIL Function Call Block','modal'));
    lastwarn('');
    % Try again.
    try
        retVal = resume(PDATA.tgtFcnObj);
    catch
        disp(lasterr);
        error('Error running function on target.  See MATLAB command window for details.')
    end
end
if ~exist('retVal','var') || ...
        ~isempty(findstr(lastwarn,'A breakpoint within the function')),
    error(['Encountered unexpected CPU halt.  If you are using ' ...
            'breakpoints in Code Composer Studio, you must resume ' ...
            'execution only using MATLAB.'])
end

if ~isempty(handles),
    set(handles.statusTextTag,'string', ...
        ['Reading output port data from target for function "' ...
            UDATA.funcName '"']);
end

% --- Read outputs --- 
for k = 1:PDATA.numOutports,
    typek = PDATA.outports(k).equivType;
    sizek = PDATA.outports(k).size;
    if k==1 && UDATA.hasReturnValue,
        % Return value
        arg = UDATA.retval;
        if arg.isPtr,
            addrk = retVal;
            varargout{k} = read(PDATA.ccsObj,addrk,typek,sizek);
        else 
            % not a pointer; just read the value
            varargout{k} = retVal; 
        end    
    else
        % Output port that is really an input arg pointer
        arg = UDATA.args(PDATA.outports(k).argIdx);
        addrk = PDATA.outports(k).addr;  
        timeoutVal = max(10,30*prod(double(sizek))/1000);
        varargout{k} = read(PDATA.ccsObj,addrk,typek,sizek,timeoutVal);
    end
    % Since some read methods return double, ensure that
    % the data is actually of the correct MATLAB native type
    varargout{k} = feval(typek,varargout{k});
end

if ~isempty(handles),
    set(handles.statusTextTag,'string', ...
        'Completed simulation time step');
end
