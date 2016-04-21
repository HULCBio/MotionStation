function HilBlkInitFcn
% Implements block's "InitFcn" callback. 
% (Executed when you Ctrl-D, before the mask init callback, before port
% connectivity is checked.  Not when you open the model, nor when you open
% the dialog.)

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:26 $

blk = gcb;

UDATA = get_param(blk,'UserData');

if ~isempty(UDATA.guiHandle) && ishandle(UDATA.guiHandle), 
    
    % Press button in gui
    % (incorporates HilBlkSetUpLinkObjects())
    HilBlkGui('queryButtonTag_Callback',UDATA.guiHandle, ...
        [],guidata(UDATA.guiHandle));
    
else
    
    % Just do the non-GUI portion of the initialization 
    HilBlkSetUpLinkObjects(blk);
    
end
