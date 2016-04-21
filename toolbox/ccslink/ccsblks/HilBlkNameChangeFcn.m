function HilBlkNameChangeFcn
% Implements block's "NameChangeFcn" callback. 

% Copyright 2003 The MathWorks, Inc.
% $Revision: 1.1.10.2 $ $Date: 2004/04/08 20:44:28 $
blk = gcb;

UDATA = get_param(blk,'UserData');

if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle), 
    
    g = guidata(UDATA.guiHandle);
    % Update name in title bar of GUI
    set(g.HilBlkFigureTag,'Name',blk);
    % Update name in GUI UserData
    set(g.HilBlkFigureTag,'UserData',blk);
    
end
