function s = HilBlkGetRtwData(blk)
% Creates structure of strings to be placed in 
% the "RTWdata" property of the block.
% This information is used by TLC.
% The structure must contain only string fields.

% Copyright 2003-2004 The MathWorks, Inc.

% RTWdata structure fields:
% s.funcName                  "<name>"
% s.funcDecl                  "<string>"
% s.numArgs                   "<val>"
%     s.arg1_name             "<name>"
%     s.arg1_isPtr            "0"/"1"
%     s.arg1_portAssign       ...
%     s.arg1_inportIdx        "<val>" (1-based; -1 if none)
%     s.arg1_outportIdx       "<val>" (1-based; -1 if none)
%     s.arg1_length           "<val>"
%     s.arg2_  ... ... ...
% s.hasReturnVale             "0"/"1"
%     s.isReturnValuePointer  "0"/"1"
%         s.returnValueLength "<val>"

PDATA = HilBlkPersistentData(blk,'get');
UDATA = get_param(blk,'UserData');

s.funcName        = UDATA.funcName;
s.funcDecl        = UDATA.funcDecl;
s.numArgs         = num2str(UDATA.numArgs);
% s.numInports    = num2str(PDATA.numInports);
% s.numOutports   = num2str(PDATA.numOutports);
for k = 1:UDATA.numArgs,
    ks = num2str(k);
    eval(['s.arg' ks '_name       = ' ...
            'UDATA.args(' ks ').name;']);
    eval(['s.arg' ks '_isPtr      = ' ...
            'num2str(UDATA.args(' ks ').isPtr);']);
    eval(['s.arg' ks '_portAssign = ' ...
            'UDATA.args(' ks ').portAssign;']);
    len = prod(double(UDATA.args(k).size));
    eval(['s.arg' ks '_length     = ' ...
            'num2str(len);']);
    eval(['s.arg' ks '_inportIdx  = ' ...
            'num2str(UDATA.args(' ks ').inportIdx);']);
    eval(['s.arg' ks '_outportIdx = ' ...
            'num2str(UDATA.args(' ks ').outportIdx);']);
end
s.hasReturnValue = num2str(UDATA.hasReturnValue);
if UDATA.hasReturnValue,
    s.isReturnValuePointer = num2str(UDATA.retval.isPtr);
    if UDATA.retval.isPtr,
        len = prod(double(UDATA.retval.size));
        s.returnValueLength = num2str(len);
    end
end
