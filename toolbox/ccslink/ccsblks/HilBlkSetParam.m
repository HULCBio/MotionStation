function HilBlkSetParam(blk,paramName,val)
%HilBlkSetParam:  Helper function for HIL Block.
%  This function allows you to set block parameters without
%  opening the GUI.  This is provided for testing purposes.
%  Most of the block parameters are not implemented here.
%  You can add functionality as needed.
%
%  If you need a block parameter to be accessible via this
%  function, be sure to reproduce all the callback activity
%  along with the change to UserData.  Consider all dependencies
%  within the other block parameters in UserData and PDATA.
%
%  Note that we do not update the model's "Dirty" flag here.
%
%  In the future, this file could encapsulate much of the callback
%  activity for the widgets, and that stuff could be removed from 
%  the GUI m-files.  

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:30 $

UDATA = get_param(blk,'UserData');

if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle),
    g = get(UDATA.guiHandle);
    if isfield(g,'Tag') && strcmp(g.Tag,'HilBlkFigureTag'),
        error('Cannot use HilBlkSetParam when GUI is open')
    end
end

PDATA = HilBlkPersistentData(blk,'get');

switch paramName
    case 'tgtQueried',
        
        error(['Param name ' paramName ' not writable.']);
        
    case 'numArgs',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'args',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'hasReturnValue',
    
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'declAutoDetermined',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'funcDecl',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'funcName',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'sourceFiles',
        
        % No dependencies
        UDATA.sourceFiles = val;
        set_param(blk,'UserData',UDATA);
        
    case 'includePaths',
        
        % No dependencies
        UDATA.includePaths = val;
        set_param(blk,'UserData',UDATA);
        
    case 'boardName',
        
        UDATA.boardName = val;
        c = ccsboardinfo;
        boardIndex = -1;
        for k = 1:length(c),
            if strcmp(c(k).name,val),
                boardIndex = k;
                break;
            end
        end
        procName = c(boardIndex).proc(1).name;
        UDATA.procName = procName;
        set_param(blk,'UserData',UDATA);
        PDATA.ccsObjStale = true;
        PDATA.tgtFcnObjStale = true;
        HilBlkPersistentData(blk,'set',PDATA);
        
    case 'procName',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'procFamily',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'retval',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'lastSelectedTab',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    case 'guiHandle',
        
        error(['Param name ' paramName ... 
                ' not yet implemented in HilBlkSetParam.m.']);
        
    otherwise,
        
        error(['Param name ' paramName ' not recognized.']);
        
end
