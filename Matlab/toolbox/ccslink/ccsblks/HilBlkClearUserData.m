function HilBlkClearUserData(blk)

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:18 $


% Clear certain UserData block params.
% This is done when the function name changes.

UDATA_old = get_param(blk,'UserData');

UDATA.tgtQueried = false;
UDATA.numArgs = 0;
UDATA.args = [];
UDATA.hasReturnValue = false;
UDATA.declAutoDetermined = true;
UDATA.funcDecl = '';
UDATA.funcName = '';
UDATA.sourceFiles = {};  
UDATA.typedefList = {};
UDATA.funcTimeout = 30;

% Don't clear these if they are populated
if ~isfield(UDATA_old,'boardName') || ...
        isempty(UDATA_old.boardName),
    UDATA.boardName = '';
else
    UDATA.boardName = UDATA_old.boardName;
end
if ~isfield(UDATA_old,'procName') || ...
        isempty(UDATA_old.procName),
    UDATA.procName = '';
else
    UDATA.procName = UDATA_old.procName;
end
if ~isfield(UDATA_old,'procFamily') || ...
        isempty(UDATA_old.procFamily),
    UDATA.procFamily = '';
else
    UDATA.procFamily = UDATA_old.procFamily;
end
if ~isfield(UDATA_old,'guiHandle') || ...
        isempty(UDATA_old.guiHandle),
    UDATA.guiHandle = [];
else
    UDATA.guiHandle = UDATA_old.guiHandle;
end

if ~isequal(UDATA_old,UDATA),
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
end
