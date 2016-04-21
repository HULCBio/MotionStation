function HilBlkCloseGui(blk)

UDATA = get_param(blk,'UserData');

if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle), 
    
    close(UDATA.guiHandle);
    UDATA.guiHandle = [];
    set_param(blk,'UserData',UDATA);  % Does not make the model dirty
    
end

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:19 $
