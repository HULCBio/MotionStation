function [numInports, inports, numOutports, outports] = HilBlkPortInfo(blk);
% This function is called during the Mask Init function 
% to help determine port settings
% based on information in mask and UserData.
% (UserData is partially populated in HilBlkSetUpHandles.m when 
%  "Query target ..." is clicked, but 
%  the UserData contents may be left over from a previous session
%  if the model is opened freshly.)
% Cache this new info in PDATA (persistent m-variable)

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:47 $


inports = []; numInports = 0;
outports = []; numOutports = 0;

UDATA =  get_param(blk,'UserData');

if ~isempty(UDATA.funcName) && UDATA.tgtQueried,
    if UDATA.hasReturnValue,
        % Assign first outport to func return value
        procFamily = UDATA.procFamily;
        typeInfo = UDATA.retval.typeInfo;
        [numOutports outports] = addPort( ...
            numOutports,outports,UDATA.retval,-1);
    end
    % Loop over func args and assign to ports
    for k=1:UDATA.numArgs,
        arg = UDATA.args(k); 
        switch arg.portAssign
            case 'Input port',
                [numInports inports]     = addPort( ...
                    numInports,inports,arg,k);
                UDATA.args(k).inportIdx  = numInports;
                UDATA.args(k).outportIdx = -1;
            case 'Output port',
                [numOutports outports] = addPort( ...
                    numOutports,outports,arg,k);
                UDATA.args(k).inportIdx  = -1;
                UDATA.args(k).outportIdx = numOutports;
            case 'Input and output ports',
                [numInports inports] = addPort( ...
                    numInports,inports,arg,k);
                [numOutports outports] = addPort( ...
                    numOutports,outports,arg,k);
                UDATA.args(k).inportIdx  = numInports;
                UDATA.args(k).outportIdx = numOutports;
        end
    end
end

sysName = HilBlkGetParentSystemName(blk);
if ~strcmp(get_param(sysName,'blockdiagramtype'), 'library'),
    % Add information to PDATA, UDATA, RTWdata.
    PDATA = HilBlkPersistentData(blk,'get');
    PDATA.numInports  = numInports;
    PDATA.numOutports = numOutports;
    PDATA.inports     = inports;
    PDATA.outports    = outports;
    HilBlkPersistentData(blk,'set',PDATA);
    if ~isequal(UDATA,get_param(blk,'UserData')),
        set_param(blk,'UserData',UDATA);
        mdlName = HilBlkGetParentSystemName(blk);
        set_param(mdlName,'Dirty','on');
    end
    s = HilBlkGetRtwData(blk);
    set_param(blk,'RTWdata',s);
end

%--------------------------------------------------------
function [numPorts, portList] = addPort(numPorts,portList,arg,argIdx)
% Can be used for inports or outports.

[slTypeId, mxTypeId] = HilBlkGetTypeIds(arg.equivType);

numPorts = numPorts + 1;
portList(numPorts).argIdx     = argIdx;
portList(numPorts).name       = arg.name;
portList(numPorts).equivType  = arg.equivType;
portList(numPorts).slTypeId   = slTypeId; 
portList(numPorts).mxTypeId   = mxTypeId;
portList(numPorts).typeInfo   = arg.typeInfo;
if arg.isPtr,
    if ~isa(arg.size,'uint32'),       % A favor to the S-function
        warning('size param in UserData must be uint32 vector length 2')
    end
    portList(numPorts).size = arg.size;
    if ~strcmp(arg.name,'Return value'),
        switch arg.storageOption,
            case 'Automatic',
                % NOP
            case 'Global variable',
                portList(numPorts).globVarName = arg.globVarName;
            case 'Specify address',
                portList(numPorts).address     = arg.address;
        end
    end
else % scalar passed by value:
    portList(numPorts).size = uint32([1 1]);
end                    
