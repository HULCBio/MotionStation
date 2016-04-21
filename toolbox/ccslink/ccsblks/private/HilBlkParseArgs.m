function HilBlkParseArgs(blk)
% Parse new function object properties and update UserData info
% relating to the function arguments.  
% Assumes that function is fully declared.
% For some properties, the values are unchanged if they are not
% already set.  To reset an arg field to default values, first call
% HilBlkClearUserData.
%
% This code is modularized because it is shared 
% between multiple GUI callbacks and the block init function.  

% Copyright 2003-2004 The MathWorks, Inc.


UDATA = get_param(blk,'UserData');
PDATA = HilBlkPersistentData(blk,'get');

if ~PDATA.tgtFcnObjFullyDeclared,
    error(['HilBlkParseArgs.m cannot be run until ' ...
        'function object is fully declared.'])
end

inputNames = PDATA.tgtFcnObj.inputnames;
UDATA.numArgs = length(inputNames);
for k = 1:UDATA.numArgs,
    UDATA.args(k).name = inputNames{k};
    argObjExpr = ['PDATA.tgtFcnObj.inputvars.' UDATA.args(k).name];
    argObj = eval(argObjExpr);
    [bool, badClass] = isObjOfSupportedClass(argObj);
    if ~bool,
        error(['Function argument "' UDATA.args(k).name '"'...
                ' is of class ' badClass ', which ' ...
                'is not supported by the HIL Function Call ' ...
                'Block.']);
    end
    UDATA.args(k).isPtr = isObjPtr(argObj);
    try    
        L = PDATA.tgtFcnObj.list(UDATA.args(k).name);
        UDATA.args(k).cType = L.type;  % XXX   can give wrong result
    catch  %  May be a library function.... try this.
        try
            UDATA.args(k).cType = eval( ...
            ['PDATA.tgtFcnObj.inputvars.' UDATA.args(k).name '.typestring']);
        catch
            UDATA.args(k).cType = '';
        end
    end
    UDATA.args(k).typeInfo = getTypeInfo(argObj);
    UDATA.args(k).equivType = HilBlkEquivNativeType( ...
        UDATA.procFamily, ...
        UDATA.args(k).typeInfo);
    % Set defaults on params that user can optionally change:
    if ~isfield(UDATA.args(k),'size') || ...
            isempty(UDATA.args(k).size),
        UDATA.args(k).size = uint32([1 1]);
    end
    if ~isfield(UDATA.args(k),'portAssign') || ...
            isempty(UDATA.args(k).portAssign),
        UDATA.args(k).portAssign = 'Input port';
    end
    if ~isfield(UDATA.args(k),'storageOption') || ...
            isempty(UDATA.args(k).storageOption),
        UDATA.args(k).storageOption = 'Global variable';
    end
    if ~isfield(UDATA.args(k),'address') || ...
            isempty(UDATA.args(k).address),
        UDATA.args(k).address = '';
    end
    if ~isfield(UDATA.args(k),'globVarName') || ...
            isempty(UDATA.args(k).globVarName),
        UDATA.args(k).globVarName = '';
    end
end
retvalProp = PDATA.tgtFcnObj.outputvar;
UDATA.hasReturnValue = ~isempty(retvalProp);
if UDATA.hasReturnValue,
    [bool, badClass] = isObjOfSupportedClass(retvalProp);
    if ~bool,
        error(['The function''s return value ' ...
                ' is of class ' badClass ', which ' ...
                'is not supported by the HIL Function Call ' ...
                'Block.']);
    end
    UDATA.retval.name = 'Return value';
    UDATA.retval.isPtr = isObjPtr(retvalProp);
    UDATA.retval.portAssign = 'Output port';
    UDATA.retval.cType = PDATA.tgtFcnObj.type;
    UDATA.retval.typeInfo = getTypeInfo(retvalProp);
    UDATA.retval.equivType = HilBlkEquivNativeType( ...
        UDATA.procFamily, ...
        UDATA.retval.typeInfo);
    if ~isfield(UDATA.retval,'size') || ...
            isempty(UDATA.retval.size),
        UDATA.retval.size = uint32([1 1]);
    end
end
UDATA.tgtQueried = true;

if ~isequal(UDATA,get_param(blk,'UserData')),
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
end


% --------------------------------------------
function typeInfo = getTypeInfo(obj);
% Get data type attributes from NUMERIC object
% and other CCS Link objects

if isObjPtr(obj),
    obj = deref(obj);
end
if isObjPtr(obj),  % If is STILL a pointer
    msg = 'Pointers to pointers are not supported';
    disp(['ERROR: ' msg])
    error(msg)
end

typeInfo.wordsize  = obj.wordsize;
typeInfo.represent = obj.represent;
typeInfo.binarypt  = obj.binarypt;
typeInfo.prepad    = obj.prepad;
typeInfo.postpad   = obj.postpad;

% --------------------------------------------
function bool = isObjPtr(obj)

bool = isa(obj,'ccs.pointer') || ...
    isa(obj,'ccs.rpointer');


% --------------------------------------------
function [bool, badClass] = isObjOfSupportedClass(obj)
% Verify that argument/retval object is of a
% supported class for this block.

badClass = '';

if ~isObjPtr(obj),
    bool = ...
        isa(obj,'ccs.numeric') || ...
        isa(obj,'ccs.rnumeric') || ...
        isa(obj,'ccs.string') || ...
        isa(obj,'ccs.rstring');
    if ~bool,
        badClass = class(obj);
    end
else  % Pointer:
    if (length(obj.typestring) >= 4) && strcmp(obj.typestring(1:4),'void'),
        bool = false;
        badClass = 'void';
    else
        % Can't access the referent directly if pointer address is
        % undefined ...
        p = getprop(obj,'referent');
        bool = isfield(p,'uclass') && strcmp(p.uclass,'numeric');
    end
    if ~bool,
        badClass = p.type;  % A hack.
    end
end
