function HilBlkGetCcsHandle(blk)

% Copyright 2003-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:40 $

UDATA = get_param(blk,'UserData');
PDATA = HilBlkPersistentData(blk,'get');

if PDATA.ccsObjStale, 
    
    % Handle to CCS
    try 
        c = ccsboardinfo;
    catch
        error('Error connecting to Code Composer Studio(R).')
    end
    
    boardIndex = HilBlkFindBoardOrProc(c,UDATA.boardName);
    if boardIndex==-1,
        error(['The specified board does not exist in ' ...
                'Code Composer Studio(R) Setup.'])
    end
    procIndex = HilBlkFindBoardOrProc(c(boardIndex).proc,UDATA.procName);
    if procIndex==-1,
        error(['The specified processor does not exist on this board in ' ...
                'Code Composer Studio(R) Setup.'])
    end
    % Constructor boardnum and procnum are different from struct indices
    boardNum = c(boardIndex).number;
    procNum = c(boardIndex).proc(procIndex).number;
    
    try
        PDATA.ccsObj = ccsdsp('boardnum',boardNum,'procnum',procNum);
    catch
        error('Error connecting to Code Composer Studio(R).')
    end
    
    if isfield(UDATA,'typedefList'),
        PDATA.ccsObj = addTypesToCcsObj(PDATA.ccsObj,UDATA.typedefList);
    end
    PDATA.ccsObjStale = false;
    HilBlkPersistentData(blk,'set',PDATA);
    
    UDATA.procFamily = HilBlkGetProcFamily(PDATA.ccsObj);
    
    set_param(blk,'UserData',UDATA);
    mdlName = HilBlkGetParentSystemName(blk);
    set_param(mdlName,'Dirty','on');
    
    
end

% ------------------------------------------------------
function cc = addTypesToCcsObj(cc,typedefList)
% Add stored typedef info from UserData into the new CCS object.

warnMode = warning;
lw1 = lastwarn;
% Don't display warning:
%     "Warning: 'Void' already exists in the type list, 
%        information will be overwritten."
warning off;

for k = 1:length(typedefList),
    cell1 = typedefList(k);
    typedefInfo = cell1{1}; % An unnecessary layer?
    typeName  = typedefInfo.name;
    typeEquiv = typedefInfo.basetype.type;
    add(cc.type, typeName, typeEquiv);
end

lw2 = lastwarn;
warning(warnMode);
if ~isempty(lw2) && ~isequal(lw1,lw2), 
    if isempty(findstr(lw2,'already exists in the type list')),
        % Unexpected warning; re-issue it.
        warning(lw2);
    end
end
